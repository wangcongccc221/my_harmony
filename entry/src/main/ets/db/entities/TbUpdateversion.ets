import { Table, Column, PrimaryKey } from '@ibestservices/ibest-orm';

@Table({ name: 'tb_UpdateVersion' })
export class TbUpdateversion {
  @Column()
  FDeviceType?: string;

  @Column()
  FFile?: string;

  @Column()
  FType?: number;

  @Column()
  FProject?: string;

  @Column()
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