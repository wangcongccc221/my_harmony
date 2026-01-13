/**
 * 协议层统一导出
 * 复刻48项目的通信协议实现
 */

// 常量定义
export { ConstPreDefine } from './ConstPreDefine'

// 命令类型
export {
  HC_FSM_COMMAND_TYPE,
  FSM_HC_COMMAND_TYPE,
  HC_IPM_COMMAND_TYPE,
  IPM_HC_COMMAND_TYPE,
  FSM_IPM_COMMAND_TYPE,
  HC_DATABASE_COMMAND_TYPE,
  HC_SERVICE_COMMAND_TYPE,
  getCommandName
} from './CommandTypes'

// 数据结构
export {
  MessageHeader,
  MESSAGE_HEADER_SIZE,
  StStatistics,
  StWeightInfo,
  StGradeInfo,
  StSystemConfig,
  StSizeGradeSetting,
  StQualityGradeSetting,
  StExitSetting,
  StChannelSetting,
  StFsmStatus,
  StIpmStatus,
  StWaveData,
  GlobalRealtimeData,
  createDefaultStatistics,
  createDefaultWeightInfo,
  createDefaultGradeInfo,
  createDefaultSystemConfig,
  createDefaultGlobalRealtimeData,
  copyGlobalRealtimeData,
  copyStStatistics,
  copyStWeightInfo,
  copyStGradeInfo,
  copyStFsmStatus,
  copyStGradeInfoArray
} from './Structures'

// 协议解析器
export {
  ProtocolParser,
  ParsedMessage,
  getProtocolParser
} from './ProtocolParser'

// 全局数据接口
export {
  GlobalDataInterface,
  DataChangeListener,
  StatisticsListener,
  WeightInfoListener,
  GradeInfoListener,
  DeviceStatusListener,
  getGlobalDataInterface
} from './GlobalDataInterface'

// 统计数据处理器
export {
  StatisticsHandler,
  getStatisticsHandler
} from './StatisticsHandler'

// 配置发送器
export {
  ConfigSender,
  ITcpSender,
  getConfigSender
} from './ConfigSender'

// 数据库同步
export {
  DatabaseSync,
  IDatabaseSaver,
  getDatabaseSync
} from './DatabaseSync'

// UI数据同步
export {
  UIDataSync,
  getUIDataSync
} from './UIDataSync'
