import { Table, Field, FieldType } from '../orm';
import { GetIBestORM } from '../orm';

/**
 * 导出信息数据模型类
 * 用于存储水果导出信息数据
 * 对应数据库表：tb_exportinfo
 */
@Table({ name: 'tb_exportinfo' })
export class ExportInfo {
  @Field({ type: FieldType.INTEGER, tag: ['primaryKey', 'autoIncrement', 'notNull'] })
  FID?: number;

  @Field({ type: FieldType.INTEGER, tag: ['notNull'] })
  CustomerID?: number;

  @Field({ type: FieldType.INTEGER, tag: ['notNull'] })
  ChannelID?: number;

  @Field({ type: FieldType.INTEGER, tag: ['notNull'] })
  ExportID?: number;

  @Field({ type: FieldType.INTEGER })
  FruitNumber?: number;

  @Field({ type: FieldType.REAL })
  FruitWeight?: number;

  @Field({ type: FieldType.INTEGER })
  BoxNumber?: number;

  @Field({ type: FieldType.TEXT })
  ExitName?: string;

  constructor(data?: Partial<ExportInfo>) {
    // 设置默认值：ChannelID、BoxNumber 默认为 0
    this.ChannelID = 0;
    this.BoxNumber = 0;
    
    if (data) {
      // 手动赋值，避免使用 Object.assign（ArkTS 限制）
      if (data.FID !== undefined) this.FID = data.FID;
      if (data.CustomerID !== undefined) this.CustomerID = data.CustomerID;
      if (data.ChannelID !== undefined) this.ChannelID = data.ChannelID;
      if (data.ExportID !== undefined) this.ExportID = data.ExportID;
      if (data.FruitNumber !== undefined) this.FruitNumber = data.FruitNumber;
      if (data.FruitWeight !== undefined) this.FruitWeight = data.FruitWeight;
      if (data.BoxNumber !== undefined) this.BoxNumber = data.BoxNumber;
      if (data.ExitName !== undefined) this.ExitName = data.ExitName;
    }
  }

  private static indexesCreated: boolean = false;

  /**
   * 创建索引以优化查询性能
   */
  static createIndexes(): void {
    if (ExportInfo.indexesCreated) {
      return;
    }
    
    try {
      const db = GetIBestORM();
      const core = db.GetCore();
      const tableName = 'tb_exportinfo';
      
      if (!core) {
        console.error('ExportInfo: RdbStore未初始化，无法创建索引');
        return;
      }

      const indexColumns = [
        'f_id',
        'customer_id',
        'channel_id',
        'export_id'
      ];
      
      indexColumns.forEach(col => {
        core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_${col} ON ${tableName}(${col});`);
      });
      
      core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_f_id_desc ON ${tableName}(f_id DESC);`);
      
      ExportInfo.indexesCreated = true;
      console.log('ExportInfo 索引创建完成');
    } catch (error) {
      console.error('创建ExportInfo索引失败:', error);
    }
  }
}

