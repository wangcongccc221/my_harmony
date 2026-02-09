/**
 * UI 数据同步服务
 * 将协议层的实时数据同步到 UI 组件使用的 AppStorage
 * 替换模拟数据为真实的下位机数据
 */

import {
  GlobalDataInterface,
  getGlobalDataInterface,
  DataChangeListener,
  StatisticsListener
} from './GlobalDataInterface'
import { GlobalCardDataManager } from '../utils/managers/GlobalCardDataManager'
import { StStatistics, GlobalRealtimeData } from './Structures'
import { hilog } from '@kit.PerformanceAnalysisKit'

const TAG = 'UIDataSync'

/**
 * AppStorage 键名接口
 */
interface StorageKeysType {
  TOP_PRODUCTION_TON_H: string
  TOP_SUM_WEIGHT_TON: string
  TOP_SUM_COUNTS: string
  TOP_AVG_G: string
  SORT_SPEED: string
  BATCH_WEIGHT: string
  BATCH_COUNT: string
  START_TIME: string
  EFFICIENCY: string
  AVG_WEIGHT: string
  REALTIME_OUTPUT: string
  INTERVAL_SPEED: string
  EXIT_COUNT_PREFIX: string
  EXIT_WEIGHT_PREFIX: string
  EXIT_PERCENT_PREFIX: string
  IS_PROCESSING: string
  RUNNING_TIME: string
}

/**
 * UI 数据同步服务类
 * 监听协议层数据变化，自动更新 AppStorage
 */
export class UIDataSync {
  private static instance: UIDataSync | null = null

  private dataInterface: GlobalDataInterface
  private dataChangeListener: DataChangeListener | null = null
  private statisticsListener: StatisticsListener | null = null
  private isRunning: boolean = false

  // AppStorage 键名常量
  private static readonly STORAGE_KEYS: StorageKeysType = {
    TOP_PRODUCTION_TON_H: 'TOP_PRODUCTION_TON_H',
    TOP_SUM_WEIGHT_TON: 'TOP_SUM_WEIGHT_TON',
    TOP_SUM_COUNTS: 'TOP_SUM_COUNTS',
    TOP_AVG_G: 'TOP_AVG_G',
    SORT_SPEED: 'SORT_SPEED',
    BATCH_WEIGHT: 'BATCH_WEIGHT',
    BATCH_COUNT: 'BATCH_COUNT',
    START_TIME: 'START_TIME',
    EFFICIENCY: 'EFFICIENCY',
    AVG_WEIGHT: 'AVG_WEIGHT',
    REALTIME_OUTPUT: 'REALTIME_OUTPUT',
    INTERVAL_SPEED: 'INTERVAL_SPEED',
    EXIT_COUNT_PREFIX: 'EXIT_COUNT_',
    EXIT_WEIGHT_PREFIX: 'EXIT_WEIGHT_',
    EXIT_PERCENT_PREFIX: 'EXIT_PERCENT_',
    IS_PROCESSING: 'IS_PROCESSING',
    RUNNING_TIME: 'RUNNING_TIME'
  }

  /**
   * 获取单例实例
   */
  static getInstance(): UIDataSync {
    if (!UIDataSync.instance) {
      UIDataSync.instance = new UIDataSync()
    }
    return UIDataSync.instance
  }

  private constructor() {
    this.dataInterface = getGlobalDataInterface()
    hilog.info(0x0001, TAG, 'UI数据同步服务初始化')
  }

  /**
   * 启动同步服务
   */
  start(): void {
    if (this.isRunning) {
      hilog.warn(0x0001, TAG, '同步服务已在运行')
      return
    }

    // 初始化 AppStorage 键值
    this.initializeStorageKeys()

    // 注册数据变化监听器
    this.dataChangeListener = (data: GlobalRealtimeData) => {
      this.syncGlobalDataToStorage(data)
    }
    this.dataInterface.addDataChangeListener(this.dataChangeListener)

    // 注册统计数据监听器（用于更细粒度的更新）
    this.statisticsListener = (stats: StStatistics) => {
      this.syncStatisticsToStorage(stats)
    }
    this.dataInterface.addStatisticsListener(this.statisticsListener)

    // 同步初始数据
    const initialData = this.dataInterface.getGlobalData()
    this.syncGlobalDataToStorage(initialData)

    this.isRunning = true
    hilog.info(0x0001, TAG, 'UI数据同步服务已启动')
  }

