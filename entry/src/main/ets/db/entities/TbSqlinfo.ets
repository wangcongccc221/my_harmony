import { Table, Column, PrimaryKey } from '@ibestservices/ibest-orm';

@Table({ name: 'tb_SqlInfo' })
export class TbSqlinfo {
  @PrimaryKey({ autoIncrement: true })
  FID?: number;

  @Column()
  FName?: string;

  @Column()
  FIsExecute?: boolean;

  @Column()
  FExecuteDate?: string;

  @Column()
  FIsInit?: boolean;

  @Column()
  FInitDate?: string;

}