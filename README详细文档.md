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

## 3. 环境要求
- DevEco Studio（含 hvigor、hdc）
- 模拟器或真机已连接（`hdc list targets`）

## 4. 构建与打包

### 4.1 DevEco Studio（推荐）
1) 打开项目 → 如需发布包，先在 Project Structure > Signing Configs 配置 release 签名/Profile。
2) 菜单 Build > Generate App Package(s)。
3) 产物：
   - HAP：`entry/build/default/outputs/default/entry-default-signed.hap`
   - APP（多模块打包）：`build/default/outputs/app/*.app`

### 4.2 命令行（Windows 示例）
```bat
"E:\huawei\DevEco Studio\tools\node\node.exe" "E:\huawei\DevEco Studio\tools\hvigor\bin\hvigorw.js" --mode module -p module=entry@default -p product=default -p requiredDeviceType=2in1 assembleHap --parallel --incremental --daemon
```

> 若 PowerShell 引号转义报错，可用：
```bat
cmd /c "\"E:\\huawei\\DevEco Studio\\tools\\node\\node.exe\" \"E:\\huawei\\DevEco Studio\\tools\\hvigor\\bin\\hvigorw.js\" --mode module -p module=entry@default -p product=default -p requiredDeviceType=2in1 assembleHap --parallel --incremental --daemon"
```

## 5. 安装与启动
```bat
hdc list targets                     # 确认设备
hdc install entry\build\default\outputs\default\entry-default-signed.hap

# 启动（可选）
hdc shell aa start -a com.nutpi.My_Project.EntryAbility -b com.nutpi.My_Project
```

## 6. 端口映射（如需在主机访问设备内 HTTP 服务）
应用内置 HTTP 服务默认 9999 端口：
```bat
hdc fport add tcp:9999 tcp:9999   # 添加映射
hdc fport ls                      # 查看映射
hdc fport rm tcp:9999             # 删除映射
```
接口示例：
- 查询：`GET http://127.0.0.1:9999/api/processing?action=listJson`
- 插入：`GET http://127.0.0.1:9999/api/processing?action=insert&startTime=...&endTime=...&customerName=...&farmName=...&fruitName=...`

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

## 8. 压力测试（可选）
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


