import { Context } from '@kit.AbilityKit';
import { GradeInfo } from '../models/GradeInfo';
import { GetIBestORM } from '../orm';
import { relationalStore } from '@kit.ArkData';

/**
 * 等级信息CRUD接口
 * 使用ORM同步方法，直接内部调用
 */
export class GradeInfoService {
  /**
   * Create - 创建记录
   */
  static create(gradeInfo: GradeInfo): GradeInfo {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const id = orm.Session(GradeInfo).Insert(gradeInfo) as number;
    const result = orm.Session(GradeInfo).Where('fid', id).Find(GradeInfo);
    if (result.length === 0) {
      throw new Error('创建后查询失败');
    }
    return result[0] as GradeInfo;
  }

  /**
   * Read - 根据ID查询
   */
  static findById(id: number): GradeInfo | null {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const results = orm.Session(GradeInfo).Where('fid', id).Find(GradeInfo);
    return results.length > 0 ? (results[0] as GradeInfo) : null;
  }

  /**
   * Read - 查询所有
   */
  static findAll(): GradeInfo[] {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(GradeInfo).Find(GradeInfo) as GradeInfo[];
  }

  /**
   * Update - 更新记录
   */
  static update(id: number, gradeInfo: Partial<GradeInfo>): GradeInfo {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const values: relationalStore.ValuesBucket = {};
    if (gradeInfo.CustomerID !== undefined) values['customer_i_d'] = gradeInfo.CustomerID;
    if (gradeInfo.ChannelID !== undefined) values['channel_i_d'] = gradeInfo.ChannelID;
    if (gradeInfo.QualityIndex !== undefined) values['quality_index'] = gradeInfo.QualityIndex;
    if (gradeInfo.SizeID !== undefined) values['size_i_d'] = gradeInfo.SizeID;
    if (gradeInfo.SizeIndex !== undefined) values['size_index'] = gradeInfo.SizeIndex;
    if (gradeInfo.BoxNumber !== undefined) values['box_number'] = gradeInfo.BoxNumber;
    if (gradeInfo.BoxWeight !== undefined) values['box_weight'] = gradeInfo.BoxWeight;
    if (gradeInfo.FruitNumber !== undefined) values['fruit_number'] = gradeInfo.FruitNumber;
    if (gradeInfo.FruitWeight !== undefined) values['fruit_weight'] = gradeInfo.FruitWeight;
    if (gradeInfo.FPrice !== undefined) values['f_price'] = gradeInfo.FPrice;
    if (gradeInfo.GradeID !== undefined) values['grade_i_d'] = gradeInfo.GradeID;
    if (gradeInfo.QualityName !== undefined) values['quality_name'] = gradeInfo.QualityName;
    if (gradeInfo.WeightOrSizeName !== undefined) values['weight_or_size_name'] = gradeInfo.WeightOrSizeName;
    if (gradeInfo.WeightOrSizeLimit !== undefined) values['weight_or_size_limit'] = gradeInfo.WeightOrSizeLimit;
    if (gradeInfo.SelectWeightOrSize !== undefined) values['select_weight_or_size'] = gradeInfo.SelectWeightOrSize;
    if (gradeInfo.TraitWeightOrSize !== undefined) values['trait_weight_or_size'] = gradeInfo.TraitWeightOrSize;
    if (gradeInfo.TraitColor !== undefined) values['trait_color'] = gradeInfo.TraitColor;
    if (gradeInfo.TraitShape !== undefined) values['trait_shape'] = gradeInfo.TraitShape;
    if (gradeInfo.TraitFlaw !== undefined) values['trait_flaw'] = gradeInfo.TraitFlaw;
    if (gradeInfo.TraitHard !== undefined) values['trait_hard'] = gradeInfo.TraitHard;
    if (gradeInfo.TraitDensity !== undefined) values['trait_density'] = gradeInfo.TraitDensity;
    if (gradeInfo.TraitSugarDegree !== undefined) values['trait_sugar_degree'] = gradeInfo.TraitSugarDegree;

    orm.Session(GradeInfo).Where('fid', id).Update(values);
    const updated = GradeInfoService.findById(id);
    if (!updated) {
      throw new Error('更新后查询失败');
    }
    return updated;
  }

