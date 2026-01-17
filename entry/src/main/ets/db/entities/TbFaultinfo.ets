import { Table, Column, PrimaryKey } from '@ibestservices/ibest-orm';

@Table({ name: 'tb_FaultInfo' })
export class TbFaultinfo {
  @PrimaryKey({ autoIncrement: true })
  FID?: number;

  @Column()
  FType?: number;

  @Column()
  FCode?: string;

  @Column()
  FName?: string;

  @Column()
  FMessage?: string;

  @Column()
  FStatus?: number;

  @Column()
  FBeginDate?: string;

  @Column()
  FEndDate?: string;

}