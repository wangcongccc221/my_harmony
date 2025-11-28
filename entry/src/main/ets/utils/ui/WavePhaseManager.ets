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
    // 确保没有重复的定时器
    if (this.animationId) {
      clearInterval(this.animationId)
      this.animationId = 0
    }
    // 使用60fps（约16.67ms间隔）统一更新相位，保持恒定速度
    // 使用 17ms 而不是 16ms，给系统一些缓冲，避免时间累积误差
    this.animationId = setInterval(() => {
      // 固定速度增量，确保动画速度一致
      this.phase += this.speed
      // 相位值过大时重置，避免精度问题
      if (this.phase > Math.PI * 2) {
        this.phase = this.phase % (Math.PI * 2)
      }
      // 通知所有监听器（WaveCard实例）重绘
      this.notifyListeners()
    }, 17) as number
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
    // 注意：不清空 listeners，保留监听器以便恢复
  }

  /**
   * 恢复全局动画（应用从后台恢复时调用）
   */
  public resume(): void {
    // 确保只启动一次，避免重复启动导致速度异常
    if (this.animationId) {
      // 如果已经有动画在运行，先停止它
      clearInterval(this.animationId)
      this.animationId = 0
    }
    // 重新启动动画
    this.startGlobalAnimation()
    // 立即通知所有监听器，触发重绘
    this.notifyListeners()
  }

  /**
   * 完全停止并清理（应用退出时调用）
   */
  public destroy(): void {
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

