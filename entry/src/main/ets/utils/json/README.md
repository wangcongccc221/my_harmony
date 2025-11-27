# JSON 通用格式说明

## 📋 概述

所有 API 响应都应该遵循统一的 JSON 格式，确保前后端交互的一致性。

## 📦 格式定义

### 成功响应格式

```json
{
  "ok": true,
  "code": 200,
  "message": "操作成功",
  "data": {
    // 实际数据
  },
  "timestamp": 1703123456789
}
```

### 错误响应格式

```json
{
  "ok": false,
  "code": 400,
  "message": "参数错误",
  "timestamp": 1703123456789
}
```

## 🔧 字段说明

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `ok` | boolean | 是 | 操作是否成功 |
| `code` | number | 否 | 响应码（通常与 HTTP 状态码一致） |
| `message` | string | 否 | 响应消息 |
| `data` | any | 否 | 响应数据（成功时通常有，错误时通常没有） |
| `timestamp` | number | 否 | 时间戳（毫秒） |

## 💻 使用方式

### 方式一：使用 JsonResponseFormat 工具类

```typescript
import { JsonResponseFormat } from './utils/json/JsonResponseFormat';

// 构建成功响应
const success = JsonResponseFormat.buildSuccess(
  { id: 1, name: 'test' },
  '查询成功',
  200
);

// 构建错误响应
const error = JsonResponseFormat.buildError('参数错误', 400);

// 序列化为 JSON 字符串
const json = JsonResponseFormat.serialize(success);
```

### 方式二：使用便捷函数

```typescript
import { buildSuccessResponse, buildErrorResponse } from './utils/json/JsonResponseFormat';

// 成功响应
const success = buildSuccessResponse({ id: 1 }, '操作成功');

// 错误响应
const error = buildErrorResponse('参数错误', 400);
```

### 方式三：使用 HttpResponseUtils（当前项目）

```typescript
import { HttpResponseUtils } from './utils/helpers/HttpResponseUtils';

// 成功响应（自动构建 HTTP 响应）
const httpResponse = HttpResponseUtils.buildSuccessResponse(data, '成功');

// 错误响应
const errorResponse = HttpResponseUtils.buildErrorResponse('错误', 400);
```

## 📝 示例

### 查询列表接口

```typescript
// 成功响应
{
  "ok": true,
  "code": 200,
  "message": "查询成功",
  "data": [
    { "id": 1, "name": "张三" },
    { "id": 2, "name": "李四" }
  ],
  "timestamp": 1703123456789
}
```

### 创建记录接口

```typescript
// 成功响应
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

### 错误响应

```typescript
// 参数错误
{
  "ok": false,
  "code": 400,
  "message": "参数 name 不能为空",
  "timestamp": 1703123456789
}

// 服务器错误
{
  "ok": false,
  "code": 500,
  "message": "服务器内部错误",
  "timestamp": 1703123456789
}
```

## 🎯 最佳实践

1. **所有 API 都应该使用这个格式**，确保一致性
2. **成功时**：`ok: true`，`data` 包含实际数据
3. **失败时**：`ok: false`，`message` 包含错误信息
4. **HTTP 状态码**：通常与 `code` 字段一致
5. **时间戳**：建议包含，方便调试和日志记录

## 📦 在其他项目中使用

复制 `JsonResponseFormat.ets` 到你的项目，然后：

```typescript
import { buildSuccessResponse, buildErrorResponse } from './utils/json/JsonResponseFormat';

// 直接使用
const response = buildSuccessResponse(data);
```

