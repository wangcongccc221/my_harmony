# 性能测试说明

## 测试目标
- 评估 ORM 在不同字段数量（10~300）下的 CRUD 与批量操作耗时
- 环境：HarmonyOS 模拟器 5.0.0.317，`EntryAbility` 启动后自动执行 `runPerformanceTest()`
- 日志输出标签：`A03d00/JSAPP`

## 运行方式
- 现阶段在 `EntryAbility` 初始化完成后自动调用 `runPerformanceTest()`（会占用主线程，可能导致 SetUIContent 超时，建议后续改为调试入口或手动触发）
- 日志中会按字段档位打印：
  - 单条插入、查询、更新、删除耗时
  - 批量插入 10 条耗时（与平均值）
  - 批量查询耗时
  - 汇总表

## 模型列表
| 字段数 | 表名                      |
| ------ | ------------------------- |
| 10     | `test_model_10_fields`    |
| 20     | `test_model_20_fields`    |
| 30     | `test_model_30_fields`    |
| 50     | `test_model_50_fields`    |
| 100    | `test_model_100_fields`   |
| 150    | `test_model_150_fields`   |
| 200    | `test_model_200_fields`   |
| 250    | `test_model_250_fields`   |
| 300    | `test_model_300_fields`   |

## 结果摘要（示例：2025-11-17 模拟器日志）
| 字段数 | 插入(ms) | 查询(ms) | 更新(ms) | 删除(ms) | 批量插入(ms) | 批量查询(ms) |
| ------ | -------- | -------- | -------- | -------- | ------------ | ------------ |
| 10     | 5        | 2        | 19       | 8        | 53           | 4            |
| 20     | 4        | 1        | 3        | 4        | 36           | 7            |
| 30     | 5        | 14       | 5        | 4        | 39           | 7            |
| 50     | 4        | 3        | 3        | 3        | 33           | 16           |
| 100    | 5        | 9        | 5        | 3        | 35           | 57           |
| 150    | 6        | 26       | 7        | 3        | 36           | 118          |
| 200    | 4        | 22       | 5        | 4        | 42           | 241          |
| 250    | 4        | 30       | 4        | 9        | 38           | 413          |
| 300    | 5        | 47       | 5        | 5        | 41           | 497          |

## 观察与建议
- 单条 CRUD 与批量插入 10 条的耗时在 3~8ms，增长不明显
- 批量查询随字段数呈线性~指数增长，300 字段约 500ms，是主要瓶颈
- 建议：
  1. 将 `runPerformanceTest()` 改为手动触发或后台任务，避免阻塞 UI
  2. 评估批量查询的列选择与分页策略（如只查询必要字段或使用 `LIMIT/OFFSET`）
  3. 如果需要线上监控，可将结果写入日志文件或上报分析

# my_harmony_master 项目总览

## 目录结构
- `entry/`：主应用（UIAbility、页面、网络服务、数据库等）
  - `entryability/EntryAbility.ets`：应用生命周期与启动流程
  - `pages/`：业务页面（历史加工、实时大屏等）
  - `utils/`：网络、文件、生命周期等工具
  - `database/`：业务模型、管理器与类型；`database/orm/` 内置 ORM 核心源码
- `build-profile.json5`：构建配置（仅保留 entry 模块）

## 核心功能
- **数据库持久化**：内嵌 ORM 支持自动迁移、CRUD、关系映射，`DatabaseManager` 负责建表及数据恢复。
- **网络服务**：HTTP/TCP 服务为外部系统提供加工数据查询与导出。
- **历史可视化**：历史页面支持筛选、统计、导出。
- **启动流程**：`EntryAbility` 分阶段初始化资源、网络、数据库并恢复种子数据。
- **UI 主题**：集成 Omni UI 与自研组件，满足大屏展示需求。

## 环境要求
- DevEco Studio 5.0+ / HarmonyOS SDK 5.1.1
- hvigor 构建链与 ohpm
- PowerShell 7 或兼容终端

## 初始化与运行
1. 执行 `ohpm install`
2. DevEco Studio 导入项目，选择 5.1.1 SDK
3. 直接运行 `entry` 模块到模拟器或真机
4. 首次启动会复制资源、初始化网络/数据库、恢复历史数据；页面加载后可在历史模块查看与导出。

