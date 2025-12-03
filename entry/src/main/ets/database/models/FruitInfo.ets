import { Table, Field, FieldType } from '../orm';
import { GetIBestORM } from '../orm';

/**
 * 水果信息数据模型类
 * 用于存储水果加工信息数据
 * 对应数据库表：tb_fruitinfo
 */
@Table({ name: 'tb_fruitinfo' })
export class FruitInfo {
  @Field({ type: FieldType.INTEGER, tag: ['primaryKey', 'autoIncrement', 'notNull'] })
  CustomerID?: number;

  @Field({ type: FieldType.INTEGER })
  SysID?: number;

  @Field({ type: FieldType.INTEGER })
  FeedPortID?: number;

  @Field({ type: FieldType.INTEGER })
  MajorCustomerID?: number;

  @Field({ type: FieldType.TEXT })
  FBatchNo?: string;

  @Field({ type: FieldType.INTEGER })
  OrderID?: number;

  @Field({ type: FieldType.TEXT })
  ChainIdx?: string;

  @Field({ type: FieldType.TEXT })
  CustomerName?: string;

  @Field({ type: FieldType.TEXT })
  FarmName?: string;

  @Field({ type: FieldType.TEXT })
  FruitName?: string;

  @Field({ type: FieldType.TEXT })
  StartTime?: string;

  @Field({ type: FieldType.TEXT })
  EndTime?: string;

  @Field({ type: FieldType.TEXT })
  StartedState?: string;

  @Field({ type: FieldType.TEXT })
  CompletedState?: string;

  @Field({ type: FieldType.REAL })
  BatchWeight?: number;

  @Field({ type: FieldType.INTEGER })
  BatchNumber?: number;

  @Field({ type: FieldType.INTEGER, tag: ['notNull'] })
  SortType?: number;

  @Field({ type: FieldType.INTEGER })
  SystemNum?: number;

  @Field({ type: FieldType.INTEGER })
  SizeIDNum?: number;

  @Field({ type: FieldType.INTEGER })
  ChannelNum?: number;

  @Field({ type: FieldType.INTEGER })
  QualityGradeSum?: number;

  @Field({ type: FieldType.INTEGER })
  WeightOrSizeGradeSum?: number;

  @Field({ type: FieldType.TEXT })
  ColorGradeName?: string;

  @Field({ type: FieldType.TEXT })
  ShapeGradeName?: string;

  @Field({ type: FieldType.TEXT })
  FlawGradeName?: string;

  @Field({ type: FieldType.TEXT })
  HardGradeName?: string;

  @Field({ type: FieldType.TEXT })
  DensityGradeName?: string;

  @Field({ type: FieldType.TEXT })
  SugarDegreeGradeName?: string;

  @Field({ type: FieldType.INTEGER })
  ExportSum?: number;

  @Field({ type: FieldType.TEXT })
  ProgramName?: string;

  constructor(data?: Partial<FruitInfo>) {
    // 设置默认值：SysID、FeedPortID、OrderID、SortType 默认为 0
    this.SysID = 0;
    this.FeedPortID = 0;
    this.OrderID = 0;
    this.SortType = 0;
    
    if (data) {
      // 手动赋值，避免使用 Object.assign（ArkTS 限制）
      if (data.CustomerID !== undefined) this.CustomerID = data.CustomerID;
      if (data.SysID !== undefined) this.SysID = data.SysID;
      if (data.FeedPortID !== undefined) this.FeedPortID = data.FeedPortID;
      if (data.MajorCustomerID !== undefined) this.MajorCustomerID = data.MajorCustomerID;
      if (data.FBatchNo !== undefined) this.FBatchNo = data.FBatchNo;
      if (data.OrderID !== undefined) this.OrderID = data.OrderID;
      if (data.ChainIdx !== undefined) this.ChainIdx = data.ChainIdx;
      if (data.CustomerName !== undefined) this.CustomerName = data.CustomerName;
      if (data.FarmName !== undefined) this.FarmName = data.FarmName;
      if (data.FruitName !== undefined) this.FruitName = data.FruitName;
      if (data.StartTime !== undefined) this.StartTime = data.StartTime;
      if (data.EndTime !== undefined) this.EndTime = data.EndTime;
      if (data.StartedState !== undefined) this.StartedState = data.StartedState;
      if (data.CompletedState !== undefined) this.CompletedState = data.CompletedState;
      if (data.BatchWeight !== undefined) this.BatchWeight = data.BatchWeight;
      if (data.BatchNumber !== undefined) this.BatchNumber = data.BatchNumber;
      if (data.SortType !== undefined) this.SortType = data.SortType;
      if (data.SystemNum !== undefined) this.SystemNum = data.SystemNum;
      if (data.SizeIDNum !== undefined) this.SizeIDNum = data.SizeIDNum;
      if (data.ChannelNum !== undefined) this.ChannelNum = data.ChannelNum;
      if (data.QualityGradeSum !== undefined) this.QualityGradeSum = data.QualityGradeSum;
      if (data.WeightOrSizeGradeSum !== undefined) this.WeightOrSizeGradeSum = data.WeightOrSizeGradeSum;
      if (data.ColorGradeName !== undefined) this.ColorGradeName = data.ColorGradeName;
      if (data.ShapeGradeName !== undefined) this.ShapeGradeName = data.ShapeGradeName;
      if (data.FlawGradeName !== undefined) this.FlawGradeName = data.FlawGradeName;
      if (data.HardGradeName !== undefined) this.HardGradeName = data.HardGradeName;
      if (data.DensityGradeName !== undefined) this.DensityGradeName = data.DensityGradeName;
      if (data.SugarDegreeGradeName !== undefined) this.SugarDegreeGradeName = data.SugarDegreeGradeName;
      if (data.ExportSum !== undefined) this.ExportSum = data.ExportSum;
      if (data.ProgramName !== undefined) this.ProgramName = data.ProgramName;
    }
  }

  private static indexesCreated: boolean = false;

  /**
   * 创建索引以优化查询性能
   */
  static createIndexes(): void {
    if (FruitInfo.indexesCreated) {
      return;
    }
    
    try {
      const db = GetIBestORM();
      const core = db.GetCore();
      const tableName = 'tb_fruitinfo';
      
      if (!core) {
        console.error('FruitInfo: RdbStore未初始化，无法创建索引');
        return;
      }

      const indexColumns = [
        'customer_id',
        'sys_id',
        'order_id',
        'f_batch_no',
        'start_time',
        'end_time',
        'fruit_name',
        'customer_name'
      ];
      
      indexColumns.forEach(col => {
        core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_${col} ON ${tableName}(${col});`);
      });
      
      core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_customer_id_desc ON ${tableName}(customer_id DESC);`);
      
      FruitInfo.indexesCreated = true;
      console.log('FruitInfo 索引创建完成');
    } catch (error) {
      console.error('创建FruitInfo索引失败:', error);
    }
  }
}

