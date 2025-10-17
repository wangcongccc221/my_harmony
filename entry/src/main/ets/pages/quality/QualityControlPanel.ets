/**
 * 品质页面控制面板组件
 * 
 * 功能说明：
 * - 提供品质页面的控制面板功能
 * - 包含等级数量选择、自动设定、设置参数等控制
 * - 支持主题切换和样式适配
 * 
 * 主要特性：
 * - 等级数量选择：支持2-6个等级的选择
 * - 自动设定功能：一键自动设定参数
 * - 设置参数功能：打开参数设置面板
 * - 主题适配：支持明暗主题切换
 * - 事件回调：支持各种用户交互事件
 * 
 * 使用场景：
 * - 品质页面顶部控制区域
 * - 用户配置品质参数
 * - 快速设定品质等级
 * 
 * 组件结构：
 * - 等级数量标签：显示"等级数量:"
 * - 等级数量选择器：下拉框选择2-6个等级
 * - 自动设定按钮：一键自动设定
 * - 设置参数按钮：打开参数设置
 * 
 * 事件处理：
 * - onLevelCountChange：等级数量变化事件
 * - onAutoSet：自动设定事件
 * - onSettingsClick：设置参数事件
 * 
 * 样式特性：
 * - 响应式设计：适配不同屏幕尺寸
 * - 主题适配：支持明暗主题
 * - 按钮样式：统一的按钮设计
 * - 布局优化：合理的间距和对齐
 */

import { BaseComponentHelper } from '../../components/common/BaseComponent'
import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { LEVEL_COUNT_OPTIONS } from './QualityConstants'

/**
 * 品质页面控制面板组件
 * 
 * 功能说明：
 * - 提供品质页面的控制面板功能
 * - 包含等级数量选择、自动设定、设置参数等控制
 * - 支持主题切换和样式适配
 * 
 * 属性说明：
 * - levelCountIndex：当前选中的等级数量索引
 * - onLevelCountChange：等级数量变化回调函数
 * - onAutoSet：自动设定回调函数
 * - onSettingsClick：设置参数回调函数
 * 
 * 主题支持：
 * - 支持明暗主题切换
 * - 自动适配主题颜色
 * - 响应主题变化
 */
@Component
export struct QualityControlPanel {
  // ==================== 属性定义 ====================
  
  /**
   * 当前选中的等级数量索引
   * 
   * 功能说明：
   * - 存储当前选中的等级数量索引
   * - 用于控制面板显示和数据处理
   * - 默认值为0（对应2个等级）
   * 
   * 使用场景：
   * - 控制面板显示当前选择
   * - 数据处理时使用选中的等级数量
   * - 状态重置时恢复默认值
   */
  @Prop levelCountIndex: number = 0

  // ==================== 事件回调 ====================
  
  /**
   * 等级数量变化回调函数
   * 
   * 功能说明：
   * - 处理用户选择等级数量的事件
   * - 接收等级数量索引参数
   * - 可选的回调函数
   * 
   * @param index 等级数量索引
   * 
   * 使用场景：
   * - 用户从下拉框选择等级数量时
   * - 程序自动设置等级数量时
   */
  onLevelCountChange?: (index: number) => void

  /**
   * 自动设定回调函数
   * 
   * 功能说明：
   * - 处理用户点击自动设定按钮的事件
   * - 自动设定品质参数
   * - 可选的回调函数
   * 
   * 使用场景：
   * - 用户点击自动设定按钮时
   * - 程序需要自动设定参数时
   */
  onAutoSet?: () => void

  /**
   * 设置参数回调函数
   * 
   * 功能说明：
   * - 处理用户点击设置参数按钮的事件
   * - 打开参数设置面板
   * - 可选的回调函数
   * 
   * 使用场景：
   * - 用户点击设置参数按钮时
   * - 程序需要打开参数设置时
   */
  onSettingsClick?: () => void

  // ==================== 主题相关 ====================
  
  /**
   * 当前主题样式
   * 
   * 功能说明：
   * - 存储当前应用的主题样式
   * - 用于组件样式适配
   * - 自动响应主题变化
   * 
   * 使用场景：
   * - 组件渲染时获取主题样式
   * - 主题切换时自动更新
   */
  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()

