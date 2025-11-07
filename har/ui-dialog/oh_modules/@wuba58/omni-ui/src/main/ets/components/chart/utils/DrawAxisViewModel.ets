import { calculateNum, drawBreakText, drawTexts } from ".";
import { AxisInterface, OptionInterface } from "./chartInterface";
import { axisLineStyle, xAxisOpt, yAxisOpt } from "./defaultOption";
import { DrawBaseViewModel } from "./DrawBaseViewModel";


export abstract class DrawAxisViewModel extends DrawBaseViewModel<number> {
  protected xs: number = 1; // x轴间隔
  protected min?: number = -NaN
  protected max?: number
  protected yTickNum = 0
  protected yTickStep = 0
  protected xAxisOpt: AxisInterface = xAxisOpt;
  protected yAxisOpt: AxisInterface = yAxisOpt;
  protected yAxisNameHeight = 0

  setOption(opt: OptionInterface<number>): void {
    super.setOption(opt)
    this.xAxisOpt = opt.xAxis ?? {}
    this.yAxisOpt = opt.yAxis ?? {}
  }

  initData() {
    const xStart = 0
    const xEnd = this.xAxisOpt.data?.length ?? 1
    let seriesArr = this.series

    const dataArr = seriesArr.flatMap(seriesItem => seriesItem.data?.slice(xStart, xEnd)).filter(value => typeof value === 'number') as number[]
    const yInfo = calculateNum(dataArr)
    this.min = yInfo.min
    this.max = yInfo.max
    this.yTickNum = yInfo.num
    this.yTickStep = yInfo.step
  }

  // 绘制x轴
  drawXAxis(startZero: boolean = true) {
    const ctx = this.ctx, width = this.width, height = this.height
    const padding = this.padding
    const xStart = 0
    const xEnd = this.xAxisOpt.data?.length ?? 1
    const xLength = xEnd - xStart - (startZero ? 1 : -1)

    const chartWidth = width - padding.left! - padding.right!
    this.xs = chartWidth / xLength
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
      ctx!.lineTo(chartWidth, 0)
      ctx!.stroke()
    }
    // 画刻度和标签
    const axisTickShow = this.xAxisOpt.axisTick?.show
    const tickLine = this.xAxisOpt.axisTick?.lineStyle ?? axisLineStyle
    const fontColor = xAxisLabel.color ?? "#999999"
    const fontWeight = xAxisLabel.fontWeight ?? "normal"
    const fontSize = xAxisLabel.fontSize ?? 23
    const fontFamily = xAxisLabel.fontFamily ?? "sans-serif"
    const overflow = xAxisLabel.overflowType ?? 'none'
    const margin = xAxisLabel.margin ?? 5
    for (let i = 0; i < xEnd; i++) {
      let value = xData[i]
      let x = Math.round(this.xs * (startZero ? i : (i + 1)))

      if (axisTickShow) {
        const color = tickLine.color
        const width = tickLine.width
        ctx!.beginPath()
        ctx!.strokeStyle = color ?? '#999'
        ctx!.lineWidth = width ?? 1
        ctx!.moveTo(x, 0)
        ctx!.lineTo(x, xAxisTickLength)
        ctx!.stroke()

      }

      ctx!.font = `${fontWeight} ${fontSize}px ${fontFamily}`
      ctx!.fillStyle = fontColor
      ctx!.textAlign = 'left'
      ctx!.textBaseline = 'middle'
      value = String(value)
      const textW = ctx!.measureText(value).width
      const textX = Math.round(x - (textW / 2))
      const textY = xAxisTickLength + margin
      let textI = value.length
      if (overflow === 'break') {
        textI = drawTexts(ctx, value, this.xs)
        ctx!.fillText(value.substring(0, textI) + (textI !== value.length ? '...' : ''), textX, textY)
      } else if (overflow === 'breakAll') {
        drawBreakText(ctx, value, this.xs, {
          x: textX,
          y: textY
        })
      } else {
        ctx!.fillText(value.substring(0, textI), textX, textY)
      }
    }

    ctx!.restore()
  }

  drawYAxis() {
    const ctx = this.ctx

    let yAxisNameHeight = this.yAxisNameHeight
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
      const measure = ctx!.measureText(yAxisName)
      yAxisNameHeight = measure.height
      const yAxisNameWidth = measure.width
      ctx!.fillText(yAxisName, this.padding.left! - yAxisNameWidth / 2,
        this.padding.top! - (this.yAxisOpt.nameGap ?? 5))
      if (yAxisNameHeight != 0) {
        this.yAxisNameHeight = yAxisNameHeight
      }
    }
    const chartHeight = this.height - this.padding.bottom! - this.padding.top! - yAxisNameHeight
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
      ctx!.lineTo(0, -chartHeight)
      ctx!.stroke()
    }

    // 画y轴刻度、刻度数值和分割线
    let yTickNum = this.yTickNum // 刻度数量默认为5
    let yTickUnit = chartHeight / yTickNum
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
        ctx!.moveTo(0, -yTick)
        ctx!.lineTo(-axisTickLength!, -yTick)
        ctx!.stroke()
      }

      // 绘制分割线
      if (spliceLineStyle?.show) {
        const color = spliceLineStyle.color ?? '#DDE2EB'
        const width = spliceLineStyle.width ?? 1

        ctx!.beginPath()
        ctx!.strokeStyle = color
        ctx!.lineWidth = width
        ctx!.moveTo(0, -yTick)
        ctx!.lineTo(chartWidth, -yTick)
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
      ctx!.textAlign = 'right'
      ctx!.textBaseline = 'middle'
      const text = String(Math.floor(this.min! + this.yTickStep * (i + 1)))
      const txtWidth = ctx!.measureText(text!).width; // 获取文字的长度
      const txtX = -(txtWidth + (axisTick?.show ? axisTick?.length! : 0) + (axisTick?.interval ?? 4)) // 文字长度 + 刻度长度 + 两者之间的间距
      ctx!.fillText(text, txtX, -yTick)
    }

    ctx!.restore()
  }
}