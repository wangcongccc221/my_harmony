/**
 * 客户信息查询卡片组件
 * 
 * 功能说明：
 * - 提供客户名称、农场名称、水果品种的选择功能
 * - 使用Select组件进行下拉选择
 * - 支持选择状态的管理和回调
 * 
 * 组件特点：
 * - 三个选择器：客户名称、农场名称、水果品种
 * - 下拉选择：使用Select组件实现选择功能
 * - 主题支持：支持主题切换和样式更新
 * 
 * 使用方式：
 * ```typescript
 * CustomerQueryCard({
 *   customerIndex: this.customerIndex,
 *   farmIndex: this.farmIndex,
 *   fruitIndex: this.fruitIndex,
 *   onCustomerChange: (index: number) => { this.handleCustomerChange(index) },
 *   onFarmChange: (index: number) => { this.handleFarmChange(index) },
 *   onFruitChange: (index: number) => { this.handleFruitChange(index) }
 * })
 * ```
 */

import { BaseComponentHelper } from '../../components/common/BaseComponent'
import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'

/**
 * Select选项接口
 * 
 * 功能说明：
 * - 定义Select组件的选项数据结构
 * - 用于下拉选择框的选项配置
 * - 确保选项数据的类型安全
 * 
 * 属性说明：
 * - value: 选项的值，用于内部逻辑处理
 */
interface SelectOption {
  /** 选项的值（用于内部逻辑） */
  value: string
}

/**
 * 客户信息查询卡片组件结构体
 * 
 * 属性说明：
 * - customerIndex: 客户选择索引
 * - farmIndex: 农场选择索引
 * - fruitIndex: 水果选择索引
 * - onCustomerChange: 客户选择变化回调函数
 * - onFarmChange: 农场选择变化回调函数
 * - onFruitChange: 水果选择变化回调函数
 * 
 * 方法说明：
 * - getCurrentTheme(): 获取当前主题配置
 * - build(): 构建客户信息查询卡片的UI结构
 */
@Component
export struct CustomerQueryCard {
  // ==================== 选择相关属性 ====================
  /** 客户选择索引 */
  @Prop customerIndex: number = 0
  /** 农场选择索引 */
  @Prop farmIndex: number = 0
  /** 水果选择索引 */
  @Prop fruitIndex: number = 0

  // ==================== 事件回调函数 ====================
  /** 客户选择变化回调函数 */
  onCustomerChange?: (index: number) => void
  /** 农场选择变化回调函数 */
  onFarmChange?: (index: number) => void
  /** 水果选择变化回调函数 */
  onFruitChange?: (index: number) => void

  // ==================== 选项数据 ====================
  /** 客户选项数据 */
  private customerOptions: SelectOption[] = [
    { value: '全部客户' },
    { value: '客户A' },
    { value: '客户B' },
    { value: '客户C' }
  ]
  
  /** 农场选项数据 */
  private farmOptions: SelectOption[] = [
    { value: '全部农场' },
    { value: '农场A' },
    { value: '农场B' },
    { value: '农场C' }
  ]
  
  /** 水果选项数据 */
  private fruitOptions: SelectOption[] = [
    { value: '全部水果' },
    { value: '苹果' },
    { value: '橙子' },
    { value: '香蕉' }
  ]

  // ==================== 主题相关属性 ====================
  /** 当前主题样式 */
  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  /** 当前主题类型 */
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: OmniThemeType = OmniThemeManager.getInstance().getCurrentThemeType()
  /** 主题版本号 */
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0
  /** 基础组件助手 */
  private baseComponentHelper = new BaseComponentHelper()

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
    return this.baseComponentHelper.getCurrentTheme(this.consumedTheme)
  }

  /**
   * 组件构建方法
   * 
   * 功能：
   * - 构建客户信息查询卡片的UI结构
   * - 实现三个选择器的布局和交互
   * - 处理选择变化事件
   * 
   * 布局说明：
   * - 使用Column布局垂直排列
   * - 卡片标题：客户信息查询表
   * - 客户名称：标签 + 下拉选择框
   * - 农场名称：标签 + 下拉选择框
   * - 水果品种：标签 + 下拉选择框
   * 
   * 样式说明：
   * - 卡片样式：白色背景，圆角设计，阴影效果
   * - 选择框样式：主题背景色，边框，圆角
   * - 文字样式：主题文字颜色，不同字体大小
   * - 间距设计：合理的组件间距
   */
  build() {
    Column() {
      // ==================== 卡片标题 ====================
      Text('客户信息查询表')
        .fontSize(18)  // 调大到18px
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getCurrentTheme().textColor)
        .margin({ bottom: 4 })
        .alignSelf(ItemAlign.Start)

      // ==================== 客户名称选择 ====================
      Row() {
        Text('客户名称:')
          .fontSize(16)  // 调大到16px
          .fontColor(this.getCurrentTheme().textColor)
          .margin({ right: 8 })
          .alignSelf(ItemAlign.Center)

        Select(this.customerOptions)
          .selected(this.customerIndex)
          .value(this.customerOptions[this.customerIndex].value)
          .font({ size: 16 })  // 调大到16px
          .fontColor(this.getCurrentTheme().textColor)
          .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
          .border({ width: 1, color: this.getCurrentTheme().borderColor })
          .borderRadius(6)
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .height(40)
          .layoutWeight(1)
          .onSelect((index: number) => {
            if (this.onCustomerChange) {
              this.onCustomerChange(index)
            }
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 3 })

      // ==================== 农场名称选择 ====================
      Row() {
        Text('农场名称:')
          .fontSize(16)  // 调大到16px
          .fontColor(this.getCurrentTheme().textColor)
          .margin({ right: 8 })
          .alignSelf(ItemAlign.Center)

        Select(this.farmOptions)
          .selected(this.farmIndex)
          .value(this.farmOptions[this.farmIndex].value)
          .font({ size: 16 })  // 调大到16px
          .fontColor(this.getCurrentTheme().textColor)
          .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
          .border({ width: 1, color: this.getCurrentTheme().borderColor })
          .borderRadius(6)
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .height(40)
          .layoutWeight(1)
          .onSelect((index: number) => {
            if (this.onFarmChange) {
              this.onFarmChange(index)
            }
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 3 })

      // ==================== 水果品种选择 ====================
      Row() {
        Text('水果品种:')
          .fontSize(16)  // 调大到16px
          .fontColor(this.getCurrentTheme().textColor)
          .margin({ right: 8 })
          .alignSelf(ItemAlign.Center)

        Select(this.fruitOptions)
          .selected(this.fruitIndex)
          .value(this.fruitOptions[this.fruitIndex].value)
          .font({ size: 16 })  // 调大到16px
          .fontColor(this.getCurrentTheme().textColor)
          .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
          .border({ width: 1, color: this.getCurrentTheme().borderColor })
          .borderRadius(6)
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .height(40)
          .layoutWeight(1)
          .onSelect((index: number) => {
            if (this.onFruitChange) {
              this.onFruitChange(index)
            }
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(6)
    .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
    .border({ width: 1, color: this.getCurrentTheme().borderColor })
    .borderRadius(4)
    .shadow({ radius: 2, color: 'rgba(0,0,0,0.1)', offsetY: 1 })
    .alignItems(HorizontalAlign.Start)
  }
}
