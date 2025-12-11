/**
 * 等级页面左侧控制面板组件
 * 
 * 功能说明：
 * - 显示水果选择、出口报警、分选标准、计算单位、装箱量等设置
 * - 在Level页面中作为左侧控制区域显示
 * - 提供用户交互界面，支持各种设置选项的配置
 * - 实现设置项的状态管理和事件处理
 * 
 * 包含设置项：
 * - 水果选择：支持苹果、香蕉、橙子、葡萄四种水果类型
 * - 出口报警：设置出口阈值，支持数值输入
 * - 分选标准：支持尺寸、重量、直径、面积、体积等标准选择
 * - 计算单位：支持克（重量）和个（数量）两种单位
 * - 装箱量设置：支持两个装箱重量的设置和自动生成
 * 
 * 组件特点：
 * - 响应式设计：支持主题切换和样式更新
 * - 事件驱动：通过回调函数处理用户交互
 * - 状态同步：与父组件保持状态同步
 * - 类型安全：使用TypeScript接口确保类型安全
 * 
 * 使用方式：
 * ```typescript
 * LevelControlPanel({
 *   selectedFruit: this.selectedFruit,
 *   outletThreshold: this.outletThreshold,
 *   selectedStandards: this.selectedStandards,
 *   selectedUnit: this.selectedUnit,
 *   packingWeight1: this.packingWeight1,
 *   packingWeight2: this.packingWeight2,
 *   onFruitChange: (fruit: string) => { this.handleFruitChange(fruit) },
 *   onOutletThresholdChange: (threshold: number) => { this.handleOutletThresholdChange(threshold) },
 *   onStandardsChange: (standards: string[]) => { this.handleStandardsChange(standards) },
 *   onUnitChange: (unit: string) => { this.handleUnitChange(unit) },
 *   onPackingWeight1Change: (weight: number) => { this.handlePackingWeight1Change(weight) },
 *   onPackingWeight2Change: (weight: number) => { this.handlePackingWeight2Change(weight) },
 *   onAutoGenerate: () => { this.handleAutoGenerate() }
 * })
 * ```
 * 
 * 布局说明：
 * - 使用Column布局垂直排列各个设置项
 * - 每个设置项使用独立的卡片容器
 * - 支持滚动显示，适应不同屏幕尺寸
 * - 左侧面板宽度：20%
 */

import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme as resolveTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY, useOmniTheme } from '../../utils/theme/useOmniTheme'
import { AppleDesignStyle } from '../../utils/theme/AppleDesignStyle'
import { FRUIT_TYPES, SORTING_STANDARDS, UNIT_OPTIONS } from './LevelConstants'
import { t } from '../../utils/i18n/I18nManager'

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
 * 等级页面左侧控制面板组件结构体
 * 
 * 属性说明：
 * - selectedFruit: 选中的水果类型，默认第一个水果
 * - outletThreshold: 出口阈值，默认0
 * - selectedStandards: 选中的分选标准数组，默认空数组
 * - selectedUnit: 选中的计算单位，默认第一个单位
 * - packingWeight1: 包装重量1，默认0
 * - packingWeight2: 包装重量2，默认0
 * - onFruitChange: 水果类型变化回调函数
 * - onOutletThresholdChange: 出口阈值变化回调函数
 * - onStandardsChange: 分选标准变化回调函数
 * - onUnitChange: 单位变化回调函数
 * - onPackingWeight1Change: 包装重量1变化回调函数
 * - onPackingWeight2Change: 包装重量2变化回调函数
 * - onAutoGenerate: 自动生成回调函数
 * - consumedTheme: 当前主题样式
 * - consumedThemeType: 当前主题类型
 * - themeVersion: 主题版本号
 * 
 * 方法说明：
 * - getCurrentTheme(): 获取当前主题配置
 * - build(): 构建控制面板的UI结构
 */
@Component
export struct LevelControlPanel {
  // ==================== 设置项属性 ====================
  /**
   * 选中的水果类型
   * 
   * 功能说明：
   * - 存储当前选中的水果类型
   * - 默认值为第一个水果类型
   * - 支持苹果、香蕉、橙子、葡萄四种类型
   */
  @Prop selectedFruit: string = FRUIT_TYPES[0].value
  
