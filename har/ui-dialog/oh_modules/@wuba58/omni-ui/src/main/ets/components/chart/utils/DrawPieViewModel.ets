import { DrawBaseViewModel } from './DrawBaseViewModel'
import { percentToNumer, isPointInSector, roundRect, getColor, deepCopy, assign } from './index'
import { legend as commonLegend, legendTextStyle, label as commonLabel, labelLine as commonLabelLine, lineStyle as commonLineStyle,
  emphasis as commonEmphasis} from './defaultOption'
import { HighlightStyle, InterfaceObj, LabelLineStyle, LabelStyle, LineStyle, SeriesInterface,
  SeriesItemType } from './chartInterface'


interface PieDataType {
  name?: string,
  value?: number,
  color?: string,
  hide?: boolean,
  wf?: boolean,
  wrapFlag?: boolean
}
class DrawPieViewModel extends DrawBaseViewModel<PieDataType> {
  private radius = ['70%', '40%']
  private center = ['50%', '50%']
  private radi: InterfaceObj = { inner: '40%', outer: '70%'}
  private padAngle: number = 0
  // 标签设置，标签的视觉引导线配置
  private label: LabelStyle = {
    show: true,
    position: 'outside',
    // 文字与 label line 之间的距离
    distanceToLabelLine: 5
  }
  // 标签的视觉引导线配置
  private labelLine: LabelLineStyle = {
    show: true, // 默认开启，如果当label的position的值不是outside，则自动隐藏
    length: 10,
    length2: 20,
    minTurnAngle: 90
  }
  // 标签的视觉引导线配置
  private lineStyle: LineStyle = {
    color: '',
    width: 2,
    type: 'solid'
  }
  // 高亮状态的扇区和标签样式。
  private highLightStyle: HighlightStyle = {
    scale: true,
    scaleSize: 4,
    shadowColor: 'rgba(0, 0, 0, 0.5)',
    shadowBlur: 15,
    shadowOffsetX: 0,
    shadowOffsetY: 0
  }
  // 存储所有图形的数据
  private pieData: Array<PieDataType> = []

  private timer?: number

