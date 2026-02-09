/**
 * 数据表格TabBar组件
 */

import { LevelTable, TableRow } from '../../components/layout/LevelTable'
import { GridTable } from '../../components/layout/GridTable'
import { DraggableGridTable, DragData } from '../../components/layout/DraggableGridTable'
import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme as resolveTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { t, I18N_VERSION_KEY } from '../../utils/i18n/I18nManager'
import { ChartComponent, ChartComponentParams, ChartData } from '../../components/ChartComponent'
import { BarChart } from '../../components/charts/BarChart'
import { TabConfig } from '../../components/ui/layout/OmniTabBar'
import { drawLineChart, measureChartWidth, LineChartOptions } from  '../../utils/charts/lineChart'
import { ProcessingCurveFeed } from '../../utils/data/ProcessingCurveFeed'
import { TableHeaderCell } from '../../components/ui/tables/TableHeaderCell'
import { TableCell } from '../../components/ui/tables/TableCell'

// 图表颜色配置接口
interface ChartColors {
  background: string
  axis: string
  grid: string
  line: string
  pointFill: string
  pointStroke: string
  axisText: string
  labelText: string
}

@Component
export struct DataTablesTabBar {
  private lineCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D()
  // 折线图参数与数据（使用环形缓冲区避免内存增长）
  private readonly lcChartHeight: number = 340
  private readonly LC_MAX_POINTS: number = 60
  // 固定长度环形缓冲区（避免 concat/slice 创建新数组）
  private lcDataBuffer: number[] = new Array(this.LC_MAX_POINTS).fill(0)
  private lcLabelsBuffer: string[] = new Array(this.LC_MAX_POINTS).fill('')
  // 写入索引（0-59循环）
  private lcWriteIndex: number = 0
  // 有效数据点数量（0-60）
  private lcValidCount: number = 0
  // 用于UI显示的数据（只读，从缓冲区提取）
  @State lcData: number[] = []
  @State lcLabels: string[] = []
  // 不再在组件内生成数据，改为全局数据源；仅保留重绘定时器
  private lcTimerId?: number
  private lcFlushTimerId?: number
  private lcCurrentValue: number = 50
  private lcTimeIndex: number = 0
  private lcRealtimeEnabled: boolean = false
  // 缓存的颜色配置对象（避免每次重绘新建）
  private cachedColors: ChartColors | null = null
  
  // McLineChart 配置
  // Removed McCharts Options state after reverting to Canvas implementation

  // 主题相关
  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: OmniThemeType = OmniThemeManager.getInstance().getCurrentThemeType()
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0  // 监听语言变化，触发 UI 更新
  
  // 提供主题给子组件
  @Provide providedTheme: ExtendedOmniThemeStyle = this.consumedTheme

  // 当前选中的Tab
  @State selectedTab: string = '等级表'

  // 表格数据
  @Prop levelTableData: TableRow[] = []
  @Prop levelHeaderTitles: string[] = []
  @Prop containerTableData: TableRow[] = []
  @Prop statisticsTableData: TableRow[] = []
  @Prop dynamicPackingTableData: TableRow[] = []
  @Prop finishedProductsTableData: TableRow[] = []
  
  // 刷新键，用于强制刷新表格
  @Prop refreshKey: number = 0

  // 拖拽数据
  @Prop levelTableDragData: DragData[] = []
  @Prop containerTableDragData: DragData[] = []
  @Prop statisticsTableDragData: DragData[] = []
  @Prop dynamicPackingTableDragData: DragData[] = []
  @Prop finishedProductsTableDragData: DragData[] = []

  // 拖拽事件回调
  onRowDragStart?: (dragData: DragData) => void
  onRowDragEnd?: () => void
  