  /**
   * 出口阈值
   * 
   * 功能说明：
   * - 存储出口报警的阈值设置
   * - 默认值为0
   * - 支持数值输入和调整
   */
  @Prop outletThreshold: number = 0
  
  /**
   * 选中的分选标准数组
   * 
   * 功能说明：
   * - 存储当前选中的分选标准
   * - 默认值为空数组
   * - 支持多选，包括尺寸、重量、直径、面积、体积等标准
   */
  @Prop selectedStandards: string[] = []
  
  /**
   * 选中的计算单位
   * 
   * 功能说明：
   * - 存储当前选中的计算单位
   * - 默认值为第一个单位
   * - 支持克（重量）和个（数量）两种单位
   */
  @Prop selectedUnit: string = UNIT_OPTIONS[0].value
  
  /**
   * 包装重量1
   * 
   * 功能说明：
   * - 存储第一个包装重量的设置
   * - 默认值为0
   * - 支持数值输入和调整
   */
  @Prop packingWeight1: number = 0
  
  /**
   * 包装重量2
   * 
   * 功能说明：
   * - 存储第二个包装重量的设置
   * - 默认值为0
   * - 支持数值输入和调整
   */
  @Prop packingWeight2: number = 0

  // ==================== 事件回调函数 ====================
  /**
   * 水果类型变化回调函数
   * 
   * 功能说明：
   * - 当用户选择水果类型时触发
   * - 传递选中的水果类型给父组件
   * - 用于处理水果类型变化逻辑
   */
  onFruitChange?: (fruit: string) => void
  
  /**
   * 出口阈值变化回调函数
   * 
   * 功能说明：
   * - 当用户设置出口阈值时触发
   * - 传递阈值数值给父组件
   * - 用于处理出口阈值变化逻辑
   */
  onOutletThresholdChange?: (threshold: number) => void
  
  /**
   * 分选标准变化回调函数
   * 
   * 功能说明：
   * - 当用户选择分选标准时触发
   * - 传递选中的标准数组给父组件
   * - 用于处理分选标准变化逻辑
   */
  onStandardsChange?: (standards: string[]) => void
  
  /**
   * 单位变化回调函数
   * 
   * 功能说明：
   * - 当用户选择计算单位时触发
   * - 传递选中的单位给父组件
   * - 用于处理单位变化逻辑
   */
  onUnitChange?: (unit: string) => void
  
  /**
   * 包装重量1变化回调函数
   * 
   * 功能说明：
   * - 当用户设置包装重量1时触发
   * - 传递重量数值给父组件
   * - 用于处理包装重量1变化逻辑
   */
  onPackingWeight1Change?: (weight: number) => void
  
  /**
   * 包装重量2变化回调函数
   * 
   * 功能说明：
   * - 当用户设置包装重量2时触发
   * - 传递重量数值给父组件
   * - 用于处理包装重量2变化逻辑
   */
  onPackingWeight2Change?: (weight: number) => void
  
  /**
   * 自动生成回调函数
   * 
   * 功能说明：
   * - 当用户点击自动生成按钮时触发
   * - 用于处理自动生成包装重量逻辑
   */
  onAutoGenerate?: () => void

  // ==================== 主题相关属性 ====================
  /**
   * 当前主题样式
   * 
   * 功能说明：
   * - 存储当前主题的样式配置
   * - 使用@StorageLink实现主题响应式更新
   * - 默认值为当前主题管理器的主题
   */
  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  
  /**
   * 当前主题类型
   * 
   * 功能说明：
   * - 存储当前主题的类型
   * - 使用@StorageLink实现主题响应式更新
   * - 默认值为当前主题管理器的主题类型
   */
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: OmniThemeType = OmniThemeManager.getInstance().getCurrentThemeType()
  
  /**
   * 主题版本号
   * 
   * 功能说明：
   * - 存储主题的版本号
   * - 用于主题更新时的版本控制
   * - 默认值为0
   */
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0
  
  /**
   * 获取当前主题配置
   * 
   * 功能说明：
   * - 通过统一的主题工具获取当前主题样式
   * - 用于组件样式配置
   * - 支持主题切换时的样式更新
   * 
   * @returns 当前主题的扩展样式对象
   */
  getCurrentTheme(): ExtendedOmniThemeStyle {
    const __version: number = this.themeVersion
    return resolveTheme(this.consumedTheme)
  }

