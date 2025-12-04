import { hilog } from '@kit.PerformanceAnalysisKit';
import { Context } from '@kit.AbilityKit';
import { HttpResponseUtils } from '../../../helpers/HttpResponseUtils';
import { QueryStringUtils } from '../../../helpers/QueryStringUtils';
import { FruitInfoService } from '../../../../database/services/FruitInfoService';
import { FruitInfo } from '../../../../database/models/FruitInfo';

const DOMAIN = 0x0000;

// ESObject 类型别名
type ESObject = object;

/**
 * 响应数据接口
 */
interface IdResponse {
  id: number;
}

interface AffectedResponse {
  affected: number;
}

interface InsertedResponse {
  inserted: number;
}

interface PaginationInfo {
  page: number;
  size: number;
  total: number;
  totalPages: number;
}

interface PaginatedResponse {
  data: FruitInfo[];
  pagination: PaginationInfo;
}

/**
 * 水果信息 API 处理器
 */
export class FruitInfoApiHandler {

  static async handle(method: string, path: string, body?: string, ctx?: Context): Promise<string> {
    if (!path.startsWith('/api/fruitinfo')) {
      return HttpResponseUtils.buildErrorResponse('无效的API路径', 404);
    }

    if (!ctx) {
      return HttpResponseUtils.buildErrorResponse('Context 未提供', 500);
    }

    try {
      const pathAndQuery = QueryStringUtils.parsePathAndQuery(path);
      const cleanPath = pathAndQuery.path;
      const params = pathAndQuery.params;
      const upperMethod = method.toUpperCase();
      const pathId = FruitInfoApiHandler.extractIdFromPath(cleanPath);
      const bodyParams = body ? FruitInfoApiHandler.parseRequestBody(body) : new Map<string, string>();

      if (upperMethod === 'GET' && cleanPath === '/api/fruitinfo') {
        return await FruitInfoApiHandler.handleList(params, ctx);
      }

      if (upperMethod === 'GET' && pathId !== null) {
        return await FruitInfoApiHandler.handleGetById(pathId, ctx);
      }

      if (upperMethod === 'POST' && cleanPath === '/api/fruitinfo/batch') {
        return await FruitInfoApiHandler.handleBatchInsert(body, ctx);
      }

      if (upperMethod === 'POST' && cleanPath === '/api/fruitinfo') {
        return await FruitInfoApiHandler.handleInsert(bodyParams, ctx);
      }

      if (upperMethod === 'PUT' && pathId !== null) {
        return await FruitInfoApiHandler.handleUpdate(pathId, bodyParams, ctx);
      }

      if (upperMethod === 'DELETE' && pathId !== null) {
        return await FruitInfoApiHandler.handleDelete(pathId, ctx);
      }

      return HttpResponseUtils.buildErrorResponse(`方法 ${method} 不允许`, 405);
    } catch (error) {
      hilog.error(DOMAIN, 'FruitInfoApiHandler', `处理请求失败: ${JSON.stringify(error)}`);
      return HttpResponseUtils.buildErrorResponse('服务器内部错误', 500);
    }
  }

  private static async handleList(params: Record<string, string>, ctx: Context): Promise<string> {
    try {
      const page = Math.max(1, Number(params['page'] || '1'));
      const size = Math.max(1, Math.min(100, Number(params['size'] || '20')));

      const list = await FruitInfoService.queryPage(page, size, ctx);
      const total = await FruitInfoService.count(ctx);
      const totalPages = Math.ceil(total / size);

      const pagination: PaginationInfo = { page: page, size: size, total: total, totalPages: totalPages };
      const response: PaginatedResponse = { data: list, pagination: pagination };

      return HttpResponseUtils.buildSuccessResponse(response);
    } catch (error) {
      hilog.error(DOMAIN, 'FruitInfoApiHandler', `查询列表失败: ${JSON.stringify(error)}`);
      return HttpResponseUtils.buildErrorResponse('查询失败', 500);
    }
  }

