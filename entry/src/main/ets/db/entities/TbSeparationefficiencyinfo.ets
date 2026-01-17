import { Table, Column, PrimaryKey } from '@ibestservices/ibest-orm';

@Table({ name: 'tb_SeparationEfficiencyInfo' })
export class TbSeparationefficiencyinfo {
  @PrimaryKey({ autoIncrement: true })
  ID?: number;

  @Column()
  EfficiencyValue?: string;

  @Column()
  CurrentDate?: string;

  @Column()
  CurrentTime?: string;

}