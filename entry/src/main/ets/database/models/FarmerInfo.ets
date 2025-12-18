 import { Table, Field, FieldType, Model, HasMany } from '../orm';
import { GetIBestORM } from '../orm';
import { ProcessingTask } from './ProcessingTask';

/**
 * 农户/工厂信息数据模型类
 * 用于存储农户基础档案信息（静态数据）
 * 对应数据库表：tb_farmer_info
 */
@Table({ name: 'tb_farmer_info' })
export class FarmerInfo extends Model {

  /**
   * 工厂ID (主键)
   */
  @Field({ type: FieldType.INTEGER, tag: ['primaryKey', 'autoIncrement', 'notNull'] })
  FarmerID?: number;

  /**
   * 农户/工厂名称
   */
  @Field({ type: FieldType.TEXT, tag: ['notNull'] })
  FarmerName?: string;

  /**
   * 联系电话
   */
  @Field({ type: FieldType.TEXT })
  FarmerPhone?: string;

  /**
   * 地址
   */
  @Field({ type: FieldType.TEXT })
  FarmerAddress?: string;

  /**
   * 创建时间
   */
  @Field({ type: FieldType.TEXT, tag: ['autoCreateTime'] })
  FarmerCreateAt?: string;

  /**
   * 关联：一个农户拥有多个加工任务
   */
  @HasMany({ target: () => ProcessingTask, foreignKey: 'FarmerID' })
  Tasks?: ProcessingTask[];

  constructor(data?: Partial<FarmerInfo>) {
    super();
    if (data) {
      this.FarmerID = data.FarmerID;
      this.FarmerName = data.FarmerName;
      this.FarmerPhone = data.FarmerPhone;
      this.FarmerAddress = data.FarmerAddress;
      this.FarmerCreateAt = data.FarmerCreateAt;
    }
  }

  // 静态标志：记录索引是否已创建
  private static indexesCreated: boolean = false;

  /**
   * 创建索引以优化查询性能
   */
  static createIndexes(): void {
    if (FarmerInfo.indexesCreated) {
      return;
    }
    
    try {
      const db = GetIBestORM();
      const core = db.GetCore();
      const tableName = 'tb_farmer_info';
      
      if (!core) {
        console.error('FarmerInfo: RdbStore未初始化，无法创建索引');
        return;
      }

      // 常用查询索引
      const indexColumns = [
        'farmer_name',
        'farmer_phone'
      ];
      
      indexColumns.forEach(col => {
        core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_${col} ON ${tableName}(${col});`);
      });
      
      // 主键倒序
      core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_farmer_id_desc ON ${tableName}(farmer_id DESC);`);
      
      FarmerInfo.indexesCreated = true;
      console.log('FarmerInfo 索引创建完成');
    } catch (error) {
      console.error('创建FarmerInfo索引失败:', error);
    }
  }
}