  /**
   * 组件构建方法
   * 
   * 功能：
   * - 构建等级页面左侧控制面板的UI结构
   * - 实现各种设置项的布局和交互
   * - 处理用户输入和选择事件
   * - 支持主题切换和样式更新
   * 
   * 布局说明：
   * - 使用Column布局垂直排列各个设置卡片
   * - 每个设置项使用独立的卡片容器
   * - 支持滚动显示，适应不同屏幕尺寸
   * 
   * 包含设置项：
   * - 水果选择：下拉框选择水果类型
   * - 出口报警：数值输入框设置阈值
   * - 分选标准：多选框选择分选标准
   * - 计算单位：下拉框选择计算单位
   * - 装箱量设置：两个数值输入框和自动生成按钮
   * 
   * 样式说明：
   * - 卡片样式：白色背景，圆角设计，阴影效果
   * - 输入框样式：主题背景色，边框，圆角
   * - 按钮样式：主题背景色，圆角，悬停效果
   * - 文字样式：主题文字颜色，不同字体大小
   */
  build() {
    Column() {
      // ==================== 水果表单卡片 ====================
      Column() {
        Text(t('水果', '水果'))
          .fontSize(20) // 合理字体
          .fontWeight(FontWeight.Medium) // Apple风格：Medium而非Bold
          .fontColor(this.getCurrentTheme().textColor)
          .margin({ top: 0, bottom: 10 }) // 合理间距
          .alignSelf(ItemAlign.Start)

        // 种类选择行
        Row() {
          Text(t('种类:', '种类:'))
            .fontSize(18)
            .fontColor(this.getCurrentTheme().textColor)
            .margin({ right: 8 })

          // 下拉框
          Select(FRUIT_TYPES.map(fruit => ({ value: fruit.value } as SelectOption)))
            .selected(FRUIT_TYPES.findIndex(fruit => fruit.value === this.selectedFruit))
            .font({ size: 18 })
            .fontColor(this.getCurrentTheme().textColor)
            .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
            .border({ width: AppleDesignStyle.BORDER_WIDTH_THIN, color: this.getCurrentTheme().borderColor }) // 恢复细边框
            .borderRadius(AppleDesignStyle.BORDER_RADIUS_SMALL) // 合理圆角(8px)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .layoutWeight(1)
            .constraintSize({ minWidth: 120, maxWidth: 220 })
            .height(36)
            .onSelect((index: number, value: string) => {
              if (this.onFruitChange) {
                this.onFruitChange(value)
              }
            })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .margin({ bottom: 3 })
      }
      .width('100%')
      .padding(AppleDesignStyle.CARD_PADDING_SMALL) // 合理内边距
      .backgroundColor(this.getCurrentTheme().surfaceColor)
      .border({ width: AppleDesignStyle.BORDER_WIDTH_THIN, color: this.getCurrentTheme().borderColor }) // 恢复细边框
      .borderRadius(AppleDesignStyle.BORDER_RADIUS_SMALL) // 合理圆角(8px)
      .shadow(AppleDesignStyle.getShadowSmall()) // 柔和阴影
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: AppleDesignStyle.CARD_MARGIN_SMALL }) // 合理间距

      // 出口报警卡片
      Column() {
        Text(t('出口报警', '出口报警'))
          .fontSize(20)  // 合理字体
          .fontWeight(FontWeight.Medium) // Apple风格：Medium而非Bold
          .fontColor(this.getCurrentTheme().textColor)
          .margin({ top: 0, bottom: 8 }) // 合理间距
          .alignSelf(ItemAlign.Start)

        // 出口阀值输入行
        Row() {
          Text(t('出口阀值:', '出口阀值:'))
            .fontSize(18)  // 标签字体优化到18px
            .fontColor(this.getCurrentTheme().textColor)
            .margin({ right: 2 })

          // 数字输入框（0-100）
          TextInput({ text: this.outletThreshold.toString() })
            .type(InputType.Number)
            .fontSize(16)  // 输入框字体优化到16px
            .fontColor(this.getCurrentTheme().textColor)
            .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
            .border({ width: AppleDesignStyle.BORDER_WIDTH_THIN, color: this.getCurrentTheme().borderColor }) // 恢复细边框
            .borderRadius(AppleDesignStyle.BORDER_RADIUS_SMALL) // 合理圆角(8px)
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .layoutWeight(1)
            .constraintSize({ minWidth: 60, maxWidth: 140 })
            .height(30)
            .onChange((val: string) => {
              let num = Number(val)
              if (isNaN(num)) {
                num = 0
              }
              if (num < 0) num = 0
              if (num > 100) num = 100
              if (this.onOutletThresholdChange) {
                this.onOutletThresholdChange(num)
              }
            })

          // %符号
          Text('%')
            .fontSize(18)  // 符号字体优化到18px
            .fontColor(this.getCurrentTheme().textColor)
            .margin({ left: 4 })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .margin({ bottom: 3 })
      }
      .width('100%')
      .padding(AppleDesignStyle.CARD_PADDING_SMALL) // 合理内边距
      .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
      .border({ width: AppleDesignStyle.BORDER_WIDTH_THIN, color: this.getCurrentTheme().borderColor }) // 恢复细边框
      .borderRadius(AppleDesignStyle.BORDER_RADIUS_SMALL) // 合理圆角(8px)
      .shadow(AppleDesignStyle.getShadowSmall()) // 柔和阴影
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: AppleDesignStyle.CARD_MARGIN_SMALL }) // 合理间距

