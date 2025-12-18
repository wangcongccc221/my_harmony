import { Table, Field, FieldType, Model, BelongsTo } from '../orm';
import { GetIBestORM } from '../orm';
import { FarmerInfo } from './FarmerInfo';

/**
 * 加工任务数据模型类
 * 用于存储具体的业务加工记录（动态数据）
 * 对应数据库表：tb_processing_task
 */
@Table({ name: 'tb_processing_task' })
export class ProcessingTask extends Model {

  /**
   * 任务ID (主键)
   */
  @Field({ type: FieldType.INTEGER, tag: ['primaryKey', 'autoIncrement', 'notNull'] })
  TaskID?: number;

  /**
   * 关联的农户ID (外键)
   */
  @Field({ type: FieldType.INTEGER, tag: ['notNull'] })
  FarmerID?: number;

  /**
   * 关联：属于一个农户
   */
  @BelongsTo({ target: () => FarmerInfo, foreignKey: 'FarmerID' })
  Farmer?: FarmerInfo;

  /**
   * 代加工对象名称
   */
  @Field({ type: FieldType.TEXT })
  CustomerName?: string;

  /**
   * 加工水果名称
   */
  @Field({ type: FieldType.TEXT })
  FruitName?: string;

  /**
   * 加工总重量
   */
  @Field({ type: FieldType.REAL })
  TotalWeight?: number;

  /**
   * 任务状态
   */
  @Field({ type: FieldType.TEXT })
  Status?: string;

  /**
   * 绑定内部订单号
   */
  @Field({ type: FieldType.INTEGER })
  BoundOrderID?: number;

  /**
   * 创建时间
   */
  @Field({ type: FieldType.TEXT, tag: ['autoCreateTime'] })
  CreatedAt?: string;

  constructor(data?: Partial<ProcessingTask>) {
    super();
    if (data) {
      this.TaskID = data.TaskID;
      this.FarmerID = data.FarmerID;
      this.CustomerName = data.CustomerName;
      this.FruitName = data.FruitName;
      this.TotalWeight = data.TotalWeight;
      this.Status = data.Status;
      this.BoundOrderID = data.BoundOrderID;
      this.CreatedAt = data.CreatedAt;
    }
  }

  // 静态标志：记录索引是否已创建
  private static indexesCreated: boolean = false;

  /**
   * 创建索引以优化查询性能
   */
  static createIndexes(): void {
    if (ProcessingTask.indexesCreated) {
      return;
    }
    
    try {
      const db = GetIBestORM();
      const core = db.GetCore();
      const tableName = 'tb_processing_task';
      
      if (!core) {
        console.error('ProcessingTask: RdbStore未初始化，无法创建索引');
        return;
      }

      // 常用查询索引
      const indexColumns = [
        'farmer_id', // 外键查询非常频繁
        'customer_name',
        'fruit_name',
        'status',
        'created_at'
      ];
      
      indexColumns.forEach(col => {
        core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_${col} ON ${tableName}(${col});`);
      });
      
      // 主键倒序
      core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_task_id_desc ON ${tableName}(task_id DESC);`);
      
      ProcessingTask.indexesCreated = true;
      console.log('ProcessingTask 索引创建完成');
    } catch (error) {
      console.error('创建ProcessingTask索引失败:', error);
    }
  }
}
