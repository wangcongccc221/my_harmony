import { hilog } from '@kit.PerformanceAnalysisKit';
import { Context } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import { HttpResponseUtils } from '../../helpers/HttpResponseUtils';
import { Base64Utils } from '../utils/Base64Utils';

const DOMAIN = 0x0000;

export interface FileItem {
  name: string;
  isDir: boolean;
  path: string;
}

export class FileBrowserHandler {
  /**
   * 获取根目录文件浏览页面
   */
  static async getRootResponse(context: Context | null): Promise<string> {
    if (!context) {
      return HttpResponseUtils.buildErrorResponse('服务器未初始化', 500);
    }

    try {
      const fileList = await FileBrowserHandler.buildRootFileList(context);
      const fileListHtml = FileBrowserHandler.renderFileList(fileList);
      const htmlContent = FileBrowserHandler.renderRootHtml(fileListHtml);
      return HttpResponseUtils.buildHtmlResponse(htmlContent);
    } catch (error) {
      hilog.error(DOMAIN, 'FileBrowserHandler', `生成文件浏览器页面失败: ${JSON.stringify(error)}`);
      return HttpResponseUtils.buildErrorResponse('生成文件列表失败', 500);
    }
  }

  /**
   * 获取文件内容或目录页面
   */
  static async getFileContentResponse(
    context: Context | null,
    textDecoder: util.TextDecoder,
    filePath: string
  ): Promise<string> {
    if (!context) {
      return HttpResponseUtils.buildErrorResponse('服务器未初始化', 500);
    }

    try {
      let decodedPath = filePath;
      try {
        decodedPath = decodeURIComponent(filePath);
      } catch (e) {
        hilog.warn(DOMAIN, 'FileBrowserHandler', `URL解码失败: ${filePath}`);
      }

      const rawFilePath = `file/${decodedPath}`;

      // 如果是目录，展示目录浏览页面
      try {
        const subFiles = await context.resourceManager.getRawFileList(rawFilePath);
        if (subFiles && subFiles.length > 0) {
          return await FileBrowserHandler.getDirectoryResponse(context, decodedPath, rawFilePath);
        }
      } catch (e) {
        // 不是目录，继续处理文件
      }

      return FileBrowserHandler.buildFileContentResponse(context, textDecoder, decodedPath, rawFilePath);
    } catch (error) {
      hilog.error(DOMAIN, 'FileBrowserHandler', `处理文件请求失败: ${JSON.stringify(error)}`);
      return HttpResponseUtils.buildErrorResponse('处理文件请求失败', 500);
    }
  }

  /**
   * 获取目录浏览页面
   */
  static async getDirectoryResponse(
    context: Context | null,
    dirPath: string,
    rawDirPath: string
  ): Promise<string> {
    if (!context) {
      return HttpResponseUtils.buildErrorResponse('服务器未初始化', 500);
    }

    try {
      const fileList = await FileBrowserHandler.buildDirectoryFileList(context, dirPath, rawDirPath);
      const fileListHtml = FileBrowserHandler.renderDirectoryList(fileList);
      const breadcrumbHtml = FileBrowserHandler.renderBreadcrumb(dirPath);
      const htmlContent = FileBrowserHandler.renderDirectoryHtml(dirPath, fileListHtml, breadcrumbHtml);
      return HttpResponseUtils.buildHtmlResponse(htmlContent);
    } catch (error) {
      hilog.error(DOMAIN, 'FileBrowserHandler', `生成目录浏览页面失败: ${JSON.stringify(error)}`);
      return HttpResponseUtils.buildErrorResponse('生成目录列表失败', 500);
    }
  }

