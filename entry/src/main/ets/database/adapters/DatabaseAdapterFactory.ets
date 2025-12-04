import { IDatabaseAdapter } from './IDatabaseAdapter';
import { SQLiteAdapter, SQLiteAdapterConfig } from './SQLiteAdapter';
import { ProcessingHistory } from '../models/ProcessingHistory';
import { FruitInfo } from '../models/FruitInfo';
import { GradeInfo } from '../models/GradeInfo';
import { ExportInfo } from '../models/ExportInfo';
import { Class } from '../orm';

/**
 * 数据库适配器工厂
 * 负责创建和管理数据库适配器实例
 * 
 * 使用方式：
 * ```typescript
 * // 获取当前数据库适配器（默认是 SQLite，自动迁移所有模型）
 * const adapter = DatabaseAdapterFactory.getAdapter();
 * 
 * // 带配置初始化（自动迁移模型）
 * DatabaseAdapterFactory.initialize({
 *   dbName: 'my_app.db',
 *   models: [User, Product]
 * });
 * 
 * // 未来切换数据库时：
 * DatabaseAdapterFactory.setAdapter(new MySQLAdapter());
 * ```
 */
export class DatabaseAdapterFactory {
  // 当前使用的适配器实例（单例模式）
  private static adapter: IDatabaseAdapter | null = null;
  
  // 默认需要迁移的所有模型
  private static readonly DEFAULT_MODELS: Class[] = [
    ProcessingHistory,
    FruitInfo,
    GradeInfo,
    ExportInfo
  ];

  /**
   * 初始化适配器（带配置）
   * @param config SQLite 适配器配置
   */
  static initialize(config?: SQLiteAdapterConfig): void {
    if (!DatabaseAdapterFactory.adapter) {
      DatabaseAdapterFactory.adapter = new SQLiteAdapter(config);
    }
  }

  /**
   * 获取数据库适配器实例
   * 如果未初始化，则创建默认的 SQLiteAdapter（自动迁移所有模型）
   */
  static getAdapter(): IDatabaseAdapter {
    if (!DatabaseAdapterFactory.adapter) {
      // 使用默认配置，包含所有需要迁移的模型
      DatabaseAdapterFactory.adapter = new SQLiteAdapter({
        dbName: 'db_fruitsor.db',
        models: DatabaseAdapterFactory.DEFAULT_MODELS
      });
    }
    return DatabaseAdapterFactory.adapter;
  }

  /**
   * 设置数据库适配器实例
   * 用于切换不同的数据库实现（例如：从 SQLite 切换到 MySQL）
   * 
   * @param adapter 新的适配器实例
   */
  static setAdapter(adapter: IDatabaseAdapter): void {
    DatabaseAdapterFactory.adapter = adapter;
  }

  /**
   * 重置适配器（用于测试或重新初始化）
   */
  static reset(): void {
    DatabaseAdapterFactory.adapter = null;
  }
}

