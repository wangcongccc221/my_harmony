# 代码审查指南

本文档列出向主管展示代码时应该重点关注的**核心文件和模块**，按重要性和审查顺序排列。

---

## 📋 审查顺序建议

### 第一优先级：架构核心（必须展示）

#### 1. 应用入口与初始化
- **`entry/src/main/ets/entryability/EntryAbility.ets`**
  - 作用：应用生命周期管理、ORM 初始化、HTTP 服务器启动
  - 亮点：`onCreate` 中初始化数据库和网络服务，`onWindowStageCreate` 中执行 `AutoMigrate` 和索引创建

#### 2. 数据库调度架构（核心亮点）
- **`entry/src/main/ets/utils/network/database/dispatch/DatabaseQueueManager.ets`**
  - 作用：统一数据库操作入口，区分读写队列（读并发、写串行）
  - 亮点：封装了 `queryAll`、`insert`、`update`、`delete` 等接口，自动选择队列类型

- **`entry/src/main/ets/utils/network/database/dispatch/DatabaseDispatchQueue.ets`**
  - 作用：DispatchQueue + TaskPool 调度实现
  - 亮点：`runTask()` 通过 `taskpool.Task` 调用 `@Concurrent` 方法，确保数据库操作不阻塞 UI

- **`entry/src/main/ets/utils/network/http/handlers/ProcessingApiHandler.ets`**
  - 作用：所有数据库操作的 `@Concurrent` 实现（`PH_QueryAll`、`PH_Insert` 等）
  - 亮点：真正的 SQLite/ORM 操作都在 TaskPool 线程执行，启用 WAL、列裁剪优化

#### 3. HTTP 服务器实现
- **`entry/src/main/ets/utils/network/http/HttpServer.ets`**
  - 作用：基于 TCPSocket 的 HTTP 服务器，监听端口、处理连接
  - 亮点：支持普通模式和 `runHttpServerWorker()` TaskPool 常驻模式

- **`entry/src/main/ets/utils/network/http/HttpServerHandler.ets`**
  - 作用：HTTP 请求路由映射（Map + 前缀匹配）、业务 handler
  - 亮点：使用 `Map` 和数组替代 `if-else`，支持路由扩展

- **`entry/src/main/ets/utils/network/http/dispatch/HttpRequestQueueManager.ets`**
  - 作用：HTTP 请求的 Dispatch 并发队列管理
  - 亮点：支持背压控制（503 响应），错误统一处理

#### 4. TCP 服务器/客户端
- **`entry/src/main/ets/utils/network/tcp/TCPServer.ets`**
  - 作用：TCP 服务器封装，管理客户端连接、消息分发
  - 亮点：支持 `runTcpServerWorker()` TaskPool 常驻，AppStorage 同步连接状态

- **`entry/src/main/ets/utils/network/tcp/TcpClient.ets`**
  - 作用：TCP 客户端封装，自动重连机制
  - 亮点：指数退避重连策略，消息队列统一处理

#### 5. ORM 实体与映射
- **`entry/src/main/ets/database/models/ProcessingHistory.ets`**
  - 作用：ORM 实体定义，自动映射到 `processing_history` 表
  - 亮点：类名自动匹配表名，支持 `createIndexes()` 性能优化

- **`entry/src/main/ets/pages/history/core/HistoryTableManager.ets`**
  - 作用：业务层数据管理，实体转换（`ProcessingHistoryData` → `HistoryTableData`）
  - 亮点：`mapRecord()` 实现“数据库行 → 实体类对象 → 直接实体（模型）”的完整链路

---

### 第二优先级：业务实现（按需展示）

#### 6. 历史数据页面
- **`entry/src/main/ets/pages/history/HistoryContent.ets`**
  - 作用：历史数据页面主逻辑，重置按钮、导出、过滤
  - 亮点：调用 `HistoryTableManager.loadAllData()` 实现全量数据加载，带耗时日志

- **`entry/src/main/ets/pages/history/HistoryDataTable.ets`**
  - 作用：历史数据表格 UI 组件，支持滚动加载更多
  - 亮点：使用“哨兵行”（sentinel `ListItem`）触发 `onAppear` 实现无限滚动

