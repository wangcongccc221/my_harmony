import { Table, Field, FieldType, Model } from '@ibestservices/ibest-orm';

/**
 * 测试模型类
 * 用于测试数据库功能
 */
@Table
export class TestModel extends Model {
  /**
   * 标题
   */
  @Field({ type: FieldType.TEXT })
  Title?: string;

  /**
   * 描述
   */
  @Field({ type: FieldType.TEXT })
  Description?: string;

  /**
   * 数量
   */
  @Field({ type: FieldType.INTEGER })
  Count?: number;

  /**
   * 是否启用
   */
  @Field({ type: FieldType.INTEGER })
  IsEnabled?: number; // 0 或 1，表示 false 或 true

  constructor(title?: string, description?: string, count?: number, isEnabled?: number) {
    super();
    this.Title = title;
    this.Description = description;
    this.Count = count;
    this.IsEnabled = isEnabled;
  }
}

