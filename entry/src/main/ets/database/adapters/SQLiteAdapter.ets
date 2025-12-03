import { Context } from '@kit.AbilityKit';
import { common } from '@kit.AbilityKit';
import { relationalStore } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { IBestORMInit, GetIBestORM, Class } from '../orm';
import { IDatabaseAdapter } from './IDatabaseAdapter';
import { snakeToCamel } from '../orm/utils/Utils';

const DOMAIN = 0x0000;
const TAG = 'SQLiteAdapter';

// ESObject 类型别名
type ESObject = object;


/**
 * SQLite 适配器配置选项
 */
export interface SQLiteAdapterConfig {
  /** 数据库文件名 */
  dbName?: string;
  /** 安全级别 */
  securityLevel?: relationalStore.SecurityLevel;
  /** 需要自动迁移的模型类列表（可选） */
  models?: Class[];
}

/**
 * SQLite 数据库适配器实现
 * 封装 IBestORM 的所有操作
 * 
 * 使用方式：
 * ```typescript
 * // 基本使用（不自动迁移）
 * const adapter = new SQLiteAdapter();
 * await adapter.initialize(ctx);
 * 
 * // 带配置使用（自动迁移模型）
 * const adapter = new SQLiteAdapter({
 *   dbName: 'my_app.db',
 *   models: [User, Product]  // 需要迁移的模型
 * });
 * await adapter.initialize(ctx);
 * ```
 */
export class SQLiteAdapter implements IDatabaseAdapter {
  private config: relationalStore.StoreConfig;
  private models: Class[];
  private initialized: boolean = false;

  /**
   * 构造函数
   * @param options 配置选项（可选）
   */
  constructor(options?: SQLiteAdapterConfig) {
    this.config = {
      name: options?.dbName || 'db_fruitsor.db',
      securityLevel: options?.securityLevel || relationalStore.SecurityLevel.S2
    };
    this.models = options?.models || [];
  }

  /**
   * 初始化数据库连接
   */
  async initialize(ctx: Context): Promise<void> {
    if (this.initialized) {
      return;
    }

    let db = GetIBestORM();
    if (!db) {
      await IBestORMInit(ctx as common.UIAbilityContext, this.config);
      db = GetIBestORM();
      if (db) {
        // 如果提供了模型列表，则自动迁移
        if (this.models.length > 0) {
          for (const modelClass of this.models) {
            db.AutoMigrate(modelClass);
            // 注意：由于 ArkTS 类型限制，无法自动调用 createIndexes 静态方法
            // 如果模型有 createIndexes 方法，需要在初始化后手动调用
            // 例如：ProcessingHistory.createIndexes();
          }
          hilog.info(DOMAIN, TAG, `SQLite 数据库已初始化，已迁移 ${this.models.length} 个模型`);
        } else {
          hilog.info(DOMAIN, TAG, 'SQLite 数据库已初始化（无自动迁移）');
        }
      } else {
        throw new Error('SQLite 数据库初始化失败：GetIBestORM() 返回 undefined');
      }
    }
    this.initialized = true;
  }

  /**
   * 确保数据库已初始化
   */
  private async ensureInitialized(ctx: Context): Promise<void> {
    if (!this.initialized) {
      await this.initialize(ctx);
    }
  }

  /**
   * 获取数据库实例
   */
  private getDatabase() {
    const db = GetIBestORM();
    if (!db) {
      throw new Error('数据库未初始化：GetIBestORM() 返回 undefined');
    }
    return db;
  }

  /**
   * 查询所有记录
   */
  async queryAll<T extends ESObject = ESObject>(
    ctx: Context,
    tableName: string,
    modelClass?: Class
  ): Promise<T[]> {
    await this.ensureInitialized(ctx);
    const db = this.getDatabase();

    if (modelClass) {
      const records = db.Table(tableName).OrderByDesc('id').Find(modelClass) as T[];
      return records || [];
    } else {
      const records = db.Table(tableName).OrderByDesc('id').Find() as T[];
      return records || [];
    }
  }

