/**
 * 数据库同步服务
 * 将实时统计数据保存到数据库
 * 对应48项目的数据持久化逻辑
 */

import {
  GlobalDataInterface,
  getGlobalDataInterface,
  DataChangeListener,
  StatisticsListener
} from './GlobalDataInterface'
import { GlobalRealtimeData, StStatistics } from './Structures'
import { hilog } from '@kit.PerformanceAnalysisKit'

const TAG = 'DatabaseSync'

/**
 * 数据库保存接口
 * 由外部实现具体的数据库操作
 */
export interface IDatabaseSaver {
  /**
   * 保存统计数据
   */
  saveStatistics(data: GlobalRealtimeData): Promise<boolean>

  /**
   * 保存加工批次信息
   */
  saveBatchInfo(batchId: number, data: GlobalRealtimeData): Promise<boolean>

  /**
   * 保存出口数据
   */
  saveExitData(exitIndex: number, count: number, weight: number): Promise<boolean>

  /**
   * 结束加工批次
   */
  endBatch(batchId: number, data: GlobalRealtimeData): Promise<boolean>
}

/**
 * 数据库同步服务类
 */
export class DatabaseSync {
  private static instance: DatabaseSync | null = null

  private dataInterface: GlobalDataInterface
  private databaseSaver: IDatabaseSaver | null = null

  // 监听器
  private dataChangeListener: DataChangeListener | null = null
  private statisticsListener: StatisticsListener | null = null

  // 自动保存配置
  private autoSaveEnabled: boolean = false
  private autoSaveInterval: number = 60000 // 60秒
  private autoSaveTimer: number = -1

  // 批次信息
  private currentBatchId: number = 0
  private lastSaveTime: number = 0

  /**
   * 获取单例实例
   */
  static getInstance(): DatabaseSync {
    if (!DatabaseSync.instance) {
      DatabaseSync.instance = new DatabaseSync()
    }
    return DatabaseSync.instance
  }

  private constructor() {
    this.dataInterface = getGlobalDataInterface()
    hilog.info(0x0001, TAG, '数据库同步服务初始化')
  }

  /**
   * 设置数据库保存器
   */
  setDatabaseSaver(saver: IDatabaseSaver): void {
    this.databaseSaver = saver
    hilog.info(0x0001, TAG, '数据库保存器已设置')
  }

  /**
   * 启动同步服务
   */
  start(): void {
    // 注册统计数据监听器
    this.statisticsListener = (stats: StStatistics) => {
      this.onStatisticsUpdate(stats)
    }
    this.dataInterface.addStatisticsListener(this.statisticsListener)

    // 注册全局数据变化监听器
    this.dataChangeListener = (data: GlobalRealtimeData) => {
      this.onDataChange(data)
    }
    this.dataInterface.addDataChangeListener(this.dataChangeListener)

    hilog.info(0x0001, TAG, '数据库同步服务已启动')
  }

  /**
   * 停止同步服务
   */
  stop(): void {
    // 移除监听器
    if (this.statisticsListener) {
      this.dataInterface.removeStatisticsListener(this.statisticsListener)
      this.statisticsListener = null
    }

    if (this.dataChangeListener) {
      this.dataInterface.removeDataChangeListener(this.dataChangeListener)
      this.dataChangeListener = null
    }

    // 停止自动保存
    this.stopAutoSave()

    hilog.info(0x0001, TAG, '数据库同步服务已停止')
  }

  /**
   * 启用自动保存
   */
  enableAutoSave(intervalMs: number = 60000): void {
    this.autoSaveInterval = intervalMs
    this.autoSaveEnabled = true

    if (this.autoSaveTimer === -1) {
      this.autoSaveTimer = setInterval(() => {
        this.performAutoSave()
      }, this.autoSaveInterval)
    }

    hilog.info(0x0001, TAG, `自动保存已启用，间隔: ${intervalMs}ms`)
  }

