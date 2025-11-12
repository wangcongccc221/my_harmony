/**
 * 数据库模块统一导出
 * 方便外部使用数据库相关功能
 */

// 导出数据库管理器
export { DatabaseManager } from './DatabaseManager';

// 导出数据模型
export { User } from './models/User';
export { TestModel } from './models/TestModel';
export { ProcessingHistory } from './models/ProcessingHistory';

// 导出数据类型
export { UserData, TestData, ProcessingHistoryData, CreateUserParams, CreateTestRecordParams, CreateProcessingHistoryParams } from './types';

// 导出工具函数
export { TABLE_NAMES, getTableName } from './utils/TableNameMapper';
export { toSnakeCase, PROCESSING_HISTORY_FIELDS, TEST_MODEL_FIELDS, USER_FIELDS } from './utils/FieldNameMapper';
export { processingHistoryToValueBucket, convertToProcessingHistoryData, getValueFromResult } from './utils/DataConverter';
export { setValueIfNotEmpty, setValueWithDefault, cleanEmptyStrings } from './utils/ValueBucketHelper';