## 数据库说明
- ORM 源码位于 `entry/src/main/ets/database/orm`（含 `core`、`decorator`、`model`、`utils` 等）
- 业务实体在 `entry/src/main/ets/database/models`，通过 `../orm` 导出的装饰器与 `Model` 基类定义
- `entry/src/main/ets/database/index.ets` 统一导出 ORM API 与业务对象，业务层仅需 `import { IBestORMInit, DatabaseManager } from '../database';`

## 常见命令
- 构建调试：`hvigor assembleDebug`
- 清理：`hvigor clean`

## 注意事项
- 性能测试示例已拆除，如需恢复请在独立分支引入
- HTTP/TCP 端口定义在 `utils/network`，部署到真机需确认权限
- ORM 已完全内嵌，不再依赖外部 `library` 模块，如需复用可直接从 `database/orm` 拷贝

## 网络与服务
- **HTTP 服务**  
  - 启停：`utils/network/http/HttpServer.ts` 暴露 `startHttpServer/stopHttpServer/isHttpServerRunning`。  
  - 路由：`HttpServerHandler` 统一分发到 `handlers` 子目录。  
  - 主要接口：  
    | 接口 | 说明 | 对应文件 | 关键逻辑 |
    | ---- | ---- | ---- | ---- |
    | `GET /api/processing` | 分页查询加工记录 | `ProcessingApiHandler` | 支持时间、客户、农场、状态筛选 |
    | `POST /api/processing/export` | 导出选中加工记录 | 同上 | 写入 rawfile，再返回路径 |
    | `GET /api/files` | 浏览导出的 HTML/CSV | `FileBrowserHandler` | 基于沙箱路径读取 |
- **TCP 服务**  
  - 文件：`utils/network/tcp/TCPServer.ets`  
  - 功能：维持与硬件端的长连接，实时接收加工线状态、心跳、告警；`NetworkOptimizer` 会根据配置调整收发缓冲与重连策略。  
  - 数据分发：收到消息后写入 `GlobalCardDataManager` 等全局状态，触发 UI 刷新。
- **处理流程**  
  - `EntryAbility.onCreate`：顺序执行资源拷贝 → 网络优化器初始化 → HTTP/TCP 服务启动。  
  - `EntryAbility.onDestroy/onStop`：调用 `AppCleanup` 与 `stopHttpServer`，确保端口与资源释放。

## UI 与组件
- **页面结构**  
  | 目录 | 说明 | 关键文件 |
  | ---- | ---- | ---- |
  | `pages/Home` | 汇总仪表盘、实时曲线、告警面板 | `Home.ets`, `components/layout/*` |
  | `pages/history` | 历史加工列表、筛选、导出 | `HistoryContent.ets`, `HistoryDataTable.ets`, `core/HistoryTableManager.ets` |
  | `components/feedback` | 弹框、Toast、导出对话框 | `FruitInfoDialog.ets` 等 |
- **主题与状态**  
  - `OmniThemeManager` + `@StorageLink` 共享主题状态，组件使用 `@Provide/@Consume` 传递主题对象。  
  - 常量存于 `utils/constants/theme.ts`（如 `OMNI_THEME_KEY`、`TOP_STATUS_TEXT`）。
- **典型组件**  
  - `TopStatusBar`：顶部统计条，展示产量、告警、连接状态。  
  - `CompactFsmToggle`：双通道切换器，通过动画指示当前生产线。  
  - `HistoryDataTable`：封装 ArkUI 表格，可分页、勾选导出。  
  - `FruitInfoDialog`：显示单果详细指标，支持滑动切换。  
- **数据喂料**  
  - `ProcessingCurveFeed`、`ProcessingBarFeed` 等模拟实时数据，供大屏 demo 使用。  
  - 可接入 TCP 实时数据替换这些 feed。

## 其他模块
- **数据恢复**  
  - `database/DataRestore.ets` 提供 `restoreProcessingHistoryData`，检测表为空时批量插入示例数据。  
  - 数据来源：`entry/src/main/resources/rawfile/file/*.html`/JSON，可自定义。
- **文件操作**  
  - `utils/FileUtils.ts`：递归复制 rawfile 至 `context.filesDir`，并包含基础的路径校验。  
  - 导出报表时会使用 `fs` 写入 `files/export/...`。
- **网络优化**  
  - `utils/network/NetworkOptimizer.ets`：单例管理 socket 超时、缓冲区、连接监控。  
  - 提供 `getInstance()`、`startMonitoring()` 等方法，供 Ability 与 server 调用。