  // 获取当前主题配置
  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return resolveTheme(this.consumedTheme)
  }

  // 处理拖拽开始
  private handleDragStart(dragData: DragData) {
    console.log('DataTablesTabBar - 拖拽开始:', dragData)
    if (this.onRowDragStart) {
      this.onRowDragStart(dragData)
    }
  }

  // 处理拖拽结束
  private handleDragEnd() {
    console.log('DataTablesTabBar - 拖拽结束')
    if (this.onRowDragEnd) {
      this.onRowDragEnd()
    }
  }

  // 更新折线图配置（初始化或主题变化时调用）
  // Removed: updateLineChartOptions() – no longer needed for Canvas implementation


  // 从环形缓冲区提取数据（用于UI显示）
  // 注意：虽然会创建新数组，但频率已从"每次数据更新"降至"每200ms一次"，且数组大小固定（最多60），不会无限增长
  private extractDataFromBuffer(): void {
    if (this.lcValidCount === 0) {
      this.lcData = []
      this.lcLabels = []
      return
    }
    // 从写入位置向前读取 lcValidCount 个元素（循环读取）
    const result: number[] = new Array(this.lcValidCount)
    const labels: string[] = new Array(this.lcValidCount)
    for (let i = 0; i < this.lcValidCount; i++) {
      const idx = (this.lcWriteIndex - this.lcValidCount + i + this.LC_MAX_POINTS) % this.LC_MAX_POINTS
      result[i] = this.lcDataBuffer[idx]
      labels[i] = this.lcLabelsBuffer[idx]
    }
    this.lcData = result
    this.lcLabels = labels
  }

  // 获取或创建缓存的颜色配置（避免每次重绘新建对象）
  private getCachedColors(): ChartColors {
    if (!this.cachedColors) {
      const theme = this.getCurrentTheme()
      this.cachedColors = {
        background: (theme.chartBg ?? theme.surfaceColor) as string,
        axis: theme.borderColor as string,
        grid: (theme.borderColor as string) + '40',
        line: (theme.chartLineColor ?? theme.primary) as string,
        pointFill: (theme.chartLineColor ?? theme.primary) as string,
        pointStroke: theme.surfaceColor as string,
        axisText: theme.textColor as string,
        labelText: theme.textColor as string
      }
    }
    return this.cachedColors
  }

  // 刷新颜色缓存（主题变化时调用）
  private refreshColorCache(): void {
    this.cachedColors = null
  }

  // 仅控制UI重绘的定时器（数据源持续运行）
  private startFlushTimer(): void {
    if (this.lcFlushTimerId) { return }
    this.lcFlushTimerId = setInterval(() => {
      const snap = ProcessingCurveFeed.getInstance().getSnapshot()
      this.lcValidCount = Math.min(this.LC_MAX_POINTS, snap.validCount)
      this.lcWriteIndex = snap.writeIndex % this.LC_MAX_POINTS
      // 直接使用快照数据，避免重复复制（快照数据已经是复用数组）
      // 但需要复制到本地缓冲区，因为快照数据可能被下次调用覆盖
      for (let i = 0; i < this.lcValidCount; i++) {
        const idx = (this.lcWriteIndex - this.lcValidCount + i + this.LC_MAX_POINTS) % this.LC_MAX_POINTS
        this.lcDataBuffer[idx] = snap.data[i]
        this.lcLabelsBuffer[idx] = snap.labels[i]
      }
      this.extractDataFromBuffer()
      this.redrawChart()
    }, 15000) as number
  }

  private stopFlushTimer(): void {
    if (this.lcFlushTimerId) {
      clearInterval(this.lcFlushTimerId)
      this.lcFlushTimerId = undefined
    }
  }

  // ========== 外部数据传入接口 ==========
  
  /**
   * 追加单个数据点到折线图
   * @param value 数据值
   * @param label 时间标签（如 "09:30"）
   */
  appendLineChartData(value: number, label: string): void {
    // 直接写入环形缓冲区（覆盖旧数据）
    this.lcDataBuffer[this.lcWriteIndex] = value
    this.lcLabelsBuffer[this.lcWriteIndex] = label
    this.lcWriteIndex = (this.lcWriteIndex + 1) % this.LC_MAX_POINTS
    this.lcValidCount = Math.min(this.lcValidCount + 1, this.LC_MAX_POINTS)
    // 立即更新显示（可选，如果希望立即看到效果）
    this.extractDataFromBuffer()
    this.redrawChart()
  }

  /**
   * 批量追加数据点到折线图
   * @param data 数据值数组
   * @param labels 时间标签数组（长度需与data相同）
   */
  appendLineChartDataBatch(data: number[], labels: string[]): void {
    if (data.length !== labels.length) {
      console.error('appendLineChartDataBatch: data和labels长度不匹配')
      return
    }
    for (let i = 0; i < data.length; i++) {
      this.lcDataBuffer[this.lcWriteIndex] = data[i]
      this.lcLabelsBuffer[this.lcWriteIndex] = labels[i]
      this.lcWriteIndex = (this.lcWriteIndex + 1) % this.LC_MAX_POINTS
      this.lcValidCount = Math.min(this.lcValidCount + 1, this.LC_MAX_POINTS)
    }
    // 批量更新后统一刷新显示
    this.extractDataFromBuffer()
    this.redrawChart()
  }

  /**
   * 设置折线图的完整数据（覆盖模式，清空旧数据）
   * @param data 数据值数组（最多60个，超出部分会被截断）
   * @param labels 时间标签数组（长度需与data相同）
   */
  setLineChartData(data: number[], labels: string[]): void {
    if (data.length !== labels.length) {
      console.error('setLineChartData: data和labels长度不匹配')
      return
    }
    // 清空缓冲区
    this.lcWriteIndex = 0
    this.lcValidCount = 0
    // 写入新数据（最多60个）
    const count = Math.min(data.length, this.LC_MAX_POINTS)
    for (let i = 0; i < count; i++) {
      this.lcDataBuffer[i] = data[i]
      this.lcLabelsBuffer[i] = labels[i]
      this.lcValidCount++
    }
    this.lcWriteIndex = this.lcValidCount % this.LC_MAX_POINTS
    // 更新显示
    this.extractDataFromBuffer()
    this.redrawChart()
  }

  /**
   * 清空折线图数据
   */
  clearLineChartData(): void {
    this.lcWriteIndex = 0
    this.lcValidCount = 0
    this.lcData = []
    this.lcLabels = []
    this.redrawChart()
  }

  /**
   * 启用/禁用自动数据生成（模拟数据）
   * @param enabled true=启用自动生成，false=禁用
   */
  setAutoDataGeneration(enabled: boolean): void {
    this.lcRealtimeEnabled = enabled
    if (this.lcTimerId) {
      clearInterval(this.lcTimerId)
      this.lcTimerId = undefined
    }
  }

  /**
   * 重绘图表（私有方法，供内部调用）
   */
  private redrawChart(): void {
    const opts: LineChartOptions = {
      chartHeight: this.lcChartHeight,
      canvasPadding: 40,
      xStep: 80,
      data: this.lcData,
      labels: this.lcLabels,
      yMax: 100,
      axisFontSizePx: 18,
      labelFontSizePx: 18,
      axisFontBold: true,
      labelFontBold: true,
      lineWidthPx: 3,
      pointRadiusPx: 5,
      colors: this.getCachedColors()
    }
    drawLineChart(this.lineCtx, opts)
  }

  aboutToAppear() {
    // 如果当前Tab是"加工曲线"，立即从全局数据源同步数据
    if (this.selectedTab === '加工曲线') {
      // 立即同步全局数据源到本地缓冲区，避免切换页面后显示空白或旧数据
      const snap = ProcessingCurveFeed.getInstance().getSnapshot()
      this.lcValidCount = Math.min(this.LC_MAX_POINTS, snap.validCount)
      this.lcWriteIndex = snap.writeIndex % this.LC_MAX_POINTS
      for (let i = 0; i < this.lcValidCount; i++) {
        const idx = (this.lcWriteIndex - this.lcValidCount + i + this.LC_MAX_POINTS) % this.LC_MAX_POINTS
        this.lcDataBuffer[idx] = snap.data[i]
        this.lcLabelsBuffer[idx] = snap.labels[i]
      }
      // 立即提取并显示数据
      this.extractDataFromBuffer()
      this.redrawChart()
      // 启动重绘定时器
      this.startFlushTimer()
    } else {
    }
    
    // 刷新颜色缓存
    this.refreshColorCache()
  }

  aboutToUpdate() {
    // 主题变化时刷新颜色缓存
    this.refreshColorCache()
  }

  aboutToDisappear() {
    // 保留后台数据源运行，仅停止重绘定时器
    this.stopFlushTimer()
    // 清理自动数据生成定时器（如果存在）
    if (this.lcTimerId) {
      clearInterval(this.lcTimerId)
      this.lcTimerId = undefined
    }
  }

  // Tab配置（依赖 i18nVersion 确保语言变化时重新计算）
  private getTabConfig(): TabConfig[] {
    const _version = this.i18nVersion
    return [
      { key: '等级表', label: t('等级表', '等级表') },
      { key: '等级统计表', label: t('等级统计表', '等级统计表') },
      { key: '加工曲线', label: t('加工曲线', '加工曲线') },
      { key: '加工柱状图', label: t('加工柱状图', '加工柱状图') },
      { key: '动态装箱', label: t('动态装箱', '动态装箱') },
      { key: '成品', label: t('成品', '成品') }
    ]
  }

  // 处理Tab切换
  private handleTabChange(tabKey: string) {
    this.selectedTab = tabKey
    if (tabKey === '加工曲线') {
      // 切换到"加工曲线"Tab时，立即从全局数据源同步数据
      const snap = ProcessingCurveFeed.getInstance().getSnapshot()
      this.lcValidCount = Math.min(this.LC_MAX_POINTS, snap.validCount)
      this.lcWriteIndex = snap.writeIndex % this.LC_MAX_POINTS
      for (let i = 0; i < this.lcValidCount; i++) {
        const idx = (this.lcWriteIndex - this.lcValidCount + i + this.LC_MAX_POINTS) % this.LC_MAX_POINTS
        this.lcDataBuffer[idx] = snap.data[i]
        this.lcLabelsBuffer[idx] = snap.labels[i]
      }
      // 立即提取并显示数据
      this.extractDataFromBuffer()
      this.redrawChart()
      // 启动重绘定时器
      this.startFlushTimer()
    } else {
      this.stopFlushTimer()
    }
  }

  private getGradeAndContainerTableAreaHeight(headerHeight: number, dataRowHeight: number): string {
    const maxRows = Math.max(this.levelTableData.length, this.containerTableData.length)
    return `${headerHeight + maxRows * dataRowHeight}vp`
  }

  // 构建内容区域
  @Builder
  private buildContent() {
    Column() {
      if (this.selectedTab === '等级表') {
        Row() {
          // 左侧：等级表卡片（支持拖拽）
          GridTable({
            tableName: '等级表',
            tableRows: this.levelTableData,
            tableTitle: t('等级表', '等级表'),
            showTitle: false,
            headerTitles: this.levelHeaderTitles.length > 0 ? this.levelHeaderTitles : [t('等级', '等级'), '30', '20', '10', '0'],
            tableWidth: '100%',
            maxHeight: '100%',
            enableDrag: true,
            enableScroll: true,
            enableHorizontalScroll: true,
            minColumnWidth: 120,
            headerHeight: 60,
            dataRowHeight: 70,
            dividerHeight: 70,
            customBorderWidth: 2,
            enableCardStyle: true
          })
          .layoutWeight(1)

          Blank().width('10vp')  // 参照 48 的 splitter handle，固定像素间距

          // 右侧：容器表卡片（支持拖拽）
          GridTable({
            tableName: '容器表',
            tableRows: this.containerTableData,
            tableTitle: t('容器表', '容器表'),
            showTitle: false,
            headerTitles: [t('容器名称', '容器名称'), t('分选标准', '分选标准'), t('容器规格', '容器规格'), t('容器等级', '容器等级')],
            tableWidth: '100%',
            maxHeight: '100%',
            enableDrag: true,
            headerHeight: 60,
            dataRowHeight: 70,
            dividerHeight: 70,
            customBorderWidth: 2,
            enableCardStyle: true
          })
          .layoutWeight(1)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Top)
      } else if (this.selectedTab === '等级统计表') {
        GridTable({
          tableName: '等级统计表',
          tableRows: this.statisticsTableData,
          showTitle: false,
          headerTitles: [t('等级名称', '等级名称'), t('重量/尺寸', '重量/尺寸'), t('等级出口', '等级出口'), t('等级个数', '等级个数'), t('个数百分比', '个数百分比'), t('等级重量', '等级重量'), t('重量百分比', '重量百分比'), t('箱数', '箱数'), t('箱数百分比', '箱数百分比'), t('装箱量(克/个)', '装箱量(克/个)'), t('箱重', '箱重'), t('贴标', '贴标')],
          tableWidth: '100%',
          maxHeight: '72%',
          enableDrag: false,    // 拖拽设置
          enableScroll: false, // 滚动设置
            headerHeight: 60,  // 等级统计表表头高度
            dataRowHeight: 75,  // 等级统计表数据行高度
            dividerHeight: 75,   // 等级统计表分割线高度
            customBorderWidth: 2,      // 等级统计表边框宽度
            enableCardStyle: false     // 禁用内部卡片样式，融入外部大卡片
        })
        .key(`statistics_table_${this.refreshKey}`)
      } else if (this.selectedTab === '加工曲线') {
        // 使用自定义 Canvas 折线图工具（可横向滚动）
        Scroll() {
          Canvas(this.lineCtx)
            .width(measureChartWidth({ canvasPadding: 40, xStep: 80, data: this.lcData }))
            .height(this.lcChartHeight)
            .onReady(() => {
              const opts: LineChartOptions = {
                chartHeight: this.lcChartHeight,
                canvasPadding: 40,
                xStep: 80,
                data: this.lcData,
                labels: this.lcLabels,
                yMax: 100,
                axisFontSizePx: 18,
                labelFontSizePx: 18,
                axisFontBold: true,
                labelFontBold: true,
                lineWidthPx: 3,
                pointRadiusPx: 5,
                colors: {
                  background: (this.getCurrentTheme().chartBg ?? this.getCurrentTheme().surfaceColor) as string,
                  axis: this.getCurrentTheme().borderColor as string,
                  grid: (this.getCurrentTheme().borderColor as string) + '40',
                  line: (this.getCurrentTheme().chartLineColor ?? this.getCurrentTheme().primary) as string,
                  pointFill: (this.getCurrentTheme().chartLineColor ?? this.getCurrentTheme().primary) as string,
                  pointStroke: this.getCurrentTheme().surfaceColor as string,
                  axisText: this.getCurrentTheme().textColor as string,
                  labelText: this.getCurrentTheme().textColor as string
                }
              }
              drawLineChart(this.lineCtx, opts)
            })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Auto)
        .width('100%')
        .height(this.lcChartHeight)
        .border({ width: 1, color: this.getCurrentTheme().borderColor })
        .borderRadius(4)
        .backgroundColor(this.getCurrentTheme().chartBg ?? this.getCurrentTheme().surfaceColor)
      } else if (this.selectedTab === '加工柱状图') {
        // 使用新的 Canvas 并列柱状图组件
        BarChart({
          title: '',
          chartHeight: 380
        })
      } else if (this.selectedTab === '动态装箱') {
        // 使用Grid组件显示动态装箱表格（带卡片包裹）
        Column() {
          // 表格容器（卡片样式）
          Column() {
            Grid() {
            // 表头
            ForEach([t('出口', '出口'), t('流水码', '流水码'), t('装箱规格', '装箱规格'), t('等级', '等级'), t('箱数', '箱数'), t('纸箱规格', '纸箱规格'), t('纸箱净重', '纸箱净重'), t('箱数/分', '箱数/分')], (title: string, index: number) => {
              GridItem() {
                TableHeaderCell({
                  text: title,
                  fontSize: 20,
                  cellHeight: 50,
                  cellPadding: 6,
                  showRightBorder: true,
                  showBottomBorder: true
                })
              }
            })
            
            // 数据行
            ForEach(this.dynamicPackingTableData, (row: string[], rowIndex: number) => {
              ForEach(row, (cell: string, colIndex: number) => {
                GridItem() {
                  TableCell({
                    text: cell,
                    fontSize: 16,
                    cellHeight: 65,
                    cellPadding: 2,
                    showRightBorder: true,
                    showBottomBorder: true
                  })
                }
              })
            })
          }
          .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr')
          .columnsGap(0)
          .rowsGap(0)
          .width('100%')
          .height('75%')
          .backgroundColor(this.getCurrentTheme().surfaceColor)
          .borderRadius(8)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
      .border({ width: 1, color: this.getCurrentTheme().borderColor })
      .borderRadius(6)
    .padding('0.28%')
      .margin({ top: 4, left: 4, right: 4, bottom: 2 })
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      } else if (this.selectedTab === '成品') {
        // 使用Grid组件显示成品表格（带卡片包裹）
        Column() {
          // 表格容器（卡片样式）
          Column() {
            Grid() {
            // 表头
            ForEach([t('成品码', '成品码'), t('出口', '出口'), t('流水码', '流水码'), t('容器名称', '容器名称'), t('等级', '等级'), t('包装时间', '包装时间'), t('纸箱规格', '纸箱规格'), t('纸箱净重', '纸箱净重')], (title: string, index: number) => {
              GridItem() {
                TableHeaderCell({
                  text: title,
                  fontSize: 20,
                  cellHeight: 50,
                  cellPadding: 6,
                  showRightBorder: true,
                  showBottomBorder: true
                })
              }
            })
            
            // 数据行
            ForEach(this.finishedProductsTableData, (row: string[], rowIndex: number) => {
              ForEach(row, (cell: string, colIndex: number) => {
                GridItem() {
                  TableCell({
                    text: cell,
                    fontSize: 16,
                    cellHeight: 65,
                    cellPadding: 2,
                    showRightBorder: true,
                    showBottomBorder: true
                  })
                }
              })
            })
          }
          .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr')
          .columnsGap(0)
          .rowsGap(0)
          .width('100%')
          .height('75%')
          .backgroundColor(this.getCurrentTheme().surfaceColor)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
      .border({ width: 1, color: this.getCurrentTheme().borderColor })
      .borderRadius(6)
    .padding('0.28%')
      .margin({ top: 4, left: 4, right: 4, bottom: 2 })
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ bottom: '1.11%' })  // 移除左右 padding，由外层 Row + Blank 控制间隙
  }

  build() {
    Column() {
      // 1. 表格内容区域
      Column() {
        this.buildContent()
      }
      .width('100%')
      .layoutWeight(1)

      Column() {
        Scroll() {
          Row() {
            ForEach(this.getTabConfig(), (tab: TabConfig) => {
              Column() {
                Text(tab.label)
                  .fontSize(this.selectedTab === tab.key ? 20 : 18)
                  .fontWeight(this.selectedTab === tab.key ? FontWeight.Bold : FontWeight.Medium)
                  .fontColor(this.selectedTab === tab.key ? this.getCurrentTheme().textColor : (this.getCurrentTheme().subTextColor ?? this.getCurrentTheme().textColor))
              }
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor(this.selectedTab === tab.key ? (this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor) : this.getCurrentTheme().surfaceColor)
              .border({
                width: {
                  left: 1,
                  right: 1,
                  top: 1,
                  bottom: this.selectedTab === tab.key ? 0 : 1
                },
                color: this.getCurrentTheme().borderColor
              })
              .borderRadius({ topLeft: 6, topRight: 6 })
              .margin({ right: 4 })
              .onClick(() => {
                this.handleTabChange(tab.key)
              })
            })
          }
          .padding({ left: 0, right: 0, top: 0, bottom: 0 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
        .align(Alignment.Start)
      }
      .width('100%')
      .padding({ top: 12, bottom: 0 }) // 内部间距，与上方表格分开
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
    .border({ width: 1, color: this.getCurrentTheme().borderColor })
    .borderRadius(6)
    .padding({ left: 4, right: 4, top: 4, bottom: 4 })
    .justifyContent(FlexAlign.Center)
  }
}
