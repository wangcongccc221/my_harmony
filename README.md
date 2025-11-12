## 一文读懂本项目（HarmonyOS/OpenHarmony）

### TL;DR（90 秒超短速读）
- 构建安装：在 DevEco Studio 生成 HAP → 安装运行
- 启动后端：应用内置 HTTP(8080)/TCP(8081) 服务，设备访问用 `hdc fport tcp:8080 tcp:8080`
- 数据库用法：`DatabaseManager.getInstance()` → `initDatabase()` 一次 → 直接 `add*/get*/delete*`
- 一致性：多步操作用 `executeInTransaction(async () => { ... })`，成功自动提交、异常自动回滚
- 常用排错：访问超时看 `hdc fport ls`；TCP 改 `0.0.0.0` 监听；事务失败看日志/异常

### 最常用三段代码（可直接粘贴）
```ts
// 1) 启动初始化（App 启动时一次）
const db = DatabaseManager.getInstance();
await db.initDatabase();

// 2) 新增 + 查询（页面里随用随调）
db.addUser({ name: '张三', age: 25 });
const list = db.getAllUsers(); // UserData[]

// 3) 事务（两步要么都成功，要么都回滚）
const ok = await db.executeInTransaction(async () => {
  db.addUser({ name: '李四', age: 20 });
  db.addProcessingHistory({
    customerName: '客户A', farmName: '农场1', fruitName: '苹果',
    status: '进行中', startTime: '2025-11-11 10:00:00', endTime: '',
    weight: 12.5, quantity: 100
  });
});
```

本页汇总最有用的操作与信息，5–10 分钟快速上手。原始详细文档已整合进本页。

### 1. 项目概览
- 包名：`com.nutpi.My_Project`
- 入口能力：`EntryAbility`
- 构建工具：DevEco Studio（hvigor）
- 功能：首页看板（卡片/波浪）、历史数据、质量/等级模块、内置 HTTP/TCP 联调与压测工具

---

### 2. 目录与关键代码入口
- 应用配置：`AppScope/app.json5`、`entry/module.json5`
- UI/页面：`entry/src/main/ets/pages/*`、`entry/src/main/ets/components/*`
- 数据库封装：`entry/src/main/ets/database/`
  - 入口：`DatabaseManager.ets`（单例，AutoMigrate、CRUD、事务）
  - 类型：`types.ets`
  - 示例：`examples/TransactionExample.ets`
- 网络：
  - HTTP：`entry/src/main/ets/utils/network/HttpServer.ets`、`HttpServerHandler.ets`
  - TCP：`entry/src/main/ets/utils/network/TCPServer.ets`、`TcpClientManager.ets`

---

### 3. 构建与安装（最短路径）
1) DevEco Studio 打开工程
2) 生成 HAP：Build > Generate App Package(s)
3) 安装运行（命令行示例）：
```bash
hdc install entry/build/default/outputs/default/entry-default-signed.hap
hdc shell aa start -a com.nutpi.My_Project.EntryAbility -b com.nutpi.My_Project
```

---

### 4. 内置 HTTP 接口（本地联调）
- 默认端口：8080
- 端口映射到本机（如需从电脑访问设备服务）：
```bash
hdc fport tcp:8080 tcp:8080
```
- 接口示例：
  - 查询：GET `http://127.0.0.1:8080/api/processing?action=listJson`
  - 插入：GET `http://127.0.0.1:8080/api/processing?action=insert&startTime=...&endTime=...&customerName=...&farmName=...&fruitName=...&weight=...&count=...`
- 用途：快速验证与压测演示。生产建议切换到受控后端服务（鉴权/分页/审计）。

---

### 5. 内置 TCP 服务（联调建议）
- 服务器默认监听固定 IP，建议改为监听所有接口：
  - 将 `entry/src/main/ets/utils/network/NetworkOptimizer.ets` 中
    ```ts
    const TCP_SERVER_IP: string = '192.168.0.15';
    ```
    改为
    ```ts
    const TCP_SERVER_IP: string = '0.0.0.0';
    ```
