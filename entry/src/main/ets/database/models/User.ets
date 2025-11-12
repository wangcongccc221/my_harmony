import { Table, Field, FieldType, Model } from '@ibestservices/ibest-orm';

/**
 * 用户模型类
 */
@Table
export class User extends Model {
  /**
   * 名字
   */
  @Field({ type: FieldType.TEXT })
  Name?: string;

  /**
   * 年龄
   */
  @Field({ type: FieldType.INTEGER })
  Age?: number;

  /**
   * 没有被装饰器装饰的字段, 不会被映射成表字段
   */
  Salary?: number;

  constructor(name?: string, age?: number) {
    super();
    this.Name = name;
    this.Age = age;
  }
}

