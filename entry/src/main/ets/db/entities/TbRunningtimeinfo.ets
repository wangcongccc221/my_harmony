import { Table, Column, PrimaryKey } from '@ibestservices/ibest-orm';

@Table({ name: 'tb_RunningTimeInfo' })
export class TbRunningtimeinfo {
  @PrimaryKey({ autoIncrement: true })
  ID?: number;

  @Column()
  RunningDate?: string;

  @Column()
  StartTime?: string;

  @Column()
  StopTime?: string;

}