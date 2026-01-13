import { ConstPreDefine } from './ConstPreDefine'

// ==================== 消息头结构 ====================
/**
 * 消息头结构
 * 所有TCP消息的公共头部
 */
export interface MessageHeader {
  /** 消息长度（包括头部） */
  length: number
  /** 源ID */
  srcId: number
  /** 目标ID */
  destId: number
  /** 命令ID */
  cmdId: number
}

/**
 * 消息头大小（字节）
 * length(4) + srcId(2) + destId(2) + cmdId(2) = 10 bytes
 */
export const MESSAGE_HEADER_SIZE: number = 10

// ==================== 统计数据结构 ====================
/**
 * 统计数据结构
 * 对应 FSM_CMD_STATISTICS 命令的数据
 * 包含产量、重量等核心统计信息
 */
export interface StStatistics {
  /** 产量（个） */
  yield: number
  /** 总重（克） */
  totalWeight: number
  /** 合格果数量 */
  qualifiedCount: number
  /** 不合格果数量 */
  unqualifiedCount: number
  /** 大果数量 */
  bigCount: number
  /** 小果数量 */
  smallCount: number
  /** 空杯数量 */
  emptyCount: number
  /** 各等级数量数组 */
  gradeCount: number[]
  /** 各出口数量数组 */
  exitCount: number[]
  /** 各出口重量数组（克） */
  exitWeight: number[]
  /** 通道索引 */
  channelIndex: number
  /** 子系统索引 */
  subsysIndex: number
  /** 时间戳 */
  timestamp: number
}

/**
 * 创建默认统计数据结构
 */
export function createDefaultStatistics(): StStatistics {
  return {
    yield: 0,
    totalWeight: 0,
    qualifiedCount: 0,
    unqualifiedCount: 0,
    bigCount: 0,
    smallCount: 0,
    emptyCount: 0,
    gradeCount: new Array(ConstPreDefine.MAX_SIZE_GRADE_NUM).fill(0),
    exitCount: new Array(ConstPreDefine.MAX_EXIT_NUM).fill(0),
    exitWeight: new Array(ConstPreDefine.MAX_EXIT_NUM).fill(0),
    channelIndex: 0,
    subsysIndex: 0,
    timestamp: 0
  }
}

// ==================== 重量信息结构 ====================
/**
 * 重量信息结构
 * 对应 FSM_CMD_WEIGHTINFO 命令的数据
 */
export interface StWeightInfo {
  /** 当前水果重量（克） */
  weight: number
  /** 水果直径（mm） */
  diameter: number
  /** 水果体积（cm³） */
  volume: number
  /** 水果面积（cm²） */
  area: number
  /** 重量等级 */
  weightGrade: number
  /** 尺寸等级 */
  sizeGrade: number
  /** 品质等级 */
  qualityGrade: number
  /** 最终等级 */
  finalGrade: number
  /** 目标出口 */
  targetExit: number
  /** 水果ID */
  fruitId: number
  /** 通道索引 */
  channelIndex: number
  /** 果杯号 */
  cupIndex: number
  /** 时间戳 */
  timestamp: number
}

/**
 * 创建默认重量信息结构
 */
export function createDefaultWeightInfo(): StWeightInfo {
  return {
    weight: 0,
    diameter: 0,
    volume: 0,
    area: 0,
    weightGrade: 0,
    sizeGrade: 0,
    qualityGrade: 0,
    finalGrade: 0,
    targetExit: 0,
    fruitId: 0,
    channelIndex: 0,
    cupIndex: 0,
    timestamp: 0
  }
}

// ==================== 水果分级信息结构 ====================
/**
 * 水果实时分级信息
 * 对应 FSM_CMD_GRADEINFO 命令的数据
 */
export interface StGradeInfo {
  /** 水果ID */
  fruitId: number
  /** 重量（克） */
  weight: number
  /** 直径（mm） */
  diameter: number
  /** 颜色等级 */
  colorGrade: number
  /** 形状等级 */
  shapeGrade: number
  /** 瑕疵等级 */
  flawGrade: number
  /** 糖度等级 */
  sugarGrade: number
  /** 酸度等级 */
  acidityGrade: number
  /** 密度等级 */
  densityGrade: number
  /** 硬度等级 */
  rigidityGrade: number
  /** 最终品质等级 */
  qualityGrade: number
  /** 最终尺寸等级 */
  sizeGrade: number
  /** 综合等级 */
  finalGrade: number
  /** 目标出口 */
  targetExit: number
  /** 通道索引 */
  channelIndex: number
  /** 果杯号 */
  cupIndex: number
  /** 颜色值 RGB */
  colorR: number
  colorG: number
  colorB: number
  /** 时间戳 */
  timestamp: number
}

/**
 * 创建默认分级信息结构
 */
export function createDefaultGradeInfo(): StGradeInfo {
  return {
    fruitId: 0,
    weight: 0,
    diameter: 0,
    colorGrade: 0,
    shapeGrade: 0,
    flawGrade: 0,
    sugarGrade: 0,
    acidityGrade: 0,
    densityGrade: 0,
    rigidityGrade: 0,
    qualityGrade: 0,
    sizeGrade: 0,
    finalGrade: 0,
    targetExit: 0,
    channelIndex: 0,
    cupIndex: 0,
    colorR: 0,
    colorG: 0,
    colorB: 0,
    timestamp: 0
  }
}