  private static async buildRootFileList(context: Context): Promise<FileItem[]> {
    const fileList: FileItem[] = [];

    try {
      const rawFiles: string[] = await context.resourceManager.getRawFileList('file');
      if (!rawFiles || rawFiles.length === 0) {
        return fileList;
      }

      const seenPaths = new Set<string>();
      for (let i = 0; i < rawFiles.length; i++) {
        let fileName = rawFiles[i];
        if (fileName.startsWith('file/')) {
          fileName = fileName.substring(5);
        }

        if (!fileName) {
          continue;
        }

        const firstLevel = fileName.split('/')[0];
        if (seenPaths.has(firstLevel)) {
          continue;
        }
        seenPaths.add(firstLevel);

        let isDir = false;
        if (fileName.includes('/')) {
          isDir = true;
        } else {
          try {
            const testPath = `file/${fileName}`;
            const subFiles = await context.resourceManager.getRawFileList(testPath);
            if (subFiles && subFiles.length > 0) {
              isDir = true;
            }
          } catch (e) {
            isDir = false;
          }
        }

        fileList.push({
          name: firstLevel,
          isDir,
          path: firstLevel
        });
      }
    } catch (error) {
      hilog.error(DOMAIN, 'FileBrowserHandler', `读取rawfile文件列表失败: ${JSON.stringify(error)}`);
    }

    return fileList;
  }

  private static renderFileList(fileList: FileItem[]): string {
    if (fileList.length === 0) {
      return '<div class="empty-state">暂无文件</div>';
    }

    const dirs: FileItem[] = [];
    const files: FileItem[] = [];

    for (let i = 0; i < fileList.length; i++) {
      if (fileList[i].isDir) {
        dirs.push(fileList[i]);
      } else {
        files.push(fileList[i]);
      }
    }

    let fileListHtml = '';
    for (let i = 0; i < dirs.length; i++) {
      const item = dirs[i];
      const encodedPath = encodeURIComponent(item.path);
      fileListHtml += `
        <div class="file-item directory">
          <span class="file-icon">📁</span>
          <a href="/file/${encodedPath}" class="file-name">${item.name}</a>
        </div>`;
    }

    for (let i = 0; i < files.length; i++) {
      const item = files[i];
      const encodedPath = encodeURIComponent(item.path);
      const fileIcon = item.name.endsWith('.html') ? '🌐' :
        item.name.endsWith('.txt') ? '📄' :
        item.name.endsWith('.json') ? '📋' : '📄';
      fileListHtml += `
        <div class="file-item file">
          <span class="file-icon">${fileIcon}</span>
          <a href="/file/${encodedPath}" class="file-name">${item.name}</a>
        </div>`;
    }

    return fileListHtml;
  }

