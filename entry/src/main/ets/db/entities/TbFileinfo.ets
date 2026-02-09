import { Table, Column, PrimaryKey } from '@ibestservices/ibest-orm';

@Table({ name: 'tb_FileInfo' })
export class TbFileinfo {
  @PrimaryKey()
  FileName?: string;

  @Column()
  Url?: string;

  @PrimaryKey()
  DirectoryName?: string;

  @Column()
  LastWriteTime?: string;

}
