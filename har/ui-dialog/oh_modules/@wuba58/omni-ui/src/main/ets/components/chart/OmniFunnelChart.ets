import { OmniTheme, OmniThemeStyle } from "../../theme/OmniTheme";

@Component
export struct OmniFunnelChart {
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true));
  @State private funnelChartHeight: number = 0
  /**
   * 漏斗图入参
   */
  @Require @Prop @Watch('renderFunnelChart') config: OmniFunnelChartConfig
  @StorageLink(OmniTheme.KEY)
  baseStyle: OmniThemeStyle = OmniTheme.getDefaultStyle()

  /**
   * 实际渲染漏斗图逻辑
   */
  renderFunnelChart() {
    if (this.config.maxLayerWidth <= this.config.minLayerWidth) {
      return
    }
    let layerHeight = this.config.layerHeight ?? 40
    //漏斗图的高度
    let yOffset = this.config.layerMargin ?? 0
    this.funnelChartHeight = layerHeight * this.config.layerCount + yOffset * (this.config.layerCount - 1)

    //给个默认的背景色
    let axisBackground = 0xFFEEF0FF
    if (this.config.axisBackground) {
      this.context.fillStyle = this.config.axisBackground;
    } else {
      this.context.fillStyle = axisBackground;
    }
    // 绘制画布的背景
    this.context.fillRect(0, 0, this.context.width, this.funnelChartHeight);

    //layer的起始坐标
    let layerStartX = 0;
    let layerStartY = layerHeight / 2;
    //计算layer间diff宽度
    let layerDiffWidth = (this.config.maxLayerWidth - this.config.minLayerWidth) / this.config.layerCount

    //layer上文本的起始x坐标
    let layerTextStartX = 0;
    //layer后面widget文本的起始x坐标
    let markerTextStartX = 0;

    for (let i = 0; i < this.config.layerCount; i++) {
      if (this.config.shape == OmniFunnelShape.Left) {
        layerStartX = i * layerDiffWidth
        layerTextStartX = (i + 1) * layerDiffWidth
        markerTextStartX = this.config.maxLayerWidth
      } else if (this.config.shape == OmniFunnelShape.Right) {
        layerStartX = 0
        layerTextStartX = (this.config.maxLayerWidth - i * layerDiffWidth) / 2
        markerTextStartX = this.config.maxLayerWidth - i * layerDiffWidth
      } else {
        layerStartX = i * layerDiffWidth / 2
        layerTextStartX =this.config.maxLayerWidth / 2
        markerTextStartX = this.config.maxLayerWidth - i * layerDiffWidth / 2
      }

      let yOffset = this.config.layerMargin ?? 0

      //绘制漏斗形状
      drawFunnel({
        context: this.context,
        startX: layerStartX,
        startY: layerHeight * i + yOffset * i,
        width: this.config.maxLayerWidth - i * layerDiffWidth,
        height: layerHeight,
        funnelColor: this.config.defaultLayerColor[i % this.config.defaultLayerColor.length],
        diffWidth: layerDiffWidth,
      }, this.config.shape)

      //设置文本样式
      let fontStyle = 'normal normal 50px sans-serif'
      if (this.config.layerTextFont) {
        this.context.font = this.config.layerTextFont;
      } else {
        this.context.font = fontStyle;
      }

      //画横条上的文本
      this.context.fillStyle = this.config.layerTextColor ?? 0xffffffff;
      let layerTitle = this.config.layerTitles[i];
      if (layerTitle) {
        const measuredText = this.context.measureText(layerTitle)
        if (this.config.shape != OmniFunnelShape.Left) {
          layerTextStartX -= measuredText.width / 2;
        }
        this.context.fillText(layerTitle, layerTextStartX,
          layerStartY + layerHeight * i + yOffset * i)
      } else {
        this.context.fillText(`layer${i + 1}`, layerTextStartX,
          layerStartY + layerHeight * i + yOffset * i)
      }

      //设置文本样式
      if (this.config.markerTextFont) {
        this.context.font = this.config.markerTextFont;
      } else {
        this.context.font = fontStyle;
      }

      //画marker
      this.context.fillStyle = this.config.markerTextColor ?? 0xff000000
      let markerTitle = this.config.markerTitles[i]
      if (markerTitle) {
        this.context.fillText(markerTitle, markerTextStartX,
          layerStartY + layerHeight * i + yOffset * i)
      } else {
        this.context.fillText(`marker${i + 1}`, markerTextStartX,
          layerStartY + layerHeight * i + yOffset * i)
      }
    }
  }

  build() {
    Row() {
      Canvas(this.context)
        .height(this.funnelChartHeight)
        .onReady(() => {
          this.renderFunnelChart()
        })
    }
  }
}


