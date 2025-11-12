# HTTP服务器综合文档

## 1. 架构概述

HarmonyOS HTTP服务器是一个基于TCP Socket实现的轻量级HTTP服务，提供了完整的HTTP请求处理、路由分发和API服务能力。该服务器采用了模块化设计，将核心服务器、路由处理、API实现和响应生成等功能分离，便于维护和扩展。

### 1.1 核心架构组件

| 组件名称 | 主要职责 | 文件路径 |
|---------|---------|----------|
| HttpServer | 服务器核心实现，基于TCP Socket | entry/src/main/ets/utils/network/http/HttpServer.ets |
| HttpServerHandler | 路由分发和请求处理 | entry/src/main/ets/utils/network/http/HttpServerHandler.ets |
| ProcessingApiHandler | 加工数据API实现 | entry/src/main/ets/utils/network/http/handlers/ProcessingApiHandler.ets |
| FileBrowserHandler | 文件浏览功能实现 | entry/src/main/ets/utils/network/http/handlers/FileBrowserHandler.ets |
| ResponseHandler | 通用响应处理 | entry/src/main/ets/utils/network/http/handlers/ResponseHandler.ets |
| HttpResponseUtils | HTTP响应工具类 | entry/src/main/ets/utils/helpers/HttpResponseUtils.ets |
| ApiDocumentation | API文档生成器 | entry/src/main/ets/utils/network/http/docs/ApiDocumentation.ets |

### 1.2 架构图

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           HTTP客户端                                    │
└───────────────┬─────────────────────────────────────────────────────────┘
                │
┌───────────────▼─────────────────────────────────────────────────────────┐
│                        HttpServer (TCP Socket)                           │
└───────────────┬─────────────────────────────────────────────────────────┘
                │
┌───────────────▼─────────────────────────────────────────────────────────┐
│                     HttpServerHandler (路由分发)                         │
├───────────────┬────────────────────────┬────────────────────────────────┤
│               │                        │                                │
▼               ▼                        ▼                                ▼
┌─────────────────────────────────┐  ┌─────────────────┐  ┌───────────────────┐
│       静态文件/根路径处理        │  │  API接口处理     │  │  系统状态接口      │
└─────────────────────────────────┘  └─────────┬───────┘  └───────────────────┘
                                               │
                                               ▼
                           ┌───────────────────────────────┐
                           │      ProcessingApiHandler      │
                           │      (RESTful API实现)        │
                           └───────────────────────────────┘
```

## 2. 核心功能模块

### 2.1 服务器核心 (HttpServer)

服务器核心组件基于HarmonyOS的`@kit.NetworkKit`中的TCP Socket实现，提供了HTTP服务器的基础功能。

**主要功能：**
- 启动/停止HTTP服务器
- 监听指定端口的TCP连接
- 处理客户端连接和断开事件
- 异步处理HTTP请求，避免阻塞主线程
- 错误处理和异常捕获

**关键特性：**
- 单例模式实现，确保全局唯一服务器实例
- 支持自定义请求处理器注入
- 异步请求处理，提高并发性能
- 完善的错误处理机制

**使用方式：**

```typescript
import { startHttpServer, stopHttpServer, isHttpServerRunning } from './http/HttpServer';

// 启动HTTP服务器
await startHttpServer(8080, customHandler);

// 检查服务器是否运行
const running = isHttpServerRunning();