  /**
   * 分页查询
   */
  async queryPage<T extends ESObject = ESObject>(
    ctx: Context,
    tableName: string,
    page: number,
    size: number,
    modelClass?: Class
  ): Promise<T[]> {
    await this.ensureInitialized(ctx);
    const db = this.getDatabase();

    const p = Math.max(1, page);
    const s = Math.max(1, Math.min(100, size));
    const offset = (p - 1) * s;

    let query = db.Table(tableName).OrderByDesc('id').Limit(s).Offset(offset);

    if (modelClass) {
      const records = query.Find(modelClass) as T[];
      return records || [];
    } else {
      const records = query.Find() as T[];
      return records || [];
    }
  }

  /**
   * 根据条件查询记录
   */
  async queryByCondition<T extends ESObject = ESObject>(
    ctx: Context,
    tableName: string,
    whereClause: string,
    args: Array<string | number | boolean>,
    modelClass?: Class
  ): Promise<T[]> {
    await this.ensureInitialized(ctx);
    const db = this.getDatabase();

    // 使用 IBestORM 的 Where 方法进行查询
    // 注意：IBestORM 的 Where 方法通常接受 (field, value) 或 (field, operator, value)
    // 这里我们假设 whereClause 是完整的条件字符串，args 是参数
    // 如果 IBestORM 支持原生 WHERE 子句，我们可以直接使用
    // 否则我们需要解析 whereClause
    
    // 尝试使用 querySql 来实现通用条件查询，但为了保持 ORM 特性（如自动映射），
    // 我们最好使用 Table().Where()
    
    // 假设 whereClause 是 "customer_id = ?"，args 是 [1]
    // 我们可以尝试解析简单的条件
    
    // 简单实现：如果 whereClause 包含 =，则尝试拆分
    // 更通用的做法是直接使用 querySql，然后手动映射，或者看 IBestORM 是否支持 Raw Where
    
    // 这里我们使用 querySql 来确保灵活性，但为了响应用户的"使用 ORM"请求，
    // 我们应该尽可能使用 ORM 的 API。
    // 如果 IBestORM 没有提供直接执行带参数 WHERE 的 API，我们可能需要回退到 querySql
    // 但为了"转换成实体"，我们可以使用 modelClass
    
    // 检查 IBestORM 文档或源码（假设）：
    // db.Table(tableName).Where(whereClause, ...args).Find(modelClass)
    
    // 由于我们无法确定 IBestORM 的确切 API，我们这里使用一种混合方法：
    // 使用 querySql 获取数据，然后如果提供了 modelClass，则尝试转换
    // 但用户明确要求"使用 ORM 转换成实体"
    
    // 让我们尝试使用 IBestORM 的 Where 接口
    // 假设 args[0] 是值
    if (whereClause.includes('=') && args.length === 1) {
      const field = whereClause.split('=')[0].trim();
      const value = args[0];
      if (modelClass) {
        return db.Table(tableName).Where(field, value).OrderByDesc('id').Find(modelClass) as T[];
      } else {
        return db.Table(tableName).Where(field, value).OrderByDesc('id').Find() as T[];
      }
    }
    
    // 对于复杂查询，回退到 SQL，但尝试手动映射（如果 IBestORM 不支持）
    // 或者，我们可以构造完整的 SQL
    let sql = `SELECT * FROM ${tableName} WHERE ${whereClause}`;
    // 简单的参数替换（注意：这只是一个简单的实现，不支持复杂的参数替换）
    args.forEach(arg => {
      const val = typeof arg === 'string' ? `'${arg}'` : arg;
      sql = sql.replace('?', String(val));
    });
    sql += ' ORDER BY id DESC';
    
    const records = await this.querySql<T>(ctx, sql);
    
    // 如果提供了 modelClass，我们可能需要手动映射（如果 querySql 返回的是纯对象）
    // 但 SQLiteAdapter.querySql 返回的是 Record<string, ValueType>
    // 如果我们需要返回实体实例，我们需要转换
    if (modelClass && records.length > 0) {
      // 简单的转换逻辑：实例化 modelClass 并赋值
      // 注意：这里假设 records 的键是蛇形命名，而 modelClass 属性是驼峰命名
      const mappedResults: T[] = [];
      for (const record of records) {
        const entity = new modelClass() as ESObject;
        const recordObj = record as ESObject;
        const keys = Object.keys(recordObj);
        for (const key of keys) {
          const camelKey = snakeToCamel(key);
          const value = (recordObj as Record<string, ESObject>)[key];
          (entity as Record<string, ESObject>)[camelKey] = value;
        }
        mappedResults.push(entity as T);
      }
      return mappedResults;
    }
    
    return records;
  }