  /**
   * 停止自动保存
   */
  stopAutoSave(): void {
    this.autoSaveEnabled = false

    if (this.autoSaveTimer !== -1) {
      clearInterval(this.autoSaveTimer)
      this.autoSaveTimer = -1
    }

    hilog.info(0x0001, TAG, '自动保存已停止')
  }

  /**
   * 开始新的加工批次
   */
  startNewBatch(): number {
    this.currentBatchId = Date.now()
    this.lastSaveTime = this.currentBatchId

    hilog.info(0x0001, TAG, `开始新批次: ${this.currentBatchId}`)
    return this.currentBatchId
  }

  /**
   * 结束当前批次
   */
  async endCurrentBatch(): Promise<boolean> {
    if (this.currentBatchId === 0) {
      hilog.warn(0x0001, TAG, '没有活动的批次')
      return false
    }

    if (!this.databaseSaver) {
      hilog.warn(0x0001, TAG, '数据库保存器未设置')
      return false
    }

    const data = this.dataInterface.getGlobalData()

    try {
      const success = await this.databaseSaver.endBatch(this.currentBatchId, data)
      if (success) {
        hilog.info(0x0001, TAG, `批次 ${this.currentBatchId} 已结束并保存`)
        this.currentBatchId = 0
      }
      return success
    } catch (e) {
      hilog.error(0x0001, TAG, `结束批次失败: ${e}`)
      return false
    }
  }

  /**
   * 立即保存当前数据
   */
  async saveNow(): Promise<boolean> {
    if (!this.databaseSaver) {
      hilog.warn(0x0001, TAG, '数据库保存器未设置')
      return false
    }

    const data = this.dataInterface.getGlobalData()

    try {
      const success = await this.databaseSaver.saveStatistics(data)
      if (success) {
        this.lastSaveTime = Date.now()
        hilog.info(0x0001, TAG, '数据已保存')
      }
      return success
    } catch (e) {
      hilog.error(0x0001, TAG, `保存数据失败: ${e}`)
      return false
    }
  }

  /**
   * 获取当前批次ID
   */
  getCurrentBatchId(): number {
    return this.currentBatchId
  }

  /**
   * 获取最后保存时间
   */
  getLastSaveTime(): number {
    return this.lastSaveTime
  }

  // ==================== 私有方法 ====================
  /**
   * 统计数据更新回调
   */
  private onStatisticsUpdate(stats: StStatistics): void {
    // 可以在这里触发即时保存重要数据
    hilog.debug(0x0001, TAG,
      `统计更新: 通道${stats.nChannelIndex}, 产量=${stats.nYield}`)
  }

  /**
   * 全局数据变化回调
   */
  private onDataChange(data: GlobalRealtimeData): void {
    hilog.debug(0x0001, TAG,
      `数据变化: 总产量=${data.totalYield}, 总重=${data.totalWeight}g`)
    if (!this.databaseSaver) {
      return
    }

    if (this.currentBatchId === 0 && data.startTime > 0) {
      this.currentBatchId = data.startTime
      this.lastSaveTime = Date.now()
      Promise.resolve().then(async () => {
        try {
          await this.databaseSaver!.saveBatchInfo(this.currentBatchId, data)
        } catch (e) {
          hilog.error(0x0001, TAG, `保存批次信息失败: ${e}`)
        }
      })
    }
  }

  /**
   * 执行自动保存
   */
  private async performAutoSave(): Promise<void> {
    if (!this.autoSaveEnabled || !this.databaseSaver) {
      return
    }

    const data = this.dataInterface.getGlobalData()

    // 只有有数据变化时才保存
    if (data.totalYield === 0 && data.totalWeight === 0) {
      return
    }

    try {
      const success = await this.databaseSaver.saveStatistics(data)
      if (success) {
        this.lastSaveTime = Date.now()
        hilog.info(0x0001, TAG, `自动保存完成: 产量=${data.totalYield}, 总重=${data.totalWeight}g`)
      }
    } catch (e) {
      hilog.error(0x0001, TAG, `自动保存失败: ${e}`)
    }
  }
}

// 导出单例获取方法
export function getDatabaseSync(): DatabaseSync {
  return DatabaseSync.getInstance()
}
