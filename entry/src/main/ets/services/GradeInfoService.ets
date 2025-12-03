import { Context } from '@kit.AbilityKit';
import { DatabaseQueueManager } from '../utils/network/database/dispatch/DatabaseQueueManager';
import { relationalStore } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { GradeInfo } from '../database/models/GradeInfo';

const DOMAIN = 0x0000;

/**
 * 等级信息服务类
 * 提供等级信息表(tb_gradeinfo)的业务逻辑处理
 * 
 * 使用示例:
 * ```typescript
 * // 保存单条等级信息
 * const id = await GradeInfoService.save(ctx, {
 *   CustomerID: 1,
 *   ChannelID: 2,
 *   QualityName: 'A级',
 *   ...
 * });
 * 
 * // 批量保存等级信息
 * const count = await GradeInfoService.batchSave(ctx, [data1, data2, ...]);
 * 
 * // 查询所有等级信息
 * const list = await GradeInfoService.queryAll(ctx);
 * ```
 */
export class GradeInfoService {
  
  /**
   * 保存单条等级信息
   * @param ctx 应用上下文
   * @param data 等级信息数据
   * @returns 插入的记录ID
   */
  static async save(ctx: Context, data: Partial<GradeInfo>): Promise<number> {
    try {
      // 数据验证
      GradeInfoService.validateData(data);
      
      // 自动添加时间戳
      const values: relationalStore.ValuesBucket = {
        ...data,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      };
      
      const id = await DatabaseQueueManager.insert(ctx, values, GradeInfo);
      hilog.info(DOMAIN, 'GradeInfoService', `保存等级信息成功: ID=${id}, 质量=${data.QualityName || '未知'}`);
      return id;
    } catch (error) {
      hilog.error(DOMAIN, 'GradeInfoService', `保存等级信息失败: ${JSON.stringify(error)}`);
      throw error;
    }
  }
  
