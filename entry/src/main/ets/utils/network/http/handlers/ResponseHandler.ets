import { HttpResponseUtils } from '../../../helpers/HttpResponseUtils';

/**
 * 状态响应数据接口
 */
interface StatusResponseData {
  status: string;
  timestamp: string;
  server: string;
}

/**
 * HTTP响应处理器
 * 负责生成各种通用HTTP响应
 */
export class ResponseHandler {
  /**
   * 获取默认响应（首页）
   */
  static getDefaultResponse(): string {
    const htmlContent = `
      <!DOCTYPE html>
      <html lang="zh-CN">
      <head>
        <meta charset="utf-8">
        <title>HarmonyOS HTTP 服务</title>
        <style>
          :root { --primary:#667eea; --bg:#f5f6fa; --card:#ffffff; --muted:#6b7280; }
          * { box-sizing: border-box; }
          body { font-family: "HarmonyOS Sans", -apple-system, BlinkMacSystemFont, "Segoe UI", Arial, sans-serif; margin:0; background: var(--bg); color:#1e1e1e; }
          .topnav { position: sticky; top:0; background: var(--primary); color:#fff; display:flex; align-items:center; justify-content:space-between; padding:12px 20px; }
          .brand { font-weight:600; letter-spacing:.3px; }
          .links a { color:#fff; text-decoration:none; margin-left:16px; padding:6px 10px; border-radius:6px; }
          .links a:hover { background: rgba(255,255,255,.18); }
          .container { max-width: 960px; margin: 24px auto; padding: 0 16px; }
          .hero { background: var(--card); border-radius: 12px; box-shadow: 0 8px 24px rgba(0,0,0,.08); padding: 28px; }
          .hero h1 { margin:0 0 8px; font-size:28px; }
          .hero p { margin: 6px 0; color: var(--muted); }
          .quick { display:flex; gap:12px; flex-wrap:wrap; margin-top: 20px; }
          .quick a { display:inline-block; padding: 12px 16px; background: var(--primary); color:#fff; text-decoration:none; border-radius: 8px; font-weight:500; }
          .quick a.secondary { background:#10b981; }
          .quick a.neutral { background:#64748b; }
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
        <main class="container">
          <section class="hero">
            <h1>服务器运行正常</h1>
            <p>当前时间：${new Date().toLocaleString('zh-CN')}</p>
            <div class="quick">
              <a href="/">📂 打开文件浏览器</a>
              <a href="/api/docs" class="secondary">📚 查看 API 文档</a>
              <a href="/api/processing?action=listJson" class="neutral">📋 查看加工历史 JSON</a>
            </div>
          </section>
        </main>
      </body>
      </html>`;

    return HttpResponseUtils.buildHtmlResponse(htmlContent);
  }

  /**
   * 状态API响应
   */
  static getStatusResponse(): string {
    const statusData: StatusResponseData = {
      status: 'ok',
      timestamp: new Date().toISOString(),
      server: 'HarmonyOS HTTP Server'
    };
    return HttpResponseUtils.buildSuccessResponse(statusData);
  }

  /**
   * 404未找到响应
   */
  static getNotFoundResponse(): string {
    return HttpResponseUtils.buildErrorResponse('未找到资源', 404);
  }
}

