import { Table, Field, FieldType, Model } from '@ibestservices/ibest-orm';

/**
 * 历史加工数据模型类
 * 用于存储加工历史记录
 */
@Table
export class ProcessingHistory extends Model {
  /**
   * 客户名称
   */
  @Field({ type: FieldType.TEXT, tag: ['notNull'] })
  CustomerName?: string;

  /**
   * 农场名称
   */
  @Field({ type: FieldType.TEXT, tag: ['notNull'] })
  FarmName?: string;

  /**
   * 水果名称
   */
  @Field({ type: FieldType.TEXT, tag: ['notNull'] })
  FruitName?: string;

  /**
   * 状态
   */
  @Field({ type: FieldType.TEXT, tag: ['notNull'] })
  Status?: string;

  /**
   * 开始时间
   */
  @Field({ type: FieldType.TEXT, tag: ['notNull'] })
  StartTime?: string;

  /**
   * 结束时间
   */
  @Field({ type: FieldType.TEXT })
  EndTime?: string;

  /**
   * 重量（单位：克或千克）
   */
  @Field({ type: FieldType.REAL })
  Weight?: number;

  /**
   * 数量
   */
  @Field({ type: FieldType.INTEGER })
  Quantity?: number;

  constructor(
    customerName?: string,
    farmName?: string,
    fruitName?: string,
    status?: string,
    startTime?: string,
    endTime?: string,
    weight?: number,
    quantity?: number
  ) {
    super();
    this.CustomerName = customerName;
    this.FarmName = farmName;
    this.FruitName = fruitName;
    this.Status = status;
    this.StartTime = startTime;
    this.EndTime = endTime;
    this.Weight = weight;
    this.Quantity = quantity;
  }
}

