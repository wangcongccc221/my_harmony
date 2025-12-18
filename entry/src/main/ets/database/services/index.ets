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

// 新增的服务（对应48项目）
export { CustomerService } from './CustomerService';
export { SysFruitInfoService } from './SysFruitInfoService';
export { BaseFaultService } from './BaseFaultService';
export { FaultInfoService } from './FaultInfoService';
export { FruitProcessInfoService } from './FruitProcessInfoService';
export { SysConfigsService } from './SysConfigsService';

export { createService, createOrmService } from './createService';

// 如果需要使用底层的 DatabaseQueueManager,也可以从这里导出
export { DatabaseQueueManager } from '../../utils/network/database/dispatch/DatabaseQueueManager';
