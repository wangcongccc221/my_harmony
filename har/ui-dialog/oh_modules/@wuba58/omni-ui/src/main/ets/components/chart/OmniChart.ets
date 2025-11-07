import { InterfaceObj, OptionInterface } from './utils/chartInterface'
import { Tooltip, globalBuilder } from './Tooltip'
import { Options } from './Options'
import { DrawBaseViewModel } from './utils/DrawBaseViewModel'

type ChartUnionData = object | number | string

@Component
export struct OmniChart {
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  drawViewModel: DrawBaseViewModel<ChartUnionData> | null = null;
  click: Function = (event: ClickEvent, args: InterfaceObj) => {};
  tooltipClick: Function = () => {};
  @Link @Watch('onCountUpdated') options: OptionInterface<ChartUnionData>;
  @Link renderType: string
  @State isTooltipShow: boolean = false
  @State tooltipInfo: InterfaceObj = {}
  @BuilderParam customTooltip: (tooltipInfo: InterfaceObj) => void = globalBuilder; // 自定义组件

  onCountUpdated(options: Options<ChartUnionData>): void {
    this.isTooltipShow = false
    this.drawViewModel && this.drawViewModel.draw(this.context, this.options, this.renderType)
  }

  updateTooltipInfo (flag: boolean, event: ClickEvent, pos?: InterfaceObj, title?: string, arr?: [], tooltipInfo: InterfaceObj = {}) {
    if (!tooltipInfo.show) {
      this.isTooltipShow = false
      return;
    }
    this.isTooltipShow = flag
    if (tooltipInfo.type !== 'default') {
      this.tooltipClick && this.tooltipClick(event, flag ? { title, pos, data: arr } : {})
    }
    if (tooltipInfo.type !== 'default') return;
    if (this.isTooltipShow) {
      this.tooltipInfo = {
        pos,
        title,
        data: arr
      }
      const keys = Object.keys(tooltipInfo)
      keys.forEach(item => {
        this.tooltipInfo[item] = tooltipInfo[item]
      })
    }
  }

  build() {
    Column () {
      Canvas(this.context)
        .width('100%')
        .height('100%')
        .onReady(() => {
          this.drawViewModel && this.drawViewModel.draw(this.context, this.options, this.renderType)
        })
        .onClick((event) => {
          if (this.drawViewModel) {
            this.drawViewModel.bindEvent(event, (flag: boolean, event: ClickEvent, pos: InterfaceObj = {}, title: string = '', arr: [] = [], tooltipInfo: InterfaceObj = {}) => {
              this.click && this.click(event, flag ? {
                title,
                data: arr
              } : {})
              this.updateTooltipInfo(flag, event, pos, title, arr, tooltipInfo)
            })
          }
        })

      if (this.isTooltipShow) {
        Tooltip({
          tooltipInfo: $tooltipInfo,
          customTooltip: this.customTooltip
        })
      }
    }
    .width('100%')
    .height('100%')
    .onDisAppear(() => {
      this.drawViewModel && this.drawViewModel.clear()
    })
  }
}
