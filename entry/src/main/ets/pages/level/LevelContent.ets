/**
 * 等级页面主内容组件
 * 
 * 功能说明：
 * - 整合等级页面的所有子组件，实现组件化架构
 * - 作为等级页面的主入口，协调各个子组件的工作
 * - 管理页面状态、数据流和事件处理
 * - 提供统一的主题管理和布局控制
 * 
 * 组件架构：
 * - LevelControlPanel：左侧控制面板，包含各种设置选项
 * - LevelDataTable：右侧数据表格，显示等级数据和统计数据
 * - LevelOutletDialog：出口设置对话框，用于配置出口参数
 * - LevelStateManager：状态管理器，统一管理页面状态
 * - LevelDataManager：数据管理器，处理数据操作
 * - LevelEventHandler：事件处理器，处理用户交互
 * 
 * 布局说明：
 * - 左侧面板：20%宽度，用于控制面板
 * - 右侧面板：75%宽度，用于数据表格
 * - 对话框：覆盖整个页面，用于出口设置
 * 
 * 使用方式：
 * ```typescript
 * LevelContent()
 *   .width('100%')
 *   .height('100%')
 * ```
 * 
 * 生命周期：
 * - aboutToAppear：初始化数据和事件
 * - aboutToDisappear：清理资源和事件
 */

import { BaseComponentHelper } from '../../components/common/BaseComponent'
import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { LevelControlPanel } from './LevelControlPanel'
import { LevelDataTable } from './LevelDataTable'
import { LevelOutletDialog } from './LevelOutletDialog'
import { LevelDataManager, LevelData, StatisticsData } from './core/LevelDataManager'
import { LevelEventHandler } from './core/LevelEventHandler'
import { LevelStateManager } from './core/LevelStateManager'
import { LAYOUT_CONFIG } from './LevelConstants'
import { ArrowToggleButton } from '../../components/ui/ArrowToggleButton'

/**
 * 等级页面主内容组件结构体
 * 
 * 属性说明：
 * - consumedTheme: 当前主题样式
 * - consumedThemeType: 当前主题类型
 * - themeVersion: 主题版本号
 * - baseComponentHelper: 基础组件助手
 * - dataManager: 数据管理器
 * - eventHandler: 事件处理器
 * - stateManager: 状态管理器
 * 
 * 方法说明：
 * - getCurrentTheme(): 获取当前主题配置
 * - initializeData(): 初始化数据
 * - handleFruitChange(): 处理水果类型变化
 * - handleOutletThresholdChange(): 处理出口阈值变化
 * - handleStandardsChange(): 处理分选标准变化
 * - handleUnitChange(): 处理单位变化
 * - handlePackingWeight1Change(): 处理包装重量1变化
 * - handlePackingWeight2Change(): 处理包装重量2变化
 * - handleAutoGenerate(): 处理自动生成
 * - handleTableCountChange(): 处理表格数量变化
 * - handleOutletSetting(): 处理出口设置
 * - handleOutletSwitch(): 处理出口切换
 * - handleOutletConfirm(): 处理出口确认
 * - handleOutletCancel(): 处理出口取消
 * - build(): 构建组件UI结构
 */
@Component
export struct LevelContent {
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
   * 基础组件助手
   * 
   * 功能说明：
   * - 提供基础组件的通用功能
   * - 用于主题管理和样式配置
   * - 实例化BaseComponentHelper
   */
  private baseComponentHelper = new BaseComponentHelper()

  // ==================== 管理器实例 ====================
  /**
   * 数据管理器
   * 
   * 功能说明：
   * - 管理等级页面的所有数据操作
   * - 包括等级数据、统计数据的增删改查
   * - 提供数据初始化和随机生成功能
   */
  private dataManager = new LevelDataManager()
  
  /**
   * 事件处理器
   * 
   * 功能说明：
   * - 处理等级页面的所有用户交互事件
   * - 包括水果选择、标准选择、数据操作等事件
   * - 提供事件日志和调试功能
   */
  private eventHandler = new LevelEventHandler()
  
  /**
   * 状态管理器
   * 
   * 功能说明：
   * - 管理等级页面的所有状态变量
   * - 包括用户设置、数据状态、UI状态等
   * - 提供状态更新和同步功能
   */
  private stateManager = new LevelStateManager()

