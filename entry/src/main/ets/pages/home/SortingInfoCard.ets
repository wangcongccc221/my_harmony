/**
 * 分选信息卡片组件
 * 
 * 功能说明：
 * - 显示当前分选信息的9个关键指标
 * - 提供分选过程的实时数据展示
 * - 支持数据的动态更新和显示
 * - 使用卡片式布局展示信息
 * 
 * 显示指标：
 * - 分拣速度：当前分拣速度（件/分钟）
 * - 本批重量：当前批次的重量（kg）
 * - 本批个数：当前批次的件数
 * - 开始时间：分拣开始的时间
 * - 分选程序：当前使用的分选程序名称
 * - 分选效率：当前分选效率（%）
 * - 平均重量：平均每件重量（kg）
 * - 实时产量：实时产量（件/分钟）
 * - 间隔速度：分拣间隔时间（ms）
 * 
 * 组件特点：
 * - 数据展示：清晰展示9个关键指标
 * - 实时更新：支持数据的实时更新
 * - 主题支持：使用主题管理器的样式配置
 * - 响应式设计：支持不同屏幕尺寸
 * 
 * 使用方式：
 * ```typescript
 * SortingInfoCard({
 *   sortSpeed: this.sortSpeed,
 *   batchWeight: this.batchWeight,
 *   batchCount: this.batchCount,
 *   startTime: this.startTime,
 *   programName: this.programName,
 *   efficiency: this.efficiency,
 *   avgWeight: this.avgWeight,
 *   realTimeOutput: this.realTimeOutput,
 *   intervalSpeed: this.intervalSpeed
 * })
 * ```
 * 
 * 布局说明：
 * - 排列方式：3列3行网格布局
 * - 卡片样式：白色背景，圆角设计
 * - 数据格式：数值+单位的形式
 * - 位置：位于主页顶部区域
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'

/**
 * 分选信息卡片组件结构体
 * 
 * 属性说明：
 * - sortSpeed: 分拣速度，默认'0 件/分钟'
 * - batchWeight: 本批重量，默认'0.00 kg'
 * - batchCount: 本批个数，默认'0 件'
 * - startTime: 开始时间，默认'--:--:--'
 * - programName: 分选程序，默认'未选择'
 * - efficiency: 分选效率，默认'0%'
 * - avgWeight: 平均重量，默认'0.00 kg'
 * - realTimeOutput: 实时产量，默认'0 件/分钟'
 * - intervalSpeed: 间隔速度，默认'0 ms'
 * 
 * 方法说明：
 * - getCurrentTheme(): 获取当前主题配置
 * - build(): 构建分选信息卡片的UI结构
 * - buildInfoItem(): 构建单个信息条目的UI结构
 */
@Component
export struct SortingInfoCard {
  /**
   * 分拣速度
   * 
   * 功能说明：
   * - 显示当前分拣速度
   * - 默认值为'0 件/分钟'
   * - 支持动态更新
   */
  @StorageLink('SORT_SPEED') sortSpeed: string = '0 件/分钟'
  
  /**
   * 本批重量
   * 
   * 功能说明：
   * - 显示当前批次的重量
   * - 默认值为'0.00 kg'
   * - 支持动态更新
   */
  @StorageLink('BATCH_WEIGHT') batchWeight: string = '0.00 kg'
  
  /**
   * 本批个数
   * 
   * 功能说明：
   * - 显示当前批次的件数
   * - 默认值为'0 件'
   * - 支持动态更新
   */
  @StorageLink('BATCH_COUNT') batchCount: string = '0 件'
  
  /**
   * 开始时间
   * 
   * 功能说明：
   * - 显示分拣开始的时间
   * - 默认值为'--:--:--'（占位符）
   * - 支持动态更新
   */
  @StorageLink('START_TIME') startTime: string = '--:--:--'
  
  /**
   * 分选程序
   * 
   * 功能说明：
   * - 显示当前使用的分选程序名称
   * - 默认值为'未选择'
   * - 支持动态更新
   */
  @StorageLink('PROGRAM_NAME') programName: string = '未选择'
  
  /**
   * 分选效率
   * 
   * 功能说明：
   * - 显示当前分选效率
   * - 默认值为'0%'
   * - 支持动态更新
   */
  @StorageLink('EFFICIENCY') efficiency: string = '0%'
  
  /**
   * 平均重量
   * 
   * 功能说明：
   * - 显示平均每件重量
   * - 默认值为'0.00 kg'
   * - 支持动态更新
   */
  @StorageLink('AVG_WEIGHT') avgWeight: string = '0.00 kg'
  
  /**
   * 实时产量
   * 
   * 功能说明：
   * - 显示实时产量
   * - 默认值为'0 件/分钟'
   * - 支持动态更新
   */
  @StorageLink('REALTIME_OUTPUT') realTimeOutput: string = '0 件/分钟'
  
  /**
   * 间隔速度
   * 
   * 功能说明：
   * - 显示分拣间隔时间
   * - 默认值为'0 ms'
   * - 支持动态更新
   */
  @StorageLink('INTERVAL_SPEED') intervalSpeed: string = '0 ms'

