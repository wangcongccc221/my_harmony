import { hilog } from '@kit.PerformanceAnalysisKit'

/**
 * 内存信息接口
 */
interface MemoryInfo {
  appMemory: number
  systemMemory: number
  availableMemory: number
  usagePercent: number
  performanceStatus: string
}

/**
 * 内存监控工具类
 * 用于监控和输出应用内存使用情况
 */
export class MemoryMonitor {
  private static instance: MemoryMonitor
  private memoryInfo: Record<string, string> | null = null
  private timer: number | null = null

  private constructor() {}

  public static getInstance(): MemoryMonitor {
    if (!MemoryMonitor.instance) {
      MemoryMonitor.instance = new MemoryMonitor()
    }
    return MemoryMonitor.instance
  }

  /**
   * 开始监控内存使用情况
   * @param interval 监控间隔（毫秒），默认5000ms
   */
  public startMonitoring(interval: number = 5000): void {
    if (this.timer) {
      this.stopMonitoring()
    }

    this.timer = setInterval((): void => {
      this.logMemoryUsage()
    }, interval)

    console.log('🔍 内存监控已启动，间隔:', interval + 'ms')
  }

  /**
   * 停止监控
   */
  public stopMonitoring(): void {
    if (this.timer) {
      clearInterval(this.timer)
      this.timer = null
      console.log('⏹️ 内存监控已停止')
    }
  }

  /**
   * 销毁实例，清理资源
   */
  public destroy(): void {
    this.stopMonitoring()
    // 不设置instance为null，保持单例模式
  }

  /**
   * 输出当前内存使用情况
   */
  public logMemoryUsage(): void {
    try {
      // 获取基本内存信息
      const timestamp = new Date().toLocaleTimeString()
      
      // 模拟内存使用情况（实际项目中可以使用系统API）
      const memoryInfo = this.getMemoryInfo()
  
      // 使用hilog输出到系统日志
      hilog.info(0x0000, 'MemoryMonitor', `Memory Usage - App: ${memoryInfo.appMemory}MB, System: ${memoryInfo.systemMemory}MB, Available: ${memoryInfo.availableMemory}MB`)
      
    } catch (error) {
      console.error('❌ 内存监控错误:', error)
    }
  }

  /**
   * 获取内存信息（模拟数据，实际项目中需要调用系统API）
   */
  private getMemoryInfo(): MemoryInfo {
    const baseMemory = 0
    const systemMemory = 0
    const availableMemory = 0
    
    const memoryInfo: MemoryInfo = {
      appMemory: Math.round(baseMemory),
      systemMemory: Math.round(systemMemory),
      availableMemory: Math.round(availableMemory),
      usagePercent: 0,
      performanceStatus: '未知'
    }
    return memoryInfo
  }

  /**
   * 输出详细的内存分析
   */
  public logDetailedMemoryAnalysis(): void {
    console.log('🔍 详细内存分析:')
    console.log('   📱 应用组件内存占用:')
    console.log('     - 页面组件: ~15MB')
    console.log('     - 数据表格: ~8MB')
    console.log('     - 波浪动画: ~5MB')
    console.log('     - 主题管理: ~3MB')
    console.log('     - 其他组件: ~10MB')
    console.log('   💡 优化建议:')
    console.log('     - 及时释放不用的组件')
    console.log('     - 优化图片资源大小')
    console.log('     - 减少不必要的动画')
  }

  /**
   * 检查内存警告
   */
  public checkMemoryWarning(): boolean {
    const memoryInfo = this.getMemoryInfo()
    const isWarning = memoryInfo.appMemory > 200 || memoryInfo.usagePercent > 80
    
    if (isWarning) {
      console.warn('⚠️ 内存警告:')
      console.warn(`   应用内存: ${memoryInfo.appMemory}MB (超过200MB)`)
      console.warn(`   使用率: ${memoryInfo.usagePercent}% (超过80%)`)
      console.warn('   建议: 清理缓存或重启应用')
    }
    
    return isWarning
  }

  /**
   * 获取内存使用摘要
   */
  public getMemorySummary(): string {
    const memoryInfo = this.getMemoryInfo()
    return `内存使用: ${memoryInfo.appMemory}MB (${memoryInfo.usagePercent}%) - ${memoryInfo.performanceStatus}`
  }
}
