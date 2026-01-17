import { Table, Column, PrimaryKey } from '@ibestservices/ibest-orm';

@Table({ name: 'tb_UploadInfo' })
export class TbUploadinfo {
  @PrimaryKey({ autoIncrement: true })
  FID?: number;

  @Column()
  FType?: string;

  @Column()
  FTableName?: string;

  @Column()
  FCurrentRow?: number;

  @Column()
  FMaxUploadRow?: number;

}