import { Table, Column, PrimaryKey } from '@ibestservices/ibest-orm';

@Table({ name: 'tb_FruitInfo' })
export class TbFruitinfo {
  @Column()
  CustomerID?: number;

  @Column()
  SysID?: number;

  @Column()
  MajorCustomerID?: number;

  @Column()
  ChainIdx?: string;

  @Column()
  FBatchNo?: string;

  @Column()
  CustomerName?: string;

  @Column()
  FarmName?: string;

  @Column()
  FruitName?: string;

  @Column()
  SortBaseName?: string;

  @Column()
  StartTime?: string;

  @Column()
  EndTime?: string;

  @Column()
  StartedState?: string;

  @Column()
  CompletedState?: string;

  @Column()
  BatchWeight?: number;

  @Column()
  BatchNumber?: number;

  @Column()
  QualityGradeSum?: number;

  @Column()
  WeightOrSizeGradeSum?: number;

  @Column()
  ExportSum?: number;

  @Column()
  ColorGradeName?: string;

  @Column()
  ShapeGradeName?: string;

  @Column()
  FlawGradeName?: string;

  @Column()
  HardGradeName?: string;

  @Column()
  DensityGradeName?: string;

  @Column()
  SugarDegreeGradeName?: string;

  @Column()
  ProgramName?: string;

  @Column()
  FVisible?: number;

  @Column()
  PageSize?: number;

  @Column()
  PageIndex?: number;

  @Column()
  IsMerge?: boolean;

  @Column()
  SortColumn?: string;

  @Column()
  SortOrder?: string;

}