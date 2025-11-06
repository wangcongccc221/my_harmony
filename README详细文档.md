# My_Project（HarmonyOS/OpenHarmony）

应用包含首页卡片（波浪动画等）、历史数据、质量/等级模块，并内置简易 HTTP/TCP 服务用于本地联调与压测。

## 1. 基本信息
- 包名：`com.nutpi.My_Project`
- 入口能力：`EntryAbility`
- 构建工具：DevEco Studio（hvigor）
- 当前版本：1.0.0（Code: 1000000）

## 2. 目录与关键文件
- `AppScope/app.json5`：应用级配置
- `entry/module.json5`：模块与能力配置（含 `EntryBackupAbility`）
- `entry/src/main/ets/`
  - 首页与卡片：`pages/home/HomeContent.ets`、`pages/Home.ets`、`pages/home/LiquidCardsArea.ets`
  - 三层卡片：`components/ThreeLayerCard/*`、`components/cards/ThreeLayerCard.ets`
  - 历史页面：`pages/history/*`
  - 质量/等级：`pages/quality/*`、`pages/level/*`
  - 主题系统：`utils/theme/*`
  - 网络服务：`utils/network/(HttpServer|HttpServerHandler|TcpClient|TCPServer|NetworkOptimizer).ets`
  - 折线图工具：`utils/lineChart.ts`（被 `DataTablesTabBar.ets` 使用）

### 2.1 tree:文件目录：
C:.
|-- AppScope
|   \-- resources\base\(element|media)
|-- entry
|   |-- build\...
|   |-- src\main
|   |   |-- ets\(components|pages|utils|entryability|...)
|   |   \-- resources
|   |       |-- base\(element|media|profile)
|   |       \-- rawfile\file\(1|2|3)
|   \-- outputs\...
|-- oh_modules\...
|-- playwright-tests
|   |-- tests\(smoke.spec.ts|database-stability.spec.ts)
|   |-- k6-load-test.js
|   |-- k6-load-test-extreme.js
|   |-- playwright.config.ts
|   \-- (package.json|README.md|report|test-results)
|-- README使用文档.md
|-- README详细文档.md
|-- 测试总结文档.md

### 2.2 重要文件说明（用途概览）
- `entry/src/main/ets/entryability/EntryAbility.ets`：应用入口 Ability，初始化 HTTP 服务、资源清理（调用 `AppCleanup`），生命周期日志。
- `entry/src/main/ets/components/layout/TopStatusBar.ets`：顶部状态栏（指标、时间、客户信息、最小化/关闭按钮）。
- `entry/src/main/ets/pages/history/HistoryContent.ets`：历史页主容器，处理查询、重置、表格刷新、输入清空等逻辑。
- `entry/src/main/ets/pages/history/HistoryDataTable.ets`：历史表格渲染，支持传入 `filteredData`，使用稳定 key(`id`)。
- `entry/src/main/ets/pages/history/core/HistoryTableManager.ets`：历史数据管理与筛选（精确匹配与严格日期区间；`productType`→`fruitName` 映射）。
- `entry/src/main/ets/pages/history/CustomerQueryCard.ets`：客户/农场/水果输入组件，`TextInput` 正确双向绑定（`text` 参数）。
- `entry/src/main/ets/utils/network/HttpServer.ets`：HTTP 服务器管理（启动/停止、端口），统一 `TextEncoder.encode`。
- `entry/src/main/ets/utils/network/HttpServerHandler.ets`：接口路由处理（`listJson`/`insert` 等），响应编码统一。
- `entry/src/main/ets/utils/network/TcpClientManager.ets`：TCP 客户端管理，提供批量清理，修复 ArkTS 解构报错。
- `entry/src/main/ets/utils/AppCleanup.ets`：统一清理（HTTP/TCP/优化器及注册回调），`EntryAbility.onStop()` 调用。
- `entry/src/main/ets/utils/lineChart.ts`：折线图工具函数（被数据表页引用）。
- `entry/src/main/resources/rawfile/file/processing.html`：历史联调静态页（如用到）。
- `entry/src/main/resources/rawfile/file/1/1.html`：演示页，已改为实时显示当前时间。

- `playwright-tests/playwright.config.ts`：Playwright 配置，`baseURL` 默认 `http://127.0.0.1:8080`，可被 `BASE_URL` 覆盖。
- `playwright-tests/tests/smoke.spec.ts`：接口冒烟测试（读列表/插入轮询校验，兼容 `{ok,data}` 返回）。
- `playwright-tests/tests/database-stability.spec.ts`：长稳测试（约15分钟，每3秒插入一条，统计成功率）。
- `playwright-tests/k6-load-test.js`：15 分钟 K6 压测脚本（1m 预热/13m 稳态/1m 降载，70% 查询/30% 插入）。
- `playwright-tests/k6-load-test-extreme.js`：更激进的压测脚本（并发/时长更高）。
- `playwright-tests/README.md`：测试子项目使用说明。

## 3. 环境要求
- DevEco Studio（含 hvigor、hdc）
- 模拟器或真机已连接（`hdc list targets`）

