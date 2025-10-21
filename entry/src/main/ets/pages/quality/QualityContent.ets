 /**
 * 品质内容组件
 * 
 * 功能说明：
 * - 显示品质相关的内容和功能
 * - 集成模块化组件架构
 * - 支持主题切换和样式适配
 * 
 * 主要特性：
 * - 模块化架构：使用独立的组件模块
 * - 状态管理：集中管理所有状态
 * - 事件处理：统一处理用户交互
 * - 数据管理：集中管理数据操作
 * - 主题适配：支持明暗主题切换
 * 
 * 组件结构：
 * - 控制面板：等级数量选择、自动设定、设置参数
 * - 数据表格：显示品质等级数据
 * - 出口对话框：出口设置和选择
 * 
 * 使用场景：
 * - 品质页面主界面
 * - 品质等级管理
 * - 出口设置配置
 *
 * 集成说明：
 * - 使用QualityStateManager管理状态
 * - 使用QualityDataManager管理数据
 * - 使用QualityEventHandler处理事件
 * - 使用模块化组件构建UI
 */

import { BaseComponentHelper } from '../../components/common/BaseComponent'
import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { QualityStateManager } from './core/QualityStateManager'
import { QualityDataManager } from './core/QualityDataManager'
import { QualityEventHandler } from './core/QualityEventHandler'
import { QualityControlPanel } from './QualityControlPanel'
import { QualityDataTable } from './QualityDataTable'
import { QualityOutletDialog } from './QualityOutletDialog'
import { QualityLevelData } from './QualityConstants'
import { DEFAULT_QUALITY_SETTINGS } from './QualityConstants'
import { ArrowToggleButton } from '../../components/ui/ArrowToggleButton'

/**
 * 品质内容组件
 * 
 * 功能说明：
 * - 显示品质相关的内容和功能
 * - 集成模块化组件架构
 * - 支持主题切换和样式适配
 * 
 * 组件架构：
 * - 状态管理：使用QualityStateManager集中管理状态
 * - 数据管理：使用QualityDataManager管理数据
 * - 事件处理：使用QualityEventHandler处理事件
 * - UI组件：使用模块化组件构建界面
 * 
 * 主要功能：
 * - 品质等级管理
 * - 出口设置配置
 * - 数据表格显示
 * - 用户交互处理
 */
@Component
export struct QualityContent {
  // ==================== 状态管理 ====================
  
  /**
   * 品质页面状态管理器
   * 
   * 功能说明：
   * - 集中管理品质页面的所有状态
   * - 提供状态更新和重置功能
   * - 简化状态管理逻辑
   * 
   * 使用场景：
   * - 状态初始化和更新
   * - 状态重置和恢复
   * - 状态验证和同步
   */
  private stateManager = new QualityStateManager()

  /**
   * 品质页面数据管理器
   * 
   * 功能说明：
   * - 管理品质页面的所有数据操作
   * - 提供数据的增删改查功能
   * - 支持数据验证和格式化
   * 
   * 使用场景：
   * - 数据初始化和加载
   * - 数据更新和同步
   * - 数据验证和格式化
   */
  private dataManager = new QualityDataManager()

  /**
   * 品质页面事件处理器
   * 
   * 功能说明：
   * - 处理品质页面的所有用户交互事件
   * - 提供事件日志和调试功能
   * - 支持事件的扩展和自定义
   * 
   * 使用场景：
   * - 用户交互处理
   * - 事件日志记录
   * - 错误处理和调试
   */
  private eventHandler = new QualityEventHandler()

  // 用于驱动UI刷新的可观察数据（表格与等级数量联动）
  @State private currentLevels: QualityLevelData[] = []
  
  // 右侧操作栏展开状态
  @State private rightOpsExpanded: boolean = false

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
   * 初始化品质页面
   * 
   * 功能说明：
   * - 初始化品质页面的所有组件
   * - 设置默认状态和数据
   * - 注册事件处理器
   * 
   * 初始化内容：
   * - 初始化状态管理器
   * - 初始化数据管理器
   * - 初始化事件处理器
   * - 设置默认状态
   * 
   * 使用场景：
   * - 页面初始化时
   * - 组件创建时
   * - 状态重置时
   */
  private initializeQualityPage(): void {
    // 初始化状态管理器
    this.stateManager.resetAllStates()
    
    // 初始化数据管理器
    this.dataManager.initializeQualityData()
    
    // 初始化事件处理器
    this.eventHandler.onPageInit()

    // 初始化可观察数据，确保表格根据默认数量渲染
    this.currentLevels = this.stateManager.getQualityLevels()
  }

  // ==================== 事件处理方法 ====================
  
  /**
   * 处理等级数量变化
   * 
   * 功能说明：
   * - 处理用户选择等级数量的事件
   * - 更新状态管理器和数据管理器
   * - 触发相关事件处理
   * 
   * @param index 等级数量索引
   * 
   * 使用场景：
   * - 用户从下拉框选择等级数量时
   * - 程序自动设置等级数量时
   */
  private handleLevelCountChange(index: number): void {
    // 更新状态管理器
    this.stateManager.updateLevelCountIndex(index)
    
    // 更新数据管理器
    this.dataManager.setLevelCount(index)
    
    // 触发事件处理
    this.eventHandler.onLevelCountChange(index)

    // 刷新可观察数据，触发表格联动
    this.currentLevels = this.stateManager.getQualityLevels()
  }