  constructor () {
    super('pie')
  }
  bindEvent(e: ClickEvent, callback: Function) {
    let startAng = -Math.PI / 2;
    let isLegend = false;
    let posX = e.x
    let posY = e.y
    const centerX = this.setCenter(true)[0]
    const centerY = this.setCenter(true)[1]
    let radius = this.getRadius()[0]
    let innerRadius = this.getRadius()[1]
    if (isLegend || this.drawing || !this.animateArr.length) return;
    for (let i = 0, l = this.animateArr.length; i < l; i++) {
      const item = this.animateArr[i];
      if (item.hide) continue;
      // 判断当前点击是否在某个扇形区域里面
      const angle = startAng + (item.ang as number);
      // 如果是渲染环形的话，先判断点击是否是点击内部圆圈
      if (innerRadius) {
        const flag = isPointInSector(posX, posY, centerX, centerY, innerRadius, startAng, angle)
        if (flag) {
          callback(false, e)
          this.clearGrid();
          break;
        }
      }
      const flag = isPointInSector(posX, posY, centerX, centerY, radius, startAng, angle)
      if (flag) {
        this.clearGrid(i)
        posX -= 20
        callback(true, e, {
          x: posX,
          y: posY,
          W: this.width,
          H: this.height
        }, '', [{
          name: item.name,
          num: item.num
        }], this.tooltip)
        break;
      }
      startAng += item.ang;
      callback(false, e)
      this.clearGrid();
    }
  }
  clearGrid(index?: number) {
    let that = this,
      ctx = that.ctx,
      label = that.label,
      labelLine = that.labelLine,
      lineStyle = that.lineStyle,
      item: InterfaceObj, startAng = -Math.PI / 2,
      len = that.animateArr.filter(item => !item.hide).length, labels: Array<Label> = [],
      angle = 0;
    // 判断是否标签类型是在饼图外
    const isLine = label.position === 'outside' && labelLine.show
    let radius = that.getRadius()[0] ?? 0
    let innerRadius = that.getRadius()[1]
    ctx!.clearRect(0, 0, that.width, that.height);
    that.drawDescriptions(this.pieData);
    ctx!.save();
    that.setCenter()
    const length = labelLine.length ?? 10
    const length2 = labelLine.length2 ?? 20
    const color = lineStyle.color
    const width = lineStyle.width
    let j = 0
    for (let i = 0, l = that.animateArr.length; i < l; i++) {
      item = that.animateArr[i];
      if (item.hide) continue;
      j++
      ctx!.strokeStyle = item.color;
      ctx!.fillStyle = item.color;

      angle = startAng + item.ang - (index === len ? 0 : (this.padAngle / 2));
      if (label.show) {
        //画描述
        let tr = radius,
          textAlign = 'center',
          tAng = startAng + item.ang / 2,
          x = tr * Math.cos(tAng),
          y = tr * Math.sin(tAng);
        let labelX = 0, labelY = y;
        if (isLine) {
          ctx!.lineWidth = width ?? 0;
          ctx!.strokeStyle = color || item.color;
          ctx!.lineCap = 'round';
          ctx!.beginPath();
          ctx!.moveTo(x, y);
          const lengthX = (tr + length) * Math.cos(tAng)
          const lengthY = (tr + length) * Math.sin(tAng)
          const lengthY2 = (tr + length2) * Math.sin(tAng)
          labelY = lengthY2
          if (tAng >= -Math.PI / 2 && tAng <= Math.PI / 2) {
            ctx!.lineTo(lengthX, lengthY);
            ctx!.lineTo(x + length2, lengthY2);
          } else {
            ctx!.lineTo(lengthX, lengthY);
            ctx!.lineTo(x - length2, lengthY2);
          }
        }
        if (tAng >= -Math.PI / 2 && tAng <= Math.PI / 2) {
          labelX = x + (label.distanceToLabelLine ?? 5) + (isLine ? length2 : 0)
          textAlign= 'left'
        } else {
          labelX = x - (label.distanceToLabelLine ?? 5) - (isLine ? length2 : 0)
          textAlign = 'right'
        }

        if (label.position === 'center') {
          textAlign = 'center'
          labelX = x / 2
          labelY = y / 2
        }

        labels.push({
          textAlign,
          i,
          value: typeof label.formatter === 'function' ? label.formatter(item) : item.name,
          x: labelX,
          y: labelY
        })
        isLine && ctx!.stroke();
      }
      ctx!.beginPath();
      ctx!.moveTo(0, 0);
      ctx!.save();
      if (innerRadius) {
        let outR = radius
        let innerR = innerRadius
        if (index === i) {
          // ctx.save();
          const scale = that.highLightStyle.scale
          const scaleSize = that.highLightStyle.scaleSize ?? 0
          if (scale) {
            ctx!.shadowColor = that.highLightStyle.shadowColor ?? 'rgba(0, 0, 0, 0.5)'
            ctx!.shadowBlur = that.highLightStyle.shadowBlur ?? 15;
            ctx!.shadowOffsetX = that.highLightStyle.shadowOffsetX ?? 0;
            ctx!.shadowOffsetY = that.highLightStyle.shadowOffsetY ?? 0;
          }
          outR = radius + (scale ? scaleSize : 0)
          innerR = innerR + (scale ? scaleSize : 0)
        }
        // 绘制扇形
        ctx!.beginPath();
        // 移动到外圆的起始点
        let startPointX = outR * Math.cos(startAng)
        let startPointY = outR * Math.sin(startAng)
        ctx!.moveTo(startPointX, startPointY);
        // 绘制外圆的圆弧
        ctx!.arc(0, 0, outR, startAng, angle);
        // 绘制内圆的圆弧
        ctx!.arc(0, 0, innerR, angle, startAng, true);

      } else {
        if (index === i) {
          // ctx.save();
          const scale = that.highLightStyle.scale
          const scaleSize = that.highLightStyle.scaleSize ?? 0
          if (scale) {
            ctx!.shadowColor = that.highLightStyle.shadowColor ?? 'rgba(0, 0, 0, 0.5)'
            ctx!.shadowBlur = that.highLightStyle.shadowBlur ?? 15;
            ctx!.shadowOffsetX = that.highLightStyle.shadowOffsetX ?? 0;
            ctx!.shadowOffsetY = that.highLightStyle.shadowOffsetY ?? 0;
          }
          ctx!.arc(0, 0, radius + (scale ? scaleSize : 0), startAng, angle, false);
        } else {
          ctx!.arc(0, 0, radius, startAng, angle, false);
        }
      }
      ctx!.closePath();
      ctx!.fill();
      ctx!.restore();
      startAng = angle + that.padAngle / 2;
    }
    labels.forEach((lab) => {
      ctx!.textAlign = lab.textAlign as CanvasTextAlign
      that.fillText(lab, label)
    })
    ctx!.restore();
  }

