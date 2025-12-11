/**
 * 日期条件查询卡片组件
 * 
 * 功能说明：
 * - 提供开始日期和结束日期的选择功能
 * - 使用DatePickerHelper进行日期选择
 * - 支持日期格式化和显示
 * 
 * 组件特点：
 * - 只读输入框：用户不能直接输入，只能通过日期选择器选择
 * - 日期图标：点击图标触发日期选择器
 * - 主题支持：支持主题切换和样式更新
 * 
 * 使用方式：
 * ```typescript
 * DateQueryCard({
 *   startDate: this.startDate,
 *   endDate: this.endDate,
 *   selectedStartDate: this.selectedStartDate,
 *   selectedEndDate: this.selectedEndDate,
 *   onStartDateChange: (date: string) => { this.handleStartDateChange(date) },
 *   onEndDateChange: (date: string) => { this.handleEndDateChange(date) }
 * })
 * ```
 */

import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme as resolveTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { AppleDesignStyle } from '../../utils/theme/AppleDesignStyle'
import { DatePickerHelper } from '../../utils/helpers/DatePickerHelper'

/**
 * 日期条件查询卡片组件结构体
 * 
 * 属性说明：
 * - startDate: 开始日期字符串
 * - endDate: 结束日期字符串
 * - selectedStartDate: 选中的开始日期对象
 * - selectedEndDate: 选中的结束日期对象
 * - onStartDateChange: 开始日期变化回调函数
 * - onEndDateChange: 结束日期变化回调函数
 * 
 * 方法说明：
 * - getCurrentTheme(): 获取当前主题配置
 * - showStartDatePicker(): 显示开始日期选择器
 * - showEndDatePicker(): 显示结束日期选择器
 * - build(): 构建日期查询卡片的UI结构
 */
@Component
export struct DateQueryCard {
  // ==================== 日期相关属性 ====================
  /** 开始日期字符串 */
  @Prop startDate: string = ''
  /** 结束日期字符串 */
  @Prop endDate: string = ''
  /** 选中的开始日期对象 */
  @Prop selectedStartDate: Date = new Date()
  /** 选中的结束日期对象 */
  @Prop selectedEndDate: Date = new Date()

  // ==================== 事件回调函数 ====================
  /** 开始日期变化回调函数 */
  onStartDateChange?: (date: string) => void
  /** 结束日期变化回调函数 */
  onEndDateChange?: (date: string) => void

  // ==================== 主题相关属性 ====================
  /** 当前主题样式 */
  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  /** 当前主题类型 */
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: OmniThemeType = OmniThemeManager.getInstance().getCurrentThemeType()
  /** 主题版本号 */
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0

  /**
   * 获取当前主题配置
   * 
   * 功能说明：
   * - 从基础组件助手获取当前主题样式
   * - 用于组件样式配置
   * - 支持主题切换时的样式更新
   * 
   * @returns 当前主题的扩展样式对象
   */
  getCurrentTheme(): ExtendedOmniThemeStyle {
    return resolveTheme(this.consumedTheme)
  }

  /**
   * 显示开始日期选择器
   * 
   * 功能说明：
   * - 使用DatePickerHelper显示日期选择器
   * - 处理日期选择结果
   * - 更新开始日期状态
   * - 触发开始日期变化回调
   * 
   * 使用场景：
   * - 用户点击开始日期输入框的日期图标时
   * - 需要选择开始日期时
   */
  private async showStartDatePicker() {
    try {
      const result = await DatePickerHelper.showDatePicker("选择开始日期", this.selectedStartDate)
      if (result) {
        this.startDate = result
        this.selectedStartDate = DatePickerHelper.parseDate(result)
        console.info("选择的开始日期:", result)
        
        // 触发开始日期变化回调
        if (this.onStartDateChange) {
          this.onStartDateChange(result)
        }
      }
    } catch (error) {
      console.error("开始日期选择失败:", error)
    }
  }

  /**
   * 显示结束日期选择器
   * 
   * 功能说明：
   * - 使用DatePickerHelper显示日期选择器
   * - 处理日期选择结果
   * - 更新结束日期状态
   * - 触发结束日期变化回调
   * 
   * 使用场景：
   * - 用户点击结束日期输入框的日期图标时
   * - 需要选择结束日期时
   */
  private async showEndDatePicker() {
    try {
      const result = await DatePickerHelper.showDatePicker("选择结束日期", this.selectedEndDate)
      if (result) {
        this.endDate = result
        this.selectedEndDate = DatePickerHelper.parseDate(result)
        console.info("选择的结束日期:", result)
        
        // 触发结束日期变化回调
        if (this.onEndDateChange) {
          this.onEndDateChange(result)
        }
      }
    } catch (error) {
      console.error("结束日期选择失败:", error)
    }
  }

