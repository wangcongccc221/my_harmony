/**
 * 数据表格TabBar组件
 */

import { LevelTable, TableRow } from '../../components/layout/LevelTable'
import { GridTable } from '../../components/layout/GridTable'
import { DraggableGridTable, DragData } from '../../components/layout/DraggableGridTable'
import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme as resolveTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { ChartComponent, ChartComponentParams, ChartData } from '../../components/ChartComponent'
import { OmniTabBar, TabConfig, TabBarDirection } from '../../components/ui/OmniTabBar'
import { drawLineChart, measureChartWidth, LineChartOptions } from  '../../utils/lineChart'
import { ProcessingCurveFeed } from '../../utils/ProcessingCurveFeed'

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
  
  // 提供主题给子组件
  @Provide providedTheme: ExtendedOmniThemeStyle = this.consumedTheme

  // 当前选中的Tab
  @State selectedTab: string = '等级表'

  // 表格数据
  @Prop levelTableData: TableRow[] = []
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
    if (enabled && !this.lcTimerId) {
      // 启动自动生成（见aboutToAppear中的逻辑）
      this.startAutoDataGeneration()
    } else if (!enabled && this.lcTimerId) {
      // 停止自动生成
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

  /**
   * 启动自动数据生成（私有方法）
   */
  private startAutoDataGeneration(): void {
    const startHour = 9
    const startMinute = 0
    if (this.lcTimerId) {
      clearInterval(this.lcTimerId)
    }
    this.lcTimerId = setInterval(() => {
      const totalMin = startMinute + this.lcTimeIndex
      const h = startHour + Math.floor(totalMin / 60)
      const m = totalMin % 60
      const hh = h.toString().padStart(2, '0')
      const mm = m.toString().padStart(2, '0')
      const newLabel = `${hh}:${mm}`

      // 随机游走
      const step = (Math.random() - 0.5) * 20
      this.lcCurrentValue = Math.max(10, Math.min(90, Math.round(this.lcCurrentValue + step)))

      // 直接写入环形缓冲区（覆盖旧数据）
      this.lcDataBuffer[this.lcWriteIndex] = this.lcCurrentValue
      this.lcLabelsBuffer[this.lcWriteIndex] = newLabel
      this.lcWriteIndex = (this.lcWriteIndex + 1) % this.LC_MAX_POINTS
      this.lcValidCount = Math.min(this.lcValidCount + 1, this.LC_MAX_POINTS)
      this.lcTimeIndex++
    }, 1000) as number
  }

  aboutToAppear() {
    // 确保全局数据源在后台运行
    ProcessingCurveFeed.getInstance().start()
    
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
      // 其他Tab：仅在无数据时播种初始点（用于其他可能使用折线图的场景）
      if (this.lcValidCount === 0) {
        const count = 10
        const startHour = 9
        const startMinute = 0
        let cur = 50
        for (let i = 0; i < count; i++) {
          const change = (Math.random() - 0.5) * 20
          cur = Math.max(10, Math.min(90, cur + change))
          const h = startHour + Math.floor((startMinute + i) / 60)
          const m = (startMinute + i) % 60
          const label = `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}`
          this.lcDataBuffer[this.lcWriteIndex] = Math.round(cur)
          this.lcLabelsBuffer[this.lcWriteIndex] = label
          this.lcWriteIndex = (this.lcWriteIndex + 1) % this.LC_MAX_POINTS
          this.lcValidCount = Math.min(this.lcValidCount + 1, this.LC_MAX_POINTS)
        }
        this.lcTimeIndex = count
        this.lcCurrentValue = cur
        this.lcRealtimeEnabled = true
        this.extractDataFromBuffer()
      }
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

  // Tab配置
  private tabConfig: TabConfig[] = [
    { key: '等级表', label: '等级表' },
    { key: '等级统计表', label: '等级统计表' },
    { key: '加工曲线', label: '加工曲线' },
    { key: '加工柱状图', label: '加工柱状图' },
    { key: '动态装箱', label: '动态装箱' },
    { key: '成品', label: '成品' }
  ]

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

  // 构建内容区域
  @Builder
  private buildContent() {
    Column() {
      if (this.selectedTab === '等级表') {
        // 显示等级表和容器表（左右分布）- 使用新的GridTable组件
        Row() {
          // 左侧：等级表卡片（支持拖拽）
          GridTable({
            tableName: '等级表',
            tableRows: this.levelTableData,
            tableTitle: '等级表',
            headerTitles: ['等级', '30', '20', '10', '0'],
            tableWidth: '100%',
            maxHeight: '72%', // 等级表最大高度改为65%
            enableDrag: true,
            headerHeight: 60,  // 等级表表头高度
            dataRowHeight: 75,  // 等级表数据行高度
            dividerHeight: 75,   // 等级表分割线高度
            customBorderWidth: 2      // 等级表边框宽度
          })
          .width('48%')

          // 右侧：容器表卡片（支持拖拽）
          GridTable({
            tableName: '容器表',
            tableRows: this.containerTableData,
            tableTitle: '容器表',
            headerTitles: ['容器名称', '分选标准', '容器规格', '容器等级'],
            tableWidth: '100%',
            maxHeight: '72%',
            enableDrag: true,
            headerHeight: 62,  // 容器表表头高度
            dataRowHeight: 73,  // 容器表数据行高度
            dividerHeight: 73,   // 容器表分割线高度
            customBorderWidth: 2      // 容器表边框宽度
          })
          .width('48%')
          .margin({ left: '2%', right: '2px' })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Top)
      } else if (this.selectedTab === '等级统计表') {
        GridTable({
          tableName: '等级统计表',
          tableRows: this.statisticsTableData,
          tableTitle: '等级统计表',
          headerTitles: ['等级', '重量', '出口', '个数', '占比', '重量2', '占比2', '箱数', '占比3', '箱重', '平均'],
          tableWidth: '100%',
          maxHeight: '72%',
          enableDrag: false,    // 拖拽设置
          enableScroll: false, // 滚动设置
            headerHeight: 60,  // 等级统计表表头高度
            dataRowHeight: 75,  // 等级统计表数据行高度
            dividerHeight: 75,   // 等级统计表分割线高度
          customBorderWidth: 2      // 等级统计表边框宽度
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
        // 启用外部单例数据源，行为与折线图一致（后台持续追加，页面只负责渲染）
        ChartComponent({
          params: {
            dataCount: 10,
            startHour: 9,
            startMinute: 0,
            chartHeight: 280,
            barWidth: 25,
            barSpacing: 40,
            showScrollBar: false,
            axisFontSizePx: 18,
            labelFontSizePx: 18,
            axisFontBold: true,
            labelFontBold: true,
            useExternalFeed: true,
            onDataClick: (data: ChartData, event: ClickEvent) => {
              console.log(`点击了加工数据: ${data.time} - ${data.value}`);
            }
          }
        })
      } else if (this.selectedTab === '动态装箱') {
        // 使用Grid组件显示动态装箱表格（带卡片包裹）
        Column() {
          Text('动态装箱')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getCurrentTheme().textColor)
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 4 })

          // 表格容器（卡片样式）
          Column() {
            Grid() {
            // 表头
            ForEach(['出口', '流水码', '装箱规格', '等级', '箱数', '纸箱规格', '纸箱净重', '箱数/分'], (title: string, index: number) => {
              GridItem() {
                Text(title)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.getCurrentTheme().tableHeaderTextColor ?? this.getCurrentTheme().textColor)
                  .textAlign(TextAlign.Center)
                  .width('100%')
                  .height(50)
                  .padding(6)
                  .backgroundColor(this.getCurrentTheme().tableHeaderBg ?? this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                  .border({ width: { right: 1, bottom: 1 }, color: this.getCurrentTheme().borderColor })
              }
            })
            
            // 数据行
            ForEach(this.dynamicPackingTableData, (row: string[], rowIndex: number) => {
              ForEach(row, (cell: string, colIndex: number) => {
                GridItem() {
                  Text(cell)
                    .fontSize(16)
                    .fontColor(this.getCurrentTheme().textColor)
                    .textAlign(TextAlign.Center)
                    .width('100%')
                    .height(65)
                    .padding(2)
                    .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                    .border({ width: { right: 1, bottom: 1 }, color: this.getCurrentTheme().borderColor })
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
      .padding(4)
      .margin({ top: 4, left: 4, right: 4, bottom: 2 })
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      } else if (this.selectedTab === '成品') {
        // 使用Grid组件显示成品表格（带卡片包裹）
        Column() {
          Text('成品')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getCurrentTheme().textColor)
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 4 })

          // 表格容器（卡片样式）
          Column() {
            Grid() {
            // 表头
            ForEach(['成品码', '出口', '流水码', '容器名称', '等级', '包装时间', '纸箱规格', '纸箱净重'], (title: string, index: number) => {
              GridItem() {
                Text(title)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.getCurrentTheme().tableHeaderTextColor ?? this.getCurrentTheme().textColor)
                  .textAlign(TextAlign.Center)
                  .width('100%')
                  .height(50)
                  .padding(6)
                  .backgroundColor(this.getCurrentTheme().tableHeaderBg ?? this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                  .border({ width: { right: 1, bottom: 1 }, color: this.getCurrentTheme().borderColor })
              }
            })
            
            // 数据行
            ForEach(this.finishedProductsTableData, (row: string[], rowIndex: number) => {
              ForEach(row, (cell: string, colIndex: number) => {
                GridItem() {
                  Text(cell)
                    .fontSize(16)
                    .fontColor(this.getCurrentTheme().textColor)
                    .textAlign(TextAlign.Center)
                    .width('100%')
                    .height(65)
                    .padding(2)
                    .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                    .border({ width: { right: 1, bottom: 1 }, color: this.getCurrentTheme().borderColor })
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
      .padding(4)
      .margin({ top: 4, left: 4, right: 4, bottom: 2 })
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 16, right: 16, bottom: 16 })
  }

  build() {
    Column() {
      // TabBar导航
      OmniTabBar({
        tabs: this.tabConfig,
        selectedTab: this.selectedTab,
        layoutDirection: TabBarDirection.HORIZONTAL,
        showSeparator: false,
        onTabClick: (tabKey: string) => {
          this.handleTabChange(tabKey)
        }
      })
      
      // 内容区域
      this.buildContent()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.getCurrentTheme().pageBg ?? this.getCurrentTheme().backgroundColor)
  }
}