  /**
   * 处理自动设定事件
   * 
   * 功能说明：
   * - 处理用户点击自动设定按钮的事件
   * - 执行自动设定逻辑
   * - 触发相关事件处理
   * 
   * 使用场景：
   * - 用户点击自动设定按钮时
   * - 程序需要自动设定参数时
   */
  private handleAutoSet(): void {
    // 触发事件处理
    this.eventHandler.onAutoSet()
    
    // TODO: 实现自动设定逻辑
    console.log('品质页面：执行自动设定逻辑')
  }

  /**
   * 处理设置参数事件
   * 
   * 功能说明：
   * - 处理用户点击设置参数按钮的事件
   * - 打开参数设置面板
   * - 触发相关事件处理
   * 
   * 使用场景：
   * - 用户点击设置参数按钮时
   * - 程序需要打开参数设置时
   */
  private handleSettingsClick(): void {
    // 触发事件处理
    this.eventHandler.onSettingsClick()
    
    // TODO: 实现设置参数逻辑
    console.log('品质页面：打开参数设置面板')
  }

  /**
   * 处理出口按钮点击
   * 
   * 功能说明：
   * - 处理用户点击出口按钮的事件
   * - 更新状态管理器和数据管理器
   * - 显示出口设置对话框
   * 
   * @param outletNumber 出口编号
   * 
   * 使用场景：
   * - 用户点击出口按钮时
   * - 程序需要打开出口设置时
   */
  private handleOutletClick(outletNumber: number): void {
    // 更新状态管理器
    this.stateManager.updateCurrentOutletIndex(outletNumber)
    this.stateManager.updateShowOutletDialog(true)
    
    // 更新数据管理器
    this.dataManager.setCurrentOutletIndex(outletNumber)
    
    // 触发事件处理
    this.eventHandler.onOutletClick(outletNumber)
  }

  /**
   * 处理出口切换事件
   * 
   * 功能说明：
   * - 处理用户切换出口状态的事件
   * - 更新状态管理器和数据管理器
   * - 触发相关事件处理
   * 
   * @param direction 切换方向
   * 
   * 使用场景：
   * - 用户点击上一个/下一个按钮时
   * - 程序需要切换出口时
   */
  private handleOutletSwitch(direction: 'previous' | 'next'): void {
    // 更新数据管理器
    if (direction === 'previous') {
      this.dataManager.switchToPreviousOutlet()
    } else {
      this.dataManager.switchToNextOutlet()
    }
    
    // 更新状态管理器
    this.stateManager.updateCurrentOutletIndex(this.dataManager.getCurrentOutletIndex())
    
    // 触发事件处理
    this.eventHandler.onOutletSwitch(direction, this.stateManager.getCurrentOutletIndex())
  }

  /**
   * 处理出口确认事件
   * 
   * 功能说明：
   * - 处理用户确认出口设置的事件
   * - 更新状态管理器
   * - 关闭出口设置对话框
   * 
   * 使用场景：
   * - 用户确认出口设置时
   * - 程序需要确认出口设置时
   */
  private handleOutletConfirm(): void {
    // 更新状态管理器
    this.stateManager.updateShowOutletDialog(false)
    
    // 触发事件处理
    this.eventHandler.onOutletConfirm(this.stateManager.getCurrentOutletIndex())
  }

  /**
   * 处理出口取消事件
   * 
   * 功能说明：
   * - 处理用户取消出口设置的事件
   * - 更新状态管理器
   * - 关闭出口设置对话框
   * 
   * 使用场景：
   * - 用户取消出口设置时
   * - 程序需要取消出口设置时
   */
  private handleOutletCancel(): void {
    // 更新状态管理器
    this.stateManager.updateShowOutletDialog(false)
    
    // 触发事件处理
    this.eventHandler.onOutletCancel()
  }

  /**
   * 处理数据更新事件
   * 
   * 功能说明：
   * - 处理品质等级数据更新的事件
   * - 更新状态管理器和数据管理器
   * - 触发相关事件处理
   * 
   * @param data 更新的数据
   * @param index 数据索引
   * 
   * 使用场景：
   * - 用户编辑等级数据时
   * - 程序自动更新数据时
   */
  private handleDataUpdate(data: QualityLevelData, index: number): void {
    // 更新状态管理器
    this.stateManager.updateQualityLevel(index, {
      levelName: data.levelName,
      colorLevel: typeof data.colorLevel === 'string' ? data.colorLevel : String(data.colorLevel.value),
      sugarLevel: data.sugarLevel
    })
    
    // 更新数据管理器
    this.dataManager.updateQualityLevel(index, {
      levelName: data.levelName,
      colorLevel: typeof data.colorLevel === 'string' ? data.colorLevel : String(data.colorLevel.value),
      sugarLevel: data.sugarLevel
    })
    
    // 触发事件处理
    this.eventHandler.onDataUpdate(data, index)

    // 同步最新数据到可观察数组
    this.currentLevels = this.stateManager.getQualityLevels()
  }