## 4. 构建与打包

### 4.1 DevEco Studio（推荐）
1) 打开项目 → 如需发布包，先在 Project Structure > Signing Configs 配置 release 签名/Profile。
2) 菜单 Build > Generate App Package(s)。
3) 产物：
   - HAP：`entry/build/default/outputs/default/entry-default-signed.hap`

## 5. 端口映射（如需在主机访问设备内 HTTP 服务）
应用内置 HTTP 服务默认 8080 端口：
```bat
hdc fport tcp:8080 tcp:8080       # 添加映射（将设备 8080 端口映射到本机 8080）
hdc fport ls                      # 查看映射
hdc fport rm tcp:8080             # 删除映射
```
接口示例：
- 查询：`GET http://127.0.0.1:8080/api/processing?action=listJson`
- 插入：`GET http://127.0.0.1:8080/api/processing?action=insert&startTime=...&endTime=...&customerName=...&farmName=...&fruitName=...`

### 6.1 HTTP 接口参数表

1) 查询加工记录

- URL：`GET /api/processing?action=listJson`
- 描述：返回当前数据库中的加工记录列表（JSON 数组）。
- 请求参数：
  - `action`：必填，固定为 `listJson`
- 响应示例：
```json
[
  {
    "id": 1,
    "customerName": "客户A",
    "farmName": "农场1",
    "fruitName": "苹果",      
    "startTime": "2024-11-01 08:30",
    "endTime": "2024-11-01 12:45",
    "weight": 12.5,
    "count": 320,
    "status": "已完成"
  }
]
```
- 字段说明：
  - `fruitName`：展示/筛选使用该字段，内部与 `productType` 对齐
  - `status`：`已完成` | `进行中` | `待开始`

2) 插入加工记录（简易联调用）

- URL：`GET /api/processing?action=insert`
- 描述：向数据库插入一条测试记录，用于压测/快速验证。
- 请求参数（QueryString）：
  - `action`：必填，固定为 `insert`
  - `startTime`：必填，开始时间，如 `2024-11-01 08:30`
  - `endTime`：可选，结束时间，如 `2024-11-01 12:45`（不填代表进行中）
  - `customerName`：可选，客户名称
  - `farmName`：可选，农场名称
  - `fruitName`：可选，水果品种（与 `productType` 同步）
  - `weight`：可选，批重量(吨)，数值
  - `count`：可选，批个数，整数
- 响应：
  - 成功：`{"success": true}`
  - 失败：`{"success": false, "message": "错误信息"}`
- 示例：
```
GET http://127.0.0.1:8080/api/processing?action=insert&startTime=2024-11-01%2008:30&endTime=2024-11-01%2012:45&customerName=客户A&farmName=农场1&fruitName=苹果&weight=12.5&count=320
```

### 6.2 接口定位与限制
- 仅用于本地联调/演示：无鉴权、无分页、数据直接读写应用内本地库，不对公网暴露
- 访问方式：设备运行应用 → `hdc fport tcp:8080 tcp:8080` → 通过 `http://127.0.0.1:8080` 访问
- 生产建议：切换为后端服务（鉴权/分页/审计），前端仅调用受控 API

### 6.3 常见问题
- 访问超时：检查应用是否已运行、端口映射是否建立（`hdc fport ls`）
- 端口被占用：改用其他端口并同步更新 `HttpServer` 监听端口与映射
- 数据不更新：确认未被旧缓存覆盖；如为前端表格，请确保使用稳定 key（已使用 `id`）

## 7. 功能验证清单
- 首页
  - 波浪动画流畅显示
  - 顶部状态与卡片数据随时间刷新
- 历史页面
  - 输入客户/农场/水果筛选
  - 导出 CSV/Excel（以 CSV 内容写入 .xlsx）
- 网络服务
  - `listJson` 返回 JSON
  - `insert` 写入后可在 `listJson` 中看到

## 8. 压力测试
- 脚本：`playwright-tests/k6-load-test-extreme.js`
- 默认配置：5 分钟、最大并发 10、70% 查询 / 30% 插入、每次迭代 `sleep(1)`
- 运行：
```bash
k6 run playwright-tests/k6-load-test-extreme.js
```
提示：当数据库有数千条记录时，全表返回会明显增大负载。建议生产环境改为分页接口（如 `page/size`）。

## 9. 已知事项
- 第三方库（`oh_modules`）会输出一些 deprecated 警告，不影响核心功能。
- EntryAbility 中个别 API（如 `setFullScreen`）亦有 deprecated 提示，后续统一适配即可。
- 文件写入：统一用 `TextEncoder.encode(string)` → `Uint8Array` → `fs.writeSync(fd, u8)`，避免运行期编码错误日志。

## 10. 可选优化（数据量增大后建议）
- 历史接口分页化：`listJson?page=&size=`（后端分页 + 前端分页 UI）
- 数据库索引：常用字段如 `customerName`、`farmName`、`startTime`
- 限流与缓存：高并发下保护 UI 主线程


