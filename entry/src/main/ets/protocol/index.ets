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
  HC_WAM_COMMAND_TYPE,
  WAM_HC_COMMAND_TYPE,
  SERVER_HMI_COMMAND_TYPE,
  HMI_ACS_COMMAND_TYPE,
  FaultInfoType,
  FSM_IPM_COMMAND_TYPE,
  IPM_FSM_COMMAND_TYPE,
  BROADCAST_SOURCE_TYPE,
  IQS_FSM_COMMAND_TYPE,
  BROADCAST_COMMAND_TYPE,
  BROADCAST_DATA_TYPE,
  HMI_SIM_COMMAND_TYPE,
  SIM_HMI_COMMAND_TYPE,
  HMI_SCR_COMMAND_TYPE,
  HMI_SIM_PLC_COMMAND_TYPE,
  LANGUAGE_TYPE,
  EXIT_MQ_COMMAND_TYPE,
  HC_DATABASE_COMMAND_TYPE,
  HC_SERVICE_COMMAND_TYPE,
  DATABASE_COMMAND_TYPE,
  RabbitMQCmd,
  MessageTypeEnum,
  getCommandName
} from './CommandTypes'

// 数据结构
export {
  MessageHeader,
  MESSAGE_HEADER_SIZE,
  StStatistics,
  StWeightInfo,
  StWeightResult,
  StWeightStat,
  StTrackingData,
  StWaveInfo,
  StWeightGlobal,
  StGradeInfo,
  StFruitGradeInfo,
  StFruitParam,
  StGlobal,
  StSysConfig,
  StSizeGradeSetting,
  StQualityGradeSetting,
  StExitSetting,
  StMotorInfo,
  StFsmStatus,
  GlobalRealtimeData,
  createDefaultStatistics,
  createDefaultWeightInfo,
  createDefaultGradeInfo,
  createDefaultMotorInfo,
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
