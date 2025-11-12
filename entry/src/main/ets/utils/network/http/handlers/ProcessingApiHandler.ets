import { hilog } from '@kit.PerformanceAnalysisKit';
import { QueryStringUtils } from '../../../helpers/QueryStringUtils';
import { DateValidationUtils } from '../../../helpers/DateValidationUtils';
import { HttpResponseUtils } from '../../../helpers/HttpResponseUtils';
import { DatabaseManager } from '../../../../database/DatabaseManager';
import { ProcessingHistory } from '../../../../database/models/ProcessingHistory';
import { ProcessingHistoryData } from '../../../../database/types';

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
    this.id = record.id;
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
  private static getAllRecordsAsRows(): ProcessingRow[] {
    const dbManager = DatabaseManager.getInstance();
    const dbRecords = dbManager.getAllProcessingHistory();
    const rows: ProcessingRow[] = [];
    for (let i = 0; i < dbRecords.length; i++) {
      rows.push(ProcessingApiHandler.convertToProcessingRow(dbRecords[i]));
    }
    return rows;
  }

  /**
   * 处理列表查询请求（支持分页）
   */
  private static handleList(params: Record<string, string>): string {
    try {
      const allRows = ProcessingApiHandler.getAllRecordsAsRows();
      
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
  private static handleListJson(): string {
    try {
      const data = ProcessingApiHandler.getAllRecordsAsRows();
      return HttpResponseUtils.buildSuccessResponse(data);
    } catch (error) {
      hilog.error(DOMAIN, 'ProcessingApiHandler', `从数据库查询失败: ${JSON.stringify(error)}`);
      return HttpResponseUtils.buildErrorResponse('查询数据失败', 500);
    }
  }

  /**
   * 处理插入请求
   */
  private static handleInsert(params: Record<string, string>): string {
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

    // 保存到数据库（使用便捷方法）
    try {
      const dbManager = DatabaseManager.getInstance();
      dbManager.addProcessingHistory(
        customerName,
        farmName,
        fruitName,
        status,
        startTime,
        endTime,
        weight,
        count
      );
      const data = ProcessingApiHandler.getAllRecordsAsRows();
      return HttpResponseUtils.buildSuccessResponse(data, '添加成功');
    } catch (error) {
      hilog.error(DOMAIN, 'ProcessingApiHandler', `保存到数据库失败: ${JSON.stringify(error)}`);
      return HttpResponseUtils.buildErrorResponse('保存数据失败', 500);
    }
  }

  /**
   * 处理更新请求
   */
  private static handleUpdate(params: Record<string, string>): string {
    const id = Number(params['id'] || '0');
    if (!id || id <= 0) {
      return HttpResponseUtils.buildErrorResponse('ID无效或未提供', 400);
    }

    try {
      const dbManager = DatabaseManager.getInstance();
      const existingRecord = dbManager.getProcessingHistoryById(id);
      if (!existingRecord) {
        return HttpResponseUtils.buildErrorResponse('记录不存在', 404);
      }

      // 获取更新参数（如果字段未提供，则使用原值）
      const customerName = params['customerName'] !== undefined ? params['customerName'] : (existingRecord.CustomerName || '');
      const farmName = params['farmName'] !== undefined ? params['farmName'] : (existingRecord.FarmName || '');
      const fruitName = params['fruitName'] !== undefined ? params['fruitName'] : (params['productType'] || existingRecord.FruitName || '');
      const status = params['status'] !== undefined ? params['status'] : (existingRecord.Status || '');
      // 统一时间格式：优先使用参数，其次使用已有记录；并将 'T' 替换为空格
      const startTimeParam = params['startTime'] || '';
      const endTimeParam = params['endTime'] || '';
      const startTime = (startTimeParam ? startTimeParam : (existingRecord.StartTime || '')).replace('T', ' ');
      const endTime = (endTimeParam ? endTimeParam : (existingRecord.EndTime || '')).replace('T', ' ');
      const weight = params['weight'] !== undefined ? Number(params['weight']) :
        (params['totalWeight'] ? Number(params['totalWeight']) : (existingRecord.Weight || 0));
      const count = params['count'] !== undefined ? Number(params['count']) : (existingRecord.Quantity || 0);

      const updatedRecord = new ProcessingHistory(
        customerName,
        farmName,
        fruitName,
        status,
        startTime,
        endTime,
        weight,
        count
      );

      dbManager.updateProcessingHistory(id, updatedRecord);
      const data = ProcessingApiHandler.getAllRecordsAsRows();
      return HttpResponseUtils.buildSuccessResponse(data, '更新成功');
    } catch (error) {
      hilog.error(DOMAIN, 'ProcessingApiHandler', `更新数据库失败: ${JSON.stringify(error)}`);
      return HttpResponseUtils.buildErrorResponse('更新数据失败', 500);
    }
  }

  /**
   * 处理删除请求
   */
  private static handleDelete(params: Record<string, string>): string {
    const id = Number(params['id'] || '0');
    if (!id || id <= 0) {
      return HttpResponseUtils.buildErrorResponse('ID无效或未提供', 400);
    }

    try {
      const dbManager = DatabaseManager.getInstance();
      const existingRecord = dbManager.getProcessingHistoryById(id);
      if (!existingRecord) {
        return HttpResponseUtils.buildErrorResponse('记录不存在', 404);
      }

      dbManager.deleteProcessingHistory(id);
      const data = ProcessingApiHandler.getAllRecordsAsRows();
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
  static async handle(method: string, path: string, body?: string): Promise<string> {
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
          return ProcessingApiHandler.handleListJson();
        }
        return ProcessingApiHandler.handleList(params);
      }
      
      // GET /api/processing/:id - 获取单条记录（暂不支持，返回404）
      if (upperMethod === 'GET' && pathId !== null) {
        return HttpResponseUtils.buildErrorResponse('获取单条记录接口暂未实现', 404);
      }
      
      // POST /api/processing - 创建记录
      if (upperMethod === 'POST' && cleanPath === '/api/processing') {
        // 兼容旧版本：如果 action=insert，使用旧接口
        if (params['action'] === 'insert') {
          return ProcessingApiHandler.handleInsert(params);
        }
        return ProcessingApiHandler.handleInsert(params);
      }
      
      // PUT /api/processing/:id - 更新记录
      if (upperMethod === 'PUT' && pathId !== null) {
        return ProcessingApiHandler.handleUpdate(params);
      }
      
      // DELETE /api/processing/:id - 删除记录
      if (upperMethod === 'DELETE' && pathId !== null) {
        return ProcessingApiHandler.handleDelete(params);
      }
      
      // 兼容旧版本：通过 action 参数
      if (params['action']) {
        const action = params['action'];
        switch (action) {
          case 'listJson':
            return ProcessingApiHandler.handleListJson();
          case 'insert':
            return ProcessingApiHandler.handleInsert(params);
          case 'update':
            return ProcessingApiHandler.handleUpdate(params);
          case 'delete':
            return ProcessingApiHandler.handleDelete(params);
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