  /**
   * 当前主题类型
   * 
   * 功能说明：
   * - 存储当前应用的主题类型
   * - 用于主题类型判断
   * - 自动响应主题变化
   * 
   * 使用场景：
   * - 主题类型判断时
   * - 主题切换时自动更新
   */
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: OmniThemeType = OmniThemeManager.getInstance().getCurrentThemeType()

  /**
   * 主题版本号
   * 
   * 功能说明：
   * - 存储当前主题的版本号
   * - 用于主题更新检测
   * - 自动响应主题变化
   * 
   * 使用场景：
   * - 主题更新检测时
   * - 主题切换时自动更新
   */
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0

  /**
   * 基础组件助手
   * 
   * 功能说明：
   * - 提供基础组件的通用功能
   * - 用于主题获取和样式处理
   * - 私有属性，不对外暴露
   * 
   * 使用场景：
   * - 获取当前主题时
   * - 处理组件样式时
   */
  private baseComponentHelper = new BaseComponentHelper()

  // ==================== 方法定义 ====================
  
  /**
   * 获取当前主题配置
   * 
   * 功能说明：
   * - 获取当前应用的主题配置
   * - 返回主题样式对象
   * - 用于组件样式适配
   * 
   * @returns 当前主题样式对象
   * 
   * 使用场景：
   * - 组件渲染时获取主题样式
   * - 样式适配时调用
   */
  getCurrentTheme(): ExtendedOmniThemeStyle {
    return this.baseComponentHelper.getCurrentTheme(this.consumedTheme)
  }

  /**
   * 构建组件UI
   * 
   * 功能说明：
   * - 构建品质页面控制面板的UI结构
   * - 包含等级数量选择、自动设定、设置参数等控制
   * - 支持主题适配和事件处理
   * 
   * 组件结构：
   * - 等级数量标签：显示"等级数量:"
   * - 等级数量选择器：下拉框选择2-6个等级
   * - 自动设定按钮：一键自动设定
   * - 设置参数按钮：打开参数设置
   * 
   * 样式特性：
   * - 响应式设计：适配不同屏幕尺寸
   * - 主题适配：支持明暗主题
   * - 按钮样式：统一的按钮设计
   * - 布局优化：合理的间距和对齐
   * 
   * 事件处理：
   * - 等级数量选择：触发onLevelCountChange事件
   * - 自动设定按钮：触发onAutoSet事件
   * - 设置参数按钮：触发onSettingsClick事件
   */
  build() {
    Column() {
      Row() {
        // 等级数量标签
        Text('等级数量:')
          .fontSize(24)
          .fontColor(this.getCurrentTheme().textColor)
          .margin({ right: 8 })

        // 等级数量选择器
        Select(LEVEL_COUNT_OPTIONS)
          .selected(this.levelCountIndex)
          .font({ size: 22 })
          .fontColor(this.getCurrentTheme().textColor)
          .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
          .border({ width: 1, color: this.getCurrentTheme().borderColor })
          .borderRadius(6)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .width('30%')
          .margin({ right: 8 })
          .onSelect((index: number) => {
            if (this.onLevelCountChange) {
              this.onLevelCountChange(index)
            }
          })

        // 自动设定按钮
        Button('自动设定')
          .fontSize(22)
          .backgroundColor(this.getCurrentTheme().primary)
          .fontColor('#FFFFFF')
          .borderRadius(8)
          .padding({ left: 12, right: 12 })
          .margin({ right: 6 })
          .onClick(() => {
            if (this.onAutoSet) {
              this.onAutoSet()
            }
          })

        // 设置参数按钮
        Button('设置参数')
          .fontSize(22)
          .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().backgroundColor)
          .fontColor(this.getCurrentTheme().textColor)
          .border({ width: 1, color: this.getCurrentTheme().borderColor })
          .borderRadius(8)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            if (this.onSettingsClick) {
              this.onSettingsClick()
            }
          })
      }
      .width('100%')
    }
    .width('100%')
    .height('10%')
    .padding(16)
    .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
    .border({ width: 1, color: this.getCurrentTheme().borderColor })
    .borderRadius(12)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.15)', offsetY: 2 })
    .margin({ top: 12, bottom: 10, left: 16, right: 16 })
  }
}
