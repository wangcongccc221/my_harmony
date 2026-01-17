import { Table, Column, PrimaryKey } from '@ibestservices/ibest-orm';

@Table({ name: 'tb_Sys_Configs' })
export class TbSysConfigs {
  @PrimaryKey({ autoIncrement: true })
  FID?: number;

  @Column()
  FModuleName?: string;

  @Column()
  FType?: string;

  @Column()
  FValue?: string;

  @Column()
  FCreateDate?: string;

  @Column()
  FVisible?: number;

  @Column()
  FEnType?: string;

  @Column()
  FValueType?: number;

  @Column()
  FValueTypeDetail?: string;

  @Column()
  FZhType?: string;

}