import { Table, Field, FieldType } from '../orm';
import { GetIBestORM } from '../orm';

/**
 * 系统水果信息数据模型类
 * 用于存储每个子系统（FSM1、FSM2）的水果信息
 * 对应数据库表：tb_sys_fruitinfo
 * 对应48项目：tb_Sys_FruitInfo
 */
@Table({ name: 'tb_sys_fruitinfo' })
export class SysFruitInfo {
  @Field({ type: FieldType.INTEGER, tag: ['primaryKey', 'autoIncrement', 'notNull'] })
  FID?: number;

  @Field({ type: FieldType.INTEGER, tag: ['notNull'] })
  CustomerID?: number;

  @Field({ type: FieldType.INTEGER, tag: ['notNull'] })
  SystemID?: number;

  @Field({ type: FieldType.INTEGER })
  BatchNumber?: number;

  @Field({ type: FieldType.INTEGER })
  BatchWeight?: number;

  constructor(data?: Partial<SysFruitInfo>) {
    // 设置默认值
    this.SystemID = 0;
    this.BatchNumber = 0;
    this.BatchWeight = 0;
    
    // 从 data 复制属性（ArkTS 兼容方式）
    if (data) {
      if (data.FID !== undefined) this.FID = data.FID;
      if (data.CustomerID !== undefined) this.CustomerID = data.CustomerID;
      if (data.SystemID !== undefined) this.SystemID = data.SystemID;
      if (data.BatchNumber !== undefined) this.BatchNumber = data.BatchNumber;
      if (data.BatchWeight !== undefined) this.BatchWeight = data.BatchWeight;
    }
  }

  private static indexesCreated: boolean = false;

  /**
   * 创建索引以优化查询性能
   */
  static createIndexes(): void {
    if (SysFruitInfo.indexesCreated) {
      return;
    }
    
    try {
      const db = GetIBestORM();
      const core = db.GetCore();
      const tableName = 'tb_sys_fruitinfo';
      
      if (!core) {
        console.error('SysFruitInfo: RdbStore未初始化，无法创建索引');
        return;
      }

      const indexColumns = [
        'customer_id',
        'system_id'
      ];
      
      indexColumns.forEach(col => {
        core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_${col} ON ${tableName}(${col});`);
      });
      
      // 复合索引：按客户ID和系统ID查询
      core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_customer_system ON ${tableName}(customer_id, system_id);`);
      
      core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_f_id_desc ON ${tableName}(f_id DESC);`);
      
      SysFruitInfo.indexesCreated = true;
      console.log('SysFruitInfo 索引创建完成');
    } catch (error) {
      console.error('创建SysFruitInfo索引失败:', error);
    }
  }
}