  private static async handleGetById(id: number, ctx: Context): Promise<string> {
    try {
      const list = await FruitInfoService.queryAll(ctx);
      let item: FruitInfo | undefined = undefined;
      for (const f of list) {
        const fruitInfo = f as FruitInfo;
        if (fruitInfo.CustomerID === id) {
          item = fruitInfo;
          break;
        }
      }
      
      if (!item) {
        return HttpResponseUtils.buildErrorResponse('记录不存在', 404);
      }

      return HttpResponseUtils.buildSuccessResponse(item);
    } catch (error) {
      hilog.error(DOMAIN, 'FruitInfoApiHandler', `查询记录失败: ${JSON.stringify(error)}`);
      return HttpResponseUtils.buildErrorResponse('查询失败', 500);
    }
  }

  private static async handleInsert(data: Map<string, string>, ctx: Context): Promise<string> {
    try {
      const fruitInfo: Partial<FruitInfo> = FruitInfoApiHandler.mapToFruitInfo(data);
      const id = await FruitInfoService.save(fruitInfo, ctx);

      const resp: IdResponse = { id: id };
      return HttpResponseUtils.buildSuccessResponse(resp, '创建成功');
    } catch (error) {
      hilog.error(DOMAIN, 'FruitInfoApiHandler', `创建记录失败: ${JSON.stringify(error)}`);
      return HttpResponseUtils.buildErrorResponse('创建失败', 500);
    }
  }

  private static async handleBatchInsert(body: string | undefined, ctx: Context): Promise<string> {
    if (!body || body.trim().length === 0) {
      return HttpResponseUtils.buildErrorResponse('请求体不能为空', 400);
    }

    try {
      const parsed = JSON.parse(body) as ESObject;
      let records: ESObject[] = [];
      
      if (Array.isArray(parsed)) {
        records = parsed;
      } else {
        const wrapper = parsed as Record<string, ESObject>;
        if (wrapper['records'] && Array.isArray(wrapper['records'])) {
          records = wrapper['records'] as ESObject[];
        }
      }

      if (records.length === 0) {
        return HttpResponseUtils.buildErrorResponse('无有效记录', 400);
      }

      const dataList: Array<Partial<FruitInfo>> = [];
      for (const record of records) {
        const r = record as Record<string, ESObject>;
        const map = new Map<string, string>();
        const keys = Object.keys(r);
        for (const key of keys) {
          map.set(key, String(r[key]));
        }
        dataList.push(FruitInfoApiHandler.mapToFruitInfo(map));
      }

      const count = await FruitInfoService.batchSave(dataList, ctx);
      const resp: InsertedResponse = { inserted: count };
      return HttpResponseUtils.buildSuccessResponse(resp, '批量创建成功');
    } catch (error) {
      hilog.error(DOMAIN, 'FruitInfoApiHandler', `批量创建失败: ${JSON.stringify(error)}`);
      return HttpResponseUtils.buildErrorResponse('批量创建失败', 500);
    }
  }

  private static async handleUpdate(id: number, data: Map<string, string>, ctx: Context): Promise<string> {
    try {
      const fruitInfo: Partial<FruitInfo> = FruitInfoApiHandler.mapToFruitInfo(data);
      const affected = await FruitInfoService.update(id, fruitInfo, ctx);

      if (affected === 0) {
        return HttpResponseUtils.buildErrorResponse('记录不存在', 404);
      }

      const resp: AffectedResponse = { affected: affected };
      return HttpResponseUtils.buildSuccessResponse(resp, '更新成功');
    } catch (error) {
      hilog.error(DOMAIN, 'FruitInfoApiHandler', `更新记录失败: ${JSON.stringify(error)}`);
      return HttpResponseUtils.buildErrorResponse('更新失败', 500);
    }
  }

  private static async handleDelete(id: number, ctx: Context): Promise<string> {
    try {
      const affected = await FruitInfoService.delete(id, ctx);

      if (affected === 0) {
        return HttpResponseUtils.buildErrorResponse('记录不存在', 404);
      }

      const resp: AffectedResponse = { affected: affected };
      return HttpResponseUtils.buildSuccessResponse(resp, '删除成功');
    } catch (error) {
      hilog.error(DOMAIN, 'FruitInfoApiHandler', `删除记录失败: ${JSON.stringify(error)}`);
      return HttpResponseUtils.buildErrorResponse('删除失败', 500);
    }
  }

  private static extractIdFromPath(path: string): number | null {
    const parts = path.split('/');
    if (parts.length >= 4 && parts[3]) {
      const id = Number(parts[3]);
      if (!isNaN(id) && id > 0) {
        return id;
      }
    }
    return null;
  }

