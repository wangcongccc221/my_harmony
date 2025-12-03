import { Context } from '@kit.AbilityKit';
import { DatabaseQueueManager } from '../utils/network/database/dispatch/DatabaseQueueManager';
import { relationalStore } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ExportInfo } from '../database/models/ExportInfo';

const DOMAIN = 0x0000;

/**
 * 导出信息服务类
 * 提供导出信息表(tb_exportinfo)的业务逻辑处理
 * 
 * 使用示例:
 * ```typescript
 * // 保存单条导出信息
 * const id = await ExportInfoService.save(ctx, {
 *   CustomerID: 1,
 *   ChannelID: 2,
 *   ExportID: 100,
 *   FruitNumber: 500,
 *   FruitWeight: 250.5,
 *   BoxNumber: 10,
 *   ExitName: '出口A',
 * });
 * 
 * // 批量保存导出信息
 * const count = await ExportInfoService.batchSave(ctx, [data1, data2, ...]);
 * 
 * // 查询所有导出信息
 * const list = await ExportInfoService.queryAll(ctx);
 * 
 * // 根据客户ID查询
 * const customerExports = await ExportInfoService.queryByCustomerId(ctx, 1);
 * ```
 */
export class ExportInfoService {
  
  /**
   * 保存单条导出信息
   * @param ctx 应用上下文
   * @param data 导出信息数据
   * @returns 插入的记录ID
   */
  static async save(ctx: Context, data: Partial<ExportInfo>): Promise<number> {
    try {
      // 数据验证
      ExportInfoService.validateData(data);
      
      // 自动添加时间戳
      const values: relationalStore.ValuesBucket = {
        ...data,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      };
      
      const id = await DatabaseQueueManager.insert(ctx, values, ExportInfo);
      hilog.info(DOMAIN, 'ExportInfoService', `保存导出信息成功: ID=${id}, 出口=${data.ExitName || '未知'}`);
      return id;
    } catch (error) {
      hilog.error(DOMAIN, 'ExportInfoService', `保存导出信息失败: ${JSON.stringify(error)}`);
      throw error;
    }
  }
  
  /**
   * 批量保存导出信息
   * @param ctx 应用上下文
   * @param dataList 导出信息数据数组
   * @returns 插入的记录数
   */
  static async batchSave(ctx: Context, dataList: Array<Partial<ExportInfo>>): Promise<number> {
    try {
      if (!dataList || dataList.length === 0) {
        hilog.warn(DOMAIN, 'ExportInfoService', '批量保存数据为空');
        return 0;
      }
      
      // 批量数据验证
      dataList.forEach((data, index) => {
        try {
          ExportInfoService.validateData(data);
        } catch (error) {
          throw new Error(`第${index + 1}条数据验证失败: ${error}`);
        }
      });
      
      // 自动添加时间戳
      const timestamp = new Date().toISOString();
      const valuesList = dataList.map(data => ({
        ...data,
        created_at: timestamp,
        updated_at: timestamp
      }));
      
      const count = await DatabaseQueueManager.batchInsert(ctx, valuesList, ExportInfo);
      hilog.info(DOMAIN, 'ExportInfoService', `批量保存导出信息成功: 数量=${count}`);
      return count;
    } catch (error) {
      hilog.error(DOMAIN, 'ExportInfoService', `批量保存导出信息失败: ${JSON.stringify(error)}`);
      throw error;
    }
  }
  
  /**
   * 更新导出信息
   * @param ctx 应用上下文
   * @param id 记录ID
   * @param data 更新的数据
   * @returns 受影响的行数
   */
  static async update(ctx: Context, id: number, data: Partial<ExportInfo>): Promise<number> {
    try {
      // 自动更新时间戳
      const values: relationalStore.ValuesBucket = {
        ...data,
        updated_at: new Date().toISOString()
      };
      
      const affected = await DatabaseQueueManager.update(ctx, id, values, ExportInfo);
      hilog.info(DOMAIN, 'ExportInfoService', `更新导出信息成功: ID=${id}, 影响行数=${affected}`);
      return affected;
    } catch (error) {
      hilog.error(DOMAIN, 'ExportInfoService', `更新导出信息失败: ID=${id}, ${JSON.stringify(error)}`);
      throw error;
    }
  }
  
  /**
   * 删除导出信息
   * @param ctx 应用上下文
   * @param id 记录ID
   * @returns 受影响的行数
   */
  static async delete(ctx: Context, id: number): Promise<number> {
    try {
      const affected = await DatabaseQueueManager.delete(ctx, id, ExportInfo);
      hilog.info(DOMAIN, 'ExportInfoService', `删除导出信息成功: ID=${id}, 影响行数=${affected}`);
      return affected;
    } catch (error) {
      hilog.error(DOMAIN, 'ExportInfoService', `删除导出信息失败: ID=${id}, ${JSON.stringify(error)}`);
      throw error;
    }
  }
  
