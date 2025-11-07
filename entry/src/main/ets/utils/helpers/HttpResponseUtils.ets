/**
 * HTTP响应工具类
 * 功能：统一构建HTTP响应，避免重复代码
 * 用途：简化HTTP服务器响应构建逻辑
 */

import { util } from '@kit.ArkTS';

/**
 * 成功响应接口
 */
interface SuccessResponse {
  ok: boolean;
  message?: string;
  data?: object | string | number | boolean | Array<object | string | number | boolean>;
}

/**
 * HTTP响应工具类
 * 提供统一的HTTP响应构建方法
 */
export class HttpResponseUtils {
  private static textEncoder: util.TextEncoder = new util.TextEncoder();

  /**
   * 构建JSON响应
   * @param data 响应数据对象
   * @param statusCode HTTP状态码（默认200）
   * @param includeCors 是否包含CORS头（默认false）
   * @returns HTTP响应字符串
   */
  static buildJsonResponse(data: object, statusCode: number = 200, includeCors: boolean = false): string {
    const json = JSON.stringify(data);
    const buf = HttpResponseUtils.textEncoder.encodeInto(json);
    const statusText = statusCode === 200 ? 'OK' : 
                      statusCode === 400 ? 'Bad Request' :
                      statusCode === 404 ? 'Not Found' :
                      statusCode === 405 ? 'Method Not Allowed' :
                      statusCode === 500 ? 'Internal Server Error' : 'OK';
    
    let headers = `HTTP/1.1 ${statusCode} ${statusText}\r\n` +
                  `Content-Type: application/json; charset=utf-8\r\n` +
                  `Content-Length: ${buf.length}\r\n`;
    
    if (includeCors) {
      headers += `Access-Control-Allow-Origin: *\r\n` +
                 `Access-Control-Allow-Methods: POST, GET, OPTIONS\r\n` +
                 `Access-Control-Allow-Headers: Content-Type\r\n`;
    }
    
    return headers + `\r\n` + json;
  }

  /**
   * 构建成功JSON响应
   * @param data 响应数据
   * @param message 可选的成功消息
   * @returns HTTP响应字符串
   */
  static buildSuccessResponse(data?: object | string | number | boolean | Array<object | string | number | boolean>, message?: string): string {
    const response: SuccessResponse = { ok: true };
    if (message) {
      response.message = message;
    }
    if (data !== undefined) {
      response.data = data;
    }
    return HttpResponseUtils.buildJsonResponse(response, 200);
  }

  /**
   * 构建错误JSON响应
   * @param message 错误消息
   * @param statusCode HTTP状态码（默认400）
   * @returns HTTP响应字符串
   */
  static buildErrorResponse(message: string, statusCode: number = 400): string {
    const errorResponse: SuccessResponse = { ok: false, message };
    return HttpResponseUtils.buildJsonResponse(errorResponse, statusCode);
  }

  /**
   * 构建HTML响应
   * @param htmlContent HTML内容
   * @param statusCode HTTP状态码（默认200）
   * @returns HTTP响应字符串
   */
  static buildHtmlResponse(htmlContent: string, statusCode: number = 200): string {
    const contentBuf = HttpResponseUtils.textEncoder.encodeInto(htmlContent);
    const statusText = statusCode === 200 ? 'OK' : 
                      statusCode === 404 ? 'Not Found' : 'OK';
    
    return `HTTP/1.1 ${statusCode} ${statusText}\r\n` +
           `Content-Type: text/html; charset=utf-8\r\n` +
           `Content-Length: ${contentBuf.length}\r\n` +
           `\r\n` +
           htmlContent;
  }

  /**
   * 构建文件下载响应
   * @param content 文件内容（二进制字符串）
   * @param contentType MIME类型
   * @param filename 文件名
   * @param fileSize 文件大小（字节）
   * @returns HTTP响应字符串
   */
  static buildFileDownloadResponse(
    content: string,
    contentType: string,
    filename: string,
    fileSize: number
  ): string {
    return `HTTP/1.1 200 OK\r\n` +
           `Content-Type: ${contentType}\r\n` +
           `Content-Disposition: attachment; filename="${encodeURIComponent(filename)}"\r\n` +
           `Content-Length: ${fileSize}\r\n` +
           `\r\n` +
           content;
  }
}

