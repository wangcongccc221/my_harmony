import { Table, Column, PrimaryKey } from '@ibestservices/ibest-orm';

@Table({ name: 'tb_GradeInfo' })
export class TbGradeinfo {
  @PrimaryKey()
  CustomerID?: number;

  @PrimaryKey()
  GradeID?: number;

  @Column()
  BoxNumber?: number;

  @Column()
  FruitNumber?: number;

  @Column()
  FruitWeight?: number;

  @Column()
  QualityName?: string;

  @Column()
  WeightOrSizeName?: string;

  @Column()
  WeightOrSizeLimit?: number;

  @Column()
  SelectWeightOrSize?: string;

  @Column()
  TraitWeightOrSize?: string;

  @Column()
  TraitColor?: string;

  @Column()
  TraitShape?: string;

  @Column()
  TraitFlaw?: string;

  @Column()
  TraitHard?: string;

  @Column()
  TraitDensity?: string;

  @Column()
  TraitSugarDegree?: string;

  @Column()
  FPrice?: number;

  @Column()
  nSizeMax?: number;

  @Column()
  nSizeMin?: number;

}
