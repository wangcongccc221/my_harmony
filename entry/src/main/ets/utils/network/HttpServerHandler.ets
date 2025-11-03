import { hilog } from '@kit.PerformanceAnalysisKit';
import { util } from '@kit.ArkTS';
import { fileIo as fs } from '@kit.CoreFileKit';
import { Context } from '@kit.AbilityKit';
import { HttpRequestHandler } from './HttpServer';
import { listFilesInDirectory, getDefaultStoragePath } from '../FileUtils';
import { ArkDataDemoService, ProcessingRow, ProcessingInsertParams } from '../../db/ArkDataDemo';

const DOMAIN = 0x0000;

/**
 * 文件项接口
 */
interface FileItem {
  name: string;
  isDir: boolean;
  path: string;
}

/**
 * HTTP服务器请求处理器
 * 功能：处理所有HTTP请求，返回自定义响应
 * 用途：统一管理HTTP服务器的响应逻辑
 */
export class HttpServerHandler {
  private static fileBasePath: string = ''; // 存储文件基础路径
  private static textEncoder: util.TextEncoder = new util.TextEncoder();
  private static textDecoder: util.TextDecoder = util.TextDecoder.create('utf-8');
  // 加工历史缓存
  private static processingCacheLoaded: boolean = false;
  private static processingCache: ProcessingRow[] = [];
  private static getProcessingCacheFile(): string {
    return `${HttpServerHandler.fileBasePath}/processing_cache.json`;
  }
  private static loadProcessingCacheFromDisk(): void {
    try {
      const fp = HttpServerHandler.getProcessingCacheFile();
      if (fs.accessSync(fp)) {
        const f = fs.openSync(fp, fs.OpenMode.READ_ONLY);
        const st = fs.statSync(fp);
        const buf = new ArrayBuffer(st.size);
        fs.readSync(f.fd, buf);
        fs.closeSync(f.fd);
        const arr = new Uint8Array(buf);
        const txt = HttpServerHandler.textDecoder.decode(arr);
        const data = JSON.parse(txt) as ProcessingRow[];
        if (data && data instanceof Array) {
          HttpServerHandler.processingCache = data;
          HttpServerHandler.processingCacheLoaded = true;
        }
      }
    } catch (_) {}
  }
  private static saveProcessingCacheToDisk(): void {
    try {
      const list = HttpServerHandler.processingCache || [];
      const txt = JSON.stringify(list);
      const arr = HttpServerHandler.textEncoder.encodeInto(txt);
      const fp = HttpServerHandler.getProcessingCacheFile();
      const f = fs.openSync(fp, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.writeSync(f.fd, arr);
      fs.closeSync(f.fd);
    } catch (_) {}
  }
  private static toBase64(data: Uint8Array): string {
    let base64 = '';
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    for (let i = 0; i < data.length; i += 3) {
      const b1 = data[i] || 0;
      const b2 = data[i + 1] || 0;
      const b3 = data[i + 2] || 0;
      const bitmap = (b1 << 16) | (b2 << 8) | b3;
      base64 += chars.charAt((bitmap >> 18) & 63);
      base64 += chars.charAt((bitmap >> 12) & 63);
      base64 += (i + 1 < data.length) ? chars.charAt((bitmap >> 6) & 63) : '=';
      base64 += (i + 2 < data.length) ? chars.charAt(bitmap & 63) : '=';
    }
    return base64;
  }

  /**
   * 设置文件浏览的基础路径
   */
  static setFileBasePath(context: Context): void {
    HttpServerHandler.fileBasePath = getDefaultStoragePath(context);
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

    const contentBuf = HttpServerHandler.textEncoder.encodeInto(htmlContent);

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
      try {
        // 安全地截取请求内容用于日志
        const requestPreview = rawRequest && rawRequest.length > 0 
          ? rawRequest.substring(0, Math.min(200, rawRequest.length))
          : '(empty request)';
        hilog.info(DOMAIN, 'HttpServerHandler', `处理路由请求: ${requestPreview}...`);
        
        // 检查请求是否为空
        if (!rawRequest || rawRequest.trim().length === 0) {
          hilog.warn(DOMAIN, 'HttpServerHandler', '收到空请求');
          return HttpServerHandler.getNotFoundResponse();
        }
        
        // 解析请求路径
      const requestLines = rawRequest.split('\r\n');
        if (requestLines.length === 0) {
          hilog.warn(DOMAIN, 'HttpServerHandler', '请求格式无效');
          return HttpServerHandler.getNotFoundResponse();
        }
        
      const requestLine = requestLines[0] || '';
        const pathParts = requestLine.split(' ');
        const rawPath = pathParts.length > 1 ? pathParts[1] : '/';
        // 拆分路径与查询参数（避免解构声明）
        const qIndex = rawPath.indexOf('?');
        const path = qIndex >= 0 ? rawPath.substring(0, qIndex) : rawPath;
        const queryString = qIndex >= 0 ? rawPath.substring(qIndex + 1) : '';
        const params: Record<string, string> = {};
        if (queryString && queryString.length > 0) {
          const pairs = queryString.split('&');
          for (let i = 0; i < pairs.length; i++) {
            const kv = pairs[i].split('=');
            const k = decodeURIComponent(kv[0] || '');
            const v = decodeURIComponent(kv[1] || '');
            if (k) { params[k] = v; }
          }
        }
        
        // 解析路径参数（处理 URL 编码）
        let decodedPath = path;
        try {
          decodedPath = decodeURIComponent(path);
        } catch (e) {
          // 如果解码失败，使用原路径
          hilog.warn(DOMAIN, 'HttpServerHandler', `URL解码失败: ${path}`);
        }
      
      // 根据路径返回不同内容
      if (path === '/' || path === '/index') {
          return HttpServerHandler.getFileBrowserResponse(params);
      } else if (path === '/api/status') {
        return HttpServerHandler.getStatusResponse();
        } else if (path.startsWith('/files/') || path.startsWith('/file/')) {
          // 文件浏览路径: /files/ 或 /file/ （支持两种路径）
          // 统一处理，去掉前缀
          const filePath = decodedPath.replace(/^\/files?\//, '');
          if (filePath === '') {
            // 显示文件列表
            return HttpServerHandler.getFileBrowserResponse(params);
          } else {
            // 显示或下载文件
            return HttpServerHandler.getFileResponse(filePath);
          }
      } else if (path.startsWith('/api/')) {
          // 注意：这里需要包含查询串，否则 getApiResponse 无法解析 action 等参数
          return HttpServerHandler.getApiResponse(rawPath);
      } else {
        return HttpServerHandler.getNotFoundResponse();
        }
      } catch (error) {
        // 捕获所有异常，防止崩溃
        hilog.error(DOMAIN, 'HttpServerHandler', `路由处理异常: ${JSON.stringify(error)}`);
        try {
          return HttpServerHandler.getNotFoundResponse();
        } catch (e) {
          // 如果连 404 响应都无法生成，返回最基本的错误响应
          hilog.error(DOMAIN, 'HttpServerHandler', `无法生成错误响应: ${JSON.stringify(e)}`);
          return 'HTTP/1.1 500 Internal Server Error\r\n\r\n';
        }
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
    const jsonBuf = HttpServerHandler.textEncoder.encodeInto(jsonContent);
    return `HTTP/1.1 200 OK\r\n` +
           `Content-Type: application/json; charset=utf-8\r\n` +
           `Content-Length: ${jsonBuf.length}\r\n` +
           `\r\n` +
           jsonContent;
  }

  /**
   * API响应处理
   */
  static getApiResponse(path: string): string {
    // /api/processing?action=listJson|insert|update|delete
    if (path.indexOf('/api/processing') === 0) {
      try {
        const idx = path.indexOf('?');
        const queryString = idx >= 0 ? path.substring(idx + 1) : '';
        const params: Record<string, string> = {};
        if (queryString) {
          const pairs = queryString.split('&');
          for (let i = 0; i < pairs.length; i++) {
            const kv = pairs[i].split('=');
            const k = decodeURIComponent(kv[0] || '');
            const v = decodeURIComponent(kv[1] || '');
            if (k) { params[k] = v; }
          }
        }

        const action = params['action'] || 'listJson';
        // 首次访问时加载缓存
        if (!HttpServerHandler.processingCacheLoaded) {
          try {
            ArkDataDemoService.createProcessingHistoryTable().then(() => {
              ArkDataDemoService.queryAllProcessing().then((rows) => {
                HttpServerHandler.processingCache = rows;
                HttpServerHandler.processingCacheLoaded = true;
              }, () => {});
            }, () => {});
          } catch (_) {}
        }

        if (action === 'listJson') {
          if (!HttpServerHandler.processingCacheLoaded) {
            HttpServerHandler.loadProcessingCacheFromDisk();
          }
          const src = HttpServerHandler.processingCache || [];
          // 兼容旧数据：填充缺失字段，避免前端显示为空
          const data: ProcessingRow[] = [];
          for (let i = 0; i < src.length; i++) {
            const r = src[i];
            const norm: ProcessingRow = {
              id: r.id,
              startTime: r.startTime,
              endTime: r.endTime,
              productType: r.productType,
              totalWeight: r.totalWeight,
              customerName: r.customerName || '',
              farmName: r.farmName || '',
              fruitName: r.fruitName || r.productType || '',
              status: r.status || '',
              count: (typeof r.count === 'number') ? r.count : 0,
              weight: (typeof r.weight === 'number') ? r.weight : (r.totalWeight || 0)
            };
            data.push(norm);
          }
          const json = JSON.stringify({ ok: true, data });
          const buf = HttpServerHandler.textEncoder.encodeInto(json);
          return `HTTP/1.1 200 OK\r\nContent-Type: application/json; charset=utf-8\r\nContent-Length: ${buf.length}\r\n\r\n${json}`;
        } else if (action === 'insert') {
          const startTime = params['startTime'] || '';
          const endTime = params['endTime'] || '';
          const productType = params['productType'] || '';
          const totalWeight = Number(params['totalWeight'] || '0');
          // 新增扩展字段（仅缓存/页面显示）
          const customerName = params['customerName'] || '';
          const farmName = params['farmName'] || '';
          const fruitName = params['fruitName'] || productType;
          const status = params['status'] || '';
          const count = Number(params['count'] || '0');
          const weight = Number(params['weight'] || totalWeight || '0');
          // 参数校验：非空与时间先后
          if (!startTime || !endTime || !fruitName || !(params['totalWeight'] || params['weight'] || '').toString().length) {
            const errJson = JSON.stringify({ ok: false, message: '参数不能为空' });
            const errBuf = HttpServerHandler.textEncoder.encodeInto(errJson);
            return `HTTP/1.1 400 Bad Request\r\nContent-Type: application/json; charset=utf-8\r\nContent-Length: ${errBuf.length}\r\n\r\n${errJson}`;
          }
          // 尝试比较时间
          let invalidOrder = false;
          try {
            const sNum = Date.parse(startTime);
            const eNum = Date.parse(endTime);
            if (!isNaN(sNum) && !isNaN(eNum) && sNum > eNum) {
              invalidOrder = true;
            }
          } catch (_) {}
          if (invalidOrder) {
            const errJson = JSON.stringify({ ok: false, message: '开始时间不能晚于结束时间' });
            const errBuf = HttpServerHandler.textEncoder.encodeInto(errJson);
            return `HTTP/1.1 400 Bad Request\r\nContent-Type: application/json; charset=utf-8\r\nContent-Length: ${errBuf.length}\r\n\r\n${errJson}`;
          }
          // 先更新内存缓存，保证前端立即可见
          try {
            // 生成一个更贴近业务的临时ID：取当前缓存最大ID+1（若无则为1）
            let nextId = 1;
            try {
              const listForId = HttpServerHandler.processingCache || [];
              for (let i = 0; i < listForId.length; i++) {
                const cid = listForId[i] && typeof listForId[i].id === 'number' ? listForId[i].id : 0;
                if (cid >= nextId) { nextId = cid + 1; }
              }
            } catch (_) {}
            const tmpRow: ProcessingRow = { id: nextId, startTime, endTime, productType, totalWeight, customerName, farmName, fruitName, status, count, weight };
            if (!HttpServerHandler.processingCache) { HttpServerHandler.processingCache = []; }
            HttpServerHandler.processingCache.unshift(tmpRow);
            HttpServerHandler.processingCacheLoaded = true;
          } catch (_) {}
          try {
            const payload: ProcessingInsertParams = {
              startTime: startTime,
              endTime: endTime,
              productType: productType,
              totalWeight: totalWeight,
              customerName: customerName,
              farmName: farmName,
              fruitName: fruitName,
              status: status,
              count: count,
              weight: weight
            };
            ArkDataDemoService.insertProcessingFull(payload).then(() => {
              ArkDataDemoService.queryAllProcessing().then((rows) => {
                HttpServerHandler.processingCache = rows;
                HttpServerHandler.processingCacheLoaded = true;
                HttpServerHandler.saveProcessingCacheToDisk();
              }, () => {});
            }, () => {});
          } catch (_) {}
          // 立即把当前内存列表返回，便于前端无需等待缓存刷新
          HttpServerHandler.saveProcessingCacheToDisk();
          const json = JSON.stringify({ ok: true, data: HttpServerHandler.processingCache || [] });
          const buf = HttpServerHandler.textEncoder.encodeInto(json);
          return `HTTP/1.1 200 OK\r\nContent-Type: application/json; charset=utf-8\r\nContent-Length: ${buf.length}\r\n\r\n${json}`;
        } else if (action === 'update') {
          const id = Number(params['id'] || '0');
          const startTime = params['startTime'] || '';
          const endTime = params['endTime'] || '';
          const productType = params['productType'] || '';
          const totalWeight = Number(params['totalWeight'] || '0');
          // 先更新内存缓存
          try {
            const list = HttpServerHandler.processingCache || [];
            for (let i = 0; i < list.length; i++) {
              if (list[i].id === id) {
                list[i] = { id, startTime, endTime, productType, totalWeight };
                break;
              }
            }
            HttpServerHandler.processingCache = list;
            HttpServerHandler.processingCacheLoaded = true;
          } catch (_) {}
          try {
            ArkDataDemoService.updateProcessingById(id, startTime, endTime, productType, totalWeight).then(() => {
              ArkDataDemoService.queryAllProcessing().then((rows) => {
                HttpServerHandler.processingCache = rows;
                HttpServerHandler.processingCacheLoaded = true;
                HttpServerHandler.saveProcessingCacheToDisk();
              }, () => {});
            }, () => {});
          } catch (_) {}
          HttpServerHandler.saveProcessingCacheToDisk();
          const json = JSON.stringify({ ok: true, data: HttpServerHandler.processingCache || [] });
          const buf = HttpServerHandler.textEncoder.encodeInto(json);
          return `HTTP/1.1 200 OK\r\nContent-Type: application/json; charset=utf-8\r\nContent-Length: ${buf.length}\r\n\r\n${json}`;
        } else if (action === 'delete') {
          const id = Number(params['id'] || '0');
          // 先更新内存缓存
          try {
            const list = HttpServerHandler.processingCache || [];
            const next: ProcessingRow[] = [];
            for (let i = 0; i < list.length; i++) {
              if (list[i].id !== id) { next.push(list[i]); }
            }
            HttpServerHandler.processingCache = next;
            HttpServerHandler.processingCacheLoaded = true;
          } catch (_) {}
          try {
            ArkDataDemoService.deleteProcessingById(id).then(() => {
              ArkDataDemoService.queryAllProcessing().then((rows) => {
                HttpServerHandler.processingCache = rows;
                HttpServerHandler.processingCacheLoaded = true;
                HttpServerHandler.saveProcessingCacheToDisk();
              }, () => {});
            }, () => {});
          } catch (_) {}
          HttpServerHandler.saveProcessingCacheToDisk();
          const json = JSON.stringify({ ok: true, data: HttpServerHandler.processingCache || [] });
          const buf = HttpServerHandler.textEncoder.encodeInto(json);
          return `HTTP/1.1 200 OK\r\nContent-Type: application/json; charset=utf-8\r\nContent-Length: ${buf.length}\r\n\r\n${json}`;
        }
      } catch (e) {
        const json = JSON.stringify({ ok: false });
        const buf = HttpServerHandler.textEncoder.encodeInto(json);
        return `HTTP/1.1 500 Internal Server Error\r\nContent-Type: application/json; charset=utf-8\r\nContent-Length: ${buf.length}\r\n\r\n${json}`;
      }
    }
    // 默认占位
    const jsonContent2 = JSON.stringify({
      path: path,
      message: 'API endpoint',
      data: null
    });
    const jsonBuf2 = HttpServerHandler.textEncoder.encodeInto(jsonContent2);
    return `HTTP/1.1 200 OK\r\n` +
           `Content-Type: application/json; charset=utf-8\r\n` +
           `Content-Length: ${jsonBuf2.length}\r\n` +
           `\r\n` +
           jsonContent2;
  }

  /**
   * 文件浏览器响应（显示文件列表，类似 Jupyter Notebook）
   */
  static getFileBrowserResponse(params?: Record<string, string>): string {
    if (!HttpServerHandler.fileBasePath) {
      return HttpServerHandler.getNotFoundResponse();
    }

    try {
      // 根目录页：展示基础路径下的第一层目录（包含 file）
      const targetDir = `${HttpServerHandler.fileBasePath}`;
      
      hilog.info(DOMAIN, 'HttpServerHandler', `文件浏览器访问目录(根): ${targetDir}`);
      console.log(`HTTP服务器文件浏览器访问目录(根): ${targetDir}`);
      
      // 列出目录中的所有文件和文件夹
      const items: FileItem[] = [];
      // 分页展示辅助变量（需在外层声明，模板中使用）
      let prevHtml: string = '<span>上一页</span>';
      let pageLabelHtml: string = '<span>第 1 页</span>';
      let nextHtml: string = '<span>下一页</span>';
      
      try {
        const files = fs.listFileSync(targetDir);
        // 分页参数
        const pageSize = Math.max(1, Math.min(200, Number(params && params['pageSize'] ? params['pageSize'] : '50') || 50));
        const page = Math.max(1, Number(params && params['page'] ? params['page'] : '1') || 1);
        const total = files.length;
        const totalPages = Math.max(1, Math.ceil(total / pageSize));
        const start = (page - 1) * pageSize;
        const end = Math.min(total, start + pageSize);
        const filesToProcess = files.slice(start, end);
        // 预生成分页HTML（外层已声明，这里只赋值）
        const prevPage = page > 1 ? page - 1 : 1;
        const nextPage = page < totalPages ? page + 1 : totalPages;
        prevHtml = page > 1 ? `<a href="/files/?page=${prevPage}&pageSize=${pageSize}">上一页</a>` : '<span>上一页</span>';
        pageLabelHtml = `<span>第 ${page} 页 / 共 ${totalPages} 页</span>`;
        nextHtml = page < totalPages ? `<a href="/files/?page=${nextPage}&pageSize=${pageSize}">下一页</a>` : '<span>下一页</span>';
        
        for (let i = 0; i < filesToProcess.length; i++) {
          const fileName = files[i];
          const fullPath = `${targetDir}/${fileName}`;
          
          try {
            const stat = fs.statSync(fullPath);
            const item: FileItem = {
              name: fileName,
              isDir: stat.isDirectory(),
              path: fileName
            };
            items.push(item);
          } catch (e) {
            hilog.warn(DOMAIN, 'HttpServerHandler', 'Cannot access: %{public}s', fullPath);
          }
        }
        
        // 分页信息日志（可选）
        hilog.info(DOMAIN, 'HttpServerHandler', `分页: page=${page}, pageSize=${pageSize}, total=${total}`);
      } catch (error) {
        hilog.error(DOMAIN, 'HttpServerHandler', `Failed to list directory: ${JSON.stringify(error)}`);
      }

      // 生成 HTML 文件列表
      let fileListHtml = '';
      if (items.length === 0) {
        fileListHtml = '<p style="color: #999; padding: 20px;">目录为空</p>';
      } else {
        // 先显示文件夹，再显示文件
        const dirs = items.filter(item => item.isDir).sort((a, b) => a.name.localeCompare(b.name));
        const files = items.filter(item => !item.isDir).sort((a, b) => a.name.localeCompare(b.name));
        
        [...dirs, ...files].forEach(item => {
          const icon = item.isDir ? '📁' : '📄';
          const encodedPath = encodeURIComponent(item.path);
          // 使用完整的URL路径，确保浏览器地址栏正确更新
          fileListHtml += `
            <div class="file-item" onclick="window.location.href='http://' + window.location.host + '/files/${encodedPath}'">
              <span class="file-icon">${icon}</span>
              <span class="file-name">${HttpServerHandler.escapeHtml(item.name)}</span>
              ${item.isDir ? '<span class="file-type">目录</span>' : '<span class="file-type">文件</span>'}
            </div>
          `;
        });
      }

      const htmlContent = `
        <!DOCTYPE html>
        <html lang="zh-CN">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>文件浏览器 - HarmonyOS</title>
          <style>
            * {
              margin: 0;
              padding: 0;
              box-sizing: border-box;
            }
            body {
              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif;
              background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
              min-height: 100vh;
              padding: 20px;
            }
            .container {
              max-width: 900px;
              margin: 0 auto;
              background: white;
              border-radius: 12px;
              box-shadow: 0 10px 40px rgba(0,0,0,0.2);
              overflow: hidden;
            }
            .header {
              background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
              color: white;
              padding: 30px;
              text-align: center;
            }
            .header h1 {
              font-size: 28px;
              margin-bottom: 10px;
            }
            .header p {
              opacity: 0.9;
              font-size: 14px;
            }
            .file-browser {
              padding: 30px;
            }
            .quick-links { display:flex; gap:10px; margin-bottom: 16px; }
            .quick-links a { color:#fff; background:#667eea; padding:8px 12px; border-radius:6px; text-decoration:none; }
            .quick-links a:hover { background:#556cdf; }
            .path-info {
              background: #f8f9fa;
              padding: 15px;
              border-radius: 8px;
              margin-bottom: 20px;
              font-family: monospace;
              color: #495057;
              font-size: 14px;
            }
            .file-item {
              display: flex;
              align-items: center;
              padding: 15px;
              margin: 8px 0;
              background: #f8f9fa;
              border-radius: 8px;
              cursor: pointer;
              transition: all 0.2s;
              border: 2px solid transparent;
            }
            .file-item:hover {
              background: #e9ecef;
              border-color: #667eea;
              transform: translateX(5px);
            }
            .file-icon {
              font-size: 24px;
              margin-right: 15px;
              width: 30px;
              text-align: center;
            }
            .file-name {
              flex: 1;
              font-size: 16px;
              color: #212529;
              font-weight: 500;
            }
            .file-type {
              background: #667eea;
              color: white;
              padding: 4px 12px;
              border-radius: 12px;
              font-size: 12px;
              font-weight: 500;
            }
            .empty-message {
              text-align: center;
              padding: 60px 20px;
              color: #6c757d;
            }
            .pagination { display: flex; justify-content: space-between; margin: 20px 0; }
            .pagination a { color: #667eea; text-decoration: none; padding: 8px 12px; background: #f0f0ff; border-radius: 6px; }
            .pagination span { color: #666; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>📂 文件浏览器</h1>
              <p>HarmonyOS HTTP 服务器文件管理</p>
            </div>
            <div class="file-browser">
              <div class="quick-links">
                <a href="/files/file/processing.html">加工历史管理</a>
              </div>
              <div class="path-info">
                当前位置: ${HttpServerHandler.buildBreadcrumb('')}
              </div>
              <div class="pagination">
                <div>${prevHtml}</div>
                <div>${pageLabelHtml}</div>
                <div>${nextHtml}</div>
              </div>
              <div class="file-list">
                ${fileListHtml}
              </div>
            </div>
          </div>
        </body>
        </html>
      `;

      const contentBuf = HttpServerHandler.textEncoder.encodeInto(htmlContent);

    return `HTTP/1.1 200 OK\r\n` +
             `Content-Type: text/html; charset=utf-8\r\n` +
             `Content-Length: ${contentBuf.length}\r\n` +
           `\r\n` +
             htmlContent;
    } catch (error) {
      hilog.error(DOMAIN, 'HttpServerHandler', `文件浏览器错误: ${JSON.stringify(error)}`);
      return HttpServerHandler.getNotFoundResponse();
    }
  }

  /**
   * 文件响应（显示或下载文件内容）
   * 注意：文件大小限制为 5MB，避免阻塞主线程
   */
  static getFileResponse(relativePath: string): string {
    if (!HttpServerHandler.fileBasePath) {
      return HttpServerHandler.getNotFoundResponse();
    }

    try {
      const fullPath = `${HttpServerHandler.fileBasePath}/${relativePath}`;
      
      // 检查文件是否存在
      if (!fs.accessSync(fullPath)) {
        return HttpServerHandler.getNotFoundResponse();
      }

      const stat = fs.statSync(fullPath);
      
      // 限制文件大小：最大 5MB，避免阻塞主线程
      const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB
      if (stat.isFile() && stat.size > MAX_FILE_SIZE) {
        hilog.warn(DOMAIN, 'HttpServerHandler', `文件过大，已跳过: ${fullPath} (${stat.size} bytes)`);
        return `HTTP/1.1 413 Payload Too Large\r\nContent-Type: text/plain\r\n\r\n文件过大（超过 5MB），无法通过 HTTP 服务器预览。`;
      }
      
      // 如果是目录，显示目录内容
      if (stat.isDirectory()) {
        const items: FileItem[] = [];
        try {
          const files = fs.listFileSync(fullPath);
          
          // 限制目录文件数量：最多处理 100 个文件，避免阻塞主线程
          const MAX_FILES = 100;
          const filesToProcess = files.length > MAX_FILES ? files.slice(0, MAX_FILES) : files;
          
          for (let i = 0; i < filesToProcess.length; i++) {
            const fileName = filesToProcess[i];
            const itemPath = `${fullPath}/${fileName}`;
            try {
              const itemStat = fs.statSync(itemPath);
              const item: FileItem = {
                name: fileName,
                isDir: itemStat.isDirectory(),
                path: `${relativePath}/${fileName}`
              };
              items.push(item);
            } catch (e) {
              // 忽略无法访问的文件
            }
            
            // 每处理 10 个文件后，让出主线程（使用 setTimeout 延迟）
            if (i > 0 && i % 10 === 0) {
              // 注意：这里不能真正异步，但可以减少连续阻塞
            }
          }
          
          if (files.length > MAX_FILES) {
            hilog.warn(DOMAIN, 'HttpServerHandler', `目录文件过多（${files.length}），仅显示前 ${MAX_FILES} 个`);
          }
        } catch (e) {
          // 忽略错误
        }

        // 生成目录列表 HTML（类似文件浏览器）
        let fileListHtml = '';
        const dirs = items.filter(item => item.isDir).sort((a, b) => a.name.localeCompare(b.name));
        const files = items.filter(item => !item.isDir).sort((a, b) => a.name.localeCompare(b.name));
        
        [...dirs, ...files].forEach(item => {
          const icon = item.isDir ? '📁' : '📄';
          const encodedPath = encodeURIComponent(item.path);
          // 使用完整的URL路径，确保浏览器地址栏正确更新
          fileListHtml += `
            <div class="file-item" onclick="window.location.href='http://' + window.location.host + '/files/${encodedPath}'">
              <span class="file-icon">${icon}</span>
              <span class="file-name">${HttpServerHandler.escapeHtml(item.name)}</span>
              ${item.isDir ? '<span class="file-type">目录</span>' : '<span class="file-type">文件</span>'}
            </div>
          `;
        });

        const htmlContent = `
          <!DOCTYPE html>
          <html lang="zh-CN">
          <head>
            <meta charset="utf-8">
            <title>${HttpServerHandler.escapeHtml(relativePath)} - 文件浏览器</title>
            <style>
              * { margin: 0; padding: 0; box-sizing: border-box; }
              body { font-family: Arial, sans-serif; background: #f5f5f5; padding: 20px; }
              .container { max-width: 900px; margin: 0 auto; background: white; border-radius: 8px; padding: 20px; }
              .path-info { background: #f8f9fa; padding: 10px; border-radius: 4px; margin-bottom: 20px; font-family: monospace; }
              .file-item { display: flex; align-items: center; padding: 10px; margin: 5px 0; background: #f8f9fa; border-radius: 4px; cursor: pointer; }
              .file-item:hover { background: #e9ecef; }
              .file-icon { font-size: 20px; margin-right: 10px; }
              .file-name { flex: 1; }
              .file-type { background: #667eea; color: white; padding: 2px 8px; border-radius: 4px; font-size: 12px; }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="path-info">当前位置: ${HttpServerHandler.buildBreadcrumb(relativePath)}</div>
              <div class="file-list">${fileListHtml}</div>
            </div>
          </body>
          </html>
        `;

        const contentBuf = HttpServerHandler.textEncoder.encodeInto(htmlContent);
        return `HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\nContent-Length: ${contentBuf.length}\r\n\r\n${htmlContent}`;
      }

      // 读取文件内容
      const file = fs.openSync(fullPath, fs.OpenMode.READ_ONLY);
      const fileSize = stat.size;
      const buffer = new ArrayBuffer(fileSize);
      fs.readSync(file.fd, buffer);
      fs.closeSync(file.fd);

      // 判断文件类型
      const fileExt = relativePath.split('.').pop()?.toLowerCase() || '';
      let contentType = 'text/plain';
      let shouldDisplay = true;

      if (fileExt === 'html' || fileExt === 'htm') {
        contentType = 'text/html';
      } else if (fileExt === 'css') {
        contentType = 'text/css';
      } else if (fileExt === 'js') {
        contentType = 'application/javascript';
      } else if (fileExt === 'json') {
        contentType = 'application/json';
      } else if (fileExt === 'png' || fileExt === 'jpg' || fileExt === 'jpeg' || fileExt === 'gif') {
        contentType = `image/${fileExt === 'jpg' ? 'jpeg' : fileExt}`;
        shouldDisplay = false;
      } else if (fileExt === 'txt') {
        contentType = 'text/plain; charset=utf-8';
      } else {
        shouldDisplay = false;
      }

      // 转换为字符串（文本文件）
      if (shouldDisplay && (contentType.startsWith('text/') || contentType.includes('json') || contentType.includes('javascript'))) {
        // 文本预览大小限制（避免一次性渲染超大文本造成卡顿）
        const TEXT_PREVIEW_LIMIT = 256 * 1024; // 256KB
        if (fileSize > TEXT_PREVIEW_LIMIT) {
          // 超过限制直接提供下载
          const uint8ArrayAll = new Uint8Array(buffer);
          let binaryStringAll = '';
          for (let i = 0; i < uint8ArrayAll.length; i++) {
            binaryStringAll += String.fromCharCode(uint8ArrayAll[i]);
          }
          return `HTTP/1.1 200 OK\r\nContent-Type: ${contentType}; charset=utf-8\r\nContent-Disposition: attachment; filename="${encodeURIComponent(relativePath.split('/').pop() || 'text')}"\r\nContent-Length: ${fileSize}\r\n\r\n${binaryStringAll}`;
        }
        const uint8Array = new Uint8Array(buffer);
        const textContent = HttpServerHandler.textDecoder.decode(uint8Array);
        
        // 如果是 HTML 文件，直接返回原始 HTML 内容让浏览器渲染
        if (fileExt === 'html' || fileExt === 'htm') {
          const contentBuf = HttpServerHandler.textEncoder.encodeInto(textContent);
          return `HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\nContent-Length: ${contentBuf.length}\r\n\r\n${textContent}`;
        }
        
        // 其他文本文件（txt, css, js, json）显示为代码预览
        const htmlContent = `
          <!DOCTYPE html>
          <html lang="zh-CN">
          <head>
            <meta charset="utf-8">
            <title>${HttpServerHandler.escapeHtml(relativePath)}</title>
            <style>
              body { font-family: 'Courier New', monospace; padding: 20px; background: #1e1e1e; color: #d4d4d4; }
              .header { margin-bottom: 20px; padding-bottom: 10px; border-bottom: 1px solid #444; }
              .header h1 { color: #fff; margin-bottom: 5px; }
              .file-path { color: #999; font-size: 12px; }
              pre { background: #252526; padding: 15px; border-radius: 4px; overflow-x: auto; }
            </style>
          </head>
          <body>
            <div class="header">
              <h1>📄 ${HttpServerHandler.escapeHtml(relativePath)}</h1>
              <div class="file-path">${HttpServerHandler.escapeHtml(fullPath)}</div>
            </div>
            <pre>${HttpServerHandler.escapeHtml(textContent)}</pre>
          </body>
          </html>
        `;

        const contentBuf = HttpServerHandler.textEncoder.encodeInto(htmlContent);
        return `HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\nContent-Length: ${contentBuf.length}\r\n\r\n${htmlContent}`;
      } else {
        // 二进制文件或图片
        const uint8Array = new Uint8Array(buffer);
        const EMBED_IMAGE_LIMIT = 512 * 1024; // 512KB
        
        if (contentType.startsWith('image/')) {
          // 大图直接下载，小图内嵌显示
          if (fileSize > EMBED_IMAGE_LIMIT) {
            let binaryString = '';
            for (let i = 0; i < uint8Array.length; i++) {
              binaryString += String.fromCharCode(uint8Array[i]);
            }
            return `HTTP/1.1 200 OK\r\nContent-Type: ${contentType}\r\nContent-Disposition: attachment; filename="${encodeURIComponent(relativePath.split('/').pop() || 'image')}"\r\nContent-Length: ${fileSize}\r\n\r\n${binaryString}`;
          }
          const dataUrl = `data:${contentType};base64,${HttpServerHandler.toBase64(uint8Array)}`;
          const htmlContent = `
            <!DOCTYPE html>
            <html>
            <head>
              <meta charset="utf-8">
              <title>${HttpServerHandler.escapeHtml(relativePath)}</title>
              <style>
                body { text-align: center; padding: 20px; background: #f5f5f5; }
                img { max-width: 100%; height: auto; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.2); }
              </style>
            </head>
            <body>
              <h2>${HttpServerHandler.escapeHtml(relativePath)}</h2>
              <img src="${dataUrl}" alt="${HttpServerHandler.escapeHtml(relativePath)}">
            </body>
            </html>
          `;
          const contentBuf = HttpServerHandler.textEncoder.encodeInto(htmlContent);
          return `HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\nContent-Length: ${contentBuf.length}\r\n\r\n${htmlContent}`;
        } else {
          // 其他二进制文件，提供下载
          // 将 Uint8Array 转换为字符串（用于二进制数据）
          let binaryString = '';
          for (let i = 0; i < uint8Array.length; i++) {
            binaryString += String.fromCharCode(uint8Array[i]);
          }
          return `HTTP/1.1 200 OK\r\nContent-Type: ${contentType}\r\nContent-Disposition: attachment; filename="${encodeURIComponent(relativePath.split('/').pop() || 'file')}"\r\nContent-Length: ${fileSize}\r\n\r\n${binaryString}`;
        }
      }
    } catch (error) {
      hilog.error(DOMAIN, 'HttpServerHandler', `文件读取错误: ${JSON.stringify(error)}`);
      return HttpServerHandler.getNotFoundResponse();
    }
  }

  /**
   * HTML 转义
   */
  private static escapeHtml(text: string): string {
    return text
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
  }

  /**
   * 构建面包屑导航 HTML
   * relativePath 例如 "", "logs", "logs/2025-11"
   */
  static buildBreadcrumb(relativePath: string): string {
    // 根
    if (!relativePath || relativePath.trim().length === 0) {
      return `<a href="/files/">首页</a>`;
    }
    const safe = relativePath.replace(/^\/+|\/+$/g, '');
    const parts = safe.split('/');
    let acc = '';
    let html = `<a href="/files/">首页</a>`;
    for (let i = 0; i < parts.length; i++) {
      const name = parts[i];
      acc = acc ? (acc + '/' + name) : name;
      const href = '/files/' + encodeURIComponent(acc);
      if (i < parts.length - 1) {
        html += ` / <a href="${href}">${HttpServerHandler.escapeHtml(name)}</a>`;
      } else {
        html += ` / <span>${HttpServerHandler.escapeHtml(name)}</span>`;
      }
    }
    return html;
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

