import { hilog } from '@kit.PerformanceAnalysisKit';
import { Context } from '@kit.AbilityKit';
import { HttpResponseUtils } from '../../../helpers/HttpResponseUtils';
import { QueryStringUtils } from '../../../helpers/QueryStringUtils';
import { GradeInfoService } from '../../../../database/services/GradeInfoService';
import { GradeInfo } from '../../../../database/models/GradeInfo';

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
  data: GradeInfo[];
  pagination: PaginationInfo;
}

/**
 * 等级信息 API 处理器
 */
export class GradeInfoApiHandler {

  static async handle(method: string, path: string, body?: string, ctx?: Context): Promise<string> {
    if (!path.startsWith('/api/gradeinfo')) {
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

      if (upperMethod === 'GET' && cleanPath === '/api/gradeinfo') {
        return await GradeInfoApiHandler.handleList(params, ctx);
      }

      if (upperMethod === 'GET' && cleanPath.startsWith('/api/gradeinfo/customer/')) {
        const customerId = GradeInfoApiHandler.extractSubPathId(cleanPath, 'customer');
        if (customerId !== null) {
          return await GradeInfoApiHandler.handleGetByCustomerId(customerId, ctx);
        }
      }

      const pathId = GradeInfoApiHandler.extractIdFromPath(cleanPath);
      const bodyParams = body ? GradeInfoApiHandler.parseRequestBody(body) : new Map<string, string>();

      if (upperMethod === 'GET' && pathId !== null) {
        return await GradeInfoApiHandler.handleGetById(pathId, ctx);
      }

      if (upperMethod === 'POST' && cleanPath === '/api/gradeinfo/batch') {
        return await GradeInfoApiHandler.handleBatchInsert(body, ctx);
      }

      if (upperMethod === 'POST' && cleanPath === '/api/gradeinfo') {
        return await GradeInfoApiHandler.handleInsert(bodyParams, ctx);
      }

      if (upperMethod === 'PUT' && pathId !== null) {
        return await GradeInfoApiHandler.handleUpdate(pathId, bodyParams, ctx);
      }

      if (upperMethod === 'DELETE' && pathId !== null) {
        return await GradeInfoApiHandler.handleDelete(pathId, ctx);
      }

      return HttpResponseUtils.buildErrorResponse(`方法 ${method} 不允许`, 405);
    } catch (error) {
      hilog.error(DOMAIN, 'GradeInfoApiHandler', `处理请求失败: ${JSON.stringify(error)}`);
      return HttpResponseUtils.buildErrorResponse('服务器内部错误', 500);
    }
  }

  private static async handleList(params: Record<string, string>, ctx: Context): Promise<string> {
    try {
      const page = Math.max(1, Number(params['page'] || '1'));
      const size = Math.max(1, Math.min(100, Number(params['size'] || '20')));

      const list = await GradeInfoService.queryPage(page, size, ctx);
      const total = await GradeInfoService.count(ctx);
      const totalPages = Math.ceil(total / size);

      const pagination: PaginationInfo = { page: page, size: size, total: total, totalPages: totalPages };
      const response: PaginatedResponse = { data: list, pagination: pagination };

      return HttpResponseUtils.buildSuccessResponse(response);
    } catch (error) {
      hilog.error(DOMAIN, 'GradeInfoApiHandler', `查询列表失败: ${JSON.stringify(error)}`);
      return HttpResponseUtils.buildErrorResponse('查询失败', 500);
    }
  }

  private static async handleGetById(id: number, ctx: Context): Promise<string> {
    try {
      const list = await GradeInfoService.queryAll(ctx);
      let item: GradeInfo | undefined = undefined;
      for (const g of list) {
        const gradeInfo = g as GradeInfo;
        if (gradeInfo.FID === id) {
          item = gradeInfo;
          break;
        }
      }
      
      if (!item) {
        return HttpResponseUtils.buildErrorResponse('记录不存在', 404);
      }

      return HttpResponseUtils.buildSuccessResponse(item);
    } catch (error) {
      hilog.error(DOMAIN, 'GradeInfoApiHandler', `查询记录失败: ${JSON.stringify(error)}`);
      return HttpResponseUtils.buildErrorResponse('查询失败', 500);
    }
  }

  private static async handleGetByCustomerId(customerId: number, ctx: Context): Promise<string> {
    try {
      const list = await GradeInfoService.queryByCustomerId(ctx, customerId);
      return HttpResponseUtils.buildSuccessResponse(list);
    } catch (error) {
      hilog.error(DOMAIN, 'GradeInfoApiHandler', `根据客户ID查询失败: ${JSON.stringify(error)}`);
      return HttpResponseUtils.buildErrorResponse('查询失败', 500);
    }
  }

