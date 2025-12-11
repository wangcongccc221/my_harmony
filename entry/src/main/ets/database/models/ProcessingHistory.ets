import { Table, Field, FieldType, Model } from '../orm';
import { GetIBestORM } from '../orm';

/**
 * 历史加工数据模型类
 * 用于存储加工历史记录
 * 基于CSV字段清单设计，共20个字段
 */
@Table
export class ProcessingHistory extends Model {
  // 注意：ID、CreatedAt、UpdatedAt 由 Model 基类自动提供

  /**
   * 客户ID（关联tb_fruitinfo）
   */
  @Field({ type: FieldType.INTEGER, tag: ['notNull'] })
  CustomerID?: number;

  /**
   * 客户名称
   */
  @Field({ type: FieldType.TEXT, tag: ['notNull'] })
  CustomerName?: string;

  /**
   * 农场名称
   */
  @Field({ type: FieldType.TEXT, tag: ['notNull'] })
  FarmName?: string;

  /**
   * 水果名称/品种
   */
  @Field({ type: FieldType.TEXT, tag: ['notNull'] })
  FruitName?: string;

  /**
   * 状态（已完成/进行中/待开始）- 计算字段
   */
  @Field({ type: FieldType.TEXT, tag: ['notNull'] })
  Status?: string;

  /**
   * 开始时间（格式：YYYY-MM-DD HH:mm:ss）
   */
  @Field({ type: FieldType.TEXT, tag: ['notNull'] })
  StartTime?: string;

  /**
   * 结束时间（格式：YYYY-MM-DD HH:mm:ss）
   */
  @Field({ type: FieldType.TEXT })
  EndTime?: string;

  /**
   * 总重量（单位：克或千克）
   */
  @Field({ type: FieldType.REAL, tag: ['notNull'] })
  Weight?: number;

  /**
   * 总数量（个）
   */
  @Field({ type: FieldType.INTEGER, tag: ['notNull'] })
  Quantity?: number;

  /**
   * 批次号（用于追溯和查询）
   */
  @Field({ type: FieldType.TEXT })
  BatchNo?: string;

  /**
   * 订单ID（关联订单系统）
   */
  @Field({ type: FieldType.INTEGER })
  OrderID?: number;

  /**
   * 使用的分选程序名称
   */
  @Field({ type: FieldType.TEXT })
  ProgramName?: string;

  /**
   * 通道数量
   */
  @Field({ type: FieldType.INTEGER })
  ChannelNum?: number;

  /**
   * 出口总数
   */
  @Field({ type: FieldType.INTEGER })
  ExportSum?: number;

  /**
   * 品质等级总数
   */
  @Field({ type: FieldType.INTEGER })
  QualityGradeSum?: number;

  /**
   * 重量/尺寸等级总数
   */
  @Field({ type: FieldType.INTEGER })
  WeightOrSizeGradeSum?: number;

  /**
   * 完成状态
   */
  @Field({ type: FieldType.TEXT })
  CompletedState?: string;

  constructor(data?: Partial<ProcessingHistory>) {
    super();
    if (data) {
      this.CustomerID = data.CustomerID ?? 0;
      this.CustomerName = data.CustomerName;
      this.FarmName = data.FarmName;
      this.FruitName = data.FruitName;
      this.Status = data.Status;
      this.StartTime = data.StartTime;
      this.EndTime = data.EndTime;
      this.Weight = data.Weight ?? 0;
      this.Quantity = data.Quantity ?? 0;
      this.BatchNo = data.BatchNo;
      this.OrderID = data.OrderID ?? 0;
      this.ProgramName = data.ProgramName;
      this.ChannelNum = data.ChannelNum ?? 0;
      this.ExportSum = data.ExportSum ?? 0;
      this.QualityGradeSum = data.QualityGradeSum ?? 0;
      this.WeightOrSizeGradeSum = data.WeightOrSizeGradeSum ?? 0;
      this.CompletedState = data.CompletedState;
    }
  }

  // 静态标志：记录索引是否已创建（性能优化：避免重复执行）
  private static indexesCreated: boolean = false;

  /**
   * 创建索引以优化查询性能
   * 应该在表创建后调用一次（带缓存机制，避免重复执行）
   */
  static createIndexes(): void {
    // 性能优化：如果索引已创建，直接返回
    if (ProcessingHistory.indexesCreated) {
      return;
    }
    
    try {
      const db = GetIBestORM();
      const core = db.GetCore();
      const tableName = 'processing_history';
      
      if (!core) {
        console.error('ProcessingHistory: RdbStore未初始化，无法创建索引');
        return;
      }
      // 创建索引（根据CSV文件中的索引字段）
      const indexColumns = [
        'customer_id',      // CustomerID
        'customer_name',    // CustomerName
        'farm_name',        // FarmName
        'fruit_name',       // FruitName
        'status',           // Status
        'start_time',       // StartTime
        'end_time',         // EndTime
        'batch_no',         // BatchNo
        'order_id',         // OrderID
        'created_at'        // CreatedAt
      ];
      
      for (let i = 0; i < indexColumns.length; i++) {
        const col = indexColumns[i];
        core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_${col} ON ${tableName}(${col});`);
      }
      
      // ID降序索引（用于获取最新记录）
      core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_id_desc ON ${tableName}(id DESC);`);
      
      // 标记为已创建
      ProcessingHistory.indexesCreated = true;
      console.log('ProcessingHistory 索引创建完成');
    } catch (error) {
      console.error('创建ProcessingHistory索引失败:', error);
    }
  }
}