  /**
   * 停止同步服务
   */
  stop(): void {
    if (this.dataChangeListener) {
      this.dataInterface.removeDataChangeListener(this.dataChangeListener)
      this.dataChangeListener = null
    }

    if (this.statisticsListener) {
      this.dataInterface.removeStatisticsListener(this.statisticsListener)
      this.statisticsListener = null
    }

    this.isRunning = false
    hilog.info(0x0001, TAG, 'UI数据同步服务已停止')
  }

  /**
   * 初始化 AppStorage 键值
   */
  private initializeStorageKeys(): void {
    const keys = UIDataSync.STORAGE_KEYS

    // 初始化顶部状态栏
    AppStorage.setOrCreate(keys.TOP_PRODUCTION_TON_H, '0.00')
    AppStorage.setOrCreate(keys.TOP_SUM_WEIGHT_TON, '0.000')
    AppStorage.setOrCreate(keys.TOP_SUM_COUNTS, '0')
    AppStorage.setOrCreate(keys.TOP_AVG_G, '0.0')

    // 初始化分选信息卡片
    AppStorage.setOrCreate(keys.SORT_SPEED, '0 件/分钟')
    AppStorage.setOrCreate(keys.BATCH_WEIGHT, '0.00 kg')
    AppStorage.setOrCreate(keys.BATCH_COUNT, '0 件')
    AppStorage.setOrCreate(keys.START_TIME, '--:--:--')
    AppStorage.setOrCreate(keys.EFFICIENCY, '0%')
    AppStorage.setOrCreate(keys.AVG_WEIGHT, '0.00 kg')
    AppStorage.setOrCreate(keys.REALTIME_OUTPUT, '0 件/分钟')
    AppStorage.setOrCreate(keys.INTERVAL_SPEED, '0 ms')

    // 初始化状态
    AppStorage.setOrCreate(keys.IS_PROCESSING, false)
    AppStorage.setOrCreate(keys.RUNNING_TIME, '00:00:00')
    
    for (let i = 0; i < 48; i++) {
      AppStorage.setOrCreate(`${keys.EXIT_COUNT_PREFIX}${i + 1}`, 0)
      AppStorage.setOrCreate(`${keys.EXIT_WEIGHT_PREFIX}${i + 1}`, 0)
      AppStorage.setOrCreate(`${keys.EXIT_PERCENT_PREFIX}${i + 1}`, 0)
    }

    hilog.info(0x0001, TAG, 'AppStorage 键值已初始化')
  }

  private syncGlobalDataToStorage(data: GlobalRealtimeData): void {
    const keys = UIDataSync.STORAGE_KEYS

    let productionTonH = '0.00'
    const avgWeightG = data.totalYield > 0 ? (data.totalWeight / data.totalYield) : 0
    if (data.efficiency > 0) {

      const tonPerHour = (data.efficiency * 60 * avgWeightG) / 1000000
      productionTonH = tonPerHour.toFixed(2)
    } else if (data.runningTime > 0) {
      // 备选：使用平均效率
      const hoursElapsed = data.runningTime / 3600
      const tonPerHour = (data.totalWeight / 1000000) / hoursElapsed
      productionTonH = tonPerHour.toFixed(2)
    }

    // 总重（吨）
    // 注意：totalWeight 单位是 克(g)，转换为 吨(Ton) 需要除以 1,000,000
    const sumWeightTon = (data.totalWeight / 1000000).toFixed(3)

    // 总数
    const sumCounts = data.totalYield.toString()

    // 平均重量（克/个）
    let avgG = '0.0'
    if (data.totalYield > 0) {
      avgG = (data.totalWeight / data.totalYield).toFixed(1)
    }

    // 更新顶部状态栏
    // 使用 AppStorage.set 确保 UI 监听到变化
    AppStorage.setOrCreate(keys.TOP_PRODUCTION_TON_H, productionTonH)
    AppStorage.setOrCreate(keys.TOP_SUM_WEIGHT_TON, sumWeightTon)
    AppStorage.setOrCreate(keys.TOP_SUM_COUNTS, sumCounts)
    AppStorage.setOrCreate(keys.TOP_AVG_G, avgG)

    hilog.debug(0x0001, TAG, 
      `UI数据同步详情: 效率=${data.efficiency}, 运行时间=${data.runningTime}s, 产量=${sumCounts}, 总重=${sumWeightTon}吨, 时产=${productionTonH}吨/时`)
    // console.log(`UI数据同步详情: 效率=${data.efficiency}, 运行时间=${data.runningTime}s, 产量=${sumCounts}, 总重=${sumWeightTon}吨, 时产=${productionTonH}吨/时`)
    // 更新分选信息卡片
    AppStorage.setOrCreate(keys.SORT_SPEED, `${data.efficiency.toFixed(0)} 件/分钟`)
    AppStorage.setOrCreate(keys.BATCH_WEIGHT, `${(data.totalWeight / 1000).toFixed(2)} kg`)
    AppStorage.setOrCreate(keys.BATCH_COUNT, `${data.totalYield} 件`)
    AppStorage.setOrCreate(keys.AVG_WEIGHT, `${avgG} g`)
    AppStorage.setOrCreate(keys.REALTIME_OUTPUT, `${data.efficiency.toFixed(1)} 件/分钟`)

    // 更新效率
    const total = data.totalQualified + data.totalUnqualified
    const efficiencyPercent = total > 0 ? ((data.totalQualified / total) * 100).toFixed(1) : '0.0'
    AppStorage.setOrCreate(keys.EFFICIENCY, `${efficiencyPercent}%`)

    // 更新运行时间
    AppStorage.setOrCreate(keys.RUNNING_TIME, this.formatTime(data.runningTime))
    AppStorage.setOrCreate(keys.IS_PROCESSING, data.runningTime > 0 || data.totalYield > 0)

    // 更新开始时间（如果正在加工）
    if (data.startTime > 0) {
      const startDate = new Date(data.startTime)
      const timeStr = `${startDate.getHours().toString().padStart(2, '0')}:${startDate.getMinutes().toString().padStart(2, '0')}:${startDate.getSeconds().toString().padStart(2, '0')}`
      AppStorage.setOrCreate(keys.START_TIME, timeStr)
    }

    // 更新出口数据
    this.syncExitDataToStorage(data)

    // [NEW] 触发 GlobalCardDataManager 的同步逻辑
    // 类似于 C++ 中的 Event 触发，这里直接调用单例方法通知 UI 数据已准备好
    GlobalCardDataManager.getInstance().syncExitDataFromStorage()

    hilog.debug(0x0001, TAG,
      `UI数据已同步: 产量=${sumCounts}, 总重=${sumWeightTon}吨, 效率=${productionTonH}吨/时`)
  }

