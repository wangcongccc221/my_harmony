import { Table, Column, PrimaryKey } from '@ibestservices/ibest-orm';

@Table({ name: 'tb_ClientInfo' })
export class TbClientinfo {
  @PrimaryKey({ autoIncrement: true })
  FID?: number;

  @Column()
  FCode?: string;

  @Column()
  FName?: string;

  @Column()
  FCreateDate?: string;

  @Column()
  FModifyDate?: string;

  @Column()
  FIsCurrent?: boolean;

}