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

import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme as resolveTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { DateQueryCard } from './DateQueryCard'
import { CustomerQueryCard } from './CustomerQueryCard'
import { ActionButtonsCard } from './ActionButtonsCard'
import { HistoryTableData } from './core/HistoryTableManager'

/**
 * 历史加工查询条件区域组件结构体
 * 
 * 属性说明：
 * - startDate: 开始日期
 * - endDate: 结束日期
 * - selectedStartDate: 选中的开始日期
 * - selectedEndDate: 选中的结束日期
 * - customerName: 客户名称输入值
 * - farmName: 农场名称输入值
 * - fruitName: 水果品种输入值
 * - onStartDateChange: 开始日期变化回调
 * - onEndDateChange: 结束日期变化回调
 * - onCustomerChange: 客户名称输入变化回调
 * - onFarmChange: 农场名称输入变化回调
 * - onFruitChange: 水果品种输入变化回调
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
  /** 客户名称输入值 */
  @Prop customerName: string = ''
  /** 农场名称输入值 */
  @Prop farmName: string = ''
  /** 水果品种输入值 */
  @Prop fruitName: string = ''

  // ==================== 事件回调函数 ====================
  /** 开始日期变化回调函数 */
  onStartDateChange?: (date: string) => void
  /** 结束日期变化回调函数 */
  onEndDateChange?: (date: string) => void
  /** 客户名称输入变化回调函数 */
  onCustomerChange?: (value: string) => void
  /** 农场名称输入变化回调函数 */
  onFarmChange?: (value: string) => void
  /** 水果品种输入变化回调函数 */
  onFruitChange?: (value: string) => void
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
  /** 导出成功回调函数 */
  onExportSuccess?: (filePath: string, count: number) => void
  /** 获取表格数据回调函数 */
  onGetTableData?: () => HistoryTableData[]
  /** 获取选中数据回调函数 */
  onGetSelectedData?: () => HistoryTableData[]
  /** 显示文件命名对话框回调函数 */
  onShowFileNameDialog?: (exportType: string) => void

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
        customerName: this.customerName,
        farmName: this.farmName,
        fruitName: this.fruitName,
        onCustomerChange: (value: string) => {
          if (this.onCustomerChange) {
            this.onCustomerChange(value)
          }
        },
        onFarmChange: (value: string) => {
          if (this.onFarmChange) {
            this.onFarmChange(value)
          }
        },
        onFruitChange: (value: string) => {
          if (this.onFruitChange) {
            this.onFruitChange(value)
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
        },
        onExportSuccess: (filePath: string, count: number) => {
          if (this.onExportSuccess) {
            this.onExportSuccess(filePath, count)
          }
        },
        onGetTableData: () => {
          if (this.onGetTableData) {
            return this.onGetTableData()
          }
          return []
        },
        onGetSelectedData: () => {
          if (this.onGetSelectedData) {
            return this.onGetSelectedData()
          }
          return []
        },
        onShowFileNameDialog: (exportType: string) => {
          if (this.onShowFileNameDialog) {
            this.onShowFileNameDialog(exportType)
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