  /**
   * 获取当前主题配置
   * 
   * 功能说明：
   * - 从主题管理器获取当前主题样式
   * - 用于组件样式配置
   * - 支持主题切换时的样式更新
   * 
   * @returns 当前主题的扩展样式对象
   */
  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return OmniThemeManager.getInstance().getCurrentTheme()
  }

  /**
   * 组件构建方法
   * 
   * 功能：
   * - 构建分选信息卡片的UI结构
   * - 实现9个关键指标的水平排列
   * - 处理数据的显示和更新
   * 
   * 布局说明：
   * - 使用Column布局垂直排列标题和内容
   * - 标题：'当前分选信息'
   * - 内容：9个信息项水平排列
   * - 卡片样式：白色背景，圆角设计
   * 
   * 样式说明：
   * - 卡片高度：15%
   * - 背景色：主题控制背景色或表面色
   * - 边框：1px主题边框色
   * - 圆角：12px
   * - 内边距：12px
   * - 外边距：顶部16px，右侧20px，底部5px
   */
  build() {
    Column() {
      // ==================== 卡片标题 ====================
      Text('当前分选信息')
        .fontSize(22)                                    // 字体大小（调大到22px）
        .fontWeight(FontWeight.Medium)                   // 字体粗细
        .fontColor(this.getCurrentTheme().textColor)     // 文字颜色（主题色）
        .alignSelf(ItemAlign.Start)                      // 左对齐
        .margin({ bottom: 12 })                          // 底部边距调大

      // ==================== 信息内容区域 ====================
      // 内容一行布局（九个项目，按百分比等分，每项约11.11%）
      Row() {
        this.buildInfoItem('分选速度', () => this.sortSpeed, 11.11)        // 分选速度信息项
        this.buildInfoItem('本批重量', () => this.batchWeight, 11.11)      // 本批重量信息项
        this.buildInfoItem('本批个数', () => this.batchCount, 11.11)       // 本批个数信息项
        this.buildInfoItem('开始时间', () => this.startTime, 11.11)        // 开始时间信息项
        this.buildInfoItem('分选程序', () => this.programName, 11.11)     // 分选程序信息项
        this.buildInfoItem('分选效率', () => this.efficiency, 11.11)      // 分选效率信息项
        this.buildInfoItem('平均重量', () => this.avgWeight, 11.11)       // 平均重量信息项
        this.buildInfoItem('实时产量', () => this.realTimeOutput, 11.11)   // 实时产量信息项
        this.buildInfoItem('间隔速度', () => this.intervalSpeed, 11.11)   // 间隔速度信息项
      }
      .width('100%')                                     // 宽度100%
      .justifyContent(FlexAlign.Start)                   // 左对齐
      .alignItems(VerticalAlign.Center)                  // 垂直居中
    }
    .width('100%')                                       // 宽度100%
    .height('15%')                                       // 信息卡片占15%
    .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)  // 背景色（主题控制背景色或表面色）
    .border({ width: 1, color: this.getCurrentTheme().borderColor })  // 边框（1px主题边框色）
    .borderRadius(12)                                    // 圆角12px
    .padding(12)                                         // 内边距12px
    .margin({ top: 0, left: 0, right: 20, bottom: 5 })  // 外边距（顶部0px，右侧20px，底部5px）
  }

  /**
   * 构建信息条目
   * 
   * 功能说明：
   * - 构建单个信息条目的UI结构
   * - 包含标签和数值两部分
   * - 支持自定义宽度百分比
   * 
   * @param label 信息标签（如：'分选速度'）
   * @param value 信息数值（如：'0 件/分钟'）
   * @param widthPercent 宽度百分比（可选，默认11.11%）
   * 
   * 布局说明：
   * - 使用Column布局垂直排列标签和数值
   * - 标签：12px字体，灰色文字
   * - 数值：13px字体，深色文字，支持省略号
   * - 宽度：按百分比等分（默认11.11%）
   * 
   * 样式说明：
   * - 标签颜色：#888888（灰色）
   * - 数值颜色：#222222（深色）
   * - 数值支持单行显示和省略号
   * - 左对齐排列
   */
  @Builder
  private buildInfoItem(label: string, valueGetter: () => string, widthPercent?: number) {
    Column() {
      // ==================== 信息标签 ====================
      Text(label)
        .fontSize(16)                                    // 字体大小（调大到16px）
        .fontColor('#888888')                            // 标签颜色（灰色）
        .margin({ bottom: 4 })                          // 底部边距调大

      // ==================== 信息数值 ====================
      Text(valueGetter())
        .fontSize(20)                                    // 字体大小（调大到20px）
        .fontWeight(FontWeight.Medium)                   // 字体粗细
        .fontColor('#222222')                            // 数值颜色（深色）
        .maxLines(1)                                     // 最大行数1行
        .textOverflow({ overflow: TextOverflow.Ellipsis })  // 文本溢出省略号
    }
    .width(widthPercent !== undefined ? `${widthPercent}%` : '11.11%')  // 宽度（自定义或默认11.11%）
    .alignItems(HorizontalAlign.Start)                   // 左对齐
  }
}
