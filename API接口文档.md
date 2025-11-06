# 后端API接口文档

> 简单易懂版本，5分钟上手

## 📋 快速开始

**服务器地址**: `http://localhost:8080` 或 `http://[设备IP]:8080`

**如果连接不上，先执行端口映射**:
```bash
hdc fport tcp:8080 tcp:8080
```

---

## 🔌 接口列表

### 1️⃣ 检查服务器是否运行

**接口**: `GET /api/status`

**说明**: 看看服务器是不是在工作

**示例**:
```
浏览器访问: http://localhost:8080/api/status
```

**返回**:
```json
{
  "status": "ok",
  "timestamp": "2025-01-15T10:30:00.000Z",
  "server": "HarmonyOS HTTP Server"
}
```

---

### 2️⃣ 浏览文件

**接口**: `GET /files/` 或 `GET /file/`

**说明**: 在浏览器里查看应用里的文件

**示例**:
```
浏览器访问: http://localhost:8080/files/
```

**支持的格式**:
- 📄 文本文件（.txt, .json, .html）→ 直接显示
- 📊 CSV/XLSX → 自动下载（Excel能打开）
- 🖼️ 图片（.png, .jpg）→ 小图显示，大图下载
- 📦 其他文件 → 下载

---

### 3️⃣ 获取加工历史数据

**接口**: `GET /api/processing?action=listJson`

**说明**: 获取所有加工记录，返回JSON格式

**示例**:
```
浏览器访问: http://localhost:8080/api/processing?action=listJson
```

**返回**:
```json
{
  "ok": true,
  "data": [
    {
      "id": 1,
      "startTime": "2025-01-15 10:00:00",
      "endTime": "2025-01-15 11:00:00",
      "productType": "苹果",
      "totalWeight": 1500.5,
      "customerName": "客户A",
      "farmName": "农场B",
      "fruitName": "红富士",
      "status": "已完成",
      "count": 100,
      "weight": 15005.0
    }
  ]
}
```

---

### 4️⃣ 添加加工记录

**接口**: `POST /api/processing?action=insert`

**说明**: 添加一条新的加工记录

**必填参数**:
- `startTime`: 开始时间（格式: `2025-01-15 10:00:00`）**必填**
- `endTime`: 结束时间（格式: `2025-01-15 11:00:00`）**必填**
- `fruitName`: 水果名称 **必填**
- `totalWeight` 或 `weight`: 重量（至少填一个）**必填**

**可选参数**:
- `productType`: 产品类型
- `customerName`: 客户名称
- `farmName`: 农场名称
- `status`: 状态
- `count`: 数量（整数）

**示例（使用curl）**:
```bash
curl -X POST "http://localhost:8080/api/processing?action=insert" \
  -d "startTime=2025-01-15 10:00:00" \
  -d "endTime=2025-01-15 11:00:00" \
  -d "fruitName=苹果" \
  -d "totalWeight=1500.5" \
  -d "customerName=客户A" \
  -d "farmName=农场B" \
  -d "status=已完成" \
  -d "count=100" \
  -d "weight=15005.0"
```

**示例（使用JavaScript）**:
```javascript
// 方法1: 使用URL参数
const params = new URLSearchParams({
  action: 'insert',
  startTime: '2025-01-15 10:00:00',
  endTime: '2025-01-15 11:00:00',
  fruitName: '苹果',
  totalWeight: '1500.5',
  customerName: '客户A',
  farmName: '农场B',
  status: '已完成',
  count: '100',
  weight: '15005.0'
});

fetch(`http://localhost:8080/api/processing?${params}`, {
  method: 'POST'
})
  .then(res => res.json())
  .then(data => console.log('添加成功:', data));
```

**返回**:
```json
{
  "ok": true,
  "data": [...]  // 返回所有记录（包括新添加的）
}
```

**错误响应示例**:
```json
{
  "ok": false,
  "message": "参数不能为空"
}
```
或
```json
{
  "ok": false,
  "message": "开始时间不能晚于结束时间"
}
```

**错误情况**:
- 缺少必填参数 → 返回 `400 Bad Request`，message: `"参数不能为空"`
- 开始时间晚于结束时间 → 返回 `400 Bad Request`，message: `"开始时间不能晚于结束时间"`

---

### 5️⃣ 修改加工记录

**接口**: `POST /api/processing?action=update&id=1`

**说明**: 修改指定ID的记录

**必填参数**:
- `id`: 记录ID（必填，在URL里）

**可修改的字段**（只传要改的字段，未传入的字段保持原值）:
- `startTime`: 开始时间
- `endTime`: 结束时间
- `productType`: 产品类型
- `totalWeight`: 总重量
- `customerName`: 客户名称 ✅ **新增支持**
- `farmName`: 农场名称 ✅ **新增支持**
- `fruitName`: 水果名称 ✅ **新增支持**
- `status`: 状态 ✅ **新增支持**
- `count`: 数量（整数）✅ **新增支持**
- `weight`: 重量（千克）✅ **新增支持**

**示例**:
```bash
# 只更新基础字段
curl -X POST "http://localhost:8080/api/processing?action=update&id=1" \
  -d "startTime=2025-01-15 10:00:00" \
  -d "endTime=2025-01-15 12:00:00" \
  -d "productType=苹果" \
  -d "totalWeight=1600.0"