  /**
   * Delete - 删除记录
   */
  static delete(id: number): void {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    orm.Session(GradeInfo).Where('fid', id).Delete();
  }

  // 兼容旧代码的方法
  static async save(data: GradeInfo, ctx?: Context): Promise<number> {
    const result = GradeInfoService.create(data);
    return result.FID ?? 0;
  }

  static async queryAll(ctx?: Context): Promise<GradeInfo[]> {
    return GradeInfoService.findAll();
  }

  static async queryPage(page: number, size: number, ctx?: Context): Promise<GradeInfo[]> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    const offset = (page - 1) * size;
    return orm.Session(GradeInfo).Limit(size).Offset(offset).Find(GradeInfo) as GradeInfo[];
  }

  static async count(ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    const results = orm.Session(GradeInfo).Find();
    return results.length;
  }

  static async batchSave(list: GradeInfo[], ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    return orm.Session(GradeInfo).Insert(list) as number;
  }

  static async queryByCustomerId(ctx: Context, customerId: number): Promise<GradeInfo[]> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    return orm.Session(GradeInfo).Where('customer_i_d', customerId).Find(GradeInfo) as GradeInfo[];
  }

  // API Handler 需要的方法
  static async updateReturnAffected(id: number, gradeInfo: Partial<GradeInfo>, ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const values: relationalStore.ValuesBucket = {};
    if (gradeInfo.CustomerID !== undefined) values['customer_i_d'] = gradeInfo.CustomerID;
    if (gradeInfo.ChannelID !== undefined) values['channel_i_d'] = gradeInfo.ChannelID;
    if (gradeInfo.QualityIndex !== undefined) values['quality_index'] = gradeInfo.QualityIndex;
    if (gradeInfo.SizeID !== undefined) values['size_i_d'] = gradeInfo.SizeID;
    if (gradeInfo.SizeIndex !== undefined) values['size_index'] = gradeInfo.SizeIndex;
    if (gradeInfo.BoxNumber !== undefined) values['box_number'] = gradeInfo.BoxNumber;
    if (gradeInfo.BoxWeight !== undefined) values['box_weight'] = gradeInfo.BoxWeight;
    if (gradeInfo.FruitNumber !== undefined) values['fruit_number'] = gradeInfo.FruitNumber;
    if (gradeInfo.FruitWeight !== undefined) values['fruit_weight'] = gradeInfo.FruitWeight;
    if (gradeInfo.FPrice !== undefined) values['f_price'] = gradeInfo.FPrice;
    if (gradeInfo.GradeID !== undefined) values['grade_i_d'] = gradeInfo.GradeID;
    if (gradeInfo.QualityName !== undefined) values['quality_name'] = gradeInfo.QualityName;
    if (gradeInfo.WeightOrSizeName !== undefined) values['weight_or_size_name'] = gradeInfo.WeightOrSizeName;
    if (gradeInfo.WeightOrSizeLimit !== undefined) values['weight_or_size_limit'] = gradeInfo.WeightOrSizeLimit;
    if (gradeInfo.SelectWeightOrSize !== undefined) values['select_weight_or_size'] = gradeInfo.SelectWeightOrSize;
    if (gradeInfo.TraitWeightOrSize !== undefined) values['trait_weight_or_size'] = gradeInfo.TraitWeightOrSize;
    if (gradeInfo.TraitColor !== undefined) values['trait_color'] = gradeInfo.TraitColor;
    if (gradeInfo.TraitShape !== undefined) values['trait_shape'] = gradeInfo.TraitShape;
    if (gradeInfo.TraitFlaw !== undefined) values['trait_flaw'] = gradeInfo.TraitFlaw;
    if (gradeInfo.TraitHard !== undefined) values['trait_hard'] = gradeInfo.TraitHard;
    if (gradeInfo.TraitDensity !== undefined) values['trait_density'] = gradeInfo.TraitDensity;
    if (gradeInfo.TraitSugarDegree !== undefined) values['trait_sugar_degree'] = gradeInfo.TraitSugarDegree;

    return orm.Session(GradeInfo).Where('fid', id).Update(values) as number;
  }

  static async deleteReturnAffected(id: number, ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(GradeInfo).Where('fid', id).Delete() as number;
  }
}
