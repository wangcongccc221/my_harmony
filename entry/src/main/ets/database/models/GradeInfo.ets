import { Table, Field, FieldType } from '../orm';
import { GetIBestORM } from '../orm';

/**
 * 等级信息数据模型类
 * 用于存储水果等级信息数据
 * 对应数据库表：tb_gradeinfo
 */
@Table({ name: 'tb_gradeinfo' })
export class GradeInfo {
  @Field({ type: FieldType.INTEGER, tag: ['primaryKey', 'autoIncrement', 'notNull'] })
  FID?: number;

  @Field({ type: FieldType.INTEGER, tag: ['notNull'] })
  CustomerID?: number;

  @Field({ type: FieldType.INTEGER, tag: ['notNull'] })
  ChannelID?: number;

  @Field({ type: FieldType.INTEGER, tag: ['notNull'] })
  QualityIndex?: number;

  @Field({ type: FieldType.INTEGER, tag: ['notNull'] })
  SizeID?: number;

  @Field({ type: FieldType.INTEGER, tag: ['notNull'] })
  SizeIndex?: number;

  @Field({ type: FieldType.INTEGER, tag: ['notNull'] })
  BoxNumber?: number;

  @Field({ type: FieldType.REAL })
  BoxWeight?: number;

  @Field({ type: FieldType.INTEGER, tag: ['notNull'] })
  FruitNumber?: number;

  @Field({ type: FieldType.REAL, tag: ['notNull'] })
  FruitWeight?: number;

  @Field({ type: FieldType.REAL, tag: ['notNull'] })
  FPrice?: number;

  @Field({ type: FieldType.INTEGER, tag: ['notNull'] })
  GradeID?: number;

  @Field({ type: FieldType.TEXT })
  QualityName?: string;

  @Field({ type: FieldType.TEXT })
  WeightOrSizeName?: string;

  @Field({ type: FieldType.REAL })
  WeightOrSizeLimit?: number;

  @Field({ type: FieldType.TEXT })
  SelectWeightOrSize?: string;

  @Field({ type: FieldType.TEXT })
  TraitWeightOrSize?: string;

  @Field({ type: FieldType.TEXT })
  TraitColor?: string;

  @Field({ type: FieldType.TEXT })
  TraitShape?: string;

  @Field({ type: FieldType.TEXT })
  TraitFlaw?: string;

  @Field({ type: FieldType.TEXT })
  TraitHard?: string;

  @Field({ type: FieldType.TEXT })
  TraitDensity?: string;

  @Field({ type: FieldType.TEXT })
  TraitSugarDegree?: string;

  constructor(data?: Partial<GradeInfo>) {
    // 设置默认值
    this.ChannelID = 0;
    this.QualityIndex = 0;
    this.SizeID = 0;
    this.SizeIndex = 0;
    this.BoxNumber = 0;
    this.FruitNumber = 0;
    this.FruitWeight = 0.00;
    this.FPrice = 0.00;
    
    // 从 data 复制属性（ArkTS 兼容方式）
    if (data) {
      if (data.FID !== undefined) this.FID = data.FID;
      if (data.CustomerID !== undefined) this.CustomerID = data.CustomerID;
      if (data.ChannelID !== undefined) this.ChannelID = data.ChannelID;
      if (data.QualityIndex !== undefined) this.QualityIndex = data.QualityIndex;
      if (data.SizeID !== undefined) this.SizeID = data.SizeID;
      if (data.SizeIndex !== undefined) this.SizeIndex = data.SizeIndex;
      if (data.BoxNumber !== undefined) this.BoxNumber = data.BoxNumber;
      if (data.BoxWeight !== undefined) this.BoxWeight = data.BoxWeight;
      if (data.FruitNumber !== undefined) this.FruitNumber = data.FruitNumber;
      if (data.FruitWeight !== undefined) this.FruitWeight = data.FruitWeight;
      if (data.FPrice !== undefined) this.FPrice = data.FPrice;
      if (data.GradeID !== undefined) this.GradeID = data.GradeID;
      if (data.QualityName !== undefined) this.QualityName = data.QualityName;
      if (data.WeightOrSizeName !== undefined) this.WeightOrSizeName = data.WeightOrSizeName;
      if (data.WeightOrSizeLimit !== undefined) this.WeightOrSizeLimit = data.WeightOrSizeLimit;
      if (data.SelectWeightOrSize !== undefined) this.SelectWeightOrSize = data.SelectWeightOrSize;
      if (data.TraitWeightOrSize !== undefined) this.TraitWeightOrSize = data.TraitWeightOrSize;
      if (data.TraitColor !== undefined) this.TraitColor = data.TraitColor;
      if (data.TraitShape !== undefined) this.TraitShape = data.TraitShape;
      if (data.TraitFlaw !== undefined) this.TraitFlaw = data.TraitFlaw;
      if (data.TraitHard !== undefined) this.TraitHard = data.TraitHard;
      if (data.TraitDensity !== undefined) this.TraitDensity = data.TraitDensity;
      if (data.TraitSugarDegree !== undefined) this.TraitSugarDegree = data.TraitSugarDegree;
    }
  }

  private static indexesCreated: boolean = false;

  /**
   * 创建索引以优化查询性能
   */
  static createIndexes(): void {
    if (GradeInfo.indexesCreated) {
      return;
    }
    
    try {
      const db = GetIBestORM();
      const core = db.GetCore();
      const tableName = 'tb_gradeinfo';
      
      if (!core) {
        console.error('GradeInfo: RdbStore未初始化，无法创建索引');
        return;
      }

      const indexColumns = [
        'f_id',
        'customer_id',
        'channel_id',
        'grade_id',
        'quality_index',
        'size_id'
      ];
      
      indexColumns.forEach(col => {
        core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_${col} ON ${tableName}(${col});`);
      });
      
      core.executeSql(`CREATE INDEX IF NOT EXISTS idx_${tableName}_f_id_desc ON ${tableName}(f_id DESC);`);
      
      GradeInfo.indexesCreated = true;
      console.log('GradeInfo 索引创建完成');
    } catch (error) {
      console.error('创建GradeInfo索引失败:', error);
    }
  }
}

