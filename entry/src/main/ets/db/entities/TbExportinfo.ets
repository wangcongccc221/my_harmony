import { Table, Column, PrimaryKey } from '@ibestservices/ibest-orm';

@Table({ name: 'tb_ExportInfo' })
export class TbExportinfo {
  @Column()
  CustomerID?: number;

  @Column()
  ExportID?: number;

  @Column()
  FruitNumber?: number;

  @Column()
  FruitWeight?: number;

  @Column()
  ExitName?: string;

}