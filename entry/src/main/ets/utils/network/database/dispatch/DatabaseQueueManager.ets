import { DatabaseDispatchQueue, DatabaseTask, DatabaseTaskType, DatabaseTaskResult } from './DatabaseDispatchQueue';
import { Context } from '@kit.AbilityKit';
import { relationalStore } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ProcessingHistoryData } from '../../../../database/types';
import { Class, GetTableName } from '../../../../database/orm';
import { ProcessingHistory } from '../../../../database/models/ProcessingHistory';

const DOMAIN = 0x0000;

// ESObject 类型别名
type ESObject = object;

/**
 * 数据库操作队列管理器
 * 提供统一的数据库操作接口
 * - 查询操作使用并发队列（提高查询性能）
 * - 写入操作使用串行队列（避免并发写入冲突）
 */
export class DatabaseQueueManager {
  // 并发队列：用于查询操作
  private static queryQueue: DatabaseDispatchQueue | null = null;
  // 串行队列：用于写入操作
  private static writeQueue: DatabaseDispatchQueue | null = null;

  /**
   * 初始化队列
   */
  static initialize(): void {
    if (!DatabaseQueueManager.queryQueue) {
      DatabaseQueueManager.queryQueue = DatabaseDispatchQueue.queue_create_concurrent(
        'com.harmony.db.query'
      );
      hilog.info(DOMAIN, 'DatabaseQueueManager', '数据库查询队列已初始化');
    }
    if (!DatabaseQueueManager.writeQueue) {
      DatabaseQueueManager.writeQueue = DatabaseDispatchQueue.queue_create_serial(
        'com.harmony.db.write'
      );
      hilog.info(DOMAIN, 'DatabaseQueueManager', '数据库写入队列已初始化');
    }
  }

  /**
   * 获取查询队列
   */
  static getQueryQueue(): DatabaseDispatchQueue {
    if (!DatabaseQueueManager.queryQueue) {
      DatabaseQueueManager.initialize();
    }
    return DatabaseQueueManager.queryQueue!;
  }

  /**
   * 获取写入队列
   */
  static getWriteQueue(): DatabaseDispatchQueue {
    if (!DatabaseQueueManager.writeQueue) {
      DatabaseQueueManager.initialize();
    }
    return DatabaseQueueManager.writeQueue!;
  }

  /**
   * 执行查询所有记录
   * @param ctx Context 上下文
   * @param entityClass 实体类（可选，默认使用 ProcessingHistory）
   */
  static async queryAll<T = ProcessingHistoryData>(ctx: Context, entityClass?: Class): Promise<T[]> {
    return new Promise<T[]>((resolve, reject) => {
      const queue = DatabaseQueueManager.getQueryQueue();
      const task = new DatabaseTask({ type: DatabaseTaskType.QUERY_ALL });
      
      queue.setTaskContext(task.uniqueId, ctx);
      // 设置表名（如果提供实体类，转换为表名；否则使用默认表名）
      const tableName = entityClass ? GetTableName(entityClass) : 'processing_history';
      queue.setTaskTableName(task.uniqueId, tableName);
      
      queue.async(task, (result: ESObject) => {
        try {
          const taskResult = result as DatabaseTaskResult;
          if (taskResult.success && taskResult.data) {
            resolve(taskResult.data as T[]);
          } else {
            const errorMsg = taskResult.error || '查询失败';
            hilog.error(DOMAIN, 'DatabaseQueueManager', `查询所有记录失败: ${errorMsg}`);
            reject(new Error(errorMsg));
          }
        } catch (err) {
          const error = err as Error | object;
          hilog.error(DOMAIN, 'DatabaseQueueManager', `处理查询结果失败: ${JSON.stringify(error)}`);
          reject(error instanceof Error ? error : new Error(String(error)));
        }
      });
    });
  }