  /**
   * 批量保存等级信息
   * @param ctx 应用上下文
   * @param dataList 等级信息数据数组
   * @returns 插入的记录数
   */
  static async batchSave(ctx: Context, dataList: Array<Partial<GradeInfo>>): Promise<number> {
    try {
      if (!dataList || dataList.length === 0) {
        hilog.warn(DOMAIN, 'GradeInfoService', '批量保存数据为空');
        return 0;
      }
      
      // 批量数据验证
      dataList.forEach((data, index) => {
        try {
          GradeInfoService.validateData(data);
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
      
      const count = await DatabaseQueueManager.batchInsert(ctx, valuesList, GradeInfo);
      hilog.info(DOMAIN, 'GradeInfoService', `批量保存等级信息成功: 数量=${count}`);
      return count;
    } catch (error) {
      hilog.error(DOMAIN, 'GradeInfoService', `批量保存等级信息失败: ${JSON.stringify(error)}`);
      throw error;
    }
  }
  
  /**
   * 更新等级信息
   * @param ctx 应用上下文
   * @param id 记录ID
   * @param data 更新的数据
   * @returns 受影响的行数
   */
  static async update(ctx: Context, id: number, data: Partial<GradeInfo>): Promise<number> {
    try {
      // 自动更新时间戳
      const values: relationalStore.ValuesBucket = {
        ...data,
        updated_at: new Date().toISOString()
      };
      
      const affected = await DatabaseQueueManager.update(ctx, id, values, GradeInfo);
      hilog.info(DOMAIN, 'GradeInfoService', `更新等级信息成功: ID=${id}, 影响行数=${affected}`);
      return affected;
    } catch (error) {
      hilog.error(DOMAIN, 'GradeInfoService', `更新等级信息失败: ID=${id}, ${JSON.stringify(error)}`);
      throw error;
    }
  }
  
  /**
   * 删除等级信息
   * @param ctx 应用上下文
   * @param id 记录ID
   * @returns 受影响的行数
   */
  static async delete(ctx: Context, id: number): Promise<number> {
    try {
      const affected = await DatabaseQueueManager.delete(ctx, id, GradeInfo);
      hilog.info(DOMAIN, 'GradeInfoService', `删除等级信息成功: ID=${id}, 影响行数=${affected}`);
      return affected;
    } catch (error) {
      hilog.error(DOMAIN, 'GradeInfoService', `删除等级信息失败: ID=${id}, ${JSON.stringify(error)}`);
      throw error;
    }
  }
  
  /**
   * 查询所有等级信息
   * @param ctx 应用上下文
   * @returns 查询结果数组
   */
  static async queryAll(ctx: Context): Promise<GradeInfo[]> {
    try {
      const result = await DatabaseQueueManager.queryAll<GradeInfo>(ctx, GradeInfo);
      hilog.info(DOMAIN, 'GradeInfoService', `查询所有等级信息成功: 数量=${result.length}`);
      return result;
    } catch (error) {
      hilog.error(DOMAIN, 'GradeInfoService', `查询所有等级信息失败: ${JSON.stringify(error)}`);
      throw error;
    }
  }
  
  /**
   * 分页查询等级信息
   * @param ctx 应用上下文
   * @param page 页码(从1开始)
   * @param size 每页大小
   * @returns 查询结果数组
   */
  static async queryPage(ctx: Context, page: number, size: number): Promise<GradeInfo[]> {
    try {
      const result = await DatabaseQueueManager.queryPage<GradeInfo>(ctx, page, size, GradeInfo);
      hilog.info(DOMAIN, 'GradeInfoService', `分页查询等级信息成功: 页码=${page}, 大小=${size}, 数量=${result.length}`);
      return result;
    } catch (error) {
      hilog.error(DOMAIN, 'GradeInfoService', `分页查询等级信息失败: ${JSON.stringify(error)}`);
      throw error;
    }
  }
  
  /**
   * 统计等级信息总数
   * @param ctx 应用上下文
   * @returns 记录总数
   */
  static async count(ctx: Context): Promise<number> {
    try {
      const total = await DatabaseQueueManager.countAll(ctx, GradeInfo);
      hilog.info(DOMAIN, 'GradeInfoService', `统计等级信息成功: 总数=${total}`);
      return total;
    } catch (error) {
      hilog.error(DOMAIN, 'GradeInfoService', `统计等级信息失败: ${JSON.stringify(error)}`);
      throw error;
    }
  }
  /**
   * 根据客户ID查询等级信息
   * @param ctx 应用上下文
   * @param customerId 客户ID
   * @returns 查询结果数组
   */
  static async queryByCustomerId(ctx: Context, customerId: number): Promise<GradeInfo[]> {
    try {
      // 使用 ORM 条件查询优化性能
      // 避免全量查询后过滤，也避免直接编写 SQL
      const result = await DatabaseQueueManager.queryByCondition<GradeInfo>(
        ctx, 
        GradeInfo, 
        'customer_id = ?', 
        [customerId]
      );
      
      hilog.info(DOMAIN, 'GradeInfoService', `根据客户ID查询等级信息成功: CustomerID=${customerId}, 数量=${result.length}`);
      return result;
    } catch (error) {
      hilog.error(DOMAIN, 'GradeInfoService', `根据客户ID查询等级信息失败: ${JSON.stringify(error)}`);
      throw error;
    }
  }
  
  /**
   * 数据验证
   * @param data 待验证的数据
   */
  private static validateData(data: Partial<GradeInfo>): void {
    // 根据表结构,以下字段是 NOT NULL
    const requiredFields = [
      'CustomerID', 'ChannelID', 'QualityIndex', 
      'SizeID', 'SizeIndex', 'BoxNumber', 
      'FruitNumber', 'FruitWeight', 'FPrice', 'GradeID'
    ];
    
    // 为必填字段设置默认值
    if (data.CustomerID === undefined) data.CustomerID = 0;
    if (data.ChannelID === undefined) data.ChannelID = 0;
    if (data.QualityIndex === undefined) data.QualityIndex = 0;
    if (data.SizeID === undefined) data.SizeID = 0;
    if (data.SizeIndex === undefined) data.SizeIndex = 0;
    if (data.BoxNumber === undefined) data.BoxNumber = 0;
    if (data.FruitNumber === undefined) data.FruitNumber = 0;
    if (data.FruitWeight === undefined) data.FruitWeight = 0.00;
    if (data.FPrice === undefined) data.FPrice = 0.00;
    if (data.GradeID === undefined) data.GradeID = 0;
    
    // 业务规则验证
    if (data.BoxWeight !== undefined && data.BoxWeight < 0) {
      throw new Error('箱重不能为负数');
    }
    
    if (data.FruitWeight !== undefined && data.FruitWeight < 0) {
      throw new Error('水果重量不能为负数');
    }
    
    if (data.FPrice !== undefined && data.FPrice < 0) {
      throw new Error('价格不能为负数');
    }
  }
}
