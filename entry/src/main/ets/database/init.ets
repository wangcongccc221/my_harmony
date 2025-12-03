/**
 * 数据库初始化配置
 * 当前项目使用此文件配置需要自动迁移的模型
 * 
 * 其他项目可以：
 * 1. 不导入此文件（不自动迁移，手动管理）
 * 2. 创建自己的 init.ets，配置自己的模型
 */

import { DatabaseAdapterFactory } from './adapters/DatabaseAdapterFactory';
import { ProcessingHistory } from './models/ProcessingHistory';
import { FruitInfo } from './models/FruitInfo';
import { GradeInfo } from './models/GradeInfo';
import { ExportInfo } from './models/ExportInfo';

/**
 * 初始化数据库适配器（当前项目专用）
 * 在应用启动时调用此函数
 * 
 * 使用方式：
 * ```typescript
 * import { initDatabase } from './database/init';
 * 
 * // 在 EntryAbility 的 onWindowStageCreate 中调用
 * initDatabase();
 * ```
 */
export function initDatabase(): void {
  DatabaseAdapterFactory.initialize({
    dbName: 'db_fruitsor.db',
    models: [ProcessingHistory, FruitInfo, GradeInfo, ExportInfo]  // 当前项目需要迁移的模型
  });
  
  // 由于 ArkTS 类型限制，无法在适配器中自动调用 createIndexes
  // 需要在这里手动调用
  ProcessingHistory.createIndexes();
  FruitInfo.createIndexes();
  GradeInfo.createIndexes();
  ExportInfo.createIndexes();
}

