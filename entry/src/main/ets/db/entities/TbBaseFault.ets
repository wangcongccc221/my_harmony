import { Table, Column, PrimaryKey } from '@ibestservices/ibest-orm';

@Table({ name: 'tb_Base_Fault' })
export class TbBaseFault {
  @PrimaryKey({ autoIncrement: true })
  FID?: number;

  @Column()
  FType?: number;

  @Column()
  FCode?: string;

  @Column()
  FName?: string;

  @Column()
  FGroupName?: string;

  @Column()
  FMessage?: string;

  @Column()
  FShutdownCondition?: number;

  @Column()
  FDecelerationCondition?: number;

  @Column()
  FPopupCondition?: number;

  @Column()
  FPromptCondition?: number;

  @Column()
  FExitid?: number;

  @Column()
  FDuration?: number;

  @Column()
  FCreateDate?: string;

  @Column()
  FModifyDate?: string;

  @Column()
  FStatus?: number;

  @Column()
  FOccurDate?: string;

}