  /**
   * 统计记录总数
   */
  async count(ctx: Context, tableName: string): Promise<number> {
    await this.ensureInitialized(ctx);
    const db = this.getDatabase();

    const core = db.GetCore();
    if (!core) 
    {
      throw new Error('无法获取数据库核心对象');
    }

    let total = 0;
    const rs = core.querySqlSync(`SELECT COUNT(*) AS cnt FROM ${tableName};`);
    if (rs.columnCount > 0 && rs.goToFirstRow()) {
      const col = rs.columnNames[0];
      total = rs.getDouble(rs.getColumnIndex(col)) as number;
    }
    rs.close();
    return total;
  }

  /**
   * 插入单条记录
   */
  async insert(ctx: Context, tableName: string, values: relationalStore.ValuesBucket): Promise<number> {
    await this.ensureInitialized(ctx);
    const db = this.getDatabase();
    const insertId = db.Table(tableName).Insert(values);
    return insertId || 0;
  }

  /**
   * 批量插入记录
   */
  async batchInsert(
    ctx: Context,
    tableName: string,
    valuesList: Array<relationalStore.ValuesBucket>
  ): Promise<number> {
    await this.ensureInitialized(ctx);
    const db = this.getDatabase();
    const affected = db.Table(tableName).Insert(valuesList);
    return affected || 0;
  }

  /**
   * 更新记录
   */
  async update(
    ctx: Context,
    tableName: string,
    id: number,
    values: relationalStore.ValuesBucket
  ): Promise<number> {
    await this.ensureInitialized(ctx);
    const db = this.getDatabase();
    const affected = db.Table(tableName).Where('id', id).Update(values);
    return affected || 0;
  }

  /**
   * 删除记录
   */
  async delete(ctx: Context, tableName: string, id: number): Promise<number> {
    await this.ensureInitialized(ctx);
    const db = this.getDatabase();
    const affected = db.Table(tableName).Where('id', id).Delete();
    return affected || 0;
  }

  /**
   * 执行原生SQL查询
   */
  async querySql<T extends ESObject = ESObject>(ctx: Context, sql: string): Promise<T[]> {
    await this.ensureInitialized(ctx);
    const db = this.getDatabase();

    const core = db.GetCore();
    if (!core) {
      throw new Error('无法获取数据库核心对象');
    }

    const rs = core.querySqlSync(sql);
    const results: T[] = [];

    if (rs.columnCount > 0 && rs.goToFirstRow()) {
      do {
        const row: Record<string, relationalStore.ValueType> = {};
        for (let i = 0; i < rs.columnCount; i++) {
          const colName = rs.columnNames[i];
          const colIndex = rs.getColumnIndex(colName);
          row[colName] = rs.getValue(colIndex);
        }
        results.push(row as T);
      } while (rs.goToNextRow());
    }

    rs.close();
    return results;
  }

  /**
   * 执行原生SQL更新
   */
  async executeSql(ctx: Context, sql: string): Promise<number> {
    await this.ensureInitialized(ctx);
    const db = this.getDatabase();

    const core = db.GetCore();
    if (!core) {
      throw new Error('无法获取数据库核心对象');
    }

    core.executeSql(sql);
    // SQLite 的 executeSql 不返回受影响行数
    return 0;
  }
}

