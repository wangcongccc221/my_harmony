import { Table, Column, PrimaryKey } from '@ibestservices/ibest-orm';

@Table({ name: 'tb_FTPInfo' })
export class TbFtpinfo {
  @Column()
  FtpIp?: string;

  @Column()
  FtpPort?: number;

  @Column()
  FtpUserName?: string;

  @Column()
  FtpPassword?: string;

}