// ==================== 配置信息结构 ====================
/**
 * 系统配置信息
 * 对应 HC_CMD_SYS_CONFIG 命令的数据
 */
export interface StSystemConfig {
  /** 子系统数 */
  subsysNum: number
  /** 每个子系统的IPM数 */
  ipmNum: number[]
  /** 每个IPM的通道数 */
  channelNum: number[][]
  /** 出口数 */
  exitNum: number
  /** 尺寸等级数 */
  sizeGradeNum: number
  /** 品质等级数 */
  qualityGradeNum: number
  /** 版本号 */
  version: number
  /** 称重使能标志 */
  weightEnable: boolean
  /** 图像使能标志 */
  imageEnable: boolean
}

/**
 * 创建默认系统配置
 */
export function createDefaultSystemConfig(): StSystemConfig {
  // 创建二维数组
  const channelNumArray: number[][] = []
  for (let i = 0; i < ConstPreDefine.MAX_SUBSYS_NUM; i++) {
    const row: number[] = new Array<number>(ConstPreDefine.MAX_IPM_NUM).fill(2)
    channelNumArray.push(row)
  }

  return {
    subsysNum: 1,
    ipmNum: new Array<number>(ConstPreDefine.MAX_SUBSYS_NUM).fill(1),
    channelNum: channelNumArray,
    exitNum: 48,
    sizeGradeNum: 8,
    qualityGradeNum: 4,
    version: ConstPreDefine.VERSION,
    weightEnable: true,
    imageEnable: true
  }
}

// ==================== 等级设置结构 ====================
/**
 * 尺寸等级设置
 */
export interface StSizeGradeSetting {
  /** 等级索引 */
  gradeIndex: number
  /** 等级名称 */
  gradeName: string
  /** 重量下限（克） */
  weightMin: number
  /** 重量上限（克） */
  weightMax: number
  /** 直径下限（mm） */
  diameterMin: number
  /** 直径上限（mm） */
  diameterMax: number
  /** 启用标志 */
  enabled: boolean
}

/**
 * 品质等级设置
 */
export interface StQualityGradeSetting {
  /** 等级索引 */
  gradeIndex: number
  /** 等级名称 */
  gradeName: string
  /** 颜色等级范围 */
  colorGradeMin: number
  colorGradeMax: number
  /** 形状等级范围 */
  shapeGradeMin: number
  shapeGradeMax: number
  /** 瑕疵等级范围 */
  flawGradeMin: number
  flawGradeMax: number
  /** 启用标志 */
  enabled: boolean
}

// ==================== 出口设置结构 ====================
/**
 * 出口设置
 */
export interface StExitSetting {
  /** 出口索引 */
  exitIndex: number
  /** 出口名称 */
  exitName: string
  /** 显示名称 */
  displayName: string
  /** 目标尺寸等级 */
  targetSizeGrade: number
  /** 目标品质等级 */
  targetQualityGrade: number
  /** 装箱量（个） */
  boxCapacity: number
  /** 启用标志 */
  enabled: boolean
  /** 当前装箱数量 */
  currentCount: number
  /** 当前装箱重量 */
  currentWeight: number
}

// ==================== 通道设置结构 ====================
/**
 * 通道设置
 */
export interface StChannelSetting {
  /** 通道索引 */
  channelIndex: number
  /** 通道名称 */
  channelName: string
  /** 子系统索引 */
  subsysIndex: number
  /** IPM索引 */
  ipmIndex: number
  /** 启用标志 */
  enabled: boolean
  /** 称重启用 */
  weightEnabled: boolean
  /** 图像启用 */
  imageEnabled: boolean
}

// ==================== 设备状态结构 ====================
/**
 * FSM设备状态
 */
export interface StFsmStatus {
  /** 设备ID */
  deviceId: number
  /** IP地址 */
  ipAddress: string
  /** 在线状态 */
  online: boolean
  /** 版本号 */
  version: string
  /** 连接时间 */
  connectTime: number
  /** 最后心跳时间 */
  lastHeartbeat: number
  /** 子系统索引 */
  subsysIndex: number
}

/**
 * IPM设备状态
 */
export interface StIpmStatus {
  /** 设备ID */
  deviceId: number
  /** IP地址 */
  ipAddress: string
  /** 在线状态 */
  online: boolean
  /** 版本号 */
  version: string
  /** 子系统索引 */
  subsysIndex: number
  /** IPM索引 */
  ipmIndex: number
  /** 相机数量 */
  cameraNum: number
}

// ==================== 波形数据结构 ====================
/**
 * 波形数据
 * 用于称重波形显示
 */
export interface StWaveData {
  /** 通道索引 */
  channelIndex: number
  /** 波形点数据 */
  points: number[]
  /** 采样率 */
  sampleRate: number
  /** 时间戳 */
  timestamp: number
}

