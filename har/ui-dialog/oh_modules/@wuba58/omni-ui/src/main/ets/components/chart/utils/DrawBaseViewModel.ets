import { LegendInterface, TooltipInterface, SeriesInterface, InterfaceObj,
  OptionInterface,
  ChartType,
  Padding } from './chartInterface'
import { assign, deepCopy } from './index'
import { seriesOpt, tooltip, legend, legendTextStyle } from './defaultOption'
import { percentToNumer, roundRect } from './index'

/**
 * 图表基类
 */
export abstract class DrawBaseViewModel<T> {
  type?: ChartType;
  ctx?: CanvasRenderingContext2D;
  padding: Padding = {
    top: 30,
    bottom: 30,
    left: 30,
    right: 30
  }
  renderType: string = 'init';
  width: number = 0;
  height: number = 0;
  stepNum: number = 0; // 滚动距离
  color: Array<string> = ['#5f45ff', '#DIDEAF', '#ff50f2ff', '#EEF1C8', '#0090ff', '#F7B73E', '#A06AFP', '#F5A95F'];
  legend: LegendInterface = deepCopy(legend);
  title: InterfaceObj = {};
  legendData: Array<InterfaceObj> = [];
  tooltip: TooltipInterface = deepCopy(tooltip);
  series: Array<SeriesInterface<T>> = [];
  animateArr: Array<InterfaceObj> = [];
  previousData: Array<InterfaceObj> = []; // 存储历史数据
  drawing: boolean = false;
  seriesOpt: SeriesInterface<T> = deepCopy(seriesOpt);

  constructor (type: ChartType) {
    this.type = type
    if (type === 'pie') {
      // 如果是饼图就默认显示在区域外面
      this.seriesOpt!.label!.position = 'outside'
    }
  }

  draw(ctx: CanvasRenderingContext2D, opt: OptionInterface<T>, renderType: string) {
    this.ctx = ctx
    this.width = ctx.width
    this.height = ctx.height
    this.renderType = renderType
    ctx.translate(0, 0);
    ctx.restore()
    ctx.clearRect(0, 0, this.width, this.height);
    this.setOption(opt)
    this.create()
  }
  setOption(opt: OptionInterface<T>) {
    Object.keys(opt).forEach(key => {
      const item: object = opt[key]
      switch (key) {
        case 'padding':
          this.padding = item
          break
        case 'tooltip':
          this.tooltip = assign({}, deepCopy(this.tooltip), item)
          break
        case 'title':
          this.title = assign({}, this.title, item)
          break
        case 'color':
          this.color = deepCopy(item)
          break
        case 'legend':
          item['textStyle'] =  assign({}, deepCopy(legendTextStyle), item['textStyle'])
          this.legend = assign({}, deepCopy(legend), item)
          break
        case 'series':
          if (Array.isArray(item)) {
            this.series = item.map((li: object) => {
              return assign({}, this.seriesOpt, li)
            })
          }
          break
      }
    })

  }
  create () {

  }
  abstract bindEvent (e: ClickEvent, callback: Function)

  setCtxStyle(style: object) {
    let ctx = this.ctx as object
    let keys = Object.keys(style)
    keys.forEach((key) => {
      ctx[key] = style[key];
    })
  }

  drawDescriptions(data: Array<SeriesInterface<T>>) {
    const top = this.legend.top ?? 0
    const show = this.legend.show
    const itemTextGap = this.legend.itemTextGap ?? 0
    const itemGap = this.legend.itemGap ?? 0
    const itemWidth = this.legend.itemWidth ?? 0
    const itemHeight = this.legend.itemHeight ?? 0
    const textStyle = this.legend.textStyle
    const left = this.legend.left
    if (!show) return;
    let sp = 0;
    let item: SeriesInterface<T> | null = null;
    let ctx = this.ctx
    const color = textStyle!.color
    const fontWeight = textStyle!.fontWeight
    const fontSize = textStyle!.fontSize
    const fontFamily = textStyle!.fontFamily
    // 先计算出整体的宽度，然后设置居中
    for (let i = 0; i < data.length; i++) {
      item = data[i]
      ctx!.font = `${fontWeight} ${fontSize}px ${fontFamily}`;
      ctx!.textAlign = 'left'
      ctx!.textBaseline = "middle";
      ctx!.fillStyle = color ?? "#999"
      const tw = ctx!.measureText(item.name).width
      sp += itemWidth + tw + itemTextGap + itemGap
    }
    ctx!.save()
    ctx!.translate(this.width * percentToNumer(left) - sp / 2, this.height * percentToNumer(top))
    sp = 0
    this.legendData = []
    for (let i = 0; i < data.length; i++) {
      item = data[i]
      ctx!.fillStyle = item.color ?? '#999'
      roundRect(ctx, sp, percentToNumer(top), itemWidth, itemHeight, 2)
      ctx!.fill()
      ctx!.font = `${fontWeight} ${fontSize}px ${fontFamily}`;
      ctx!.textAlign = 'left'
      ctx!.textBaseline = "middle";
      ctx!.fillStyle = color ?? '#999'
      const tw = ctx!.measureText(item.name).width
      const th = ctx!.measureText(item.name).height
      ctx!.fillText(item.name, itemWidth + sp + itemTextGap, percentToNumer(top) + itemHeight / 2)
      // 计算每個图例的距离：上一个的图例宽度 + 上一个的图例文本与图例间隔 + 图例之间的间隔
      sp += itemWidth + tw + itemTextGap + itemGap
      this.legendData.push({
        hide: !!item.hide,
        name: item.name,
        x: itemWidth + sp + itemTextGap,
        y: this.height * percentToNumer(top),
        w: sp,
        h: Math.max(th, itemHeight)
      });
    }
    ctx!.restore()
  }


  protected isInChart(x: number, y: number): boolean {
    return y >= this.padding.top! && y <= this.height - this.padding.bottom! && x >= this.padding.left! && x <= this.width - this.padding.right!
  }

  clear() {
    this.ctx?.restore()
    this.ctx?.clearRect(0, 0, this.width, this.height)
  }
}