// 停止服务器
stopHttpServer();
```

### 2.2 路由处理器 (HttpServerHandler)

路由处理器负责解析HTTP请求并根据请求路径将其分发到相应的处理模块。

**主要功能：**
- 解析HTTP请求路径和方法
- 路由请求到相应的处理函数
- 设置文件浏览的基础路径
- 处理不同类型的HTTP请求

**路由规则：**
- `/` 或 `/index` - 文件浏览器首页
- `/file/*` - 文件内容访问
- `/api/status` - 服务器状态接口
- `/api/docs` 或 `/api/help` - API文档页面
- `/api/processing*` - 加工数据API接口

### 2.3 RESTful API处理器 (ProcessingApiHandler)

实现了加工数据的RESTful API接口，支持数据的查询、插入、更新和删除操作。

**主要功能：**
- 支持分页查询加工数据
- 处理数据插入、更新和删除请求
- 支持JSON格式请求体
- 兼容旧版本API调用方式

**API设计特点：**
- 遵循RESTful风格设计
- 支持GET/POST/PUT/DELETE等标准HTTP方法
- 返回统一格式的JSON响应
- 支持分页和参数过滤

### 2.4 文件浏览器 (FileBrowserHandler)

提供文件浏览功能，允许访问应用内的rawfile资源。

**主要功能：**
- 浏览文件系统目录结构
- 查看文件内容
- 支持目录导航和面包屑路径
- 渲染HTML格式的文件列表

**关键特性：**
- 支持URL路径解码
- 目录递归遍历
- 响应式HTML页面渲染
- 安全的文件访问控制

### 2.5 响应处理工具 (HttpResponseUtils)

提供统一的HTTP响应构建方法，确保响应格式的一致性。

**主要功能：**
- 构建JSON格式响应
- 构建HTML格式响应
- 构建成功和错误响应
- 支持CORS跨域请求

**响应格式：**
- 成功响应: `{"ok": true, "data": ..., "message": ...}`
- 错误响应: `{"ok": false, "message": "错误信息"}`

## 3. RESTful API接口详细说明

### 3.1 状态检查接口

**GET /api/status**

- **功能**：检查HTTP服务器是否正常运行
- **请求参数**：无
- **响应示例**：

```json
{
  "ok": true,
  "data": {
    "status": "ok",
    "timestamp": "2025-01-01T12:00:00.000Z",
    "server": "HarmonyOS HTTP Server"
  }
}
```

### 3.2 加工历史API

#### 3.2.1 获取加工历史列表

**GET /api/processing**

- **功能**：获取加工历史记录列表，支持分页
- **请求参数**：
  - `page`：页码（默认1）
  - `size`：每页条数（默认20，最大100）
  - 兼容旧版：`action=listJson`（无分页）
- **响应示例**：

```json
{
  "ok": true,
  "data": {
    "data": [
      {
        "id": 1,
        "startTime": "2025-01-01 10:00:00",
        "endTime": "2025-01-01 12:00:00",
        "productType": "苹果",
        "totalWeight": 100,
        "customerName": "客户A",
        "farmName": "农场A",
        "status": "已完成"
      }
    ],
    "pagination": {
      "page": 1,
      "size": 20,
      "total": 1,
      "totalPages": 1
    }
  }
}
```

#### 3.2.2 创建加工记录

**POST /api/processing**

- **功能**：创建新的加工记录
- **请求体参数**：
  - `startTime`：开始时间（必填）
  - `endTime`：结束时间（必填）
  - `productType/fruitName`：产品类型/水果名称（必填）
  - `totalWeight/weight`：重量（必填）
  - `customerName`：客户名称
  - `farmName`：农场名称
  - `status`：状态
  - `count/quantity`：数量
- **响应示例**：

```json
{
  "ok": true,
  "message": "添加成功",
  "data": [/* 所有记录列表 */]
}
```

#### 3.2.3 更新加工记录

**PUT /api/processing/:id**

- **功能**：更新指定ID的加工记录
- **路径参数**：
  - `id`：记录ID
- **请求体参数**：可选字段，与创建接口相同
- **响应示例**：

```json
{
  "ok": true,
  "message": "更新成功",
  "data": [/* 更新后的所有记录列表 */]
}
```

#### 3.2.4 删除加工记录

**DELETE /api/processing/:id**

- **功能**：删除指定ID的加工记录
- **路径参数**：
  - `id`：记录ID
- **响应示例**：

```json
{
  "ok": true,
  "message": "删除成功",
  "data": [/* 删除后的所有记录列表 */]
}
```

### 3.3 数据模型

| 字段名 | 类型 | 描述 |
|--------|------|------|
| id | number | 记录ID（自增） |
| startTime | string | 开始时间 |
| endTime | string | 结束时间 |
| productType/fruitName | string | 产品类型/水果名称 |
| totalWeight/weight | number | 总重量 |
| customerName | string | 客户名称 |
| farmName | string | 农场名称 |
| status | string | 状态 |
| count/quantity | number | 数量 |

## 4. 工作流程

### 4.1 服务器启动流程

1. 调用`startHttpServer`函数启动HTTP服务器，指定端口和可选的请求处理器
2. 服务器创建TCP Socket并监听指定端口
3. 注册连接处理函数，等待客户端连接
4. 设置默认或自定义请求处理器

### 4.2 请求处理流程

1. 客户端发送HTTP请求到服务器
2. 服务器接收连接，创建客户端Socket
3. 客户端Socket接收请求数据并调用请求处理器
4. HttpServerHandler解析请求路径和方法
5. 根据路由规则将请求分发到相应的处理模块
6. 处理模块生成响应内容
7. 通过HttpResponseUtils构建标准HTTP响应
8. 服务器将响应发送回客户端

### 4.3 错误处理机制

1. 捕获请求处理过程中的所有异常
2. 记录详细的错误日志
3. 返回标准的错误响应（404/500等）
4. 确保即使发生错误，服务器仍能继续运行

**错误响应类型：**
- 请求解析错误返回404响应
- API参数验证失败返回400响应
- 服务器内部错误返回500响应
- 不支持的HTTP方法返回405响应
- 所有错误均记录日志便于调试

## 5. 技术特性

### 5.1 技术栈

- **底层网络**：HarmonyOS NetworkKit TCP Socket
- **开发语言**：TypeScript (ArkTS)
- **响应格式**：JSON、HTML
- **API风格**：RESTful
- **纯JS/TS实现**，无外部依赖

### 5.2 性能优化

- 异步请求处理，避免阻塞主线程
- 动态路由匹配，高效分发请求
- 惰性加载资源，优化内存使用
- 分页查询支持，减少大数据量传输
- 错误处理和资源释放，防止内存泄漏
- 自动清理事件监听器，避免内存泄漏

### 5.3 安全性考虑

- URL解码和参数验证
- 请求路径安全检查
- 异常捕获和错误处理
- 资源访问控制
- 错误信息安全脱敏
- 文件路径安全校验

## 6. 配置和扩展

### 6.1 服务器配置

- 端口配置：通过`startHttpServer`函数参数指定
- 基础路径配置：通过`HttpServerHandler.setFileBasePath`设置
- 自定义处理器：可注入自定义`HttpRequestHandler`函数

### 6.2 扩展方式

- 添加新的路由规则：在`HttpServerHandler.createRouterHandler`中扩展
- 实现新的API处理器：创建新的处理器类并在路由中注册
- 自定义响应格式：扩展`HttpResponseUtils`类

### 6.3 扩展自定义处理器

可以通过实现`HttpRequestHandler`接口创建自定义处理器：

```typescript
const customHandler: HttpRequestHandler = async (rawRequest: string): Promise<string> => {
  // 自定义请求处理逻辑
  return 'HTTP/1.1 200 OK\r\n\r\nHello from custom handler!';
};

