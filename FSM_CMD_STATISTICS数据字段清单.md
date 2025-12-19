# FSM_CMD_STATISTICS 数据字段完整清单

## 命令信息
- **命令ID**: `0x0001` (FSM_CMD_STATISTICS)
- **命令名称**: 统计信息命令
- **数据流向**: FSM → HC (下位机 → 上位机)
- **数据包格式**: `[SYNC(4字节)] + [CommandHead(12字节)] + [StStatistics数据体(3620字节)]`

## 48项目使用情况
✅ **是的，48项目也使用这个指令**
- 48项目中的定义：`FSM_CMD_STATISTICS` (在 `RSS/Base/interface.h` 中定义)
- 命令ID：`0x0001`
- 结构体：`StStatistics`

---

## StStatistics 结构体完整字段列表

### 一、等级统计数据（128个等级 = 8个品质等级 × 16个尺寸等级）

| 序号 | 字段名 | 类型 | 数组大小 | 单位 | 说明 |
|------|--------|------|----------|------|------|
| 1 | `nGradeCount` | ulong | 128 | 个 | 各等级的水果个数数组 |
| 2 | `nWeightGradeCount` | ulong | 128 | 克 | 各等级的水果重量数组 |
| 3 | `nBoxGradeCount` | int | 128 | 箱 | 各等级的箱数数组 |
| 4 | `nBoxGradeWeight` | int | 128 | 克 | 各等级的每箱重量数组 |

**数组索引计算**：
- 索引 = 品质等级索引 × 16 + 尺寸等级索引
- 例如：品质等级1，尺寸等级0 → 索引 = 1 × 16 + 0 = 16

---

### 二、出口统计数据（20个出口）

| 序号 | 字段名 | 类型 | 数组大小 | 单位 | 说明 |
|------|--------|------|----------|------|------|
| 5 | `nExitCount` | ulong | 20 | 个 | 各个出口的水果个数 |
| 6 | `nExitWeightCount` | ulong | 20 | 克 | 重量分选时各个出口的重量 |
| 7 | `ExitBoxNum` | quint32/int | 20 | 箱 | 各个出口的箱数 |

---

### 三、总体统计数据

| 序号 | 字段名 | 类型 | 单位 | 说明 |
|------|--------|------|------|------|
| 8 | `nTotalCount` | ulong | 个 | 水果批总个数 |
| 9 | `nWeightCount` | ulong | 克 | 水果批总重量 |
| 10 | `nSubsysId` | int | - | 子系统ID（FSM编号，0=FSM1, 1=FSM2等） |
| 11 | `nTotalCupNum` | int | 个 | 总的果杯数 |

---

### 四、速度与间隔数据

| 序号 | 字段名 | 类型 | 单位 | 说明 |
|------|--------|------|------|------|
| 12 | `nInterval` | int | - | 与上次发送统计信息的间隔数 |
| 13 | `nIntervalSumperminute` | int | 个/分钟 | 一分钟内光电开关的个数（用于计算分选速度） |
| 14 | `nPulseInterval` | ushort | 毫秒(ms) | 脉冲间隔（2000以上时，分选速度为0） |
| 15 | `nUnpushFruitCount` | ushort | 个 | 遗漏的水果个数（上位机每20秒调用一次） |

---

### 五、设备状态数据

| 序号 | 字段名 | 类型 | 说明 |
|------|--------|------|------|
| 16 | `nCupState` | ushort | 12个通道的果杯状态（低12位有效，最低位代表通道1，0=正常，1=故障） |
| 17 | `nNetState` | quint8/ushort* | IPM网络状态（低6位有效，低6位代表6个IPM，最低位代表IPM1，0=正常，1=故障） |
| 18 | `nWeightSetting` | quint8/ushort* | 重量整定标志（1=整定完毕，0=基准整定中） |
| 19 | `nSCMState` | quint8/int* | SCM状态（根据编译选项：0=正常，1=故障 或 1=正常，0=故障） |
| 20 | `nIQSNetState` | quint8/ushort* | 糖度传感器网络状态（0=正常，1=故障） |
| 21 | `nLockState` | quint8 | 锁定状态 |

*注：根据48项目的编译选项（L64、LS8等），某些字段的类型可能不同

---

### 六、分选基准范围数据

| 序号 | 字段名 | 类型 | 数组大小 | 说明 |
|------|--------|------|----------|------|
| 22 | `fSelectBasisRange` | StRange | 16 | 分选基准范围数组（每个StRange包含nMin和nMax两个float） |

**StRange 结构**：
- `nMin`: float (最小值)
- `nMax`: float (最大值)

---

## 数据体大小计算

### 字节大小明细

