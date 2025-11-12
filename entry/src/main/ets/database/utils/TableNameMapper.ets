/**
 * 表名映射工具
 * 将模型类名转换为数据库表名
 */

/**
 * 表名映射接口
 */
export interface TableNameMap {
  User: string;
  TestModel: string;
  ProcessingHistory: string;
}

/**
 * 获取表名（将类名转换为数据库表名）
 * @param className 类名（如 "User", "TestModel", "ProcessingHistory"）
 * @returns 数据库表名（小写下划线格式，如 "user", "test_model", "processing_history"）
 */
export function getTableName(className: string): string {
  // 将 PascalCase 转换为 snake_case
  // 例如: "TestModel" -> "test_model", "ProcessingHistory" -> "processing_history"
  return className
    .replace(/([A-Z])/g, '_$1')  // 在大写字母前加下划线
    .toLowerCase()                // 转小写
    .replace(/^_/, '')            // 去掉开头的下划线
}

/**
 * 预定义的表名映射（避免每次都计算）
 */
export const TABLE_NAMES: TableNameMap = {
  User: 'user',
  TestModel: 'test_model',
  ProcessingHistory: 'processing_history'
}

