import { Context } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { FruitInfo } from '../models/FruitInfo';
import { createService } from './createService';

const DOMAIN = 0x0000;

type ESObject = object;

/**
 * 创建字段映射表
 */
function createColumnMap(): Record<string, string> {
  const map: Record<string, string> = {};
  map['CustomerID'] = 'customer_i_d';
  map['SysID'] = 'sys_i_d';
  map['FeedPortID'] = 'feed_port_i_d';
  map['MajorCustomerID'] = 'major_customer_i_d';
  map['FBatchNo'] = 'f_batch_no';
  map['OrderID'] = 'order_i_d';
  map['ChainIdx'] = 'chain_idx';
  map['CustomerName'] = 'customer_name';
  map['FarmName'] = 'farm_name';
  map['FruitName'] = 'fruit_name';
  map['StartTime'] = 'start_time';
  map['EndTime'] = 'end_time';
  map['StartedState'] = 'started_state';
  map['CompletedState'] = 'completed_state';
  map['BatchWeight'] = 'batch_weight';
  map['BatchNumber'] = 'batch_number';
  map['SortType'] = 'sort_type';
  map['SystemNum'] = 'system_num';
  map['SizeIDNum'] = 'size_i_d_num';
  map['ChannelNum'] = 'channel_num';
  map['QualityGradeSum'] = 'quality_grade_sum';
  map['WeightOrSizeGradeSum'] = 'weight_or_size_grade_sum';
  map['ColorGradeName'] = 'color_grade_name';
  map['ShapeGradeName'] = 'shape_grade_name';
  map['FlawGradeName'] = 'flaw_grade_name';
  map['HardGradeName'] = 'hard_grade_name';
  map['DensityGradeName'] = 'density_grade_name';
  map['SugarDegreeGradeName'] = 'sugar_degree_grade_name';
  map['ExportSum'] = 'export_sum';
  map['ProgramName'] = 'program_name';
  return map;
}

/**
 * 水果信息服务类
 * 
 * 使用工厂函数 createService 后，代码从 217 行减少到约 70 行！
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
const BaseFruitInfoService = createService(
  FruitInfo,
  createColumnMap(),
  {
    validateData: (data: ESObject) => {
      const fruitInfo = data as FruitInfo;
      // 设置默认值
      if (fruitInfo.SortType === undefined || fruitInfo.SortType === null) {
        fruitInfo.SortType = 0;
      }
      
      // 业务校验
      if (fruitInfo.BatchWeight !== undefined && fruitInfo.BatchWeight < 0) {
        throw new Error('批次重量不能为负数');
      }
      if (fruitInfo.BatchNumber !== undefined && fruitInfo.BatchNumber < 0) {
        throw new Error('批次数量不能为负数');
      }
    }
  }
);

/**
 * 扩展 Service 类型定义
 */
interface ExtendedFruitInfoService {
  save: (data: ESObject, ctx?: Context) => Promise<number>;
  batchSave: (list: ESObject[], ctx?: Context) => Promise<number>;
  update: (id: number, data: ESObject, ctx?: Context) => Promise<number>;
  delete: (id: number, ctx?: Context) => Promise<number>;
  queryAll: (ctx?: Context) => Promise<ESObject[]>;
  queryPage: (page: number, size: number, ctx?: Context) => Promise<ESObject[]>;
  count: (ctx?: Context) => Promise<number>;
}

/**
 * 创建扩展后的 Service
 */
const extendedService: ExtendedFruitInfoService = {
  save: BaseFruitInfoService.save,
  batchSave: BaseFruitInfoService.batchSave,
  update: BaseFruitInfoService.update,
  delete: BaseFruitInfoService.delete,
  queryAll: BaseFruitInfoService.queryAll,
  queryPage: BaseFruitInfoService.queryPage,
  count: BaseFruitInfoService.count
};

export const FruitInfoService = extendedService;
