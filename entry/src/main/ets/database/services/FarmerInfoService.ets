import { FarmerInfo } from '../models/FarmerInfo';
import { GetIBestORM } from '../orm';
import { relationalStore } from '@kit.ArkData';

/**
 * 农户信息CRUD接口
 * 使用ORM同步方法，直接内部调用
 */
export class FarmerInfoService {
  /**
   * Create - 创建记录
   */
  static create(farmerInfo: FarmerInfo): FarmerInfo {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const id = orm.Session(FarmerInfo).Insert(farmerInfo) as number;
    const result = orm.Session(FarmerInfo).Where('farmer_id', id).Find(FarmerInfo);
    if (result.length === 0) {
      throw new Error('创建后查询失败');
    }
    return result[0] as FarmerInfo;
  }

  /**
   * Read - 根据ID查询
   */
  static findById(id: number): FarmerInfo | null {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const results = orm.Session(FarmerInfo).Where('farmer_id', id).Find(FarmerInfo);
    return results.length > 0 ? (results[0] as FarmerInfo) : null;
  }

  /**
   * Read - 查询所有
   */
  static findAll(): FarmerInfo[] {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(FarmerInfo).Find(FarmerInfo) as FarmerInfo[];
  }

  /**
   * Update - 更新记录
   */
  static update(id: number, farmerInfo: Partial<FarmerInfo>): FarmerInfo {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const values: relationalStore.ValuesBucket = {};
    if (farmerInfo.FarmerName !== undefined) values['farmer_name'] = farmerInfo.FarmerName;
    if (farmerInfo.FarmerPhone !== undefined) values['farmer_phone'] = farmerInfo.FarmerPhone;
    if (farmerInfo.FarmerAddress !== undefined) values['farmer_address'] = farmerInfo.FarmerAddress;
    if (farmerInfo.FarmerCreateAt !== undefined) values['farmer_create_at'] = farmerInfo.FarmerCreateAt;

    orm.Session(FarmerInfo).Where('farmer_id', id).Update(values);
    const updated = FarmerInfoService.findById(id);
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

    orm.Session(FarmerInfo).Where('farmer_id', id).Delete();
  }
}
