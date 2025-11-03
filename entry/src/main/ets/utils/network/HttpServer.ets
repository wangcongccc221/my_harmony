import { socket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';

export type HttpRequestHandler = (requestRaw: string) => string;

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
      clientSocket.on('message', (msgInfo: socket.SocketMessageInfo) => {
        // 异步处理请求，避免阻塞主线程
        const request = buf2String(msgInfo.message);
        // 使用 Promise 的微任务将处理延迟到下一个事件循环，确保不阻塞主线程
        const promise: Promise<void> = Promise.resolve().then(() => {
          try {
            const response = (this.handler as HttpRequestHandler)(request);
            // 检查 socket 是否仍然有效
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
      });
      
      // 处理连接断开事件
      clientSocket.on('close', () => {
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


