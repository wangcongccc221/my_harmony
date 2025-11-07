import { drawBreakText, drawRoundedRect, drawTexts } from '.';
import { Point, BarStyle, InterfaceObj } from './chartInterface';
import { axisLineStyle } from './defaultOption';
import { DrawAxisViewModel } from './DrawAxisViewModel';

export class DrawHorViewModel extends DrawAxisViewModel {
  private selectedIndex: number | null = null

  constructor() {
    super('horizonBar')
  }

  create(): void {
    this.initData()
    // 画描述标签
    this.drawDescriptions(this.series)
    // 画x轴
    this.drawXAxis()
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
    const yInChart = y - (this.height - this.padding.bottom!)
    if (this.isInChart(x, y)) {
      for (let i = 0; i < xEnd - xStart; i++) {
        if (Math.abs(yInChart) >= this.xs * i) {
          selectedIndex = i
        }
      }
      this.ctx!.clearRect(0, 0, this.width, this.height)
      // 画描述标签
      this.drawDescriptions(this.series)
      // 画x轴
      this.drawXAxis()
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
            x: x - this.padding.left!,
            y: y,
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

  drawXAxis(startZero?: boolean): void {
    const ctx = this.ctx

    let yAxisName: string | undefined = undefined
    if (this.yAxisOpt && (yAxisName = this.yAxisOpt.name)) {
      const nameStyle = this.yAxisOpt.nameTextStyle ?? {}
      const color = nameStyle.color ?? "#999"
      const fontWeight = nameStyle.fontWeight ?? 'normal'
      const fontSize = nameStyle.fontSize ?? 22
      const fontFamily = nameStyle.fontFamily ?? 'sans-serif'

      ctx!.fillStyle = color
      ctx!.font = `${fontWeight} ${fontSize}px ${fontFamily}`
      ctx!.textBaseline = 'middle'
      ctx!.textAlign = 'left'
      // const measure = ctx!.measureText(yAxisName)
      // yAxisNameHeight = measure.height
      // xAxisNameWidth = measure.width
      ctx!.fillText(yAxisName, this.width - this.padding.right! + 10, this.height - this.padding.bottom!)

    }
    const chartHeight = this.height - this.padding.bottom! - this.padding.top!
    const chartWidth = this.width - this.padding.left! - this.padding.right!
    ctx!.save()
    ctx!.translate(this.padding.left, this.height - this.padding.bottom!)

    const axisLine = this.yAxisOpt.axisLine ?? {}
    if (axisLine.show) {
      const color = axisLine.color ?? '#DDE2EB'
      const width = axisLine.width ?? 1
      ctx!.strokeStyle = color
      ctx!.lineWidth = width
      ctx!.beginPath()
      ctx!.moveTo(0, 0)
      ctx!.lineTo(chartWidth, 0)
      ctx!.stroke()
    }

    // 画y轴刻度、刻度数值和分割线
    let yTickNum = this.yTickNum // 刻度数量默认为5
    let yTickUnit = chartWidth / yTickNum
    const axisTick = this.yAxisOpt.axisTick
    const axisLabel = this.yAxisOpt.axisLabel
    const spliceLineStyle = this.yAxisOpt.splitLine
    const axisTickLength = axisTick?.length
    for (let i = 0; i < yTickNum; i++) {
      const yTick = Math.floor(yTickUnit * (i + 1))
      // 绘制刻度
      if (axisTick?.show) {
        const color = axisTick.lineStyle.color ?? '#DDE2EB'
        const width = axisTick.lineStyle.width ?? 1

        ctx!.beginPath()
        ctx!.strokeStyle = color
        ctx!.lineWidth = width
        ctx!.moveTo(yTick, 0)
        ctx!.lineTo(yTick, -axisTickLength!)
        ctx!.stroke()
      }

      // 绘制分割线
      if (spliceLineStyle?.show) {
        const color = spliceLineStyle.color ?? '#DDE2EB'
        const width = spliceLineStyle.width ?? 1

        ctx!.beginPath()
        ctx!.strokeStyle = color
        ctx!.lineWidth = width
        ctx!.moveTo(yTick, 0)
        ctx!.lineTo(yTick, -chartHeight)
        ctx!.setLineDash([5, 5]) // 分割线采用虚线样式
        ctx!.stroke()
      }

      // 绘制刻度数值
      const color = axisLabel?.color ?? '#999'
      const fontSize = axisLabel?.fontSize ?? 22
      const fontWeight = axisLabel?.fontWeight ?? 'normal'
      const fontFamily = axisLabel?.fontFamily ?? 'sans-serif'

      ctx!.fillStyle = color
      ctx!.font = `${fontWeight} ${fontSize}px ${fontFamily}`;
      ctx!.textAlign = 'left'
      ctx!.textBaseline = 'middle'
      const value = String(Math.floor(this.min! + this.yTickStep * (i + 1)))
      const textW = ctx!.measureText(value).width
      const textX = Math.round(yTick - (textW / 2))
      const textY = axisTickLength! + (axisTick!.interval ?? 4)
      let textI = value.length
      if (axisLabel!.overflow === 'break') {
        textI = drawTexts(ctx, value, yTickUnit)
        ctx!.fillText(value.substring(0, textI) + (textI !== value.length ? '...' : ''), textX, textY)
      } else if (axisLabel!.overflow === 'breakAll') {
        drawBreakText(ctx, value, yTickUnit, {
          x: textX,
          y: textY
        })
      } else {
        ctx!.fillText(value.substring(0, textI), textX, textY)
      }
    }

    ctx!.restore()
  }

  drawYAxis(): void {
    const startZero = false
    const ctx = this.ctx, height = this.height
    const padding = this.padding
    const xStart = 0
    const xEnd = this.xAxisOpt.data?.length ?? 1
    const xLength = xEnd - xStart - (startZero ? 1 : -1)

    const chartHeight = height - this.padding.bottom! - this.padding.top!

    this.xs = chartHeight / xLength
    ctx!.save()
    ctx!.translate(padding.left, height - padding.bottom!)

    const xAxisLine = this.xAxisOpt.axisLine ?? {}
    const xAxisLabel = this.xAxisOpt.axisLabel ?? {}
    let xData = this.xAxisOpt.data ?? []
    const xAxisTickLength = this.xAxisOpt.axisTick?.length ?? 5
    // 画x轴底线
    if (xAxisLine.show) {
      const color = xAxisLine.color ?? axisLineStyle.color
      const width = xAxisLine.width ?? axisLineStyle.width

      ctx!.strokeStyle = color ?? '#999'
      ctx!.lineWidth = width ?? 1
      ctx!.beginPath()
      ctx!.moveTo(0, 0)
      ctx!.lineTo(0, -chartHeight)
      ctx!.stroke()
    }
    // 画刻度和标签
    const axisTick = this.xAxisOpt.axisTick
    const axisTickShow = axisTick?.show
    const tickLine = axisTick?.lineStyle ?? axisLineStyle
    const fontColor = xAxisLabel.color ?? "#999999"
    const fontWeight = xAxisLabel.fontWeight ?? "normal"
    const fontSize = xAxisLabel.fontSize ?? 23
    const fontFamily = xAxisLabel.fontFamily ?? "sans-serif"
    for (let i = 0; i < xEnd; i++) {
      let value = xData[i]
      let x = Math.round(this.xs * (startZero ? i : (i + 1)))

      if (axisTickShow) {
        const color = tickLine.color
        const width = tickLine.width
        ctx!.beginPath()
        ctx!.strokeStyle = color ?? '#999'
        ctx!.lineWidth = width ?? 1
        ctx!.moveTo(0, -x)
        ctx!.lineTo(xAxisTickLength, -x)
        ctx!.stroke()

      }

      ctx!.font = `${fontWeight} ${fontSize}px ${fontFamily}`
      ctx!.fillStyle = fontColor
      ctx!.textAlign = 'left'
      ctx!.textBaseline = 'middle'
      value = String(value)
      const txtWidth = ctx!.measureText(value!).width; // 获取文字的长度
      const txtX = -(txtWidth + (axisTick?.show ? axisTick?.length! : 0) + (axisTick?.interval ?? 4)) // 文字长度 + 刻度长度 + 两者之间的间距
      ctx!.fillText(value, txtX, -x)
    }

    ctx!.restore()
  }

  drawBarsBySeries(selectedIndex: number | null = null) {
    const ctx = this.ctx
    this.drawing = true
    ctx!.save()
    ctx!.translate(this.padding.left, this.height - this.padding.bottom!)
    // 画选中数据的标志线
    if (selectedIndex !== null && selectedIndex != 0) {
      const markerLineX = this.xs * selectedIndex + (this.xs / 2)
      const markerY = this.width - this.padding.left! - this.padding.right!
      ctx!.fillStyle = "#CCDDE2EB"
      drawRoundedRect(ctx, 0, -markerLineX, markerY, this.xs, [0, 4, 4, 0])

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
    const xWidth = this.width - this.padding.left! - this.padding.right!

    const barWidth = barStyle.width ?? 15
    const barGap = barStyle.gap ?? 3
    let radius: number[] | null = null
    if (barStyle.radius) {
      radius = [0, barStyle.radius, barStyle.radius, 0]
    } else {
      radius = [0, 4, 4, 0]
    }
    const totalOdd = total % 2 === 1
    const iTwo = i - (totalOdd ? total : total - 1) / 2
    const neg = iTwo < 0 ? -1 : 1
    let offsetX = barWidth * (totalOdd ? Math.abs(iTwo) : Math.abs(iTwo) + 0.5) + barGap * (totalOdd ? Math.abs(iTwo) - 0.5 : Math.abs(iTwo))
    // 因为绘制是从上往下，所以减去一个bar的宽度
    if (iTwo < 0) {
      offsetX -= barWidth
    }
    const totalOffsetX = neg * offsetX
    let pointArr: Point[] = data.map((value, index) => {
      return {
        y: -(this.xs * (index + 1) + totalOffsetX),
        x: xWidth * (value - this.min!) / (this.max! - this.min!)
      } as Point
    })
    ctx!.fillStyle = barStyle.color ?? '#999'
    for (let i = 0; i < pointArr.length; i++) {
      const curPoint = pointArr[i];
      drawRoundedRect(ctx, 0, curPoint.y, curPoint.x, barWidth, radius)
    }
  }
}