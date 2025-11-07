/**
 * 波浪相位管理器（单例）
 * 功能：统一管理所有波浪卡片的相位，确保动画同步
 * 用途：让多个 WaveCard 实例共享同一个相位值，实现同步动画
 */

export class WavePhaseManager {
  private static instance: WavePhaseManager | null = null
  private phase: number = 1.5  // 初始相位
  private speed: number = 0.02  // 相位变化速度
  private animationId: number = 0
  private listeners: Set<() => void> = new Set()  // 监听器集合

  private constructor() {
    this.startGlobalAnimation()
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): WavePhaseManager {
    if (!WavePhaseManager.instance) {
      WavePhaseManager.instance = new WavePhaseManager()
    }
    return WavePhaseManager.instance
  }

  /**
   * 获取当前相位值
   */
  public getPhase(): number {
    return this.phase
  }

  /**
   * 启动全局动画（统一更新相位）
   */
  private startGlobalAnimation(): void {
    if (this.animationId) {
      clearInterval(this.animationId)
    }
    // 60fps（16ms间隔）统一更新相位
    this.animationId = setInterval(() => {
      this.phase += this.speed
      // 通知所有监听器（WaveCard实例）重绘
      this.notifyListeners()
    }, 16) as number
  }

  /**
   * 注册监听器（WaveCard实例注册，用于接收相位更新通知）
   */
  public addListener(callback: () => void): void {
    this.listeners.add(callback)
  }

  /**
   * 移除监听器
   */
  public removeListener(callback: () => void): void {
    this.listeners.delete(callback)
  }

  /**
   * 通知所有监听器（触发重绘）
   */
  private notifyListeners(): void {
    this.listeners.forEach(callback => {
      try {
        callback()
      } catch (_) {
        // 忽略错误，避免某个监听器出错影响其他
      }
    })
  }

  /**
   * 停止全局动画
   */
  public stop(): void {
    if (this.animationId) {
      clearInterval(this.animationId)
      this.animationId = 0
    }
    this.listeners.clear()
  }

  /**
   * 重置相位
   */
  public resetPhase(): void {
    this.phase = 1.5
  }
}

