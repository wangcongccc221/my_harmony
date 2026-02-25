/**
 * 全局数据接口
 * 对应48项目的 DataInterface 类
 * 管理全局的实时数据和状态
 */

import { ConstPreDefine } from './ConstPreDefine'
import {
  StStatistics,
  StWeightInfo,
  StGradeInfo,
  StFruitGradeInfo,
  StFruitGradeRealtime,
  StFsmStatus,
  StSysConfig,
  GlobalRealtimeData,
  createDefaultStatistics,
  createDefaultGlobalRealtimeData,
  copyGlobalRealtimeData,
  copyStStatistics,
  copyStWeightInfo,
  copyStGradeInfo,
  copyStFsmStatus,
  GradeItem
} from './Structures'
import { hilog } from '@kit.PerformanceAnalysisKit'

const TAG = 'GlobalDataInterface'

/**
 * 数据变化监听器类型
 */
export type DataChangeListener = (data: GlobalRealtimeData) => void
export type StatisticsListener = (data: StStatistics) => void
export type WeightInfoListener = (data: StWeightInfo) => void
export type GradeInfoListener = (data: StGradeInfo) => void
export type FruitGradeListener = (data: StFruitGradeRealtime) => void
export type DeviceStatusListener = (devices: Map<number, StFsmStatus>) => void
export type SysConfigListener = (config: StSysConfig) => void

/**
 * 全局数据接口类
 * 管理所有实时数据、设备状态，并提供事件通知
 */
export class GlobalDataInterface {
  private static instance: GlobalDataInterface | null = null

  // ==================== 实时数据 ====================
  /** 全局实时汇总数据 */
  private globalData: GlobalRealtimeData = createDefaultGlobalRealtimeData()

  /** 各通道统计数据 */
  private channelStatistics: Map<number, StStatistics> = new Map()

  /** 最新的重量信息 */
  private latestWeightInfo: StWeightInfo | null = null

  /** 最新的分级信息 */
  private latestGradeInfo: StGradeInfo | null = null

  /** 最近的水果信息队列（用于实时显示） */
  private recentFruits: StFruitGradeRealtime[] = []
  private readonly MAX_RECENT_FRUITS: number = 100

  private latestFruitGradeByChannel: Map<number, StFruitGradeRealtime> = new Map()

  // ==================== 设备状态 ====================
  /** FSM设备状态 */
  private fsmDevices: Map<number, StFsmStatus> = new Map()

  // ==================== 系统配置 ====================
  private latestSysConfig: StSysConfig | null = null

  // ==================== 监听器 ====================
  private dataChangeListeners: Set<DataChangeListener> = new Set()
  private statisticsListeners: Set<StatisticsListener> = new Set()
  private weightInfoListeners: Set<WeightInfoListener> = new Set()
  private gradeInfoListeners: Set<GradeInfoListener> = new Set()
  private fruitGradeListeners: Set<FruitGradeListener> = new Set()
  private deviceStatusListeners: Set<DeviceStatusListener> = new Set()
  private sysConfigListeners: Set<SysConfigListener> = new Set()

  // ==================== 时间统计 ====================
  private startTime: number = 0
  private isProcessing: boolean = false

  /**
   * 获取单例实例
   */
  static getInstance(): GlobalDataInterface {
    if (!GlobalDataInterface.instance) {
      GlobalDataInterface.instance = new GlobalDataInterface()
    }
    return GlobalDataInterface.instance
  }

  private constructor() {
    hilog.info(0x0001, TAG, '全局数据接口初始化')
  }

  // ==================== 数据更新方法 ====================
  /**
   * 更新统计数据
   * @param stats 新的统计数据
   */
  updateStatistics(stats: StStatistics): void {
    console.log(`[全局更新] 收到统计: subsys=${stats.nSubsysId} channel=${stats.nChannelIndex} yield=${stats.nYield} totalWeight=${stats.nTotalWeight}`)
    // 计算通道键
    const channelKey: number = this.getChannelKey(stats.nSubsysId, stats.nChannelIndex)

    // 获取旧数据用于计算增量
    const oldStats: StStatistics | undefined = this.channelStatistics.get(channelKey)

    // 更新通道数据
    this.channelStatistics.set(channelKey, stats)

    // 更新全局汇总
    this.updateGlobalData(stats, oldStats)

    // 如果还没有开始时间，自动设置为开始加工
    if (this.globalData.startTime === 0 && stats.nYield > 0) {
      this.startProcessing()
    }

    // 通知监听器
    this.notifyStatisticsListeners(stats)
    this.notifyDataChangeListeners()

    hilog.info(0x0001, TAG,
      `统计数据更新: 通道${stats.nChannelIndex}, 产量=${stats.nYield}, 总重=${stats.nTotalWeight}g`)
  }

