/**
 * 实时统计对话框组件
 * 功能：以弹窗形式展示实时统计摘要，交互样式与“水果信息”一致（标题/遮罩/按钮布局）
 */

import { ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { DialogButtons } from '../ui/dialogs/DialogButtons'
import { RectButton } from '../ui/buttons/RectButton'
import { ProcessingCurveChart } from '../charts/ProcessingCurveChart'
import { ChartComponent, ChartComponentParams, ChartData } from '../ChartComponent'
import { McPieChart, Options } from '@mcui/mccharts'
import { ExportStatisticsContent } from './ExportStatisticsContent'
import { HOME_SELECTED_FSM } from '../../constants/TopBarKeys'
import { ExportStatisticsHorizontalBarChart } from '../charts/ExportStatisticsHorizontalBarChart'
import { QualityStatisticsBarChart } from '../charts/QualityStatisticsBarChart'
import { AppearanceQualityStatisticsBarChart } from '../charts/AppearanceQualityStatisticsBarChart'
import { InternalQualityStatisticsBarChart } from '../charts/InternalQualityStatisticsBarChart'
import { WeightSizeStatisticsBarChart } from '../charts/WeightSizeStatisticsBarChart'
import { WeightSizeStatisticsTable } from '../tables/WeightSizeStatisticsTable'
import { GradeStatisticsTable } from '../tables/GradeStatisticsTable'
import { TimeEfficiencyLineChart } from '../charts/TimeEfficiencyLineChart'
import { PrintManager } from '../../utils/print/PrintManager'
import GlobalStore from '../../database/orm/model/GlobalStore'
import fs from '@ohos.file.fs'
import util from '@ohos.util'
import common from '@ohos.app.ability.common'

interface RealtimeStats {
  productionTonH: string
  sumWeightTon: string
  sumCounts: string
  avgG: string
}

// 图表数据项接口
interface ChartDataItem {
  time: string
  value: number
}

@Component
export struct RealtimeStatsDialog {
  @Prop isVisible: boolean = false
  // 为子图表提供主题，避免 @Consume 解析失败
  @Provide providedTheme: ExtendedOmniThemeStyle = getCurrentTheme()

  // 简要统计占位（可由外部传入或后续联动替换）
  @State stats: RealtimeStats = {
    productionTonH: '--',
    sumWeightTon: '--',
    sumCounts: '--',
    avgG: '--'
  }

  onConfirm?: (stats: RealtimeStats) => void
  onCancel?: () => void

  // 实时统计弹窗：按钮切换所对应的键集合与当前选中项
  private readonly tabLabels: string[] = [
    '出口统计信息',
    '品质统计信息',
    '外观品质统计信息',
    '内部品质统计信息',
    '重量/尺寸统计信息',
    '重量/尺寸统计表',
    '等级统计表',
    '时间效率图'
  ]

  // 为不同按钮提供不同的模拟数据
  private getChartDataForTab(tabName: string): ChartDataItem[] {
    const baseData: ChartDataItem[] = [
      { time: '08:00', value: 0 },
      { time: '08:30', value: 20 },
      { time: '09:00', value: 40 },
      { time: '09:30', value: 60 },
      { time: '10:00', value: 80 },
      { time: '10:30', value: 90 },
      { time: '11:00', value: 100 }
    ]

    switch (tabName) {
      case '出口统计信息':
        return baseData.map(item => {
          const newItem: ChartDataItem = { time: item.time, value: item.value * 1.2 }
          return newItem
        })
      case '品质统计信息':
        return baseData.map(item => {
          const newItem: ChartDataItem = { time: item.time, value: item.value * 0.8 }
          return newItem
        })
      case '外观品质统计信息':
        return baseData.map(item => {
          const newItem: ChartDataItem = { time: item.time, value: item.value * 0.9 }
          return newItem
        })
      case '内部品质统计信息':
        return baseData.map(item => {
          const newItem: ChartDataItem = { time: item.time, value: item.value * 0.85 }
          return newItem
        })
      case '重量/尺寸统计信息':
        return baseData.map(item => {
          const newItem: ChartDataItem = { time: item.time, value: item.value * 1.1 }
          return newItem
        })
      case '重量/尺寸统计表':
        return baseData.map(item => {
          const newItem: ChartDataItem = { time: item.time, value: item.value * 0.95 }
          return newItem
        })
      case '等级统计表':
        return baseData.map(item => {
          const newItem: ChartDataItem = { time: item.time, value: item.value * 1.05 }
          return newItem
        })
      case '时间效率图':
        return baseData.map(item => {
          const newItem: ChartDataItem = { time: item.time, value: item.value * 0.75 }
          return newItem
        })
      default:
        return baseData
    }
  }
  @State private selectedTabIndex: number = 0
  @State private contentRefreshKey: number = 0
  @State private currentInnerPage: string = '出口统计信息'
  // 实时统计对话框内的子系统选择（不影响全局FSM设置）
  @State private selectedSubsystem: string = 'ALL'

  private handleConfirm() {
    if (this.onConfirm) {
      this.onConfirm(this.stats)
    }
  }

  private handleCancel() {
    if (this.onCancel) {
      this.onCancel()
    }
  }

  // 获取当前选中的子系统值（用于下拉框显示，仅用于实时统计对话框内部）
  private getSelectedSubsystemValue(): string {
    return this.selectedSubsystem
  }

  /**
   * 构建控制栏（子系统选择器和按钮组）
   */
  @Builder
  buildControlBar() {
    Row() {
      // 左侧：子系统选择器
      Row() {
        Text('子系统:')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(getCurrentTheme().textColor)
          .margin({ right: 10 })
        
        Select([{ value: 'ALL' }, { value: '1' }, { value: '2' }])
          .value(this.getSelectedSubsystemValue())
          .font({ size: 16 })
          .onSelect((index: number, value: string) => {
            // 只更新本地状态，不影响全局FSM设置
            this.selectedSubsystem = value
          })
      }
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .layoutWeight(1)
      
      // 右侧：按钮组
      Row() {
        Button('批次比例刷新')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(getCurrentTheme().controlBg || getCurrentTheme().surfaceColor)
          .fontColor(getCurrentTheme().textColor)
          .height(36)
          .onClick(() => this.handleBatchRatioRefresh())
          .margin({ right: 10 })
        
        Button('实时比例刷新')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(getCurrentTheme().controlBg || getCurrentTheme().surfaceColor)
          .fontColor(getCurrentTheme().textColor)
          .height(36)
          .onClick(() => this.handleRealtimeRatioRefresh())
          .margin({ right: 10 })
        
        Button('导出')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(getCurrentTheme().primary)
          .fontColor('#FFFFFF')
          .height(36)
          .onClick(() => this.handleExport())
          .margin({ right: 10 })
        
        Button('打印')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(getCurrentTheme().primary)
          .fontColor('#FFFFFF')
          .height(36)
          .onClick(() => this.handlePrint())
      }
      .justifyContent(FlexAlign.End)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(getCurrentTheme().surfaceColor)
    .border({ width: 1, color: getCurrentTheme().borderColor })
    .borderRadius(8)
    .margin({ top: 12 })
  }

  /**
   * 构建等级统计表的控制栏（包含更新单价按钮）
   */
  @Builder
  buildControlBarForGradeTable() {
    Row() {
      // 左侧：子系统选择器
      Row() {
        Text('子系统:')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(getCurrentTheme().textColor)
          .margin({ right: 10 })

        Select([{ value: 'ALL' }, { value: '1' }, { value: '2' }])
          .value(this.getSelectedSubsystemValue())
          .font({ size: 16 })
          .onSelect((index: number, value: string) => {
            this.selectedSubsystem = value
          })
      }
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .layoutWeight(1)

      // 右侧：按钮组
      Row() {
        Button('批次比例刷新')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(getCurrentTheme().controlBg || getCurrentTheme().surfaceColor)
          .fontColor(getCurrentTheme().textColor)
          .height(36)
          .onClick(() => this.handleBatchRatioRefresh())
          .margin({ right: 10 })

        Button('实时比例刷新')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(getCurrentTheme().controlBg || getCurrentTheme().surfaceColor)
          .fontColor(getCurrentTheme().textColor)
          .height(36)
          .onClick(() => this.handleRealtimeRatioRefresh())
          .margin({ right: 10 })

        Button('导出')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(getCurrentTheme().primary)
          .fontColor('#FFFFFF')
          .height(36)
          .onClick(() => this.handleExport())
          .margin({ right: 10 })

        Button('打印')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(getCurrentTheme().primary)
          .fontColor('#FFFFFF')
          .height(36)
          .onClick(() => this.handlePrint())
          .margin({ right: 10 })

        Button('更新单价')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(getCurrentTheme().controlBg || getCurrentTheme().surfaceColor)
          .fontColor(getCurrentTheme().textColor)
          .height(36)
          .onClick(() => this.handleUpdateUnitPrice())
      }
      .justifyContent(FlexAlign.End)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(getCurrentTheme().surfaceColor)
    .border({ width: 1, color: getCurrentTheme().borderColor })
    .borderRadius(8)
    .margin({ top: 12 })
  }

  /**
   * 批次比例刷新
   */
  private handleBatchRatioRefresh(): void {
    console.log('[RealtimeStatsDialog] 批次比例刷新')
    // TODO: 从数据库获取批次数据并更新图表
    // 这里可以触发图表数据刷新
    this.contentRefreshKey++  // 触发内容刷新
  }

  /**
   * 实时比例刷新
   */
  private handleRealtimeRatioRefresh(): void {
    console.log('[RealtimeStatsDialog] 实时比例刷新')
    // TODO: 从数据库获取实时数据并更新图表
    // 这里可以触发图表数据刷新
    this.contentRefreshKey++  // 触发内容刷新
  }

  /**
   * 生成时间戳（格式：YYYY.MM.DD.HH.mm）
   */
  private generateTimestamp(): string {
    const now = new Date()
    const year = now.getFullYear()
    const month = String(now.getMonth() + 1).padStart(2, '0')
    const day = String(now.getDate()).padStart(2, '0')
    const hour = String(now.getHours()).padStart(2, '0')
    const minute = String(now.getMinutes()).padStart(2, '0')
    return `${year}.${month}.${day}.${hour}.${minute}`
  }

  /**
   * 导出统计数据
   */
  private async handleExport(): Promise<void> {
    try {
      console.log('[RealtimeStatsDialog] 开始导出统计数据')
      
      const context: common.UIAbilityContext | undefined = GlobalStore.context
      if (!context) {
        console.error('[RealtimeStatsDialog] 无法获取应用上下文')
        return
      }
      
      const filesDir: string = context.filesDir
      const timestamp = this.generateTimestamp()
      const fileName = `报告_${timestamp}.xlsx`
      const filePath = `${filesDir}/${fileName}`
      
      // 生成CSV内容（当前标签页的统计数据）
      const csvContent = this.generateExportData()
      
      if (!csvContent || csvContent.length === 0) {
        console.error('[RealtimeStatsDialog] 导出数据为空')
        return
      }
      
      // 使用 UTF-8 编码并添加 BOM（Excel 需要 BOM 才能正确识别 UTF-8）
      const textEncoder = new util.TextEncoder()
      const utf8BOM = new Uint8Array([0xEF, 0xBB, 0xBF]) // UTF-8 BOM
      const encodedContent = textEncoder.encode(csvContent)
      
      // 合并 BOM 和编码后的内容
      const finalContent = new Uint8Array(utf8BOM.length + encodedContent.length)
      finalContent.set(utf8BOM, 0)
      finalContent.set(encodedContent, utf8BOM.length)
      
      // 转换为 ArrayBuffer
      const arrayBuffer = finalContent.buffer.slice(0, finalContent.length)
      
      // 创建并写入文件
      const file = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY)
      fs.writeSync(file.fd, arrayBuffer)
      fs.closeSync(file)
      
      console.log(`[RealtimeStatsDialog] 导出成功: ${filePath}`)
      
      // 保存到公共目录
      await this.saveToPublicDirectory(filePath, fileName, csvContent)
      
    } catch (error) {
      console.error('[RealtimeStatsDialog] 导出失败:', error)
    }
  }

  /**
   * 生成导出数据（CSV格式）
   */
  private generateExportData(): string {
    const tabName = this.tabLabels[this.selectedTabIndex]
    let csvContent = `实时统计 - ${tabName}\n`
    csvContent += `导出时间,${new Date().toLocaleString('zh-CN')}\n`
    csvContent += `子系统,${this.selectedSubsystem}\n\n`
    
    // 根据当前标签页生成不同的数据
    if (tabName === '出口统计信息') {
      csvContent += '出口编号,FSM1数量,FSM2数量\n'
      // TODO: 从实际数据源获取出口统计数据
      for (let i = 0; i < 20; i++) {
        csvContent += `${i},0,0\n`
      }
    } else {
      csvContent += '数据项,数值\n'
      csvContent += '统计信息,待实现\n'
  }

    return csvContent
  }

  /**
   * 保存到公共目录
   */
  private async saveToPublicDirectory(filePath: string, fileName: string, csvContent: string): Promise<void> {
    try {
      const context: common.UIAbilityContext | undefined = GlobalStore.context
      if (!context) {
        return
      }
      
      // 尝试保存到多个可能的公共目录
      const targetPaths = [
        '/storage/emulated/0/Download/',
        '/sdcard/Download/',
        context.filesDir + '/'
      ]
      
      const textEncoder = new util.TextEncoder()
      const utf8BOM = new Uint8Array([0xEF, 0xBB, 0xBF])
      const encodedContent = textEncoder.encode(csvContent)
      const finalContent = new Uint8Array(utf8BOM.length + encodedContent.length)
      finalContent.set(utf8BOM, 0)
      finalContent.set(encodedContent, utf8BOM.length)
      const buffer = finalContent.buffer.slice(0, finalContent.length)
      
      let successCount = 0
      for (const targetPath of targetPaths) {
        try {
          const fullPath = `${targetPath}${fileName}`
          fs.mkdirSync(targetPath, true)
          const targetFile = fs.openSync(fullPath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY)
          fs.writeSync(targetFile.fd, buffer)
          fs.closeSync(targetFile)
          successCount++
          console.log(`[RealtimeStatsDialog] 成功保存到: ${fullPath}`)
        } catch (error) {
          console.warn(`[RealtimeStatsDialog] 保存到 ${targetPath} 失败:`, error)
        }
      }
      
      if (successCount > 0) {
        console.log(`[RealtimeStatsDialog] 文件已保存到 ${successCount} 个位置`)
      }
    } catch (error) {
      console.error('[RealtimeStatsDialog] 保存到公共目录失败:', error)
    }
  }

  /**
   * 打印统计数据
   */
  private async handlePrint(): Promise<void> {
    try {
      console.log('[RealtimeStatsDialog] 开始打印统计数据')
      
      const context: common.UIAbilityContext | undefined = GlobalStore.context
      if (!context) {
        console.error('[RealtimeStatsDialog] 无法获取应用上下文')
        return
      }
      
      // 先导出为文件，然后打印
      const filesDir: string = context.filesDir
      const timestamp = this.generateTimestamp()
      const fileName = `报告_${timestamp}.xlsx`
      const filePath = `${filesDir}/${fileName}`
      
      // 生成CSV内容
      const csvContent = this.generateExportData()
      
      if (!csvContent || csvContent.length === 0) {
        console.error('[RealtimeStatsDialog] 打印数据为空')
        return
      }
      
      // 使用 UTF-8 编码并添加 BOM
      const textEncoder = new util.TextEncoder()
      const utf8BOM = new Uint8Array([0xEF, 0xBB, 0xBF])
      const encodedContent = textEncoder.encode(csvContent)
      const finalContent = new Uint8Array(utf8BOM.length + encodedContent.length)
      finalContent.set(utf8BOM, 0)
      finalContent.set(encodedContent, utf8BOM.length)
      const arrayBuffer = finalContent.buffer.slice(0, finalContent.length)
      
      // 创建并写入文件
      const file = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY)
      fs.writeSync(file.fd, arrayBuffer)
      fs.closeSync(file)
      
      // 使用 PrintManager 打印文件
      const printManager = PrintManager.getInstance()
      const fileUri = `file://${filePath}`
      await printManager.printSingleFile(context, fileUri)
      
      console.log(`[RealtimeStatsDialog] 打印成功: ${filePath}`)
      
    } catch (error) {
      console.error('[RealtimeStatsDialog] 打印失败:', error)
    }
  }

  /**
   * 更新单价
   */
  private handleUpdateUnitPrice(): void {
    console.log('[RealtimeStatsDialog] 更新单价')
    // TODO: 实现更新单价的逻辑
    // 这里可以打开一个对话框让用户输入新的单价，或者从数据库/API获取最新单价
  }

  build(): void {
    if (this.isVisible) {
      Stack() {
        // 遮罩层
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .onClick(() => {
            this.handleCancel()
          })
        
        // 内容卡片
        Column() {
          // 标题栏
          Row() {
            Text('实时统计')
              .fontSize(24)  // 标题字体调大到24px
              .fontWeight(FontWeight.Bold)
              .fontColor(getCurrentTheme().textColor)
              .layoutWeight(1)

            Button() {
              Text('×')
                .fontSize(24)  // 关闭按钮字体调大到24px
                .fontColor(getCurrentTheme().textColor)
            }
            .width(30)
            .height(30)
            .backgroundColor('#00000000')
            .onClick(() => this.handleCancel())
          }
          .width('100%')
          .padding({ left: 12, right: 12, top: 10, bottom: 10 })
          .border({ width: { bottom: 1 }, color: getCurrentTheme().borderColor })

          // 清空内容，仅保留标题（去掉与标题的间距，贴紧顶部）
          Blank().height(0)

          // 一行8个按钮的卡片容器（顶部贴紧）
          Column() {
            // 按钮行
            Row() {
              ForEach(this.tabLabels, (label: string, idx: number) => {
                // 参考主页风格，使用 RectButton
                Column() {
                  RectButton({
                    text: label,
                    widthPx: 120,  // 按钮宽度调大到120px
                    heightPx: 44,  // 按钮高度调大到44px
                    marginLeftPx: 2,
                    marginRightPx: 2,
                    fontSizePx: 16,  // 按钮字体调大到16px
                    isActive: this.selectedTabIndex === idx,
                    borderRadiusPx: 8,  // 圆角调大到8px
                    enableClickFeedback: true,
                    onTap: () => {
                      this.selectedTabIndex = idx
                      this.currentInnerPage = label
                      this.contentRefreshKey++
                    }
                  })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Center)
              }, (_label: string, idx: number) => `${idx}`)
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .padding(12)
          .backgroundColor(Color.Transparent)
          .border({ width: 0, color: '#00000000' })
          .borderRadius(0)
          .margin({ top: 0, bottom: 8, left: 12, right: 12 })

          // 下方大卡片：占据剩余空间，依据所选按钮切换内容（仿主页 if/else 渲染）
          Column() {
            if (this.currentInnerPage === '出口统计信息') {
              // 中间区域：水平条形图
              ExportStatisticsHorizontalBarChart({
                title: '出口统计信息',
                chartHeight: 500,
                selectedSubsystem: this.selectedSubsystem
              })
                .key(`export-chart-${this.selectedSubsystem}`)  // 使用key强制重新创建组件
                .width('100%')
                .layoutWeight(1)
              
              // 底部控制栏
              this.buildControlBar()
            } else if (this.currentInnerPage === '品质统计信息') {
              // 中间区域：品质统计柱状图（个数和重量）
              QualityStatisticsBarChart({
                title: '品质统计信息',
                chartHeight: 500,
                selectedSubsystem: this.selectedSubsystem
              })
                .key(`quality-chart-${this.selectedSubsystem}`)
                .width('100%')
                .layoutWeight(1)
              
              // 底部控制栏
              this.buildControlBar()
            } else if (this.currentInnerPage === '外观品质统计信息') {
              // 中间区域：外观品质统计柱状图（个数和重量）
              AppearanceQualityStatisticsBarChart({
                title: '外观品质统计信息',
                chartHeight: 500,
                selectedSubsystem: this.selectedSubsystem
              })
                .key(`appearance-quality-chart-${this.selectedSubsystem}`)
                .width('100%')
                .layoutWeight(1)
              
              // 底部控制栏
              this.buildControlBar()
            } else if (this.currentInnerPage === '内部品质统计信息') {
              // 中间区域：内部品质统计柱状图（个数和重量）
              InternalQualityStatisticsBarChart({
                title: '内部品质统计信息',
                chartHeight: 500,
                selectedSubsystem: this.selectedSubsystem
              })
                .key(`internal-quality-chart-${this.selectedSubsystem}`)
                .width('100%')
                .layoutWeight(1)
              
              // 底部控制栏
              this.buildControlBar()
            } else if (this.currentInnerPage === '重量/尺寸统计信息') {
              // 中间区域：重量/尺寸统计图表
              WeightSizeStatisticsBarChart({
                title: '重量/尺寸统计信息',
                chartHeight: 500,
                selectedSubsystem: this.selectedSubsystem
              })
                .key(`weight-size-chart-${this.selectedSubsystem}`)
                .width('100%')
                .layoutWeight(1)
              
              // 底部控制栏
              this.buildControlBar()
            } else if (this.currentInnerPage === '重量/尺寸统计表') {
              // 重量/尺寸统计表内容
              WeightSizeStatisticsTable({
                selectedSubsystem: this.selectedSubsystem
                    })
                .key(`weight-size-table-${this.selectedSubsystem}`)
                .width('100%')
                .layoutWeight(1)
              
              // 底部控制栏
              this.buildControlBar()
            } else if (this.currentInnerPage === '等级统计表') {
              // 等级统计表内容
              GradeStatisticsTable({
                selectedSubsystem: this.selectedSubsystem
              })
                .key(`grade-statistics-table-${this.selectedSubsystem}`)
              .width('100%')
                .layoutWeight(1)
              
              // 底部控制栏（包含更新单价按钮）
              this.buildControlBarForGradeTable()
            } else {
              // 时间效率图 - 不显示控制栏
              TimeEfficiencyLineChart({
                chartHeight: 500,
                selectedSubsystem: this.selectedSubsystem
              })
                .key(`time-efficiency-${this.selectedSubsystem}`)
                .width('100%')
                .layoutWeight(1)
            }
          }
          .width('100%')
          .layoutWeight(1)
          .padding(12)
          .backgroundColor(getCurrentTheme().surfaceColor)
          .border({ width: 1, color: getCurrentTheme().borderColor })
          .borderRadius(10)
          .margin({ top: 0, bottom: 12, left: 8, right: 8 })
          .id(`rt-page-${this.currentInnerPage}-${this.contentRefreshKey}`)
        }
        .width('90%')  // 调整宽度为95%，更大
        .padding({ left: 10, right: 10, top: 0, bottom: 12 })
        .height('95%')  // 固定高度90%，更大
        .backgroundColor(getCurrentTheme().surfaceColor)
        .borderRadius(12)
        .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 4 })
        .align(Alignment.Top)  // 顶部对齐，而不是居中
        // .margin({ top: '5%' })  // 距离顶部5%，留出底部空间
      }
      .width('100%')
      .height('100%')
      .zIndex(1000)  // 确保对话框在最上层
    }
  }

  @Builder
  private buildStatRow(label: string, value: string): void {
    Row() {
      Text(label)
        .fontSize(18)  // 统计标签字体调大到18px
        .fontColor(getCurrentTheme().textColor)
        .layoutWeight(1)
        .textOverflow({ overflow: TextOverflow.Clip })
      Text(value)
        .fontSize(18)  // 统计值字体调大到18px
        .fontColor(getCurrentTheme().primary)
        .textAlign(TextAlign.End)
        .constraintSize({ minWidth: 80 })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .padding({ top: 6, bottom: 6 })
  }
}