  /**
   * 查询所有导出信息
   * @param ctx 应用上下文
   * @returns 查询结果数组
   */
  static async queryAll(ctx: Context): Promise<ExportInfo[]> {
    try {
      const result = await DatabaseQueueManager.queryAll<ExportInfo>(ctx, ExportInfo);
      hilog.info(DOMAIN, 'ExportInfoService', `查询所有导出信息成功: 数量=${result.length}`);
      return result;
    } catch (error) {
      hilog.error(DOMAIN, 'ExportInfoService', `查询所有导出信息失败: ${JSON.stringify(error)}`);
      throw error;
    }
  }
  
  /**
   * 分页查询导出信息
   * @param ctx 应用上下文
   * @param page 页码(从1开始)
   * @param size 每页大小
   * @returns 查询结果数组
   */
  static async queryPage(ctx: Context, page: number, size: number): Promise<ExportInfo[]> {
    try {
      const result = await DatabaseQueueManager.queryPage<ExportInfo>(ctx, page, size, ExportInfo);
      hilog.info(DOMAIN, 'ExportInfoService', `分页查询导出信息成功: 页码=${page}, 大小=${size}, 数量=${result.length}`);
      return result;
    } catch (error) {
      hilog.error(DOMAIN, 'ExportInfoService', `分页查询导出信息失败: ${JSON.stringify(error)}`);
      throw error;
    }
  }
  
  /**
   * 统计导出信息总数
   * @param ctx 应用上下文
   * @returns 记录总数
   */
  static async count(ctx: Context): Promise<number> {
    try {
      const total = await DatabaseQueueManager.countAll(ctx, ExportInfo);
      hilog.info(DOMAIN, 'ExportInfoService', `统计导出信息成功: 总数=${total}`);
      return total;
    } catch (error) {
      hilog.error(DOMAIN, 'ExportInfoService', `统计导出信息失败: ${JSON.stringify(error)}`);
      throw error;
    }
  }
  
  
  /**
   * 根据客户ID查询导出信息
   * @param ctx 应用上下文
   * @param customerId 客户ID
   * @returns 查询结果数组
   */
  static async queryByCustomerId(ctx: Context, customerId: number): Promise<ExportInfo[]> {
    try {
      const result = await DatabaseQueueManager.queryByCondition<ExportInfo>(
        ctx, 
        ExportInfo, 
        'customer_id = ?', 
        [customerId]
      );
      return result;
    } catch (error) {
      hilog.error(DOMAIN, 'ExportInfoService', `根据客户ID查询导出信息失败: ${JSON.stringify(error)}`);
      throw error;
    }
  }
  
  /**
   * 根据导出ID查询导出信息
   * @param ctx 应用上下文
   * @param exportId 导出ID
   * @returns 查询结果数组
   */
  static async queryByExportId(ctx: Context, exportId: number): Promise<ExportInfo[]> {
    try {
      const result = await DatabaseQueueManager.queryByCondition<ExportInfo>(
        ctx, 
        ExportInfo, 
        'export_id = ?', 
        [exportId]
      );
      return result;
    } catch (error) {
      hilog.error(DOMAIN, 'ExportInfoService', `根据导出ID查询导出信息失败: ${JSON.stringify(error)}`);
      throw error;
    }
  }
  
  /**
   * 根据通道ID查询导出信息
   * @param ctx 应用上下文
   * @param channelId 通道ID
   * @returns 查询结果数组
   */
  static async queryByChannelId(ctx: Context, channelId: number): Promise<ExportInfo[]> {
    try {
      const result = await DatabaseQueueManager.queryByCondition<ExportInfo>(
        ctx, 
        ExportInfo, 
        'channel_id = ?', 
        [channelId]
      );
      return result;
    } catch (error) {
      hilog.error(DOMAIN, 'ExportInfoService', `根据通道ID查询导出信息失败: ${JSON.stringify(error)}`);
      throw error;
    }
  }
  
  /**
   * 数据验证
   * @param data 待验证的数据
   */
  private static validateData(data: Partial<ExportInfo>): void {
    // 根据表结构,以下字段是 NOT NULL
    if (data.CustomerID === undefined || data.CustomerID === null) {
      data.CustomerID = 0;
    }
    
    if (data.ChannelID === undefined || data.ChannelID === null) {
      data.ChannelID = 0;
    }
    
    if (data.ExportID === undefined || data.ExportID === null) {
      data.ExportID = 0;
    }
    
    // 业务规则验证
    if (data.FruitNumber !== undefined && data.FruitNumber < 0) {
      throw new Error('水果数量不能为负数');
    }
    
    if (data.FruitWeight !== undefined && data.FruitWeight < 0) {
      throw new Error('水果重量不能为负数');
    }
    
    if (data.BoxNumber !== undefined && data.BoxNumber < 0) {
      throw new Error('箱数不能为负数');
    }
  }
}
