import { DrawPieViewModel, PieDataType } from './utils/DrawPieViewModel'
import { OmniChart } from './OmniChart'
import { Options } from './Options'
import { globalBuilder } from './Tooltip'
import { InterfaceObj, OptionInterface, TextStyle } from './utils/chartInterface'
import { DrawBaseViewModel } from './utils/DrawBaseViewModel'
import { assign } from './utils/index'

@Extend(Text)
function fancy(textStyle: InterfaceObj) {
  .fontSize(textStyle.fontSize || 14)
  .fontColor(textStyle.color || '#fff')
  .fontWeight(textStyle.fontWeight || 'normal')
  .fontFamily(textStyle.fontFamily || 'sans-serif')
}

@Component
export struct OmniPieChart {
  private drawViewModel?: DrawBaseViewModel<PieDataType>
  @Prop @Watch('onCountUpdated') options: Options<PieDataType>;
  @State chartOption: OptionInterface<PieDataType> = {}
  @State renderType: string = 'init'
  private click: Function = (event: InterfaceObj, params: InterfaceObj) => {
  }
  private tooltipClick: Function = (event: InterfaceObj, params: InterfaceObj) => {
  }
  @State titleOption: InterfaceObj = {
    show: true,
    text: '', // 主标题文本
    subtext: '', // 副标题文本
    textAlign: 'center', // 整体（包括 text 和 subtext）的水平对齐。
    direction: 'column', // 排版。column垂直，row水平
    itemGap: 5, // 主副标题之间的间距。
    left: '50%', // title 组件离容器左侧的距离。
    top: '50%' // title 组件离容器上侧的距离。
  };
  @State textStyle: TextStyle = {
    color: '#333',
    fontWeight: 'bolder',
    fontFamily: 'sans-serif',
    position: '',
    fontSize: 18
  };
  @State subtextStyle: TextStyle = {
    color: '#aaa',
    fontWeight: 'normal',
    fontFamily: 'sans-serif',
    position: '',
    fontSize: 12
  };
  @BuilderParam customTooltip: (tooltipInfo: InterfaceObj) => void = globalBuilder

  onCountUpdated(): void {
    this.chartOption = this.options.options
    if (this.chartOption.title) {
      this.titleOption = assign(this.titleOption, this.chartOption.title)
      this.textStyle = assign(this.textStyle, this.chartOption.title.textStyle || {})
      this.subtextStyle = assign(this.subtextStyle, this.chartOption.title.subtextStyle || {})
    }
  }

  aboutToAppear() {
    this.onCountUpdated()
    this.drawViewModel = new DrawPieViewModel()
  }

  build() {
    Column() {
      OmniChart({
        options: $chartOption,
        drawViewModel: this.drawViewModel,
        renderType: this.renderType,
        customTooltip: this.customTooltip,
        click: (event: InterfaceObj, params: InterfaceObj) => {
          this.click(event, params)
        },
        tooltipClick: (event: InterfaceObj, params: InterfaceObj) => {
          this.tooltipClick(event, params)
        }
      })
      if (this.titleOption.show) {
        if (this.titleOption.direction === 'row') {
          Row() {
            Text(String(this.titleOption.text)).fancy(this.textStyle)
            Text(String(this.titleOption.subtext)).margin({ left: this.titleOption.itemGap }).fancy(this.subtextStyle)
          }.position({ x: this.titleOption.left, y: this.titleOption.top }).markAnchor({ x: '50%', y: '50%' })
        } else {
          Column() {
            Text(String(this.titleOption.text)).fancy(this.textStyle)
            Text(String(this.titleOption.subtext)).margin({ top: this.titleOption.itemGap }).fancy(this.subtextStyle)
          }.position({ x: this.titleOption.left, y: this.titleOption.top }).markAnchor({ x: '50%', y: '50%' })
        }
      }
    }.width('100%').height('100%')
  }
}


