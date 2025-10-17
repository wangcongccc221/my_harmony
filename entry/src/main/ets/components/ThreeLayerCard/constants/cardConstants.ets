/**
 * 卡片常量
 *
 * 说明：
 * - 统一维护 ThreeLayerCard 模块内常量，便于集中配置与后续扩展。
 * - 常量仅承载“默认值/静态配置”，不包含计算逻辑。
 */

export class CardConstants {
  /**
   * 默认卡片宽度（px）
   * 用途：ThreeLayerCard 的默认渲染宽度；可被组件 @Prop 覆盖
   */
  static readonly DEFAULT_CARD_WIDTH: number = 150
  /**
   * 默认卡片高度（px）
   * 用途：ThreeLayerCard 的默认渲染高度；可被组件 @Prop 覆盖
   */
  static readonly DEFAULT_CARD_HEIGHT: number = 200
  /**
   * 默认主色（十六进制）
   * 用途：卡片强调色/按钮/拖拽预览背景等的默认主色
   */
  static readonly DEFAULT_MAIN_COLOR: string = '#EA7A10'
  /**
   * 预设波浪高度百分比序列（%）
   * 用途：为不同卡片提供默认的波浪填充高度（示例：第1/2/3张卡 20/40/60）
   * 取值范围：0 - 100
   */
  static readonly WAVE_HEIGHT_PERCENTS: number[] = [20, 40, 60]
}