  drawDescriptions(data: Array<PieDataType>) {
    data = deepCopy(data)
    const show = this.legend.show ?? commonLegend.show
    const itemGap = this.legend.itemGap ?? commonLegend.itemGap
    const itemTextGap = this.legend.itemTextGap ?? commonLegend.itemTextGap
    const itemWidth = this.legend.itemWidth ?? commonLegend.itemWidth
    const itemHeight = this.legend.itemHeight ?? commonLegend.itemHeight
    const textStyle = this.legend.textStyle ?? commonLegend.textStyle
    const left = this.legend.left ?? commonLegend.left
    const top = this.legend.top ?? commonLegend.top
    if (!show) return;
    let sp = 0;
    let wrapSp = 0;
    let item: PieDataType | null; let ctx = this.ctx;
    let W = this.width;
    let paddingLeft = this.padding.left ?? 30;
    let paddingRight = this.padding.right ?? 20;

    const fontFamily = textStyle?.fontFamily ?? legendTextStyle.fontFamily
    const color = textStyle?.color ?? legendTextStyle.color
    const fontWeight = textStyle?.fontWeight ?? legendTextStyle.fontWeight
    const fontSize = textStyle?.fontSize ?? legendTextStyle.fontSize
    // 先计算出整体的宽度，然后设置居中
    let isWrapFLag = false
    for (let i = 0; i < data.length; i++) {
      item = data[i]
      ctx!.font = `${fontWeight} ${fontSize}px ${fontFamily}`;
      ctx!.textAlign = 'left'
      ctx!.textBaseline = "middle";
      ctx!.fillStyle = color ?? '999'
      const tw = ctx!.measureText(item.name).width
      sp += itemWidth! + tw + itemTextGap! + itemGap!
      wrapSp += itemWidth! + tw + itemTextGap! + itemGap!
      if (wrapSp >= (W - paddingLeft - paddingRight)) {
        wrapSp = 0
        isWrapFLag = true

      }
      if (sp >= (W - paddingLeft - paddingRight)) {
        item.wf = true
      }
    }
    ctx!.save()
    ctx!.translate(this.width * percentToNumer(left) - sp / 2, this.height * percentToNumer(top))
    sp = 0
    for (let i = 0; i < data.length; i++) {
      item = data[i]
      const tw = ctx!.measureText(item.name).width
      const th = ctx!.measureText(item.name).height
      const h = Math.max(th, itemHeight!)
      const wrapY = 0
      ctx!.fillStyle = item.color ?? '#999'
      roundRect(ctx, sp, percentToNumer(top) + wrapY, itemWidth, itemHeight, 2)
      ctx!.globalAlpha = item.hide ? 0.3 : 1
      ctx!.fill()
      ctx!.font = `${fontWeight} ${fontSize}px ${fontFamily}`;
      ctx!.textAlign = 'left'
      ctx!.textBaseline = "middle";
      ctx!.fillStyle = color ?? '999'
      ctx!.fillText(item.name, itemWidth! + sp + itemTextGap!, percentToNumer(top) + (itemHeight!) / 2 + wrapY)
      // 计算每個图例的距离：上一个的图例宽度 + 上一个的图例文本与图例间隔 + 图例之间的间隔
      sp += itemWidth! + tw + itemTextGap! + itemGap!
    }
    ctx!.restore()
  }

