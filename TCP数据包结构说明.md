# TCP数据包结构说明

## 一、TCP数据包整体格式

TCP数据包由以下部分组成：

```
[SYNC字符串(4字节)] + [CommandHead命令头(12字节)] + [数据体(变长)]
```

### 1. SYNC字符串（4字节）
- **格式**: ASCII字符串 "SYNC"
- **字节**: `0x53 0x59 0x4E 0x43` (S=0x53, Y=0x59, N=0x4E, C=0x43)
- **用途**: 数据包同步标识，用于识别数据包开始

### 2. CommandHead命令头（12字节）
- **格式**: 小端字节序（Little-Endian）
- **结构**:
  ```
  struct CommandHead {
      int nSrcId;      // 发送源ID (4字节)
      int nDstId;      // 接收目标ID (4字节)
      int nCmdId;      // 命令ID (4字节)
  };
  ```
- **字节顺序**: 
  - 字节0-3: nSrcId (小端)
  - 字节4-7: nDstId (小端)
  - 字节8-11: nCmdId (小端)

### 3. 数据体（变长）
- 根据不同的命令ID，数据体的结构不同
- 所有整数和浮点数都使用小端字节序

---

## 二、主要结构体定义

### 1. StStatistics（实时统计信息）
**命令ID**: `FSM_CMD_STATISTICS = 0x0001`

**结构体定义**:
```cpp
struct StStatistics {
    // 等级统计（16品质 × 16尺寸 = 256个等级）
    ulong nGradeCount[256];              // 总个数 (8字节 × 256 = 2048字节)
    ulong nWeightGradeCount[256];        // 总重量 (8字节 × 256 = 2048字节)
    
    // 出口统计（最多48个出口）
    ulong nExitCount[48];                // 各个出口的水果个数 (8字节 × 48 = 384字节)
    ulong nExitWeightCount[48];          // 各个出口的重量，单位：克 (8字节 × 48 = 384字节)
    
    // 总体统计
    ulong nTotalCount;                   // 水果批个数 (8字节)
    ulong nWeightCount;                  // 水果批重量，单位：克 (8字节)
    
    // 子系统信息
    int nSubsysId;                       // 子系统id,FSM (4字节)
    
    // 箱数统计
    int nBoxGradeCount[256];             // 各个等级的箱数 (4字节 × 256 = 1024字节)
    int nBoxGradeWeight[256];            // 重量分选时的每箱重 (4字节 × 256 = 1024字节)
    
    // 其他信息
    int nTotalCupNum;                    // 总的果杯数 (4字节)
    int nInterval;                       // 与上次发送统计信息的间隔数 (4字节)
    int nIntervalSumperminute;           // 一分钟内光电开关的个数，计算分选速度 (4字节)
    ushort nCupState;                    // 12个通道的果杯状态，低12位有效 (2字节)
    ushort nPulseInterval;               // 2000以上时，分选速度为0；单位为ms (2字节)
    ushort nUnpushFruitCount;            // 遗漏的水果个数 (2字节)
    quint8 nNetState;                    // 网络状态，低6位有效，代表6个IPM (1字节)
    quint8 nWeightSetting;               // 重量整定标志 1整定完毕 0基准整定 (1字节)
    quint8 nSCMState;                    // SCM状态，0正常，1故障 (1字节)
    quint8 nIQSNetState;                 // 糖度传感器网络状态，0正常，1故障 (1字节)
    quint8 nLockState;                   // 锁定状态 (1字节)
    quint32 ExitBoxNum[48];              // 出口箱数 (4字节 × 48 = 192字节)
    StRange fSelectBasisRange[16];       // 分选基准范围 (变长，约64字节)
};
```

**总大小**: 约 1032 字节（根据平台可能略有不同）

**字节布局示例**:
```
偏移    大小    字段名
0-2047  2048    nGradeCount[256] (ulong数组)
2048-4095 2048  nWeightGradeCount[256] (ulong数组)
4096-4479 384   nExitCount[48] (ulong数组)
4480-4863 384   nExitWeightCount[48] (ulong数组)
4864-4871 8     nTotalCount (ulong)
4872-4879 8     nWeightCount (ulong)
4880-4883 4     nSubsysId (int)
4884-5907 1024  nBoxGradeCount[256] (int数组)
5908-6931 1024  nBoxGradeWeight[256] (int数组)
6932-6935 4     nTotalCupNum (int)
6936-6939 4     nInterval (int)
6940-6943 4     nIntervalSumperminute (int)
6944-6945 2     nCupState (ushort)
6946-6947 2     nPulseInterval (ushort)
6948-6949 2     nUnpushFruitCount (ushort)
6950      1     nNetState (quint8)
6951      1     nWeightSetting (quint8)
6952      1     nSCMState (quint8)
6953      1     nIQSNetState (quint8)
6954      1     nLockState (quint8)
6955-7146 192    ExitBoxNum[48] (quint32数组)
7147-...  变长   fSelectBasisRange[16] (StRange数组)
```

---

### 2. StGlobal（全局配置信息）
**命令ID**: `FSM_CMD_CONFIG = 0x0000`

