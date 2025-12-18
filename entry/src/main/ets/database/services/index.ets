/**
 * 服务层统一导出
 * 提供所有CRUD接口的统一入口
 */

export { ProcessingHistoryService } from './ProcessingHistoryService';
export { FruitInfoService } from './FruitInfoService';
export { GradeInfoService } from './GradeInfoService';
export { ExportInfoService } from './ExportInfoService';
export { FarmerInfoService } from './FarmerInfoService';
export { ProcessingTaskService } from './ProcessingTaskService';
export { AlarmInfoService } from './AlarmInfoService';

export { createService, createOrmService } from './createService';

// 如果需要使用底层的 DatabaseQueueManager,也可以从这里导出
export { DatabaseQueueManager } from '../../utils/network/database/dispatch/DatabaseQueueManager';