  /**
   * 执行分页查询
   * @param ctx Context 上下文
   * @param page 页码
   * @param size 每页大小
   * @param entityClass 实体类（可选，默认使用 ProcessingHistory）
   */
  static async queryPage<T = ProcessingHistoryData>(ctx: Context, page: number, size: number, entityClass?: Class): Promise<T[]> {
    return new Promise<T[]>((resolve, reject) => {
      const queue = DatabaseQueueManager.getQueryQueue();
      const task = new DatabaseTask({ 
        type: DatabaseTaskType.QUERY_PAGE, 
        page: page, 
        size: size 
      });
      
      queue.setTaskContext(task.uniqueId, ctx);
      // 设置表名（如果提供实体类，转换为表名；否则使用默认表名）
      const tableName = entityClass ? GetTableName(entityClass) : 'processing_history';
      queue.setTaskTableName(task.uniqueId, tableName);
      
      queue.async(task, (result: ESObject) => {
        try {
          const taskResult = result as DatabaseTaskResult;
          if (taskResult.success && taskResult.data) {
            resolve(taskResult.data as T[]);
          } else {
            const errorMsg = taskResult.error || '查询失败';
            hilog.error(DOMAIN, 'DatabaseQueueManager', `分页查询失败: ${errorMsg}`);
            reject(new Error(errorMsg));
          }
        } catch (err) {
          const error = err as Error | object;
          hilog.error(DOMAIN, 'DatabaseQueueManager', `处理查询结果失败: ${JSON.stringify(error)}`);
          reject(error instanceof Error ? error : new Error(String(error)));
        }
      });
    });
  }

  /**
   * 执行计数查询
   * @param ctx Context 上下文
   * @param entityClass 实体类（可选，默认使用 ProcessingHistory）
   */
  static async countAll(ctx: Context, entityClass?: Class): Promise<number> {
    return new Promise<number>((resolve, reject) => {
      const queue = DatabaseQueueManager.getQueryQueue();
      const task = new DatabaseTask({ type: DatabaseTaskType.COUNT_ALL });
      
      queue.setTaskContext(task.uniqueId, ctx);
      // 设置表名（如果提供实体类，转换为表名；否则使用默认表名）
      const tableName = entityClass ? GetTableName(entityClass) : 'processing_history';
      queue.setTaskTableName(task.uniqueId, tableName);
      
      queue.async(task, (result: ESObject) => {
        try {
          const taskResult = result as DatabaseTaskResult;
          if (taskResult.success && taskResult.data !== undefined) {
            resolve(taskResult.data as number);
          } else {
            const errorMsg = taskResult.error || '计数失败';
            hilog.error(DOMAIN, 'DatabaseQueueManager', `计数查询失败: ${errorMsg}`);
            reject(new Error(errorMsg));
          }
        } catch (err) {
          const error = err as Error | object;
          hilog.error(DOMAIN, 'DatabaseQueueManager', `处理计数结果失败: ${JSON.stringify(error)}`);
          reject(error instanceof Error ? error : new Error(String(error)));
        }
      });
    });
  }

  /**
   * 执行插入操作
   * @param ctx Context 上下文
   * @param values 插入的数据
   * @param entityClass 实体类（可选，默认使用 ProcessingHistory）
   */
  static async insert(ctx: Context, values: relationalStore.ValuesBucket, entityClass?: Class): Promise<number> {
    return new Promise<number>((resolve, reject) => {
      const queue = DatabaseQueueManager.getWriteQueue();
      const task = new DatabaseTask({ 
        type: DatabaseTaskType.INSERT, 
        values: values 
      });
      
      queue.setTaskContext(task.uniqueId, ctx);
      // 设置表名（如果提供实体类，转换为表名；否则使用默认表名）
      const tableName = entityClass ? GetTableName(entityClass) : 'processing_history';
      queue.setTaskTableName(task.uniqueId, tableName);
      
      queue.async(task, (result: ESObject) => {
        try {
          const taskResult = result as DatabaseTaskResult;
          if (taskResult.success && taskResult.data !== undefined) {
            resolve(taskResult.data as number);
          } else {
            const errorMsg = taskResult.error || '插入失败';
            hilog.error(DOMAIN, 'DatabaseQueueManager', `插入失败: ${errorMsg}`);
            reject(new Error(errorMsg));
          }
        } catch (err) {
          const error = err as Error | object;
          hilog.error(DOMAIN, 'DatabaseQueueManager', `处理插入结果失败: ${JSON.stringify(error)}`);
          reject(error instanceof Error ? error : new Error(String(error)));
        }
      });
    });
  }