  animate() {
    let that = this,
      ctx = that.ctx,
      item: InterfaceObj | null = null,
      len = that.animateArr.filter(item => !item.hide).length;
    let radius = that.getRadius()[0]
    let innerRadius = that.getRadius()[1]
    const cx = that.setCenter(true)[0]
    const cy = that.setCenter(true)[1]
    let currentProgress = 1;
    const speed = 0.02;
    const data = that.animateArr

    let draw: Function = () => {
      ctx!.clearRect(0, 0, that.width, that.height);
      let startAngle = -Math.PI / 2;
      let endAngle = 0;
      let index = 0;
      for (let i = 0, l = that.animateArr.length; i < l; i++) {
        item = that.animateArr[i];
        if (item.hide) continue;
        index += 1
        // 计算扇形的结束角度
        const ang = (item.ang) * currentProgress
        endAngle = startAngle + ang - (index === len ? 0 : (that.padAngle / 2))

        // 绘画内部扇形
        if (innerRadius) {
          // 绘制扇形
          ctx!.beginPath();
          // 移动到外圆的起始点
          let startPointX = cx + radius! * Math.cos(startAngle)
          let startPointY = cy + radius! * Math.sin(startAngle)
          ctx!.moveTo(startPointX, startPointY);
          // 绘制外圆的圆弧
          ctx!.arc(cx, cy, radius, startAngle, endAngle);
          // 绘制内圆的圆弧
          ctx!.arc(cx, cy, innerRadius, endAngle, startAngle, true);
        } else {
          // 绘制扇形
          ctx!.beginPath();
          ctx!.moveTo(cx, cy);
          ctx!.arc(cx, cy, radius, startAngle, endAngle);
        }
        // 闭合路径
        ctx!.closePath();
        ctx!.fillStyle = item.color;
        ctx!.fill();
        // 更新起始角度，加上间隔角度
        startAngle = endAngle + (that.padAngle / 2);
      };
      // 更新当前角度
      currentProgress += speed;
      // 检查是否完成整个圆的绘制
      if (currentProgress <= 1) {
        // 使用setTimeout来模拟requestAnimationFrame
        this.timer = setTimeout(draw, 16); // 大约每16毫秒更新一次，模拟60fps
      } else {
        that.clearGrid();
      }
    }

    draw()
  }
  create() {
    if (this.timer) {
      clearTimeout(this.timer)
    }
    this.initData();
    this.animate();
  }
  initData() {
    let item: SeriesInterface<PieDataType> | null = null, total = 0;
    // this.pieData = []
    for (let i = 0; i < this.series.length; i++) {
      item = this.series[i]
      this.radius = item.radius || ['60%', '30%']
      this.center = item.center || ['50%', '50%']
      this.label = assign({commonLabel}, this.label, item.label)
      this.highLightStyle = assign({commonEmphasis}, this.highLightStyle, item.emphasis!)
      this.labelLine = assign({commonLabelLine}, this.labelLine, item.labelLine!)
      this.lineStyle = assign({commonLineStyle}, this.lineStyle, item.labelLine?.lineStyle)
      this.padAngle = (item!.padAngle ?? 0) * 2 * Math.PI / 360
      this.pieData = item.data || []
    }
    let pieDataItem: PieDataType
    this.legendData.length = 0;
    for (let i = 0; i < this.pieData.length; i++) {
      pieDataItem = this.pieData[i];
      // 赋予没有颜色的项
      if (!pieDataItem.color) {
        pieDataItem.color = getColor(i, this.color);
      }
      pieDataItem.name = pieDataItem.name || 'unnamed';
      if (pieDataItem.hide) continue;
      total += Math.abs(pieDataItem.value ?? 0);
    }

    for (let i = 0; i < this.pieData.length; i++) {
      let item = this.pieData[i];
      this.animateArr.push({
        i: i,
        create: true,
        hide: !!item.hide,
        name: item.name,
        color: item.color,
        num: item.value,
        percent: Math.round((item.value ?? 0) / total * 10000) / 100,
        ang: ((item.value ?? 0) / total) * Math.PI * 2,
        last: 0,
        cur: 0
      });
    }
  }
  // 获取中心坐标
  setCenter (flag = false): Array<number> {
    const wc = this.center[0]
    const hc = this.center[1]
    const cx = this.width * percentToNumer(wc)
    const cy = this.height * percentToNumer(hc)
    if (!flag) {
      this.ctx!.translate(cx, cy);
    }
    return [cx, cy]
  }
  // 获取转化后的半径
  getRadius () {
    const r = this.height * 0.5
    let radius = this.radius[0]
    let innerRadius = this.radius[1]
    return [r * percentToNumer(radius), innerRadius ? r * percentToNumer(innerRadius) : null]
  }
  fillText(label: Label, style: LabelStyle) {
    const ctx = this.ctx
    if (!style.show) return;
    ctx!.textBaseline = "middle";
    ctx!.font = `${style.fontWeight} ${style.fontSize}px ${style.fontFamily}`;
    ctx!.fillStyle = style.color || getColor(label.i, this.color)
    ctx!.fillText(label.value, label.x, label.y);
  }
}

interface Label {
  i: number,
  x: number,
  y: number,
  textAlign?: string,
  value: string
}

export {
  DrawPieViewModel,
  PieDataType
}