  /**
   * 同步出口数据到 AppStorage
   */
  private syncExitDataToStorage(data: GlobalRealtimeData): void {
    const keys = UIDataSync.STORAGE_KEYS

    // 更新每个出口的数量和重量
    for (let i = 0; i < data.exitCount.length && i < 48; i++) {
      const countKey = `${keys.EXIT_COUNT_PREFIX}${i + 1}`
      const weightKey = `${keys.EXIT_WEIGHT_PREFIX}${i + 1}`

      AppStorage.set(countKey, data.exitCount[i])
      AppStorage.set(weightKey, data.exitWeight[i])
    }

    const maxExit = Math.min(48, data.exitCount.length, data.exitWeight.length)
    let totalCount = 0
    let totalWeight = 0
    for (let i = 0; i < maxExit; i++) {
      totalCount += data.exitCount[i] || 0
      totalWeight += data.exitWeight[i] || 0
    }

    const useWeightBase = totalWeight > 0
    const baseTotal = useWeightBase ? totalWeight : totalCount

    for (let i = 0; i < maxExit; i++) {
      const percentKey = `${keys.EXIT_PERCENT_PREFIX}${i + 1}`
      const baseValue = useWeightBase ? (data.exitWeight[i] || 0) : (data.exitCount[i] || 0)
      const pct = baseTotal > 0 ? (baseValue * 100) / baseTotal : 0
      const pctRounded = Math.round(pct * 100) / 100
      AppStorage.set(percentKey, pctRounded)
    }
  }

  /**
   * 同步统计数据到 AppStorage（通道级别）
   */
  private syncStatisticsToStorage(stats: StStatistics): void {
    // 可以在这里处理更细粒度的通道数据
    hilog.debug(0x0001, TAG,
      `通道${stats.nChannelIndex}统计: 产量=${stats.nYield}, 总重=${stats.nTotalWeight}g`)
  }

  /**
   * 格式化时间（秒 -> HH:MM:SS）
   */
  private formatTime(seconds: number): string {
    const hours = Math.floor(seconds / 3600)
    const minutes = Math.floor((seconds % 3600) / 60)
    const secs = Math.floor(seconds % 60)
    return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
  }

  /**
   * 手动触发数据刷新
   */
  refresh(): void {
    const data = this.dataInterface.getGlobalData()
    this.syncGlobalDataToStorage(data)
    hilog.info(0x0001, TAG, '数据已手动刷新')
  }

  /**
   * 获取同步服务运行状态
   */
  isServiceRunning(): boolean {
    return this.isRunning
  }
}

// 导出单例获取方法
export function getUIDataSync(): UIDataSync {
  return UIDataSync.getInstance()
}
