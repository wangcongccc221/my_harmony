# HTTP 通用格式规范

## 📋 概述

本文档定义了项目中所有 HTTP API 的通用格式规范，包括请求格式和响应格式，确保前后端交互的一致性和可维护性。

---

## 🌐 HTTP 响应格式

### 标准 HTTP 响应结构

所有 HTTP 响应都应遵循标准的 HTTP/1.1 协议格式：

```
HTTP/1.1 {状态码} {状态文本}
Content-Type: {内容类型}
Content-Length: {内容长度}
{其他响应头}

{响应体}
```

### 响应头规范

| 响应头 | 必填 | 说明 | 示例 |
|--------|------|------|------|
| `Content-Type` | 是 | 内容类型 | `application/json; charset=utf-8` |
| `Content-Length` | 是 | 响应体字节长度 | `123` |
| `Content-Encoding` | 否 | 内容编码（如 gzip） | `gzip` |
| `Access-Control-Allow-Origin` | 否 | CORS 跨域支持 | `*` |

### HTTP 状态码规范

| 状态码 | 说明 | 使用场景 |
|--------|------|----------|
| `200 OK` | 请求成功 | 正常响应 |
| `400 Bad Request` | 请求参数错误 | 参数验证失败 |
| `404 Not Found` | 资源不存在 | 路径不存在或资源未找到 |
| `405 Method Not Allowed` | 方法不允许 | 不支持的 HTTP 方法 |
| `500 Internal Server Error` | 服务器内部错误 | 服务器处理异常 |

---

## 📦 JSON 响应体格式

### 统一 JSON 响应结构

所有 API 的 JSON 响应体都应遵循以下统一格式：

```typescript
interface JsonResponse<T> {
  ok: boolean;        // 操作是否成功
  code?: number;     // 响应码（通常与 HTTP 状态码一致）
  message?: string;  // 响应消息
  data?: T;          // 响应数据
  timestamp?: number; // 时间戳（毫秒）
}
```

### 成功响应格式

```json
{
  "ok": true,
  "code": 200,
  "message": "操作成功",
  "data": {
    // 实际数据内容
  },
  "timestamp": 1703123456789
}
```

**字段说明：**
- `ok`: `true` 表示操作成功
- `code`: HTTP 状态码，通常为 `200`
- `message`: 可选的成功提示消息
- `data`: 实际的响应数据（对象、数组等）
- `timestamp`: 响应生成的时间戳（毫秒）

### 错误响应格式

```json
{
  "ok": false,
  "code": 400,
  "message": "参数错误：缺少必填字段 name",
  "timestamp": 1703123456789
}
```

**字段说明：**
- `ok`: `false` 表示操作失败
- `code`: HTTP 状态码（400, 404, 500 等）
- `message`: 错误描述信息（必填）
- `data`: 错误响应通常不包含 `data` 字段
- `timestamp`: 响应生成的时间戳（毫秒）

---

## 📥 HTTP 请求格式

### 请求行格式

```
{方法} {路径} HTTP/1.1
```

**示例：**
```
GET /api/processing?page=1&pageSize=50 HTTP/1.1
POST /api/processing HTTP/1.1
PUT /api/processing/123 HTTP/1.1
DELETE /api/processing/123 HTTP/1.1
```

### 请求头规范

| 请求头 | 必填 | 说明 | 示例 |
|--------|------|------|------|
| `Content-Type` | POST/PUT 必填 | 请求体类型 | `application/json` |
| `Content-Length` | POST/PUT 必填 | 请求体字节长度 | `123` |
| `Accept-Encoding` | 否 | 支持的编码（如 gzip） | `gzip, deflate` |

### 请求体格式

#### JSON 格式（推荐）

```json
{
  "field1": "value1",
  "field2": 123,
  "field3": {
    "nested": "value"
  }
}
```

#### 表单格式（兼容）

```
field1=value1&field2=value2
```

---

## 🔧 使用方式

### 方式一：使用 HttpResponseUtils（推荐）

```typescript
import { HttpResponseUtils } from '../../utils/helpers/HttpResponseUtils';
import { buildSuccessResponse, buildErrorResponse } from '../../utils/json/JsonResponseFormat';

// 构建成功响应（自动包含 HTTP 响应头）
const successResponse = HttpResponseUtils.buildSuccessResponse(
  { id: 1, name: 'test' },
  '操作成功'
);

// 构建错误响应
const errorResponse = HttpResponseUtils.buildErrorResponse('参数错误', 400);
```

### 方式二：使用 JsonResponseFormat + HttpResponseUtils

```typescript
import { JsonResponseFormat } from '../../utils/json/JsonResponseFormat';
import { HttpResponseUtils } from '../../utils/helpers/HttpResponseUtils';

// 构建 JSON 响应对象
const jsonResponse = JsonResponseFormat.buildSuccess(
  { id: 1, name: 'test' },
  '操作成功',
  200
);

// 序列化为 HTTP 响应字符串
const httpResponse = HttpResponseUtils.buildJsonResponse(jsonResponse, 200);
```

### 方式三：直接使用便捷函数

