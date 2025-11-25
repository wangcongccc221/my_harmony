## TaskPool 数据库调度与实体映射说明

### 1. DispatchQueue + TaskPool 核心链路
- **入口**：UI / Ability / HTTP 层统一调用 `DatabaseQueueManager`（`entry/src/main/ets/utils/network/database/index` 导出）。
- **队列管理**：`DatabaseQueueManager` 根据操作类型选择串行（写）或并发（读）`DatabaseDispatchQueue`，为 `DatabaseTask` 设置 `Context` 后入队。
- **调度执行**：`DatabaseDispatchQueue.runTask()` 内部通过 `taskpool.Task` 调用 `ProcessingApiHandler` 中对应的 `@Concurrent` 方法（`PH_QueryAll`、`PH_Insert` 等）。所有真正的 SQLite/ORM 操作都在 TaskPool 线程执行，避免阻塞 UI。
- **结果回传**：TaskPool 执行完成后返回 `DatabaseTaskResult`，`DatabaseQueueManager` promise resolve，业务侧（如 `HistoryTableManager`）即可获取数据或状态。
- **扩展步骤**：新增操作时按“`ProcessingApiHandler` 新建 @Concurrent 方法 → `DatabaseDispatchQueue` 添加 `executeXXX` → `DatabaseQueueManager` 暴露静态方法 → 业务侧调用”的顺序实现即可。

### 2. ORM 实体自动映射与实体转换
- **ORM 实体**：在 `entry/src/main/ets/database/models/ProcessingHistory.ets` 声明实体类，ORM 根据类名或 `tableName` 属性自动定位 `processing_history` 表，不必手写字符串。
- **数据库行 → ORM 实体**：`ProcessingApiHandler` / ORM `Find()` 结果直接是 `ProcessingHistoryData`，字段名与表列一一对应。
- **实体 → UI 模型**：`HistoryTableManager.mapRecord()` 负责把 `ProcessingHistoryData` 转成 UI 使用的 `HistoryTableData`（“直接实体”），其它层都通过该对象交互。
- **意义**：实现主管要求的“放行一个实体 ↔ 直接实体”，即数据库行转实体类、实体间互转全部在统一位置完成，便于维护也便于后续新增模型。

### 3. 现状与交付要点
- 历史模块所有增删改查均走 TaskPool；写操作串行、读操作并发，配合 SQLite WAL 模式，1.7 万行全量查询保持 600–700 ms。
- 重置按钮和 HTTP 接口都直接复用 `HistoryTableManager.loadAllData()` + `DatabaseQueueManager.queryAll()`，并带 10 s 缓存与耗时日志。
- 未来如需为其他模块启用相同架构，可参考上述两个流程复刻：定义实体 → 写映射函数 → 挂载到 Dispatch/TaskPool 管道。


