import { OmniChart } from './OmniChart'
import { Options } from './Options'
import { globalBuilder } from './Tooltip'
import { InterfaceObj, OptionInterface } from '../chart/utils/chartInterface'
import { DrawBaseViewModel } from '../chart/utils/DrawBaseViewModel'
import { DrawVerBarViewModel } from './utils/DrawVerBarViewModel'
import { DrawHorViewModel } from './utils/DrawHorViewModel'

// 柱状图样式
export enum BarChartStyle {
  //纵向
  vertical,

  //横向
  horizontal,
}

@Component
export struct OmniProgressBarChart {
  private drawViewModel?: DrawBaseViewModel<number>
  @Prop @Watch('onCountUpdated') options: Options<number>;
  @State chartOption: OptionInterface<number> = {};
  @State renderType: string = 'init'
  // 柱状图的样式
  @State barChartStyle: BarChartStyle = BarChartStyle.vertical;
  private click: Function = (event: InterfaceObj, params: InterfaceObj) => {
  }
  private tooltipClick: Function = (event: InterfaceObj, params: InterfaceObj) => {
  }
  @BuilderParam customTooltip: (tooltipInfo: InterfaceObj) => void = globalBuilder

  onCountUpdated(options: Options<number>): void {
    this.renderType = 'update'
    this.chartOption = this.options.options
  }

  aboutToAppear() {
    this.chartOption = this.options.options
    if (this.barChartStyle === BarChartStyle.vertical) {
      this.drawViewModel = new DrawVerBarViewModel()
    } else {
      this.drawViewModel = new DrawHorViewModel()
    }
  }

  build() {
    OmniChart({
      options: $chartOption,
      drawViewModel: this.drawViewModel,
      customTooltip: this.customTooltip,
      renderType: this.renderType,
      click: (event: InterfaceObj, params: InterfaceObj) => {
        this.click(event, params)
      },
      tooltipClick: (event: InterfaceObj, params: InterfaceObj) => {
        this.tooltipClick(event, params)
      }
    })
  }
}
