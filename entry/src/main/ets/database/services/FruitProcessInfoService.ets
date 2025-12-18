import { Context } from '@kit.AbilityKit';
import { FruitProcessInfo } from '../models/FruitProcessInfo';
import { GetIBestORM } from '../orm';
import { relationalStore } from '@kit.ArkData';

/**
 * 水果加工信息CRUD接口
 * 对应48项目：DataBaseOperation中的FruitProcessInfo相关方法
 * 用于存储水果加工过程的统计信息
 */
export class FruitProcessInfoService {
  /**
   * Create - 创建记录
   */
  static create(fruitProcessInfo: FruitProcessInfo): FruitProcessInfo {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const id = orm.Session(FruitProcessInfo).Insert(fruitProcessInfo) as number;
    const result = orm.Session(FruitProcessInfo).Where('fid', id).Find(FruitProcessInfo);
    if (result.length === 0) {
      throw new Error('创建后查询失败');
    }
    return result[0] as FruitProcessInfo;
  }

  /**
   * Read - 根据ID查询
   */
  static findById(id: number): FruitProcessInfo | null {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const results = orm.Session(FruitProcessInfo).Where('fid', id).Find(FruitProcessInfo);
    return results.length > 0 ? (results[0] as FruitProcessInfo) : null;
  }

  /**
   * Read - 根据CustomerID查询
   */
  static findByCustomerId(customerId: number): FruitProcessInfo[] {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(FruitProcessInfo).Where('customer_i_d', customerId).Find(FruitProcessInfo) as FruitProcessInfo[];
  }

  /**
   * Read - 查询所有
   */
  static findAll(): FruitProcessInfo[] {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(FruitProcessInfo).Find(FruitProcessInfo) as FruitProcessInfo[];
  }

  /**
   * Update - 更新记录
   */
  static update(id: number, fruitProcessInfo: Partial<FruitProcessInfo>): FruitProcessInfo {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const values: relationalStore.ValuesBucket = {};
    if (fruitProcessInfo.CustomerID !== undefined) values['customer_i_d'] = fruitProcessInfo.CustomerID;
    if (fruitProcessInfo.RealWeightCountPercent !== undefined) values['real_weight_count_percent'] = fruitProcessInfo.RealWeightCountPercent;
    if (fruitProcessInfo.SeparationEfficiencyPercent !== undefined) values['separation_efficiency_percent'] = fruitProcessInfo.SeparationEfficiencyPercent;

    orm.Session(FruitProcessInfo).Where('fid', id).Update(values);
    const updated = FruitProcessInfoService.findById(id);
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

    orm.Session(FruitProcessInfo).Where('fid', id).Delete();
  }

  /**
   * Delete - 根据CustomerID删除所有相关记录
   */
  static deleteByCustomerId(customerId: number): number {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(FruitProcessInfo).Where('customer_i_d', customerId).Delete() as number;
  }

  // 兼容旧代码的方法（用于API Handler）
  static async save(data: FruitProcessInfo, ctx?: Context): Promise<number> {
    const result = FruitProcessInfoService.create(data);
    return result.FID ?? 0;
  }

  static async queryAll(ctx?: Context): Promise<FruitProcessInfo[]> {
    return FruitProcessInfoService.findAll();
  }

  static async queryPage(page: number, size: number, ctx?: Context): Promise<FruitProcessInfo[]> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    const offset = (page - 1) * size;
    return orm.Session(FruitProcessInfo).Limit(size).Offset(offset).Find(FruitProcessInfo) as FruitProcessInfo[];
  }

  static async count(ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    const results = orm.Session(FruitProcessInfo).Find();
    return results.length;
  }

  static async batchSave(list: FruitProcessInfo[], ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    return orm.Session(FruitProcessInfo).Insert(list) as number;
  }

  // API Handler 需要的方法：返回受影响的行数
  static async updateReturnAffected(id: number, fruitProcessInfo: Partial<FruitProcessInfo>, ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const values: relationalStore.ValuesBucket = {};
    if (fruitProcessInfo.CustomerID !== undefined) values['customer_i_d'] = fruitProcessInfo.CustomerID;
    if (fruitProcessInfo.RealWeightCountPercent !== undefined) values['real_weight_count_percent'] = fruitProcessInfo.RealWeightCountPercent;
    if (fruitProcessInfo.SeparationEfficiencyPercent !== undefined) values['separation_efficiency_percent'] = fruitProcessInfo.SeparationEfficiencyPercent;

    return orm.Session(FruitProcessInfo).Where('fid', id).Update(values) as number;
  }

  static async deleteReturnAffected(id: number, ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(FruitProcessInfo).Where('fid', id).Delete() as number;
  }
}

