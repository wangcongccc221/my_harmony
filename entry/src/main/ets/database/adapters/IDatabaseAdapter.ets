import { Context } from '@kit.AbilityKit';
import { relationalStore } from '@kit.ArkData';
import { Class } from '../orm';

// ESObject 类型别名
type ESObject = object;

/**
 * 数据库适配器接口
 * 定义所有数据库操作的抽象方法
 * 实现此接口后，可以轻松切换不同的数据库（SQLite、MySQL等）
 * 
 * 使用场景：
 * - 当前：SQLiteAdapter 实现，使用 IBestORM
 * - 未来：MySQLAdapter 实现，使用 MySQL 客户端
 * - 调用方（DatabaseHelper）无需修改，只需切换适配器实例
 */
export interface IDatabaseAdapter {
  /**
   * 初始化数据库连接
   * @param ctx 应用上下文
   */
  initialize(ctx: Context): Promise<void>;

  /**
   * 查询所有记录
   * @param ctx 应用上下文
   * @param tableName 表名
   * @param modelClass 实体类（可选，用于类型转换）
   * @returns 查询结果数组
   */
  queryAll<T extends ESObject = ESObject>(
    ctx: Context,
    tableName: string,
    modelClass?: Class
  ): Promise<T[]>;

  /**
   * 分页查询
   * @param ctx 应用上下文
   * @param tableName 表名
   * @param page 页码（从1开始）
   * @param size 每页大小
   * @param modelClass 实体类（可选，用于类型转换）
   * @returns 查询结果数组
   */
  queryPage<T extends ESObject = ESObject>(
    ctx: Context,
    tableName: string,
    page: number,
    size: number,
    modelClass?: Class
  ): Promise<T[]>;

  /**
   * 统计记录总数
   * @param ctx 应用上下文
   * @param tableName 表名
   * @returns 记录总数
   */
  count(ctx: Context, tableName: string): Promise<number>;

  /**
   * 插入单条记录
   * @param ctx 应用上下文
   * @param tableName 表名
   * @param values 插入的数据
   * @returns 插入的记录ID
   */
  insert(ctx: Context, tableName: string, values: relationalStore.ValuesBucket): Promise<number>;

  /**
   * 批量插入记录
   * @param ctx 应用上下文
   * @param tableName 表名
   * @param valuesList 插入的数据数组
   * @returns 插入的记录数
   */
  batchInsert(
    ctx: Context,
    tableName: string,
    valuesList: Array<relationalStore.ValuesBucket>
  ): Promise<number>;

  /**
   * 更新记录
   * @param ctx 应用上下文
   * @param tableName 表名
   * @param id 记录ID
   * @param values 更新的数据
   * @returns 受影响的行数
   */
  update(
    ctx: Context,
    tableName: string,
    id: number,
    values: relationalStore.ValuesBucket
  ): Promise<number>;

  /**
   * 删除记录
   * @param ctx 应用上下文
   * @param tableName 表名
   * @param id 记录ID
   * @returns 受影响的行数
   */
  delete(ctx: Context, tableName: string, id: number): Promise<number>;

  /**
   * 执行原生SQL查询
   * @param ctx 应用上下文
   * @param sql SQL语句
   * @returns 查询结果
   */
  querySql<T extends ESObject = ESObject>(ctx: Context, sql: string): Promise<T[]>;

  /**
   * 执行原生SQL更新
   * @param ctx 应用上下文
   * @param sql SQL语句
   * @returns 受影响的行数
   */
  executeSql(ctx: Context, sql: string): Promise<number>;
}

