import { Table, Column, PrimaryKey } from '@ibestservices/ibest-orm';

@Table({ name: 'tb_Sys_FruitInfo' })
export class TbSysFruitinfo {
  @PrimaryKey({ autoIncrement: true })
  FID?: number;

  @Column()
  CustomerID?: number;

  @Column()
  SystemID?: number;

  @Column()
  BatchWeight?: number;

  @Column()
  BatchNumber?: number;

}
