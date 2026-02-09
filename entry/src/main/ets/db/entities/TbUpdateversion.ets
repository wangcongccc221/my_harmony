import { Table, Column, PrimaryKey } from '@ibestservices/ibest-orm';

@Table({ name: 'tb_UpdateVersion' })
export class TbUpdateversion {
  @PrimaryKey()
  FDeviceType?: string;

  @Column()
  FFile?: string;

  @Column()
  FType?: number;

  @PrimaryKey()
  FProject?: string;

  @PrimaryKey()
  FVersion?: string;

  @Column()
  FZHDescribe?: string;

  @Column()
  FENDescribe?: string;

  @Column()
  FIsEncryption?: boolean;

  @Column()
  FLevel?: number;

  @Column()
  FStrFileData?: string;

  @Column()
  FFileData?: Uint8Array;

}