  /**
   * 更新重量信息
   * @param info 新的重量信息
   */
  updateWeightInfo(info: StWeightInfo): void {
    this.latestWeightInfo = info

    // 通知监听器
    this.notifyWeightInfoListeners(info)

    hilog.debug(0x0001, TAG,
      `重量信息更新: 重量=${info.weight}g, 等级=${info.finalGrade}, 出口=${info.targetExit}`)
  }

  /**
   * 更新分级信息
   * @param info 新的分级信息
   */
  updateGradeInfo(info: StGradeInfo): void {
    const safeInfo = copyStGradeInfo(info)
    this.latestGradeInfo = safeInfo

    const item = new StFruitGradeRealtime()
    item.channelIndex = safeInfo.channelIndex
    item.timestamp = safeInfo.timestamp
    item.grade = safeInfo.finalGrade
    item.targetExit = safeInfo.targetExit
    item.weightG = safeInfo.weight
    item.densityKgPerM3 = safeInfo.densityGrade
    item.brix = safeInfo.sugarGrade
    item.acidity = safeInfo.acidityGrade
    item.diameterMm = safeInfo.diameter
    this.latestFruitGradeByChannel.set(item.channelIndex, item)

    this.recentFruits.unshift(item)
    if (this.recentFruits.length > this.MAX_RECENT_FRUITS) {
      this.recentFruits.pop()
    }

    // 通知监听器
    this.notifyGradeInfoListeners(safeInfo)
    this.notifyFruitGradeListeners(item)

    hilog.debug(0x0001, TAG,
      `分级信息更新: ID=${safeInfo.fruitId}, 重量=${safeInfo.weight}g, 等级=${safeInfo.finalGrade}`)
  }

  updateFruitGradeInfo(srcId: number, info: StFruitGradeInfo): void {
    const ipmIdxRaw = (srcId >> 4) & 0x0F
    const ipmIndex0 = ipmIdxRaw > 0 ? (ipmIdxRaw - 1) : 0
    const baseChannelIndex = ipmIndex0 * ConstPreDefine.CHANNEL_NUM
    const now = Date.now()

    for (let i = 0; i < info.params.length; i++) {
      const param = info.params[i]
      const hasAny =
        param.fWeight !== 0 ||
        param.fDensity !== 0 ||
        param.unGrade !== 0 ||
        param.visionParam.unArea !== 0 ||
        param.visionParam.unVolume !== 0 ||
        param.visionParam.unFlawArea !== 0 ||
        param.visionParam.unFlawNum !== 0 ||
        param.uvParam.unBruiseArea !== 0 ||
        param.uvParam.unRotArea !== 0 ||
        param.nirParam.fSugar !== 0 ||
        param.nirParam.fAcidity !== 0
      if (!hasAny) {
        continue
      }
      const item = new StFruitGradeRealtime()
      item.channelIndex = baseChannelIndex + i
      item.timestamp = now
      item.routeId = info.nRouteId
      item.grade = param.unGrade
      item.targetExit = param.unWhichExit
      item.weightG = param.fWeight
      item.densityKgPerM3 = param.fDensity
      item.colorRate0Pct = param.visionParam.unColorRate0 / 2
      item.colorRate1Pct = param.visionParam.unColorRate1 / 2
      item.colorRate2Pct = param.visionParam.unColorRate2 / 2
      item.projectionAreaMm2 = param.visionParam.unArea
      item.volumeMm3 = param.visionParam.unVolume
      item.visionFlawAreaMm2 = param.visionParam.unFlawArea
      item.visionFlawCount = param.visionParam.unFlawNum
      item.uvDefectAreaMm2 = param.uvParam.unBruiseArea + param.uvParam.unRotArea
      item.uvDefectCount = param.uvParam.unBruiseNum + param.uvParam.unRotNum
      item.uvRigidity = param.uvParam.unRigidity
      item.uvWater = param.uvParam.unWater
      item.brix = param.nirParam.fSugar
      item.acidity = param.nirParam.fAcidity
      item.pulpColor = param.nirParam.fBrown
      item.maturity = param.nirParam.fTangxin
      item.diameterMm = param.visionParam.unSelectBasis
      item.diameterRatio = param.visionParam.fDiameterRatio
      item.minDiameterRatio = param.visionParam.fMinDRatio

      this.latestFruitGradeByChannel.set(item.channelIndex, item)

      this.recentFruits.unshift(item)
      if (this.recentFruits.length > this.MAX_RECENT_FRUITS) {
        this.recentFruits.pop()
      }

      this.notifyFruitGradeListeners(item)
    }
  }