  /**
   * 执行批量插入操作
   * @param ctx Context 上下文
   * @param valuesList 批量插入的数据列表
   * @param entityClass 实体类（可选，默认使用 ProcessingHistory）
   */
  static async batchInsert(ctx: Context, valuesList: Array<relationalStore.ValuesBucket>, entityClass?: Class): Promise<number> {
    return new Promise<number>((resolve, reject) => {
      const queue = DatabaseQueueManager.getWriteQueue();
      const task = new DatabaseTask({ 
        type: DatabaseTaskType.BATCH_INSERT, 
        valuesList: valuesList 
      });
      
      queue.setTaskContext(task.uniqueId, ctx);
      // 设置表名（如果提供实体类，转换为表名；否则使用默认表名）
      const tableName = entityClass ? GetTableName(entityClass) : 'processing_history';
      queue.setTaskTableName(task.uniqueId, tableName);
      
      queue.async(task, (result: ESObject) => {
        try {
          const taskResult = result as DatabaseTaskResult;
          if (taskResult.success && taskResult.data !== undefined) {
            resolve(taskResult.data as number);
          } else {
            const errorMsg = taskResult.error || '批量插入失败';
            hilog.error(DOMAIN, 'DatabaseQueueManager', `批量插入失败: ${errorMsg}`);
            reject(new Error(errorMsg));
          }
        } catch (err) {
          const error = err as Error | object;
          hilog.error(DOMAIN, 'DatabaseQueueManager', `处理批量插入结果失败: ${JSON.stringify(error)}`);
          reject(error instanceof Error ? error : new Error(String(error)));
        }
      });
    });
  }

  /**
   * 执行更新操作
   * @param ctx Context 上下文
   * @param id 记录ID
   * @param values 更新的数据
   * @param entityClass 实体类（可选，默认使用 ProcessingHistory）
   */
  static async update(ctx: Context, id: number, values: relationalStore.ValuesBucket, entityClass?: Class): Promise<number> {
    return new Promise<number>((resolve, reject) => {
      const queue = DatabaseQueueManager.getWriteQueue();
      const task = new DatabaseTask({ 
        type: DatabaseTaskType.UPDATE, 
        id: id, 
        values: values 
      });
      
      queue.setTaskContext(task.uniqueId, ctx);
      // 设置表名（如果提供实体类，转换为表名；否则使用默认表名）
      const tableName = entityClass ? GetTableName(entityClass) : 'processing_history';
      queue.setTaskTableName(task.uniqueId, tableName);
      
      queue.async(task, (result: ESObject) => {
        try {
          const taskResult = result as DatabaseTaskResult;
          if (taskResult.success && taskResult.data !== undefined) {
            resolve(taskResult.data as number);
          } else {
            const errorMsg = taskResult.error || '更新失败';
            hilog.error(DOMAIN, 'DatabaseQueueManager', `更新失败: ${errorMsg}`);
            reject(new Error(errorMsg));
          }
        } catch (err) {
          const error = err as Error | object;
          hilog.error(DOMAIN, 'DatabaseQueueManager', `处理更新结果失败: ${JSON.stringify(error)}`);
          reject(error instanceof Error ? error : new Error(String(error)));
        }
      });
    });
  }