```typescript
import { buildSuccessResponse, buildErrorResponse } from '../../utils/json/JsonResponseFormat';
import { HttpResponseUtils } from '../../utils/helpers/HttpResponseUtils';

// 成功响应
const json = buildSuccessResponse({ id: 1 }, '操作成功');
const httpResponse = HttpResponseUtils.buildJsonResponse(json);

// 错误响应
const errorJson = buildErrorResponse('参数错误', 400);
const errorHttpResponse = HttpResponseUtils.buildJsonResponse(errorJson, 400);
```

---

## 📝 实际示例

### 示例 1：查询列表接口

**请求：**
```
GET /api/processing?page=1&pageSize=50 HTTP/1.1
```

**响应：**
```json
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
Content-Length: 456

{
  "ok": true,
  "code": 200,
  "message": "查询成功",
  "data": {
    "list": [
      { "id": 1, "name": "记录1" },
      { "id": 2, "name": "记录2" }
    ],
    "total": 100,
    "page": 1,
    "pageSize": 50
  },
  "timestamp": 1703123456789
}
```

### 示例 2：创建记录接口

**请求：**
```
POST /api/processing HTTP/1.1
Content-Type: application/json
Content-Length: 45

{
  "customerName": "客户A",
  "fruitName": "苹果"
}
```

**响应：**
```json
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
Content-Length: 123

{
  "ok": true,
  "code": 200,
  "message": "创建成功",
  "data": {
    "id": 123
  },
  "timestamp": 1703123456789
}
```

### 示例 3：参数错误响应

**请求：**
```
POST /api/processing HTTP/1.1
Content-Type: application/json
Content-Length: 20

{
  "name": ""
}
```

**响应：**
```json
HTTP/1.1 400 Bad Request
Content-Type: application/json; charset=utf-8
Content-Length: 89

{
  "ok": false,
  "code": 400,
  "message": "参数错误：name 不能为空",
  "timestamp": 1703123456789
}
```

### 示例 4：资源不存在响应

**请求：**
```
GET /api/processing/999 HTTP/1.1
```

**响应：**
```json
HTTP/1.1 404 Not Found
Content-Type: application/json; charset=utf-8
Content-Length: 87

{
  "ok": false,
  "code": 404,
  "message": "资源不存在：ID 999 的记录未找到",
  "timestamp": 1703123456789
}
```

---

## 🎯 最佳实践

### 1. 统一使用工具类

✅ **推荐：** 使用 `HttpResponseUtils` 和 `JsonResponseFormat` 构建响应
```typescript
const response = HttpResponseUtils.buildSuccessResponse(data, '操作成功');
```

❌ **不推荐：** 手动拼接 HTTP 响应字符串
```typescript
const response = `HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n\r\n${JSON.stringify(data)}`;
```

### 2. 错误处理

✅ **推荐：** 提供清晰的错误消息
```typescript
HttpResponseUtils.buildErrorResponse('参数错误：缺少必填字段 name', 400);
```

❌ **不推荐：** 使用模糊的错误消息
```typescript
HttpResponseUtils.buildErrorResponse('错误', 400);
```

### 3. 状态码一致性

✅ **推荐：** JSON 响应中的 `code` 与 HTTP 状态码保持一致
```json
{
  "ok": false,
  "code": 400,  // 与 HTTP 状态码 400 一致
  "message": "参数错误"
}
```

### 4. 时间戳

✅ **推荐：** 所有响应都包含 `timestamp` 字段，方便调试和日志记录

### 5. 数据字段

✅ **推荐：** 成功响应时，将实际数据放在 `data` 字段中
```json
{
  "ok": true,
  "data": {
    "id": 1,
    "name": "test"
  }
}
```

❌ **不推荐：** 将数据直接放在响应根级别
```json
{
  "ok": true,
  "id": 1,
  "name": "test"
}
```

---

## 📦 相关文件

- **JSON 响应格式工具类：** `entry/src/main/ets/utils/json/JsonResponseFormat.ets`
- **HTTP 响应工具类：** `entry/src/main/ets/utils/helpers/HttpResponseUtils.ets`
- **API 处理器示例：** `entry/src/main/ets/utils/network/http/handlers/ProcessingApiHandler.ets`
- **JSON 格式说明文档：** `entry/src/main/ets/utils/json/README.md`

---

## 🔍 检查清单

在实现新的 API 接口时，请确保：

- [ ] HTTP 响应头包含 `Content-Type` 和 `Content-Length`
- [ ] JSON 响应体包含 `ok` 字段（`true` 或 `false`）
- [ ] 成功响应包含 `data` 字段
- [ ] 错误响应包含 `message` 字段
- [ ] HTTP 状态码与 JSON 中的 `code` 字段一致
- [ ] 响应包含 `timestamp` 字段
- [ ] 使用 `HttpResponseUtils` 或 `JsonResponseFormat` 构建响应
- [ ] 错误消息清晰明确，便于调试

---

## 📚 参考资料

- [HTTP/1.1 规范 (RFC 7231)](https://tools.ietf.org/html/rfc7231)
- [JSON 格式规范 (RFC 7159)](https://tools.ietf.org/html/rfc7159)
- [项目 JSON 通用格式说明](./../../json/README.md)

