import { hilog } from '@kit.PerformanceAnalysisKit';
import { util } from '@kit.ArkTS';
import { Context } from '@kit.AbilityKit';
import { relationalStore } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { IBestORMInit, GetIBestORM } from '../../../database/orm';
import { ProcessingHistory } from '../../../database/models/ProcessingHistory';
import { FruitInfo } from '../../../database/models/FruitInfo';
import { GradeInfo } from '../../../database/models/GradeInfo';
import { HttpRequestHandler } from './HttpServer';
import { getDefaultStoragePath } from '../../FileUtils';
import { QueryStringUtils } from '../../helpers/QueryStringUtils';
import { ApiDocumentation } from './docs/ApiDocumentation';
import { ResponseHandler } from './handlers/ResponseHandler';
import { ProcessingApiHandler } from './handlers/ProcessingApiHandler';
import { PerformanceApiHandler } from './handlers/PerformanceApiHandler';
import { FileBrowserHandler } from './handlers/FileBrowserHandler';

const DOMAIN = 0x0000;

export class HttpServerHandler {
  private static fileBasePath: string = '';
  private static appContext: Context | null = null;
  private static textDecoder: util.TextDecoder = util.TextDecoder.create('utf-8');

  /**
   * 设置文件浏览的基础路径
   */
  static setFileBasePath(context: Context): void {
    HttpServerHandler.fileBasePath = getDefaultStoragePath(context);
    HttpServerHandler.appContext = context; // 保存Context引用，用于访问rawfile
    hilog.info(DOMAIN, 'HttpServerHandler', `文件浏览基础路径已设置: ${HttpServerHandler.fileBasePath}`);
    console.log(`HTTP服务器文件浏览基础路径: ${HttpServerHandler.fileBasePath}`);
    console.log(`HTTP服务器实际浏览目录将是: ${HttpServerHandler.fileBasePath}/file`);
  }

  /**
   * 默认HTTP请求处理器
   * 可以根据rawRequest解析请求内容，返回相应的响应
   */
  static createHandler(): HttpRequestHandler {
    return (rawRequest: string): string => {
      hilog.info(DOMAIN, 'HttpServerHandler', `收到HTTP请求: ${rawRequest.substring(0, 200)}...`);
      
      // 默认响应（已由 createRouterHandler 处理路由逻辑）
      return ResponseHandler.getDefaultResponse();
    };
  }


