import { Context } from '@kit.AbilityKit';
import { SysFruitInfo } from '../models/SysFruitInfo';
import { GetIBestORM } from '../orm';
import { relationalStore } from '@kit.ArkData';

/**
 * 系统水果信息CRUD接口
 * 对应48项目：DataBaseOperation中的SysFruitInfo相关方法
 * 用于存储每个子系统（FSM1、FSM2）的水果信息
 */
export class SysFruitInfoService {
  /**
   * Create - 创建记录
   */
  static create(sysFruitInfo: SysFruitInfo): SysFruitInfo {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const id = orm.Session(SysFruitInfo).Insert(sysFruitInfo) as number;
    const result = orm.Session(SysFruitInfo).Where('fid', id).Find(SysFruitInfo);
    if (result.length === 0) {
      throw new Error('创建后查询失败');
    }
    return result[0] as SysFruitInfo;
  }

  /**
   * Read - 根据ID查询
   */
  static findById(id: number): SysFruitInfo | null {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const results = orm.Session(SysFruitInfo).Where('fid', id).Find(SysFruitInfo);
    return results.length > 0 ? (results[0] as SysFruitInfo) : null;
  }

  /**
   * Read - 根据CustomerID查询所有子系统信息
   */
  static findByCustomerId(customerId: number): SysFruitInfo[] {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(SysFruitInfo).Where('customer_i_d', customerId).Find(SysFruitInfo) as SysFruitInfo[];
  }

  /**
   * Read - 根据CustomerID和SystemID查询
   */
  static findByCustomerIdAndSystemId(customerId: number, systemId: number): SysFruitInfo | null {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const results = orm.Session(SysFruitInfo)
      .Where('customer_i_d', customerId)
      .Where('system_id', systemId)
      .Find(SysFruitInfo);
    return results.length > 0 ? (results[0] as SysFruitInfo) : null;
  }

  /**
   * Read - 查询所有
   */
  static findAll(): SysFruitInfo[] {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(SysFruitInfo).Find(SysFruitInfo) as SysFruitInfo[];
  }

  /**
   * Update - 更新记录
   */
  static update(id: number, sysFruitInfo: Partial<SysFruitInfo>): SysFruitInfo {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const values: relationalStore.ValuesBucket = {};
    if (sysFruitInfo.CustomerID !== undefined) values['customer_i_d'] = sysFruitInfo.CustomerID;
    if (sysFruitInfo.SystemID !== undefined) values['system_id'] = sysFruitInfo.SystemID;
    if (sysFruitInfo.BatchNumber !== undefined) values['batch_number'] = sysFruitInfo.BatchNumber;
    if (sysFruitInfo.BatchWeight !== undefined) values['batch_weight'] = sysFruitInfo.BatchWeight;

    orm.Session(SysFruitInfo).Where('fid', id).Update(values);
    const updated = SysFruitInfoService.findById(id);
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

    orm.Session(SysFruitInfo).Where('fid', id).Delete();
  }

  /**
   * Delete - 根据CustomerID删除所有相关记录
   */
  static deleteByCustomerId(customerId: number): number {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(SysFruitInfo).Where('customer_i_d', customerId).Delete() as number;
  }

  // 兼容旧代码的方法（用于API Handler）
  static async save(data: SysFruitInfo, ctx?: Context): Promise<number> {
    const result = SysFruitInfoService.create(data);
    return result.FID ?? 0;
  }

  static async queryAll(ctx?: Context): Promise<SysFruitInfo[]> {
    return SysFruitInfoService.findAll();
  }

  static async queryPage(page: number, size: number, ctx?: Context): Promise<SysFruitInfo[]> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    const offset = (page - 1) * size;
    return orm.Session(SysFruitInfo).Limit(size).Offset(offset).Find(SysFruitInfo) as SysFruitInfo[];
  }

  static async count(ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    const results = orm.Session(SysFruitInfo).Find();
    return results.length;
  }

  static async batchSave(list: SysFruitInfo[], ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    return orm.Session(SysFruitInfo).Insert(list) as number;
  }

  // API Handler 需要的方法：返回受影响的行数
  static async updateReturnAffected(id: number, sysFruitInfo: Partial<SysFruitInfo>, ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const values: relationalStore.ValuesBucket = {};
    if (sysFruitInfo.CustomerID !== undefined) values['customer_i_d'] = sysFruitInfo.CustomerID;
    if (sysFruitInfo.SystemID !== undefined) values['system_id'] = sysFruitInfo.SystemID;
    if (sysFruitInfo.BatchNumber !== undefined) values['batch_number'] = sysFruitInfo.BatchNumber;
    if (sysFruitInfo.BatchWeight !== undefined) values['batch_weight'] = sysFruitInfo.BatchWeight;

    return orm.Session(SysFruitInfo).Where('fid', id).Update(values) as number;
  }

  static async deleteReturnAffected(id: number, ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(SysFruitInfo).Where('fid', id).Delete() as number;
  }
}

