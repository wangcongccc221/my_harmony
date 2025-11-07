import { countDownLatch, deepCopy, drawBreakText, drawTexts,
  isPointInsidePolygon,
  percentToNumer, rotatePoint } from '.';
import { InterfaceObj, OptionInterface, RadarInterface } from './chartInterface';
import { radar } from './defaultOption';
import { DrawBaseViewModel } from './DrawBaseViewModel';

interface RadarDataType {

}
class DrawRadarViewModel extends DrawBaseViewModel<number> {
  private maxValue = 0
  private selectIndex: number | null = null
  private radarConfig: RadarInterface = deepCopy(radar);

  // 保存已经绘制的数据信息，供提供点击时显示tooltip使用
  private pointArr: Array<InterfaceObj> = []
  constructor() {
    super('radar')
  }

  setOption(opt: OptionInterface<number>): void {
    super.setOption(opt)
    this.radarConfig = opt.radar || {}
  }

  initData() {
    let seriesArr = this.series

    const dataArr = seriesArr.flatMap(seriesItem => seriesItem.data).filter(value => typeof value === 'number') as number[]
    this.maxValue = Math.max(...dataArr)
  }

  create(): void {
    this.pointArr = []
    this.ctx!.save();
    this.setCenter()
    this.initData()

    this.drawBgAndText()
    this.drawRadarWithAnimate()
  }

  drawBgAndText() {
    let ctx = this.ctx
    let indicator = this.radarConfig.indicator ?? []
    let radius = this.getRadius()
    let rotateAngle = 90
    let splitNumber = this.radarConfig.splitNumber ?? 5
    let splitLineShow = this.radarConfig.splitLineStyle?.show ?? true
    let splitAreaShow = this.radarConfig.splitArea?.length!! > 0
    let axisLineShow = this.radarConfig.axisLineStyle?.show ?? true
    let totalDots = indicator.length

    // 绘制文字
    let axisName = this.radarConfig.axisName ?? {}
    const show = axisName.show ?? true
    const color = axisName.color ?? '999'
    const fontWeight = axisName.fontWeight ?? 'normal'
    const fontFamily = axisName.fontFamily ?? 'sans-serif'
    const fontSize = axisName.fontSize ?? 22
    const width = axisName.width ?? 0
    const overflowType = axisName.overflowType ?? 'none'
    const nameGap = this.radarConfig.nameGap ?? 10
    if (!show) return;
    let length = indicator.length;
    ctx!.fillStyle = color;
    ctx!.font = `${fontSize}px ${fontWeight} ${fontFamily}`;
    ctx!.textAlign = 'center';
    let startAngle = -rotateAngle * 2 * Math.PI / 360;
    for (let i = 0; i < indicator.length; i++) {
      const obj = String(indicator[i].name)
      let x = (radius * Math.cos(startAngle));
      let y = (radius * Math.sin(startAngle));
      //根据方向调整文字的对齐点
      let cos = Math.cos(startAngle);
      startAngle = startAngle - 2 * Math.PI / length;
      if (Math.abs(cos) < 10e-4) {
        ctx!.textAlign = 'center';
        if (y < 0) {
          y -= nameGap
        } else {
          y += nameGap
        }
      } else if (cos > 0) {
        ctx!.textAlign = 'left';
        x += nameGap
      } else {
        ctx!.textAlign = 'right';
        x -= nameGap
      }
      if (width !== 0 && overflowType !== 'none') {
        const textX = x
        const textY = y
        let textI = obj.length
        if (overflowType === 'break') {
          textI = drawTexts(ctx, obj, width)
          ctx!.fillText(obj.substring(0, textI) + '...', textX, textY)
        } else if (overflowType === 'breakAll') {
          drawBreakText(ctx, obj, width, {
            x: textX,
            y: textY
          })
        }
      } else {
        ctx!.fillText(obj, x, y);
      }
    }
    // 绘制雷达坐标
    startAngle = 0
    splitNumber = Math.max(splitNumber, 1)
    ctx!.rotate(-rotateAngle * 2 * Math.PI / 360);
    for (let index = 0; index < splitNumber; index++) {
      // 算出每个间隔的距离
      let R = radius * (1 - index / splitNumber);
      const startX = R * Math.cos(startAngle);
      const startY = R * Math.sin(startAngle);
      // 绘画每一个环
      ctx!.beginPath();
      ctx!.moveTo(startX, startY);
      for (let i = 1; i < totalDots + 1; i++) { // 多画一个闭合路径
        const startX = R * Math.cos(startAngle);
        const startY = R * Math.sin(startAngle);
        ctx!.lineTo(startX, startY);
        startAngle = startAngle - 2 * Math.PI / totalDots;
      }
      if (splitLineShow || index == 0) {
        ctx!.lineWidth = 1;
        ctx!.strokeStyle = "#DBDBDB";
      } else {
        ctx!.lineWidth = 0;
        ctx!.strokeStyle = "rgba(0,0,0,0)";
      }
      ctx!.closePath();
      ctx!.stroke();
      if (splitAreaShow) {
        if (index % 2 === 0) {
          ctx!.fillStyle = '#fff';
        } else {
          ctx!.fillStyle = 'rgba(200,200,200,0.2)';
        }
        ctx!.fill();
      }
      // 绘画分割线
      if (axisLineShow) {
        startAngle = 0;
        const width = this.radarConfig.axisLineStyle?.width ?? 1
        const color = this.radarConfig.axisLineStyle?.color ?? '#DBDBDB'
        for (let i = 1; i < totalDots + 1; i++) { // 多画一个闭合路径
          const startX = R * Math.cos(startAngle);
          const startY = R * Math.sin(startAngle);
          startAngle = startAngle - 2 * Math.PI / totalDots;
          ctx!.beginPath();
          ctx!.lineWidth = width;
          ctx!.strokeStyle = color;
          ctx!.lineTo(startX, startY);
          ctx!.lineTo(0, 0); // 从中心点触发去绘画
          ctx!.closePath();
          ctx!.stroke();
        }
      }
    }



  }

