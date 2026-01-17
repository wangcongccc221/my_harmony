import { Table, Column, PrimaryKey } from '@ibestservices/ibest-orm';

@Table({ name: 'tb_Sys_FruitInfo' })
export class TbSysFruitinfo {
  @Column()
  CustomerID?: number;

  @Column()
  SystemID?: number;

  @Column()
  BatchWeight?: number;

  @Column()
  BatchNumber?: number;

}