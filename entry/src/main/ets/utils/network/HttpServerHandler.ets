import { hilog } from '@kit.PerformanceAnalysisKit';
import { util } from '@kit.ArkTS';
import { HttpRequestHandler } from './HttpServer';

const DOMAIN = 0x0000;

/**
 * HTTP服务器请求处理器
 * 功能：处理所有HTTP请求，返回自定义响应
 * 用途：统一管理HTTP服务器的响应逻辑
 */
export class HttpServerHandler {
  /**
   * 默认HTTP请求处理器
   * 可以根据rawRequest解析请求内容，返回相应的响应
   */
  static createHandler(): HttpRequestHandler {
    return (rawRequest: string): string => {
      hilog.info(DOMAIN, 'HttpServerHandler', `收到HTTP请求: ${rawRequest.substring(0, 200)}...`);
      
      // TODO: 在这里添加你的请求处理逻辑
      // 例如：解析URL、请求方法、参数等
      // 例如：根据不同路径返回不同内容
      // 例如：调用业务逻辑处理数据
      
      // 默认响应
      return HttpServerHandler.getDefaultResponse();
    };
  }

  /**
   * 获取默认响应
   */
  static getDefaultResponse(): string {
    const htmlContent = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>HarmonyOS HTTP Server</title>
        <style>
          body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f5f5f5;
          }
          h1 {
            color: #333;
            text-align: center;
          }
          .info {
            background-color: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
          }
        </style>
      </head>
      <body>
        <div class="info">
          <h1>HarmonyOS HTTP 服务器</h1>
          <p>服务器运行正常</p>
          <p>当前时间: ${new Date().toLocaleString('zh-CN')}</p>
        </div>
      </body>
      </html>
    `;

    const textEncoder = new util.TextEncoder();
    const contentBuf = textEncoder.encodeInto(htmlContent);

    return `HTTP/1.1 200 OK\r\n` +
           `Content-Type: text/html; charset=utf-8\r\n` +
           `Content-Length: ${contentBuf.length}\r\n` +
           `\r\n` +
           htmlContent;
  }

  /**
   * 根据请求路径处理不同的响应
   * 可以扩展这个方法来实现路由功能
   */
  static createRouterHandler(): HttpRequestHandler {
    return (rawRequest: string): string => {
      hilog.info(DOMAIN, 'HttpServerHandler', `处理路由请求: ${rawRequest.substring(0, 200)}...`);
      
      // 解析请求路径（简单示例）
      const requestLines = rawRequest.split('\r\n');
      const requestLine = requestLines[0] || '';
      const path = requestLine.split(' ')[1] || '/';
      
      // 根据路径返回不同内容
      if (path === '/' || path === '/index') {
        return HttpServerHandler.getDefaultResponse();
      } else if (path === '/api/status') {
        return HttpServerHandler.getStatusResponse();
      } else if (path.startsWith('/api/')) {
        return HttpServerHandler.getApiResponse(path);
      } else {
        return HttpServerHandler.getNotFoundResponse();
      }
    };
  }

  /**
   * 状态API响应
   */
  static getStatusResponse(): string {
    const jsonContent = JSON.stringify({
      status: 'ok',
      timestamp: new Date().toISOString(),
      server: 'HarmonyOS HTTP Server'
    });

    return `HTTP/1.1 200 OK\r\n` +
           `Content-Type: application/json; charset=utf-8\r\n` +
           `Content-Length: ${jsonContent.length}\r\n` +
           `\r\n` +
           jsonContent;
  }

  /**
   * API响应处理
   */
  static getApiResponse(path: string): string {
    // TODO: 实现具体的API逻辑
    const jsonContent = JSON.stringify({
      path: path,
      message: 'API endpoint',
      data: null
    });

    return `HTTP/1.1 200 OK\r\n` +
           `Content-Type: application/json; charset=utf-8\r\n` +
           `Content-Length: ${jsonContent.length}\r\n` +
           `\r\n` +
           jsonContent;
  }

  /**
   * 404响应
   */
  static getNotFoundResponse(): string {
    const htmlContent = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>404 Not Found</title>
      </head>
      <body>
        <h1>404</h1>
        <p>页面未找到</p>
      </body>
      </html>
    `;

    return `HTTP/1.1 404 Not Found\r\n` +
           `Content-Type: text/html; charset=utf-8\r\n` +
           `Content-Length: ${htmlContent.length}\r\n` +
           `\r\n` +
           htmlContent;
  }
}

