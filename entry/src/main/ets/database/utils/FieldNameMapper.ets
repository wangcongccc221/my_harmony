/**
 * 字段名映射工具
 * 将模型字段名（PascalCase）转换为数据库字段名（snake_case）
 */

/**
 * ProcessingHistory 字段名映射接口
 */
export interface ProcessingHistoryFieldMap {
  CustomerName: string;
  FarmName: string;
  FruitName: string;
  Status: string;
  StartTime: string;
  EndTime: string;
  Weight: string;
  Quantity: string;
}

/**
 * TestModel 字段名映射接口
 */
export interface TestModelFieldMap {
  Title: string;
  Description: string;
  Count: string;
  IsEnabled: string;
}

/**
 * User 字段名映射接口
 */
export interface UserFieldMap {
  Name: string;
  Age: string;
}

/**
 * 将 PascalCase 字段名转换为 snake_case
 * @param fieldName 字段名（如 "CustomerName", "StartTime"）
 * @returns 数据库字段名（如 "customer_name", "start_time"）
 */
export function toSnakeCase(fieldName: string): string {
  return fieldName
    .replace(/([A-Z])/g, '_$1')  // 在大写字母前加下划线
    .toLowerCase()                // 转小写
    .replace(/^_/, '')            // 去掉开头的下划线
}

/**
 * ProcessingHistory 字段名映射
 */
export const PROCESSING_HISTORY_FIELDS: ProcessingHistoryFieldMap = {
  CustomerName: 'customer_name',
  FarmName: 'farm_name',
  FruitName: 'fruit_name',
  Status: 'status',
  StartTime: 'start_time',
  EndTime: 'end_time',
  Weight: 'weight',
  Quantity: 'quantity'
}

/**
 * TestModel 字段名映射
 */
export const TEST_MODEL_FIELDS: TestModelFieldMap = {
  Title: 'title',
  Description: 'description',
  Count: 'count',
  IsEnabled: 'is_enabled'
}

/**
 * User 字段名映射
 */
export const USER_FIELDS: UserFieldMap = {
  Name: 'name',
  Age: 'age'
}

