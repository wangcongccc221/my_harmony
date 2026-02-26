# Qt vs Harmony Protocol Offset Check (MAX64)

基准：
- Qt: `C:/Users/AI008/Desktop/源文件/48/RSS/Base/interface.h`
- Harmony Native: `E:/NEW/MY_HARMONY/entry/src/main/cpp/Tcp/structures.h`
- Harmony ArkTS: `E:/NEW/MY_HARMONY/entry/src/main/ets/protocol/Structures.ets`

说明：
- 已按 Qt `MAX64` 分支对齐字段类型与布局。
- 下面偏移值来自本地 `offsetof/sizeof` 实测（Harmony C++），在“结构定义一致”前提下即为 Qt 兼容偏移。

## 1) `StGradeItemInfo`
- `sizeof = 32`
- `exit = 0`
- `nMinSize = 4`
- `sbLabelbyGrade = 30`

## 2) `StGradeInfo`
- `sizeof = 10672`
- `intervals = 0`
- `grades = 108`
- `ExitEnabled = 8300`
- `nExitSwitchNum = 8316`
- `nTagInfo = 8572`
- `ForceChannel = 10668`

## 3) `StFruitParam`
- `sizeof = 120`
- `visionParam = 0`
- `uvParam = 48`
- `nirParam = 76`
- `unWhichExit = 116` (`short`, MAX64)

## 4) `StFruitGradeInfo`
- `sizeof = 244`
- `param = 0`
- `nRouteId = 240`

## 5) `StTrackingData`
- `sizeof = 16`
- `nADFruit = 12`

## 6) `StWeightStat`
- `sizeof = 12`
- `nAD0 = 4`

## 7) `StWeightResult`
- `sizeof = 44`
- `data = 0`
- `paras = 16`
- `state = 40`

## 8) `StWaveInfo`
- `sizeof = 1032`

## 9) `StWeightBaseInfo`
- `sizeof = 16`

## 10) `StGlobalWeightBaseInfo`
- `sizeof = 32`
- `fFilterParam = 0`
- `WeightTh = 26`
- `nCupLostageThreshold = 28` (MAX64)

## 11) `StWeightGlobal`
- `sizeof = 268`
- `cFSMInfo = 12` (`quint8[30]`)
- `gweight = 44`
- `weights = 76`

## 12) `StGlobal`
- `sizeof = 29328`
- `sys = 0`
- `grade = 632`
- `gexit = 11304`
- `analogdensity = 11948`
- `motor = 28012`
- `cFSMInfo = 29292`
- `nSubsysId = 29316`
- `nNetState = 29324` (`ushort`, MAX64)
- `nFsmModule = 29327`

## 13) `StStatistics` (已对齐)
- `sizeof = 7764`
- `nWeightGradeCount = 1024`
- `nSCMState = 7084`
- `ExitWeight = 7220`
- `Notice = 7732`

