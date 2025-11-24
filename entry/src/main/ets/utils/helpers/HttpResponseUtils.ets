/**
 * HTTP响应工具类
 * 功能：统一构建HTTP响应，避免重复代码
 * 用途：简化HTTP服务器响应构建逻辑
 */

import { util } from '@kit.ArkTS';
import { zlib } from '@kit.BasicServicesKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { Context } from '@kit.AbilityKit';

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
  private static tempCounter: number = 0;

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

  static async buildJsonResponseGzip(
    data: object,
    statusCode: number = 200,
    includeCors: boolean = false,
    context?: Context
  ): Promise<Uint8Array> {
    try {
      const json = JSON.stringify(data);
      const bodyBytes = HttpResponseUtils.textEncoder.encodeInto(json);
      const gzip = zlib.createGZipSync();
      const baseDir = context ? context.getApplicationContext().filesDir : '/data/storage/el2/base/haps/entry/files';
      const id = (++HttpResponseUtils.tempCounter) % 1000000;
      const filePath = `${baseDir}/resp_${Date.now()}_${id}.gz`;
      await gzip.gzopen(filePath, 'wb');
      // 分块写入以降低单次内存峰值
      const CHUNK = 64 * 1024;
      const ab = (new Uint8Array(bodyBytes)).buffer;
      let written = 0;
      while (written < bodyBytes.length) {
        const remain = bodyBytes.length - written;
        const size = remain > CHUNK ? CHUNK : remain;
        const slice = ab.slice(written, written + size);
        await gzip.gzwrite(slice, size);
        written += size;
      }
      await gzip.gzclose();
      const stat = fs.statSync(filePath);
      const compSize = stat.size;
      const fd = fs.openSync(filePath, fs.OpenMode.READ_ONLY);
      const readBuf = new ArrayBuffer(compSize);
      fs.readSync(fd.fd, readBuf, { offset: 0 });
      fs.closeSync(fd.fd);
      try { fs.unlinkSync(filePath); } catch (_) {}

      const statusText = statusCode === 200 ? 'OK' : 
                        statusCode === 400 ? 'Bad Request' :
                        statusCode === 404 ? 'Not Found' :
                        statusCode === 405 ? 'Method Not Allowed' :
                        statusCode === 500 ? 'Internal Server Error' : 'OK';
      let headers = `HTTP/1.1 ${statusCode} ${statusText}\r\n` +
                    `Content-Type: application/json; charset=utf-8\r\n` +
                    `Content-Encoding: gzip\r\n` +
                    `Content-Length: ${compSize}\r\n`;
      if (includeCors) {
        headers += `Access-Control-Allow-Origin: *\r\n` +
                   `Access-Control-Allow-Methods: POST, GET, OPTIONS\r\n` +
                   `Access-Control-Allow-Headers: Content-Type, Accept-Encoding\r\n`;
      }
      headers += `\r\n`;
      const headerBytes = HttpResponseUtils.textEncoder.encodeInto(headers);
      const bodyUint8 = new Uint8Array(readBuf);
      const out = new Uint8Array(headerBytes.length + bodyUint8.length);
      out.set(headerBytes, 0);
      out.set(bodyUint8, headerBytes.length);
      return out;
    } catch (e) {
      const fallback = { ok: false, message: 'gzip 失败，返回未压缩响应', data } as SuccessResponse;
      const resp = HttpResponseUtils.buildJsonResponse(fallback, 200, includeCors);
      return HttpResponseUtils.textEncoder.encodeInto(resp);
    }
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

