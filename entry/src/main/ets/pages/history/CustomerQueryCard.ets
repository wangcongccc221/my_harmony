/**
 * 客户信息查询卡片组件
 * 
 * 功能说明：
 * - 提供客户名称、农场名称、水果品种的输入查询功能
 * - 使用TextInput组件进行输入查询
 * - 支持输入状态的管理和回调
 * 
 * 组件特点：
 * - 三个输入框：客户名称、农场名称、水果品种
 * - 文本输入：使用TextInput组件实现输入功能
 * - 主题支持：支持主题切换和样式更新
 * 
 * 使用方式：
 * ```typescript
 * CustomerQueryCard({
 *   customerName: this.customerName,
 *   farmName: this.farmName,
 *   fruitName: this.fruitName,
 *   onCustomerChange: (value: string) => { this.handleCustomerChange(value) },
 *   onFarmChange: (value: string) => { this.handleFarmChange(value) },
 *   onFruitChange: (value: string) => { this.handleFruitChange(value) }
 * })
 * ```
 */

import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme as resolveTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { AppleDesignStyle } from '../../utils/theme/AppleDesignStyle'

/**
 * 客户信息查询卡片组件结构体
 * 
 * 属性说明：
 * - customerName: 客户名称输入值
 * - farmName: 农场名称输入值
 * - fruitName: 水果品种输入值
 * - onCustomerChange: 客户名称输入变化回调函数
 * - onFarmChange: 农场名称输入变化回调函数
 * - onFruitChange: 水果品种输入变化回调函数
 * 
 * 方法说明：
 * - getCurrentTheme(): 获取当前主题配置
 * - build(): 构建客户信息查询卡片的UI结构
 */
@Component
export struct CustomerQueryCard {
  // ==================== 输入相关属性 ====================
  /** 客户名称输入值 */
  @Prop customerName: string = ''
  /** 农场名称输入值 */
  @Prop farmName: string = ''
  /** 水果品种输入值 */
  @Prop fruitName: string = ''
  
  // ==================== 内部状态（用于双向绑定）====================
  @State private customerNameValue: string = ''
  @State private farmNameValue: string = ''
  @State private fruitNameValue: string = ''

  // ==================== 事件回调函数 ====================
  /** 客户名称输入变化回调函数 */
  onCustomerChange?: (value: string) => void
  /** 农场名称输入变化回调函数 */
  onFarmChange?: (value: string) => void
  /** 水果品种输入变化回调函数 */
  onFruitChange?: (value: string) => void

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
   * 组件构建方法
   * 
   * 功能：
   * - 构建客户信息查询卡片的UI结构
   * - 实现三个输入框的布局和交互
   * - 处理输入变化事件
   * 
   * 布局说明：
   * - 使用Column布局垂直排列
   * - 卡片标题：客户信息查询表
   * - 客户名称：标签 + 文本输入框
   * - 农场名称：标签 + 文本输入框
   * - 水果品种：标签 + 文本输入框
   * 
   * 样式说明：
   * - 卡片样式：白色背景，圆角设计，阴影效果
   * - 输入框样式：主题背景色，边框，圆角
   * - 文字样式：主题文字颜色，不同字体大小
   * - 间距设计：合理的组件间距
   */
  aboutToRender() {
    // 同步外部传入的值到内部状态
    if (this.customerNameValue !== this.customerName) {
      this.customerNameValue = this.customerName
    }
    if (this.farmNameValue !== this.farmName) {
      this.farmNameValue = this.farmName
    }
    if (this.fruitNameValue !== this.fruitName) {
      this.fruitNameValue = this.fruitName
    }
  }
  
  build() {
    Column() {
      // ==================== 卡片标题 ====================
      Text('客户信息查询表')
        .fontSize(18)  // 标题字体
        .fontWeight(FontWeight.Medium) // Apple风格：Medium而非Bold
        .fontColor(this.getCurrentTheme().textColor)
        .margin({ bottom: AppleDesignStyle.SPACING_XS }) // Apple风格：统一间距
        .alignSelf(ItemAlign.Start)

      // ==================== 客户名称输入 ====================
      Row() {
        Text('客户名称:')
          .fontSize(16)  // 调大到16px
          .fontColor(this.getCurrentTheme().textColor)
          .margin({ right: 8 })
          .alignSelf(ItemAlign.Center)

        TextInput({ placeholder: '请输入客户名称', text: this.customerNameValue })
          .fontSize(16)  // 输入框字体
          .fontColor(this.getCurrentTheme().textColor)
          .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
          .border({ width: AppleDesignStyle.BORDER_WIDTH_THIN, color: this.getCurrentTheme().borderColor }) // Apple风格：细边框
          .borderRadius(AppleDesignStyle.BORDER_RADIUS_SMALL) // Apple风格：小圆角
          .padding({ left: AppleDesignStyle.SPACING_SMALL, right: AppleDesignStyle.SPACING_SMALL, top: AppleDesignStyle.SPACING_XS, bottom: AppleDesignStyle.SPACING_XS }) // Apple风格：统一间距
          .height(40)
          .layoutWeight(1)
          .onChange((value: string) => {
            this.customerNameValue = value
            if (this.onCustomerChange) {
              this.onCustomerChange(value)
            }
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 3 })

      // ==================== 农场名称输入 ====================
      Row() {
        Text('农场名称:')
          .fontSize(16)  // 调大到16px
          .fontColor(this.getCurrentTheme().textColor)
          .margin({ right: 8 })
          .alignSelf(ItemAlign.Center)

        TextInput({ placeholder: '请输入农场名称', text: this.farmNameValue })
          .fontSize(16)  // 调大到16px
          .fontColor(this.getCurrentTheme().textColor)
          .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
          .border({ width: 1, color: this.getCurrentTheme().borderColor })
          .borderRadius(6)
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .height(40)
          .layoutWeight(1)
          .onChange((value: string) => {
            this.farmNameValue = value
            if (this.onFarmChange) {
              this.onFarmChange(value)
            }
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 3 })

      // ==================== 水果品种输入 ====================
      Row() {
        Text('水果品种:')
          .fontSize(16)  // 调大到16px
          .fontColor(this.getCurrentTheme().textColor)
          .margin({ right: 8 })
          .alignSelf(ItemAlign.Center)

        TextInput({ placeholder: '请输入水果品种', text: this.fruitNameValue })
          .fontSize(16)  // 调大到16px
          .fontColor(this.getCurrentTheme().textColor)
          .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
          .border({ width: 1, color: this.getCurrentTheme().borderColor })
          .borderRadius(6)
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .height(40)
          .layoutWeight(1)
          .onChange((value: string) => {
            this.fruitNameValue = value
            if (this.onFruitChange) {
              this.onFruitChange(value)
            }
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
