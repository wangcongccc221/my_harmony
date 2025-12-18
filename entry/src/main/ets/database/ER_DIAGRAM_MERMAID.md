# 数据库ER图 (Mermaid格式)

## 实体关系图

```mermaid
erDiagram
    tb_fruitinfo ||--o{ tb_gradeinfo : "1对多"
    tb_fruitinfo ||--o{ tb_exportinfo : "1对多"
    tb_fruitinfo ||--o{ processing_history : "1对多"
    tb_farmer_info ||--o{ tb_processing_task : "1对多"
    
    tb_fruitinfo {
        integer CustomerID PK "主键，自增"
        integer SysID
        integer FeedPortID
        integer MajorCustomerID
        text FBatchNo
        integer OrderID
        text ChainIdx
        text CustomerName
        text FarmName
        text FruitName
        text StartTime
        text EndTime
        text StartedState
        text CompletedState
        real BatchWeight
        integer BatchNumber
        integer SortType
        integer SystemNum
        integer SizeIDNum
        integer ChannelNum
        integer QualityGradeSum
        integer WeightOrSizeGradeSum
        text ColorGradeName
        text ShapeGradeName
        text FlawGradeName
        text HardGradeName
        text DensityGradeName
        text SugarDegreeGradeName
        integer ExportSum
        text ProgramName
    }
    
    tb_gradeinfo {
        integer FID PK "主键，自增"
        integer CustomerID FK "外键 → tb_fruitinfo.CustomerID"
        integer ChannelID "⚠️ 无关联表"
        integer QualityIndex
        integer SizeID
        integer SizeIndex
        integer BoxNumber
        real BoxWeight
        integer FruitNumber
        real FruitWeight
        real FPrice
        integer GradeID
        text QualityName
        text WeightOrSizeName
        real WeightOrSizeLimit
        text SelectWeightOrSize
        text TraitWeightOrSize
        text TraitColor
        text TraitShape
        text TraitFlaw
        text TraitHard
        text TraitDensity
        text TraitSugarDegree
    }
    
    tb_exportinfo {
        integer FID PK "主键，自增"
        integer CustomerID FK "外键 → tb_fruitinfo.CustomerID"
        integer ChannelID "⚠️ 无关联表"
        integer ExportID "⚠️ 无关联表"
        integer FruitNumber
        real FruitWeight
        integer BoxNumber
        text ExitName
    }
    
    processing_history {
        integer ID PK "主键，自增 (继承自Model)"
        integer CustomerID FK "外键 → tb_fruitinfo.CustomerID"
        text CustomerName "⚠️ 冗余字段"
        text FarmName "⚠️ 冗余字段"
        text FruitName "⚠️ 冗余字段"
        text Status
        text StartTime
        text EndTime
        real Weight
        integer Quantity
        text BatchNo
        integer OrderID "⚠️ 无关联表"
        text ProgramName
        integer ChannelNum
        integer ExportSum
        integer QualityGradeSum
        integer WeightOrSizeGradeSum
        text CompletedState
        text CreatedAt "继承自Model"
        text UpdatedAt "继承自Model"
    }
    
    tb_farmer_info {
        integer FarmerID PK "主键，自增"
        text FarmerName
        text FarmerPhone
        text FarmerAddress
        text FarmerCreateAt
        integer ID "继承自Model"
        text CreatedAt "继承自Model"
        text UpdatedAt "继承自Model"
    }
    
    tb_processing_task {
        integer TaskID PK "主键，自增"
        integer FarmerID FK "外键 → tb_farmer_info.FarmerID ✅ 已定义ORM关系"
        text CustomerName
        text FruitName
        real TotalWeight
        text Status
        integer BoundOrderID "⚠️ 无关联表"
        text CreatedAt
        integer ID "继承自Model"
        text UpdatedAt "继承自Model"
    }
    
    tb_alarm_info {
        integer AlarmID PK "主键，自增"
        text AlarmStartTime
        text AlarmEndTime
        text AlarmType
        text AlarmGrade
        text AlarmMsg
        integer ID "继承自Model"
        text CreatedAt "继承自Model"
        text UpdatedAt "继承自Model"
    }
```

## 建议补充的表（缺失）

```mermaid
erDiagram
    tb_channel ||--o{ tb_gradeinfo : "1对多"
    tb_channel ||--o{ tb_exportinfo : "1对多"
    tb_export ||--o{ tb_exportinfo : "1对多"
    tb_order ||--o{ tb_fruitinfo : "1对多"
    tb_order ||--o{ tb_processing_task : "1对多"
    
    tb_channel {
        integer ChannelID PK "主键，自增"
        text ChannelName
        text ChannelType
        text Status
        text CreatedAt
    }
    
    tb_export {
        integer ExportID PK "主键，自增"
        text ExportName
        text ExportType
        text Status
        text CreatedAt
    }
    
    tb_order {
        integer OrderID PK "主键，自增"
        text OrderNo "订单号"
        integer CustomerID FK "外键 → tb_fruitinfo.CustomerID"
        text Status "订单状态"
        real TotalAmount "总金额"
        text CreatedAt
        text UpdatedAt
    }
```

## 问题总结

### 🔴 严重问题
1. **外键约束缺失**：虽然代码中有外键字段，但数据库层面没有外键约束
2. **字段命名混淆**：`CustomerID` 在不同表中含义不同
3. **数据冗余**：ProcessingHistory 中重复存储了 FruitInfo 的字段

### 🟡 中等问题
1. **缺少基础数据表**：ChannelID, ExportID, OrderID 没有对应的主表
2. **时间字段类型**：所有时间都是 TEXT，应该考虑使用 DATETIME

### 🟢 建议优化
1. 添加基础数据表（Channel, Export, Order）
2. 明确 CustomerID 的含义或重命名
3. 减少 ProcessingHistory 的冗余字段
4. 考虑添加数据库层面的外键约束

