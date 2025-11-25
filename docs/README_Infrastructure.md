## 平台基础能力总览

本文件整理当前项目中「数据库调度」「HTTP 服务器」「TCP 服务器 / 客户端」以及「ORM 实体自动映射与实体转换」的实现方式，方便交付与复查。下表概览三类后端服务的关键特征：

| 模块 | 主要职责 | 核心文件 | 线程模型 / 队列 | 备注 |
| --- | --- | --- | --- | --- |
| 数据库 | ORM 查询、写入、批操作 | `DatabaseDispatchQueue.ets`<br>`DatabaseQueueManager.ets`<br>`ProcessingApiHandler.ets`<br>`HistoryTableManager.ets` | 读：并发 DispatchQueue + TaskPool；写：串行 DispatchQueue + TaskPool | 启用 WAL、列裁剪，`mapRecord()` 负责实体转换 |
| HTTP 服务 | 监听 TCP，解析 HTTP，请求路由 | `HttpServer.ets`<br>`HttpServerHandler.ets`<br>`HttpRequestQueueManager.ets` | TCPSocket + Dispatch 并发队列，支持 TaskPool worker | 路由 Map/前缀匹配，支持 503 背压 |
| TCP 服务/客户端 | 长连接收发、消息解析、状态同步 | `TCPServer.ets`<br>`TcpClient.ets`<br>`TcpMessageQueueManager.ets` | Server/Client socket → Dispatch 并发消息队列；支持 worker/自动重连 | AppStorage 同步连接状态，消息结果回调 |

---

### 1. 数据库：DispatchQueue + TaskPool + ORM
- **核心文件**  
  - `entry/src/main/ets/utils/network/database/dispatch/DatabaseDispatchQueue.ets`  
  - `entry/src/main/ets/utils/network/database/dispatch/DatabaseQueueManager.ets`  
  - `entry/src/main/ets/utils/network/http/handlers/ProcessingApiHandler.ets`（@Concurrent DB 方法）  
  - `entry/src/main/ets/pages/history/core/HistoryTableManager.ets`（业务入口）  
  - `entry/src/main/ets/database/models/*.ets`（ORM 模型）
- **执行链路**  
  1. UI / Ability / HTTP 调用 `DatabaseQueueManager` 的 `queryAll / insert / update …`。  
  2. Manager 根据操作类型选择并发（读）或串行（写）`DatabaseDispatchQueue`，并为 `DatabaseTask` 绑定 `Context`。  
  3. `DatabaseDispatchQueue.runTask()` 内部通过 `taskpool.Task` 调用 `ProcessingApiHandler` 中的 `@Concurrent` 函数（`PH_QueryAll` 等）。  
  4. @Concurrent 函数直接操作 ORM / SQLite（已启用 WAL、列裁剪、SQL 直查），结果通过队列回传到业务层。  
  5. 业务层（如 `HistoryTableManager`) 将 `ProcessingHistoryData` 转为 UI 模型并缓存，避免 UI 线程阻塞。
- **扩展步骤**：新增 DB 操作时按 “`ProcessingApiHandler` 写 @Concurrent 方法 → `DatabaseDispatchQueue` 增加 `executeXXX` → `DatabaseQueueManager` 暴露接口 → 业务层调用” 即可。串行/并发队列已经内置，保证写安全与读吞吐。

---

### 2. HTTP 服务器：纯 TCPSocket + Dispatch 请求队列
- **核心文件**  
  - `entry/src/main/ets/utils/network/http/HttpServer.ets`  
  - `entry/src/main/ets/utils/network/http/HttpServerHandler.ets`（路由映射 + 业务 handler）  
  - `entry/src/main/ets/utils/network/http/dispatch/HttpRequestQueueManager.ets` 与 `HttpRequestDispatchQueue.ets`
- **实现要点**  
  - 使用 `socket.constructTCPSocketServerInstance()` 监听 0.0.0.0:port，`on('connect')` 后逐字节缓存并解析 HTTP 报文。  
  - 将解析好的原始请求交给 `HttpRequestQueueManager.executeRequest()`，在 Dispatch 并发队列中分发到 `HttpServerHandler.createRouterHandler()`。  
  - `HttpServerHandler` 通过 `Map` / 前缀路由表定位具体处理函数，每个 handler 返回 `Promise<string | Uint8Array>`，统一写回客户端。  
  - 提供 `runHttpServerWorker()` @Concurrent 版本，可在 TaskPool 中常驻监听，确保 Ability 主线程轻量。  
  - 背压可通过 `HttpRequestQueueManager.isQueueAvailable()` + 503 响应控制，错误链路都集中在队列回调。

