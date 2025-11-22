import { hilog } from '@kit.PerformanceAnalysisKit';
import { IBestORMInit, GetIBestORM } from '../../../../database/orm';
import { QueryStringUtils } from '../../../helpers/QueryStringUtils';
import { DateValidationUtils } from '../../../helpers/DateValidationUtils';
import { HttpResponseUtils } from '../../../helpers/HttpResponseUtils';
import { ProcessingHistory } from '../../../../database/models/ProcessingHistory';
import { ProcessingHistoryData } from '../../../../database/types';
import { relationalStore } from '@kit.ArkData';
import { taskpool } from '@kit.ArkTS';
import { Context } from '@kit.AbilityKit';
import { common } from '@kit.AbilityKit';

const DOMAIN = 0x0000;

class ProcessingRow {
  id?: number;
  startTime: string;
  endTime: string;
  productType: string;
  totalWeight: number;
  customerName?: string;
  farmName?: string;
  fruitName?: string;
  status?: string;
  count?: number;
  weight?: number;

  constructor(record: ProcessingHistoryData) {
    this.id = record.ID || record.id;
    this.startTime = record.StartTime || '';
    this.endTime = record.EndTime || '';
    this.productType = record.FruitName || '';
    this.totalWeight = record.Weight || 0;
    this.customerName = record.CustomerName || '';
    this.farmName = record.FarmName || '';
    this.fruitName = record.FruitName || '';
    this.status = record.Status || '';
    this.count = record.Quantity || 0;
    this.weight = record.Weight || 0;
  }
}

/**
 * 分页信息接口
 */
interface PaginationInfo {
  page: number;
  size: number;
  total: number;
  totalPages: number;
}

/**
 * 分页响应接口
 */
interface PaginatedResponse {
  data: ProcessingRow[];
  pagination: PaginationInfo;
}

/**
 * 加工历史API处理器
 * 负责处理 /api/processing 相关的所有请求（RESTful 风格）
 */
// 并发函数内部使用本地配置，避免捕获外部常量，满足 ArkTS 并发限制

@Concurrent
export async function PH_QueryAll(ctx: Context): Promise<ProcessingHistoryData[]> {
  const config: relationalStore.StoreConfig = { name: 'article.db', securityLevel: relationalStore.SecurityLevel.S2 };
  let initialized = true;
  try {
    GetIBestORM().AutoMigrate(ProcessingHistory);
  } catch (e) {
    initialized = false;
  }
  if (!initialized) {
    await IBestORMInit(ctx as common.UIAbilityContext, config);
    GetIBestORM().AutoMigrate(ProcessingHistory);
  }
  const dbRecords = GetIBestORM().Table('processing_history').Find(ProcessingHistory) as ProcessingHistoryData[];
  return dbRecords || [];
}

@Concurrent
export async function PH_Insert(ctx: Context, values: relationalStore.ValuesBucket): Promise<number> {
  const config: relationalStore.StoreConfig = { name: 'article.db', securityLevel: relationalStore.SecurityLevel.S2 };
  let initialized = true;
  try {
    GetIBestORM().AutoMigrate(ProcessingHistory);
  } catch (e) {
    initialized = false;
  }
  if (!initialized) {
    await IBestORMInit(ctx as common.UIAbilityContext, config);
    GetIBestORM().AutoMigrate(ProcessingHistory);
  }
  const insertId = GetIBestORM().Table('processing_history').Insert(values);
  return insertId || 0;
}

@Concurrent
export async function PH_Delete(ctx: Context, id: number): Promise<number> {
  const config: relationalStore.StoreConfig = { name: 'article.db', securityLevel: relationalStore.SecurityLevel.S2 };
  let initialized = true;
  try {
    GetIBestORM().AutoMigrate(ProcessingHistory);
  } catch (e) {
    initialized = false;
  }
  if (!initialized) {
    await IBestORMInit(ctx as common.UIAbilityContext, config);
    GetIBestORM().AutoMigrate(ProcessingHistory);
  }
  const affected = GetIBestORM().Table('processing_history').Where('id', id).Delete();
  return affected || 0;
}

