# TODO

- [ ] 打印模块对齐 48 项目：实现“版式化打印”链路（非纯文件直打）
- [ ] 打印模块：拆分“打印报告/打印标签”两套模板与字段映射，行为对齐 48
- [ ] 打印设置：补齐导入/导出配置兼容（首次无文件时自动创建默认配置，避免 `code:13900002` 误判）
- [ ] 打印联调：在真机验证系统打印能力（模拟器可能无完整打印服务）
- [ ] 打印日志：补充统一日志点（打开设置、预览触发、打印调用成功/失败、错误码）

- [ ] 协议联调：用真实下位机连续字节流验证“接收 -> 拆包 -> 解析 -> ArkTS UI 绑定”全链路
- [ ] 协议一致性回归：再次核对 Harmony 与 48 的结构体字段偏移/字节序/长度边界
- [ ] 协议健壮性：补充异常包处理（长度不足、未知命令、错位包头、粘包/半包）
- [ ] TCP 连接模型确认：核对是否需要按 48 的“双服务链路”实现（当前方案与 Qt 角色保持一致性检查）
- [ ] 图像链路 UI（对齐 48）：将 HC_PORT1 图像服务接入 `QualitySettingsDialog`/`ChannelRangePage`，实现图像预览区与帧信息展示（cmd/src/len/time），支持连续采集调试

- [ ] 文档化：输出“鸿蒙 vs 48 协议与打印对照表（最终版）”并标注已验证项/未验证项

## 功能/UI 待完善（非协议）

- [ ] 主页“更多设置”按钮逻辑补齐（复位果杯、测试果杯、保存设备信息、导入/保存配置、贴标设置保存、出口屏设置保存） `entry/src/main/ets/pages/Home.ets`
- [ ] “更多”页面导入/保存功能实现 `entry/src/main/ets/pages/more/MoreContent.ets`
- [ ] 品质页面“保存参数”逻辑实现与联调 `entry/src/main/ets/pages/quality/QualityContent.ets`
- [ ] 实时统计弹窗：更新单价逻辑与占位块替换 `entry/src/main/ets/components/feedback/RealtimeStatsDialog.ets`
- [ ] 出口统计页面：数据库数据源/实时数据刷新/导出/打印功能实现 `entry/src/main/ets/components/feedback/ExportStatisticsContent.ets`
- [ ] 设备信息弹窗：日期选择器与下拉选择逻辑补齐 `entry/src/main/ets/components/dialogs/DeviceInfoDialog.ets`
- [ ] 电器故障/系统故障弹窗：导入与保存逻辑实现 `entry/src/main/ets/components/dialogs/ElectricalFaultDialog.ets`, `entry/src/main/ets/components/dialogs/SystemFaultDialog.ets`
- [ ] 电机使能弹窗：出果清框/全部出框动作实现 `entry/src/main/ets/components/dialogs/MotorEnableDialog.ets`
- [ ] 通道范围页面：获取系数/自动计算/立即生效逻辑实现 `entry/src/main/ets/components/dialogs/pages/ChannelRangePage.ets`
- [ ] 水果信息页面：立即生效逻辑实现 `entry/src/main/ets/components/dialogs/pages/FruitInfoPage.ets`