  // 悬浮按钮显示状态
  @State private showFloatingButtons: boolean = true
  // 悬浮按钮悬停状态
  @State private isHovering: boolean = false

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

  // ==================== 数据初始化方法 ====================
  /**
   * 初始化数据
   * 
   * 功能说明：
   * - 初始化等级页面的所有数据
   * - 从数据管理器获取默认数据
   * - 更新状态管理器的数据状态
   * 
   * 初始化内容：
   * - 等级数据：从数据管理器获取默认等级数据
   * - 统计数据：从数据管理器获取默认统计数据
   * - 状态同步：将数据同步到状态管理器
   * 
   * 使用场景：
   * - 页面首次加载时
   * - 数据重置时
   * - 组件初始化时
   */
  private initializeData(): void {
    // 不再预填充默认等级数据：等待用户选择后再生成
    this.stateManager.updateLevelData([])
    this.stateManager.updateStatisticsData(this.dataManager.getStatisticsData())
  }

  // ==================== 事件处理方法 ====================
  /**
   * 处理水果类型变化
   * 
   * 功能说明：
   * - 处理用户选择水果类型的事件
   * - 更新状态管理器中的水果类型
   * - 触发事件处理器的水果选择事件
   * 
   * @param fruit 选中的水果类型
   * 
   * 使用场景：
   * - 用户从下拉框选择水果类型时
   * - 程序自动设置水果类型时
   */
  private handleFruitChange(fruit: string): void {
    this.stateManager.updateSelectedFruit(fruit)
    this.eventHandler.onFruitSelect(fruit)
  }

  /**
   * 处理出口阈值变化
   * 
   * 功能说明：
   * - 处理用户设置出口阈值的事件
   * - 更新状态管理器中的出口阈值
   * - 触发事件处理器的出口阈值变化事件
   * 
   * @param threshold 出口阈值数值
   * 
   * 使用场景：
   * - 用户输入出口阈值时
   * - 程序自动设置出口阈值时
   */
  private handleOutletThresholdChange(threshold: number): void {
    this.stateManager.updateOutletThreshold(threshold)
    this.eventHandler.onOutletThresholdChange(threshold)
  }

  /**
   * 处理分选标准变化
   * 
   * 功能说明：
   * - 处理用户选择分选标准的事件
   * - 更新状态管理器中的分选标准
   * - 触发事件处理器的分选标准变化事件
   * 
   * @param standards 选中的分选标准数组
   * 
   * 使用场景：
   * - 用户选择分选标准时
   * - 程序自动设置分选标准时
   */
  private handleStandardsChange(standards: string[]): void {
    this.stateManager.updateSelectedStandards(standards)
    this.eventHandler.onSortingStandardChange(standards)
  }

  /**
   * 处理单位变化
   * 
   * 功能说明：
   * - 处理用户选择计算单位的事件
   * - 更新状态管理器中的计算单位
   * - 触发事件处理器的单位变化事件
   * 
   * @param unit 选中的计算单位
   * 
   * 使用场景：
   * - 用户选择计算单位时
   * - 程序自动设置计算单位时
   */
  private handleUnitChange(unit: string): void {
    this.stateManager.updateSelectedUnit(unit)
    this.eventHandler.onUnitChange(unit)
  }

  /**
   * 处理包装重量1变化
   * 
   * 功能说明：
   * - 处理用户设置包装重量1的事件
   * - 更新状态管理器中的包装重量1
   * - 触发事件处理器的包装重量变化事件
   * 
   * @param weight 包装重量1的数值
   * 
   * 使用场景：
   * - 用户输入包装重量1时
   * - 程序自动设置包装重量1时
   */
  private handlePackingWeight1Change(weight: number): void {
    this.stateManager.updatePackingWeight1(weight)
    this.eventHandler.onPackingWeightChange(weight, this.stateManager.packingWeight2)
  }

  /**
   * 处理包装重量2变化
   * 
   * 功能说明：
   * - 处理用户设置包装重量2的事件
   * - 更新状态管理器中的包装重量2
   * - 触发事件处理器的包装重量变化事件
   * 
   * @param weight 包装重量2的数值
   * 
   * 使用场景：
   * - 用户输入包装重量2时
   * - 程序自动设置包装重量2时
   */
  private handlePackingWeight2Change(weight: number): void {
    this.stateManager.updatePackingWeight2(weight)
    this.eventHandler.onPackingWeightChange(this.stateManager.packingWeight1, weight)
  }