  private static renderRootHtml(fileListHtml: string): string {
    return `<!DOCTYPE html>
<html lang="zh-CN">
  <head>
    <meta charset="UTF-8" />
    <title>HarmonyOS HTTP 服务器 - 文件浏览器</title>
    <style>
      * { margin: 0; padding: 0; box-sizing: border-box; }
      :root { --primary:#667eea; --bg:#f5f6fa; --card:#ffffff; --muted:#6b7280; }
      body { font-family: "HarmonyOS Sans", -apple-system, BlinkMacSystemFont, "Segoe UI", Arial, sans-serif; background: var(--bg); color:#1e1e1e; }
      .topnav { position: sticky; top:0; background: var(--primary); color:#fff; display:flex; align-items:center; justify-content:space-between; padding:12px 20px; }
      .brand { font-weight:600; letter-spacing:.3px; }
      .links a { color:#fff; text-decoration:none; margin-left:16px; padding:6px 10px; border-radius:6px; }
      .links a:hover { background: rgba(255,255,255,.18); }
      .container {
        max-width: 960px; margin: 24px auto; padding: 0 16px;
      }
      .header { background: var(--card); border-radius: 12px; box-shadow: 0 8px 24px rgba(0,0,0,.08); padding: 24px; }
      .header h1 { font-size: 24px; margin-bottom: 6px; }
      .header p { font-size: 14px; color: var(--muted); }
      .content { padding: 16px; }
      .file-list { display: block; margin-top: 12px; background: var(--card); border-radius: 8px; border: 1px solid #e9ecef; }
      .file-item { display: flex; align-items: center; padding: 12px 14px; border-bottom: 1px solid #e9ecef; cursor: pointer; transition: background .15s ease; }
      .file-item:last-child { border-bottom: none; }
      .file-item:hover { background: #f6f8ff; }
      .file-item.directory .file-icon { color: #eab308; }
      .file-icon { font-size: 20px; margin-right: 10px; flex-shrink: 0; }
      .file-name { color: #1e1e1e; text-decoration: none; font-size: 15px; font-weight: 500; flex: 1; word-break: break-all; }
      .file-name:hover { color: #667eea; text-decoration: underline; }
      .empty-state { text-align: center; padding: 24px; color: #6c757d; font-size: 14px; }
      .quick-links {
        margin-top: 32px;
        padding-top: 24px;
        border-top: 1px solid #e9ecef;
      }
      .quick-links h2 {
        font-size: 18px;
        margin-bottom: 16px;
        color: #495057;
      }
      .links {
        display: flex;
        gap: 12px;
        flex-wrap: wrap;
      }
      .links a {
        padding: 10px 18px;
        background: #667eea;
        color: #ffffff;
        border-radius: 6px;
        text-decoration: none;
        font-size: 14px;
        transition: all 0.2s ease;
        font-weight: 500;
      }
      .links a:hover {
        background: #5568d3;
        transform: translateY(-1px);
        box-shadow: 0 4px 8px rgba(102, 126, 234, 0.3);
      }
    </style>
  </head>
  <body>
    <nav class="topnav">
      <div class="brand"></div>
      <div class="links">
        <a href="/">首页</a>
        <a href="/api/docs">API 文档</a>
        <a href="/api/status">服务器状态</a>
      </div>
    </nav>
    <div class="container">
      <div class="header">
        <h1>📂 文件浏览器</h1>
        <p>HarmonyOS HTTP 服务器 - 浏览 rawfile 资源文件</p>
      </div>
      <div class="content">
        <div class="file-list">
          ${fileListHtml}
        </div>
        <div class="quick-links">
          <h2>快速链接</h2>
          <div class="links">
            <a href="/api/status">📊 服务器状态</a>
            <a href="/api/processing?action=listJson">📋 加工历史数据</a>
            <a href="/api/docs">📚 API接口文档</a>
          </div>
        </div>
      </div>
    </div>
  </body>
</html>`;
  }

  private static async buildDirectoryFileList(
    context: Context,
    dirPath: string,
    rawDirPath: string
  ): Promise<FileItem[]> {
    const fileList: FileItem[] = [];
    const seenPaths = new Set<string>();

    const rawFiles: string[] = await context.resourceManager.getRawFileList(rawDirPath);
    if (!rawFiles || rawFiles.length === 0) {
      return fileList;
    }

    for (let i = 0; i < rawFiles.length; i++) {
      let fileName = rawFiles[i];
      if (fileName.startsWith(rawDirPath + '/')) {
        fileName = fileName.substring(rawDirPath.length + 1);
      } else if (fileName.startsWith(rawDirPath)) {
        fileName = fileName.substring(rawDirPath.length);
      }

      if (!fileName) {
        continue;
      }

      const firstLevel = fileName.split('/')[0];
      const fullPath = dirPath ? `${dirPath}/${firstLevel}` : firstLevel;
      if (seenPaths.has(fullPath)) {
        continue;
      }
      seenPaths.add(fullPath);

      let isDir = false;
      if (fileName.includes('/')) {
        isDir = true;
      } else {
        try {
          const testPath = `${rawDirPath}/${fileName}`;
          const subFiles = await context.resourceManager.getRawFileList(testPath);
          if (subFiles && subFiles.length > 0) {
            isDir = true;
          }
        } catch (e) {
          isDir = false;
        }
      }

      fileList.push({
        name: firstLevel,
        isDir,
        path: fullPath
      });
    }

    return fileList;
  }

