import { socket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Context } from '@kit.AbilityKit';
import { HttpServerHandler } from './HttpServerHandler';
import { HttpRequestQueueManager } from './dispatch';

export type HttpResponseData = string | Uint8Array;
export type HttpRequestHandler = (requestRaw: string) => Promise<HttpResponseData> | HttpResponseData;

// 内部接口和类，不导出
interface IHttpServer {
  start(port: number, handler?: HttpRequestHandler): Promise<void>;
  stop(): void;
  isRunning(): boolean;
}

class HttpServer implements IHttpServer {
  private server: socket.TCPSocketServer = socket.constructTCPSocketServerInstance();
  private running: boolean = false;
  private port: number = 0;
  private handler: HttpRequestHandler | undefined;

  async start(port: number, handler?: HttpRequestHandler): Promise<void> {
    if (this.running) return;
    this.port = port;
    this.handler = handler ?? defaultHtmlHandler;

    const listenAddr: socket.NetAddress = {
      address: '0.0.0.0',
      port: port,
      family: 1
    };

    await new Promise<void>((resolve, reject) => {
      this.server.listen(listenAddr, (err: BusinessError) => {
        if (err) {
          reject(err);
          return;
        }
        this.running = true;
        resolve();
      })
    });

    this.server.on('connect', (clientSocket: socket.TCPSocketConnection) => {
      const onMessage = (msgInfo: socket.SocketMessageInfo) => {
        // 异步处理请求，避免阻塞主线程
        const request = buf2String(msgInfo.message);
        // 使用 Promise 的微任务将处理延迟到下一个事件循环，确保不阻塞主线程
        const promise: Promise<void> = Promise.resolve().then(async () => {
          try {
            const handlerResult = (this.handler as HttpRequestHandler)(request);
            const response = handlerResult instanceof Promise ? await handlerResult : handlerResult;
            if (this.running && clientSocket) {
              clientSocket.send({ data: response });
            }
          } catch (error) {
            // 错误处理，返回500错误
            const errorObj: Error | BusinessError | object = error as Error | BusinessError | object;
            hilog.error(0x0000, 'HttpServer', `Request handler error: ${JSON.stringify(errorObj)}`);
            try {
              if (this.running && clientSocket) {
                const errorResponse = 'HTTP/1.1 500 Internal Server Error\r\n\r\n';
                clientSocket.send({ data: errorResponse });
              }
            } catch (sendError) {
              const sendErrorObj: Error | BusinessError | object = sendError as Error | BusinessError | object;
              hilog.error(0x0000, 'HttpServer', `Failed to send error response: ${JSON.stringify(sendErrorObj)}`);
            }
          }
        });
        // 静默处理 Promise 拒绝，避免未捕获的 Promise 警告
        promise.then(() => {
          // Promise 成功处理，无需额外操作
        }, (rejectedValue: Error | BusinessError | object) => {
          // 处理 Promise 拒绝，但这里应该不会发生，因为我们已经 catch 了所有错误
          hilog.error(0x0000, 'HttpServer', `Promise rejected: ${JSON.stringify(rejectedValue)}`);
        });
      };

      clientSocket.on('message', onMessage);
      
      // 处理连接断开事件
      clientSocket.on('close', () => {
        // 移除监听，避免长时间保持引用导致内存上涨
        clientSocket.off('message', onMessage);
        hilog.info(0x0000, 'HttpServer', 'Client socket closed');
      });
      
      // 处理错误事件
      clientSocket.on('error', (error: BusinessError) => {
        hilog.error(0x0000, 'HttpServer', `Socket error: ${JSON.stringify(error)}`);
      });
    });
  }

  stop(): void {
    if (!this.running) return;
    this.server.off('connect');
    this.running = false;
  }

  isRunning(): boolean {
    return this.running;
  }
}

// 内部单例，不导出
const httpServer = new HttpServer();

function defaultHtmlHandler(content: string): string {
  let result: string = "";
  let bodyContent = "<html>";
  bodyContent += "<head>";
  bodyContent += "<title>";
  bodyContent += "HTTP服务器模拟";
  bodyContent += "</title>";
  bodyContent += "</head>";
  bodyContent += "<body>";
  bodyContent += "<h1>";
  bodyContent += "浏览器发送的请求信息";
  bodyContent += "</h1>";
  bodyContent += "<pre><h2>";
  bodyContent += content;
  bodyContent += "</h2></pre>";
  bodyContent += "</body>";
  bodyContent += "</html>";

  const textEncoder = new util.TextEncoder();
  const contentBuf = textEncoder.encodeInto(bodyContent);

  result += "HTTP/1.1 200 OK \r\n";
  result += "Content-Type: text/html; charset=utf-8 \r\n";
  result += `Content-Length: ${contentBuf.length} \r\n`;
  result += "\r\n";
  result += bodyContent;

  return result;
}

