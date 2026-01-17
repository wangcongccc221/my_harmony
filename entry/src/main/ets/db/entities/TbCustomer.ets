import { Table, Column, PrimaryKey } from '@ibestservices/ibest-orm';

@Table({ name: 'tb_Customer' })
export class TbCustomer {
  @PrimaryKey({ autoIncrement: true })
  FID?: number;

  @Column()
  FName?: string;

  @Column()
  FPassWord?: string;

  @Column()
  FCode?: string;

  @Column()
  FIsUse?: string;

  @Column()
  FCreateDate?: string;

}