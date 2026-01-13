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
  StFsmStatus,
  GlobalRealtimeData,
  createDefaultStatistics,
  createDefaultGlobalRealtimeData,
  copyGlobalRealtimeData,
  copyStStatistics,
  copyStWeightInfo,
  copyStGradeInfo,
  copyStFsmStatus,
  copyStGradeInfoArray
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
export type DeviceStatusListener = (devices: Map<number, StFsmStatus>) => void

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
  private recentFruits: StGradeInfo[] = []
  private readonly MAX_RECENT_FRUITS: number = 100

  // ==================== 设备状态 ====================
  /** FSM设备状态 */
  private fsmDevices: Map<number, StFsmStatus> = new Map()

  // ==================== 监听器 ====================
  private dataChangeListeners: Set<DataChangeListener> = new Set()
  private statisticsListeners: Set<StatisticsListener> = new Set()
  private weightInfoListeners: Set<WeightInfoListener> = new Set()
  private gradeInfoListeners: Set<GradeInfoListener> = new Set()
  private deviceStatusListeners: Set<DeviceStatusListener> = new Set()

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
    // 计算通道键
    const channelKey = this.getChannelKey(stats.subsysIndex, stats.channelIndex)

    // 获取旧数据用于计算增量
    const oldStats = this.channelStatistics.get(channelKey)

    // 更新通道数据
    this.channelStatistics.set(channelKey, stats)

    // 更新全局汇总
    this.updateGlobalData(stats, oldStats)

    // 通知监听器
    this.notifyStatisticsListeners(stats)
    this.notifyDataChangeListeners()

    hilog.info(0x0001, TAG,
      `统计数据更新: 通道${stats.channelIndex}, 产量=${stats.yield}, 总重=${stats.totalWeight}g`)
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
    this.latestGradeInfo = info

    // 添加到最近水果队列
    this.recentFruits.unshift(info)
    if (this.recentFruits.length > this.MAX_RECENT_FRUITS) {
      this.recentFruits.pop()
    }

    // 通知监听器
    this.notifyGradeInfoListeners(info)

    hilog.debug(0x0001, TAG,
      `分级信息更新: ID=${info.fruitId}, 重量=${info.weight}g, 等级=${info.finalGrade}`)
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

  // ==================== 全局数据汇总 ====================
  /**
   * 更新全局汇总数据
   */
  private updateGlobalData(newStats: StStatistics, oldStats: StStatistics | undefined): void {
    // 如果有旧数据，先减去旧值
    if (oldStats) {
      this.globalData.totalYield -= oldStats.yield
      this.globalData.totalWeight -= oldStats.totalWeight
      this.globalData.totalQualified -= oldStats.qualifiedCount
      this.globalData.totalUnqualified -= oldStats.unqualifiedCount

      for (let i = 0; i < oldStats.gradeCount.length; i++) {
        this.globalData.gradeCount[i] -= oldStats.gradeCount[i]
      }
      for (let i = 0; i < oldStats.exitCount.length; i++) {
        this.globalData.exitCount[i] -= oldStats.exitCount[i]
        this.globalData.exitWeight[i] -= oldStats.exitWeight[i]
      }
    }

    // 加上新值
    this.globalData.totalYield += newStats.yield
    this.globalData.totalWeight += newStats.totalWeight
    this.globalData.totalQualified += newStats.qualifiedCount
    this.globalData.totalUnqualified += newStats.unqualifiedCount

    for (let i = 0; i < newStats.gradeCount.length; i++) {
      this.globalData.gradeCount[i] += newStats.gradeCount[i]
    }
    for (let i = 0; i < newStats.exitCount.length; i++) {
      this.globalData.exitCount[i] += newStats.exitCount[i]
      this.globalData.exitWeight[i] += newStats.exitWeight[i]
    }

    // 更新通道产量
    const channelIdx = newStats.channelIndex
    if (channelIdx >= 0 && channelIdx < this.globalData.channelYield.length) {
      this.globalData.channelYield[channelIdx] = newStats.yield
    }

    // 更新效率
    this.updateEfficiency()
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
  getRecentFruits(): StGradeInfo[] {
    return copyStGradeInfoArray(this.recentFruits)
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

  // ==================== 通知监听器 ====================
  private notifyDataChangeListeners(): void {
    const data = this.getGlobalData()
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