  /**
   * 组件构建方法
   * 
   * 功能：
   * - 构建日期条件查询卡片的UI结构
   * - 实现开始日期和结束日期的选择功能
   * - 处理日期选择器的事件
   * 
   * 布局说明：
   * - 使用Column布局垂直排列
   * - 卡片标题：日期条件查询
   * - 开始日期：标签 + 只读输入框 + 日期图标
   * - 结束日期：标签 + 只读输入框 + 日期图标
   * 
   * 样式说明：
   * - 卡片样式：白色背景，圆角设计，阴影效果
   * - 输入框样式：只读模式，主题背景色，边框
   * - 图标样式：日期图标，点击触发日期选择器
   * - 文字样式：主题文字颜色，不同字体大小
   */
  build() {
    Column() {
      // ==================== 卡片标题 ====================
      Text('日期条件查询')
        .fontSize(18)  // 标题字体
        .fontWeight(FontWeight.Medium) // Apple风格：Medium而非Bold
        .fontColor(this.getCurrentTheme().textColor)
        .margin({ bottom: AppleDesignStyle.SPACING_XS }) // Apple风格：统一间距
        .alignSelf(ItemAlign.Start)

      // ==================== 开始日期 ====================
      Row() {
        Text('开始日期:')
          .fontSize(16)  // 调大到16px
          .fontColor(this.getCurrentTheme().textColor)
          .margin({ right: 8 })
          .alignSelf(ItemAlign.Center)

        TextInput({ text: this.startDate, placeholder: '请选择开始日期' })
          .fontSize(16)  // 输入框字体
          .fontColor(this.getCurrentTheme().textColor)
          .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
          .border({ width: AppleDesignStyle.BORDER_WIDTH_THIN, color: this.getCurrentTheme().borderColor }) // Apple风格：细边框
          .borderRadius(AppleDesignStyle.BORDER_RADIUS_SMALL) // Apple风格：小圆角
          .padding({ left: AppleDesignStyle.SPACING_SMALL, right: 30, top: AppleDesignStyle.SPACING_XS, bottom: AppleDesignStyle.SPACING_XS }) // Apple风格：统一间距
          .layoutWeight(1)
          .enabled(false) // 设置为只读

        Image($r('app.media.Data'))
          .width(16)
          .height(16)
          .margin({ left: -26, right: 6 })
          .alignSelf(ItemAlign.Center)
          .onClick(() => {
            this.showStartDatePicker()
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 4 })

      // ==================== 结束日期 ====================
      Row() {
        Text('结束日期:')
          .fontSize(16)  // 调大到16px
          .fontColor(this.getCurrentTheme().textColor)
          .margin({ right: 8 })
          .alignSelf(ItemAlign.Center)

        TextInput({ text: this.endDate, placeholder: '请选择结束日期' })
          .fontSize(16)  // 输入框字体
          .fontColor(this.getCurrentTheme().textColor)
          .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
          .border({ width: AppleDesignStyle.BORDER_WIDTH_THIN, color: this.getCurrentTheme().borderColor }) // Apple风格：细边框
          .borderRadius(AppleDesignStyle.BORDER_RADIUS_SMALL) // Apple风格：小圆角
          .padding({ left: AppleDesignStyle.SPACING_SMALL, right: 30, top: AppleDesignStyle.SPACING_XS, bottom: AppleDesignStyle.SPACING_XS }) // Apple风格：统一间距
          .layoutWeight(1)
          .enabled(false) // 设置为只读

        Image($r('app.media.Data'))
          .width(16)
          .height(16)
          .margin({ left: -26, right: 6 })
          .alignSelf(ItemAlign.Center)
          .onClick(() => {
            this.showEndDatePicker()
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(AppleDesignStyle.SPACING_SMALL) // Apple风格：统一间距
    .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
    .border({ width: AppleDesignStyle.BORDER_WIDTH_THIN, color: this.getCurrentTheme().borderColor }) // Apple风格：细边框
    .borderRadius(AppleDesignStyle.BORDER_RADIUS_SMALL) // Apple风格：小圆角
    .shadow(AppleDesignStyle.getShadowSmall()) // Apple风格：柔和阴影
    .alignItems(HorizontalAlign.Start)
  }
}
