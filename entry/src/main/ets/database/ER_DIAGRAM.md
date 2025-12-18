# 数据库ER图

## 实体关系图（文本版）

```
┌─────────────────────────────────────────────────────────────────┐
│                         tb_fruitinfo                            │
│                      (水果信息表 - 主表)                         │
├─────────────────────────────────────────────────────────────────┤
│ PK │ CustomerID        │ INTEGER │ 主键，自增                  │
│    │ SysID             │ INTEGER │                             │
│    │ FeedPortID        │ INTEGER │                             │
│    │ MajorCustomerID   │ INTEGER │                             │
│    │ FBatchNo          │ TEXT    │                             │
│    │ OrderID           │ INTEGER │                             │
│    │ ChainIdx          │ TEXT    │                             │
│    │ CustomerName      │ TEXT    │                             │
│    │ FarmName          │ TEXT    │                             │
│    │ FruitName         │ TEXT    │                             │
│    │ StartTime         │ TEXT    │                             │
│    │ EndTime           │ TEXT    │                             │
│    │ StartedState      │ TEXT    │                             │
│    │ CompletedState    │ TEXT    │                             │
│    │ BatchWeight       │ REAL    │                             │
│    │ BatchNumber       │ INTEGER │                             │
│    │ SortType          │ INTEGER │                             │
│    │ SystemNum         │ INTEGER │                             │
│    │ SizeIDNum         │ INTEGER │                             │
│    │ ChannelNum        │ INTEGER │                             │
│    │ QualityGradeSum   │ INTEGER │                             │
│    │ WeightOrSizeGradeSum │ INTEGER │                         │
│    │ ColorGradeName    │ TEXT    │                             │
│    │ ShapeGradeName    │ TEXT    │                             │
│    │ FlawGradeName     │ TEXT    │                             │
│    │ HardGradeName     │ TEXT    │                             │
│    │ DensityGradeName  │ TEXT    │                             │
│    │ SugarDegreeGradeName │ TEXT │                             │
│    │ ExportSum         │ INTEGER │                             │
│    │ ProgramName       │ TEXT    │                             │
└─────────────────────────────────────────────────────────────────┘
         │
         │ 1
         │
         │ CustomerID (外键关联)
         │
         ├─────────────────┬─────────────────┐
         │                 │                 │
         │ N                │ N                │ N
         │                 │                 │
    ┌────▼────┐      ┌────▼────┐      ┌────▼────┐
    │tb_gradeinfo│    │tb_exportinfo│  │processing_history│
    │(等级信息表) │    │(导出信息表) │  │(历史加工数据表)   │
    ├───────────┤    ├───────────┤    ├──────────────────┤
    │PK│FID     │    │PK│FID     │    │PK│ID              │
    │FK│CustomerID│   │FK│CustomerID│  │FK│CustomerID      │
    │  │ChannelID │   │  │ChannelID │  │  │CustomerName    │
    │  │QualityIndex│ │  │ExportID  │  │  │FarmName        │
    │  │SizeID    │   │  │FruitNumber│ │  │FruitName       │
    │  │SizeIndex │   │  │FruitWeight│ │  │Status          │
    │  │BoxNumber │   │  │BoxNumber  │ │  │StartTime       │
    │  │BoxWeight │   │  │ExitName   │ │  │EndTime         │
    │  │FruitNumber│  │             │  │  │Weight          │
    │  │FruitWeight│  │             │  │  │Quantity        │
    │  │FPrice    │   │             │  │  │BatchNo         │
    │  │GradeID   │   │             │  │  │OrderID         │
    │  │QualityName│  │             │  │  │ProgramName     │
    │  │WeightOrSizeName│          │  │  │ChannelNum      │
    │  │WeightOrSizeLimit│         │  │  │ExportSum       │
    │  │SelectWeightOrSize│        │  │  │QualityGradeSum │
    │  │TraitWeightOrSize│         │  │  │WeightOrSizeGradeSum│
    │  │TraitColor │   │             │  │  │CompletedState  │
    │  │TraitShape │   │             │  │  │CreatedAt       │
    │  │TraitFlaw  │   │             │  │  │UpdatedAt       │
    │  │TraitHard  │   │             │  │                  │
    │  │TraitDensity│ │             │  │                  │
    │  │TraitSugarDegree│           │  │                  │
    └───────────┘    └───────────┘    └──────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                      tb_farmer_info                             │
│                    (农户/工厂信息表)                             │
├─────────────────────────────────────────────────────────────────┤
│ PK │ FarmerID         │ INTEGER │ 主键，自增                  │
│    │ FarmerName       │ TEXT    │                             │
│    │ FarmerPhone      │ TEXT    │                             │
│    │ FarmerAddress    │ TEXT    │                             │
│    │ FarmerCreateAt   │ TEXT    │                             │
│    │ ID               │ INTEGER │ (继承自Model)               │
│    │ CreatedAt        │ TEXT    │ (继承自Model)               │
│    │ UpdatedAt        │ TEXT    │ (继承自Model)               │
└─────────────────────────────────────────────────────────────────┘
         │
         │ 1
         │
         │ FarmerID (外键关联)
         │
         │ N
         │
    ┌────▼────┐
    │tb_processing_task│
    │(加工任务表)       │
    ├──────────────────┤
    │PK│TaskID         │
    │FK│FarmerID       │
    │  │CustomerName   │
    │  │FruitName      │
    │  │TotalWeight    │
    │  │Status         │
    │  │BoundOrderID   │
    │  │CreatedAt      │
    │  │ID             │ (继承自Model)
    │  │UpdatedAt      │ (继承自Model)
    └──────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                      tb_alarm_info                              │
│                      (告警信息表)                                │
├─────────────────────────────────────────────────────────────────┤
│ PK │ AlarmID          │ INTEGER │ 主键，自增                  │
│    │ AlarmStartTime   │ TEXT    │                             │
│    │ AlarmEndTime     │ TEXT    │                             │
│    │ AlarmType        │ TEXT    │                             │
│    │ AlarmGrade       │ TEXT    │                             │
│    │ AlarmMsg         │ TEXT    │                             │
│    │ ID               │ INTEGER │ (继承自Model)               │
│    │ CreatedAt        │ TEXT    │ (继承自Model)               │
│    │ UpdatedAt        │ TEXT    │ (继承自Model)               │
└─────────────────────────────────────────────────────────────────┘
         │
         │ (独立表，无外键关联)
         │
```

