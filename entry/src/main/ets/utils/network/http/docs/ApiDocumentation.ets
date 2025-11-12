import { HttpResponseUtils } from '../../../helpers/HttpResponseUtils';

/**
 * API接口文档生成器
 * 用于生成历史加工数据表的API文档HTML页面
 */
export class ApiDocumentation {
  /**
   * 获取API文档页面响应
   */
  static getApiDocsResponse(): string {
    const htmlContent = `<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <title>API接口文档 - 历史加工数据表</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    :root { --primary:#667eea; --bg:#f5f6fa; --card:#ffffff; --muted:#6b7280; }
    body { font-family: "HarmonyOS Sans", -apple-system, BlinkMacSystemFont, "Segoe UI", Arial, sans-serif; background: var(--bg); line-height: 1.6; }
    .topnav { position: sticky; top:0; background: var(--primary); color:#fff; display:flex; align-items:center; justify-content:space-between; padding:12px 20px; }
    .brand { font-weight:600; letter-spacing:.3px; }
    .links a { color:#fff; text-decoration:none; margin-left:16px; padding:6px 10px; border-radius:6px; }
    .links a:hover { background: rgba(255,255,255,.18); }
    .container { max-width: 1000px; margin: 24px auto; background: var(--card); border-radius: 12px; box-shadow: 0 8px 24px rgba(0,0,0,0.08); padding: 32px; }
    h1 { color: #333; margin-bottom: 10px; font-size: 32px; }
    .subtitle { color: #666; margin-bottom: 30px; font-size: 16px; }
    h2 { color: #444; margin-top: 40px; margin-bottom: 20px; font-size: 24px; border-bottom: 2px solid #667eea; padding-bottom: 10px; }
    h3 { color: #555; margin-top: 25px; margin-bottom: 15px; font-size: 18px; }
    .api-item { background: #f8f9fa; border-left: 4px solid #667eea; padding: 20px; margin-bottom: 20px; border-radius: 8px; }
    .method { display: inline-block; background: #667eea; color: white; padding: 4px 12px; border-radius: 4px; font-weight: bold; font-size: 14px; margin-right: 10px; }
    .endpoint { font-family: monospace; font-size: 16px; color: #333; margin: 10px 0; }
    .params { margin-top: 15px; }
    .param-item { margin: 8px 0; padding-left: 20px; }
    .param-name { font-family: monospace; color: #667eea; font-weight: bold; }
    .param-desc { color: #666; margin-left: 10px; }
    .required { color: #e74c3c; font-weight: bold; }
    code { background: #f1f3f5; padding: 2px 6px; border-radius: 4px; font-family: monospace; font-size: 14px; }
    pre { background: #2d2d2d; color: #f8f8f2; padding: 15px; border-radius: 8px; overflow-x: auto; margin: 15px 0; }
    .example { background: #e8f4f8; border-left: 4px solid #3498db; padding: 15px; margin: 15px 0; border-radius: 4px; }
    .note { background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 15px 0; border-radius: 4px; }
    a { color: #667eea; text-decoration: none; }
    a:hover { text-decoration: underline; }
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
    <h1>📚 API接口文档</h1>
    <p class="subtitle">历史加工数据表 - 第三方系统访问接口</p>
    
    <div class="note">
      <strong>💡 提示：</strong> 服务器地址通常是 <code>http://[设备IP]:8080</code> 或 <code>http://localhost:8080</code><br>
      如果连接不上，先执行端口映射：<code>hdc fport tcp:8080 tcp:8080</code>
    </div>

    <h2>1️⃣ 获取历史加工数据列表（RESTful 风格，支持分页）</h2>
    <div class="api-item">
      <span class="method">GET</span>
      <span class="endpoint">/api/processing</span>
      <p style="margin-top: 15px; color: #666;">获取历史加工记录列表，支持分页查询</p>
      
      <h3>查询参数：</h3>
      <div class="params">
        <div class="param-item">
          <span class="param-name">page</span>
          <span class="param-desc">页码，从1开始（默认：1）</span>
        </div>
        <div class="param-item">
          <span class="param-name">size</span>
          <span class="param-desc">每页数量，最大100（默认：20）</span>
        </div>
      </div>
      
      <h3>请求示例：</h3>
      <div class="example">
        <strong>获取第一页（20条）：</strong>
        <pre>fetch('http://localhost:8080/api/processing?page=1&size=20')
  .then(res => res.json())
  .then(data => console.log(data));</pre>
      </div>
      
      <div class="example">
        <strong>curl命令：</strong>
        <pre>curl "http://localhost:8080/api/processing?page=1&size=20"</pre>
      </div>

      <h3>返回数据格式：</h3>
      <pre>{
  "ok": true,
  "data": {
    "data": [
      {
        "id": 1,
        "customerName": "客户A",
        "farmName": "农场B",
        "fruitName": "苹果",
        "status": "已完成",
        "startTime": "2025-11-08 11:40",
        "endTime": "2025-11-11 11:40",
        "weight": 123,
        "count": 123,
        "productType": "苹果",
        "totalWeight": 123
      }
    ],
    "pagination": {
      "page": 1,
      "size": 20,
      "total": 100,
      "totalPages": 5
    }
  }
}</pre>
    </div>

    <div class="note" style="margin-top: 20px;">
      <strong>💡 兼容旧版本：</strong> 仍支持 <code>GET /api/processing?action=listJson</code> 获取所有数据（无分页）
    </div>

    <h2>2️⃣ 创建新的加工记录（RESTful 风格）</h2>
    <div class="api-item">
      <span class="method">POST</span>
      <span class="endpoint">/api/processing</span>
      <p style="margin-top: 15px; color: #666;">创建一条新的历史加工记录，支持 JSON 请求体</p>
      
      <h3>请求参数（JSON Body 或 Query String）：</h3>
      <div class="params">
        <div class="param-item">
          <span class="param-name">startTime</span>
          <span class="required">必填</span>
          <span class="param-desc">开始时间，格式：2025-11-08T11:40 或 2025-11-08 11:40:00</span>
        </div>
        <div class="param-item">
          <span class="param-name">endTime</span>
          <span class="required">必填</span>
          <span class="param-desc">结束时间，格式：2025-11-11T11:40 或 2025-11-11 11:40:00</span>
        </div>
        <div class="param-item">
          <span class="param-name">fruitName</span>
          <span class="required">必填</span>
          <span class="param-desc">水果名称</span>
        </div>
        <div class="param-item">
          <span class="param-name">weight</span> 或 <span class="param-name">totalWeight</span>
          <span class="required">必填</span>
          <span class="param-desc">重量（千克），至少填一个</span>
        </div>
        <div class="param-item">
          <span class="param-name">customerName</span>
          <span class="param-desc">客户名称（可选）</span>
        </div>
        <div class="param-item">
          <span class="param-name">farmName</span>
          <span class="param-desc">农场名称（可选）</span>
        </div>
        <div class="param-item">
          <span class="param-name">status</span>
          <span class="param-desc">状态，如：已完成、进行中、待开始（可选）</span>
        </div>
        <div class="param-item">
          <span class="param-name">count</span>
          <span class="param-desc">数量（整数，可选）</span>
        </div>
      </div>

      <h3>请求示例（JSON Body，推荐）：</h3>
      <div class="example">
        <strong>JavaScript (fetch)：</strong>
        <pre>fetch('http://localhost:8080/api/processing', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    startTime: '2025-11-08T11:40',
    endTime: '2025-11-11T11:40',
    fruitName: '苹果',
    weight: 123,
    customerName: '客户A',
    farmName: '农场B',
    status: '已完成',
    count: 123
  })
})
  .then(res => res.json())
  .then(data => console.log('添加成功:', data));</pre>
      </div>

      <div class="example">
        <strong>curl命令（JSON）：</strong>
        <pre>curl -X POST http://localhost:8080/api/processing \\
  -H "Content-Type: application/json" \\
  -d '{"startTime":"2025-11-08T11:40","endTime":"2025-11-11T11:40","fruitName":"苹果","weight":123,"customerName":"客户A","farmName":"农场B","status":"已完成","count":123}'</pre>
      </div>
    </div>

    <div class="note" style="margin-top: 20px;">
      <strong>💡 兼容旧版本：</strong> 仍支持 <code>POST /api/processing?action=insert&...</code> 通过 Query String 传参
    </div>

    <h2>3️⃣ 更新加工记录（RESTful 风格）</h2>
    <div class="api-item">
      <span class="method">PUT</span>
      <span class="endpoint">/api/processing/:id</span>
      <p style="margin-top: 15px; color: #666;">更新指定ID的加工记录（只传要修改的字段）</p>
      
      <h3>路径参数：</h3>
      <div class="params">
        <div class="param-item">
          <span class="param-name">id</span>
          <span class="required">必填</span>
          <span class="param-desc">记录ID（在URL路径中）</span>
        </div>
      </div>

      <h3>请求参数（JSON Body，只传要修改的字段）：</h3>
      <div class="params">
        <div class="param-item">
          <span class="param-name">customerName, farmName, fruitName, status, startTime, endTime, weight, count</span>
          <span class="param-desc">可选，只传要修改的字段</span>
        </div>
      </div>

      <h3>请求示例（JSON Body，推荐）：</h3>
      <div class="example">
        <strong>JavaScript (fetch)：</strong>
        <pre>fetch('http://localhost:8080/api/processing/1', {
  method: 'PUT',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    status: '已完成',
    weight: 200
  })
})
  .then(res => res.json())
  .then(data => console.log('更新成功:', data));</pre>
      </div>

      <div class="example">
        <strong>curl命令：</strong>
        <pre>curl -X PUT http://localhost:8080/api/processing/1 \\
  -H "Content-Type: application/json" \\
  -d '{"status":"已完成","weight":200}'</pre>
      </div>
    </div>

    <div class="note" style="margin-top: 20px;">
      <strong>💡 兼容旧版本：</strong> 仍支持 <code>POST /api/processing?action=update&id=1&...</code>
    </div>

    <h2>4️⃣ 删除加工记录（RESTful 风格）</h2>
    <div class="api-item">
      <span class="method">DELETE</span>
      <span class="endpoint">/api/processing/:id</span>
      <p style="margin-top: 15px; color: #666;">删除指定ID的加工记录</p>
      
      <h3>路径参数：</h3>
      <div class="params">
        <div class="param-item">
          <span class="param-name">id</span>
          <span class="required">必填</span>
          <span class="param-desc">记录ID（在URL路径中）</span>
        </div>
      </div>

      <h3>请求示例：</h3>
      <div class="example">
        <strong>JavaScript (fetch)：</strong>
        <pre>fetch('http://localhost:8080/api/processing/1', {
  method: 'DELETE'
})
  .then(res => res.json())
  .then(data => console.log('删除成功:', data));</pre>
      </div>

      <div class="example">
        <strong>curl命令：</strong>
        <pre>curl -X DELETE http://localhost:8080/api/processing/1</pre>
      </div>
    </div>

    <div class="note" style="margin-top: 20px;">
      <strong>💡 兼容旧版本：</strong> 仍支持 <code>POST /api/processing?action=delete&id=1</code>
    </div>

    <h2>5️⃣ 检查服务器状态</h2>
    <div class="api-item">
      <span class="method">GET</span>
      <span class="endpoint">/api/status</span>
      <p style="margin-top: 15px; color: #666;">检查HTTP服务器是否正常运行</p>
      <pre>fetch('http://localhost:8080/api/status')
  .then(res => res.json())
  .then(data => console.log(data));</pre>
    </div>

    <div class="note" style="margin-top: 40px;">
      <strong>📝 注意事项：</strong>
      <ul style="margin-top: 10px; margin-left: 20px;">
        <li>所有接口都返回JSON格式数据</li>
        <li>成功时返回 <code>{"ok": true, "data": [...]}</code></li>
        <li>失败时返回 <code>{"ok": false, "message": "错误信息"}</code></li>
        <li>时间格式支持：<code>2025-11-08T11:40</code> 或 <code>2025-11-08 11:40:00</code></li>
        <li>开始时间不能晚于结束时间</li>
        <li><strong>RESTful 风格：</strong> 推荐使用 GET/POST/PUT/DELETE 方法，更符合标准</li>
        <li><strong>分页：</strong> GET /api/processing 支持 page 和 size 参数，默认每页20条，最多100条</li>
        <li><strong>JSON Body：</strong> POST/PUT 请求支持 JSON 格式的请求体，Content-Type: application/json</li>
        <li><strong>向后兼容：</strong> 旧版本的 action 参数方式仍然支持</li>
      </ul>
    </div>
  </div>
</body>
</html>`;

    return HttpResponseUtils.buildHtmlResponse(htmlContent);
  }
}


