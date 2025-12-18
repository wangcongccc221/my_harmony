import { Table, Field, FieldType } from '../orm';
import { GetIBestORM } from '../orm';

/**
 * 基础故障数据模型类
 * 用于存储故障模板/基础故障信息
 * 对应数据库表：tb_base_fault
 * 对应48项目：tb_Base_Fault
 */
@Table({ name: 'tb_base_fault' })
export class BaseFault {
  @Field({ type: FieldType.INTEGER, tag: ['primaryKey', 'autoIncrement', 'notNull'] })
  FID?: number;

  @Field({ type: FieldType.INTEGER })
  FType?: number; // 0=硬件类, 1=电气类

  @Field({ type: FieldType.TEXT })
  FCode?: string;

  @Field({ type: FieldType.TEXT })
  FName?: string;

  @Field({ type: FieldType.TEXT })
  FGroupName?: string;

  @Field({ type: FieldType.TEXT })
  FMessage?: string;

  @Field({ type: FieldType.INTEGER })
  FShutdownCondition?: number; // 停机条件

  @Field({ type: FieldType.INTEGER })
  FDecelerationCondition?: number; // 减速条件

  @Field({ type: FieldType.INTEGER })
  FPopupCondition?: number; // 弹窗条件

  @Field({ type: FieldType.INTEGER })
  FPromptCondition?: number; // 提示条件

  @Field({ type: FieldType.TEXT })
  FCreateDate?: string;

  @Field({ type: FieldType.TEXT })
  FModifyDate?: string;

  constructor(data?: Partial<BaseFault>) {
    // 设置默认值
    this.FType = 0;
    this.FShutdownCondition = 0;
    this.FDecelerationCondition = 0;
    this.FPopupCondition = 0;
    this.FPromptCondition = 0;
    
    // 从 data 复制属性（ArkTS 兼容方式）
    if (data) {
      if (data.FID !== undefined) this.FID = data.FID;
      if (data.FType !== undefined) this.FType = data.FType;
      if (data.FCode !== undefined) this.FCode = data.FCode;
      if (data.FName !== undefined) this.FName = data.FName;
      if (data.FGroupName !== undefined) this.FGroupName = data.FGroupName;
      if (data.FMessage !== undefined) this.FMessage = data.FMessage;
      if (data.FShutdownCondition !== undefined) this.FShutdownCondition = data.FShutdownCondition;
      if (data.FDecelerationCondition !== undefined) this.FDecelerationCondition = data.FDecelerationCondition;
      if (data.FPopupCondition !== undefined) this.FPopupCondition = data.FPopupCondition;
      if (data.FPromptCondition !== undefined) this.FPromptCondition = data.FPromptCondition;
      if (data.FCreateDate !== undefined) this.FCreateDate = data.FCreateDate;
      if (data.FModifyDate !== undefined) this.FModifyDate = data.FModifyDate;
    }
  }

  private static indexesCreated: boolean = false;

  /**
   * 创建索引以优化查询性能
   */
  static createIndexes(): void {
    if (BaseFault.indexesCreated) {
      return;
    }
    
    try {
      const db = GetIBestORM();
      const core = db.GetCore();
      const tableName = 'tb_base_fault';
      
      if (!core) {
        console.error('BaseFault: RdbStore未初始化，无法创建索引');
        return;
      }

      const indexColumns = [
        'f_type',
        'f_code',
        'f_group_name'
      ];
      
      indexColumns.forEach(col => {
        core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_${col} ON ${tableName}(${col});`);
      });
      
      core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_f_id_desc ON ${tableName}(f_id DESC);`);
      
      BaseFault.indexesCreated = true;
      console.log('BaseFault 索引创建完成');
    } catch (error) {
      console.error('创建BaseFault索引失败:', error);
    }
  }
}

