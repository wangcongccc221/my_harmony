import { Table, Column, PrimaryKey } from '@ibestservices/ibest-orm';

@Table({ name: 'tb_PriceInfo' })
export class TbPriceinfo {
  @PrimaryKey({ autoIncrement: true })
  FID?: number;

  @Column()
  Price?: number;

  @Column()
  PriceName?: string;

}