// ==================== 全局实时数据 ====================
/**
 * 全局实时数据
 * 汇总所有通道的统计信息
 */
export interface GlobalRealtimeData {
  /** 总产量 */
  totalYield: number
  /** 总重量（克） */
  totalWeight: number
  /** 总合格数 */
  totalQualified: number
  /** 总不合格数 */
  totalUnqualified: number
  /** 各等级汇总数量 */
  gradeCount: number[]
  /** 各出口汇总数量 */
  exitCount: number[]
  /** 各出口汇总重量 */
  exitWeight: number[]
  /** 各通道产量 */
  channelYield: number[]
  /** 效率（个/分钟） */
  efficiency: number
  /** 开始时间 */
  startTime: number
  /** 运行时长（秒） */
  runningTime: number
}

/**
 * 创建默认全局实时数据
 */
export function createDefaultGlobalRealtimeData(): GlobalRealtimeData {
  return {
    totalYield: 0,
    totalWeight: 0,
    totalQualified: 0,
    totalUnqualified: 0,
    gradeCount: new Array<number>(ConstPreDefine.MAX_SIZE_GRADE_NUM).fill(0),
    exitCount: new Array<number>(ConstPreDefine.MAX_EXIT_NUM).fill(0),
    exitWeight: new Array<number>(ConstPreDefine.MAX_EXIT_NUM).fill(0),
    channelYield: new Array<number>(ConstPreDefine.MAX_CHANNEL_NUM).fill(0),
    efficiency: 0,
    startTime: 0,
    runningTime: 0
  }
}

// ==================== 复制函数 ====================
/**
 * 复制 GlobalRealtimeData
 */
export function copyGlobalRealtimeData(src: GlobalRealtimeData): GlobalRealtimeData {
  return {
    totalYield: src.totalYield,
    totalWeight: src.totalWeight,
    totalQualified: src.totalQualified,
    totalUnqualified: src.totalUnqualified,
    gradeCount: src.gradeCount.slice(),
    exitCount: src.exitCount.slice(),
    exitWeight: src.exitWeight.slice(),
    channelYield: src.channelYield.slice(),
    efficiency: src.efficiency,
    startTime: src.startTime,
    runningTime: src.runningTime
  }
}

/**
 * 复制 StStatistics
 */
export function copyStStatistics(src: StStatistics): StStatistics {
  return {
    yield: src.yield,
    totalWeight: src.totalWeight,
    qualifiedCount: src.qualifiedCount,
    unqualifiedCount: src.unqualifiedCount,
    bigCount: src.bigCount,
    smallCount: src.smallCount,
    emptyCount: src.emptyCount,
    gradeCount: src.gradeCount.slice(),
    exitCount: src.exitCount.slice(),
    exitWeight: src.exitWeight.slice(),
    channelIndex: src.channelIndex,
    subsysIndex: src.subsysIndex,
    timestamp: src.timestamp
  }
}

/**
 * 复制 StWeightInfo
 */
export function copyStWeightInfo(src: StWeightInfo): StWeightInfo {
  return {
    weight: src.weight,
    diameter: src.diameter,
    volume: src.volume,
    area: src.area,
    weightGrade: src.weightGrade,
    sizeGrade: src.sizeGrade,
    qualityGrade: src.qualityGrade,
    finalGrade: src.finalGrade,
    targetExit: src.targetExit,
    fruitId: src.fruitId,
    channelIndex: src.channelIndex,
    cupIndex: src.cupIndex,
    timestamp: src.timestamp
  }
}

/**
 * 复制 StGradeInfo
 */
export function copyStGradeInfo(src: StGradeInfo): StGradeInfo {
  return {
    fruitId: src.fruitId,
    weight: src.weight,
    diameter: src.diameter,
    colorGrade: src.colorGrade,
    shapeGrade: src.shapeGrade,
    flawGrade: src.flawGrade,
    sugarGrade: src.sugarGrade,
    acidityGrade: src.acidityGrade,
    densityGrade: src.densityGrade,
    rigidityGrade: src.rigidityGrade,
    qualityGrade: src.qualityGrade,
    sizeGrade: src.sizeGrade,
    finalGrade: src.finalGrade,
    targetExit: src.targetExit,
    channelIndex: src.channelIndex,
    cupIndex: src.cupIndex,
    colorR: src.colorR,
    colorG: src.colorG,
    colorB: src.colorB,
    timestamp: src.timestamp
  }
}

/**
 * 复制 StFsmStatus
 */
export function copyStFsmStatus(src: StFsmStatus): StFsmStatus {
  return {
    deviceId: src.deviceId,
    ipAddress: src.ipAddress,
    online: src.online,
    version: src.version,
    connectTime: src.connectTime,
    lastHeartbeat: src.lastHeartbeat,
    subsysIndex: src.subsysIndex
  }
}

/**
 * 复制 StGradeInfo 数组
 */
export function copyStGradeInfoArray(src: StGradeInfo[]): StGradeInfo[] {
  const result: StGradeInfo[] = []
  for (const item of src) {
    result.push(copyStGradeInfo(item))
  }
  return result
}