  /**
   * 根据请求路径处理不同的响应
   * 可以扩展这个方法来实现路由功能
   */
  static createRouterHandler(): HttpRequestHandler {
    return async (rawRequest: string): Promise<string | Uint8Array> => {
      try {
        // 安全地截取请求内容用于日志
        const requestPreview = rawRequest && rawRequest.length > 0 
          ? rawRequest.substring(0, Math.min(200, rawRequest.length))
          : '(empty request)';
        hilog.info(DOMAIN, 'HttpServerHandler', `处理路由请求: ${requestPreview}...`);
        
        // 检查请求是否为空
        if (!rawRequest || rawRequest.trim().length === 0) {
          hilog.warn(DOMAIN, 'HttpServerHandler', '收到空请求');
          return ResponseHandler.getNotFoundResponse();
        }
        
        // 解析请求路径
      const requestLines = rawRequest.split('\r\n');
        if (requestLines.length === 0) {
          hilog.warn(DOMAIN, 'HttpServerHandler', '请求格式无效');
          return ResponseHandler.getNotFoundResponse();
        }
        
      const requestLine = requestLines[0] || '';
        const pathParts = requestLine.split(' ');
        const rawPath = pathParts.length > 1 ? pathParts[1] : '/';
        let acceptGzip = false;
        for (let i = 1; i < requestLines.length; i++) {
          const line = requestLines[i];
          if (!line) continue;
          const lower = line.toLowerCase();
          if (lower.startsWith('accept-encoding:')) {
            if (lower.indexOf('gzip') >= 0) {
              acceptGzip = true;
            }
          }
        }
        
        // 使用工具类解析路径和查询参数
        const pathAndQuery = QueryStringUtils.parsePathAndQuery(rawPath);
        const path = pathAndQuery.path;
        const params = pathAndQuery.params;
        
        // 解析路径参数（处理 URL 编码）
        let decodedPath = path;
        try {
          decodedPath = decodeURIComponent(path);
        } catch (e) {
          // 如果解码失败，使用原路径
          hilog.warn(DOMAIN, 'HttpServerHandler', `URL解码失败: ${path}`);
        }
      
      // 根据路径返回不同内容
      hilog.info(DOMAIN, 'HttpServerHandler', `路由匹配: path=${path}, decodedPath=${decodedPath}`);
      
      if (path === '/' || path === '/index') {
        return await HttpServerHandler.getFileBrowserResponse(params);
      }
      if (path.startsWith('/file/')) {
        // 处理文件访问请求
        const filePath = path.substring(6); // 去掉 "/file/" 前缀
        return await HttpServerHandler.getFileContentResponse(filePath);
      }
      if (path === '/api/status') {
        return ResponseHandler.getStatusResponse();
      }
      if (path === '/api/docs' || path === '/api/help') {
        // API文档页面
        return ApiDocumentation.getApiDocsResponse();
      }
      if (path.startsWith('/api/performance')) {
        // 解析 HTTP 方法
        const method = pathParts[0] || 'GET';
        
        // 提取请求体（POST/PUT 请求）
        let requestBody: string | undefined = undefined;
        if (method === 'POST' || method === 'PUT') {
          // 查找空行后的请求体
          const emptyLineIndex = rawRequest.indexOf('\r\n\r\n');
          if (emptyLineIndex >= 0) {
            requestBody = rawRequest.substring(emptyLineIndex + 4);
          }
        }
        
        hilog.info(DOMAIN, 'HttpServerHandler', `性能测试路由匹配: method=${method}, path=${path}, rawPath=${rawPath}`);
        return await PerformanceApiHandler.handle(method, rawPath, requestBody);
      }
      if (path.startsWith('/api/processing')) {
        // 解析 HTTP 方法
        const method = pathParts[0] || 'GET';
        
        // 提取请求体（POST/PUT 请求）
        let requestBody: string | undefined = undefined;
        if (method === 'POST' || method === 'PUT') {
          // 查找空行后的请求体
          const emptyLineIndex = rawRequest.indexOf('\r\n\r\n');
          if (emptyLineIndex >= 0) {
            requestBody = rawRequest.substring(emptyLineIndex + 4);
          }
        }
        
        return await ProcessingApiHandler.handle(method, rawPath, requestBody, HttpServerHandler.appContext as Context, acceptGzip);
      }
      return ResponseHandler.getNotFoundResponse();
      } catch (error) {
        // 捕获所有异常，防止崩溃
        hilog.error(DOMAIN, 'HttpServerHandler', `路由处理异常: ${JSON.stringify(error)}`);
        try {
          return ResponseHandler.getNotFoundResponse();
        } catch (e) {
          // 如果连 404 响应都无法生成，返回最基本的错误响应
          hilog.error(DOMAIN, 'HttpServerHandler', `无法生成错误响应: ${JSON.stringify(e)}`);
          return 'HTTP/1.1 500 Internal Server Error\r\n\r\n';
        }
      }
    };
  }

  static async getFileBrowserResponse(params?: Record<string, string>): Promise<string> {
    return FileBrowserHandler.getRootResponse(HttpServerHandler.appContext);
  }

  static async getFileContentResponse(filePath: string): Promise<string> {
    return FileBrowserHandler.getFileContentResponse(
      HttpServerHandler.appContext,
      HttpServerHandler.textDecoder,
      filePath
    );
  }

  static async getDirectoryBrowserResponse(dirPath: string, rawDirPath: string): Promise<string> {
    return FileBrowserHandler.getDirectoryResponse(
      HttpServerHandler.appContext,
      dirPath,
      rawDirPath
    );
  }
}
