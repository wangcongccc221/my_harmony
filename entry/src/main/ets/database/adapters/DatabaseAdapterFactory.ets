import { IDatabaseAdapter } from './IDatabaseAdapter';
import { SQLiteAdapter } from './SQLiteAdapter';

/**
 * 数据库适配器工厂
 * 负责创建和管理数据库适配器实例
 * 
 * 使用方式：
 * ```typescript
 * // 获取当前数据库适配器（默认是 SQLite）
 * const adapter = DatabaseAdapterFactory.getAdapter();
 * 
 * // 未来切换数据库时，只需修改这里：
 * // DatabaseAdapterFactory.setAdapter(new MySQLAdapter());
 * ```
 */
export class DatabaseAdapterFactory {
  // 当前使用的适配器实例（单例模式）
  private static adapter: IDatabaseAdapter | null = null;

  /**
   * 获取数据库适配器实例
   * 如果未初始化，则创建默认的 SQLiteAdapter
   */
  static getAdapter(): IDatabaseAdapter {
    if (!DatabaseAdapterFactory.adapter) {
      DatabaseAdapterFactory.adapter = new SQLiteAdapter();
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

