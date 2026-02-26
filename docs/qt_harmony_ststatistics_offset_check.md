# Qt vs Harmony `StStatistics` Offset Check (MAX64)

Qt source: `C:/Users/AI008/Desktop/源文件/48/RSS/Base/interface.h:9912`  
Harmony source: `E:/NEW/MY_HARMONY/entry/src/main/cpp/Tcp/structures.h:268` + `E:/NEW/MY_HARMONY/entry/src/main/ets/protocol/Structures.ets:998`

Assumption: `#pragma pack(4)`, `MAX_EXIT_NUM=64`, `WEIGHTANDSIZE` disabled.

| Field | Offset | Type |
|---|---:|---|
| `nGradeCount` | 0 | `ulong[256]` |
| `nWeightGradeCount` | 1024 | `double[256]` |
| `nExitCount` | 3072 | `ulong[64]` |
| `nExitWeightCount` | 3328 | `double[64]` |
| `nChannelTotalCount` | 3840 | `ulong[12]` |
| `nChannelWeightCount` | 3888 | `double[12]` |
| `nSubsysId` | 3984 | `int` |
| `nBoxGradeCount` | 3988 | `int[256]` |
| `nBoxGradeWeight` | 5012 | `double[256]` |
| `nTotalCupNum` | 7060 | `int` |
| `nInterval` | 7064 | `int` |
| `nIntervalSumperminute` | 7068 | `int` |
| `nCupState` | 7072 | `ushort` |
| `nPulseInterval` | 7074 | `ushort` |
| `nUnpushFruitCount` | 7076 | `ushort` |
| `nNetState` | 7078 | `ushort` |
| `nWeightSetting` | 7080 | `ushort` |
| `padding` | 7082 | 2 bytes (align `int`) |
| `nSCMState` | 7084 | `int` |
| `nIQSNetState` | 7088 | `ushort` |
| `nLockState` | 7090 | `quint8` |
| `padding` | 7091 | 1 byte (align `ushort[]`) |
| `ExitBoxNum` | 7092 | `quint16[64]` |
| `ExitWeight` | 7220 | `double[64]` |
| `Notice` | 7732 | `quint8[30]` |
| tail padding | 7762 | 2 bytes (struct align 4) |

`sizeof(StStatistics) = 7764`