function buf2String(buf: ArrayBuffer): string {
  const msgArray = new Uint8Array(buf);
  const textDecoder = util.TextDecoder.create("utf-8");
  // 使用非废弃的 decode
  return textDecoder.decode(msgArray);
}

// ========== 纯函数式接口（对外唯一导出） ==========
export async function startHttpServer(port: number, handler?: HttpRequestHandler): Promise<void> {
  await httpServer.start(port, handler);
}

export function stopHttpServer(): void {
  httpServer.stop();
}

export function isHttpServerRunning(): boolean {
  return httpServer.isRunning();
}

// 在 TaskPool worker 中运行 HTTP 服务器监听，使用本地变量与导入依赖，满足并发约束
@Concurrent
export async function runHttpServerWorker(ctx: Context, port: number): Promise<void> {
  const server = socket.constructTCPSocketServerInstance();
  const listenAddr: socket.NetAddress = { address: '0.0.0.0', port, family: 1 };
  
  try {
    // 初始化 HTTP 请求队列管理器
    HttpRequestQueueManager.initialize();
    hilog.info(0x0000, 'HttpServerWorker', 'HTTP 请求队列管理器已初始化');
    
    HttpServerHandler.setFileBasePath(ctx);
    const handler = HttpServerHandler.createRouterHandler();

    await new Promise<void>((resolve, reject) => {
      server.listen(listenAddr, (err: BusinessError) => {
        if (err) {
          reject(err);
          return;
        }
        hilog.info(0x0000, 'HttpServerWorker', `HTTP服务器(worker)启动成功，端口: ${port}`);
        resolve();
      });
    });

    server.on('connect', (clientSocket: socket.TCPSocketConnection) => {
      let cache: Uint8Array = new Uint8Array(0);

      const tryProcess = () => {
        // 尝试解析完整HTTP请求（支持分片）
        const decoder = util.TextDecoder.create('utf-8');
        const encoded = decoder.decode(cache);
        const headerEnd = encoded.indexOf('\r\n\r\n');
        if (headerEnd < 0) {
          return; // 头部未完整
        }
        const headerText = encoded.substring(0, headerEnd);
        // 提取 Content-Length
        const lines = headerText.split('\r\n');
        let contentLength = 0;
        for (let i = 0; i < lines.length; i++) {
          const line = lines[i];
          if (line.toLowerCase().startsWith('content-length:')) {
            const v = line.split(':')[1]?.trim() || '0';
            contentLength = Number(v) || 0;
            break;
          }
        }
        // 计算字节头部长度
        const enc = new util.TextEncoder();
        const headerBytes = enc.encodeInto(encoded.substring(0, headerEnd + 4)).length;
        if (cache.length < headerBytes + contentLength) {
          return; // 正文未完整
        }
        // 切出完整请求
        const requestBytes = cache.slice(0, headerBytes + contentLength);
        const remaining = cache.slice(headerBytes + contentLength);
        cache = remaining; // 保留剩余（理论上不会有管线）
        const raw = decoder.decode(requestBytes);

        // 使用 Dispatch 队列处理请求
        // 注意：这里使用 Promise 包装，但不等待完成，避免阻塞消息处理
        HttpRequestQueueManager.executeRequest(raw, clientSocket, handler).catch((err: Error | BusinessError | object) => {
          // 错误已经在 executeRequest 中处理，这里只记录日志
          hilog.error(0x0000, 'HttpServerWorker', `请求处理异常: ${JSON.stringify(err)}`);
        });
      };

      const onMessage = (msgInfo: socket.SocketMessageInfo) => {
        try {
          const incoming = new Uint8Array(msgInfo.message);
          const merged = new Uint8Array(cache.length + incoming.length);
          merged.set(cache, 0);
          merged.set(incoming, cache.length);
          cache = merged;
          tryProcess();
        } catch (e) {
          const err = e as Error | BusinessError | object;
          hilog.error(0x0000, 'HttpServerWorker', `解析消息失败: ${JSON.stringify(err)}`);
        }
      };

      clientSocket.on('message', onMessage);
      clientSocket.on('close', () => {
        clientSocket.off('message', onMessage);
        hilog.info(0x0000, 'HttpServerWorker', '客户端连接关闭');
      });
      clientSocket.on('error', (error: BusinessError) => {
        hilog.error(0x0000, 'HttpServerWorker', `客户端错误: ${JSON.stringify(error)}`);
      });
    });

    // 防止并发函数返回导致 worker 退出：保持挂起
    await new Promise<void>(() => {});
  } catch (error) {
    const err = error as Error | BusinessError | object;
    hilog.error(0x0000, 'HttpServerWorker', `HTTP服务器(worker)启动失败: ${JSON.stringify(err)}`);
    const e = error as Error;
    throw e instanceof Error ? e : new Error(String(error));
  }
}


