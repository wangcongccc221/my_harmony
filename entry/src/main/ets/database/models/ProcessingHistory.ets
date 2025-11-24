import { Table, Field, FieldType, Model } from '../orm';
import { GetIBestORM } from '../orm';

/**
 * 历史加工数据模型类
 * 用于存储加工历史记录
 */
@Table
export class ProcessingHistory extends Model {
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
   * 水果名称
   */
  @Field({ type: FieldType.TEXT, tag: ['notNull'] })
  FruitName?: string;

  /**
   * 状态
   */
  @Field({ type: FieldType.TEXT, tag: ['notNull'] })
  Status?: string;

  /**
   * 开始时间
   */
  @Field({ type: FieldType.TEXT, tag: ['notNull'] })
  StartTime?: string;

  /**
   * 结束时间
   */
  @Field({ type: FieldType.TEXT })
  EndTime?: string;

  /**
   * 重量（单位：克或千克）
   */
  @Field({ type: FieldType.REAL })
  Weight?: number;

  /**
   * 数量
   */
  @Field({ type: FieldType.INTEGER })
  Quantity?: number;

  constructor(
    customerName?: string,
    farmName?: string,
    fruitName?: string,
    status?: string,
    startTime?: string,
    endTime?: string,
    weight?: number,
    quantity?: number
  ) {
    super();
    this.CustomerName = customerName;
    this.FarmName = farmName;
    this.FruitName = fruitName;
    this.Status = status;
    this.StartTime = startTime;
    this.EndTime = endTime;
    this.Weight = weight;
    this.Quantity = quantity;
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
      const cols = ['start_time','end_time','customer_name','farm_name','fruit_name','status'];
      for (let i = 0; i < cols.length; i++) {
        const col = cols[i];
        core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_${col} ON ${tableName}(${col});`);
      }
      core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_id_desc ON ${tableName}(id DESC);`);
      
      // 标记为已创建
      ProcessingHistory.indexesCreated = true;
      console.log('ProcessingHistory 索引创建完成');
    } catch (error) {
      console.error('创建ProcessingHistory索引失败:', error);
    }
  }
}