function drawFunnel(options: FunnelChartOptions, shape?: OmniFunnelShape) {
  if (shape == OmniFunnelShape.Left) {
    drawLeftFunnel(options)
  } else if (shape == OmniFunnelShape.Right) {
    drawRightFunnel(options)
  } else {
    drawBothFunnel(options)
  }
}

//(startX,startY),(startX,startY+height),(startX+width-height,startY+height),(startX+width,startY)
function drawRightFunnel(options: FunnelChartOptions) {
  options.context.beginPath()
  options.context.moveTo(options.startX, options.startY) //设置中心点
  options.context.lineTo(options.startX, options.startY + options.height)
  if (options.diffWidth) {
    options.context.lineTo(options.startX + options.width - options.diffWidth, options.startY + options.height)
  } else {
    options.context.lineTo(options.startX + options.width - options.height, options.startY + options.height)
  }
  options.context.lineTo(options.startX + options.width, options.startY)
  options.context.fillStyle = options.funnelColor
  options.context.fill()
  options.context.closePath()
}

function drawLeftFunnel(options: FunnelChartOptions) {
  options.context.beginPath()
  options.context.moveTo(options.startX, options.startY) //设置中心点
  if (options.diffWidth) {
    options.context.lineTo(options.startX + options.diffWidth, options.startY + options.height)
  } else {
    options.context.lineTo(options.startX + options.height, options.startY + options.height)
  }
  options.context.lineTo(options.startX + options.width, options.startY + options.height)
  options.context.lineTo(options.startX + options.width, options.startY)
  options.context.fillStyle = options.funnelColor
  options.context.fill()
  options.context.closePath()
}

function drawBothFunnel(options: FunnelChartOptions) {
  options.context.beginPath()
  options.context.moveTo(options.startX, options.startY) //设置中心点
  if (options.diffWidth) {
    options.context.lineTo(options.startX + options.diffWidth / 2, options.startY + options.height)
    options.context.lineTo(options.startX + options.width - options.diffWidth / 2, options.startY + options.height)
    options.context.lineTo(options.startX + options.width, options.startY)
  } else {
    options.context.lineTo(options.startX + options.height, options.startY + options.height)
    options.context.lineTo(options.startX + options.width - options.height, options.startY + options.height)
    options.context.lineTo(options.startX + options.width, options.startY)
  }
  options.context.fillStyle = options.funnelColor
  options.context.fill()
  options.context.closePath()
}

interface FunnelChartOptions {
  context: CanvasRenderingContext2D,
  startX: number,
  startY: number,
  width: number,
  height: number,
  funnelColor: Color,
  diffWidth?: number,
}

interface OmniFunnelChartConfig {
  layerCount: number
  defaultLayerColor: Color[]
  maxLayerWidth: number
  minLayerWidth: number
  layerTitles: string[]
  markerTitles: string[]
  layerHeight?: number
  axisBackground?: Color | undefined
  layerTextColor?: Color
  markerTextColor?: Color
  layerMargin?: number
  shape?: OmniFunnelShape
  layerTextFont?: string
  markerTextFont?: string
}

export enum OmniFunnelShape {
  Left,
  Right,
  Both,
}