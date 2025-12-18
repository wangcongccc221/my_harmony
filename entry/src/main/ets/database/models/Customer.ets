import { Table, Field, FieldType } from '../orm';
import { GetIBestORM } from '../orm';

/**
 * 客户数据模型类
 * 用于存储客户/用户信息
 * 对应数据库表：tb_customer
 * 对应48项目：tb_Customer
 */
@Table({ name: 'tb_customer' })
export class Customer {
  @Field({ type: FieldType.INTEGER, tag: ['primaryKey', 'autoIncrement', 'notNull'] })
  FID?: number;

  @Field({ type: FieldType.TEXT })
  FName?: string;

  @Field({ type: FieldType.TEXT })
  FPassWord?: string;

  @Field({ type: FieldType.TEXT })
  FCode?: string;

  @Field({ type: FieldType.TEXT })
  FCreateDate?: string;

  @Field({ type: FieldType.TEXT })
  FIsUse?: string;

  constructor(data?: Partial<Customer>) {
    // 设置默认值
    this.FIsUse = '0';
    
    // 从 data 复制属性（ArkTS 兼容方式）
    if (data) {
      if (data.FID !== undefined) this.FID = data.FID;
      if (data.FName !== undefined) this.FName = data.FName;
      if (data.FPassWord !== undefined) this.FPassWord = data.FPassWord;
      if (data.FCode !== undefined) this.FCode = data.FCode;
      if (data.FCreateDate !== undefined) this.FCreateDate = data.FCreateDate;
      if (data.FIsUse !== undefined) this.FIsUse = data.FIsUse;
    }
  }

  private static indexesCreated: boolean = false;

  /**
   * 创建索引以优化查询性能
   */
  static createIndexes(): void {
    if (Customer.indexesCreated) {
      return;
    }
    
    try {
      const db = GetIBestORM();
      const core = db.GetCore();
      const tableName = 'tb_customer';
      
      if (!core) {
        console.error('Customer: RdbStore未初始化，无法创建索引');
        return;
      }

      const indexColumns = [
        'f_code',
        'f_name',
        'f_is_use',
        'f_create_date'
      ];
      
      indexColumns.forEach(col => {
        core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_${col} ON ${tableName}(${col});`);
      });
      
      core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_f_id_desc ON ${tableName}(f_id DESC);`);
      
      Customer.indexesCreated = true;
      console.log('Customer 索引创建完成');
    } catch (error) {
      console.error('创建Customer索引失败:', error);
    }
  }
}

