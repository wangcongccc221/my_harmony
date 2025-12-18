import { Table, Field, FieldType } from '../orm';
import { GetIBestORM } from '../orm';

/**
 * 系统配置数据模型类
 * 用于存储系统配置参数（键值对形式）
 * 对应数据库表：tb_sys_configs
 * 对应48项目：tb_Sys_Configs
 * 
 * 这是48项目中非常重要的表，用于存储各种系统配置参数
 */
@Table({ name: 'tb_sys_configs' })
export class SysConfigs {
  @Field({ type: FieldType.INTEGER, tag: ['primaryKey', 'autoIncrement', 'notNull'] })
  FID?: number;

  @Field({ type: FieldType.TEXT, tag: ['notNull'] })
  FModuleName?: string; // 模块名称，默认'RSS'

  @Field({ type: FieldType.TEXT, tag: ['notNull'] })
  FType?: string; // 配置类型（键）

  @Field({ type: FieldType.TEXT })
  FValue?: string; // 配置值（值）

  @Field({ type: FieldType.TEXT })
  FCreateDate?: string;

  @Field({ type: FieldType.TEXT })
  FModifyDate?: string;

  @Field({ type: FieldType.INTEGER })
  FVisible?: number; // 是否可见，0=不可见, 1=可见

  constructor(data?: Partial<SysConfigs>) {
    // 设置默认值
    this.FModuleName = 'RSS';
    this.FVisible = 0;
    
    // 从 data 复制属性（ArkTS 兼容方式）
    if (data) {
      if (data.FID !== undefined) this.FID = data.FID;
      if (data.FModuleName !== undefined) this.FModuleName = data.FModuleName;
      if (data.FType !== undefined) this.FType = data.FType;
      if (data.FValue !== undefined) this.FValue = data.FValue;
      if (data.FCreateDate !== undefined) this.FCreateDate = data.FCreateDate;
      if (data.FModifyDate !== undefined) this.FModifyDate = data.FModifyDate;
      if (data.FVisible !== undefined) this.FVisible = data.FVisible;
    }
  }

  private static indexesCreated: boolean = false;

  /**
   * 创建索引以优化查询性能
   */
  static createIndexes(): void {
    if (SysConfigs.indexesCreated) {
      return;
    }
    
    try {
      const db = GetIBestORM();
      const core = db.GetCore();
      const tableName = 'tb_sys_configs';
      
      if (!core) {
        console.error('SysConfigs: RdbStore未初始化，无法创建索引');
        return;
      }

      const indexColumns = [
        'f_module_name',
        'f_type',
        'f_visible'
      ];
      
      indexColumns.forEach(col => {
        core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_${col} ON ${tableName}(${col});`);
      });
      
      // 复合索引：按模块名称和配置类型查询（最常用的查询方式）
      core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_module_type ON ${tableName}(f_module_name, f_type);`);
      
      // 复合索引：按模块名称和可见性查询
      core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_module_visible ON ${tableName}(f_module_name, f_visible);`);
      
      core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_f_id_desc ON ${tableName}(f_id DESC);`);
      
      SysConfigs.indexesCreated = true;
      console.log('SysConfigs 索引创建完成');
    } catch (error) {
      console.error('创建SysConfigs索引失败:', error);
    }
  }
}