- 局域网访问：用设备实际 IP 访问 `IP:8081`
- 常见测试方式：telnet / nc / 简短的 Python/Node.js 脚本

---

### 6. 数据库（不会 SQL 也能用）
- ORM：IBest-ORM（上层），ArkData 关系存储（底层）
- 入口：`DatabaseManager.getInstance()`；启动时调用 `initDatabase()` 做 `AutoMigrate`
- 常用方法：
  - 新增：`addUser` / `addTestRecord` / `addProcessingHistory`
  - 查询：`getAll...` / `get...ById(...)` / 条件查询（如 `getUsersByAge`）
  - 删除：`delete...`
  - 事务：`executeInTransaction(async () => { ...多步一致性... })`
- 返回结构：见 `entry/src/main/ets/database/types.ets`

最小示例：
```ts
const db = DatabaseManager.getInstance();
await db.initDatabase();
db.addUser({ name: '张三', age: 25 });
const users = db.getAllUsers(); // UserData[]
const ok = await db.executeInTransaction(async () => {
  db.addUser({ name: '李四', age: 20 });
  db.addProcessingHistory({ customerName:'客户A', farmName:'农场1', fruitName:'苹果', status:'进行中', startTime:'2025-11-11 10:00:00', endTime:'', weight:12.5, quantity:100 });
});
```

---

### 7. 压测与自动化
- Playwright 与 K6 脚本：`playwright-tests/`
  - `tests/smoke.spec.ts`：冒烟
  - `tests/database-stability.spec.ts`：长稳（约 15 分钟）
  - `k6-load-test.js`、`k6-load-test-extreme.js`：压测脚本
- 注意：大数据量全表查询负载大，生产建议分页

---

### 8. 依赖与锁文件
- 依赖：见 `oh-package.json5`
- 锁定：`oh-package-lock.json5`（自动生成，请勿手改）

---

### 9. 诊断脚本（内存监控）
- PowerShell：`mem_watch.ps1`（和 `.bak`）
- 作用：通过 `hdc` 获取 `hidumper --mem` 数据，定时写入 CSV，便于趋势分析
- 用法（示例）：
```powershell
pwsh ./mem_watch.ps1 -Bundle com.nutpi.My_Project -IntervalSec 5 -OutCsv ./mem_monitor_com.nutpi.My_Project.csv
```

---

### 10. 常见问题（精简）
1) 访问超时
   - App 是否运行
   - 端口映射是否建立（HTTP：8080）
2) TCP 无法连接
   - 改为 `0.0.0.0` 监听
   - 防火墙与同网段检查
3) 数据库一致性
   - 使用 `executeInTransaction` 包裹多步操作
4) 字段命名差异（大小写/下划线）
   - 管理器已做兼容转换，按 `types.ets` 使用即可

---

### 11. API 速览（内置 HTTP，仅用于联调/演示）
- Base：`http://127.0.0.1:8080`
- 端口映射（设备→本机）：
```bash
hdc fport tcp:8080 tcp:8080
```
- 列表：
  - GET `/api/processing?action=listJson`
  - 响应：JSON 数组（示例字段：id/customerName/farmName/fruitName/startTime/endTime/weight/count/status）
- 插入：
  - GET `/api/processing?action=insert&startTime=...&endTime=...&customerName=...&farmName=...&fruitName=...&weight=...&count=...`
  - 响应：`{"success": true}` 或 `{"success": false, "message": "..."}``
提示：用于本地演示，生产应迁至后端服务（鉴权/分页/审计/限流）。

---

### 12. TCP 联调快速指南
- 建议把服务器监听改为所有接口：
```ts
// entry/src/main/ets/utils/network/NetworkOptimizer.ets
const TCP_SERVER_IP: string = '0.0.0.0';
```
- 局域网访问：`<设备IP>:8081`
- 测试方式：
```bash
# telnet
telnet <设备IP> 8081
# nc
nc <设备IP> 8081
```
- 常见问题：
  - 端口被占用：更换端口或重启服务
  - 访问失败：确认同网段、防火墙放行

---

### 13. 数据库详解（带事务范式）
核心：IBest-ORM（操作层） + ArkData 关系存储（数据层）。不写 SQL 也能完成常用 CRUD 与事务。

初始化与基本 CRUD：
```ts
import { DatabaseManager } from './entry/src/main/ets/database/DatabaseManager';