@Concurrent
export async function PH_Update(ctx: Context, id: number, values: relationalStore.ValuesBucket): Promise<number> {
  const config: relationalStore.StoreConfig = { name: 'article.db', securityLevel: relationalStore.SecurityLevel.S2 };
  let initialized = true;
  try {
    GetIBestORM().AutoMigrate(ProcessingHistory);
  } catch (e) {
    initialized = false;
  }
  if (!initialized) {
    await IBestORMInit(ctx as common.UIAbilityContext, config);
    GetIBestORM().AutoMigrate(ProcessingHistory);
  }
  const affected = GetIBestORM().Table('processing_history').Where('id', id).Update(values);
  return affected || 0;
}

export class ProcessingApiHandler {
  /**
   * 将数据库记录转换为前端格式
   */
  private static convertToProcessingRow(record: ProcessingHistoryData): ProcessingRow {
    return new ProcessingRow(record);
  }

  /**
   * 获取所有记录并转换为前端格式
   */
  private static async getAllRecordsAsRowsTask(ctx?: Context): Promise<ProcessingRow[]> {
    let dbRecords: ProcessingHistoryData[] = [];
    if (ctx) {
      const task = new taskpool.Task(PH_QueryAll, ctx);
      dbRecords = await taskpool.execute(task) as ProcessingHistoryData[];
    } else {
      const db = GetIBestORM();
      dbRecords = db.Table('processing_history').Find(ProcessingHistory) as ProcessingHistoryData[];
    }
    const rows: ProcessingRow[] = [];
    for (let i = 0; i < dbRecords.length; i++) {
      rows.push(ProcessingApiHandler.convertToProcessingRow(dbRecords[i]));
    }
    return rows;
  }

  /**
   * 处理列表查询请求（支持分页）
   */
  private static async handleList(params: Record<string, string>, ctx?: Context): Promise<string> {
    try {
      const allRows = await ProcessingApiHandler.getAllRecordsAsRowsTask(ctx);
      
      // 分页参数
      const page = Math.max(1, Number(params['page'] || '1'));
      const size = Math.max(1, Math.min(100, Number(params['size'] || '20'))); // 限制每页最多100条
      
      const total = allRows.length;
      const totalPages = Math.ceil(total / size);
      const startIndex = (page - 1) * size;
      const endIndex = startIndex + size;
      const paginatedData = allRows.slice(startIndex, endIndex);
      
      const paginationInfo: PaginationInfo = {
        page: page,
        size: size,
        total: total,
        totalPages: totalPages
      };
      const response: PaginatedResponse = {
        data: paginatedData,
        pagination: paginationInfo
      };
      
      return HttpResponseUtils.buildSuccessResponse(response);
    } catch (error) {
      hilog.error(DOMAIN, 'ProcessingApiHandler', `从数据库查询失败: ${JSON.stringify(error)}`);
      return HttpResponseUtils.buildErrorResponse('查询数据失败', 500);
    }
  }

  /**
   * 处理列表查询请求（兼容旧版本，无分页）
   */
  private static async handleListJson(ctx?: Context): Promise<string> {
    try {
      const data = await ProcessingApiHandler.getAllRecordsAsRowsTask(ctx);
      return HttpResponseUtils.buildSuccessResponse(data);
    } catch (error) {
      hilog.error(DOMAIN, 'ProcessingApiHandler', `从数据库查询失败: ${JSON.stringify(error)}`);
      return HttpResponseUtils.buildErrorResponse('查询数据失败', 500);
    }
  }

