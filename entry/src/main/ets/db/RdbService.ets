// 统一数据库服务导出别名，避免 "ArkDataDemo" 命名造成误解
// 后续逐步将项目中的引用改为从本文件导入

export { ArkDataDemoService as RdbService } from './ArkDataDemo'
export type { ProcessingRow, ProcessingInsertParams } from './ArkDataDemo'
export type { FruitInfoRow, FruitInfoInsertParams } from './ArkDataDemo'


