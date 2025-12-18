# TCP数据接收和实时更新功能实现总结

## ✅ 已完成的工作

### 1. 核心数据结构定义 ✅
- **文件**: `entry/src/main/ets/utils/network/tcp/types/StStatistics.ets`
- **内容**: 
  - 定义了`StStatistics`接口（对应48项目的结构体）
  - 定义了`CommandHead`接口（命令头结构）
  - 定义了`TcpDataPacket`接口（TCP数据包格式）
  - 提供了`createDefaultStStatistics()`函数创建默认对象

### 2. TCP数据解析器 ✅
- **文件**: `entry/src/main/ets/utils/network/tcp/parsers/TcpStatisticsParser.ets`
- **功能**:
  - 解析SYNC字符串（4字节）
  - 解析命令头（12字节，小端字节序）
  - 解析StStatistics结构体（二进制字节流）
  - 支持各种数据类型的转换（int32, uint64, uint16, uint8, float）
  - 手动实现IEEE 754浮点数解析（兼容HarmonyOS）

### 3. 实时数据管理器 ✅
- **文件**: `entry/src/main/ets/utils/managers/RealtimeDataManager.ets`
- **功能**:
  - 管理多个子系统的统计数据（FSM1=0, FSM2=1）
  - 每3秒自动计算实时指标
  - 计算分选效率、实时产量、平均重量等
  - 提供数据更新事件通知（通过AppStorage）
  - 支持获取单个子系统或所有子系统的累加数据

### 4. TCP数据处理器 ✅
- **文件**: `entry/src/main/ets/utils/network/tcp/handlers/StatisticsDataHandler.ets`
- **功能**:
  - 处理TCP接收的二进制统计数据
  - 验证SYNC字符串和命令ID
  - 调用解析器解析数据
  - 更新实时数据管理器

### 5. TCP服务器/客户端集成 ✅
- **修改文件**:
  - `entry/src/main/ets/utils/network/tcp/TCPServer.ets`
  - `entry/src/main/ets/utils/network/tcp/TcpClient.ets`
  - `entry/src/main/ets/utils/network/tcp/dispatch/TcpMessageDispatchQueue.ets`
- **功能**:
  - 自动识别二进制统计数据（以"SYNC"开头）
  - 支持文本消息和二进制消息两种格式
  - 自动调用统计数据处理器

### 6. UI组件更新 ✅

#### 6.1 HomeContent组件
- **文件**: `entry/src/main/ets/pages/home/HomeContent.ets`
- **修改内容**:
  - 添加`RealtimeDataManager`实例
  - 添加TCP数据更新监听（`@StorageLink('TCP_STATISTICS_GLOBAL_UPDATE')`）
  - 实现`updateFromTcpData()`方法，从TCP数据更新9个分选信息指标
  - 禁用模拟数据定时器，改用真实TCP数据
  - 更新顶部状态栏的4个指标

#### 6.2 LiquidCardsArea组件
- **文件**: `entry/src/main/ets/pages/home/LiquidCardsArea.ets`
- **修改内容**:
  - 添加`RealtimeDataManager`实例
  - 添加TCP数据更新监听
  - 实现`updateCardsFromTcpData()`方法，从TCP数据更新出口卡片数据

#### 6.3 HomeDataManager组件
- **文件**: `entry/src/main/ets/pages/home/core/HomeDataManager.ets`
- **修改内容**:
  - 添加`RealtimeDataManager`实例
  - 修改`initializeStatisticsTableData()`方法，从TCP数据更新等级统计表
  - 实现`updateStatisticsTableFromTcp()`方法，解析TCP数据并构建表格数据

## 📋 需要从TCP接收的数据清单

### 直接使用的字段（9个）
1. ✅ `nTotalCount` - 水果批总个数
2. ✅ `nWeightCount` - 水果批总重量（克）
3. ✅ `nIntervalSumperminute` - 分选速度（个/分钟）
4. ✅ `nPulseInterval` - 间隔速度（ms）
5. ✅ `nCupState` - 果杯状态
6. ✅ `nNetState` - IPM网络状态
7. ✅ `nWeightSetting` - 重量整定标志
8. ✅ `nSCMState` - SCM状态
9. ✅ `nIQSNetState` - 糖度传感器状态

### 数组数据字段（7个数组）
1. ✅ `nGradeCount[]` - 各等级个数数组（128个元素）
2. ✅ `nWeightGradeCount[]` - 各等级重量数组（128个元素，克）
3. ✅ `nBoxGradeCount[]` - 各等级箱数数组（128个元素）
4. ✅ `nBoxGradeWeight[]` - 各等级每箱重数组（128个元素，克）
5. ✅ `nExitCount[]` - 各出口个数数组（20个元素）
6. ✅ `nExitWeightCount[]` - 各出口重量数组（20个元素，克）
7. ✅ `ExitBoxNum[]` - 各出口箱数数组（20个元素）

### 计算需要的字段（1个）
1. ✅ `nTotalCupNum` - 总果杯数（用于计算分选效率）

## 🔄 数据更新流程

```
下位机TCP发送
    ↓
[SYNC(4字节) + 命令头(12字节) + 数据体(二进制)]
    ↓
TCPServer/TcpClient接收
    ↓
识别为二进制数据（以SYNC开头）
    ↓
StatisticsDataHandler处理
    ↓
TcpStatisticsParser解析
    ↓
RealtimeDataManager存储和计算
    ↓
AppStorage通知更新
    ↓
UI组件自动刷新
```