  /**
   * 处理自动生成
   * 
   * 功能说明：
   * - 处理用户点击自动生成按钮的事件
   * - 触发事件处理器的自动生成事件
   * - 用于自动生成包装重量
   * 
   * 使用场景：
   * - 用户点击自动生成按钮时
   * - 程序需要自动生成包装重量时
   */
  private handleAutoGenerate(): void {
    this.eventHandler.onAutoGeneratePackingWeight()
  }

  /**
   * 处理表格数量变化
   * 
   * 功能说明：
   * - 处理用户选择表格数量的事件
   * - 更新状态管理器中的表格数量
   * - 调整数据管理器中的等级数据
   * - 触发事件处理器的表格数量变化事件
   * 
   * @param count 表格数量字符串
   * 
   * 使用场景：
   * - 用户选择表格数量时
   * - 程序自动设置表格数量时
   */
  private handleTableCountChange(count: string): void {
    this.stateManager.updateTableCount(count)
    this.dataManager.adjustLevelDataByCount(Number(count))
    this.stateManager.updateLevelData(this.dataManager.getLevelData())
    this.eventHandler.onTableCountChange(count)
  }

  /**
   * 处理生成随机数据
   * 
   * 功能说明：
   * - 处理用户点击生成随机数据按钮的事件
   * - 从数据管理器生成随机统计数据
   * - 更新状态管理器中的统计数据
   * - 触发事件处理器的生成随机数据事件
   * 
   * 使用场景：
   * - 用户点击生成随机数据按钮时
   * - 程序需要生成测试数据时
   */
  private handleGenerateRandomData(): void {
    this.dataManager.generateRandomStatisticsData()
    this.stateManager.updateStatisticsData(this.dataManager.getStatisticsData())
    this.eventHandler.onGenerateRandomData()
  }

  /**
   * 处理清空数据
   * 
   * 功能说明：
   * - 处理用户点击清空数据按钮的事件
   * - 清空数据管理器中的统计数据
   * - 更新状态管理器中的统计数据
   * - 触发事件处理器的清空数据事件
   * 
   * 使用场景：
   * - 用户点击清空数据按钮时
   * - 程序需要重置数据时
   */
  private handleClearData(): void {
    this.dataManager.clearStatisticsData()
    this.stateManager.updateStatisticsData(this.dataManager.getStatisticsData())
    this.eventHandler.onClearData()
  }


  /**
   * 处理出口设置
   * 
   * 功能说明：
   * - 处理用户点击出口设置按钮的事件
   * - 显示出口设置对话框
   * - 设置当前出口索引
   * - 触发事件处理器的出口设置事件
   * 
   * @param outletNumber 出口编号
   * 
   * 使用场景：
   * - 用户点击出口设置按钮时
   * - 程序需要显示出口设置对话框时
   */
  private handleOutletSetting(outletNumber: number): void {
    this.stateManager.updateShowOutletDialog(true)
    this.stateManager.updateCurrentOutletIndex(outletNumber)
    this.eventHandler.onOutletSetting(outletNumber)
  }

  /**
   * 处理出口切换
   * 
   * 功能说明：
   * - 处理用户在出口设置对话框中切换出口的事件
   * - 计算新的出口索引（1-8范围）
   * - 更新状态管理器中的当前出口索引
   * - 触发事件处理器的出口切换事件
   * 
   * @param direction 切换方向（'previous' 或 'next'）
   * 
   * 使用场景：
   * - 用户点击上一个/下一个按钮时
   * - 程序需要切换出口时
   */
  private handleOutletSwitch(direction: 'previous' | 'next'): void {
    let newIndex = this.stateManager.currentOutletIndex
    if (direction === 'previous') {
      newIndex = Math.max(1, newIndex - 1)
    } else {
      newIndex = Math.min(8, newIndex + 1)
    }
    this.stateManager.updateCurrentOutletIndex(newIndex)
    this.eventHandler.onOutletSwitch(direction, newIndex)
  }