  /**
   * 构建组件UI
   * 
   * 功能说明：
   * - 构建品质页面的完整UI结构
   * - 使用模块化组件构建界面
   * - 支持主题适配和事件处理
   * 
   * 组件结构：
   * - 控制面板：等级数量选择、自动设定、设置参数
   * - 数据表格：显示品质等级数据
   * - 出口对话框：出口设置和选择
   * 
   * 样式特性：
   * - 响应式设计：适配不同屏幕尺寸
   * - 主题适配：支持明暗主题
   * - 模块化架构：使用独立组件
   * - 事件处理：统一的事件管理
   */
  build() {
    Stack() {
      // 主要内容
      Row() {
        Column() {
        // 控制面板组件
        QualityControlPanel({
          levelCountIndex: this.stateManager.getLevelCountIndex(),
          onLevelCountChange: (index: number) => {
            this.handleLevelCountChange(index)
          },
          onAutoSet: () => {
            this.handleAutoSet()
          },
          onSettingsClick: () => {
            this.handleSettingsClick()
          }
        })

        // 数据表格组件
        QualityDataTable({
          qualityLevels: this.currentLevels,
          onDataUpdate: (data: QualityLevelData, index: number) => {
            this.handleDataUpdate(data, index)
          },
          onDataClick: (data: QualityLevelData, index: number) => {
            this.handleDataUpdate(data, index)
          }
        })

        }
        .width('100%')
        .height('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Start)

        // 右侧操作栏（可折叠）
        Stack() {
          // 展开时的按钮内容
          if (this.rightOpsExpanded) {
            Column() {
              Blank().height(0) // 顶部留出空间给箭头位置

              Button('取消')
                .width('100%')
                .height(42)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.getCurrentTheme().textColor)
                .backgroundColor(Color.Transparent)
                .border({ width: 1, color: this.getCurrentTheme().borderColor })
                .borderRadius(10)
                .margin({ bottom: 8 })
                .onClick(() => {
                  this.eventHandler.onDataReset()
                  console.log('品质页面：取消操作')
                })

              Button('确认')
                .width('100%')
                .height(42)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(Color.White)
                .backgroundColor(this.getCurrentTheme().primary)
                .borderRadius(10)
                .onClick(() => {
                  const first = this.stateManager.getQualityLevels()[0]
                  this.eventHandler.onDataUpdate(first, -1)
                  console.log('品质页面：确认操作')
                })
            }
            .width('100%')
            .height('100%')
            .padding({ left: 8, right: 8, top: 8, bottom: 8 })
            .justifyContent(FlexAlign.Start)
            .alignItems(HorizontalAlign.Center)
          }

          // 悬浮箭头按钮（贴左边缘）
          ArrowToggleButton({
            isExpanded: this.rightOpsExpanded,
            onToggle: () => { this.rightOpsExpanded = !this.rightOpsExpanded }
          })
          .position({ x: this.rightOpsExpanded ? 110 : 5, y: '50%' })
          .translate({ y: -20 })
          .zIndex(10)
        }
        .width(this.rightOpsExpanded ? 150 : 50)
        .height('100%')
        .backgroundColor(this.getCurrentTheme().surfaceColor)
        .borderRadius(12)
        .margin({ left: 12, right: 8, top: 8, bottom: 8 })
        .shadow({
          radius: 12,
          color: 'rgba(0, 0, 0, 0.08)',
          offsetX: 0,
          offsetY: 6
        })
      }
      .width('100%')
      .height('100%')
      .alignItems(VerticalAlign.Top)
      .backgroundColor(this.getCurrentTheme().pageBg ?? this.getCurrentTheme().backgroundColor)
      
      // 出口设置对话框 - 放在Stack的最上层
      if (this.stateManager.getShowOutletDialog()) {
        QualityOutletDialog({
          showDialog: this.stateManager.getShowOutletDialog(),
          currentOutletIndex: this.stateManager.getCurrentOutletIndex(),
          onOutletSwitch: (direction: 'previous' | 'next') => {
            this.handleOutletSwitch(direction)
          },
          onOutletConfirm: () => {
            this.handleOutletConfirm()
          },
          onOutletCancel: () => {
            this.handleOutletCancel()
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  // ==================== 生命周期方法 ====================
  
  /**
   * 组件即将出现时的生命周期方法
   * 
   * 功能说明：
   * - 在组件即将出现时调用
   * - 初始化品质页面
   * - 设置默认状态
   * 
   * 使用场景：
   * - 页面初始化
   * - 组件创建
   * - 状态重置
   */
  aboutToAppear(): void {
    this.initializeQualityPage()
  }

  /**
   * 组件即将销毁时的生命周期方法
   * 
   * 功能说明：
   * - 在组件即将销毁时调用
   * - 清理资源和状态
   * - 触发页面销毁事件
   * 
   * 使用场景：
   * - 页面销毁
   * - 资源清理
   * - 状态重置
   */
  aboutToDisappear(): void {
    this.eventHandler.onPageDestroy()
  }
}