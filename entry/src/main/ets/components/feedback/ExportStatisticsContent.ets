/**
 * 出口统计信息内容组件
 * 功能：显示出口统计信息的堆叠柱状图
 * 每个出口（1-10）显示一个堆叠柱状图，堆叠2个指标
 */

import { ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'

interface ChartPadding {
  top: number;
  right: number;
  bottom: number;
  left: number;
}

// 出口数据接口（每个出口有两个指标）
interface OutletData {
  outletNumber: number  // 出口编号（1-10）
  value1: number  // 第一个指标值（底部，绿色）
  value2: number  // 第二个指标值（顶部，黄色）
  percentage1: number  // 第一个百分比
  percentage2: number  // 第二个百分比
}

@Component
export struct ExportStatisticsContent {
  @Consume providedTheme: ExtendedOmniThemeStyle
  @StorageLink('OutletCount_FSM1') outletCountFSM1: number = 20
  @StorageLink('OutletCount_FSM2') outletCountFSM2: number = 20

  // 子系统选择
  @State selectedSubsystem: number = 1

  // 出口数据（1-10，每个出口有两个指标）
  @State outletData: OutletData[] = []

  // 每个出口的 Canvas 上下文
  private outletContexts: Map<number, CanvasRenderingContext2D> = new Map()

  // 图表配置
  private chartPadding: ChartPadding = {
    top: 20,
    right: 10,
    bottom: 30,
    left: 40
  }

  // 颜色配置
  private color1: string = '#00B894'  // 第一个指标（绿色，底部）
  private color2: string = '#FDCB6E'  // 第二个指标（黄色，顶部）

  aboutToAppear() {
    // 初始化出口数据
    this.initOutletData()
  }

  // 初始化出口数据
  private initOutletData() {
    const outletCount = this.selectedSubsystem === 1 ? this.outletCountFSM1 : this.outletCountFSM2
    const maxOutlets = Math.min(10, outletCount) // 最多显示10个出口
    
    this.outletData = []
    for (let i = 1; i <= maxOutlets; i++) {
      this.outletData.push({
        outletNumber: i,
        value1: 0,  // 初始值为0
        value2: 0,  // 初始值为0
        percentage1: 0.00,
        percentage2: 0.00
      })
    }
  }

  // 获取当前主题
  getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.providedTheme)
  }

  // 绘制单个出口的堆叠柱状图
  private drawStackedBarChart(outlet: OutletData, context: CanvasRenderingContext2D, width: number, height: number) {
    if (!context) return

    const theme = this.getCurrentTheme()
    const chartWidth = width - this.chartPadding.left - this.chartPadding.right
    const chartHeight = height - this.chartPadding.top - this.chartPadding.bottom
    const baseY = this.chartPadding.top + chartHeight

    // 清空画布
    context.clearRect(0, 0, width, height)

    // 计算最大值（用于Y轴缩放）
    const maxValue = Math.max(1, outlet.value1 + outlet.value2) // 至少为1，避免除零

    // 绘制Y轴
    context.save()
    context.strokeStyle = theme.borderColor as string
    context.lineWidth = 1

    // Y轴线条
    context.beginPath()
    context.moveTo(this.chartPadding.left, this.chartPadding.top)
    context.lineTo(this.chartPadding.left, baseY)
    context.stroke()

    // X轴线条
    context.beginPath()
    context.moveTo(this.chartPadding.left, baseY)
    context.lineTo(this.chartPadding.left + chartWidth, baseY)
    context.stroke()

    // 绘制Y轴刻度（0, 0.2, 0.4, 0.6, 0.8, 1.0）
    context.font = '10px sans-serif'
    context.fillStyle = theme.textColor as string
    context.textAlign = 'right'

    const yTickCount = 5
    for (let i = 0; i <= yTickCount; i++) {
      const ratio = i / yTickCount  // 0, 0.2, 0.4, 0.6, 0.8, 1.0
      const y = this.chartPadding.top + chartHeight * (1 - ratio)

      // 绘制刻度线
      context.beginPath()
      context.moveTo(this.chartPadding.left - 3, y)
      context.lineTo(this.chartPadding.left, y)
      context.stroke()

      // 绘制刻度值
      context.fillText(ratio.toFixed(1), this.chartPadding.left - 8, y + 3)
    }

    // 绘制X轴刻度（显示0）
    context.textAlign = 'center'
    context.fillText('0', this.chartPadding.left + chartWidth / 2, baseY + 15)

    context.restore()

    // 绘制堆叠柱状图
    const barWidth = chartWidth * 0.6  // 柱子宽度为图表宽度的60%
    const barX = this.chartPadding.left + (chartWidth - barWidth) / 2  // 居中

    // 计算两个部分的高度
    const height1 = (outlet.value1 / maxValue) * chartHeight  // 第一个指标的高度
    const height2 = (outlet.value2 / maxValue) * chartHeight  // 第二个指标的高度

    // 绘制第一个指标（底部，绿色）
    if (height1 > 0) {
      context.fillStyle = this.color1
      context.fillRect(barX, baseY - height1, barWidth, height1)
    }

    // 绘制第二个指标（顶部，黄色）
    if (height2 > 0) {
      context.fillStyle = this.color2
      context.fillRect(barX, baseY - height1 - height2, barWidth, height2)
    }
  }

  // 构建单个出口的卡片
  @Builder
  buildOutletCard(outlet: OutletData) {
    Column() {
      // 堆叠柱状图区域
      Canvas(this.getOutletContext(outlet.outletNumber))
        .width('100%')
        .height(120)
        .backgroundColor(this.getCurrentTheme().surfaceColor)
        .onReady(() => {
          const context = this.getOutletContext(outlet.outletNumber)
          if (context) {
            // 获取Canvas的实际尺寸
            const width = context.width
            const height = context.height
            // 绘制堆叠柱状图
            this.drawStackedBarChart(outlet, context, width, height)
          }
        })

      // 百分比显示
      Text(`${outlet.percentage1.toFixed(2)}%`)
        .fontSize(11)
        .fontColor(this.getCurrentTheme().textColor)
        .margin({ top: 4 })
        .textAlign(TextAlign.Center)

      // 出口编号
      Text(outlet.outletNumber.toString())
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getCurrentTheme().textColor)
        .margin({ top: 4 })
        .alignSelf(ItemAlign.Center)
    }
    .width('100%')
    .height('100%')
    .padding(8)
    .backgroundColor(this.getCurrentTheme().surfaceColor)
    .borderRadius(4)
    .border({ width: 1, color: this.getCurrentTheme().borderColor })
  }

  // 获取或创建出口的Canvas上下文
  private getOutletContext(outletNumber: number): CanvasRenderingContext2D {
    if (!this.outletContexts.has(outletNumber)) {
      const settings = new RenderingContextSettings(true)
      const context = new CanvasRenderingContext2D(settings)
      this.outletContexts.set(outletNumber, context)
    }
    return this.outletContexts.get(outletNumber)!
  }

  // 批次比例刷新
  private handleBatchRatioRefresh() {
    console.log('批次比例刷新')
    // TODO: 从数据库获取数据并更新
    // 更新所有出口的图表
    this.outletData.forEach(outlet => {
      const context = this.outletContexts.get(outlet.outletNumber)
      if (context) {
        this.drawStackedBarChart(outlet, context, context.width, context.height)
      }
    })
  }

  // 实时比例刷新
  private handleRealtimeRatioRefresh() {
    console.log('实时比例刷新')
    // TODO: 从数据库获取实时数据并更新
    // 更新所有出口的图表
    this.outletData.forEach(outlet => {
      const context = this.outletContexts.get(outlet.outletNumber)
      if (context) {
        this.drawStackedBarChart(outlet, context, context.width, context.height)
      }
    })
  }

  // 导出
  private handleExport() {
    console.log('导出')
    // TODO: 实现导出逻辑
  }

  // 打印
  private handlePrint() {
    console.log('打印')
    // TODO: 实现打印逻辑
  }

  build() {
    Column() {
      // 中央内容区域：显示所有出口的堆叠柱状图
      Scroll() {
        // 使用Grid布局，每行显示多个出口
        Grid() {
          ForEach(this.outletData, (outlet: OutletData) => {
            GridItem() {
              this.buildOutletCard(outlet)
            }
          }, (outlet: OutletData) => `outlet-${outlet.outletNumber}`)
        }
        .columnsTemplate('1fr 1fr 1fr 1fr 1fr') // 每行5个出口
        .rowsTemplate('1fr 1fr') // 2行
        .columnsGap(8)
        .rowsGap(8)
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
      .padding(8)

      // 底部控制栏
      Row() {
        // 左侧导航箭头
        Row() {
          Button('<')
            .width(30)
            .height(30)
            .fontSize(14)
            .backgroundColor(Color.Transparent)
          Button('>')
            .width(30)
            .height(30)
            .fontSize(14)
            .backgroundColor(Color.Transparent)
        }
        .margin({ right: 16 })

        // 子系统下拉框
        Row() {
          Text('子系统:')
            .fontSize(12)
            .fontColor(this.getCurrentTheme().textColor)
            .margin({ right: 8 })
          Select([{ value: '1' }, { value: '2' }])
            .value(this.selectedSubsystem.toString())
            .onSelect((index: number, value: string) => {
              this.selectedSubsystem = parseInt(value)
              this.initOutletData()
            })
        }
        .margin({ right: 16 })

        // 按钮组
        Button('批次比例刷新')
          .fontSize(12)
          .backgroundColor(this.getCurrentTheme().controlBg || this.getCurrentTheme().surfaceColor)
          .onClick(() => this.handleBatchRatioRefresh())
          .margin({ right: 8 })

        Button('实时比例刷新')
          .fontSize(12)
          .backgroundColor(this.getCurrentTheme().controlBg || this.getCurrentTheme().surfaceColor)
          .onClick(() => this.handleRealtimeRatioRefresh())
          .margin({ right: 8 })

        Button('导出')
          .fontSize(12)
          .backgroundColor(this.getCurrentTheme().primary)
          .onClick(() => this.handleExport())
          .margin({ right: 8 })

        Button('打印')
          .fontSize(12)
          .backgroundColor(this.getCurrentTheme().primary)
          .onClick(() => this.handlePrint())
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .padding({ left: 8, right: 8, top: 8, bottom: 8 })
      .backgroundColor(this.getCurrentTheme().controlBg || '#808080')
    }
    .width('100%')
    .height('100%')
    .padding(8)
  }
}
