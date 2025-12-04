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
    }
    
    if (db) {
      // 如果提供了模型列表，则自动迁移（无论之前是否已初始化）
      if (this.models.length > 0) {
        for (const modelClass of this.models) {
          db.AutoMigrate(modelClass);
        }
        hilog.info(DOMAIN, TAG, `SQLite 数据库已初始化，已迁移 ${this.models.length} 个模型`);
      } else {
        hilog.info(DOMAIN, TAG, 'SQLite 数据库已初始化（无自动迁移）');
      }
    } else {
      throw new Error('SQLite 数据库初始化失败：GetIBestORM() 返回 undefined');
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
    const primaryKeyField = this.getPrimaryKeyField(tableName);

    if (modelClass) {
      const records = db.Table(tableName).OrderByDesc(primaryKeyField).Find(modelClass) as T[];
      return records || [];
    } else {
      const records = db.Table(tableName).OrderByDesc(primaryKeyField).Find() as T[];
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
    const primaryKeyField = this.getPrimaryKeyField(tableName);

    const p = Math.max(1, page);
    const s = Math.max(1, Math.min(100, size));
    const offset = (p - 1) * s;

    let query = db.Table(tableName).OrderByDesc(primaryKeyField).Limit(s).Offset(offset);

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

    const primaryKeyField = this.getPrimaryKeyField(tableName);
    if (whereClause.includes('=') && args.length === 1) {
      const field = whereClause.split('=')[0].trim();
      const value = args[0];
      if (modelClass) {
        return db.Table(tableName).Where(field, value).OrderByDesc(primaryKeyField).Find(modelClass) as T[];
      } else {
        return db.Table(tableName).Where(field, value).OrderByDesc(primaryKeyField).Find() as T[];
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
    sql += ` ORDER BY ${primaryKeyField} DESC`;
    
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
    
    try {
      // 移除主键字段（如果是 autoIncrement）
      const primaryKeyField = this.getPrimaryKeyField(tableName);
      const insertValues: relationalStore.ValuesBucket = {};
      
      // 复制所有字段，除了主键
      const keys = Object.keys(values);
      for (const key of keys) {
        if (key !== primaryKeyField) {
          insertValues[key] = values[key];
        }
      }
      
      hilog.info(DOMAIN, TAG, `插入数据到表 ${tableName}，字段: ${JSON.stringify(Object.keys(insertValues))}`);
      hilog.info(DOMAIN, TAG, `插入数据值: ${JSON.stringify(insertValues)}`);
      
      // 检查表是否存在
      const core = db.GetCore();
      if (core) {
        try {
          const rs = core.querySqlSync(`SELECT name FROM sqlite_master WHERE type='table' AND name='${tableName}';`);
          const tableExists = rs.columnCount > 0 && rs.goToFirstRow();
          rs.close();
          hilog.info(DOMAIN, TAG, `表 ${tableName} 是否存在: ${tableExists}`);
          
          if (tableExists) {
            // 获取表结构
            const infoRs = core.querySqlSync(`PRAGMA table_info('${tableName}');`);
            const columns: string[] = [];
            if (infoRs.columnCount > 0 && infoRs.goToFirstRow()) {
              do {
                const colName = infoRs.getString(infoRs.getColumnIndex('name'));
                columns.push(colName);
              } while (infoRs.goToNextRow());
            }
            infoRs.close();
            hilog.info(DOMAIN, TAG, `表 ${tableName} 的字段: ${JSON.stringify(columns)}`);
          }
        } catch (e) {
          hilog.warn(DOMAIN, TAG, `检查表结构失败: ${e instanceof Error ? e.message : String(e)}`);
        }
      }
      
      const insertId = db.Table(tableName).Insert(insertValues);
      hilog.info(DOMAIN, TAG, `插入成功，返回ID: ${insertId}`);
      return insertId || 0;
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      hilog.error(DOMAIN, TAG, `插入失败 - 表: ${tableName}, 错误: ${errorMsg}, 数据: ${JSON.stringify(Object.keys(values))}`);
      throw new Error(`插入失败 - 表: ${tableName}, 错误: ${errorMsg}`);
    }
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
   * 根据表名获取主键字段名
   *
   * 注意：由于 camelToSnakeCase 对结尾为 "ID" 的属性会生成 "customer_i_d" 这种形式，
   * 实际表结构中的主键字段名与预期的 "customer_id"、"f_id" 不同。
   * 这里需要按真实表结构返回正确的列名。
   */
  private getPrimaryKeyField(tableName: string): string {
    // 根据表名确定主键字段（使用实际 PRAGMA table_info 返回的列名）
    if (tableName === 'tb_fruitinfo') {
      // CustomerID -> customer_i_d
      return 'customer_i_d';
    } else if (tableName === 'tb_gradeinfo' || tableName === 'tb_exportinfo') {
      // FID -> fid
      return 'fid';
    } else {
      // 默认使用 id（适用于 processing_history, article 等表）
      return 'id';
    }
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
    const primaryKeyField = this.getPrimaryKeyField(tableName);
    const affected = db.Table(tableName).Where(primaryKeyField, id).Update(values);
    return affected || 0;
  }

  /**
   * 删除记录
   */
  async delete(ctx: Context, tableName: string, id: number): Promise<number> {
    await this.ensureInitialized(ctx);
    const db = this.getDatabase();
    const primaryKeyField = this.getPrimaryKeyField(tableName);
    const affected = db.Table(tableName).Where(primaryKeyField, id).Delete();
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

