import { Context } from '@kit.AbilityKit';
import { ExportInfo } from '../models/ExportInfo';
import { GetIBestORM } from '../orm';
import { relationalStore } from '@kit.ArkData';

/**
 * 导出信息CRUD接口
 * 使用ORM同步方法，直接内部调用
 */
export class ExportInfoService {
  /**
   * Create - 创建记录
   */
  static create(exportInfo: ExportInfo): ExportInfo {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const id = orm.Session(ExportInfo).Insert(exportInfo) as number;
    const result = orm.Session(ExportInfo).Where('fid', id).Find(ExportInfo);
    if (result.length === 0)
    {
      throw new Error('创建后查询失败');
    }
    return result[0] as ExportInfo;
  }

  /**
   * Read - 根据ID查询
   */
  static findById(id: number): ExportInfo | null {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const results = orm.Session(ExportInfo).Where('fid', id).Find(ExportInfo);
    return results.length > 0 ? (results[0] as ExportInfo) : null;
  }

  /**
   * Read - 查询所有
   */
  static findAll(): ExportInfo[] {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(ExportInfo).Find(ExportInfo) as ExportInfo[];
  }

  /**
   * Update - 更新记录
   */
  static update(id: number, exportInfo: Partial<ExportInfo>): ExportInfo {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const values: relationalStore.ValuesBucket = {};
    if (exportInfo.CustomerID !== undefined) values['customer_i_d'] = exportInfo.CustomerID;
    if (exportInfo.ChannelID !== undefined) values['channel_i_d'] = exportInfo.ChannelID;
    if (exportInfo.ExportID !== undefined) values['export_i_d'] = exportInfo.ExportID;
    if (exportInfo.FruitNumber !== undefined) values['fruit_number'] = exportInfo.FruitNumber;
    if (exportInfo.FruitWeight !== undefined) values['fruit_weight'] = exportInfo.FruitWeight;
    if (exportInfo.BoxNumber !== undefined) values['box_number'] = exportInfo.BoxNumber;
    if (exportInfo.ExitName !== undefined) values['exit_name'] = exportInfo.ExitName;

    orm.Session(ExportInfo).Where('fid', id).Update(values);
    const updated = ExportInfoService.findById(id);
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

    orm.Session(ExportInfo).Where('fid', id).Delete();
  }

  // 兼容旧代码的方法
  static async save(data: ExportInfo, ctx?: Context): Promise<number> {
    const result = ExportInfoService.create(data);
    return result.FID ?? 0;
  }

  static async queryAll(ctx?: Context): Promise<ExportInfo[]> {
    return ExportInfoService.findAll();
  }

  static async queryPage(page: number, size: number, ctx?: Context): Promise<ExportInfo[]> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    const offset = (page - 1) * size;
    return orm.Session(ExportInfo).Limit(size).Offset(offset).Find(ExportInfo) as ExportInfo[];
  }

  static async count(ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    const results = orm.Session(ExportInfo).Find();
    return results.length;
  }

  static async batchSave(list: ExportInfo[], ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    return orm.Session(ExportInfo).Insert(list) as number;
  }

  static async queryByCustomerId(ctx: Context, customerId: number): Promise<ExportInfo[]> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    return orm.Session(ExportInfo).Where('customer_i_d', customerId).Find(ExportInfo) as ExportInfo[];
  }

  static async queryByExportId(ctx: Context, exportId: number): Promise<ExportInfo[]> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    return orm.Session(ExportInfo).Where('export_i_d', exportId).Find(ExportInfo) as ExportInfo[];
  }

  static async queryByChannelId(ctx: Context, channelId: number): Promise<ExportInfo[]> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    return orm.Session(ExportInfo).Where('channel_i_d', channelId).Find(ExportInfo) as ExportInfo[];
  }

  // API Handler 需要的方法
  static async updateReturnAffected(id: number, exportInfo: Partial<ExportInfo>, ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const values: relationalStore.ValuesBucket = {};
    if (exportInfo.CustomerID !== undefined) values['customer_i_d'] = exportInfo.CustomerID;
    if (exportInfo.ChannelID !== undefined) values['channel_i_d'] = exportInfo.ChannelID;
    if (exportInfo.ExportID !== undefined) values['export_i_d'] = exportInfo.ExportID;
    if (exportInfo.FruitNumber !== undefined) values['fruit_number'] = exportInfo.FruitNumber;
    if (exportInfo.FruitWeight !== undefined) values['fruit_weight'] = exportInfo.FruitWeight;
    if (exportInfo.BoxNumber !== undefined) values['box_number'] = exportInfo.BoxNumber;
    if (exportInfo.ExitName !== undefined) values['exit_name'] = exportInfo.ExitName;

    return orm.Session(ExportInfo).Where('fid', id).Update(values) as number;
  }

  static async deleteReturnAffected(id: number, ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(ExportInfo).Where('fid', id).Delete() as number;
  }
}
