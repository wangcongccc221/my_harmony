import { countDownLatch } from '.';
import { AreaStyle, InterfaceObj, LineStyle, Point } from './chartInterface';
import { DrawAxisViewModel } from './DrawAxisViewModel';


interface LineDataType {}


class DrawLineViewModel extends DrawAxisViewModel {
  private selectedIndex: number | null = null

  constructor() {
    super('line')
  }


  create(): void {
    this.initData()

    // 画描述标签
    this.drawDescriptions(this.series)
    // 画x轴
    this.drawXAxis()
    // 画y轴
    this.drawYAxis()
    // 画折线
    this.drawLineBySeries()
  }

  bindEvent(e: ClickEvent, callback: Function): void {
    if (this.drawing) return
    const xStart = 0
    const xEnd = this.xAxisOpt.data?.length ?? 1
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
      this.drawXAxis()
      // 画y轴
      this.drawYAxis()

      if (selectedIndex != null && selectedIndex === this.selectedIndex) {
        // 重置选中的index状态
        selectedIndex = null
        this.selectedIndex = null
      }
      // 画折线
      this.drawLineBySeries(selectedIndex)
      if (selectedIndex !== null) {
        let tooltipData: InterfaceObj[] = []
        for (let i = 0; i < this.series.length; i++) {
          const seriesItem = this.series[i]
          tooltipData.push({name: seriesItem.name, num: seriesItem.data![selectedIndex!]})
        }
        callback(
          true,
          e,
          {
            x: this.xs * selectedIndex!,
            W: this.width,
            H: this.height
          },
          this.xAxisOpt.data![selectedIndex!],
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


  async drawLineBySeries(selectedIndex: number | null = null) {
    const ctx = this.ctx
    this.drawing = true
    ctx!.save()
    ctx!.translate(this.padding.left, this.height - this.padding.bottom!)

    // 画选中数据的标志线
    if (selectedIndex !== null && selectedIndex != 0) {
      const spliceLineStyle = this.yAxisOpt.splitLine
      const color = spliceLineStyle!.color ?? '#DDE2EB'
      const width = spliceLineStyle!.width ?? 1
      const markerLineX = this.xs * selectedIndex
      ctx!.beginPath()
      ctx!.strokeStyle = color
      ctx!.lineWidth = width
      ctx!.moveTo(markerLineX, -(this.height - this.padding.top! - this.padding.bottom! - this.yAxisNameHeight))
      ctx!.lineTo(markerLineX, 0)
      ctx!.setLineDash([5, 5]) // 分割线采用虚线样式
      ctx!.stroke()
      // 重置线默认样式
      ctx!.lineDashOffset = 0
      ctx!.setLineDash([0, 0])
    }

    const series = this.series
    const length = series.length
    for (let i = 0; i < length; i++) {
      const item = series[i];
      const lineStyle = item.lineStyle ?? {}
      const fillStyle = item.areaStyle ?? {}
      const data = item.data ?? []
      if (lineStyle && typeof lineStyle?.color === 'undefined') {
        lineStyle.color = item.color
      }
      await this.drawLineByDataAndStyle(data, lineStyle, fillStyle, selectedIndex == null)
    }

    ctx!.restore()
    this.drawing = false
  }

  async drawLineByDataAndStyle(data: number[], lineStyle: LineStyle, fillStyle: AreaStyle, isAnimate: boolean = false) {
    const ctx = this.ctx
    const yHeight = this.height - this.padding.top! - this.padding.bottom! - this.yAxisNameHeight
    let pointArr: Point[] = data.map((value, index) => {
      return {
        x: this.xs * index,
        y: yHeight * (value - this.min!) / (this.max! - this.min!)
      } as Point
    })

    const lineColor = lineStyle.color ?? this.color[0]
    const lineWidth = lineStyle.width ?? 1.5

    ctx!.strokeStyle = lineColor
    ctx!.lineWidth = lineWidth

    ctx!.beginPath()
    ctx!.moveTo(pointArr[0].x, -pointArr[0].y)
    for (let i = 1; i < pointArr.length; i++) {
      const curPoint = pointArr[i];
      // 开启动画
      if (isAnimate) {
        // await countDownLatch(1)
      }
      ctx!.lineTo(curPoint.x, -curPoint.y)
      ctx!.stroke()
    }
    ctx!.stroke()
    const fillColor = fillStyle.color
    if (fillColor) {
      ctx!.lineTo(pointArr[data.length - 1].x, 0)
      ctx!.lineTo(pointArr[0].x, 0)
      ctx!.lineTo(pointArr[0].x, -pointArr[0].y)
      if (typeof fillColor === 'string') {
        ctx!.fillStyle = fillColor
      } else if (typeof fillColor === 'object') {
        const chartW = this.width - this.padding.left! - this.padding.right!
        const direction = fillColor.direction || [0, 1, 0, 0]
        const gradientColors = fillColor.colors || []
        // 该api参数的含义可参考前端canvas的api
        const gradient = ctx!.createLinearGradient(chartW * direction[0], -this.height * direction[1], chartW * direction[2], -this.height * direction[3]);
        gradientColors.forEach((item, index) => {
          gradient.addColorStop(index === 0 ? 0 : 1, item)
          if (index == 2) return
        })

        ctx!.fillStyle = gradient;
      }
      ctx!.fill()
    }
  }
}

export {
  DrawLineViewModel, LineDataType
}