# 更新扩展字段
curl -X POST "http://localhost:8080/api/processing?action=update&id=1" \
  -d "status=已完成" \
  -d "customerName=客户B" \
  -d "farmName=农场C" \
  -d "fruitName=红富士" \
  -d "count=150" \
  -d "weight=16000.0"
```

**返回**:
```json
{
  "ok": true,
  "data": [...]  // 返回所有记录（已更新）
}
```

**错误响应示例**:
```json
{
  "ok": false,
  "message": "ID无效或未提供"
}
```
或
```json
{
  "ok": false,
  "message": "记录ID 999 不存在"
}
```

**错误情况**:
- 缺少ID或ID无效（≤0） → 返回 `400 Bad Request`，message: `"ID无效或未提供"`
- ID不存在 → 返回 `404 Not Found`，message: `"记录ID {id} 不存在"`
- 数据库更新失败 → 返回 `500 Internal Server Error`

---

### 6️⃣ 删除加工记录

**接口**: `POST /api/processing?action=delete&id=1`

**说明**: 删除指定ID的记录

**需要的参数**:
- `id`: 记录ID（必填，在URL里）

**示例**:
```bash
curl -X POST "http://localhost:8080/api/processing?action=delete&id=1"
```

**返回**:
```json
{
  "ok": true,
  "data": [...]  // 返回剩余的所有记录
}
```

**错误响应示例**:
```json
{
  "ok": false,
  "message": "ID无效或未提供"
}
```
或
```json
{
  "ok": false,
  "message": "记录ID 999 不存在"
}
```

**错误情况**:
- 缺少ID或ID无效（≤0） → 返回 `400 Bad Request`，message: `"ID无效或未提供"`
- ID不存在 → 返回 `404 Not Found`，message: `"记录ID {id} 不存在"`
- 数据库删除失败 → 返回 `500 Internal Server Error`

---

### 7️⃣ 提交水果信息（最重要！）

**接口**: `POST /api/fruit-info`

**说明**: 提交水果检测数据。**智能功能**：如果这个通道已经有数据，会自动更新；如果没有，会新建。

**请求格式**: JSON

**示例（使用JavaScript）**:
```javascript
fetch('http://localhost:8080/api/fruit-info', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    lane: 'lane-1',        // 通道（必填）：lane-1 到 lane-8
    level: 'A',            // 等级（可选）
    diameterMm: 85.5,      // 直径（毫米）
    weightG: 250.0,        // 重量（克）
    brix: 12.5,            // 糖度
    color1Pct: 60.0,       // 颜色1比例（%）
    acidity: 0.8,          // 酸度
    outlet: '出口1'        // 出口
    // ... 其他字段都是可选的，看下面完整列表
  })
})
  .then(res => res.json())
  .then(data => {
    if (data.success) {
      console.log('✅ 保存成功！', data.message);
    } else {
      console.error('❌ 保存失败:', data.message);
    }
  });
```

**完整字段列表**（除了`lane`，其他都是可选的）:

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| `lane` | 字符串 | **必填**：通道，格式 `lane-1` 到 `lane-8` | `"lane-1"` |
| `level` | 字符串 | 等级 | `"A"` |
| `diameterMm` | 数字 | 直径（毫米） | `85.5` |
| `weightG` | 数字 | 重量（克） | `250.0` |
| `projectionAreaMm2` | 数字 | 投影面积（平方毫米） | `5723.5` |
| `densityKgPerM3` | 数字 | 密度（千克/立方米） | `850.0` |
| `volumeMm3` | 数字 | 体积（立方毫米） | `294117.6` |
| `brix` | 数字 | 糖度 | `12.5` |
| `color1Pct` | 数字 | 颜色1比例（%） | `60.0` |
| `acidity` | 数字 | 酸度 | `0.8` |
| `color2Pct` | 数字 | 颜色2比例（%） | `30.0` |
| `drynessPct` | 数字 | 干燥度（%） | `5.0` |
| `color3Pct` | 数字 | 颜色3比例（%） | `10.0` |
| `maturityPct` | 数字 | 成熟度（%） | `85.0` |
| `defectAreaMm2` | 数字 | 瑕疵面积（平方毫米） | `0.0` |
| `pulpColorPct` | 数字 | 果肉颜色比例（%） | `70.0` |
| `defectCount` | 整数 | 瑕疵数量 | `0` |
| `outlet` | 字符串 | 出口 | `"出口1"` |
| `verticalAxis` | 数字 | 垂直轴 | `85.5` |
| `horizontalRatio` | 数字 | 水平比例 | `0.95` |
| `flatEllipticalRatioMm` | 数字 | 扁平椭圆比例（毫米） | `81.2` |

**返回**:
```json
{
  "success": true,
  "message": "水果信息已提交，正在保存到lane-1...",
  "data": {
    "lane": "lane-1",
    "level": "A",
    ...
  }
}
```

**重要提示**:
- ✅ 如果通道 `lane-1` 已经有数据，会自动更新
- ✅ 如果通道 `lane-1` 没有数据，会自动新建
- ✅ 检测时间由服务器自动生成，不需要传
- ✅ 保存是异步的，响应会立即返回

---

## 🎯 实际使用场景

### 场景1: 网页表单提交水果信息

在HTML页面（比如 `水果信息录入.html`）中，这样提交：

```html
<form id="fruitInfoForm">
  <input type="text" name="lane" value="lane-1">
  <input type="number" name="diameterMm" value="85.5">
  <input type="number" name="weightG" value="250.0">
  <input type="number" name="brix" value="12.5">
  <button type="submit">保存</button>
