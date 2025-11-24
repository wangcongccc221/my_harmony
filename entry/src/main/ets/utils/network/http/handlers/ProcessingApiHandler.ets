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
import { DatabaseQueueManager } from '../../database';

const DOMAIN = 0x0000;

interface ProcessingRow {
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

interface LiteListStats {
  page: number;
  size: number;
  total: number;
  totalPages: number;
  count: number;
}

interface InsertIdResponse {
  id: number;
}

interface PackedList {
  schema: string[];
  rows: Array<Array<string | number>>;
}

interface PackedSuccessResponse {
  ok: boolean;
  data: PackedList;
}

interface RowsSuccessResponse {
  ok: boolean;
  data: ProcessingRow[];
}

interface BatchInsertResult {
  inserted: number;
}

interface BatchInsertRecord {
  customerName?: string;
  farmName?: string;
  fruitName?: string;
  productType?: string;
  status?: string;
  startTime?: string;
  endTime?: string;
  totalWeight?: number;
  weight?: number;
  count?: number;
}

interface BatchInsertWrapper {
  records: BatchInsertRecord[];
}


@Concurrent
export async function PH_QueryAll(ctx: Context): Promise<ProcessingHistoryData[]> {
  const config: relationalStore.StoreConfig = { name: 'article.db', securityLevel: relationalStore.SecurityLevel.S2 };
  let initialized = true;
  try {
    GetIBestORM().AutoMigrate(ProcessingHistory);
    ProcessingHistory.createIndexes();
  } catch (e) {
    initialized = false;
  }
  if (!initialized) {
    await IBestORMInit(ctx as common.UIAbilityContext, config);
    GetIBestORM().AutoMigrate(ProcessingHistory);
    ProcessingHistory.createIndexes();
  }
  // 性能优化：直接查询，不使用OrderBy（查询全部数据时不需要排序）
  const dbRecords = GetIBestORM().Table('processing_history').Find(ProcessingHistory) as ProcessingHistoryData[];
  return dbRecords || [];
}

@Concurrent
export async function PH_CountAll(ctx: Context): Promise<number> {
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
  const db = GetIBestORM();
  const core = db.GetCore();
  let total = 0;
  const rs = core!.querySqlSync("SELECT COUNT(*) AS cnt FROM processing_history;");
  if (rs.columnCount > 0 && rs.goToFirstRow()) {
    const col = rs.columnNames[0];
    total = rs.getDouble(rs.getColumnIndex(col)) as number;
  }
  rs.close();
  return total;
}

@Concurrent
export async function PH_QueryPage(ctx: Context, page: number, size: number): Promise<ProcessingHistoryData[]> {
  const config: relationalStore.StoreConfig = { name: 'article.db', securityLevel: relationalStore.SecurityLevel.S2 };
  let initialized = true;
  try {
    GetIBestORM().AutoMigrate(ProcessingHistory);
    ProcessingHistory.createIndexes();
  } catch (e) {
    initialized = false;
  }
  if (!initialized) {
    await IBestORMInit(ctx as common.UIAbilityContext, config);
    GetIBestORM().AutoMigrate(ProcessingHistory);
    ProcessingHistory.createIndexes();
  }
  const p = Math.max(1, page);
  const s = Math.max(1, Math.min(100, size));
  const offset = (p - 1) * s;
  const db = GetIBestORM();
  // 性能优化：使用id字段进行排序（已创建索引，性能更好）
  const rows = db.Table('processing_history').OrderByDesc('id').Limit(s).Offset(offset).Find(ProcessingHistory) as ProcessingHistoryData[];
  return rows || [];
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
export async function PH_BatchInsert(ctx: Context, values: Array<relationalStore.ValuesBucket>): Promise<number> {
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
  const affected = GetIBestORM().Table('processing_history').Insert(values);
  return affected || 0;
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
   * 将数据库记录转换为前端格式（优化版：直接构建对象，避免构造函数调用）
   */
  private static convertToProcessingRow(record: ProcessingHistoryData): ProcessingRow {
    // 性能优化：直接构建对象字面量，避免构造函数调用开销
    return {
      id: record.ID || record.id,
      startTime: record.StartTime || '',
      endTime: record.EndTime || '',
      productType: record.FruitName || '',
      totalWeight: record.Weight || 0,
      customerName: record.CustomerName || '',
      farmName: record.FarmName || '',
      fruitName: record.FruitName || '',
      status: record.Status || '',
      count: record.Quantity || 0,
      weight: record.Weight || 0
    };
  }

  /**
   * 批量转换数据库记录为前端格式（优化版：预分配数组，减少重复字段访问）
   */
  private static convertBatchToProcessingRows(records: ProcessingHistoryData[]): ProcessingRow[] {
    const rows: ProcessingRow[] = [];
    rows.length = records.length; // 预分配数组大小
    
    // 性能优化：直接构建对象，缓存重复访问的字段
    for (let i = 0; i < records.length; i++) {
      const record = records[i];
      // 性能优化：缓存重复访问的字段
      const id = record.ID || record.id;
      const fruitName = record.FruitName || '';
      const weight = record.Weight || 0;
      rows[i] = {
        id: id,
        startTime: record.StartTime || '',
        endTime: record.EndTime || '',
        productType: fruitName,
        totalWeight: weight,
        customerName: record.CustomerName || '',
        farmName: record.FarmName || '',
        fruitName: fruitName, // 使用缓存值
        status: record.Status || '',
        count: record.Quantity || 0,
        weight: weight // 使用缓存值
      };
    }
    return rows;
  }

  /**
   * 获取所有记录并转换为前端格式
   */
  private static async getAllRecordsAsRowsTask(ctx?: Context): Promise<ProcessingRow[]> {
    let dbRecords: ProcessingHistoryData[] = [];
    if (ctx) {
      dbRecords = await DatabaseQueueManager.queryAll(ctx);
    } else {
      const db = GetIBestORM();
      dbRecords = db.Table('processing_history').Find(ProcessingHistory) as ProcessingHistoryData[];
    }
    // 性能优化：使用批量转换方法
    return ProcessingApiHandler.convertBatchToProcessingRows(dbRecords);
  }

  private static async getAllRecordsAsPackedRowsTask(ctx?: Context): Promise<Array<Array<string | number>>> {
    let dbRecords: ProcessingHistoryData[] = [];
    if (ctx) {
      dbRecords = await DatabaseQueueManager.queryAll(ctx);
    } else {
      const db = GetIBestORM();
      dbRecords = db.Table('processing_history').Find(ProcessingHistory) as ProcessingHistoryData[];
    }
    // 性能优化：预分配数组，减少重复字段访问
    const rows: Array<Array<string | number>> = new Array(dbRecords.length);
    for (let i = 0; i < dbRecords.length; i++) {
      const r = dbRecords[i];
      // 性能优化：缓存重复访问的字段
      const id = (r.ID || r.id) as number;
      const fruitName = r.FruitName || '';
      const weight = (r.Weight || 0) as number;
      rows[i] = [
        id,
        r.StartTime || '',
        r.EndTime || '',
        fruitName,
        weight,
        r.CustomerName || '',
        r.FarmName || '',
        fruitName, // 重复字段，使用缓存值
        r.Status || '',
        (r.Quantity || 0) as number,
        weight // 重复字段，使用缓存值
      ];
    }
    return rows;
  }

  private static async getPageRecordsAsRowsTask(page: number, size: number, ctx?: Context): Promise<ProcessingRow[]> {
    let dbRecords: ProcessingHistoryData[] = [];
    if (ctx) {
      dbRecords = await DatabaseQueueManager.queryPage(ctx, page, size);
    } else {
      const db = GetIBestORM();
      dbRecords = db.Table('processing_history').OrderByDesc('id').Limit(size).Offset((page - 1) * size).Find(ProcessingHistory) as ProcessingHistoryData[];
    }
    // 性能优化：使用批量转换方法
    return ProcessingApiHandler.convertBatchToProcessingRows(dbRecords);
  }

  /**
   * 处理列表查询请求（支持分页）
   */
  private static async handleList(params: Record<string, string>, ctx?: Context): Promise<string> {
    try {
      const page = Math.max(1, Number(params['page'] || '1'));
      const size = Math.max(1, Math.min(100, Number(params['size'] || '20')));
      const lite = params['lite'] === '1';
      const nocount = params['nocount'] === '1';
      if (!ctx) {
        return HttpResponseUtils.buildErrorResponse('Context 未提供', 500);
      }
      const pageRecords = await DatabaseQueueManager.queryPage(ctx, page, size);
      const total = nocount ? 0 : await DatabaseQueueManager.countAll(ctx);
      // 性能优化：使用批量转换方法
      const rows = ProcessingApiHandler.convertBatchToProcessingRows(pageRecords);
      const totalPages = Math.ceil(Math.max(0, total) / size);
      if (lite) {
        const liteResp: LiteListStats = { page, size, total, totalPages, count: rows.length };
        return HttpResponseUtils.buildSuccessResponse(liteResp);
      }
      const paginationInfo: PaginationInfo = { page, size, total, totalPages };
      const response: PaginatedResponse = { data: rows, pagination: paginationInfo };
      return HttpResponseUtils.buildSuccessResponse(response);
    } catch (error) {
      hilog.error(DOMAIN, 'ProcessingApiHandler', `从数据库查询失败: ${JSON.stringify(error)}`);
      return HttpResponseUtils.buildErrorResponse('查询数据失败', 500);
    }
  }

  /**
   * 处理列表查询请求（兼容旧版本，无分页）
   */
  private static async handleListJson(params: Record<string, string>, ctx?: Context, allowGzip?: boolean): Promise<string | Uint8Array> {
    try {
      const pack = params['pack'] === '1';
      const gzip = allowGzip === true || params['gzip'] === '1';
      if (pack) {
        const schema: string[] = ['id','startTime','endTime','productType','totalWeight','customerName','farmName','fruitName','status','count','weight'];
        const rows = await ProcessingApiHandler.getAllRecordsAsPackedRowsTask(ctx);
        const packed: PackedList = { schema, rows };
        if (gzip) {
          const response: PackedSuccessResponse = { ok: true, data: packed };
          return await HttpResponseUtils.buildJsonResponseGzip(response, 200, false, ctx);
        }
        return HttpResponseUtils.buildSuccessResponse(packed);
      }
      const data = await ProcessingApiHandler.getAllRecordsAsRowsTask(ctx);
      if (gzip) {
        const response: RowsSuccessResponse = { ok: true, data };
        return await HttpResponseUtils.buildJsonResponseGzip(response, 200, false, ctx);
      }
      return HttpResponseUtils.buildSuccessResponse(data);
    } catch (error) {
      hilog.error(DOMAIN, 'ProcessingApiHandler', `从数据库查询失败: ${JSON.stringify(error)}`);
      return HttpResponseUtils.buildErrorResponse('查询数据失败', 500);
    }
  }

  private static async handleListJsonLite(params: Record<string, string>, ctx?: Context): Promise<string> {
    try {
      const page = Math.max(1, Number(params['page'] || '1'));
      const size = Math.max(1, Math.min(100, Number(params['size'] || '20')));
      if (!ctx) {
        return HttpResponseUtils.buildErrorResponse('Context 未提供', 500);
      }
      const pageRecords = await DatabaseQueueManager.queryPage(ctx, page, size);
      const rows = ProcessingApiHandler.convertBatchToProcessingRows(pageRecords);
      const total = await DatabaseQueueManager.countAll(ctx);
      const totalPages = Math.ceil(Math.max(0, total) / size);
      const liteResp: LiteListStats = { page, size, total, totalPages, count: rows.length };
      return HttpResponseUtils.buildSuccessResponse(liteResp);
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
      if (!ctx) {
        return HttpResponseUtils.buildErrorResponse('Context 未提供', 500);
      }
      const insertId = await DatabaseQueueManager.insert(ctx, values);
      if (params['compact'] === '1') {
        const insertResp: InsertIdResponse = { id: insertId };
        return HttpResponseUtils.buildSuccessResponse(insertResp, '添加成功');
      }
      const after = await ProcessingApiHandler.getAllRecordsAsRowsTask(ctx);
      return HttpResponseUtils.buildSuccessResponse(after, '添加成功');
    } catch (error) {
      hilog.error(DOMAIN, 'ProcessingApiHandler', `保存到数据库失败: ${JSON.stringify(error)}`);
      return HttpResponseUtils.buildErrorResponse('保存数据失败', 500);
    }
  }

  private static async handleBatchInsert(body: string | undefined, ctx?: Context): Promise<string> {
    if (!body || body.trim().length === 0) {
      return HttpResponseUtils.buildErrorResponse('请求体不能为空', 400);
    }
    try {
      let arr: BatchInsertRecord[] = [];
      const parsed = JSON.parse(body) as BatchInsertRecord[] | BatchInsertWrapper;
      if (Array.isArray(parsed)) {
        arr = parsed as BatchInsertRecord[];
      } else {
        const wrapper = parsed as BatchInsertWrapper;
        if (wrapper && wrapper.records && Array.isArray(wrapper.records)) {
          arr = wrapper.records;
        }
      }
      if (!arr || arr.length === 0) {
        return HttpResponseUtils.buildErrorResponse('无有效记录', 400);
      }
      const valuesList: Array<relationalStore.ValuesBucket> = [];
      for (let i = 0; i < arr.length; i++) {
        const it: BatchInsertRecord = arr[i];
        const startTimeRaw: string = it.startTime || '';
        const endTimeRaw: string = it.endTime || '';
        const startTime: string = startTimeRaw ? startTimeRaw.replace('T', ' ') : '';
        const endTime: string = endTimeRaw ? endTimeRaw.replace('T', ' ') : '';
        const fruitName: string = (it.fruitName || it.productType || '') as string;
        const weightVal: number = it.totalWeight !== undefined ? Number(it.totalWeight) : Number(it.weight || 0);
        const countVal: number = it.count !== undefined ? Number(it.count) : 0;
        const customerName: string = it.customerName || '';
        const farmName: string = it.farmName || '';
        const status: string = it.status || '';
        if (!startTime || !endTime || !fruitName) {
          continue;
        }
        const v: relationalStore.ValuesBucket = {
          customer_name: customerName,
          farm_name: farmName,
          fruit_name: fruitName,
          status: status,
          start_time: startTime,
          end_time: endTime,
          weight: weightVal || 0,
          quantity: countVal || 0,
        };
        valuesList.push(v);
      }
      if (valuesList.length === 0) {
        return HttpResponseUtils.buildErrorResponse('无有效记录', 400);
      }
      if (!ctx) {
        return HttpResponseUtils.buildErrorResponse('Context 未提供', 500);
      }
      const inserted = await DatabaseQueueManager.batchInsert(ctx, valuesList);
      const result: BatchInsertResult = { inserted };
      return HttpResponseUtils.buildSuccessResponse(result, '批量添加成功');
    } catch (e) {
      return HttpResponseUtils.buildErrorResponse('批量添加失败', 500);
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
      if (!ctx) {
        return HttpResponseUtils.buildErrorResponse('Context 未提供', 500);
      }
      await DatabaseQueueManager.update(ctx, id, values);
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
      if (!ctx) {
        return HttpResponseUtils.buildErrorResponse('Context 未提供', 500);
      }
      await DatabaseQueueManager.delete(ctx, id);
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
  static async handle(method: string, path: string, body?: string, ctx?: Context, acceptGzip?: boolean): Promise<string | Uint8Array> {
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
      
      if (params['debug'] === '1') {
        hilog.info(DOMAIN, 'ProcessingApiHandler', `请求: ${method} ${cleanPath}`);
      }
      
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
          return await ProcessingApiHandler.handleListJson(params, ctx, acceptGzip === true);
        }
        if (params['action'] === 'listJsonLite') {
          return await ProcessingApiHandler.handleListJsonLite(params, ctx);
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
      if (upperMethod === 'POST' && cleanPath === '/api/processing/batch') {
        return await ProcessingApiHandler.handleBatchInsert(body, ctx);
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
            return await ProcessingApiHandler.handleListJson(params, ctx, acceptGzip === true);
          case 'listJsonLite':
            return await ProcessingApiHandler.handleListJsonLite(params, ctx);
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

