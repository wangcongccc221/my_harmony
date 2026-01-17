import { Table, Column, PrimaryKey } from '@ibestservices/ibest-orm';

@Table({ name: 'tb_FileInfo' })
export class TbFileinfo {
  @Column()
  FileName?: string;

  @Column()
  Url?: string;

  @Column()
  DirectoryName?: string;

  @Column()
  LastWriteTime?: string;

}