      // 分选标准卡片
      Column() {
        Text(t('分选标准', '分选标准'))
          .fontSize(20)  // 标题字体优化到20px
          .fontWeight(FontWeight.Medium) // Apple风格：Medium而非Bold
          .fontColor(this.getCurrentTheme().textColor)
          .margin({ top: 0, bottom: 6 })
          .alignSelf(ItemAlign.Start)

        // 分选标准选项
        Column() {
          // 第一行：尺寸和重量
          Row() {
            // 尺寸复选框
            Row() {
              Checkbox({ name: '尺寸', group: 'standard' })
                .select(this.selectedStandards.includes('尺寸'))
                .width(14)
                .height(14)
                .margin({ right: 4 })
                .onChange((isChecked: boolean) => {
                  this.updateStandards('尺寸', isChecked)
                })

              Text(t('尺寸', '尺寸'))
                .fontSize(22)  // 复选框标签字体调大到22px
                .fontColor(this.getCurrentTheme().textColor)
            }
            .layoutWeight(1)
            .alignItems(VerticalAlign.Center)

            // 重量复选框
            Row() {
              Checkbox({ name: '重量', group: 'standard' })
                .select(this.selectedStandards.includes('重量'))
                .width(14)
                .height(14)
                .margin({ right: 4 })
                .onChange((isChecked: boolean) => {
                  this.updateStandards('重量', isChecked)
                })

              Text(t('重量', '重量'))
                .fontSize(22)  // 复选框标签字体调大到22px
                .fontColor(this.getCurrentTheme().textColor)
            }
            .layoutWeight(1)
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .margin({ bottom: 3 })

          // 第二行：直径、面积、体积
          Row() {
            // 直径复选框
            Row() {
              Checkbox({ name: '直径', group: 'standard' })
                .select(this.selectedStandards.includes('直径'))
                .width(14)
                .height(14)
                .margin({ right: 4 })
                .onChange((isChecked: boolean) => {
                  this.updateStandards('直径', isChecked)
                })

              Text(t('直径', '直径'))
                .fontSize(22)  // 复选框标签字体调大到22px
                .fontColor(this.getCurrentTheme().textColor)
            }
            .layoutWeight(1)
            .alignItems(VerticalAlign.Center)

            // 面积复选框
            Row() {
              Checkbox({ name: '面积', group: 'standard' })
                .select(this.selectedStandards.includes('面积'))
                .width(14)
                .height(14)
                .margin({ right: 4 })
                .onChange((isChecked: boolean) => {
                  this.updateStandards('面积', isChecked)
                })

              Text(t('面积', '面积'))
                .fontSize(22)  // 复选框标签字体调大到22px
                .fontColor(this.getCurrentTheme().textColor)
            }
            .layoutWeight(1)
            .alignItems(VerticalAlign.Center)

            // 体积复选框
            Row() {
              Checkbox({ name: '体积', group: 'standard' })
                .select(this.selectedStandards.includes('体积'))
                .width(14)
                .height(14)
                .margin({ right: 4 })
                .onChange((isChecked: boolean) => {
                  this.updateStandards('体积', isChecked)
                })

              Text(t('体积', '体积'))
                .fontSize(22)  // 复选框标签字体调大到22px
                .fontColor(this.getCurrentTheme().textColor)
            }
            .layoutWeight(1)
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding(AppleDesignStyle.CARD_PADDING_SMALL) // 合理内边距
      .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
      .border({ width: AppleDesignStyle.BORDER_WIDTH_THIN, color: this.getCurrentTheme().borderColor }) // 恢复细边框
      .borderRadius(AppleDesignStyle.BORDER_RADIUS_SMALL) // 合理圆角(8px)
      .shadow(AppleDesignStyle.getShadowSmall()) // 柔和阴影
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: AppleDesignStyle.CARD_MARGIN_SMALL }) // 合理间距

      // 计算每箱单位卡片
      Column() {
        Text(t('计算每箱单位', '计算每箱单位'))
          .fontSize(20)  // 标题字体优化到20px
          .fontWeight(FontWeight.Medium) // Apple风格：Medium而非Bold
          .fontColor(this.getCurrentTheme().textColor)
          .margin({ top: 0, bottom: 4 })
          .alignSelf(ItemAlign.Start)

        // 单位选择单选按钮（横向排布）
        Row() {
          // 克选项
          Row() {
            Radio({ value: 'gram', group: 'unit' })
              .checked(this.selectedUnit === 'gram')
              .onChange((isChecked: boolean) => {
                if (isChecked && this.onUnitChange) {
                  this.onUnitChange('gram')
                }
              })
            Text(t('克', '克'))
              .fontSize(22)  // 单选按钮标签字体调大到22px
              .fontColor(this.getCurrentTheme().textColor)
              .margin({ left: 4 })
          }
          .alignItems(VerticalAlign.Center)
          .margin({ right: 16 })

          // 个选项
          Row() {
            Radio({ value: 'piece', group: 'unit' })
              .checked(this.selectedUnit === 'piece')
              .onChange((isChecked: boolean) => {
                if (isChecked && this.onUnitChange) {
                  this.onUnitChange('piece')
                }
              })
            Text(t('个', '个'))
              .fontSize(22)  // 单选按钮标签字体调大到22px
              .fontColor(this.getCurrentTheme().textColor)
              .margin({ left: 4 })
          }
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)
      }
      .width('100%')
      .padding(AppleDesignStyle.CARD_PADDING_SMALL) // 合理内边距
      .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
      .border({ width: AppleDesignStyle.BORDER_WIDTH_THIN, color: this.getCurrentTheme().borderColor }) // 恢复细边框
      .borderRadius(AppleDesignStyle.BORDER_RADIUS_SMALL) // 合理圆角(8px)
      .shadow(AppleDesignStyle.getShadowSmall()) // 柔和阴影
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: AppleDesignStyle.CARD_MARGIN_SMALL }) // 合理间距