</form>

<script>
document.getElementById('fruitInfoForm').addEventListener('submit', async (e) => {
  e.preventDefault();
  const formData = new FormData(e.target);
  const data = {};
  for (let [key, value] of formData.entries()) {
    // 数字字段转成数字
    if (!isNaN(parseFloat(value))) {
      data[key] = parseFloat(value);
    } else {
      data[key] = value;
    }
  }

  const response = await fetch('/api/fruit-info', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  });

  const result = await response.json();
  if (result.success) {
    alert('保存成功！');
  } else {
    alert('保存失败: ' + result.message);
  }
});
</script>
```

### 场景2: 从外部设备发送数据

使用Python脚本发送：

```python
import requests
import json

url = "http://localhost:8080/api/fruit-info"

data = {
    "lane": "lane-1",
    "level": "A",
    "diameterMm": 85.5,
    "weightG": 250.0,
    "brix": 12.5,
    "color1Pct": 60.0,
    "acidity": 0.8,
    "outlet": "出口1"
}

response = requests.post(url, json=data)
result = response.json()

if result.get("success"):
    print("✅ 保存成功！")
else:
    print(f"❌ 保存失败: {result.get('message')}")
```

### 场景3: 批量获取加工历史

```javascript
// 获取所有加工记录
fetch('http://localhost:8080/api/processing?action=listJson')
  .then(res => res.json())
  .then(result => {
    if (result.ok) {
      console.log(`共有 ${result.data.length} 条记录`);
      result.data.forEach(record => {
        console.log(`${record.id}: ${record.fruitName} - ${record.totalWeight}吨`);
      });
    }
  });
```

---

## ⚠️ 常见问题

### Q: 连接不上怎么办？

**A**: 
1. 确认应用已启动
2. 执行端口映射：`hdc fport tcp:8080 tcp:8080`
3. 检查防火墙是否阻止了8080端口

### Q: 返回404怎么办？

**A**: 
- 检查URL路径是否正确
- 确认接口路径是 `/api/xxx` 而不是 `/api/xxx/`

### Q: 水果信息保存失败？

**A**: 
- 确认 `lane` 字段格式是 `lane-1` 到 `lane-8`
- 确认请求头包含 `Content-Type: application/json`
- 确认JSON格式正确

### Q: 数据保存后去哪了？

**A**: 
- 所有数据保存在应用的本地数据库（RDB）
- 重启应用后数据仍然存在
- 可以通过 `/api/processing?action=listJson` 查询

### Q: 文件浏览看不到文件？

**A**: 
- 文件在应用沙箱目录下
- 只能访问应用有权限的文件
- 导出文件会在 `/files/` 目录下

### Q: 加工历史接口返回 `ok` 还是 `success`？

**A**: 
- 加工历史接口（`/api/processing`）返回的是 `ok: true/false`
- 水果信息接口（`/api/fruit-info`）返回的是 `success: true/false`
- 两个接口的返回格式不同，注意区分

### Q: update接口支持哪些字段？

**A**: 
- ✅ 现在update接口支持所有字段了！
- 包括：startTime、endTime、productType、totalWeight、customerName、farmName、fruitName、status、count、weight
- 只传要修改的字段即可，未传入的字段会保持原值

---

## 📝 总结

**最常用的3个接口**:

1. **检查服务器**: `GET /api/status`
2. **获取数据**: `GET /api/processing?action=listJson`
3. **提交水果信息**: `POST /api/fruit-info` (JSON格式)

**记住**:
- 所有接口都是 `http://localhost:8080` 开头
- 水果信息接口必须用 `POST` 方法，且 `Content-Type` 必须是 `application/json`
- 加工历史接口的 `action` 参数在URL里，数据在URL参数里（不是JSON）
- 加工历史接口返回 `ok`，水果信息接口返回 `success`，格式不同
- 服务器支持跨域（CORS），可以从网页直接调用

---

**有问题？** 看代码：`entry/src/main/ets/utils/network/HttpServerHandler.ets`
