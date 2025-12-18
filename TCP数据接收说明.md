# TCP数据接收和实时更新功能说明

## 功能概述

本项目已实现从TCP接收下位机发送的实时统计数据（StStatistics结构体），并自动更新UI界面显示。

## 实现的功能

### 1. 数据结构定义
- **文件位置**: `entry/src/main/ets/utils/network/tcp/types/StStatistics.ets`
- **功能**: 定义了`StStatistics`结构体，对应48项目中的数据结构
- **包含数据**: 等级统计、出口统计、总体统计、速度间隔、设备状态等

### 2. TCP数据解析器
- **文件位置**: `entry/src/main/ets/utils/network/tcp/parsers/TcpStatisticsParser.ets`
- **功能**: 将TCP接收的二进制字节流解析为`StStatistics`结构体
- **数据格式**: 
  - 同步字符串: "SYNC" (4字节)
  - 命令头: 源ID(4字节) + 目标ID(4字节) + 命令ID(4字节)
  - 数据体: StStatistics结构体的二进制内存布局

### 3. 实时数据管理器
- **文件位置**: `entry/src/main/ets/utils/managers/RealtimeDataManager.ets`
- **功能**: 
  - 管理从TCP接收的实时统计数据
  - 计算实时指标（分选效率、实时产量、平均重量等）
  - 每3秒自动计算一次
  - 支持多子系统（FSM1、FSM2）数据管理

### 4. TCP服务器/客户端集成
- **修改文件**: 
  - `entry/src/main/ets/utils/network/tcp/TCPServer.ets`
  - `entry/src/main/ets/utils/network/tcp/TcpClient.ets`
- **功能**: 自动识别二进制统计数据（以"SYNC"开头），并调用解析器处理

### 5. UI组件更新
- **HomeContent**: 从TCP数据更新分选信息卡片（9个指标）
- **LiquidCardsArea**: 从TCP数据更新出口卡片数据
- **HomeDataManager**: 从TCP数据更新等级统计表

## 需要从TCP接收的数据字段

### 直接使用的字段
1. `nTotalCount` - 水果批总个数
2. `nWeightCount` - 水果批总重量（克）
3. `nIntervalSumperminute` - 分选速度（个/分钟）
4. `nPulseInterval` - 间隔速度（ms）
5. `nCupState` - 果杯状态
6. `nNetState` - IPM网络状态
7. `nWeightSetting` - 重量整定标志
8. `nSCMState` - SCM状态
9. `nIQSNetState` - 糖度传感器状态

### 数组数据字段
1. `nGradeCount[]` - 各等级个数数组
2. `nWeightGradeCount[]` - 各等级重量数组（克）
3. `nBoxGradeCount[]` - 各等级箱数数组
4. `nBoxGradeWeight[]` - 各等级每箱重数组（克）
5. `nExitCount[]` - 各出口个数数组
6. `nExitWeightCount[]` - 各出口重量数组（克）
7. `ExitBoxNum[]` - 各出口箱数数组

### 计算需要的字段
1. `nTotalCupNum` - 总果杯数（用于计算分选效率）

## 实时计算的数据

### 1. 分选效率（%）
- **公式**: `(当前总数 - 上次总数) * 100 / (当前果杯数 - 上次果杯数)`
- **更新频率**: 每3秒计算一次

### 2. 实时产量（吨/小时）
- **公式**: `(当前重量 - 上次重量) * 1200`（每3秒的增量转换为每小时）
- **更新频率**: 每3秒计算一次

### 3. 平均果重（克）
- **公式**: `总重量(克) / 总个数`
- **更新频率**: 每次TCP数据更新时计算

### 4. 实时产量百分比（%）
- **公式**: `(实时产量 / 最大产量) * 100`
- **更新频率**: 每3秒计算一次

### 5. 速度百分比（%）
- **公式**: `(当前速度 / 最大速度) * 100`
- **更新频率**: 每次TCP数据更新时计算

## 使用方法

### 1. 启动TCP服务器
```typescript
import { TCPServer } from '../utils/network/tcp'

const tcpServer = new TCPServer()
await tcpServer.start('0.0.0.0', 11279) // 监听端口11279
```

### 2. 启动TCP客户端（如果需要主动连接）
```typescript
import { TcpClientManager } from '../utils/network/tcp'

const clientManager = TcpClientManager.getInstance()
const client = clientManager.createClient('statistics')
await clientManager.connectClient('statistics', '192.168.1.100', 11279)
```

### 3. 获取实时数据
```typescript
import { RealtimeDataManager } from '../utils/managers/RealtimeDataManager'

const dataManager = RealtimeDataManager.getInstance()

// 获取子系统0的统计数据
const statistics = dataManager.getStatistics(0)

// 获取子系统0的计算数据
const calculated = dataManager.getCalculatedData(0)

// 获取所有子系统的累加数据
const allStatistics = dataManager.getAllStatistics()
const allCalculated = dataManager.getAllCalculatedData()
```

## 数据更新流程

1. **TCP接收**: 下位机通过TCP发送二进制数据包
2. **数据解析**: `TcpStatisticsParser`解析二进制数据为`StStatistics`结构体
3. **数据存储**: `RealtimeDataManager`存储统计数据
4. **实时计算**: 每3秒计算一次实时指标
5. **UI更新**: 通过`AppStorage`通知UI组件更新
6. **界面刷新**: UI组件监听数据更新事件，自动刷新显示

## 注意事项

1. **字节序**: 数据使用小端字节序（Little-Endian）
2. **内存对齐**: 解析器假设结构体是紧凑布局（无对齐），如果实际结构体有对齐，需要调整偏移量
3. **数据类型**: 
   - `ulong`在TypeScript中可能超出`Number.MAX_SAFE_INTEGER`，实际项目中可能需要使用`BigInt`
   - 当前实现使用`number`类型，对于大数值可能丢失精度
4. **子系统ID**: FSM1对应子系统ID=0，FSM2对应子系统ID=1
5. **数据格式**: 下位机发送的数据格式必须严格按照协议：
   - 以"SYNC"字符串开头
   - 命令头12字节
   - 数据体为StStatistics结构体的二进制表示

## 配置参数

### 最大实时产量
- **存储位置**: `AppStorage`中的`MaxRealWeightCount`
- **默认值**: 100.0（吨/小时）
- **用途**: 计算实时产量百分比

### 最大分选速度
- **存储位置**: `AppStorage`中的`MaxSpeed`
- **默认值**: 100（个/分钟）
- **用途**: 计算速度百分比

## 调试建议

1. **查看日志**: 使用`hilog`查看TCP数据接收和解析日志
2. **检查数据**: 在`RealtimeDataManager`中添加日志，查看接收到的原始数据
3. **验证解析**: 检查`TcpStatisticsParser`解析出的数据是否正确
4. **UI更新**: 检查`AppStorage`中的数据更新事件是否触发

## 后续优化建议

1. **数据结构对齐**: 如果实际C++结构体有内存对齐，需要调整解析器的偏移量
2. **大数值处理**: 对于超过`Number.MAX_SAFE_INTEGER`的数值，考虑使用`BigInt`
3. **错误处理**: 增强数据解析的错误处理和恢复机制
4. **性能优化**: 对于高频数据更新，考虑使用数据缓冲和批量更新
5. **数据验证**: 添加数据范围验证，防止异常数据导致UI显示错误