  /**
   * 更新设备状态
   * @param deviceId 设备ID
   * @param status 设备状态
   */
  updateDeviceStatus(deviceId: number, status: StFsmStatus): void {
    this.fsmDevices.set(deviceId, status)
    this.notifyDeviceStatusListeners()

    hilog.info(0x0001, TAG,
      `设备状态更新: ID=0x${deviceId.toString(16)}, 在线=${status.online}`)
  }

  updateSysConfig(config: StSysConfig): void {
    this.latestSysConfig = config
    this.notifySysConfigListeners(config)
  }

  // ==================== 全局数据汇总 ====================
  /**
   * 更新全局汇总数据
   */
  private updateGlobalData(newStats: StStatistics, oldStats: StStatistics | undefined): void {
    // 简化策略：直接用最新数据覆盖（适用于单通道场景，或假设通道数据独立）
    // 如果是多通道，应该根据 subsys/channel 累加
    // 这里为了修复 UI 显示，我们暂时直接累加通道数据，但需要避免重复累加
    
    // 方案 B: 重新计算所有通道的总和
    let totalYield: number = 0
    let totalWeight: number = 0
    let totalQualified: number = 0
    let totalUnqualified: number = 0
    let totalSpeed: number = 0 // 累加所有通道的瞬时速度

    const gradeCount: number[] = new Array(ConstPreDefine.MAX_QUALITY_GRADE_NUM * ConstPreDefine.MAX_SIZE_GRADE_NUM).fill(0)
    const gradeWeight: number[] = new Array(ConstPreDefine.MAX_QUALITY_GRADE_NUM * ConstPreDefine.MAX_SIZE_GRADE_NUM).fill(0)
    const boxGradeCount: number[] = new Array(ConstPreDefine.MAX_QUALITY_GRADE_NUM * ConstPreDefine.MAX_SIZE_GRADE_NUM).fill(0)
    const exitCount: number[] = new Array(ConstPreDefine.MAX_EXIT_NUM).fill(0)
    const exitWeight: number[] = new Array(ConstPreDefine.MAX_EXIT_NUM).fill(0)

    const hasAnyValue = (arr: ArrayLike<number>): boolean => {
      for (let i = 0; i < arr.length; i++) {
        if (arr[i] > 0) {
          return true
        }
      }
      return false
    }

    this.channelStatistics.forEach((stats: StStatistics) => {
      totalYield += stats.nYield
      totalWeight += stats.nTotalWeight
      totalQualified += stats.nQualifiedCount
      totalUnqualified += stats.nUnqualifiedCount
      totalSpeed += stats.nIntervalSumperminute // 累加瞬时速度

      for (let i = 0; i < stats.nGradeCount.length; i++) {
        gradeCount[i] += stats.nGradeCount[i]
        gradeWeight[i] += stats.nWeightGradeCount[i]
      }
      const exitCountSource = hasAnyValue(stats.nExitCount) ? stats.nExitCount : stats.ExitBoxNum
      const exitWeightSource = hasAnyValue(stats.nExitWeightCount) ? stats.nExitWeightCount : stats.ExitWeight
      const maxExit = Math.min(exitCountSource.length, exitWeightSource.length, exitCount.length)
      for (let i = 0; i < maxExit; i++) {
        exitCount[i] += Number(exitCountSource[i] ?? 0)
        exitWeight[i] += Number(exitWeightSource[i] ?? 0)
      }
    })

    // 更新全局对象
    this.globalData.totalYield = totalYield
    this.globalData.totalWeight = totalWeight
    this.globalData.totalQualified = totalQualified
    this.globalData.totalUnqualified = totalUnqualified
    this.globalData.gradeCount = gradeCount
    this.globalData.gradeWeight = gradeWeight
    this.globalData.boxGradeCount = boxGradeCount
    this.globalData.exitCount = exitCount
    this.globalData.exitWeight = exitWeight

    // 更新通道产量 (仅当前通道)
    const channelIdx: number = newStats.nChannelIndex
    if (channelIdx >= 0 && channelIdx < this.globalData.channelYield.length) {
      this.globalData.channelYield[channelIdx] = newStats.nYield
    }

    // 更新效率
    // 如果下位机上报了有效的瞬时速度，直接使用（优先）
    if (totalSpeed > 0) {
        // 更新运行时间（仅用于显示，不参与效率计算）
        if (this.startTime > 0) {
            this.globalData.runningTime = (Date.now() - this.startTime) / 1000
        }
        this.globalData.efficiency = totalSpeed
    } else {
        // 否则使用时间倒推（兼容旧设备或模拟器未设置速度的情况）
        this.updateEfficiency()
    }
  }

