import { Table, Field, FieldType, Model } from '@ibestservices/ibest-orm';

@Table
export class HistoryRecord extends Model {
  @Field({ type: FieldType.TEXT })
  CustomerName?: string

  @Field({ type: FieldType.TEXT })
  FarmName?: string

  @Field({ type: FieldType.TEXT })
  FruitName?: string

  @Field({ type: FieldType.TEXT })
  Status?: string

  @Field({ type: FieldType.TEXT })
  StartTime?: string

  @Field({ type: FieldType.TEXT })
  EndTime?: string

  @Field({ type: FieldType.INTEGER })
  Weight?: number

  @Field({ type: FieldType.INTEGER })
  Count?: number
}


