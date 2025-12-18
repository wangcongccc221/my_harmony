import { Table, Field, FieldType } from '../orm';
import { GetIBestORM } from '../orm';

/**
 * 故障信息数据模型类
 * 用于存储实际发生的故障记录
 * 对应数据库表：tb_faultinfo
 * 对应48项目：tb_FaultInfo
 */
@Table({ name: 'tb_faultinfo' })
export class FaultInfo {
  @Field({ type: FieldType.INTEGER, tag: ['primaryKey', 'autoIncrement', 'notNull'] })
  FID?: number;

  @Field({ type: FieldType.INTEGER })
  FType?: number; // 0=硬件类, 1=电气类

  @Field({ type: FieldType.TEXT })
  FCode?: string;

  @Field({ type: FieldType.TEXT })
  FName?: string;

  @Field({ type: FieldType.TEXT })
  FMessage?: string;

  @Field({ type: FieldType.INTEGER })
  FStatus?: number; // 0=故障中, 1=故障已修复

  @Field({ type: FieldType.TEXT })
  FBeginDate?: string;

  @Field({ type: FieldType.TEXT })
  FEndDate?: string;

  constructor(data?: Partial<FaultInfo>) {
    // 设置默认值
    this.FType = 0;
    this.FStatus = 0;
    
    // 从 data 复制属性（ArkTS 兼容方式）
    if (data) {
      if (data.FID !== undefined) this.FID = data.FID;
      if (data.FType !== undefined) this.FType = data.FType;
      if (data.FCode !== undefined) this.FCode = data.FCode;
      if (data.FName !== undefined) this.FName = data.FName;
      if (data.FMessage !== undefined) this.FMessage = data.FMessage;
      if (data.FStatus !== undefined) this.FStatus = data.FStatus;
      if (data.FBeginDate !== undefined) this.FBeginDate = data.FBeginDate;
      if (data.FEndDate !== undefined) this.FEndDate = data.FEndDate;
    }
  }

  private static indexesCreated: boolean = false;

  /**
   * 创建索引以优化查询性能
   */
  static createIndexes(): void {
    if (FaultInfo.indexesCreated) {
      return;
    }
    
    try {
      const db = GetIBestORM();
      const core = db.GetCore();
      const tableName = 'tb_faultinfo';
      
      if (!core) {
        console.error('FaultInfo: RdbStore未初始化，无法创建索引');
        return;
      }

      const indexColumns = [
        'f_type',
        'f_code',
        'f_status',
        'f_begin_date',
        'f_end_date'
      ];
      
      indexColumns.forEach(col => {
        core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_${col} ON ${tableName}(${col});`);
      });
      
      // 复合索引：按故障类型和状态查询
      core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_type_status ON ${tableName}(f_type, f_status);`);
      
      // 时间范围查询索引
      core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_begin_end_date ON ${tableName}(f_begin_date, f_end_date);`);
      
      core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_f_id_desc ON ${tableName}(f_id DESC);`);
      
      FaultInfo.indexesCreated = true;
      console.log('FaultInfo 索引创建完成');
    } catch (error) {
      console.error('创建FaultInfo索引失败:', error);
    }
  }
}

