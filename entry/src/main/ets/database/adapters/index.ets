/**
 * 数据库适配器模块导出
 * 
 * 使用方式：
 * ```typescript
 * import { DatabaseAdapterFactory, IDatabaseAdapter, SQLiteAdapter } from '../database/adapters';
 * 
 * // 获取当前适配器（默认是 SQLite）
 * const adapter = DatabaseAdapterFactory.getAdapter();
 * 
 * // 未来切换数据库时：
 * // DatabaseAdapterFactory.setAdapter(new MySQLAdapter());
 * ```
 */

export { IDatabaseAdapter } from './IDatabaseAdapter';
export { SQLiteAdapter } from './SQLiteAdapter';
export { DatabaseAdapterFactory } from './DatabaseAdapterFactory';