  bindEvent(e: ClickEvent, callback: Function): void {
    if (this.drawing) return;
    const ctx = this.ctx
    const x = e.x
    const y = e.y

    const center = this.setCenter(false)

    const configAngle = this.radarConfig.startAngle ?? 90
    const rotateAngle = configAngle * 2 * Math.PI / 360
    let locatedPoint = rotatePoint(x, y, center.centerX, center.centerY, rotateAngle)

    let selectedIndex: number | null = null
    for (let i = 0; i < this.pointArr.length; i++) {
      const point = this.pointArr[i];
      // 判断当前点击的位置是否在多边形内
      if (isPointInsidePolygon(point.turnPoints, locatedPoint)) {
        selectedIndex = i
      }
    }

    if (selectedIndex !== null) {
      // 清空画布重新绘制
      ctx!.translate(0, 0);
      ctx!.save();
      ctx!.clearRect(0, 0, this.width, this.height);
      this.setCenter(true)
      this.drawBgAndText()
      this.drawRadarWithAnimate(selectedIndex)

      callback(
        true,
        e,
        {
          x: x,
          y: y,
          W: this.width,
          H: this.height
        },
        this.pointArr[selectedIndex].name,
        this.radarConfig.indicator?.map((item, index) => {
          return {
            name: item.name,
            num: this.pointArr[selectedIndex!!].seriesItem.data[index] || 0
          } as InterfaceObj
        }),
        this.tooltip
      )
    } else {
      callback(false, e)
    }
  }

  async drawRadarWithAnimate(selectedIndex: number | null = null) {
    const ctx = this.ctx

    let indicator = this.radarConfig.indicator ?? []
    let radius = this.getRadius()
    this.drawing = true

    const indicatorCount = indicator.length

    const defaultColor = this.color
    for (let i = 0; i < this.series.length; i++) {
      const seriesItem = this.series[i];
      const lineStyle = seriesItem.lineStyle ?? {}
      const areaStyle = seriesItem.areaStyle ?? {}

      ctx!.lineWidth = (this.selectIndex === i ? lineStyle.width! * 1.4 : lineStyle.width) ?? 1
      ctx!.strokeStyle = lineStyle.color || defaultColor[i % defaultColor.length]
      let valueArr = seriesItem.data ?? []
      ctx!.beginPath()
      let startAngle = 0
      let turnPoints: InterfaceObj[] = []
      for (let j = 0; valueArr.length == indicatorCount && j < indicatorCount; j++) {
        const value = valueArr[j];
        let R = radius * (value / this.maxValue);
        const startX = R * Math.cos(startAngle);
        const startY = R * Math.sin(startAngle);
        startAngle = startAngle - 2 * Math.PI / indicatorCount;
        if (j === 0) {
          ctx!.moveTo(startX, startY);
        } else {
          ctx!.lineTo(startX, startY);
        }

        ctx!.stroke()
        turnPoints.push({
          x: startX,
          y: startY
        })
        if (selectedIndex == null) {
          await countDownLatch(1)
        }
      }
      ctx!.closePath()
      ctx!.stroke()
      this.pointArr.push({seriesItem, turnPoints})
      const areaColor = areaStyle.color
      if (areaColor) {
        if (typeof areaColor === 'string') {
          ctx!.fillStyle = areaColor
        } else if (typeof areaColor === 'object') {
          const direction = areaColor.direction || [0, 1, 0, 0]
          const gradientColors = areaColor.colors || []
          const gradient = ctx!.createLinearGradient(this.width / 2 * (direction[0] || 0), -this.height * (direction[1] || 1), this.width / 2 * (direction[2] || 0), -this.height * (direction[0] || 0));
          gradientColors.forEach(item => {
            gradient.addColorStop(0.2, item)
          })
          ctx!.fillStyle = gradient;
        }
        ctx!.fill()
      }

    }
    this.drawing = false
    ctx!.restore()
  }

  getRadius(): number {
    let radius = this.radarConfig.radius
    return typeof radius === 'string' && radius.indexOf('%') !== -1 ? (this.width / 2) * percentToNumer(radius) : (Number(radius) || (this.width / 2 * 0.5))
  }

  setCenter(moveCenter = true): InterfaceObj {
    const cx = this.width * percentToNumer('50%')
    const cy = this.height * percentToNumer('50%')
    if (moveCenter) {
      this.ctx!.translate(cx, cy);
    }
    return { centerX: cx, centerY: cy }
  }
}

export {
  RadarDataType,
  DrawRadarViewModel
}
