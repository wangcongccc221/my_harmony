import { Table, Field, FieldType, Model } from '@ibestservices/ibest-orm';

@Table
export class ProcessingRecord extends Model {
  @Field({ type: FieldType.TEXT })
  StartTime?: string

  @Field({ type: FieldType.TEXT })
  EndTime?: string

  @Field({ type: FieldType.TEXT })
  ProductType?: string

  @Field({ type: FieldType.INTEGER })
  TotalWeight?: number
}