  /**
   * 执行删除操作
   * @param ctx Context 上下文
   * @param id 记录ID
   * @param entityClass 实体类（可选，默认使用 ProcessingHistory）
   */
  static async delete(ctx: Context, id: number, entityClass?: Class): Promise<number> {
    return new Promise<number>((resolve, reject) => {
      const queue = DatabaseQueueManager.getWriteQueue();
      const task = new DatabaseTask({ 
        type: DatabaseTaskType.DELETE, 
        id: id 
      });
      
      queue.setTaskContext(task.uniqueId, ctx);
      // 设置表名（如果提供实体类，转换为表名；否则使用默认表名）
      const tableName = entityClass ? GetTableName(entityClass) : 'processing_history';
      queue.setTaskTableName(task.uniqueId, tableName);
      
      queue.async(task, (result: ESObject) => {
        try {
          const taskResult = result as DatabaseTaskResult;
          if (taskResult.success && taskResult.data !== undefined) {
            resolve(taskResult.data as number);
          } else {
            const errorMsg = taskResult.error || '删除失败';
            hilog.error(DOMAIN, 'DatabaseQueueManager', `删除失败: ${errorMsg}`);
            reject(new Error(errorMsg));
          }
        } catch (err) {
          const error = err as Error | object;
          hilog.error(DOMAIN, 'DatabaseQueueManager', `处理删除结果失败: ${JSON.stringify(error)}`);
          reject(error instanceof Error ? error : new Error(String(error)));
        }
      });
    });
  }

  /**
   * 执行原生 SQL 查询
   * @param ctx Context 上下文
   * @param sql SQL 语句
   */
  static async querySql<T = ESObject>(ctx: Context, sql: string): Promise<T[]> {
    return new Promise<T[]>((resolve, reject) => {
      const queue = DatabaseQueueManager.getQueryQueue();
      const task = new DatabaseTask({ 
        type: DatabaseTaskType.QUERY_SQL, 
        sql: sql 
      });
      
      queue.setTaskContext(task.uniqueId, ctx);
      // SQL 查询不需要表名，但为了兼容性可以设置为空字符串
      queue.setTaskTableName(task.uniqueId, '');
      
      queue.async(task, (result: ESObject) => {
        try {
          const taskResult = result as DatabaseTaskResult;
          if (taskResult.success && taskResult.data) {
            resolve(taskResult.data as T[]);
          } else {
            const errorMsg = taskResult.error || 'SQL查询失败';
            hilog.error(DOMAIN, 'DatabaseQueueManager', `SQL查询失败: ${errorMsg}`);
            reject(new Error(errorMsg));
          }
        } catch (err) {
          const error = err as Error | object;
          hilog.error(DOMAIN, 'DatabaseQueueManager', `处理SQL查询结果失败: ${JSON.stringify(error)}`);
          reject(error instanceof Error ? error : new Error(String(error)));
        }
      });
    });
  }

  /**
   * 根据条件查询
   * @param ctx Context 上下文
   * @param entityClass 实体类
   * @param whereClause 条件语句
   * @param args 参数
   */
  static async queryByCondition<T = ESObject>(ctx: Context, entityClass: Class, whereClause: string, args: Array<string | number | boolean>): Promise<T[]> {
    return new Promise<T[]>((resolve, reject) => {
      const queue = DatabaseQueueManager.getQueryQueue();
      const task = new DatabaseTask({ 
        type: DatabaseTaskType.QUERY_BY_CONDITION, 
        whereClause: whereClause,
        args: args
      });
      
      queue.setTaskContext(task.uniqueId, ctx);
      const tableName = GetTableName(entityClass);
      queue.setTaskTableName(task.uniqueId, tableName);
      
      queue.async(task, (result: ESObject) => {
        try {
          const taskResult = result as DatabaseTaskResult;
          if (taskResult.success && taskResult.data) {
            resolve(taskResult.data as T[]);
          } else {
            const errorMsg = taskResult.error || '条件查询失败';
            hilog.error(DOMAIN, 'DatabaseQueueManager', `条件查询失败: ${errorMsg}`);
            reject(new Error(errorMsg));
          }
        } catch (err) {
          const error = err as Error | object;
          hilog.error(DOMAIN, 'DatabaseQueueManager', `处理条件查询结果失败: ${JSON.stringify(error)}`);
          reject(error instanceof Error ? error : new Error(String(error)));
        }
      });
    });
  }
}

