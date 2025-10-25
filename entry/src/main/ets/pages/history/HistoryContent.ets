/**
 * 历史加工内容组件
 * 
 * 功能说明：
 * - 显示历史加工相关的内容和功能
 * - 包含查询条件区域和数据表格区域
 * - 集成 Omni-UI 主题系统
 * 
 * 组件结构：
 * - 查询条件区域：包含日期查询、客户信息查询、操作按钮
 * - 数据表格区域：显示加工历史数据表
 * 
 * 使用方式：
 * ```typescript
 * HistoryContent()
 * ```
 */

import { BaseComponentHelper } from '../../components/common/BaseComponent'
import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { HistoryQueryPanel } from './HistoryQueryPanel'
import { HistoryDataTable } from './HistoryDataTable'
import { HistoryTableData } from './core/HistoryTableManager'
import { DateErrorDialog } from '../../components/dialogs/DateErrorDialog'
import { ExportSuccessDialog } from '../../components/dialogs/ExportSuccessDialog'

/**
 * 历史加工内容组件结构体
 * 
 * 属性说明：
 * - startDate: 开始日期字符串
 * - endDate: 结束日期字符串
 * - selectedStartDate: 选中的开始日期对象
 * - selectedEndDate: 选中的结束日期对象
 * - customerIndex: 客户选择索引
 * - farmIndex: 农场选择索引
 * - fruitIndex: 水果选择索引
 * 
 * 方法说明：
 * - getCurrentTheme(): 获取当前主题配置
 * - build(): 构建历史加工内容的UI结构
 */
@Component
export struct HistoryContent {
  // ==================== 日期相关状态 ====================
  /** 开始日期字符串 */
  @State startDate: string = ''
  /** 结束日期字符串 */
  @State endDate: string = ''
  /** 选中的开始日期对象 */
  @State selectedStartDate: Date = new Date()
  /** 选中的结束日期对象 */
  @State selectedEndDate: Date = new Date()
  
  // ==================== 选择相关状态 ====================
  /** 客户选择索引 */
  @State customerIndex: number = 0
  /** 农场选择索引 */
  @State farmIndex: number = 0
  /** 水果选择索引 */
  @State fruitIndex: number = 0
  
  // ==================== 主题相关属性 ====================
  /** 当前主题样式 */
  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  /** 当前主题类型 */
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: OmniThemeType = OmniThemeManager.getInstance().getCurrentThemeType()
  /** 主题版本号 */
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0
  /** 基础组件助手 */
  private baseComponentHelper = new BaseComponentHelper()
  
  // ==================== 对话框状态 ====================
  /** 日期错误对话框显示状态 */
  @State private showDateErrorDialog: boolean = false
  /** 导出成功对话框显示状态 */
  @State private showExportSuccessDialog: boolean = false
  /** 导出文件路径 */
  @State private exportFilePath: string = ''
  /** 导出数据条数 */
  @State private exportCount: number = 0

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
   * 显示日期错误对话框
   */
  private showDateErrorDialogHandler(): void {
    this.showDateErrorDialog = true
  }

  /**
   * 关闭日期错误对话框
   */
  private closeDateErrorDialog(): void {
    this.showDateErrorDialog = false
  }

  /**
   * 处理导出成功
   */
  private handleExportSuccess(filePath: string, count: number): void {
    this.exportFilePath = filePath
    this.exportCount = count
    this.showExportSuccessDialog = true
  }

  /**
   * 关闭导出成功对话框
   */
  private closeExportSuccessDialog(): void {
    this.showExportSuccessDialog = false
  }

  
  /**
   * 组件构建方法
   * 
   * 功能：
   * - 构建历史加工内容的UI结构
   * - 实现查询条件区域和数据表格区域的布局
   * - 处理组件间的事件传递
   * 
   * 布局说明：
   * - 使用Column布局垂直排列
   * - 查询条件区域：包含3个小卡片的Row布局
   * - 数据表格区域：显示加工历史数据表
   * 
   * 样式说明：
   * - 页面样式：主题背景色，响应式布局
   * - 卡片样式：白色背景，圆角设计，阴影效果
   * - 组件间距：合理的组件间距设计
   */
  build() {
    Stack() {
      Column() {
        // ==================== 查询条件区域 ====================
        Column() {
          HistoryQueryPanel({
          startDate: this.startDate,
          endDate: this.endDate,
          selectedStartDate: this.selectedStartDate,
          selectedEndDate: this.selectedEndDate,
          customerIndex: this.customerIndex,
          farmIndex: this.farmIndex,
          fruitIndex: this.fruitIndex,
          onStartDateChange: (date: string) => {
            this.startDate = date
          },
          onEndDateChange: (date: string) => {
            this.endDate = date
          },
          onCustomerChange: (index: number) => {
                this.customerIndex = index
          },
          onFarmChange: (index: number) => {
                this.farmIndex = index
          },
          onFruitChange: (index: number) => {
                this.fruitIndex = index
          },
          onQueryClick: () => {
            console.log('查询按钮被点击')
          },
          onMergeExportClick: () => {
            console.log('合并导出按钮被点击')
          },
          onReportClick: () => {
            console.log('报告按钮被点击')
          },
          onDeleteClick: () => {
            console.log('删除按钮被点击')
          },
          onResetClick: () => {
            console.log('重置按钮被点击')
          },
          onBatchExportClick: () => {
            console.log('批量导出按钮被点击')
          },
          onLevelMergeExportClick: () => {
            console.log('等级合并导出按钮被点击')
          },
          onDateError: () => {
            this.showDateErrorDialogHandler()
          },
          onExportSuccess: (filePath: string, count: number) => {
            this.handleExportSuccess(filePath, count)
          }
        })
                  }
                  .width('100%')
                  .height('20%')
                  .padding(8)
                  .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                  .border({ width: 1, color: this.getCurrentTheme().borderColor })
                  .borderRadius(6)
                  .shadow({ radius: 2, color: 'rgba(0,0,0,0.1)', offsetY: 1 })
                  .margin({ top: 8, bottom: 8, left: 16, right: 16 })

        // ==================== 数据表格区域 ====================
        HistoryDataTable({
          onRowClick: (rowData: HistoryTableData) => {
            console.log('点击行数据:', rowData)
          },
          onEditClick: (rowData: HistoryTableData) => {
            console.log('编辑行数据:', rowData)
          },
          onDeleteClick: (rowData: HistoryTableData) => {
            console.log('删除行数据:', rowData)
          }
        })

      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(this.getCurrentTheme().pageBg ?? this.getCurrentTheme().backgroundColor)

      // ==================== 日期错误对话框 ====================
      DateErrorDialog({
        isVisible: this.showDateErrorDialog,
        onConfirm: () => {
          this.closeDateErrorDialog()
        },
        onCancel: () => {
          this.closeDateErrorDialog()
        }
      })

      // ==================== 导出成功对话框 ====================
      ExportSuccessDialog({
        isVisible: this.showExportSuccessDialog,
        filePath: this.exportFilePath,
        exportCount: this.exportCount,
        onConfirm: () => {
          this.closeExportSuccessDialog()
        }
      })
    }
  }
}