await startHttpServer(8080, customHandler);
```

## 7. 常见问题与解决方案

### 7.1 端口占用问题

**现象**：启动服务器时提示端口被占用
**解决方法**：
- 选择其他未被占用的端口
- 检查是否有其他服务占用了该端口

### 7.2 权限问题

**现象**：无法访问文件系统
**解决方法**：
- 确保应用有正确的存储权限
- 检查文件浏览路径设置是否正确

### 7.3 日期格式问题

**现象**：时间参数验证失败
**解决方法**：
- 确保时间格式正确：`2025-11-08T11:40` 或 `2025-11-08 11:40:00`
- 确保开始时间不晚于结束时间

## 8. 代码示例

### 8.1 启动HTTP服务器

```typescript
import { startHttpServer } from './http/HttpServer';
import { HttpServerHandler } from './http/HttpServerHandler';
import { AbilityConstant, UIAbility } from '@kit.AbilityKit';

class MainAbility extends UIAbility {
  onCreate(want, launchParam) {
    // 设置文件浏览基础路径
    HttpServerHandler.setFileBasePath(this.context);
    
    // 启动HTTP服务器
    this.startServer();
  }
  
  async startServer() {
    try {
      // 使用默认路由处理器
      await startHttpServer(8080, HttpServerHandler.createRouterHandler());
      console.log('HTTP服务器启动成功，端口：8080');
    } catch (error) {
      console.error('HTTP服务器启动失败:', error);
    }
  }
}
```

### 8.2 API调用示例（客户端）

#### 获取加工历史列表

```javascript
// 使用Fetch API
fetch('http://localhost:8080/api/processing?page=1&size=20')
  .then(response => response.json())
  .then(data => {
    if (data.ok) {
      console.log('加工历史列表:', data.data);
      // 更新UI显示数据
    } else {
      console.error('获取失败:', data.message);
    }
  })
  .catch(error => console.error('请求错误:', error));
```

#### 创建新记录

```javascript
// 创建新的加工记录
const newRecord = {
  startTime: '2025-01-01 10:00:00',
  endTime: '2025-01-01 12:00:00',
  fruitName: '苹果',
  weight: 100,
  customerName: '客户A',
  farmName: '农场A',
  status: '已完成',
  count: 50
};

fetch('http://localhost:8080/api/processing', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(newRecord)
})
.then(response => response.json())
.then(data => {
  if (data.ok) {
    console.log('添加成功!');
    // 刷新列表
  } else {
    console.error('添加失败:', data.message);
  }
});
```

### 8.3 自定义API处理器

```typescript
import { HttpResponseUtils } from '../helpers/HttpResponseUtils';

// 创建自定义API处理器
class CustomApiHandler {
  static async handleCustomApi(params: Record<string, string>): Promise<string> {
    try {
      // 实现自定义业务逻辑
      const result = { success: true, data: 'Custom API response' };
      return HttpResponseUtils.buildSuccessResponse(result);
    } catch (error) {
      return HttpResponseUtils.buildErrorResponse('自定义API错误', 500);
    }
  }
}
```

## 9. 注意事项

- 所有接口返回JSON格式数据
- 成功响应格式：`{"ok": true, "data": [...]}`
- 失败响应格式：`{"ok": false, "message": "错误信息"}`
- 支持RESTful风格和传统action参数两种调用方式
- 分页功能支持page和size参数，默认每页20条，最多100条
- POST/PUT请求支持JSON格式请求体
- 向后兼容旧版本API调用方式

## 10. 版本信息

- **版本号**：v1.0.0


本文档综合了HTTP服务器的架构设计、核心功能、API接口和使用方法，可作为开发和使用该服务器的完整参考指南。