  private static renderDirectoryList(fileList: FileItem[]): string {
    if (fileList.length === 0) {
      return '<div class="empty-state">目录为空</div>';
    }

    const dirs: FileItem[] = [];
    const files: FileItem[] = [];

    for (let i = 0; i < fileList.length; i++) {
      if (fileList[i].isDir) {
        dirs.push(fileList[i]);
      } else {
        files.push(fileList[i]);
      }
    }

    let fileListHtml = '';
    for (let i = 0; i < dirs.length; i++) {
      const item = dirs[i];
      const encodedPath = encodeURIComponent(item.path);
      fileListHtml += `
        <div class="file-item directory">
          <span class="file-icon">📁</span>
          <a href="/file/${encodedPath}" class="file-name">${item.name}</a>
        </div>`;
    }

    for (let i = 0; i < files.length; i++) {
      const item = files[i];
      const encodedPath = encodeURIComponent(item.path);
      const fileIcon = item.name.endsWith('.html') ? '🌐' :
        item.name.endsWith('.txt') ? '📄' :
        item.name.endsWith('.json') ? '📋' : '📄';
      fileListHtml += `
        <div class="file-item file">
          <span class="file-icon">${fileIcon}</span>
          <a href="/file/${encodedPath}" class="file-name">${item.name}</a>
        </div>`;
    }

    return fileListHtml;
  }

  private static renderBreadcrumb(dirPath: string): string {
    if (!dirPath) {
      return '<a href="/">首页</a>';
    }

    const parts = dirPath.split('/');
    const breadcrumbParts: string[] = [];
    for (let i = 0; i < parts.length; i++) {
      const path = parts.slice(0, i + 1).join('/');
      if (i === parts.length - 1) {
        breadcrumbParts.push(parts[i]);
      } else {
        breadcrumbParts.push(`<a href="/file/${encodeURIComponent(path)}">${parts[i]}</a>`);
      }
    }

    return `<a href="/">首页</a> / ${breadcrumbParts.join(' / ')}`;
  }

  private static renderDirectoryHtml(dirPath: string, fileListHtml: string, breadcrumbHtml: string): string {
    return `<!DOCTYPE html>
<html lang="zh-CN">
  <head>
    <meta charset="UTF-8" />
    <title>${dirPath || '文件浏览器'} - HarmonyOS HTTP 服务器</title>
    <style>
      * { margin: 0; padding: 0; box-sizing: border-box; }
      :root { --primary:#667eea; --bg:#f5f6fa; --card:#ffffff; --muted:#6b7280; }
      body { font-family: "HarmonyOS Sans", -apple-system, BlinkMacSystemFont, "Segoe UI", Arial, sans-serif; background: var(--bg); color:#1e1e1e; }
      .topnav { position: sticky; top:0; background: var(--primary); color:#fff; display:flex; align-items:center; justify-content:space-between; padding:12px 20px; }
      .brand { font-weight:600; letter-spacing:.3px; }
      .links a { color:#fff; text-decoration:none; margin-left:16px; padding:6px 10px; border-radius:6px; }
      .links a:hover { background: rgba(255,255,255,.18); }
      .container { max-width: 960px; margin: 24px auto; padding: 0 16px; }
      .header { background: var(--card); border-radius: 12px; box-shadow: 0 8px 24px rgba(0,0,0,.08); padding: 24px; text-align:center; }
      .header h1 { font-size: 24px; margin-bottom: 6px; }
      .breadcrumb { padding: 12px 16px; background: #f8f9fa; border: 1px solid #e9ecef; border-radius: 8px; margin-top: 12px; }
      .content { padding: 16px; }
      .file-list { display: block; margin-top: 12px; background: var(--card); border-radius: 8px; border: 1px solid #e9ecef; }
      .file-item { display: flex; align-items: center; padding: 12px 14px; border-bottom: 1px solid #e9ecef; cursor: pointer; transition: background .15s ease; }
      .file-item:last-child { border-bottom: none; }
      .file-item:hover { background: #f6f8ff; }
      .file-item.directory .file-icon { color: #eab308; }
      .file-icon { font-size: 20px; margin-right: 10px; flex-shrink: 0; }
      .file-name { color: #1e1e1e; text-decoration: none; font-size: 15px; font-weight: 500; flex: 1; word-break: break-all; }
      .file-name:hover { color: #667eea; text-decoration: underline; }
      .empty-state { text-align: center; padding: 24px; color: #6c757d; font-size: 14px; }
    </style>
  </head>
  <body>
    <nav class="topnav">
      <div class="brand"></div>
      <div class="links">
        <a href="/">首页</a>
        <a href="/api/docs">API 文档</a>
        <a href="/api/status">服务器状态</a>
      </div>
    </nav>
    <div class="container">
      <div class="header">
        <h1>📂 ${dirPath || '文件浏览器'}</h1>
        <p>HarmonyOS HTTP 服务器 - 浏览 rawfile 资源文件</p>
      </div>
      <div class="breadcrumb">
        ${breadcrumbHtml}
      </div>
      <div class="content">
        <div class="file-list">
          ${fileListHtml}
        </div>
      </div>
    </div>
  </body>
</html>`;
  }

