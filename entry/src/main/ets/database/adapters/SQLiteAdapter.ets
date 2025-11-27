import { Context } from '@kit.AbilityKit';
import { common } from '@kit.AbilityKit';
import { relationalStore } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { IBestORMInit, GetIBestORM, Class } from '../orm';
import { IDatabaseAdapter } from './IDatabaseAdapter';

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
      name: options?.dbName || 'article.db',
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
   * 统计记录总数
   */
  async count(ctx: Context, tableName: string): Promise<number> {
    await this.ensureInitialized(ctx);
    const db = this.getDatabase();

    const core = db.GetCore();
    if (!core) {
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

