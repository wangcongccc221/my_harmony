/**
 * 数据库模块统一导出入口
 * 
 * 使用方式：
 * ```typescript
 * import { DatabaseInterface, DatabaseAdapterFactory } from './database';
 * 
 * // 查询数据
 * const data = await DatabaseInterface.queryAll<MyModel>(ctx, 'table_name', MyModel);
 * 
 * // 插入数据
 * const id = await DatabaseInterface.insert(ctx, 'table_name', { name: 'test', value: 100 });
 * 
 * // 带配置初始化（自动迁移模型）
 * import { User, Product } from './models';
 * DatabaseAdapterFactory.initialize({
 *   dbName: 'my_app.db',
 *   models: [User, Product]  // 需要自动迁移的模型
 * });
 * ```
 * 
 * 高级用法（切换数据库）：
 * ```typescript
 * import { DatabaseInterface, DatabaseAdapterFactory, MySQLAdapter } from './database';
 * 
 * // 切换数据库
 * DatabaseAdapterFactory.setAdapter(new MySQLAdapter());
 * 
 * // 之后所有 DatabaseInterface 的调用都会使用 MySQL
 * const data = await DatabaseInterface.queryAll(ctx, 'table_name');
 * ```
 */

// 主要使用入口：DatabaseInterface（推荐）
export { DatabaseInterface } from './DatabaseInterface';

// 适配器相关（高级用法）
export { IDatabaseAdapter } from './adapters/IDatabaseAdapter';
export { SQLiteAdapter, SQLiteAdapterConfig } from './adapters/SQLiteAdapter';
export { DatabaseAdapterFactory } from './adapters/DatabaseAdapterFactory';

// ORM 相关（如果需要直接使用 ORM）
export * from './orm';

// 类型定义
export * from './types';