  private static async buildFileContentResponse(
    context: Context,
    textDecoder: util.TextDecoder,
    decodedPath: string,
    rawFilePath: string
  ): Promise<string> {
    try {
      const uint8Array: Uint8Array = context.resourceManager.getRawFileContentSync(rawFilePath);
      const fileExtension = decodedPath.split('.').pop()?.toLowerCase() || '';
      const isTextFile = ['html', 'htm', 'txt', 'json', 'css', 'js', 'xml'].includes(fileExtension);
      const isImageFile = ['png', 'jpg', 'jpeg', 'gif', 'svg', 'webp'].includes(fileExtension);

      if (isTextFile) {
        const content = textDecoder.decode(uint8Array);
        if (fileExtension === 'html' || fileExtension === 'htm') {
          return HttpResponseUtils.buildHtmlResponse(content);
        }

        const escapedContent = content
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;')
          .replace(/'/g, '&#039;');

        const htmlContent = `<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <title>${decodedPath}</title>
  <style>
    body { font-family: monospace; padding: 20px; background: #f5f5f5; }
    pre { background: white; padding: 16px; border-radius: 8px; overflow-x: auto; }
  </style>
</head>
<body>
  <h2>${decodedPath}</h2>
  <pre>${escapedContent}</pre>
</body>
</html>`;
        return HttpResponseUtils.buildHtmlResponse(htmlContent);
      }

      if (isImageFile) {
        const base64 = Base64Utils.toBase64(uint8Array);
        const mimeType = fileExtension === 'svg' ? 'image/svg+xml' :
          fileExtension === 'jpg' || fileExtension === 'jpeg' ? 'image/jpeg' :
          `image/${fileExtension}`;

        const htmlContent = `<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <title>${decodedPath}</title>
  <style>
    body { text-align: center; padding: 20px; background: #f5f5f5; }
    img { max-width: 100%; height: auto; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
  </style>
</head>
<body>
  <h2>${decodedPath}</h2>
  <img src="data:${mimeType};base64,${base64}" alt="${decodedPath}">
</body>
</html>`;
        return HttpResponseUtils.buildHtmlResponse(htmlContent);
      }

      const htmlContent = `<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <title>${decodedPath}</title>
  <style>
    body { font-family: Arial, sans-serif; padding: 40px; text-align: center; background: #f5f5f5; }
    .card { background: white; padding: 32px; border-radius: 12px; max-width: 500px; margin: 0 auto; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
    h2 { color: #333; margin-bottom: 16px; }
    p { color: #666; margin-bottom: 24px; }
    .download-btn { display: inline-block; padding: 12px 24px; background: #667eea; color: white; text-decoration: none; border-radius: 6px; }
    .download-btn:hover { background: #5568d3; }
  </style>
</head>
<body>
  <div class="card">
    <h2>📦 ${decodedPath}</h2>
    <p>这是一个二进制文件，无法在浏览器中直接预览。</p>
    <a href="/api/file/download?path=${encodeURIComponent(decodedPath)}" class="download-btn">下载文件</a>
  </div>
</body>
</html>`;
      return HttpResponseUtils.buildHtmlResponse(htmlContent);
    } catch (error) {
      hilog.error(DOMAIN, 'FileBrowserHandler', `读取文件失败: ${rawFilePath}, 错误: ${JSON.stringify(error)}`);
      return HttpResponseUtils.buildErrorResponse(`文件不存在或无法读取: ${decodedPath}`, 404);
    }
  }
}