| 字段组 | 字段 | 类型 | 数量 | 单字段大小 | 总大小 |
|--------|------|------|------|------------|--------|
| 等级统计 | nGradeCount | ulong | 128 | 8字节 | 1024字节 |
| 等级统计 | nWeightGradeCount | ulong | 128 | 8字节 | 1024字节 |
| 出口统计 | nExitCount | ulong | 20 | 8字节 | 160字节 |
| 出口统计 | nExitWeightCount | ulong | 20 | 8字节 | 160字节 |
| 总体统计 | nTotalCount | ulong | 1 | 8字节 | 8字节 |
| 总体统计 | nWeightCount | ulong | 1 | 8字节 | 8字节 |
| 总体统计 | nSubsysId | int | 1 | 4字节 | 4字节 |
| 等级统计 | nBoxGradeCount | int | 128 | 4字节 | 512字节 |
| 等级统计 | nBoxGradeWeight | int | 128 | 4字节 | 512字节 |
| 总体统计 | nTotalCupNum | int | 1 | 4字节 | 4字节 |
| 速度间隔 | nInterval | int | 1 | 4字节 | 4字节 |
| 速度间隔 | nIntervalSumperminute | int | 1 | 4字节 | 4字节 |
| 设备状态 | nCupState | ushort | 1 | 2字节 | 2字节 |
| 速度间隔 | nPulseInterval | ushort | 1 | 2字节 | 2字节 |
| 速度间隔 | nUnpushFruitCount | ushort | 1 | 2字节 | 2字节 |
| 设备状态 | nNetState | quint8 | 1 | 1字节 | 1字节 |
| 设备状态 | nWeightSetting | quint8 | 1 | 1字节 | 1字节 |
| 设备状态 | nSCMState | quint8 | 1 | 1字节 | 1字节 |
| 设备状态 | nIQSNetState | quint8 | 1 | 1字节 | 1字节 |
| 设备状态 | nLockState | quint8 | 1 | 1字节 | 1字节 |
| 出口统计 | ExitBoxNum | int | 20 | 4字节 | 80字节 |
| 分选基准 | fSelectBasisRange | StRange | 16 | 8字节 | 128字节 |

**总计**: **3620字节**

---

## 48项目 vs HarmonyOS项目对比

| 项目 | 命令ID | 结构体名称 | 字段数量 | 数据体大小 | 使用情况 |
|------|--------|------------|----------|------------|----------|
| 48项目 | `0x0001` | `StStatistics` | 22个字段 | 3620字节 | ✅ 使用 |
| HarmonyOS项目 | `0x0001` | `StStatistics` | 22个字段 | 3620字节 | ✅ 使用 |

### 字段差异说明

1. **类型差异**（根据编译选项）：
   - `nNetState`: 48项目可能是 `quint8` 或 `ushort`（根据LS8编译选项）
   - `nWeightSetting`: 48项目可能是 `quint8` 或 `ushort`（根据LS8编译选项）
   - `nSCMState`: 48项目可能是 `quint8` 或 `int`（根据L64编译选项）
   - `nIQSNetState`: 48项目可能是 `quint8` 或 `ushort`（根据L64/LS8编译选项）

2. **HarmonyOS项目**：
   - 统一使用固定类型，简化处理
   - `nNetState`: `number` (1字节)
   - `nWeightSetting`: `number` (1字节)
   - `nSCMState`: `number` (1字节)
   - `nIQSNetState`: `number` (1字节)

---

## 数据使用场景

### 在HarmonyOS项目中的使用

1. **实时统计页面** (`RealtimeStatsContent.ets`):
   - 使用 `nGradeCount[]` 显示品质统计柱状图
   - 使用 `nGradeCount[]` 计算外观品质饼图占比
   - 使用 `nExitCount[]` 显示出口产量对比

2. **主页分选信息卡片** (`SortingInfoCard.ets`):
   - 使用 `nIntervalSumperminute` 显示分选速度
   - 使用 `nTotalCount` 显示本批个数
   - 使用 `nWeightCount` 显示本批重量
   - 使用 `nPulseInterval` 显示间隔速度

3. **顶部状态栏** (`TopStatusBar.ets`):
   - 使用 `nTotalCount` 显示总个数
   - 使用 `nWeightCount` 显示总重量
   - 使用计算后的平均果重显示平均重量

4. **等级表和等级统计表** (`HomeDataManager.ets`):
   - 使用 `nGradeCount[]` 更新等级表数据
   - 使用 `nWeightGradeCount[]` 更新等级统计表数据

---

## 数据更新频率

- **发送频率**: 下位机（FSM）定期发送，通常每几秒发送一次
- **接收处理**: HarmonyOS应用通过TCP服务器接收并实时更新UI

---

## 注意事项

1. **字节序**: 所有数据采用**小端字节序**（Little-Endian）
2. **数组索引**: 等级数组的索引计算方式为 `品质等级索引 × 16 + 尺寸等级索引`
3. **状态位**: `nCupState` 和 `nNetState` 使用位标志，需要按位解析
4. **数据类型**: `ulong` 在C++中为8字节，在TypeScript中对应 `number`（但实际解析时按8字节处理）