  /**
   * 处理出口确认
   * 
   * 功能说明：
   * - 处理用户确认出口设置的事件
   * - 隐藏出口设置对话框
   * - 触发事件处理器的出口确认事件
   * 
   * 使用场景：
   * - 用户点击确认按钮时
   * - 程序需要确认出口设置时
   */
  private handleOutletConfirm(): void {
    this.stateManager.updateShowOutletDialog(false)
    this.eventHandler.onOutletConfirm(this.stateManager.currentOutletIndex)
  }

  /**
   * 处理出口取消
   * 
   * 功能说明：
   * - 处理用户取消出口设置的事件
   * - 隐藏出口设置对话框
   * - 触发事件处理器的出口取消事件
   * 
   * 使用场景：
   * - 用户点击取消按钮时
   * - 程序需要取消出口设置时
   */
  private handleOutletCancel(): void {
    this.stateManager.updateShowOutletDialog(false)
    this.eventHandler.onOutletCancel()
  }

  /**
   * 组件构建方法
   * 
   * 功能：
   * - 构建等级页面的UI结构
   * - 实现左右分栏布局
   * - 集成所有子组件
   * - 处理组件间的事件传递
   * 
   * 布局说明：
   * - 使用Stack布局实现层级结构
   * - 主要内容：Column + Row布局
   * - 左侧面板：LevelControlPanel（20%宽度）
   * - 右侧面板：LevelDataTable（75%宽度）
   * - 对话框：LevelOutletDialog（覆盖整个页面）
   * 
   * 组件集成：
   * - LevelControlPanel：控制面板，包含所有设置选项
   * - LevelDataTable：数据表格，显示等级和统计数据
   * - LevelOutletDialog：出口设置对话框
   * 
   * 事件传递：
   * - 从子组件接收事件，通过handle方法处理
   * - 将处理结果传递给状态管理器和事件处理器
   * - 实现组件间的解耦和事件流控制
   */
  build() {
    Stack() {
      // ==================== 主要内容区域 ====================
      Column() {
        // ==================== 第一行：左侧控制面板 + 中间数据表格 + 右侧操作栏 ====================
        Row() {
          // ==================== 左侧控制面板 ====================
          LevelControlPanel({
            selectedFruit: this.stateManager.selectedFruit,                    // 选中的水果类型
            outletThreshold: this.stateManager.outletThreshold,                // 出口阈值
            selectedStandards: this.stateManager.selectedStandards,            // 选中的分选标准
            selectedUnit: this.stateManager.selectedUnit,                      // 选中的计算单位
            packingWeight1: this.stateManager.packingWeight1,                  // 包装重量1
            packingWeight2: this.stateManager.packingWeight2,                  // 包装重量2
            onFruitChange: (fruit: string) => {                                // 水果类型变化回调
              this.handleFruitChange(fruit)
            },
            onOutletThresholdChange: (threshold: number) => {                  // 出口阈值变化回调
              this.handleOutletThresholdChange(threshold)
            },
            onStandardsChange: (standards: string[]) => {                      // 分选标准变化回调
              this.handleStandardsChange(standards)
            },
            onUnitChange: (unit: string) => {                                  // 单位变化回调
              this.handleUnitChange(unit)
            },
            onPackingWeight1Change: (weight: number) => {                      // 包装重量1变化回调
              this.handlePackingWeight1Change(weight)
            },
            onPackingWeight2Change: (weight: number) => {                      // 包装重量2变化回调
              this.handlePackingWeight2Change(weight)
            },
            onAutoGenerate: () => {                                            // 自动生成回调
              this.handleAutoGenerate()
            }
          })
          .width(LAYOUT_CONFIG.LEFT_PANEL_WIDTH)                               // 左侧面板宽度（20%）
          .height('100%')                                                      // 左侧面板高度（100%）

          // ==================== 中间数据表格 ====================
          LevelDataTable({
            levelData: this.stateManager.levelData,                            // 等级数据
            statisticsData: this.stateManager.statisticsData,                  // 统计数据
            tableCount: this.stateManager.tableCount,                          // 表格数量
            onTableCountChange: (count: string) => {                           // 表格数量变化回调
              this.handleTableCountChange(count)
            }
          })
          .layoutWeight(1)                                                     // 中间面板占满剩余空间
          .height('100%')                                                      // 右侧面板高度（100%）

        }
        .width('100%')                                                         // 行宽度（100%）
        .height('100%')                                                        // 行高度（100%）
        .alignItems(VerticalAlign.Top)                                         // 垂直顶部对齐
      }
      .width('100%')                                                           // 列宽度（100%）
      .height('100%')                                                          // 列高度（100%）
      .backgroundColor(this.getCurrentTheme().pageBg ?? this.getCurrentTheme().backgroundColor)  // 背景色（主题页面背景色或背景色）
      .alignItems(HorizontalAlign.Start)                                       // 水平左对齐
      
      // ==================== 悬浮按钮 ====================
      if (this.showFloatingButtons) {
        Column() {
          // 确认按钮
          Button('确认')
            .width(80)
            .height(50)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .backgroundColor(this.getCurrentTheme().primary)
            .borderRadius(25)
            .shadow({ radius: 8, color: 'rgba(0,0,0,0.15)', offsetY: 4 })
            .animation({
              duration: 300,
              curve: Curve.EaseInOut
            })
            .onClick(() => {
              this.handleGenerateRandomData()
            })

          // 取消按钮
          Button('取消')
            .width(80)
            .height(50)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getCurrentTheme().textColor)
            .backgroundColor(Color.Transparent)
            .border({ width: 1, color: this.getCurrentTheme().borderColor })
            .borderRadius(25)
            .shadow({ radius: 8, color: 'rgba(0,0,0,0.15)', offsetY: 4 })
            .margin({ top: 12 })
            .animation({
              duration: 300,
              curve: Curve.EaseInOut
            })
            .onClick(() => {
              this.handleClearData()
            })
        }
        .position({ x: '100%', y: '50%' })
        .translate({ 
          x: this.isHovering ? -80 : -40, // 悬停时完全显示，半隐藏时一半在屏幕外
          y: -56 
        })
        .zIndex(100)
        .animation({
          duration: 300,
          curve: Curve.EaseInOut
        })
        .onHover((isHover: boolean) => {
          this.isHovering = isHover
        })
      }
      
      // ==================== 出口设置对话框 ====================
      // 放在Stack的最上层，覆盖整个页面
      LevelOutletDialog({
        showDialog: this.stateManager.showOutletDialog,                       // 对话框显示状态
        currentOutletIndex: this.stateManager.currentOutletIndex,              // 当前出口索引
        onOutletSwitch: (direction: 'previous' | 'next') => {                  // 出口切换回调
          this.handleOutletSwitch(direction)
        },
        onOutletConfirm: () => {                                               // 出口确认回调
          this.handleOutletConfirm()
        },
        onOutletCancel: () => {                                                // 出口取消回调
          this.handleOutletCancel()
        }
      })
    }
    .width('100%')                                                             // Stack宽度（100%）
    .height('100%')                                                             // Stack高度（100%）
  }

  // ==================== 生命周期方法 ====================
  /**
   * 组件即将出现时的生命周期方法
   * 
   * 功能说明：
   * - 在组件即将显示时调用
   * - 初始化页面数据和事件
   * - 设置页面初始状态
   * 
   * 初始化内容：
   * - 数据初始化：调用initializeData()初始化所有数据
   * - 事件初始化：调用eventHandler.onPageInit()初始化事件
   * 
   * 使用场景：
   * - 页面首次加载时
   * - 从其他页面返回时
   * - 组件重新显示时
   */
  aboutToAppear() {
    // 初始化数据
    this.initializeData()
    // 页面初始化事件
    this.eventHandler.onPageInit()
  }

  /**
   * 组件即将消失时的生命周期方法
   * 
   * 功能说明：
   * - 在组件即将隐藏时调用
   * - 清理页面资源和事件
   * - 保存页面状态
   * 
   * 清理内容：
   * - 事件清理：调用eventHandler.onPageDestroy()清理事件
   * - 资源清理：清理定时器、监听器等资源
   * - 状态保存：保存当前页面状态
   * 
   * 使用场景：
   * - 页面即将隐藏时
   * - 切换到其他页面时
   * - 组件即将销毁时
   */
  aboutToDisappear() {
    // 页面销毁事件
    this.eventHandler.onPageDestroy()
  }
}
