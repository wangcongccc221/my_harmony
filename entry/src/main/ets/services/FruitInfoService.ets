import { Context } from '@kit.AbilityKit';
import { DatabaseQueueManager } from '../utils/network/database/dispatch/DatabaseQueueManager';
import { relationalStore } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { FruitInfo } from '../database/models/FruitInfo';

const DOMAIN = 0x0000;

/**
 * 水果信息服务类
 * 提供水果信息表(tb_fruitinfo)的业务逻辑处理
 * 
 * 使用示例:
 * ```typescript
 * // 保存单条水果信息
 * const id = await FruitInfoService.save(ctx, {
 *   FruitName: '苹果',
 *   CustomerName: '客户A',
 *   BatchWeight: 100.5,
 *   ...
 * });
 * 
 * // 批量保存水果信息
 * const count = await FruitInfoService.batchSave(ctx, [data1, data2, ...]);
 * 
 * // 查询所有水果信息
 * const list = await FruitInfoService.queryAll(ctx);
 * 
 * // 分页查询
 * const pageData = await FruitInfoService.queryPage(ctx, 1, 20);
 * ```
 */
export class FruitInfoService {
  
  /**
   * 保存单条水果信息
   * @param ctx 应用上下文
   * @param data 水果信息数据
   * @returns 插入的记录ID
   */
  static async save(ctx: Context, data: Partial<FruitInfo>): Promise<number> {
    try {
      // 数据验证
      FruitInfoService.validateData(data);
      
      // 自动添加时间戳
      const values: relationalStore.ValuesBucket = {
        ...data,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      };
      
      const id = await DatabaseQueueManager.insert(ctx, values, FruitInfo);
      hilog.info(DOMAIN, 'FruitInfoService', `保存水果信息成功: ID=${id}, 水果=${data.FruitName || '未知'}`);
      return id;
    } catch (error) {
      hilog.error(DOMAIN, 'FruitInfoService', `保存水果信息失败: ${JSON.stringify(error)}`);
      throw error;
    }
  }
  
  /**
   * 批量保存水果信息
   * @param ctx 应用上下文
   * @param dataList 水果信息数据数组
   * @returns 插入的记录数
   */
  static async batchSave(ctx: Context, dataList: Array<Partial<FruitInfo>>): Promise<number> {
    try {
      if (!dataList || dataList.length === 0) {
        hilog.warn(DOMAIN, 'FruitInfoService', '批量保存数据为空');
        return 0;
      }
      
      // 批量数据验证
      dataList.forEach((data, index) => {
        try {
          FruitInfoService.validateData(data);
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
      
      const count = await DatabaseQueueManager.batchInsert(ctx, valuesList, FruitInfo);
      hilog.info(DOMAIN, 'FruitInfoService', `批量保存水果信息成功: 数量=${count}`);
      return count;
    } catch (error) {
      hilog.error(DOMAIN, 'FruitInfoService', `批量保存水果信息失败: ${JSON.stringify(error)}`);
      throw error;
    }
  }
  
  /**
   * 更新水果信息
   * @param ctx 应用上下文
   * @param id 记录ID
   * @param data 更新的数据
   * @returns 受影响的行数
   */
  static async update(ctx: Context, id: number, data: Partial<FruitInfo>): Promise<number> {
    try {
      // 自动更新时间戳
      const values: relationalStore.ValuesBucket = {
        ...data,
        updated_at: new Date().toISOString()
      };
      
      const affected = await DatabaseQueueManager.update(ctx, id, values, FruitInfo);
      hilog.info(DOMAIN, 'FruitInfoService', `更新水果信息成功: ID=${id}, 影响行数=${affected}`);
      return affected;
    } catch (error) {
      hilog.error(DOMAIN, 'FruitInfoService', `更新水果信息失败: ID=${id}, ${JSON.stringify(error)}`);
      throw error;
    }
  }
  
  /**
   * 删除水果信息
   * @param ctx 应用上下文
   * @param id 记录ID
   * @returns 受影响的行数
   */
  static async delete(ctx: Context, id: number): Promise<number> {
    try {
      const affected = await DatabaseQueueManager.delete(ctx, id, FruitInfo);
      hilog.info(DOMAIN, 'FruitInfoService', `删除水果信息成功: ID=${id}, 影响行数=${affected}`);
      return affected;
    } catch (error) {
      hilog.error(DOMAIN, 'FruitInfoService', `删除水果信息失败: ID=${id}, ${JSON.stringify(error)}`);
      throw error;
    }
  }
  
  /**
   * 查询所有水果信息
   * @param ctx 应用上下文
   * @returns 查询结果数组
   */
  static async queryAll(ctx: Context): Promise<FruitInfo[]> {
    try {
      const result = await DatabaseQueueManager.queryAll<FruitInfo>(ctx, FruitInfo);
      hilog.info(DOMAIN, 'FruitInfoService', `查询所有水果信息成功: 数量=${result.length}`);
      return result;
    } catch (error) {
      hilog.error(DOMAIN, 'FruitInfoService', `查询所有水果信息失败: ${JSON.stringify(error)}`);
      throw error;
    }
  }
  
  /**
   * 分页查询水果信息
   * @param ctx 应用上下文
   * @param page 页码(从1开始)
   * @param size 每页大小
   * @returns 查询结果数组
   */
  static async queryPage(ctx: Context, page: number, size: number): Promise<FruitInfo[]> {
    try {
      const result = await DatabaseQueueManager.queryPage<FruitInfo>(ctx, page, size, FruitInfo);
      hilog.info(DOMAIN, 'FruitInfoService', `分页查询水果信息成功: 页码=${page}, 大小=${size}, 数量=${result.length}`);
      return result;
    } catch (error) {
      hilog.error(DOMAIN, 'FruitInfoService', `分页查询水果信息失败: ${JSON.stringify(error)}`);
      throw error;
    }
  }
  
  /**
   * 统计水果信息总数
   * @param ctx 应用上下文
   * @returns 记录总数
   */
  static async count(ctx: Context): Promise<number> {
    try {
      const total = await DatabaseQueueManager.countAll(ctx, FruitInfo);
      hilog.info(DOMAIN, 'FruitInfoService', `统计水果信息成功: 总数=${total}`);
      return total;
    } catch (error) {
      hilog.error(DOMAIN, 'FruitInfoService', `统计水果信息失败: ${JSON.stringify(error)}`);
      throw error;
    }
  }
  
  /**
   * 数据验证
   * @param data 待验证的数据
   */
  private static validateData(data: Partial<FruitInfo>): void {
    // 基础验证:确保必填字段存在
    // 注意:根据表结构,SortType 是 NOT NULL 字段
    if (data.SortType === undefined || data.SortType === null) {
      // 如果没有提供,使用默认值 0
      data.SortType = 0;
    }
    
    // 可以添加更多业务规则验证
    // 例如:批次重量不能为负数
    if (data.BatchWeight !== undefined && data.BatchWeight < 0) {
      throw new Error('批次重量不能为负数');
    }
    
    // 批次数量不能为负数
    if (data.BatchNumber !== undefined && data.BatchNumber < 0) {
      throw new Error('批次数量不能为负数');
    }
  }
}