---

### 3. TCP 服务器 / 客户端：消息 Dispatch + 自动重连
- **核心文件**  
  - 服务器：`entry/src/main/ets/utils/network/tcp/TCPServer.ets`、`runTcpServerWorker()`、`TcpMessageQueueManager.ets`  
  - 客户端：`entry/src/main/ets/utils/network/tcp/TcpClient.ets`、`TcpMessageQueueManager.ets`
- **服务器实现**  
  - `TCPServer` 封装普通模式，内部维护 `clients` Map、消息/状态回调、AppStorage 同步 `TCP_CONNECTION_STATUS`。  
  - `runTcpServerWorker()` 为 @Concurrent 常驻版本：收到消息后使用 `TcpMessageQueueManager.executeMessage()` 在 Dispatch 并发队列解析文本，再交由业务 handler。  
  - 支持关停信号（`AppStorage` 标记）、错误监听、自动清理 client。  
  - `TcpMessageQueueManager` 与 HTTP 方案类似：为每条消息构建 `TcpMessageTask`，TaskPool/Dispatch 处理后回写或上报错误。
- **客户端实现**  
  - `TcpClient` 基于 `socket.constructTCPSocketInstance()`，封装 `connect / disconnect / sendMessage`，内置消息、状态、错误回调池。  
  - 自动重连：失败或 `close` 后通过 `scheduleReconnect()` 开始指数式尝试，支持配置次数和间隔。  
  - 收到消息同样交给 `TcpMessageQueueManager` 做统一解析，再回调至订阅者；发送前统一使用 `TextEncoder` 转二进制。  
  - 适合在独立 ability/service 中长期运行，也能直接注入 UI 组件监听连接状态（例如顶部状态栏的连接指示）。

---

### 4. ORM 实体自动映射与实体转换
- **自动映射（类名/属性名 → 表名/列名）**  
  - **定义**：通过 `@Table` 和 `@Field` 装饰器，自动将 TypeScript 的类名/属性名转换为数据库的表名/列名
  - **转换规则**：
    - 类名：`ProcessingHistory`（驼峰）→ `processing_history`（蛇形）
    - 属性名：`CustomerName`（驼峰）→ `customer_name`（蛇形）
    - 通过 `camelToSnakeCase` 函数实现驼峰到蛇形的转换
  - **使用方式**：在 `entry/src/main/ets/database/models` 定义实体类（如 `ProcessingHistory`），ORM 自动匹配表名，无需手写字符串
  - **初始化**：在 `EntryAbility` 中只需执行一次 `GetIBestORMInit`，TaskPool 线程随用随取
- **放行逻辑（链式调用）**  
  - **定义**：传表名给 `Table()` 方法，返回一个可以链式调用的对象，可继续调用 `.Find()`, `.Insert()`, `.Update()`, `.Delete()` 等方法
  - **实现**：`Table(表名)` 返回 `this`，支持链式调用
  - **使用方式**：
    ```typescript
    // 方式1：传表名字符串（放行逻辑）
    GetIBestORM().Table('processing_history').Find(ProcessingHistory)
    
    // 方式2：传实体类（自动映射表名）
    GetIBestORM().Session(ProcessingHistory).Find(ProcessingHistory)
    ```
- **实体转换**  
  - ORM 查询返回 `ProcessingHistoryData`（数据库实体），`HistoryTableManager.mapRecord()` 会转换成 UI 使用的 `HistoryTableData`（“直接实体”）。  
  - 此流程就是主管所说“数据库行 → 实体类对象 → 直接实体（模型）”的落地方案，无需额外 DTO。  
  - 若新增模块，需要：定义 ORM 实体 → 在业务 Manager 中提供 `mapRecord` 或类似函数 → 其他层统一消费，保持类型安全。

---

### 5. 交付摘要 / 可复用建议
- TaskPool + Dispatch 已覆盖 DB 查询写入、HTTP 请求、TCP 消息三个通道；写操作默认串行、读操作并发，结合 WAL 模式支撑 1.7 万行全量查询 ~0.6–0.7 s。  
- HTTP/TCP 均以 socket 原语实现，可根据需要在 Ability 中直接 `run*Worker()` 常驻，或复用封装好的 `start/stop` API。  
- 若未来新增其它数据域或网络协议，沿用“Dispatch 管调度 + TaskPool 并发执行 + 实体映射统一在 Manager”这一范式即可快速接入。

