import { drawRoundedRect } from '.';
import { BarStyle, InterfaceObj, Point } from './chartInterface';
import { DrawAxisViewModel } from './DrawAxisViewModel';

export class DrawVerBarViewModel extends DrawAxisViewModel {
  private selectedIndex: number | null = null

  constructor() {
    super('verticalBar')
  }

  create(): void {
    this.initData()

    // 画描述标签
    this.drawDescriptions(this.series)
    // 画x轴
    this.drawXAxis(false)
    // 画y轴
    this.drawYAxis()

    this.drawBarsBySeries()
  }


  bindEvent(e: ClickEvent, callback: Function): void {
    if (this.drawing) return
    const xStart = 0
    const xEnd = (this.xAxisOpt.data?.length ?? 1) + 1
    let selectedIndex: number | null = null
    const x = e.x, y = e.y
    if (this.isInChart(x, y)) {
      for (let i = 0; i < xEnd - xStart; i++) {
        if (x >= this.xs * i + this.padding.left!) {
          selectedIndex = i
        }
      }
      this.ctx!.clearRect(0, 0, this.width, this.height)
      // 画描述标签
      this.drawDescriptions(this.series)
      // 画x轴
      this.drawXAxis(false)
      // 画y轴
      this.drawYAxis()

      if (selectedIndex != null && selectedIndex === this.selectedIndex) {
        // 重置选中的index状态
        selectedIndex = null
        this.selectedIndex = null
      }
      // 画折线
      this.drawBarsBySeries(selectedIndex)
      if (selectedIndex !== null && selectedIndex > 0) {
        let tooltipData: InterfaceObj[] = []
        for (let i = 0; i < this.series.length; i++) {
          const seriesItem = this.series[i]
          tooltipData.push({name: seriesItem.name, num: seriesItem.data![selectedIndex! - 1]})
        }
        callback(
          true,
          e,
          {
            x: this.xs * selectedIndex!,
            W: this.width,
            H: this.height
          },
          this.xAxisOpt.data![selectedIndex! - 1],
          tooltipData,
          this.tooltip
        )
        this.selectedIndex = selectedIndex
      } else {
        callback(false, e)
      }

    } else {
      callback(false, e)
    }
  }

  drawBarsBySeries(selectedIndex: number | null = null) {
    const ctx = this.ctx
    this.drawing = true
    ctx!.save()
    ctx!.translate(this.padding.left, this.height - this.padding.bottom!)

    // 画选中数据的标志线
    if (selectedIndex !== null && selectedIndex != 0) {
      const markerLineX = this.xs * selectedIndex - (this.xs / 2)
      const markerY = -(this.height - this.padding.top! - this.padding.bottom! - this.yAxisNameHeight)
      ctx!.fillStyle = "#CCDDE2EB"
      drawRoundedRect(ctx, markerLineX, 0, this.xs, markerY, [4, 4, 0, 0])

    }
    const series = this.series
    const length = series.length
    for (let i = 0; i < length; i++) {
      const item = series[i];
      const barStyle = item.barStyle ?? {}
      const data = item.data ?? []
      if (barStyle && typeof barStyle?.color === 'undefined') {
        barStyle.color = item.color
      }
      this.drawBarByDataAndStyle(i, length, data, barStyle)
    }
    ctx!.restore()
    this.drawing = false
  }

  drawBarByDataAndStyle(i: number, total: number, data: number[], barStyle: BarStyle) {
    const ctx = this.ctx
    const yHeight = this.height - this.padding.top! - this.padding.bottom! - this.yAxisNameHeight

    const barWidth = barStyle.width ?? 15
    const barGap = barStyle.gap ?? 3
    let radius: number[] | null = null
    if (barStyle.radius) {
      radius = [barStyle.radius, barStyle.radius, 0, 0]
    } else {
      radius = [4, 4, 0, 0]
    }
    const totalOdd = total % 2 === 1
    const iTwo = i - (totalOdd ? total : total - 1) / 2
    const neg = iTwo < 0 ? -1 : 1
    let offsetX = barWidth * (totalOdd ? Math.abs(iTwo) : Math.abs(iTwo) + 0.5) + barGap * (totalOdd ? Math.abs(iTwo) - 0.5 : Math.abs(iTwo))
    // 因为绘制是从左往右，所以减去一个bar的宽度
    if (iTwo > 0) {
      offsetX -= barWidth
    }
    const totalOffsetX = neg * offsetX
    let pointArr: Point[] = data.map((value, index) => {
      return {
        x: this.xs * (index + 1) + totalOffsetX,
        y: yHeight * (value - this.min!) / (this.max! - this.min!)
      } as Point
    })
    ctx!.fillStyle = barStyle.color ?? '#999'
    for (let i = 0; i < pointArr.length; i++) {
      const curPoint = pointArr[i];
      drawRoundedRect(ctx, curPoint.x, 0, barWidth, -curPoint.y, radius)
    }
  }
}