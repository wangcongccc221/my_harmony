import { Table, Column, PrimaryKey } from '@ibestservices/ibest-orm';

@Table({ name: 'tb_FruitProcessInfo' })
export class TbFruitprocessinfo {
  @PrimaryKey({ autoIncrement: true })
  FID?: number;

  @Column()
  RealWeightCount?: number;

  @Column()
  RealWeightCountPer?: number;

  @Column()
  SeparationEfficiency?: number;

  @Column()
  SpeedPercent?: number;

  @Column()
  AvgWeight?: number;

  @Column()
  RunningDate?: string;

}