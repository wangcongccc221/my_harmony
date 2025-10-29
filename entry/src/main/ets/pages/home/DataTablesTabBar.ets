/**
 * 数据表格TabBar组件
 * 
 * 功能说明：
 * - 替换原有的FunctionButtons和DataTablesCard
 * - 提供6个Tab页面的切换功能
 * - 集成表格内容显示
 * - 支持主题配置和样式定制
 * 
 * Tab页面列表：
 * - 等级表：显示等级相关数据
 * - 等级统计表：显示统计相关数据
 * - 加工曲线：显示加工曲线图表
 * - 加工柱状图：显示加工柱状图
 * - 动态装箱：显示装箱相关数据
 * - 成品：显示成品相关数据
 * 
 * 组件特点：
 * - 统一TabBar设计：与项目中其他TabBar保持一致
 * - 集成内容显示：TabBar下方直接显示对应内容
 * - 主题支持：使用主题管理器的样式配置
 * - 响应式设计：支持不同屏幕尺寸
 */

import { LevelTable, TableRow } from '../../components/layout/LevelTable'
import { GridTable } from '../../components/layout/GridTable'
import { DraggableGridTable, DragData } from '../../components/layout/DraggableGridTable'
import { BaseComponentHelper } from '../../components/common/BaseComponent'
import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { drawLineChart, measureChartWidth, LineChartOptions } from '../../utils/lineChart'
import { ChartComponent, ChartComponentParams, ChartData } from '../../components/ChartComponent'
import { OmniTabBar, TabConfig, TabBarDirection } from '../../components/ui/OmniTabBar'

@Component
export struct DataTablesTabBar {
  private baseComponentHelper = new BaseComponentHelper()
  private lineCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D()
  // 折线图参数与数据
  private readonly lcChartHeight: number = 340
  private readonly lcCanvasPadding: number = 40
  private readonly lcXStep: number = 80
  @State lcData: number[] = []
  @State lcLabels: string[] = []
  private lcTimerId?: number
  private lcCurrentValue: number = 50
  private lcTimeIndex: number = 0
  private lcRealtimeEnabled: boolean = false
  
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
    return this.baseComponentHelper.getCurrentTheme(this.consumedTheme)
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


  aboutToAppear() {
    // 生成折线图模拟数据（10点，09:00开始，每分钟一个）
    const count = 10
    const startHour = 9
    const startMinute = 0
    const series: number[] = []
    let cur = 50
    for (let i = 0; i < count; i++) {
      const change = (Math.random() - 0.5) * 20
      cur = Math.max(10, Math.min(90, cur + change))
      series.push(Math.round(cur))
    }
    const lbs: string[] = []
    for (let i = 0; i < count; i++) {
      const h = startHour + Math.floor((startMinute + i) / 60)
      const m = (startMinute + i) % 60
      lbs.push(`${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}`)
    }
    this.lcData = series
    this.lcLabels = lbs
    this.lcTimeIndex = count
    this.lcRealtimeEnabled = true

    // 启动持续追加数据（每秒1个点）- 启用自动添加数据功能
    if (this.lcRealtimeEnabled && !this.lcTimerId) {
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

        this.lcLabels = [...this.lcLabels, newLabel]
        this.lcData = [...this.lcData, this.lcCurrentValue]
        this.lcTimeIndex++

        // 超过60个数据就自动清空，重新开始显示
        const maxDataPoints = 60 
        if (this.lcData.length > maxDataPoints) {
          console.log(`🔄 数据量超过${maxDataPoints}，自动清空重新开始...`)
          this.lcData = []
          this.lcLabels = []
          this.lcTimeIndex = 0
          console.log(`✅ 数据已清空，重新开始追踪`)
        }

        // 控制台输出当前数据条数
        console.log(`📊 第${this.lcTimeIndex}条数据 - 时间: ${newLabel} - 进度: ${this.lcCurrentValue}%`)

        // 数据更新后重绘
        setTimeout(() => {
          const opts: LineChartOptions = {
            chartHeight: this.lcChartHeight,
            canvasPadding: this.lcCanvasPadding,
            xStep: this.lcXStep,
            data: this.lcData,
            labels: this.lcLabels,
            yMax: 100,
            axisFontSizePx: 18,
            labelFontSizePx: 18,
            axisFontBold: true,
            labelFontBold: true,
            lineWidthPx: 3,
            pointRadiusPx: 5
          }
          drawLineChart(this.lineCtx, opts)
        }, 0)
      }, 1000) as number
    }
  }

  aboutToDisappear() {
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
            .width(measureChartWidth({ canvasPadding: this.lcCanvasPadding, xStep: this.lcXStep, data: this.lcData }))
            .height(this.lcChartHeight)
            .onReady(() => {
              const opts: LineChartOptions = {
                chartHeight: this.lcChartHeight,
                canvasPadding: this.lcCanvasPadding,
                xStep: this.lcXStep,
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
        ChartComponent({
          params: {
            dataCount: 10, // 主页只显示10条数据
            startHour: 9,
            startMinute: 0,
            chartHeight: 280, // 降低高度，让x轴标签可见
            barWidth: 25, // 主页柱子宽度改为25px
            barSpacing: 40, // 加工柱状图使用较紧密的间距
            showScrollBar: false, // 隐藏滚动条
            axisFontSizePx: 18,
            labelFontSizePx: 18,
            axisFontBold: true,
            labelFontBold: true,
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
