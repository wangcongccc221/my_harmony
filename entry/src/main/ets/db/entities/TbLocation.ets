import { Table, Column, PrimaryKey } from '@ibestservices/ibest-orm';

@Table({ name: 'tb_Location' })
export class TbLocation {
  @PrimaryKey({ autoIncrement: true })
  FID?: number;

  @Column()
  FCode?: string;

  @Column()
  FName?: string;

  @Column()
  FParentID?: number;

  @Column()
  FLevel?: number;

}