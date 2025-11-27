/**
 * 数据库模块统一导出入口
 * 
 * 其他项目使用方式：
 * ```typescript
 * import { DatabaseHelper, DatabaseAdapterFactory } from './database';
 * 
 * // 方式1: 基本使用（不自动迁移模型）
 * // 直接使用，数据库会在首次调用时自动初始化
 * const data = await DatabaseHelper.queryAll(ctx, 'table_name');
 * 
 * // 方式2: 带配置使用（自动迁移模型）
 * import { User, Product } from './models';
 * DatabaseAdapterFactory.initialize({
 *   dbName: 'my_app.db',
 *   models: [User, Product]  // 需要自动迁移的模型
 * });
 * const data = await DatabaseHelper.queryAll(ctx, 'users');
 * ```
 * 
 * 高级用法（切换数据库）：
 * ```typescript
 * import { DatabaseHelper, DatabaseAdapterFactory, MySQLAdapter } from './database';
 * 
 * // 切换数据库
 * DatabaseAdapterFactory.setAdapter(new MySQLAdapter());
 * 
 * // 之后所有 DatabaseHelper 的调用都会使用 MySQL
 * const data = await DatabaseHelper.queryAll(ctx, 'table_name');
 * ```
 */

// 主要使用入口：DatabaseHelper（推荐）
export { DatabaseHelper } from './DatabaseHelper';

// 适配器相关（高级用法）
export { IDatabaseAdapter } from './adapters/IDatabaseAdapter';
export { SQLiteAdapter, SQLiteAdapterConfig } from './adapters/SQLiteAdapter';
export { DatabaseAdapterFactory } from './adapters/DatabaseAdapterFactory';

// ORM 相关（如果需要直接使用 ORM）
export * from './orm';

// 类型定义
export * from './types';