  /**
   * 处理插入请求
   */
  private static async handleInsert(params: Record<string, string>, ctx?: Context): Promise<string> {
    // 统一时间格式：将 ISO 8601 的 'T' 安全替换为空格，便于显示与后续处理
    const startTimeRaw = params['startTime'] || '';
    const endTimeRaw = params['endTime'] || '';
    const startTime = startTimeRaw ? startTimeRaw.replace('T', ' ') : '';
    const endTime = endTimeRaw ? endTimeRaw.replace('T', ' ') : '';
    const productType = params['productType'] || '';
    const totalWeight = Number(params['totalWeight'] || '0');
    const customerName = params['customerName'] || '';
    const farmName = params['farmName'] || '';
    const fruitName = params['fruitName'] || productType;
    const status = params['status'] || '';
    const count = Number(params['count'] || '0');
    const weight = Number(params['weight'] || totalWeight || '0');

    // 参数校验：非空
    if (!startTime || !endTime || !fruitName || !(params['totalWeight'] || params['weight'] || '').toString().length) {
      return HttpResponseUtils.buildErrorResponse('参数不能为空', 400);
    }

    // 使用工具类验证日期范围
    const dateValidation = DateValidationUtils.validateDateRange(startTime, endTime);
    if (!dateValidation.isValid) {
      return HttpResponseUtils.buildErrorResponse(dateValidation.error || '日期验证失败', 400);
    }

    try {
      hilog.info(DOMAIN, 'ProcessingApiHandler', `准备插入数据: customerName=${customerName}, farmName=${farmName}, fruitName=${fruitName}, startTime=${startTime}, endTime=${endTime}, weight=${weight}, count=${count}`);
      const values: relationalStore.ValuesBucket = {
        customer_name: customerName,
        farm_name: farmName,
        fruit_name: fruitName,
        status: status,
        start_time: startTime,
        end_time: endTime,
        weight: weight,
        quantity: count,
      };
      const before = await ProcessingApiHandler.getAllRecordsAsRowsTask(ctx);
      hilog.info(DOMAIN, 'ProcessingApiHandler', `插入前查询到 ${before.length} 条记录`);
      const task = new taskpool.Task(PH_Insert, ctx as Context, values);
      const insertId = await taskpool.execute(task) as number;
      hilog.info(DOMAIN, 'ProcessingApiHandler', `插入数据结果: id=${insertId}`);
      const after = await ProcessingApiHandler.getAllRecordsAsRowsTask(ctx);
      hilog.info(DOMAIN, 'ProcessingApiHandler', `插入后查询到 ${after.length} 条记录`);
      if (after.length <= before.length) {
        hilog.warn(DOMAIN, 'ProcessingApiHandler', `插入后数据量未增加！插入前: ${before.length}, 插入后: ${after.length}`);
      }
      return HttpResponseUtils.buildSuccessResponse(after, '添加成功');
    } catch (error) {
      hilog.error(DOMAIN, 'ProcessingApiHandler', `保存到数据库失败: ${JSON.stringify(error)}`);
      return HttpResponseUtils.buildErrorResponse('保存数据失败', 500);
    }
  }

  /**
   * 处理更新请求
   */
  private static async handleUpdate(params: Record<string, string>, ctx?: Context): Promise<string> {
    const id = Number(params['id'] || '0');
    if (!id || id <= 0) {
      return HttpResponseUtils.buildErrorResponse('ID无效或未提供', 400);
    }

    try {
      const values: relationalStore.ValuesBucket = {};
      if (params['customerName'] !== undefined) values['customer_name'] = params['customerName'];
      if (params['farmName'] !== undefined) values['farm_name'] = params['farmName'];
      const fruitNameParam = params['fruitName'] !== undefined ? params['fruitName'] : (params['productType'] !== undefined ? params['productType'] : undefined);
      if (fruitNameParam !== undefined) values['fruit_name'] = fruitNameParam;
      if (params['status'] !== undefined) values['status'] = params['status'];
      if (params['startTime'] !== undefined) values['start_time'] = params['startTime'].replace('T', ' ');
      if (params['endTime'] !== undefined) values['end_time'] = params['endTime'].replace('T', ' ');
      if (params['weight'] !== undefined) values['weight'] = Number(params['weight']);
      if (params['totalWeight'] !== undefined) values['weight'] = Number(params['totalWeight']);
      if (params['count'] !== undefined) values['quantity'] = Number(params['count']);
      const task = new taskpool.Task(PH_Update, ctx as Context, id, values);
      await taskpool.execute(task);
      const data = await ProcessingApiHandler.getAllRecordsAsRowsTask(ctx);
      return HttpResponseUtils.buildSuccessResponse(data, '更新成功');
    } catch (error) {
      hilog.error(DOMAIN, 'ProcessingApiHandler', `更新数据库失败: ${JSON.stringify(error)}`);
      return HttpResponseUtils.buildErrorResponse('更新数据失败', 500);
    }
  }

