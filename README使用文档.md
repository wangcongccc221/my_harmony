本应用为分选机可视化与数据管理（HarmonyOS/OpenHarmony）。当前版本已稳定运行，支持首页看板、历史数据导出、基础网络联调与压力测试。

## 一、交付物
- 安装包：`.hap`，源码
- 文档：
  - 本说明（简版）
  - 根目录 `README.md`（技术版，含构建、端口映射、压测）

## 二、主要功能
- 首页看板：
  - 实时波浪动画、水位卡片展示
  - 顶部指标（速度、产出、均重、效率、时间等）
- 历史数据：
  - 条件筛选（客户/农场/水果/日期）
  - 导出 CSV/Excel（以 CSV 内容保存至 .xlsx）
- 网络联调：
  - 内置 HTTP 服务用于本机或设备联调（查询/插入）

## 三、演示步骤
1) 安装应用（模拟器或真机）：
   - 连接设备：`hdc list targets`
   - 安装：`hdc install entry/build/default/outputs/default/entry-default-signed.hap`
   - 启动：`hdc shell aa start -a com.nutpi.My_Project.EntryAbility -b com.nutpi.My_Project`
2) 查看首页：
   - 波浪动画与指标刷新应流畅
3) 历史页面（筛选与导出）：
   - 输入客户/农场/水果条件，点击查询
   - 点击导出按钮生成文件（CSV/Excel）
4) （可选）接口联调：
   - 端口映射：`hdc fport tcp:8080 tcp:8080`
   - 查询：`GET http://127.0.0.1:8080/api/processing?action=listJson`
   - 插入：`GET http://127.0.0.1:8080/api/processing?action=insert&startTime=...&endTime=...&customerName=...&farmName=...&fruitName=...`

## 四、性能结论（简要）
- 小数据量下（≤数十条），平均响应 < 50ms，UI 流畅
- 大数据量全表查询会增压，建议生产改为分页接口（技术 README 已给出建议）

## 五、已知事项
- 第三方 UI 组件有少量"deprecated"警告，不影响演示与使用
- 导出 Excel 目前为 CSV 内容写入 `.xlsx`

## 六、端口映射说明
- HTTP 服务器端口：8080（用于 RESTful API）
- TCP 服务器端口：8081（用于 TCP 通信）
- 端口映射命令：`hdc fport tcp:8080 tcp:8080`（将设备 8080 端口映射到本机 8080）
- 查看映射：`hdc fport ls`
- 删除映射：`hdc fport rm tcp:8080`





