import { Table, Column, PrimaryKey } from '@ibestservices/ibest-orm';

@Table({ name: 'tb_FTPInfo' })
export class TbFtpinfo {
  @PrimaryKey()
  FtpIp?: string;

  @PrimaryKey()
  FtpPort?: number;

  @Column()
  FtpUserName?: string;

  @Column()
  FtpPassword?: string;

}