  /**
   * 更新效率统计
   */
  private updateEfficiency(): void {
    if (this.startTime > 0) {
      const runningTime = (Date.now() - this.startTime) / 1000 // 秒
      this.globalData.runningTime = runningTime

      if (runningTime > 0) {
        this.globalData.efficiency = (this.globalData.totalYield / runningTime) * 60 // 个/分钟
      }
    }
  }

  // ==================== 控制方法 ====================
  /**
   * 开始加工
   */
  startProcessing(): void {
    this.startTime = Date.now()
    this.isProcessing = true
    this.globalData.startTime = this.startTime

    hilog.info(0x0001, TAG, '开始加工')
  }

  /**
   * 停止加工
   */
  stopProcessing(): void {
    this.isProcessing = false
    this.updateEfficiency()

    hilog.info(0x0001, TAG, `停止加工, 运行时长=${this.globalData.runningTime}秒`)
  }

  /**
   * 清零数据
   */
  clearData(): void {
    this.globalData = createDefaultGlobalRealtimeData()
    this.channelStatistics.clear()
    this.latestWeightInfo = null
    this.latestGradeInfo = null
    this.recentFruits = []
    this.startTime = 0
    this.isProcessing = false

    this.notifyDataChangeListeners()

    hilog.info(0x0001, TAG, '数据已清零')
  }

  // ==================== 获取数据方法 ====================
  /**
   * 获取全局实时数据
   */
  getGlobalData(): GlobalRealtimeData {
    return copyGlobalRealtimeData(this.globalData)
  }

  /**
   * 获取指定通道的统计数据
   */
  getChannelStatistics(subsysIndex: number, channelIndex: number): StStatistics | null {
    const key = this.getChannelKey(subsysIndex, channelIndex)
    const stats = this.channelStatistics.get(key)
    return stats ? copyStStatistics(stats) : null
  }

  /**
   * 获取所有通道统计数据
   */
  getAllChannelStatistics(): Map<number, StStatistics> {
    return new Map(this.channelStatistics)
  }

  /**
   * 获取最新的重量信息
   */
  getLatestWeightInfo(): StWeightInfo | null {
    return this.latestWeightInfo ? copyStWeightInfo(this.latestWeightInfo) : null
  }

  /**
   * 获取最新的分级信息
   */
  getLatestGradeInfo(): StGradeInfo | null {
    return this.latestGradeInfo ? copyStGradeInfo(this.latestGradeInfo) : null
  }

  /**
   * 获取最近的水果信息列表
   */
  getRecentFruits(): StFruitGradeRealtime[] {
    return this.recentFruits.slice()
  }

  getLatestFruitGrade(channelIndex: number): StFruitGradeRealtime | null {
    return this.latestFruitGradeByChannel.get(channelIndex) ?? null
  }

  getSysConfig(): StSysConfig | null {
    return this.latestSysConfig
  }

  /**
   * 获取设备状态
   */
  getDeviceStatus(deviceId: number): StFsmStatus | null {
    const status = this.fsmDevices.get(deviceId)
    return status ? copyStFsmStatus(status) : null
  }

  /**
   * 获取所有设备状态
   */
  getAllDeviceStatus(): Map<number, StFsmStatus> {
    return new Map(this.fsmDevices)
  }

  /**
   * 获取在线设备数量
   */
  getOnlineDeviceCount(): number {
    let count = 0
    this.fsmDevices.forEach((status) => {
      if (status.online) count++
    })
    return count
  }

  /**
   * 是否正在加工
   */
  isCurrentlyProcessing(): boolean {
    return this.isProcessing
  }

  // ==================== 监听器管理 ====================
  /**
   * 添加全局数据变化监听器
   */
  addDataChangeListener(listener: DataChangeListener): void {
    this.dataChangeListeners.add(listener)
  }

  /**
   * 移除全局数据变化监听器
   */
  removeDataChangeListener(listener: DataChangeListener): void {
    this.dataChangeListeners.delete(listener)
  }

  /**
   * 添加统计数据监听器
   */
  addStatisticsListener(listener: StatisticsListener): void {
    this.statisticsListeners.add(listener)
  }

