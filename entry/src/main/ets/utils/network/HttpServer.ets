import { socket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';

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
        // 使用 Promise 将同步处理改为异步，避免阻塞
        Promise.resolve().then(() => {
          try {
            const response = (this.handler as HttpRequestHandler)(request);
            clientSocket.send({ data: response });
          } catch (error) {
            // 错误处理，返回500错误
            const errorResponse = 'HTTP/1.1 500 Internal Server Error\r\n\r\n';
            clientSocket.send({ data: errorResponse });
          }
        }).catch(() => {
          const errorResponse = 'HTTP/1.1 500 Internal Server Error\r\n\r\n';
          clientSocket.send({ data: errorResponse });
        });
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


