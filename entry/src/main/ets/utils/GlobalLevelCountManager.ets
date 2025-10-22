/**
 * 全局等级数量管理器
 * 
 * 功能说明：
 * - 管理全局的等级数量状态
 * - 支持滚轮事件直接修改等级数量
 * - 提供状态变化监听功能
 * 
 * 使用场景：
 * - 品质页面的等级数量选择器
 * - 滚轮事件处理
 * - 跨组件状态同步
 */

import { LEVEL_COUNT_OPTIONS } from '../pages/quality/QualityConstants'

/**
 * 等级数量变化回调函数类型
 */
export type LevelCountChangeCallback = (newCount: number, newIndex: number) => void

/**
 * 全局等级数量管理器
 * 
 * 功能说明：
 * - 单例模式，确保全局唯一
 * - 管理当前等级数量和索引
 * - 提供滚轮事件处理
 * - 支持状态变化监听
 */
export class GlobalLevelCountManager {
  private static instance: GlobalLevelCountManager
  private currentIndex: number = 16 // 当前索引，默认为16（16个等级）
  private callbacks: LevelCountChangeCallback[] = [] // 状态变化回调函数列表

  /**
   * 私有构造函数，确保单例模式
   */
  private constructor() {
    console.log('🎯 全局等级数量管理器初始化')
  }

  /**
   * 获取单例实例
   * @returns GlobalLevelCountManager实例
   */
  public static getInstance(): GlobalLevelCountManager {
    if (!GlobalLevelCountManager.instance) {
      GlobalLevelCountManager.instance = new GlobalLevelCountManager()
    }
    return GlobalLevelCountManager.instance
  }

  /**
   * 获取当前等级数量索引
   * @returns 当前索引
   */
  public getCurrentIndex(): number {
    return this.currentIndex
  }

  /**
   * 获取当前等级数量值
   * @returns 当前等级数量值
   */
  public getCurrentCount(): number {
    return parseInt(LEVEL_COUNT_OPTIONS[this.currentIndex].value)
  }

  /**
   * 设置等级数量索引
   * @param index 新的索引值
   */
  public setIndex(index: number): void {
    const clampedIndex = Math.max(0, Math.min(index, LEVEL_COUNT_OPTIONS.length - 1))
    if (clampedIndex !== this.currentIndex) {
      const oldIndex = this.currentIndex
      this.currentIndex = clampedIndex
      const newCount = this.getCurrentCount()
      
      console.log(`🔄 等级数量索引变化: ${oldIndex} -> ${clampedIndex}`)
      console.log(`📊 等级数量值变化: ${parseInt(LEVEL_COUNT_OPTIONS[oldIndex].value)} -> ${newCount}`)
      
      // 通知所有监听器
      this.notifyCallbacks(newCount, clampedIndex)
    }
  }

  /**
   * 根据等级数量值设置索引
   * @param count 等级数量值
   */
  public setCount(count: number): void {
    const index = LEVEL_COUNT_OPTIONS.findIndex(option => parseInt(option.value) === count)
    if (index !== -1) {
      this.setIndex(index)
    } else {
      console.warn(`⚠️ 无效的等级数量值: ${count}`)
    }
  }

  /**
   * 处理滚轮事件
   * @param verticalValue 垂直滚轮值
   * @param currentDataCount 当前实际数据条数（可选）
   */
  public handleWheelEvent(verticalValue: number, currentDataCount?: number): void {
    console.log(`🎡 处理滚轮事件 - 垂直值: ${verticalValue}`)
    console.log(`🔍 详细检查 - verticalValue类型: ${typeof verticalValue}, 值: ${verticalValue}`)
    console.log(`🔍 当前索引: ${this.currentIndex}, 当前数值: ${this.getCurrentCount()}`)
    console.log(`🔍 当前实际数据条数: ${currentDataCount}`)
    
    // 如果有实际数据条数，基于实际数据条数进行增减
    // 否则基于当前选择器的显示值进行增减
    const baseCount = currentDataCount !== undefined ? currentDataCount : this.getCurrentCount()
    
    if (verticalValue > 0) {
      // 向上滚动，等级数量 -1（减少）
      const newCount = Math.max(baseCount - 1, 0)
      console.log(`⬆️ 向上滚动，从数值 ${baseCount} 到数值 ${newCount}`)
      this.setCount(newCount)
    } else if (verticalValue < 0) {
      // 向下滚动，等级数量 +1（增加）
      const newCount = Math.min(baseCount + 1, 16)
      console.log(`⬇️ 向下滚动，从数值 ${baseCount} 到数值 ${newCount}`)
      this.setCount(newCount)
    } else {
      console.log(`❓ 垂直值为0，不处理`)
    }
  }

  /**
   * 添加状态变化监听器
   * @param callback 回调函数
   */
  public addChangeListener(callback: LevelCountChangeCallback): void {
    this.callbacks.push(callback)
    console.log(`📝 添加等级数量变化监听器，当前监听器数量: ${this.callbacks.length}`)
  }

  /**
   * 移除状态变化监听器
   * @param callback 回调函数
   */
  public removeChangeListener(callback: LevelCountChangeCallback): void {
    const index = this.callbacks.indexOf(callback)
    if (index !== -1) {
      this.callbacks.splice(index, 1)
      console.log(`🗑️ 移除等级数量变化监听器，当前监听器数量: ${this.callbacks.length}`)
    }
  }

  /**
   * 通知所有监听器状态变化
   * @param newCount 新的等级数量值
   * @param newIndex 新的索引值
   */
  private notifyCallbacks(newCount: number, newIndex: number): void {
    console.log(`📢 通知 ${this.callbacks.length} 个监听器状态变化`)
    this.callbacks.forEach((callback, index) => {
      try {
        callback(newCount, newIndex)
        console.log(`✅ 监听器 ${index + 1} 通知成功`)
      } catch (error) {
        console.error(`❌ 监听器 ${index + 1} 通知失败:`, error)
      }
    })
  }

  /**
   * 获取所有等级数量选项
   * @returns 等级数量选项数组
   */
  public getLevelCountOptions() {
    return LEVEL_COUNT_OPTIONS
  }

  /**
   * 重置为默认值
   */
  public reset(): void {
    this.setIndex(0) // 重置为16个等级
    console.log('🔄 等级数量管理器已重置为默认值')
  }
}