  /**
   * 处理删除请求
   */
  private static async handleDelete(params: Record<string, string>, ctx?: Context): Promise<string> {
    const id = Number(params['id'] || '0');
    if (!id || id <= 0) {
      return HttpResponseUtils.buildErrorResponse('ID无效或未提供', 400);
    }

    try {
      const existing = await ProcessingApiHandler.getAllRecordsAsRowsTask(ctx);
      const found = existing.some(r => r.id === id);
      if (!found) {
        return HttpResponseUtils.buildErrorResponse('记录不存在', 404);
      }
      const task = new taskpool.Task(PH_Delete, ctx as Context, id);
      await taskpool.execute(task);
      const data = await ProcessingApiHandler.getAllRecordsAsRowsTask(ctx);
      return HttpResponseUtils.buildSuccessResponse(data, '删除成功');
    } catch (error) {
      hilog.error(DOMAIN, 'ProcessingApiHandler', `删除数据库失败: ${JSON.stringify(error)}`);
      return HttpResponseUtils.buildErrorResponse('删除数据失败', 500);
    }
  }

  /**
   * 从请求体中解析 JSON
   */
  private static parseRequestBody(body: string): Record<string, string> {
    const params: Record<string, string> = {};
    if (!body || body.trim().length === 0) {
      return params;
    }
    
    try {
      const json: Record<string, ESObject> = JSON.parse(body) as Record<string, ESObject>;
      const keys = Object.keys(json);
      for (let i = 0; i < keys.length; i++) {
        const key = keys[i];
        const value: ESObject = json[key];
        if (value !== null && value !== undefined) {
          params[key] = String(value);
        }
      }
    } catch (e) {
      // 如果不是 JSON，尝试解析为表单格式
      hilog.warn(DOMAIN, 'ProcessingApiHandler', `JSON解析失败，尝试表单格式: ${JSON.stringify(e)}`);
      const pairs = body.split('&');
      for (let i = 0; i < pairs.length; i++) {
        const kv = pairs[i].split('=');
        const k = decodeURIComponent(kv[0] || '');
        const v = decodeURIComponent(kv[1] || '');
        if (k) {
          params[k] = v;
        }
      }
    }
    return params;
  }

  /**
   * 合并查询参数和请求体参数（请求体优先级更高）
   */
  private static mergeParams(queryParams: Record<string, string>, bodyParams: Record<string, string>): Record<string, string> {
    const merged: Record<string, string> = {};
    // 先添加查询参数
    const queryKeys = Object.keys(queryParams);
    for (let i = 0; i < queryKeys.length; i++) {
      merged[queryKeys[i]] = queryParams[queryKeys[i]];
    }
    // 再添加请求体参数（覆盖查询参数）
    const bodyKeys = Object.keys(bodyParams);
    for (let i = 0; i < bodyKeys.length; i++) {
      merged[bodyKeys[i]] = bodyParams[bodyKeys[i]];
    }
    return merged;
  }

  /**
   * 从路径中提取 ID（如 /api/processing/123）
   */
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