**结构体定义**:
```cpp
struct StGlobal {
    StSysConfig sys;                     // 系统配置
    StGradeInfo grade;                   // 等级信息
    StGlobalExitInfo gexit;              // 全局出口信息
    StGlobalWeightBaseInfo gweight;      // 全局重量信息
    StAnalogDensity analogdensity;       // 模拟密度信息
    StExitInfo exit[12];                 // 出口信息数组（12个通道）
    StParas paras[12];                   // IPM参数信息数组（12个IPM）
    StWeightBaseInfo weights[12];        // 称重参数数组（12个通道）
    StMotorInfo motor[48];               // 出口电机信息数组（48个出口）
    quint8 cFSMInfo[12];                 // FSM编译日期
    quint8 cIPMInfo[12];                 // IPM编译日期
    int nSubsysId;                       // 子系统id,FSM
    int nVersion;                        // 版本号
    quint8 nNetState;                    // 网络状态
    quint8 nFsmRestart;                  // FSM是否重启标志
    quint8 nFsmModule;                   // FSM模块类型（DSP或STM32）
};
```

**总大小**: 约 20000+ 字节（包含多个嵌套结构体）

---

### 3. StWaveInfo（波形数据）
**命令ID**: `FSM_CMD_WAVEINFO = 0x1004`

**结构体定义**:
```cpp
struct StWaveInfo {
    int nChannelId;                      // 通道id,WM (4字节)
    ushort waveform0[256];               // 波形数据0 (AD0通道) (2字节 × 256 = 512字节)
    ushort waveform1[256];               // 波形数据1 (AD1通道) (2字节 × 256 = 512字节)
    float fruitweight;                   // 水果重量，单位：克 (4字节)
};
```

**总大小**: 1032 字节

**字节布局**:
```
偏移    大小    字段名
0-3     4       nChannelId (int)
4-515   512     waveform0[256] (ushort数组，小端)
516-1027 512    waveform1[256] (ushort数组，小端)
1028-1031 4     fruitweight (float，小端)
```

**示例数据**:
```
通道ID: 11 (0x0000000B)
waveform0[0]: 1461 (0x05B5)
waveform1[0]: 1221 (0x04C5)
fruitweight: 140.644g (IEEE 754 float)
```

---

## 三、数据类型说明

### 1. 整数类型（小端字节序）
- **int**: 4字节，有符号整数
- **ulong**: 8字节，无符号长整数（在C++中，Windows平台为8字节）
- **ushort**: 2字节，无符号短整数
- **quint8**: 1字节，无符号8位整数
- **quint32**: 4字节，无符号32位整数

### 2. 浮点数类型
- **float**: 4字节，IEEE 754单精度浮点数（小端）

### 3. 字节序转换示例

**int转字节（小端）**:
```cpp
int value = 0x12345678;
// 字节数组: [0x78, 0x56, 0x34, 0x12]
```

**ushort转字节（小端）**:
```cpp
ushort value = 0x1234;
// 字节数组: [0x34, 0x12]
```

**float转字节（IEEE 754小端）**:
```cpp
float value = 140.644f;
// 需要按照IEEE 754标准转换
```

---

## 四、完整数据包示例

### 示例1: FSM_CMD_WAVEINFO数据包

**完整数据包**:
```
[SYNC: 4字节] + [CommandHead: 12字节] + [StWaveInfo: 1032字节] = 1048字节
```

**十六进制表示**:
```
53 59 4E 43                    // SYNC字符串
01 00 00 00                    // nSrcId = 0x0001 (FSM_ID)
00 10 00 00                    // nDstId = 0x1000 (HC_ID)
04 10 00 00                    // nCmdId = 0x1004 (FSM_CMD_WAVEINFO)
0B 00 00 00                    // nChannelId = 11
B5 05 ...                      // waveform0[0] = 1461 (0x05B5)
...                            // waveform0[1-255]
C5 04 ...                      // waveform1[0] = 1221 (0x04C5)
...                            // waveform1[1-255]
[4字节float]                   // fruitweight = 140.644g
```

### 示例2: FSM_CMD_STATISTICS数据包

**完整数据包**:
```
[SYNC: 4字节] + [CommandHead: 12字节] + [StStatistics: 1032字节] = 1048字节
```

**十六进制表示**:
```
53 59 4E 43                    // SYNC字符串
01 00 00 00                    // nSrcId = 0x0001 (FSM_ID)
00 10 00 00                    // nDstId = 0x1000 (HC_ID)
01 00 00 00                    // nCmdId = 0x0001 (FSM_CMD_STATISTICS)
[1032字节的StStatistics数据]
```

---

## 五、解析流程

1. **接收SYNC**: 读取4字节，验证是否为"SYNC"
2. **解析CommandHead**: 读取12字节，解析nSrcId、nDstId、nCmdId
3. **根据nCmdId确定数据体结构**: 
   - `0x0000`: StGlobal
   - `0x0001`: StStatistics
   - `0x1004`: StWaveInfo
4. **解析数据体**: 按照对应的结构体定义，逐字段解析二进制数据
5. **字节序转换**: 所有整数和浮点数都需要从小端字节序转换为主机字节序

---

## 六、注意事项

1. **字节序**: 所有多字节数据都是小端字节序（Little-Endian）
2. **对齐**: C++结构体可能有内存对齐，实际字节布局可能与理论不同
3. **平台差异**: ulong在不同平台大小可能不同（Windows通常8字节）
4. **数组大小**: 某些数组大小可能根据编译选项变化（如MAX_EXIT_NUM）
5. **填充字节**: 结构体可能有编译器添加的填充字节，需要确认实际布局