      // 装箱量卡片
      Column() {
        Text(t('装箱量', '装箱量'))
          .fontSize(22)  // 标题字体增大到22px，与其它标题一致
          .fontWeight(FontWeight.Medium) // Apple风格：Medium而非Bold
          .fontColor(this.getCurrentTheme().textColor)
          .margin({ top: 0, bottom: 4 })
          .alignSelf(ItemAlign.Start)

        // 装箱重量1
        Row() {
          Text(t('装箱重量1:', '装箱重量1:'))
            .fontSize(20)  // 标签字体增大到20px
            .fontColor(this.getCurrentTheme().textColor)
            .margin({ right: 2 })

          TextInput({ text: this.packingWeight1.toString() })
            .type(InputType.Number)
            .fontSize(18)  // 输入框字体增大到18px
            .fontColor(this.getCurrentTheme().textColor)
            .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
            .border({ width: AppleDesignStyle.BORDER_WIDTH_THIN, color: this.getCurrentTheme().borderColor }) // 恢复细边框
            .borderRadius(AppleDesignStyle.BORDER_RADIUS_SMALL) // 合理圆角(8px)
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .layoutWeight(1)
            .constraintSize({ minWidth: 60, maxWidth: 140 })
            .height(30)
            .onChange((val: string) => {
              const num = Number(val)
              if (this.onPackingWeight1Change) {
                this.onPackingWeight1Change(isNaN(num) ? 0 : num)
              }
            })

          Text(t('公斤', '公斤'))
            .fontSize(22)  // 单位标签字体调大到22px
            .fontColor(this.getCurrentTheme().textColor)
            .margin({ left: 4 })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .margin({ bottom: 6 })

        // 装箱重量2
        Row() {
          Text(t('装箱重量2:', '装箱重量2:'))
            .fontSize(20)  // 标签字体增大到20px
            .fontColor(this.getCurrentTheme().textColor)
            .margin({ right: 2 })

          TextInput({ text: this.packingWeight2.toString() })
            .type(InputType.Number)
            .fontSize(18)  // 输入框字体增大到18px
            .fontColor(this.getCurrentTheme().textColor)
            .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
            .border({ width: AppleDesignStyle.BORDER_WIDTH_THIN, color: this.getCurrentTheme().borderColor }) // 恢复细边框
            .borderRadius(AppleDesignStyle.BORDER_RADIUS_SMALL) // 合理圆角(8px)
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .layoutWeight(1)
            .constraintSize({ minWidth: 60, maxWidth: 140 })
            .height(30)
            .onChange((val: string) => {
              const num = Number(val)
              if (this.onPackingWeight2Change) {
                this.onPackingWeight2Change(isNaN(num) ? 0 : num)
              }
            })

          Text(t('公斤', '公斤'))
            .fontSize(22)  // 单位标签字体调大到22px
            .fontColor(this.getCurrentTheme().textColor)
            .margin({ left: 4 })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .margin({ bottom: 6 })

        // 自动生成按钮
        Row() {
          Blank().layoutWeight(1)
          Button('自动生成')
            .height(28)
            .fontSize(20)  // 调整按钮字号以避免出界
            .fontWeight(FontWeight.Medium) // Apple风格：Medium字重
            .backgroundColor(this.getCurrentTheme().primary)
            .fontColor('#ffffff')
            .borderRadius(AppleDesignStyle.BORDER_RADIUS_SMALL) // 合理圆角(8px)
            .shadow(AppleDesignStyle.getShadowSmall()) // 柔和阴影
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .transition(AppleDesignStyle.getTransitionNormal()) // Apple风格：流畅过渡
            .onClick(() => {
              if (this.onAutoGenerate) {
                this.onAutoGenerate()
              }
            })
        }
        .width('100%')
      }
      .width('100%')
      .padding(12)
      .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().backgroundColor)
      .border({ width: AppleDesignStyle.BORDER_WIDTH_THIN, color: this.getCurrentTheme().borderColor }) // Apple风格：细边框
      .borderRadius(AppleDesignStyle.BORDER_RADIUS_SMALL) // Apple风格：小圆角
      .shadow(AppleDesignStyle.getShadowSmall('rgba(0, 0, 0, 0.08)')) // Apple风格：柔和阴影
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .padding(AppleDesignStyle.SPACING_SMALL) // 合理内边距
    .backgroundColor(this.getCurrentTheme().surfaceColor)
    .border({ width: AppleDesignStyle.BORDER_WIDTH_THIN, color: this.getCurrentTheme().borderColor }) // 恢复细边框
    .borderRadius(AppleDesignStyle.BORDER_RADIUS_MEDIUM) // 合理圆角(12px)
    .shadow(AppleDesignStyle.getShadowMedium()) // 柔和阴影
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
  }

  private updateStandards(standard: string, isChecked: boolean): void {
    let newStandards = [...this.selectedStandards]
    if (isChecked) {
      if (!newStandards.includes(standard)) {
        newStandards.push(standard)
      }
    } else {
      newStandards = newStandards.filter(s => s !== standard)
    }
    if (this.onStandardsChange) {
      this.onStandardsChange(newStandards)
    }
  }
}
