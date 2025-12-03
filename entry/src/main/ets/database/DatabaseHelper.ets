import { Context } from '@kit.AbilityKit';
import { relationalStore } from '@kit.ArkData';
import { Class } from './orm';
import { DatabaseAdapterFactory } from './adapters/DatabaseAdapterFactory';

// ESObject 类型别名
type ESObject = object;

/**
 * 数据库操作封装类
 * 提供简单的静态方法，可以直接在任何地方使用
 * 
 * **重要**：此类通过数据库适配器接口操作数据库，不直接依赖 SQLite。
 * 未来切换数据库（如 MySQL）时，只需修改 `DatabaseAdapterFactory` 即可，无需修改此类的调用方。
 * 
 * 使用示例：
 * ```typescript
 * // 查询所有数据
 * const data = await DatabaseHelper.queryAll<ProcessingHistoryData>(ctx, 'processing_history', ProcessingHistory);
 * 
 * // 分页查询
 * const pageData = await DatabaseHelper.queryPage<ProcessingHistoryData>(ctx, 'processing_history', 1, 20, ProcessingHistory);
 * 
 * // 插入数据
 * const id = await DatabaseHelper.insert(ctx, 'processing_history', { name: 'test', value: 100 });
 * 
 * // 更新数据
 * const affected = await DatabaseHelper.update(ctx, 'processing_history', 1, { name: 'updated' });
 * 
 * // 删除数据
 * const deleted = await DatabaseHelper.delete(ctx, 'processing_history', 1);
 * ```
 */
export class DatabaseHelper {
  // 初始化 Promise 缓存，避免重复初始化
  private static initPromise: Promise<void> | null = null;
  private static initContext: Context | null = null;

  /**
   * 获取数据库适配器实例
   */
  private static getAdapter() {
    return DatabaseAdapterFactory.getAdapter();
  }

  /**
   * 初始化数据库（如果需要）
   * 使用 Promise 缓存，避免并发调用时重复初始化
   */
  private static async initIfNeeded(ctx: Context): Promise<void> {
    // 如果已经初始化过且 Context 相同，直接返回
    if (DatabaseHelper.initPromise && DatabaseHelper.initContext === ctx) {
      return DatabaseHelper.initPromise;
    }
    
    // 创建新的初始化 Promise
    DatabaseHelper.initContext = ctx;
    DatabaseHelper.initPromise = (async () => {
      const adapter = DatabaseHelper.getAdapter();
      await adapter.initialize(ctx);
    })();
    
    return DatabaseHelper.initPromise;
  }
 
  /** 
   * 查询所有记录
   * @param ctx 应用上下文
   * @param tableName 表名
   * @param modelClass 实体类（可选，用于类型转换）
   * @returns 查询结果数组
   */
  static async queryAll<T extends ESObject = ESObject>(
    ctx: Context,
    tableName: string,
    modelClass?: Class
  ): Promise<T[]> {
    await DatabaseHelper.initIfNeeded(ctx);
    const adapter = DatabaseHelper.getAdapter();
    return await adapter.queryAll<T>(ctx, tableName, modelClass);
  }

  /**
   * 分页查询
   * @param ctx 应用上下文
   * @param tableName 表名
   * @param page 页码（从1开始）
   * @param size 每页大小
   * @param modelClass 实体类（可选，用于类型转换）
   * @returns 查询结果数组
   */
  static async queryPage<T extends ESObject = ESObject>(
    ctx: Context,
    tableName: string,
    page: number,
    size: number,
    modelClass?: Class
  ): Promise<T[]> {
    await DatabaseHelper.initIfNeeded(ctx);
    const adapter = DatabaseHelper.getAdapter();
    return await adapter.queryPage<T>(ctx, tableName, page, size, modelClass);
  }

  /**
   * 根据条件查询记录
   * @param ctx 应用上下文
   * @param tableName 表名
   * @param whereClause WHERE 子句（例如 "customer_id = ?"）
   * @param args 参数数组
   * @param modelClass 实体类（可选，用于类型转换）
   * @returns 查询结果数组
   */
  static async queryByCondition<T extends ESObject = ESObject>(
    ctx: Context,
    tableName: string,
    whereClause: string,
    args: Array<string | number | boolean>,
    modelClass?: Class
  ): Promise<T[]> {
    await DatabaseHelper.initIfNeeded(ctx);
    const adapter = DatabaseHelper.getAdapter();
    return await adapter.queryByCondition<T>(ctx, tableName, whereClause, args, modelClass);
  }

  /**
   * 统计记录总数
   * @param ctx 应用上下文
   * @param tableName 表名
   * @returns 记录总数
   */
  static async count(ctx: Context, tableName: string): Promise<number> {
    await DatabaseHelper.initIfNeeded(ctx);
    const adapter = DatabaseHelper.getAdapter();
    return await adapter.count(ctx, tableName);
  }

  /**
   * 插入单条记录
   * @param ctx 应用上下文
   * @param tableName 表名
   * @param values 插入的数据
   * @returns 插入的记录ID
   */
  static async insert(ctx: Context, tableName: string, values: relationalStore.ValuesBucket): Promise<number> {
    await DatabaseHelper.initIfNeeded(ctx);
    const adapter = DatabaseHelper.getAdapter();
    return await adapter.insert(ctx, tableName, values);
  }

  /**
   * 批量插入记录
   * @param ctx 应用上下文
   * @param tableName 表名
   * @param valuesList 插入的数据数组
   * @returns 插入的记录数
   */
  static async batchInsert(ctx: Context, tableName: string, valuesList: Array<relationalStore.ValuesBucket>): Promise<number> {
    await DatabaseHelper.initIfNeeded(ctx);
    const adapter = DatabaseHelper.getAdapter();
    return await adapter.batchInsert(ctx, tableName, valuesList);
  }

  /**
   * 更新记录
   * @param ctx 应用上下文
   * @param tableName 表名
   * @param id 记录ID
   * @param values 更新的数据
   * @returns 受影响的行数
   */
  static async update(ctx: Context, tableName: string, id: number, values: relationalStore.ValuesBucket): Promise<number> {
    await DatabaseHelper.initIfNeeded(ctx);
    const adapter = DatabaseHelper.getAdapter();
    return await adapter.update(ctx, tableName, id, values);
  }

  /**
   * 删除记录
   * @param ctx 应用上下文
   * @param tableName 表名
   * @param id 记录ID
   * @returns 受影响的行数
   */
  static async delete(ctx: Context, tableName: string, id: number): Promise<number> {
    await DatabaseHelper.initIfNeeded(ctx);
    const adapter = DatabaseHelper.getAdapter();
    return await adapter.delete(ctx, tableName, id);
  }

  /**
   * 执行原生SQL查询
   * @param ctx 应用上下文
   * @param sql SQL语句
   * @returns 查询结果
   */
  static async querySql<T extends ESObject = ESObject>(ctx: Context, sql: string): Promise<T[]> {
    await DatabaseHelper.initIfNeeded(ctx);
    const adapter = DatabaseHelper.getAdapter();
    return await adapter.querySql<T>(ctx, sql);
  }

  /**
   * 执行原生SQL更新
   * @param ctx 应用上下文
   * @param sql SQL语句
   * @returns 受影响的行数
   */
  static async executeSql(ctx: Context, sql: string): Promise<number> {
    await DatabaseHelper.initIfNeeded(ctx);
    const adapter = DatabaseHelper.getAdapter();
    return await adapter.executeSql(ctx, sql);
  }
}

