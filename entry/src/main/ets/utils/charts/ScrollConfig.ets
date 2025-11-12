/**
 * 高性能滚动配置
 * 功能：提供统一的滚动性能优化配置
 * 用途：解决滚动卡顿问题，提升用户体验
 */

/**
 * 高性能滚动配置类
 */
export class ScrollConfig {
  // 高性能滚动参数
  static readonly HIGH_PERFORMANCE = {
    friction: 0.6, // 更低的摩擦系数，提升流畅度
    scrollBar: BarState.Auto,
    scrollBarWidth: 6,
    edgeEffect: EdgeEffect.Spring,
    enableRedrawOptimization: true, // 启用重绘优化
    hardwareAcceleration: true // 启用硬件加速
  }

  // 标准滚动参数
  static readonly STANDARD = {
    friction: 0.8,
    scrollBar: BarState.Auto,
    scrollBarWidth: 6,
    edgeEffect: EdgeEffect.Spring,
    enableRedrawOptimization: false,
    hardwareAcceleration: false
  }

  /**
   * 应用高性能滚动配置
   * @param scrollComponent 滚动组件
   * @param scrollBarColor 滚动条颜色
   */
  static applyHighPerformance(scrollComponent: any, scrollBarColor: string = '#E0E0E0') {
    return scrollComponent
      .friction(this.HIGH_PERFORMANCE.friction)
      .scrollBar(this.HIGH_PERFORMANCE.scrollBar)
      .scrollBarColor(scrollBarColor)
      .scrollBarWidth(this.HIGH_PERFORMANCE.scrollBarWidth)
      .edgeEffect(this.HIGH_PERFORMANCE.edgeEffect)
      .enableRedrawOptimization(this.HIGH_PERFORMANCE.enableRedrawOptimization)
      .hardwareAcceleration(this.HIGH_PERFORMANCE.hardwareAcceleration)
  }

  /**
   * 应用标准滚动配置
   * @param scrollComponent 滚动组件
   * @param scrollBarColor 滚动条颜色
   */
  static applyStandard(scrollComponent: any, scrollBarColor: string = '#E0E0E0') {
    return scrollComponent
      .friction(this.STANDARD.friction)
      .scrollBar(this.STANDARD.scrollBar)
      .scrollBarColor(scrollBarColor)
      .scrollBarWidth(this.STANDARD.scrollBarWidth)
      .edgeEffect(this.STANDARD.edgeEffect)
      .enableRedrawOptimization(this.STANDARD.enableRedrawOptimization)
      .hardwareAcceleration(this.STANDARD.hardwareAcceleration)
  }
}