const db = DatabaseManager.getInstance();
await db.initDatabase(); // 启动时一次

// 新增
db.addUser({ name: '张三', age: 25 });

// 查询
const users = db.getAllUsers(); // UserData[]
const one = db.getUserById(1);  // TestData | null（示例）

// 删除
db.deleteTestRecord(8);
```

事务（推荐自动包装）：
```ts
const ok = await db.executeInTransaction(async () => {
  db.addUser({ name: '李四', age: 20 });
  db.addProcessingHistory({
    customerName: '客户A',
    farmName: '农场1',
    fruitName: '苹果',
    status: '进行中',
    startTime: '2025-11-11 10:00:00',
    endTime: '',
    weight: 12.5,
    quantity: 100
  });
});
```
说明：
- 一致性：多步要么都成功提交，要么失败回滚
- 字段命名：模型 PascalCase ↔ 表字段 snake_case，管理器已做兼容

---

### 14. 目录导读（更详细）
- `entry/src/main/ets/pages/*`：页面逻辑与 UI
- `entry/src/main/ets/components/*`：复用组件（卡片、表格、表单、对话框）
- `entry/src/main/ets/database/*`：数据库封装（入口管理器、类型、示例）
- `entry/src/main/ets/utils/network/*`：HTTP/TCP 服务与处理器
- `playwright-tests/*`：自动化/压测脚本与报告
- `oh_modules/*`：三方依赖（可能含 deprecated 警告，功能不受影响）

---

### 15. 术语小抄（20 秒背诵版）
- ORM：对象-关系映射，用类/方法操作关系型表
- 一致性：多步操作原子性保障（事务提交=放行，失败回滚）
- 放行：本项目语境多指事务提交；也可指网络/白名单开放
- AutoMigrate：根据模型自动建/迁表

---

### 16. 完整接口清单（联调用）
说明：仅用于演示/联调，生产请迁移至受控后端。

- Base：`http://127.0.0.1:8080`（设备请先 `hdc fport tcp:8080 tcp:8080`）
- 加工记录
  - 列表：GET `/api/processing?action=listJson`
    - 返回：`[{ id, customerName, farmName, fruitName, startTime, endTime, weight, count, status }]`
  - 插入：GET `/api/processing?action=insert&startTime=&endTime=&customerName=&farmName=&fruitName=&weight=&count=`
    - 返回：`{ success: boolean, message?: string }`

---

### 17. 数据库字段映射表（模型 → 表）
- User
  - Name → name
  - Age → age
- TestModel
  - Title → title
  - Description → description
  - Count → count
  - IsEnabled → is_enabled
- ProcessingHistory
  - CustomerName → customer_name
  - FarmName → farm_name
  - FruitName → fruit_name
  - Status → status
  - StartTime → start_time
  - EndTime → end_time
  - Weight → weight
  - Quantity → quantity
说明：管理器已做键名兼容，按 `types.ets` 使用即可。

---

### 18. 事务模式清单（怎么用才稳）
- 自动包装（推荐）
  - `executeInTransaction(async () => { 步骤1; 步骤2; ... })`
  - 异常/错误自动回滚；全部成功自动提交（放行）
- 手动（官方风格）
  - `beginTransaction()` → 执行 → `getError()` → `commitTransaction()` / `rollbackTransaction()`
- 典型边界
  - 多表写入/更新、批量操作、强一致性业务块

---

### 19. 性能与分页建议
- 小数据量（≤几十条）：可直接全表返回
- 上千条后：改分页接口（`page/size`），对常用筛选字段建索引（`customerName/farmName/startTime`）
- HTTP 返回尽量瘦身；前端表格使用稳定 key（`id`）

---

### 20. 运维与“放行”检查表
- 应用侧
  - 事务放行：多步操作聚合于一个事务；错误即回滚
  - 启动初始化：`initDatabase()` 在 `EntryAbility` 中仅一次
- 网络侧
  - HTTP：8080 端口映射已建立（`hdc fport ls`）
  - TCP：监听 `0.0.0.0:8081` 或正确 IP；防火墙已放行
- 权限侧
  - 若接外部 DB：账号权限 GRANT、白名单/IP 放行

---

### 21. 故障排查清单（快速定位）
- HTTP 超时：App 是否运行；`hdc fport` 是否建立；端口占用情况
- TCP 不通：监听地址是否 `0.0.0.0`；同网段；防火墙规则
- 数据异常：查看管理器日志的原始结果键；确认 `initDatabase()` 执行；校验数据类型/空字符串处理
- 事务未提交：自动包装里是否抛异常；手动模式是否忘记 `commit`

---

### 22. FAQ（面向主管/评审）
- 用的什么 ORM？为何选它？
  - IBest-ORM，配 ArkData 关系存储；少写 SQL、易维护
- 一致性如何保证？
  - 事务包装；失败回滚、成功提交
- 字段命名差异如何处理？
  - 管理器层做兼容转换；对外按 `types.ets`
- 单例的意义？
  - 统一 ORM 实例与迁移入口，避免重复初始化
- 生产化建议？
  - HTTP 联调接口迁至后端，增加鉴权/分页/审计/限流；前端仅调受控 API

---

### 23. 团队上手清单（Day 1）
1) 构建运行（HAP 安装、启动）
2) 端口映射并访问 HTTP 列表
3) 调用一次插入并在前台看见新增
4) 页面里写三行数据库调用：新增→查询→删除
5) 跑一次事务包装演示：两步一起成功/失败

---

### 24. 全量接口规范（联调用，仅用于本地/设备演示）
- 基地址
  - 本机：`http://127.0.0.1:8080`（设备需先 `hdc fport tcp:8080 tcp:8080`）
  - 设备局域网：`http://<设备IP>:8080`
- 鉴权：无（演示用，勿对公网暴露）
- 编码：UTF-8，响应 JSON

- 加工记录列表
  - 方法：GET
  - 路径：`/api/processing`
  - Query
    - `action`（string，必填）：`listJson`
  - 示例：
    - GET `/api/processing?action=listJson`
  - 响应 200：
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

- 插入加工记录
  - 方法：GET
  - 路径：`/api/processing`
  - Query
    - `action`（string，必填）：`insert`
    - `startTime`（string，必填，`YYYY-MM-DD HH:mm`）
    - `endTime`（string，可选，同上；为空代表进行中）
    - `customerName`（string，可选）
    - `farmName`（string，可选）
    - `fruitName`（string，可选）
    - `weight`（number，可选）
    - `count`（number，可选）
  - 示例：
    - GET `/api/processing?action=insert&startTime=2024-11-01%2008:30&endTime=2024-11-01%2012:45&customerName=客户A&farmName=农场1&fruitName=苹果&weight=12.5&count=320`
  - 响应：
    - 成功：`{"success": true}`
    - 失败：`{"success": false, "message": "错误信息"}`

- 错误码（HTTP）
  - 400 参数缺失或格式错误
  - 500 内部错误（请查看应用日志）

---

### 25. 数据库模型与索引（字段/约束/样例）
- 说明
  - 上层通过 IBest-ORM 操作；模型字段 PascalCase
  - 底层表字段 snake_case；常用字段已在管理器层做键名兼容
  - 系统字段：`id`、`created_at`、`updated_at`

- User（用户）
  - 字段：
    - `Name` TEXT（表：`name`）
    - `Age` INTEGER（表：`age`）
  - 示例：
    - `new User('张三', 25)`

- TestModel（测试）
  - 字段：
    - `Title` TEXT（`title`）
    - `Description` TEXT（`description`）
    - `Count` INTEGER（`count`）
    - `IsEnabled` INTEGER（`is_enabled`）

- ProcessingHistory（历史加工）
  - 字段：
    - `CustomerName` TEXT（`customer_name`）
    - `FarmName` TEXT（`farm_name`）
    - `FruitName` TEXT（`fruit_name`）
    - `Status` TEXT（`status`）
    - `StartTime` TEXT（`start_time`）
    - `EndTime` TEXT（`end_time`）
    - `Weight` REAL（`weight`）
    - `Quantity` INTEGER（`quantity`）

- 索引建议（当数据上千条时）
  - `processing_history(customer_name)`
  - `processing_history(farm_name)`
  - `processing_history(start_time)`

- 空字符串处理
  - 插入时使用工具方法清理空串，避免把空串当有效值写入（详见管理器与 utils）

---

### 26. 环境搭建到首屏（一步步走通）
1) 安装 DevEco Studio / hvigor / hdc
2) 连接真机或模拟器
   - `hdc list targets`
3) 生成 HAP 包
   - Build > Generate App Package(s)
4) 安装与启动
   - `hdc install entry/build/default/outputs/default/entry-default-signed.hap`
   - `hdc shell aa start -a com.nutpi.My_Project.EntryAbility -b com.nutpi.My_Project`
5) 打通 HTTP
   - `hdc fport tcp:8080 tcp:8080`
   - 浏览器访问：`http://127.0.0.1:8080/api/processing?action=listJson`
6) 页面联动
   - 访问 `insert` 接口后，前台历史页面应能看到新增数据

---

### 27. 事务与一致性（何时用与如何判错）
- 何时必须事务
  - 多表写入/更新、批量操作
  - 强一致性需求：要么全部成功、要么全部失败
- 自动包装（推荐）
  - `await executeInTransaction(async () => { 步骤1; 步骤2; })`
- 手动（官方风格）
  - `beginTransaction()` → 执行 → `getError()` 判错 → `commitTransaction()` / `rollbackTransaction()`
- 日志与判错
  - 方法内 catch 后打印错误信息；`getError()` 获取 ORM 最近错误
  - 推荐在关键路径加上“开始/结束/异常”日志，便于回溯

---

### 28. 性能与分页（阈值与改造示例）
- 阈值建议
  - ≤几十条：全表返回可接受
  - 上千条：必须分页（`page/size`），并对筛选字段建索引
- 接口改造思路
  - `listJson?page=1&size=50&customerName=...`
  - 后端：`LIMIT/OFFSET` 或游标；字段筛选走索引
- 前端建议
  - 表格使用稳定 `key=id`；分页 UI 与加载状态

---

### 29. 运维放行手册（网络/白名单/验证）
- HTTP 放行
  - 设备 → 本机映射：`hdc fport tcp:8080 tcp:8080`
  - 验证：`curl http://127.0.0.1:8080/api/processing?action=listJson`
- TCP 放行
  - 监听地址：`0.0.0.0:8081`（或设备实际 IP）
  - 防火墙：放行入站 8081/TCP
  - 验证：`telnet <设备IP> 8081` 或 `nc <设备IP> 8081`
- 外部 DB（如有）
  - 账号 GRANT、IP 白名单；连通性验证命令视 DB 类型而定

---

### 30. 故障排查手册（症状 → 命令 → 修复）
- HTTP 访问超时
  - 命令：`hdc fport ls`、`netstat -an | grep 8080`
  - 修复：建立映射；释放占用端口；确认 App 在运行
- TCP 无法连接
  - 命令：`telnet`/`nc` 测试；检查监听日志
  - 修复：改 `0.0.0.0` 监听；放行防火墙；同网段
- 数据库写入异常/字段错乱
  - 观察管理器日志打印的原始结果键；确认 `initDatabase()` 已执行
  - 修复：检查 types、字段映射与空字符串处理工具
- 事务未提交
  - 命令：查看事务开始/提交日志与异常堆栈
  - 修复：自动包装中修正异常；手动模式补 `commit/rollback`



