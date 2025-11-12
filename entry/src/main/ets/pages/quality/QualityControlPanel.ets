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

import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme as resolveTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { LEVEL_COUNT_OPTIONS } from './QualityConstants'
import { GlobalLevelCountManager } from '../../utils/managers/GlobalLevelCountManager'

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
  @Prop levelCountIndex: number = 9
  
  /**
   * 当前实际数据条数
   * 
   * 功能说明：
   * - 用于滚轮事件处理
   * - 基于实际数据条数进行增减
   */
  @Prop currentDataCount: number = 0

  /**
   * 当前选中的等级数量索引（内部状态）
   * 
   * 功能说明：
   * - 用于响应全局管理器的状态变化
   * - 控制Select组件的显示
   * - 与levelCountIndex保持同步
   */
  @State @Watch('onCurrentSelectedIndexChange') private currentSelectedIndex: number = 0
  
  /**
   * 强制刷新标识
   * 
   * 功能说明：
   * - 用于强制Select组件重新渲染
   * - 解决Select组件不响应@State变化的问题
   */
  @State private forceRefresh: number = 0

  // ==================== 全局管理器 ====================
  
  /**
   * 全局等级数量管理器实例
   * 
   * 功能说明：
   * - 管理全局的等级数量状态
   * - 支持滚轮事件直接修改等级数量
   * - 提供状态变化监听功能
   */
  private globalLevelCountManager = GlobalLevelCountManager.getInstance()

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
    return resolveTheme(this.consumedTheme)
  }

  /**
   * 组件即将出现时的生命周期方法
   * 
   * 功能说明：
   * - 初始化全局等级数量管理器
   * - 设置状态变化监听器
   * - 同步本地状态和全局状态
   */
  aboutToAppear(): void {
    // 初始化内部状态
    this.currentSelectedIndex = this.levelCountIndex
    console.log(`🎯 QualityControlPanel aboutToAppear - 初始索引: ${this.levelCountIndex}, 内部状态: ${this.currentSelectedIndex}`)
    this.initializeGlobalLevelCountManager()
  }

  /**
   * 监听currentSelectedIndex变化
   */
  onCurrentSelectedIndexChange(): void {
    console.log(`✅ currentSelectedIndex已更新为: ${this.currentSelectedIndex}`)
    // 强制刷新Select组件
    this.forceRefresh++
    console.log(`🔄 强制刷新Select组件，刷新次数: ${this.forceRefresh}`)
    
    // 强制触发UI更新
    this.forceRefresh = this.forceRefresh
  }

  /**
   * 从外部更新等级数量选择器
   * 
   * 功能说明：
   * - 根据表格数据条数更新等级数量选择器
   * - 实现反向数据绑定
   * - 同步选择器显示
   * 
   * @param dataCount 表格数据条数
   */
  public updateFromDataCount(dataCount: number): void {
    console.log(`🎯 外部更新等级数量选择器: ${dataCount}条数据`)
    
    // 更新全局管理器
    this.globalLevelCountManager.setCount(dataCount)
    
    console.log(`✅ 等级数量选择器已从外部更新为: ${dataCount}个等级`)
  }

  // 保存监听器回调引用，用于清理
  private levelCountChangeCallback?: (newCount: number, newIndex: number) => void

  /**
   * 初始化全局等级数量管理器
   * 
   * 功能说明：
   * - 设置全局管理器的初始状态
   * - 添加状态变化监听器
   * - 同步本地状态和全局状态
   */
  private initializeGlobalLevelCountManager(): void {
    // 设置全局管理器的初始索引
    this.globalLevelCountManager.setIndex(this.levelCountIndex)
    
    // 创建监听器回调并保存引用
    this.levelCountChangeCallback = (newCount: number, newIndex: number) => {
      console.log(`🔄 全局等级数量变化: ${newCount} (索引: ${newIndex})`)
      
      // 更新内部状态，触发UI更新
      this.currentSelectedIndex = newIndex
      console.log(`🎯 更新Select组件显示索引: ${newIndex}`)
      
      // 强制刷新Select组件
      this.forceRefresh++
      console.log(`🔄 强制刷新Select组件，刷新次数: ${this.forceRefresh}`)
      
      // 触发本地回调函数
      if (this.onLevelCountChange) {
        this.onLevelCountChange(newIndex)
      }
    }
    
    // 添加状态变化监听器
    this.globalLevelCountManager.addChangeListener(this.levelCountChangeCallback)
    
    console.log(`🎯 全局等级数量管理器初始化完成，当前索引: ${this.levelCountIndex}`)
  }

  /**
   * 组件销毁时清理监听器
   */
  aboutToDisappear(): void {
    // 移除监听器，避免内存泄漏和监听器累积
    if (this.levelCountChangeCallback) {
      this.globalLevelCountManager.removeChangeListener(this.levelCountChangeCallback)
      this.levelCountChangeCallback = undefined
      console.log(`🗑️ QualityControlPanel: 已移除等级数量变化监听器`)
    }
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

        // 等级数量选择器 - 使用key强制重新创建
        Select(LEVEL_COUNT_OPTIONS)
          .key(`select-${this.currentSelectedIndex}-${this.forceRefresh}`)
          .selected(this.currentSelectedIndex)
          .value(LEVEL_COUNT_OPTIONS[this.currentSelectedIndex]?.value || '0')
          .onAppear(() => {
            console.log(`🎯 Select组件出现 - 当前选中索引: ${this.currentSelectedIndex}, 强制刷新: ${this.forceRefresh}`)
          })
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
          .onAxisEvent((event?: AxisEvent) => {
            if (event) {
              const verticalValue = event.getVerticalAxisValue()
              const horizontalValue = event.getHorizontalAxisValue()
              
              console.log('🎡 滚轮事件触发 - 垂直值:', verticalValue, '水平值:', horizontalValue)
              
              // 处理垂直滚轮事件
              console.log('🔍 检查滚轮条件 - 垂直值绝对值:', Math.abs(verticalValue), '水平值绝对值:', Math.abs(horizontalValue))
              
              if (Math.abs(verticalValue) > Math.abs(horizontalValue)) {
                console.log('✅ 进入垂直滚轮处理逻辑')
                console.log('🎯 使用全局等级数量管理器处理滚轮事件')
                
                // 使用全局管理器处理滚轮事件，传入实际数据条数
                this.globalLevelCountManager.handleWheelEvent(verticalValue, this.currentDataCount)
                
                console.log('✅ 全局管理器处理完成')
              } else {
                console.log('❌ 不满足垂直滚轮条件')
              }
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
      .height('6%')
    .padding(16)
    .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
    .border({ width: 1, color: this.getCurrentTheme().borderColor })
    .borderRadius(12)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.15)', offsetY: 2 })
    .margin({ top: 12, bottom: 10, left: 16, right: 16 })
  }
}
