import { Context } from '@kit.AbilityKit';
import { DatabaseQueueManager } from '../../utils/network/database/dispatch/DatabaseQueueManager';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ExportInfo } from '../models/ExportInfo';
import { createService } from './createService';

const DOMAIN = 0x0000;

type ESObject = object;

/**
 * 创建字段映射表
 */
function createColumnMap(): Record<string, string> {
  const map: Record<string, string> = {};
  map['FID'] = 'fid';
  map['CustomerID'] = 'customer_i_d';
  map['ChannelID'] = 'channel_i_d';
  map['ExportID'] = 'export_i_d';
  map['FruitNumber'] = 'fruit_number';
  map['FruitWeight'] = 'fruit_weight';
  map['BoxNumber'] = 'box_number';
  map['ExitName'] = 'exit_name';
  return map;
}

/**
 * 导出信息服务类
 * 
 * 使用工厂函数 createService 后，代码从 266 行减少到约 120 行！
 * 
 * 自动获得的方法：
 * - save(data, ctx?)
 * - batchSave(list, ctx?)
 * - update(id, data, ctx?)
 * - delete(id, ctx?)
 * - queryAll(ctx?)
 * - queryPage(page, size, ctx?)
 * - count(ctx?)
 */
const BaseExportInfoService = createService(
  ExportInfo,
  createColumnMap(),
  {
    validateData: (data: ESObject) => {
      const exportInfo = data as ExportInfo;
      // 设置默认值
      if (exportInfo.CustomerID === undefined || exportInfo.CustomerID === null) {
        exportInfo.CustomerID = 0;
      }
      if (exportInfo.ChannelID === undefined || exportInfo.ChannelID === null) {
        exportInfo.ChannelID = 0;
      }
      if (exportInfo.ExportID === undefined || exportInfo.ExportID === null) {
        exportInfo.ExportID = 0;
      }
      
      // 业务校验
      if (exportInfo.FruitNumber !== undefined && exportInfo.FruitNumber < 0) {
        throw new Error('水果数量不能为负数');
      }
      if (exportInfo.FruitWeight !== undefined && exportInfo.FruitWeight < 0) {
        throw new Error('水果重量不能为负数');
      }
      if (exportInfo.BoxNumber !== undefined && exportInfo.BoxNumber < 0) {
        throw new Error('箱数不能为负数');
      }
    }
  }
);

/**
 * 扩展 Service 类型定义
 */
interface ExtendedExportInfoService {
  save: (data: ESObject, ctx?: Context) => Promise<number>;
  batchSave: (list: ESObject[], ctx?: Context) => Promise<number>;
  update: (id: number, data: ESObject, ctx?: Context) => Promise<number>;
  delete: (id: number, ctx?: Context) => Promise<number>;
  queryAll: (ctx?: Context) => Promise<ESObject[]>;
  queryPage: (page: number, size: number, ctx?: Context) => Promise<ESObject[]>;
  count: (ctx?: Context) => Promise<number>;
  queryByCustomerId: (ctx: Context, customerId: number) => Promise<ExportInfo[]>;
  queryByExportId: (ctx: Context, exportId: number) => Promise<ExportInfo[]>;
  queryByChannelId: (ctx: Context, channelId: number) => Promise<ExportInfo[]>;
}

/**
 * 创建扩展后的 Service
 */
const extendedService: ExtendedExportInfoService = {
  save: BaseExportInfoService.save,
  batchSave: BaseExportInfoService.batchSave,
  update: BaseExportInfoService.update,
  delete: BaseExportInfoService.delete,
  queryAll: BaseExportInfoService.queryAll,
  queryPage: BaseExportInfoService.queryPage,
  count: BaseExportInfoService.count,
  queryByCustomerId: async (ctx: Context, customerId: number): Promise<ExportInfo[]> => {
    try {
      const result = await DatabaseQueueManager.queryByCondition<ExportInfo>(
        ctx, 
        ExportInfo, 
        'customer_i_d = ?', 
        [customerId]
      );
      hilog.info(DOMAIN, 'ExportInfoService', `根据客户ID查询导出信息成功: CustomerID=${customerId}, 数量=${result.length}`);
      return result;
    } catch (error) {
      hilog.error(DOMAIN, 'ExportInfoService', `根据客户ID查询导出信息失败: ${JSON.stringify(error)}`);
      throw new Error(`根据客户ID查询导出信息失败: ${JSON.stringify(error)}`);
    }
  },
  queryByExportId: async (ctx: Context, exportId: number): Promise<ExportInfo[]> => {
    try {
      const result = await DatabaseQueueManager.queryByCondition<ExportInfo>(
        ctx, 
        ExportInfo, 
        'export_i_d = ?', 
        [exportId]
      );
      hilog.info(DOMAIN, 'ExportInfoService', `根据导出ID查询导出信息成功: ExportID=${exportId}, 数量=${result.length}`);
      return result;
    } catch (error) {
      hilog.error(DOMAIN, 'ExportInfoService', `根据导出ID查询导出信息失败: ${JSON.stringify(error)}`);
      throw new Error(`根据导出ID查询导出信息失败: ${JSON.stringify(error)}`);
    }
  },
  queryByChannelId: async (ctx: Context, channelId: number): Promise<ExportInfo[]> => {
    try {
      const result = await DatabaseQueueManager.queryByCondition<ExportInfo>(
        ctx, 
        ExportInfo, 
        'channel_i_d = ?', 
        [channelId]
      );
      hilog.info(DOMAIN, 'ExportInfoService', `根据通道ID查询导出信息成功: ChannelID=${channelId}, 数量=${result.length}`);
      return result;
    } catch (error) {
      hilog.error(DOMAIN, 'ExportInfoService', `根据通道ID查询导出信息失败: ${JSON.stringify(error)}`);
      throw new Error(`根据通道ID查询导出信息失败: ${JSON.stringify(error)}`);
    }
  }
};

export const ExportInfoService = extendedService;
