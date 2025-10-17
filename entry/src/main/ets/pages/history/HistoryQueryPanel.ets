/**
 * 历史加工查询条件区域组件
 * 
 * 功能说明：
 * - 包含3个小卡片的查询条件区域
 * - 日期条件查询卡片（25%宽度）
 * - 客户信息查询卡片（30%宽度）
 * - 操作按钮卡片（40%宽度）
 * 
 * 布局说明：
 * - 使用Row布局水平排列3个卡片
 * - 每个卡片都有独立的样式和功能
 * - 支持响应式布局
 */

import { BaseComponentHelper } from '../../components/common/BaseComponent'
import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { DateQueryCard } from './DateQueryCard'
import { CustomerQueryCard } from './CustomerQueryCard'
import { ActionButtonsCard } from './ActionButtonsCard'

/**
 * 历史加工查询条件区域组件结构体
 * 
 * 属性说明：
 * - startDate: 开始日期
 * - endDate: 结束日期
 * - selectedStartDate: 选中的开始日期
 * - selectedEndDate: 选中的结束日期
 * - customerIndex: 客户选择索引
 * - farmIndex: 农场选择索引
 * - fruitIndex: 水果选择索引
 * - onStartDateChange: 开始日期变化回调
 * - onEndDateChange: 结束日期变化回调
 * - onCustomerChange: 客户选择变化回调
 * - onFarmChange: 农场选择变化回调
 * - onFruitChange: 水果选择变化回调
 * - onQueryClick: 查询按钮点击回调
 * - onMergeExportClick: 合并导出按钮点击回调
 * - onReportClick: 报告按钮点击回调
 * - onDeleteClick: 删除按钮点击回调
 * - onResetClick: 重置按钮点击回调
 * - onBatchExportClick: 批量导出按钮点击回调
 * - onLevelMergeExportClick: 等级合并导出按钮点击回调
 * 
 * 方法说明：
 * - getCurrentTheme(): 获取当前主题配置
 * - build(): 构建查询条件区域的UI结构
 */
@Component
export struct HistoryQueryPanel {
  // ==================== 日期相关属性 ====================
  /** 开始日期 */
  @Prop startDate: string = ''
  /** 结束日期 */
  @Prop endDate: string = ''
  /** 选中的开始日期 */
  @Prop selectedStartDate: Date = new Date()
  /** 选中的结束日期 */
  @Prop selectedEndDate: Date = new Date()
  
  // ==================== 选择相关属性 ====================
  /** 客户选择索引 */
  @Prop customerIndex: number = 0
  /** 农场选择索引 */
  @Prop farmIndex: number = 0
  /** 水果选择索引 */
  @Prop fruitIndex: number = 0

  // ==================== 事件回调函数 ====================
  /** 开始日期变化回调函数 */
  onStartDateChange?: (date: string) => void
  /** 结束日期变化回调函数 */
  onEndDateChange?: (date: string) => void
  /** 客户选择变化回调函数 */
  onCustomerChange?: (index: number) => void
  /** 农场选择变化回调函数 */
  onFarmChange?: (index: number) => void
  /** 水果选择变化回调函数 */
  onFruitChange?: (index: number) => void
  /** 查询按钮点击回调函数 */
  onQueryClick?: () => void
  /** 合并导出按钮点击回调函数 */
  onMergeExportClick?: () => void
  /** 报告按钮点击回调函数 */
  onReportClick?: () => void
  /** 删除按钮点击回调函数 */
  onDeleteClick?: () => void
  /** 重置按钮点击回调函数 */
  onResetClick?: () => void
  /** 批量导出按钮点击回调函数 */
  onBatchExportClick?: () => void
  /** 等级合并导出按钮点击回调函数 */
  onLevelMergeExportClick?: () => void
  /** 日期错误回调函数 */
  onDateError?: () => void

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
   * - 构建查询条件区域的UI结构
   * - 实现3个卡片的水平排列布局
   * - 处理各个卡片的事件传递
   * 
   * 布局说明：
   * - 使用Row布局水平排列3个卡片
   * - 日期条件查询卡片：25%宽度
   * - 客户信息查询卡片：30%宽度
   * - 操作按钮卡片：40%宽度
   * - 卡片间有适当间距
   * 
   * 样式说明：
   * - 卡片样式：白色背景，圆角设计，阴影效果
   * - 响应式设计：支持不同屏幕尺寸
   * - 主题支持：支持主题切换和样式更新
   */
  build() {
    Row() {
      // ==================== 日期条件查询卡片 ====================
      DateQueryCard({
        startDate: this.startDate,
        endDate: this.endDate,
        selectedStartDate: this.selectedStartDate,
        selectedEndDate: this.selectedEndDate,
        onStartDateChange: (date: string) => {
          if (this.onStartDateChange) {
            this.onStartDateChange(date)
          }
        },
        onEndDateChange: (date: string) => {
          if (this.onEndDateChange) {
            this.onEndDateChange(date)
          }
        }
      })
      .width('25%')
      .margin({ right: 8 })

      // ==================== 客户信息查询卡片 ====================
      CustomerQueryCard({
        customerIndex: this.customerIndex,
        farmIndex: this.farmIndex,
        fruitIndex: this.fruitIndex,
        onCustomerChange: (index: number) => {
          if (this.onCustomerChange) {
            this.onCustomerChange(index)
          }
        },
        onFarmChange: (index: number) => {
          if (this.onFarmChange) {
            this.onFarmChange(index)
          }
        },
        onFruitChange: (index: number) => {
          if (this.onFruitChange) {
            this.onFruitChange(index)
          }
        }
      })
      .width('30%')
      .margin({ right: 8 })

      // ==================== 操作按钮卡片 ====================
      ActionButtonsCard({
        startDate: this.startDate,
        endDate: this.endDate,
        selectedStartDate: this.selectedStartDate,
        selectedEndDate: this.selectedEndDate,
        onQueryClick: () => {
          if (this.onQueryClick) {
            this.onQueryClick()
          }
        },
        onMergeExportClick: () => {
          if (this.onMergeExportClick) {
            this.onMergeExportClick()
          }
        },
        onReportClick: () => {
          if (this.onReportClick) {
            this.onReportClick()
          }
        },
        onDeleteClick: () => {
          if (this.onDeleteClick) {
            this.onDeleteClick()
          }
        },
        onResetClick: () => {
          if (this.onResetClick) {
            this.onResetClick()
          }
        },
        onBatchExportClick: () => {
          if (this.onBatchExportClick) {
            this.onBatchExportClick()
          }
        },
        onLevelMergeExportClick: () => {
          if (this.onLevelMergeExportClick) {
            this.onLevelMergeExportClick()
          }
        },
        onDateError: () => {
          if (this.onDateError) {
            this.onDateError()
          }
        }
      })
      .width('40%')
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Top)
  }
}
