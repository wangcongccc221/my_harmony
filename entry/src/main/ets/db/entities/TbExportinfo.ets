import { Table, Column, PrimaryKey } from '@ibestservices/ibest-orm';

@Table({ name: 'tb_ExportInfo' })
export class TbExportinfo {
  @PrimaryKey()
  CustomerID?: number;

  @PrimaryKey()
  ExportID?: number;

  @Column()
  FruitNumber?: number;

  @Column()
  FruitWeight?: number;

  @Column()
  ExitName?: string;

}