#### 7. UI 布局适配
- **`entry/src/main/ets/pages/home/HomeConstants.ets`**
  - 作用：首页常量配置，卡片尺寸、间距等
  - 亮点：使用百分比替代固定 `px`，适配不同分辨率

- **`entry/src/main/ets/components/cards/ThreeLayerCard.ets`**
  - 作用：三层卡片组件
  - 亮点：响应式布局，百分比尺寸

---

### 第三优先级：工具与辅助（简要提及）

#### 8. 工具类
- **`entry/src/main/ets/utils/FileUtils.ets`**：文件操作工具
- **`entry/src/main/ets/utils/helpers/HttpResponseUtils.ets`**：HTTP 响应格式化
- **`entry/src/main/ets/utils/network/NetworkOptimizer.ets`**：网络优化器

#### 9. 数据库 ORM 核心
- **`entry/src/main/ets/database/orm/core/SQLiteORM.ets`**：ORM 核心实现
- **`entry/src/main/ets/database/orm/core/RelationQueryExtension.ts`**：关联查询扩展

---

## 🎯 技术亮点总结（向主管说明）

### 1. **TaskPool + DispatchQueue 架构**
- 所有数据库操作通过 TaskPool 异步执行，不阻塞 UI
- 读操作并发、写操作串行，保证数据一致性
- 1.7 万条数据全量查询耗时 600–700 ms

### 2. **HTTP 服务器自研实现**
- 基于 TCPSocket 原生实现，不依赖第三方库
- 支持路由映射、请求队列、背压控制
- 可运行在 TaskPool 中，不影响主线程

### 3. **ORM 实体自动映射**
- 实体类自动匹配表名，无需手写字符串
- 统一的实体转换机制（`mapRecord()`），实现“数据库行 → 实体类 → UI 模型”

### 4. **响应式 UI 布局**
- 使用百分比替代固定 `px`，适配多种分辨率（2160×1440、1920×1080、2K 等）

### 5. **TCP 长连接与自动重连**
- 服务器支持多客户端连接，消息队列统一处理
- 客户端自动重连，指数退避策略

---

## 📁 文件路径速查表

| 模块 | 核心文件路径 |
| --- | --- |
| **应用入口** | `entry/src/main/ets/entryability/EntryAbility.ets` |
| **数据库调度** | `entry/src/main/ets/utils/network/database/dispatch/DatabaseQueueManager.ets`<br>`entry/src/main/ets/utils/network/database/dispatch/DatabaseDispatchQueue.ets` |
| **数据库操作** | `entry/src/main/ets/utils/network/http/handlers/ProcessingApiHandler.ets` |
| **HTTP 服务器** | `entry/src/main/ets/utils/network/http/HttpServer.ets`<br>`entry/src/main/ets/utils/network/http/HttpServerHandler.ets` |
| **TCP 服务** | `entry/src/main/ets/utils/network/tcp/TCPServer.ets`<br>`entry/src/main/ets/utils/network/tcp/TcpClient.ets` |
| **ORM 实体** | `entry/src/main/ets/database/models/ProcessingHistory.ets` |
| **实体转换** | `entry/src/main/ets/pages/history/core/HistoryTableManager.ets` |
| **业务页面** | `entry/src/main/ets/pages/history/HistoryContent.ets`<br>`entry/src/main/ets/pages/history/HistoryDataTable.ets` |

---

## 💡 审查建议

1. **先看架构文档**：让主管先阅读 `docs/README_Infrastructure.md` 了解整体架构
2. **按顺序展示代码**：从 `EntryAbility.ets` 开始，依次展示数据库调度、HTTP 服务器、TCP 服务
3. **重点强调性能**：1.7 万条数据查询 600–700 ms、TaskPool 不阻塞 UI、WAL 模式优化
4. **展示扩展性**：说明如何新增数据库操作、HTTP 路由、TCP 消息类型
5. **代码质量**：路由使用 Map 替代 if-else、统一的错误处理、类型安全

---

## 📚 相关文档

- **架构总览**：`docs/README_Infrastructure.md`
- **TaskPool 与实体映射**：`docs/README_TaskPool_Entity.md`
- **性能测试**：`scripts/README_PERFORMANCE_TEST.md`（如有）

