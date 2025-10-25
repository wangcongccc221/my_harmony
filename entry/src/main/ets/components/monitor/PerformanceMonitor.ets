/**
 * 性能监控组件
 * 使用 @ohos.hidebug 模块获取真实的CPU和内存数据
 */

import { hidebug } from '@kit.PerformanceAnalysisKit'
import { BusinessError } from '@kit.BasicServicesKit'

@Component
export struct PerformanceMonitor {
  @State private cpuUsage: string = '获取中...'
  @State private memoryUsage: string = '获取中...'
  @State private nativeHeapSize: string = '获取中...'
  @State private pssMemory: string = '获取中...'
  
  private timer: number = -1
  private updateInterval: number = 2000 // 2秒更新一次

  aboutToAppear() {
    this.startMonitoring()
  }

  aboutToDisappear() {
    this.stopMonitoring()
  }

  // 开始监控
  private startMonitoring() {
    // 立即获取一次数据
    this.updatePerformanceData()
    
    // 设置定时器定期更新
    this.timer = setInterval(() => {
      this.updatePerformanceData()
    }, this.updateInterval)
  }

  // 停止监控
  private stopMonitoring() {
    if (this.timer !== -1) {
      clearInterval(this.timer)
      this.timer = -1
    }
  }

  // 更新性能数据
  private updatePerformanceData() {
    try {
      // 获取CPU使用率
      const cpuUsageValue = hidebug.getCpuUsage()
      this.cpuUsage = `CPU: ${(cpuUsageValue * 100).toFixed(1)}%`

      // 获取PSS内存使用情况
      const pssValue = hidebug.getPss()
      this.pssMemory = `PSS: ${this.formatBytes(Number(pssValue) * 1024)}` // PSS返回的是KB，转换为字节

      // 获取原生堆内存大小
      const nativeHeapSizeValue = hidebug.getNativeHeapSize()
      this.nativeHeapSize = `堆: ${this.formatBytes(Number(nativeHeapSizeValue))}`

      // 计算内存使用率（使用PSS作为实际物理内存使用）
      const pssMB = Number(pssValue) / 1024 // 转换为MB
      this.memoryUsage = `内存: ${pssMB.toFixed(1)}MB`

    } catch (error) {
      console.error('获取性能数据失败:', error)
      const businessError = error as BusinessError
      this.cpuUsage = `CPU: 错误(${businessError.code})`
      this.memoryUsage = `内存: 错误(${businessError.code})`
      this.nativeHeapSize = `堆: 错误(${businessError.code})`
      this.pssMemory = `PSS: 错误(${businessError.code})`
    }
  }

  // 格式化字节数
  private formatBytes(bytes: number): string {
    if (bytes === 0) return '0 B'
    
    const k = 1024
    const sizes = ['B', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    
    return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + sizes[i]
  }

  build() {
    Row() {
      // CPU使用率
      Text(this.cpuUsage)
        .fontSize(12)
        .fontColor('#00FF00')
        .margin({ right: 8 })
        .textAlign(TextAlign.Center)

      // 内存使用情况
      Text(this.memoryUsage)
        .fontSize(12)
        .fontColor('#FFA500')
        .margin({ right: 8 })
        .textAlign(TextAlign.Center)

      // PSS内存
      Text(this.pssMemory)
        .fontSize(12)
        .fontColor('#FF6B6B')
        .margin({ right: 8 })
        .textAlign(TextAlign.Center)

      // 原生堆大小
      Text(this.nativeHeapSize)
        .fontSize(12)
        .fontColor('#4ECDC4')
        .textAlign(TextAlign.Center)
    }
    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
    .backgroundColor('rgba(0, 0, 0, 0.7)')
    .borderRadius(4)
    .justifyContent(FlexAlign.SpaceAround)
    .width('100%')
  }
}