  /**
   * 移除统计数据监听器
   */
  removeStatisticsListener(listener: StatisticsListener): void {
    this.statisticsListeners.delete(listener)
  }

  /**
   * 添加重量信息监听器
   */
  addWeightInfoListener(listener: WeightInfoListener): void {
    this.weightInfoListeners.add(listener)
  }

  /**
   * 移除重量信息监听器
   */
  removeWeightInfoListener(listener: WeightInfoListener): void {
    this.weightInfoListeners.delete(listener)
  }

  /**
   * 添加分级信息监听器
   */
  addGradeInfoListener(listener: GradeInfoListener): void {
    this.gradeInfoListeners.add(listener)
  }

  /**
   * 移除分级信息监听器
   */
  removeGradeInfoListener(listener: GradeInfoListener): void {
    this.gradeInfoListeners.delete(listener)
  }

  addFruitGradeListener(listener: FruitGradeListener): void {
    this.fruitGradeListeners.add(listener)
  }

  removeFruitGradeListener(listener: FruitGradeListener): void {
    this.fruitGradeListeners.delete(listener)
  }

  /**
   * 添加设备状态监听器
   */
  addDeviceStatusListener(listener: DeviceStatusListener): void {
    this.deviceStatusListeners.add(listener)
  }

  /**
   * 移除设备状态监听器
   */
  removeDeviceStatusListener(listener: DeviceStatusListener): void {
    this.deviceStatusListeners.delete(listener)
  }

  addSysConfigListener(listener: SysConfigListener): void {
    this.sysConfigListeners.add(listener)
  }

  removeSysConfigListener(listener: SysConfigListener): void {
    this.sysConfigListeners.delete(listener)
  }

  // ==================== 通知监听器 ====================
  private notifyDataChangeListeners(): void {
    const data = this.getGlobalData()
    console.log(`[全局通知] totalYield=${data.totalYield} totalWeight=${data.totalWeight} efficiency=${data.efficiency} runningTime=${data.runningTime}`)
    this.dataChangeListeners.forEach(listener => {
      try {
        listener(data)
      } catch (e) {
        hilog.error(0x0001, TAG, `数据变化监听器错误: ${e}`)
      }
    })
  }

  private notifyStatisticsListeners(stats: StStatistics): void {
    this.statisticsListeners.forEach(listener => {
      try {
        listener(stats)
      } catch (e) {
        hilog.error(0x0001, TAG, `统计数据监听器错误: ${e}`)
      }
    })
  }

  private notifyWeightInfoListeners(info: StWeightInfo): void {
    this.weightInfoListeners.forEach(listener => {
      try {
        listener(info)
      } catch (e) {
        hilog.error(0x0001, TAG, `重量信息监听器错误: ${e}`)
      }
    })
  }

  private notifyGradeInfoListeners(info: StGradeInfo): void {
    this.gradeInfoListeners.forEach(listener => {
      try {
        listener(info)
      } catch (e) {
        hilog.error(0x0001, TAG, `分级信息监听器错误: ${e}`)
      }
    })
  }

  private notifyFruitGradeListeners(info: StFruitGradeRealtime): void {
    this.fruitGradeListeners.forEach(listener => {
      try {
        listener(info)
      } catch (e) {
        hilog.error(0x0001, TAG, `水果分级监听器错误: ${e}`)
      }
    })
  }

  private notifyDeviceStatusListeners(): void {
    const devices = this.getAllDeviceStatus()
    this.deviceStatusListeners.forEach(listener => {
      try {
        listener(devices)
      } catch (e) {
        hilog.error(0x0001, TAG, `设备状态监听器错误: ${e}`)
      }
    })
  }

  private notifySysConfigListeners(config: StSysConfig): void {
    this.sysConfigListeners.forEach(listener => {
      try {
        listener(config)
      } catch (_e) {}
    })
  }

  // ==================== 辅助方法 ====================
  /**
   * 生成通道键
   */
  private getChannelKey(subsysIndex: number, channelIndex: number): number {
    return (subsysIndex << 8) | channelIndex
  }

  /**
   * 格式化重量显示（克 -> 千克）
   */
  static formatWeight(weightGram: number): string {
    if (weightGram >= 1000) {
      return (weightGram / 1000).toFixed(2) + ' kg'
    }
    return weightGram.toFixed(0) + ' g'
  }

  /**
   * 格式化效率显示
   */
  static formatEfficiency(efficiency: number): string {
    return efficiency.toFixed(1) + ' 个/分'
  }
}

// 导出单例获取方法
export function getGlobalDataInterface(): GlobalDataInterface {
  return GlobalDataInterface.getInstance()
}