  private static parseRequestBody(body: string): Map<string, string> {
    const params = new Map<string, string>();
    if (!body || body.trim().length === 0) {
      return params;
    }

    try {
      const json = JSON.parse(body) as Record<string, ESObject>;
      const keys = Object.keys(json);
      for (const key of keys) {
        const value = json[key];
        if (value !== null && value !== undefined) {
          params.set(key, String(value));
        }
      }
    } catch (e) {
      hilog.warn(DOMAIN, 'FruitInfoApiHandler', `JSON解析失败: ${JSON.stringify(e)}`);
    }
    return params;
  }

  private static mapToFruitInfo(data: Map<string, string>): FruitInfo {
    const info = new FruitInfo();

    const customerId = data.get('CustomerID');
    if (customerId) info.CustomerID = Number(customerId);
    const sysId = data.get('SysID');
    if (sysId) info.SysID = Number(sysId);
    const feedPortId = data.get('FeedPortID');
    if (feedPortId) info.FeedPortID = Number(feedPortId);
    const majorCustomerId = data.get('MajorCustomerID');
    if (majorCustomerId) info.MajorCustomerID = Number(majorCustomerId);
    const fBatchNo = data.get('FBatchNo');
    if (fBatchNo) info.FBatchNo = fBatchNo;
    const orderId = data.get('OrderID');
    if (orderId) info.OrderID = Number(orderId);
    const chainIdx = data.get('ChainIdx');
    if (chainIdx) info.ChainIdx = chainIdx;
    const customerName = data.get('CustomerName');
    if (customerName) info.CustomerName = customerName;
    const farmName = data.get('FarmName');
    if (farmName) info.FarmName = farmName;
    const fruitName = data.get('FruitName');
    if (fruitName) info.FruitName = fruitName;
    const startTime = data.get('StartTime');
    if (startTime) info.StartTime = startTime;
    const endTime = data.get('EndTime');
    if (endTime) info.EndTime = endTime;
    const startedState = data.get('StartedState');
    if (startedState) info.StartedState = startedState;
    const completedState = data.get('CompletedState');
    if (completedState) info.CompletedState = completedState;
    const batchWeight = data.get('BatchWeight');
    if (batchWeight) info.BatchWeight = Number(batchWeight);
    const batchNumber = data.get('BatchNumber');
    if (batchNumber) info.BatchNumber = Number(batchNumber);
    const sortType = data.get('SortType');
    if (sortType) info.SortType = Number(sortType);
    const systemNum = data.get('SystemNum');
    if (systemNum) info.SystemNum = Number(systemNum);
    const sizeIdNum = data.get('SizeIDNum');
    if (sizeIdNum) info.SizeIDNum = Number(sizeIdNum);
    const channelNum = data.get('ChannelNum');
    if (channelNum) info.ChannelNum = Number(channelNum);
    const qualityGradeSum = data.get('QualityGradeSum');
    if (qualityGradeSum) info.QualityGradeSum = Number(qualityGradeSum);
    const weightOrSizeGradeSum = data.get('WeightOrSizeGradeSum');
    if (weightOrSizeGradeSum) info.WeightOrSizeGradeSum = Number(weightOrSizeGradeSum);
    const colorGradeName = data.get('ColorGradeName');
    if (colorGradeName) info.ColorGradeName = colorGradeName;
    const shapeGradeName = data.get('ShapeGradeName');
    if (shapeGradeName) info.ShapeGradeName = shapeGradeName;
    const flawGradeName = data.get('FlawGradeName');
    if (flawGradeName) info.FlawGradeName = flawGradeName;
    const hardGradeName = data.get('HardGradeName');
    if (hardGradeName) info.HardGradeName = hardGradeName;
    const densityGradeName = data.get('DensityGradeName');
    if (densityGradeName) info.DensityGradeName = densityGradeName;
    const sugarDegreeGradeName = data.get('SugarDegreeGradeName');
    if (sugarDegreeGradeName) info.SugarDegreeGradeName = sugarDegreeGradeName;
    const exportSum = data.get('ExportSum');
    if (exportSum) info.ExportSum = Number(exportSum);
    const programName = data.get('ProgramName');
    if (programName) info.ProgramName = programName;

    return info;
  }
}