## 📊 实时计算的数据

### 每3秒计算一次
1. ✅ **分选效率（%）**: `(当前总数 - 上次总数) * 100 / (当前果杯数 - 上次果杯数)`
2. ✅ **实时产量（吨/小时）**: `(当前重量 - 上次重量) * 1200`
3. ✅ **实时产量百分比（%）**: `(实时产量 / 最大产量) * 100`

### 每次TCP数据更新时计算
1. ✅ **平均果重（克）**: `总重量(克) / 总个数`
2. ✅ **速度百分比（%）**: `(当前速度 / 最大速度) * 100`

## 🎯 UI更新的数据

### 分选信息卡片（9个指标）
1. ✅ 分选速度 - 来自`nIntervalSumperminute`
2. ✅ 本批重量 - 来自`nWeightCount`（转换为kg）
3. ✅ 本批个数 - 来自`nTotalCount`
4. ✅ 开始时间 - 首次`nTotalCount > 0`时记录
5. ✅ 分选程序 - 从配置获取（非TCP数据）
6. ✅ 分选效率 - 计算得出
7. ✅ 平均重量 - 计算得出
8. ✅ 实时产量 - 计算得出
9. ✅ 间隔速度 - 来自`nPulseInterval`

### 顶部状态栏（4个指标）
1. ✅ 实时产量 - 计算得出
2. ✅ 总重量 - 来自`nWeightCount`（所有子系统累加）
3. ✅ 总个数 - 来自`nTotalCount`（所有子系统累加）
4. ✅ 平均果重 - 计算得出

### 出口卡片
1. ✅ 出口个数 - 来自`nExitCount[]`
2. ✅ 出口重量 - 来自`nExitWeightCount[]`（转换为kg）
3. ✅ 出口箱数 - 来自`ExitBoxNum[]`

### 等级统计表
1. ✅ 等级个数 - 来自`nGradeCount[]`
2. ✅ 等级重量 - 来自`nWeightGradeCount[]`（转换为kg）
3. ✅ 等级箱数 - 来自`nBoxGradeCount[]`
4. ✅ 每箱重 - 来自`nBoxGradeWeight[]`（转换为kg）
5. ✅ 各种百分比 - 计算得出

## ⚙️ 配置说明

### TCP服务器端口
- **默认端口**: 11279（对应48项目的端口）
- **配置位置**: 在启动TCP服务器时指定

### 最大实时产量
- **存储位置**: `AppStorage`中的`MaxRealWeightCount`
- **默认值**: 100.0（吨/小时）
- **用途**: 计算实时产量百分比

### 最大分选速度
- **存储位置**: `AppStorage`中的`MaxSpeed`
- **默认值**: 100（个/分钟）
- **用途**: 计算速度百分比

## 🔧 使用示例

### 启动TCP服务器
```typescript
import { TCPServer } from '../utils/network/tcp'

const tcpServer = new TCPServer()
await tcpServer.start('0.0.0.0', 11279)
```

### 获取实时数据
```typescript
import { RealtimeDataManager } from '../utils/managers/RealtimeDataManager'

const dataManager = RealtimeDataManager.getInstance()

// 获取FSM1（子系统0）的数据
const stats = dataManager.getStatistics(0)
const calculated = dataManager.getCalculatedData(0)

// 获取所有子系统的累加数据
const allStats = dataManager.getAllStatistics()
const allCalculated = dataManager.getAllCalculatedData()
```

## ⚠️ 注意事项

1. **字节序**: 所有整数使用小端字节序（Little-Endian）
2. **内存对齐**: 解析器假设结构体是紧凑布局，如果实际有对齐需要调整偏移量
3. **数据类型**: `ulong`可能超出JavaScript安全范围，大数值可能需要使用`BigInt`
4. **子系统ID**: FSM1=0, FSM2=1
5. **数据格式**: 必须严格按照协议格式发送（SYNC + 命令头 + 数据体）

## 🐛 调试建议

1. **查看日志**: 使用`hilog`查看TCP接收和解析日志
2. **验证数据**: 在`RealtimeDataManager`中添加日志查看原始数据
3. **检查解析**: 验证`TcpStatisticsParser`解析的数据是否正确
4. **UI更新**: 检查`AppStorage`中的数据更新事件是否触发

## 📝 后续优化建议

1. **数据结构对齐**: 如果实际C++结构体有内存对齐，需要调整解析器偏移量
2. **大数值处理**: 对于超大数值，考虑使用`BigInt`
3. **错误处理**: 增强数据解析的错误处理和恢复机制
4. **性能优化**: 对于高频数据更新，考虑数据缓冲和批量更新
5. **数据验证**: 添加数据范围验证，防止异常数据

## ✨ 总结

已成功实现从TCP接收下位机发送的实时统计数据，并自动更新UI界面。所有需要从TCP接收的数据字段都已实现，UI组件已从模拟数据切换到真实TCP数据。系统现在可以实时显示分选速度、本批重量、本批个数、分选效率、平均重量、实时产量、间隔速度等9个关键指标，以及出口统计和等级统计信息。

