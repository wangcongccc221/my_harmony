import { hilog } from '@kit.PerformanceAnalysisKit';
import { QueryStringUtils } from '../../helpers/QueryStringUtils';
import { DateValidationUtils } from '../../helpers/DateValidationUtils';
import { HttpResponseUtils } from '../../helpers/HttpResponseUtils';
import { DatabaseManager } from '../../../database/DatabaseManager';
import { ProcessingHistory } from '../../../database/models/ProcessingHistory';
import { ProcessingHistoryData } from '../../../database/types';

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
 * 默认API响应数据接口
 */
interface DefaultApiResponseData {
  path: string;
  message: string;
  data: null;
}

/**
 * 加工历史API处理器
 * 负责处理 /api/processing 相关的所有请求
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
   * 处理列表查询请求
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

    // 保存到数据库
    try {
      const dbManager = DatabaseManager.getInstance();
      const historyRecord = new ProcessingHistory(
        customerName,
        farmName,
        fruitName,
        status,
        startTime,
        endTime,
        weight,
        count
      );

      dbManager.createProcessingHistory(historyRecord);
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
   * 处理加工历史API请求
   * @param path 请求路径，如 /api/processing?action=listJson
   */
  static async handle(path: string): Promise<string> {
    if (path.indexOf('/api/processing') !== 0) {
      // 不是加工历史API，返回默认响应
      const defaultResponseData: DefaultApiResponseData = {
        path: path,
        message: 'API endpoint',
        data: null
      };
      return HttpResponseUtils.buildSuccessResponse(defaultResponseData);
    }

    try {
      const pathAndQuery = QueryStringUtils.parsePathAndQuery(path);
      const params = pathAndQuery.params;
      const action = params['action'] || 'listJson';

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
    } catch (e) {
      hilog.error(DOMAIN, 'ProcessingApiHandler', `处理API请求失败: ${JSON.stringify(e)}`);
      return HttpResponseUtils.buildErrorResponse('服务器内部错误', 500);
    }
  }
}