  private static async handleInsert(data: Map<string, string>, ctx: Context): Promise<string> {
    try {
      const gradeInfo: Partial<GradeInfo> = GradeInfoApiHandler.mapToGradeInfo(data);
      const id = await GradeInfoService.save(gradeInfo, ctx);

      const resp: IdResponse = { id: id };
      return HttpResponseUtils.buildSuccessResponse(resp, '创建成功');
    } catch (error) {
      hilog.error(DOMAIN, 'GradeInfoApiHandler', `创建记录失败: ${JSON.stringify(error)}`);
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

      const dataList: Array<Partial<GradeInfo>> = [];
      for (const record of records) {
        const r = record as Record<string, ESObject>;
        const map = new Map<string, string>();
        const keys = Object.keys(r);
        for (const key of keys) {
          map.set(key, String(r[key]));
        }
        dataList.push(GradeInfoApiHandler.mapToGradeInfo(map));
      }

      const count = await GradeInfoService.batchSave(dataList, ctx);
      const resp: InsertedResponse = { inserted: count };
      return HttpResponseUtils.buildSuccessResponse(resp, '批量创建成功');
    } catch (error) {
      hilog.error(DOMAIN, 'GradeInfoApiHandler', `批量创建失败: ${JSON.stringify(error)}`);
      return HttpResponseUtils.buildErrorResponse('批量创建失败', 500);
    }
  }

  private static async handleUpdate(id: number, data: Map<string, string>, ctx: Context): Promise<string> {
    try {
      const gradeInfo: Partial<GradeInfo> = GradeInfoApiHandler.mapToGradeInfo(data);
      const affected = await GradeInfoService.update(id, gradeInfo, ctx);

      if (affected === 0) {
        return HttpResponseUtils.buildErrorResponse('记录不存在', 404);
      }

      const resp: AffectedResponse = { affected: affected };
      return HttpResponseUtils.buildSuccessResponse(resp, '更新成功');
    } catch (error) {
      hilog.error(DOMAIN, 'GradeInfoApiHandler', `更新记录失败: ${JSON.stringify(error)}`);
      return HttpResponseUtils.buildErrorResponse('更新失败', 500);
    }
  }

  private static async handleDelete(id: number, ctx: Context): Promise<string> {
    try {
      const affected = await GradeInfoService.delete(id, ctx);

      if (affected === 0) {
        return HttpResponseUtils.buildErrorResponse('记录不存在', 404);
      }

      const resp: AffectedResponse = { affected: affected };
      return HttpResponseUtils.buildSuccessResponse(resp, '删除成功');
    } catch (error) {
      hilog.error(DOMAIN, 'GradeInfoApiHandler', `删除记录失败: ${JSON.stringify(error)}`);
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

  private static extractSubPathId(path: string, subPath: string): number | null {
    const prefix = `/api/gradeinfo/${subPath}/`;
    if (path.startsWith(prefix)) {
      const idStr = path.substring(prefix.length);
      const id = Number(idStr);
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
      hilog.warn(DOMAIN, 'GradeInfoApiHandler', `JSON解析失败: ${JSON.stringify(e)}`);
    }
    return params;
  }

  private static mapToGradeInfo(data: Map<string, string>): GradeInfo {
    const info = new GradeInfo();

    const fid = data.get('FID');
    if (fid) info.FID = Number(fid);
    const customerId = data.get('CustomerID');
    if (customerId) info.CustomerID = Number(customerId);
    const channelId = data.get('ChannelID');
    if (channelId) info.ChannelID = Number(channelId);
    const qualityIndex = data.get('QualityIndex');
    if (qualityIndex) info.QualityIndex = Number(qualityIndex);
    const sizeId = data.get('SizeID');
    if (sizeId) info.SizeID = Number(sizeId);
    const sizeIndex = data.get('SizeIndex');
    if (sizeIndex) info.SizeIndex = Number(sizeIndex);
    const boxNumber = data.get('BoxNumber');
    if (boxNumber) info.BoxNumber = Number(boxNumber);
    const boxWeight = data.get('BoxWeight');
    if (boxWeight) info.BoxWeight = Number(boxWeight);
    const fruitNumber = data.get('FruitNumber');
    if (fruitNumber) info.FruitNumber = Number(fruitNumber);
    const fruitWeight = data.get('FruitWeight');
    if (fruitWeight) info.FruitWeight = Number(fruitWeight);
    const fPrice = data.get('FPrice');
    if (fPrice) info.FPrice = Number(fPrice);
    const gradeId = data.get('GradeID');
    if (gradeId) info.GradeID = Number(gradeId);
    const qualityName = data.get('QualityName');
    if (qualityName) info.QualityName = qualityName;
    const weightOrSizeName = data.get('WeightOrSizeName');
    if (weightOrSizeName) info.WeightOrSizeName = weightOrSizeName;
    const weightOrSizeLimit = data.get('WeightOrSizeLimit');
    if (weightOrSizeLimit) info.WeightOrSizeLimit = Number(weightOrSizeLimit);
    const selectWeightOrSize = data.get('SelectWeightOrSize');
    if (selectWeightOrSize) info.SelectWeightOrSize = selectWeightOrSize;
    const traitWeightOrSize = data.get('TraitWeightOrSize');
    if (traitWeightOrSize) info.TraitWeightOrSize = traitWeightOrSize;
    const traitColor = data.get('TraitColor');
    if (traitColor) info.TraitColor = traitColor;
    const traitShape = data.get('TraitShape');
    if (traitShape) info.TraitShape = traitShape;
    const traitFlaw = data.get('TraitFlaw');
    if (traitFlaw) info.TraitFlaw = traitFlaw;
    const traitHard = data.get('TraitHard');
    if (traitHard) info.TraitHard = traitHard;
    const traitDensity = data.get('TraitDensity');
    if (traitDensity) info.TraitDensity = traitDensity;
    const traitSugarDegree = data.get('TraitSugarDegree');
    if (traitSugarDegree) info.TraitSugarDegree = traitSugarDegree;

    return info;
  }
}