## 表关系说明

### 1. 核心业务表关系
- **tb_fruitinfo** (水果信息) ← 1:N → **tb_gradeinfo** (等级信息)
  - 关系：一个水果加工记录可以有多个等级分类
  - 外键：GradeInfo.CustomerID → FruitInfo.CustomerID

- **tb_fruitinfo** (水果信息) ← 1:N → **tb_exportinfo** (导出信息)
  - 关系：一个水果加工记录可以有多个出口导出
  - 外键：ExportInfo.CustomerID → FruitInfo.CustomerID

- **tb_fruitinfo** (水果信息) ← 1:N → **processing_history** (历史加工数据)
  - 关系：一个水果加工记录对应一条历史记录
  - 外键：ProcessingHistory.CustomerID → FruitInfo.CustomerID

### 2. 农户任务关系
- **tb_farmer_info** (农户信息) ← 1:N → **tb_processing_task** (加工任务)
  - 关系：一个农户可以有多个加工任务
  - 外键：ProcessingTask.FarmerID → FarmerInfo.FarmerID
  - **已定义ORM关系**：@HasMany / @BelongsTo

### 3. 独立表
- **tb_alarm_info** (告警信息)
  - 独立表，无外键关联

## 发现的问题和缺失

### ⚠️ 问题1：外键约束缺失
- **GradeInfo.CustomerID** → FruitInfo.CustomerID (无外键约束)
- **ExportInfo.CustomerID** → FruitInfo.CustomerID (无外键约束)
- **ProcessingHistory.CustomerID** → FruitInfo.CustomerID (无外键约束)

**建议**：虽然ORM支持关联查询，但数据库层面没有外键约束，可能导致数据不一致。

### ⚠️ 问题2：字段命名不一致
- FruitInfo 主键是 `CustomerID`，但实际应该是"水果加工记录ID"
- GradeInfo 和 ExportInfo 都有 `CustomerID`，但含义是"关联的水果加工记录ID"
- 命名容易混淆，建议：
  - FruitInfo.CustomerID → FruitInfo.FruitID 或 ProcessingID
  - 或者明确 CustomerID 的含义

### ⚠️ 问题3：缺少关联表
- **ChannelID** 在多个表中出现（GradeInfo, ExportInfo），但没有 `tb_channel` 表
- **ExportID** 在 ExportInfo 中出现，但没有 `tb_export` 表
- **OrderID** 在多个表中出现，但没有 `tb_order` 表

### ⚠️ 问题4：数据冗余
- ProcessingHistory 和 FruitInfo 有很多重复字段（CustomerName, FarmName, FruitName等）
- 建议：ProcessingHistory 只保留 CustomerID 外键，通过关联查询获取详细信息

### ⚠️ 问题5：时间字段类型
- 所有时间字段都是 TEXT 类型，建议使用 DATETIME 或 TIMESTAMP
- 但 HarmonyOS 的 relationalStore 可能不支持，需要确认

### ⚠️ 问题6：缺少索引说明
- 虽然代码中有 createIndexes()，但ER图中没有标注哪些字段有索引

## 建议补充的表

### 1. tb_channel (通道表)
```
ChannelID (PK)
ChannelName
ChannelType
Status
CreatedAt
```

### 2. tb_export (出口表)
```
ExportID (PK)
ExportName
ExportType
Status
CreatedAt
```

### 3. tb_order (订单表)
```
OrderID (PK)
OrderNo
CustomerID (FK → tb_fruitinfo)
Status
TotalAmount
CreatedAt
```

### 4. tb_system_config (系统配置表)
```
ConfigID (PK)
ConfigKey
ConfigValue
ConfigType
UpdatedAt
```

## 完整的ER关系图（建议）

```
tb_fruitinfo (1) ──< (N) tb_gradeinfo
                └──< (N) tb_exportinfo
                └──< (N) processing_history
                └──< (N) tb_order

tb_farmer_info (1) ──< (N) tb_processing_task

tb_channel (1) ──< (N) tb_gradeinfo
            └──< (N) tb_exportinfo

tb_export (1) ──< (N) tb_exportinfo

tb_alarm_info (独立表)
```

## 总结

当前数据库设计：
- ✅ 基本业务表结构完整
- ✅ ORM关系定义清晰（FarmerInfo ↔ ProcessingTask）
- ⚠️ 缺少外键约束（数据库层面）
- ⚠️ 缺少基础数据表（Channel, Export, Order）
- ⚠️ 存在数据冗余
- ⚠️ 字段命名可能引起混淆

建议优先处理：
1. 添加基础数据表（Channel, Export, Order）
2. 明确 CustomerID 的含义或重命名
3. 考虑添加数据库层面的外键约束（如果ORM支持）

