import { Table, Field, FieldType } from '../orm';
import { GetIBestORM } from '../orm';

/**
 * 水果加工信息数据模型类
 * 用于存储水果加工过程的统计信息（重量百分比、分选效率百分比）
 * 对应数据库表：tb_fruitprocessinfo
 * 对应48项目：tb_fruitprocessinfo
 * 
 * 注意：RealWeightCountPercent 和 SeparationEfficiencyPercent 在48项目中是blob类型
 * 在SQLite中，blob通常存储为BLOB类型，但在ORM中可以使用TEXT类型存储JSON字符串
 */
@Table({ name: 'tb_fruitprocessinfo' })
export class FruitProcessInfo {
  @Field({ type: FieldType.INTEGER, tag: ['primaryKey', 'autoIncrement', 'notNull'] })
  FID?: number;

  @Field({ type: FieldType.INTEGER })
  CustomerID?: number;

  /**
   * 实际重量计数百分比（blob类型，存储为JSON字符串）
   * 格式：JSON数组，例如：[0.1, 0.2, 0.3, ...]
   */
  @Field({ type: FieldType.TEXT })
  RealWeightCountPercent?: string;

  /**
   * 分选效率百分比（blob类型，存储为JSON字符串）
   * 格式：JSON数组，例如：[0.85, 0.90, 0.88, ...]
   */
  @Field({ type: FieldType.TEXT })
  SeparationEfficiencyPercent?: string;

  constructor(data?: Partial<FruitProcessInfo>) {
    // 设置默认值
    this.RealWeightCountPercent = '[]';
    this.SeparationEfficiencyPercent = '[]';
    
    // 从 data 复制属性（ArkTS 兼容方式）
    if (data) {
      if (data.FID !== undefined) this.FID = data.FID;
      if (data.CustomerID !== undefined) this.CustomerID = data.CustomerID;
      if (data.RealWeightCountPercent !== undefined) this.RealWeightCountPercent = data.RealWeightCountPercent;
      if (data.SeparationEfficiencyPercent !== undefined) this.SeparationEfficiencyPercent = data.SeparationEfficiencyPercent;
    }
  }

  /**
   * 将RealWeightCountPercent从JSON字符串解析为数组
   */
  getRealWeightCountPercentArray(): number[] {
    try {
      if (!this.RealWeightCountPercent || this.RealWeightCountPercent === '') {
        return [];
      }
      return JSON.parse(this.RealWeightCountPercent) as number[];
    } catch (error) {
      console.error('解析RealWeightCountPercent失败:', error);
      return [];
    }
  }

  /**
   * 将RealWeightCountPercent数组转换为JSON字符串
   */
  setRealWeightCountPercentArray(values: number[]): void {
    try {
      this.RealWeightCountPercent = JSON.stringify(values);
    } catch (error) {
      console.error('序列化RealWeightCountPercent失败:', error);
      this.RealWeightCountPercent = '[]';
    }
  }

  /**
   * 将SeparationEfficiencyPercent从JSON字符串解析为数组
   */
  getSeparationEfficiencyPercentArray(): number[] {
    try {
      if (!this.SeparationEfficiencyPercent || this.SeparationEfficiencyPercent === '') {
        return [];
      }
      return JSON.parse(this.SeparationEfficiencyPercent) as number[];
    } catch (error) {
      console.error('解析SeparationEfficiencyPercent失败:', error);
      return [];
    }
  }

  /**
   * 将SeparationEfficiencyPercent数组转换为JSON字符串
   */
  setSeparationEfficiencyPercentArray(values: number[]): void {
    try {
      this.SeparationEfficiencyPercent = JSON.stringify(values);
    } catch (error) {
      console.error('序列化SeparationEfficiencyPercent失败:', error);
      this.SeparationEfficiencyPercent = '[]';
    }
  }

  private static indexesCreated: boolean = false;

  /**
   * 创建索引以优化查询性能
   */
  static createIndexes(): void {
    if (FruitProcessInfo.indexesCreated) {
      return;
    }
    
    try {
      const db = GetIBestORM();
      const core = db.GetCore();
      const tableName = 'tb_fruitprocessinfo';
      
      if (!core) {
        console.error('FruitProcessInfo: RdbStore未初始化，无法创建索引');
        return;
      }

      const indexColumns = [
        'customer_id'
      ];
      
      indexColumns.forEach(col => {
        core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_${col} ON ${tableName}(${col});`);
      });
      
      core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_f_id_desc ON ${tableName}(f_id DESC);`);
      
      FruitProcessInfo.indexesCreated = true;
      console.log('FruitProcessInfo 索引创建完成');
    } catch (error) {
      console.error('创建FruitProcessInfo索引失败:', error);
    }
  }
}

