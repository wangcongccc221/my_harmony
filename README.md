# 性能测试说明
##### **概念澄清**
- 吞吐（Throughput）：单位时间内系统成功处理的请求数，常用 QPS/TPS。例：1 秒内完成的 HTTP 请求数量。反映“总体处理能力”和并发下的产能。
- 延迟（Latency）：单个请求从到达到发送响应的耗时，通常用平均、P95、P99。反映“单次响应速度”。

端到端分解
- 网络接收与解析
  - 接收套接字数据、把 `ArrayBuffer` 转成字符串、拆 HTTP 首行与头部。
  - 位置：`utils/network/http/HttpServer.ets:38-45`（消息回调）和 `utils/network/http/HttpServerHandler.ets:65-88`（解析请求行和路径）。
- 路由与参数处理
  - 根据路径选择 API、解析查询参数与请求体。
  - 位置：`utils/network/http/HttpServerHandler.ets:90-139`（路由到 `/api/processing`）、`handlers/ProcessingApiHandler.ets:356-373`（解析参数）。
- 任务池调度（你已启用）
  - 将 CRUD 交给 TaskPool 并发函数，避免阻塞路由线程和 UI。
  - 位置：查询 `PH_QueryAll` 在 `handlers/ProcessingApiHandler.ets:75`；插入 `PH_Insert` 在 `handlers/ProcessingApiHandler.ets:82`；更新 `PH_Update` 在 `handlers/ProcessingApiHandler.ets:96`；删除 `PH_Delete` 在 `handlers/ProcessingApiHandler.ets:89`。
- 数据库操作实际耗时
  - ORM 初始化（幂等）与迁移、具体读写（`Insert`、`Find`、`Update`、`Delete`）。
  - 位置：在 TaskPool 函数内调用 `IBestORMInit` 和 `AutoMigrate`，随后进行 CRUD；如 `handlers/ProcessingApiHandler.ets:70-73, 82-87`。
- 序列化与响应发送
  - 将查询结果转换为前端行结构、分页封装、生成 HTTP 响应文本并回写 socket。
  - 位置：行转换 `handlers/ProcessingApiHandler.ets:65-67`，分页响应 `handlers/ProcessingApiHandler.ets:132-166`，默认响应 `handlers/ResponseHandler.ets:75-90`。

“延迟”具体指哪些耗时
- 等待时间（队列/背压）：路由线程把任务交给 TaskPool 后可能排队，取决于并发配额和任务堆积。
- 解析与路由耗时：`HttpServerHandler` 中对字符串的处理与解码、分支选择。
- TaskPool 分发耗时：创建 `taskpool.Task` 与投递到 worker 的时间，通常很短但在高并发下不可忽略。
- ORM 初始化与迁移耗时：幂等操作，若未缓存会增加每次任务的固定开销；建议在每个 worker 中缓存初始化状态。
- 数据库 I/O 耗时：查询、插入、更新、删除的核心时间；这通常是延迟的主因。
- 序列化与生成响应耗时：将对象转为 JSON/HTML 并构造 HTTP 消息体。

“吞吐”具体看哪些指标
- 接口级 QPS/TPS：如 `/api/processing?action=insert` 每秒完成数。
- 数据库层 TPS：每秒成功的 `Insert`/`Update`/`Delete` 数；只读 QPS（`Find`）。
- 有效响应比率：成功响应占比、错误率。
- 并发占用：路由线程并发、TaskPool 活跃 worker 数。

你已有的观测点与工具
- 路由日志：`utils/network/http/HttpServerHandler.ets:50-58, 89-92, 121-139` 会打印请求预览、路由匹配和方法。
- 处理器日志：`handlers/ProcessingApiHandler.ets:366-373` 打印 action、方法；`handlers/ProcessingApiHandler.ets:180-236` 在插入前后打印记录数和插入 ID。
- 性能测试 API：`/api/performance` 路由在 `HttpServerHandler.ets:107-123`，处理器 `handlers/PerformanceApiHandler.ets` 提供启动、状态、结果接口，可用于压测与统计结果。

如何衡量并诊断
- 延迟分层采样
  - 在路由入口、TaskPool 投递前后、TaskPool 函数内数据库操作前后、响应返回前分别打点，记录时间戳。
  - 计算各阶段耗时分布，定位瓶颈（通常是数据库 I/O 或序列化大响应）。
- 吞吐采样
  - 统计单位时间内各接口完成次数（QPS/TPS），并记录错误率。
  - 在高并发压测下观察随并发上升时的“QPS饱和点”和“延迟曲线”，评估是否需要队列/背压。

优化的优先级建议
- 优先优化数据库 I/O（对延迟影响最大）：事务批量写入、必要时索引优化、减少重复迁移/初始化成本（在每个 worker 缓存 ORM 初始化）。
- 保持“监听轻量、重活下沉到 TaskPool”：对吞吐更有效，监听本身下沉收益有限。
- 加入并发控制与背压：设置 TaskPool 并发上限与队列长度，避免 1000 并发把 worker 拖慢整体响应。

一句话总结
- 吞吐是“单位时间完成的请求数”，延迟是“单个请求从进来到出去的耗时”；它们涵盖网络接收、路由解析、TaskPool 分发、数据库读写和响应生成各个阶段，不只是查询耗时。当前架构中最关键的延迟影响点是数据库 CRUD 的 I/O 时间，其次是任务池分发与序列化，监听本身不是主要瓶颈。