  /**
   * 处理加工历史API请求（RESTful 风格）
   * @param method HTTP 方法（GET, POST, PUT, DELETE）
   * @param path 请求路径，如 /api/processing 或 /api/processing/123
   * @param body 请求体（POST/PUT 请求）
   */
  static async handle(method: string, path: string, body?: string, ctx?: Context): Promise<string> {
    hilog.info(DOMAIN, 'ProcessingApiHandler', `收到请求: ${method} ${path}`);
    
    if (path.indexOf('/api/processing') !== 0) {
      return HttpResponseUtils.buildErrorResponse('无效的API路径', 404);
    }

    try {
      const pathAndQuery = QueryStringUtils.parsePathAndQuery(path);
      const queryParams = pathAndQuery.params;
      const cleanPath = pathAndQuery.path;
      
      // 解析请求体（如果有）
      const emptyBodyParams: Record<string, string> = {};
      const bodyParams = body ? ProcessingApiHandler.parseRequestBody(body) : emptyBodyParams;
      const params = ProcessingApiHandler.mergeParams(queryParams, bodyParams);
      
      hilog.info(DOMAIN, 'ProcessingApiHandler', `解析参数: action=${params['action']}, method=${method}, cleanPath=${cleanPath}`);
      
      // 从路径中提取 ID（如 /api/processing/123）
      const pathId = ProcessingApiHandler.extractIdFromPath(cleanPath);
      if (pathId !== null) {
        params['id'] = String(pathId);
      }

      // RESTful 风格路由
      const upperMethod = method.toUpperCase();
      
      // GET /api/processing - 获取列表（支持分页）
      if (upperMethod === 'GET' && cleanPath === '/api/processing') {
        // 兼容旧版本：如果 action=listJson，使用旧接口
        if (params['action'] === 'listJson') {
          return await ProcessingApiHandler.handleListJson(ctx);
        }
        // 兼容旧版本：GET 请求也可以用于 insert（虽然不符合 RESTful 规范）
        if (params['action'] === 'insert') {
          hilog.info(DOMAIN, 'ProcessingApiHandler', 'GET 请求的 insert action，调用 handleInsert');
          return await ProcessingApiHandler.handleInsert(params, ctx);
        }
        return await ProcessingApiHandler.handleList(params, ctx);
      }
      
      // GET /api/processing/:id - 获取单条记录（暂不支持，返回404）
      if (upperMethod === 'GET' && pathId !== null) {
        return HttpResponseUtils.buildErrorResponse('获取单条记录接口暂未实现', 404);
      }
      
      // POST /api/processing - 创建记录
      if (upperMethod === 'POST' && cleanPath === '/api/processing') {
        // 兼容旧版本：如果 action=insert，使用旧接口
        if (params['action'] === 'insert') {
          return await ProcessingApiHandler.handleInsert(params, ctx);
        }
        return await ProcessingApiHandler.handleInsert(params, ctx);
      }
      
      // PUT /api/processing/:id - 更新记录
      if (upperMethod === 'PUT' && pathId !== null) {
        return await ProcessingApiHandler.handleUpdate(params, ctx);
      }
      
      // DELETE /api/processing/:id - 删除记录
      if (upperMethod === 'DELETE' && pathId !== null) {
        return await ProcessingApiHandler.handleDelete(params, ctx);
      }
      
      // 兼容旧版本：通过 action 参数
      if (params['action']) {
        const action = params['action'];
        switch (action) {
          case 'listJson':
            return await ProcessingApiHandler.handleListJson(ctx);
          case 'insert':
            return await ProcessingApiHandler.handleInsert(params, ctx);
          case 'update':
            return await ProcessingApiHandler.handleUpdate(params, ctx);
          case 'delete':
            return await ProcessingApiHandler.handleDelete(params, ctx);
          default:
            return HttpResponseUtils.buildErrorResponse(`未知的action: ${action}`, 400);
        }
      }
      
      // 方法不允许
      return HttpResponseUtils.buildErrorResponse(`方法 ${method} 不允许在此路径使用`, 405);
    } catch (e) {
      hilog.error(DOMAIN, 'ProcessingApiHandler', `处理API请求失败: ${JSON.stringify(e)}`);
      return HttpResponseUtils.buildErrorResponse('服务器内部错误', 500);
    }
  }
}

