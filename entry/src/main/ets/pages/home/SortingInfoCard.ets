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
import { t, I18N_VERSION_KEY } from '../../utils/i18n/I18nManager'

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
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0  // 监听语言变化，触发 UI 更新

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
   * - 实现单个卡片内部分隔：标题区域有主题色背景，数据区域在下方
   * - 实现9个关键指标的水平排列
   * - 处理数据的显示和更新
   * 
   * 布局说明：
   * - 使用Column布局垂直排列标题和数据（在同一个卡片内）
   * - 标题区域：'当前分选信息'，主题色背景
   * - 数据区域：9个信息项水平排列，浅色背景
   * - 整体卡片：统一边框、圆角
   * 
   * 样式说明：
   * - 整体卡片：边框、圆角12px
   * - 标题区域：主题色背景，顶部圆角12px
   * - 数据区域：浅色背景
   */
  build() {
    Column() {
      // ==================== 标题区域（高级渐变效果）====================
      Row() {
        Text(t('当前分选信息', '当前分选信息'))
          .fontSize(20)                                      // 增大字体：从16改为20，更突出
          .fontWeight(FontWeight.Bold)                      // 加粗字体：从Medium改为Bold，更醒目
          .fontColor(Color.White)
          .opacity(this.i18nVersion >= 0 ? 1 : 1)
      }
      .width('100%')
      .linearGradient({                                    // 高级效果：颜色渐变 - 增强对比度，更明显
        angle: 135,
        colors: [
          [this.getCurrentTheme().primary, 0],
          [this.getCurrentTheme().primary, 0.5],
          [this.getCurrentTheme().primary + '88', 1]      // 增强渐变对比
        ]
      })
      .backdropBlur(20)                                    // 背景模糊（毛玻璃效果）
      .blur(3)                                             // 内容模糊（增强毛玻璃质感）
      .borderRadius({ topLeft: 12, topRight: 12 })
      .border({                                            // 高级效果：外描边设置 - 精致边框
        width: { bottom: 2 },                              // 加粗底部分隔线：从1改为2，更明显
        color: 'rgba(255, 255, 255, 0.3)'                 // 提高分隔线透明度：从0.2改为0.3，更清晰
      })
      .padding({ left: 16, right: 16, top: 14, bottom: 14 }) // 增加内边距：从10改为14，让标题更突出

      // ==================== 数据区域（在卡片内部，浅色背景）====================
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
    .width('100%')                                       // 宽度100%
      .justifyContent(FlexAlign.Start)                     // 左对齐
      .alignItems(VerticalAlign.Center)                    // 垂直居中
      .opacity(this.i18nVersion >= 0 ? 1 : 1)
      .backgroundColor('#FFFFFF')                          // 纯白背景
      .borderRadius({ bottomLeft: 12, bottomRight: 12 })
      .padding(12)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')                            // 整体纯白背景
    .borderRadius(16)
    .shadow({                                              // 极简风格的悬浮阴影
      radius: 16,
      color: 'rgba(0, 0, 0, 0.05)',
      offsetY: 4
    })
    .margin({ top: 0, bottom: 5 })
    .clip(true)
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
  private buildInfoItem(originalKey: string, valueGetter: () => string, widthPercent?: number) {
    Column() {
      // ==================== 信息标签 ====================
      Text(t(originalKey, originalKey))
        .fontSize(16)                                    // 字体大小（加大到16px）
        .fontWeight(FontWeight.Bold)                    // 字体粗细（加粗）
        .fontColor(this.getCurrentTheme().subTextColor ?? '#888888')  // 标签颜色（主题副文字色或灰色）
        .margin({ bottom: 12 })                         // 底部边距（增加间距，让标签和数据分离）
        .opacity(this.i18nVersion >= 0 ? 1 : 1)          // 引用 i18nVersion 确保语言变化时重新渲染

      // ==================== 信息数值 ====================
      // 将数值和单位分开显示
      Row() {
        // 数值部分（突出显示）
        Text(this.extractValue(valueGetter()))
          .fontSize(20)                                    // 字体大小（加大到20px，突出数值）
          .fontWeight(FontWeight.Bold)                     // 字体粗细（加粗，突出数值）
          .fontColor(this.getCurrentTheme().textColor)     // 数值颜色（主题文字色）
        
        // 单位部分（保持原样）
        Text(this.extractUnit(valueGetter()))
          .fontSize(16)                                    // 字体大小（保持16px）
          .fontWeight(FontWeight.Normal)                   // 字体粗细（正常）
          .fontColor(this.getCurrentTheme().subTextColor ?? '#888888')  // 单位颜色（副文字色）
          .margin({ left: 2 })                            // 与数值的间距
      }
      .alignItems(VerticalAlign.Bottom)                   // 底部对齐
    }
    .width(widthPercent !== undefined ? `${widthPercent}%` : '11.11%')  // 宽度（自定义或默认11.11%）
    .alignItems(HorizontalAlign.Start)                   // 左对齐
  }

  /**
   * 提取数值部分（去掉单位）
   * 
   * 功能说明：
   * - 从完整字符串中提取数值部分
   * - 支持各种单位格式和时间格式
   * 
   * 参数说明：
   * - fullText: 包含数值和单位的完整字符串
   * 
   * 返回值：
   * - 只包含数值的字符串
   */
  private extractValue(fullText: string): string {
    if (!fullText || fullText === '--:--:--' || fullText === '未选择') {
      return fullText
    }
    
    // 处理时间格式 (HH:MM:SS)
    if (fullText.match(/^\d{2}:\d{2}:\d{2}$/)) {
      return fullText // 时间格式整体显示，不分离
    }
    
    // 匹配数值部分（包括小数点）
    const match = fullText.match(/^([\d.]+)/)
    return match ? match[1] : fullText
  }

  /**
   * 提取单位部分
   * 
   * 功能说明：
   * - 从完整字符串中提取单位部分
   * - 支持各种单位格式和时间格式
   * 
   * 参数说明：
   * - fullText: 包含数值和单位的完整字符串
   * 
   * 返回值：
   * - 只包含单位的字符串
   */
  private extractUnit(fullText: string): string {
    if (!fullText || fullText === '--:--:--' || fullText === '未选择') {
      return ''
    }
    
    // 处理时间格式 (HH:MM:SS) - 时间格式没有单位部分
    if (fullText.match(/^\d{2}:\d{2}:\d{2}$/)) {
      return '' // 时间格式没有单位
    }
    
    // 匹配单位部分（数值后面的所有内容）
    const match = fullText.match(/^[\d.]+(.+)$/)
    return match ? match[1] : ''
  }
}
