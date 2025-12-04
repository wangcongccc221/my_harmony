import { Context } from '@kit.AbilityKit';
import { DatabaseQueueManager } from '../../utils/network/database/dispatch/DatabaseQueueManager';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { GradeInfo } from '../models/GradeInfo';
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
  map['QualityIndex'] = 'quality_index';
  map['SizeID'] = 'size_i_d';
  map['SizeIndex'] = 'size_index';
  map['BoxNumber'] = 'box_number';
  map['BoxWeight'] = 'box_weight';
  map['FruitNumber'] = 'fruit_number';
  map['FruitWeight'] = 'fruit_weight';
  map['FPrice'] = 'f_price';
  map['GradeID'] = 'grade_i_d';
  map['QualityName'] = 'quality_name';
  map['WeightOrSizeName'] = 'weight_or_size_name';
  map['WeightOrSizeLimit'] = 'weight_or_size_limit';
  map['SelectWeightOrSize'] = 'select_weight_or_size';
  map['TraitWeightOrSize'] = 'trait_weight_or_size';
  map['TraitColor'] = 'trait_color';
  map['TraitShape'] = 'trait_shape';
  map['TraitFlaw'] = 'trait_flaw';
  map['TraitHard'] = 'trait_hard';
  map['TraitDensity'] = 'trait_density';
  map['TraitSugarDegree'] = 'trait_sugar_degree';
  return map;
}

/**
 * 等级信息服务类
 * 
 * 使用工厂函数 createService 后，代码从 237 行减少到约 80 行！
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
const BaseGradeInfoService = createService(
  GradeInfo,
  createColumnMap(),
  {
    validateData: (data: ESObject) => {
      const gradeInfo = data as GradeInfo;
      // 设置默认值
      if (gradeInfo.CustomerID === undefined) gradeInfo.CustomerID = 0;
      if (gradeInfo.ChannelID === undefined) gradeInfo.ChannelID = 0;
      if (gradeInfo.QualityIndex === undefined) gradeInfo.QualityIndex = 0;
      if (gradeInfo.SizeID === undefined) gradeInfo.SizeID = 0;
      if (gradeInfo.SizeIndex === undefined) gradeInfo.SizeIndex = 0;
      if (gradeInfo.BoxNumber === undefined) gradeInfo.BoxNumber = 0;
      if (gradeInfo.FruitNumber === undefined) gradeInfo.FruitNumber = 0;
      if (gradeInfo.FruitWeight === undefined) gradeInfo.FruitWeight = 0.00;
      if (gradeInfo.FPrice === undefined) gradeInfo.FPrice = 0.00;
      if (gradeInfo.GradeID === undefined) gradeInfo.GradeID = 0;
      
      // 业务校验
      if (gradeInfo.BoxWeight !== undefined && gradeInfo.BoxWeight < 0) {
        throw new Error('箱重不能为负数');
      }
      if (gradeInfo.FruitWeight !== undefined && gradeInfo.FruitWeight < 0) {
        throw new Error('水果重量不能为负数');
      }
      if (gradeInfo.FPrice !== undefined && gradeInfo.FPrice < 0) {
        throw new Error('价格不能为负数');
      }
    }
  }
);

/**
 * 扩展 Service 类型定义
 */
interface ExtendedGradeInfoService {
  save: (data: ESObject, ctx?: Context) => Promise<number>;
  batchSave: (list: ESObject[], ctx?: Context) => Promise<number>;
  update: (id: number, data: ESObject, ctx?: Context) => Promise<number>;
  delete: (id: number, ctx?: Context) => Promise<number>;
  queryAll: (ctx?: Context) => Promise<ESObject[]>;
  queryPage: (page: number, size: number, ctx?: Context) => Promise<ESObject[]>;
  count: (ctx?: Context) => Promise<number>;
  queryByCustomerId: (ctx: Context, customerId: number) => Promise<GradeInfo[]>;
}

/**
 * 创建扩展后的 Service
 */
const extendedService: ExtendedGradeInfoService = {
  save: BaseGradeInfoService.save,
  batchSave: BaseGradeInfoService.batchSave,
  update: BaseGradeInfoService.update,
  delete: BaseGradeInfoService.delete,
  queryAll: BaseGradeInfoService.queryAll,
  queryPage: BaseGradeInfoService.queryPage,
  count: BaseGradeInfoService.count,
  queryByCustomerId: async (ctx: Context, customerId: number): Promise<GradeInfo[]> => {
    try {
      const result = await DatabaseQueueManager.queryByCondition<GradeInfo>(
        ctx, 
        GradeInfo, 
        'customer_i_d = ?', 
        [customerId]
      );
      hilog.info(DOMAIN, 'GradeInfoService', `根据客户ID查询等级信息成功: CustomerID=${customerId}, 数量=${result.length}`);
      return result;
    } catch (error) {
      hilog.error(DOMAIN, 'GradeInfoService', `根据客户ID查询等级信息失败: ${JSON.stringify(error)}`);
      throw new Error(`根据客户ID查询等级信息失败: ${JSON.stringify(error)}`);
    }
  }
};

export const GradeInfoService = extendedService;
