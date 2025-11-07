import { OmniChart } from './OmniChart'
import { Options } from './Options'
import { globalBuilder } from './Tooltip'
import { InterfaceObj, OptionInterface } from './utils/chartInterface'
import { DrawBaseViewModel } from './utils/DrawBaseViewModel'
import { DrawLineViewModel, LineDataType } from './utils/DrawLineViewModel'

@Component
export struct OmniLineChart {
  private drawViewModel?: DrawBaseViewModel<LineDataType>
  @Prop @Watch('onCountUpdated') options: Options<LineDataType>;
  @State chartOption: OptionInterface<LineDataType> = {};
  @State renderType: string = 'init'
  private click: Function = (event: InterfaceObj, params: InterfaceObj) => {
  }
  private tooltipClick: Function = (event: InterfaceObj, params: InterfaceObj) => {
  }
  @BuilderParam customTooltip: (tooltipInfo: InterfaceObj) => void = globalBuilder

  onCountUpdated(): void {
    this.renderType = 'update'
    this.chartOption = this.options.options
  }

  aboutToAppear() {
    this.chartOption = this.options.options
    this.drawViewModel = new DrawLineViewModel()
  }

  build() {
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
  }
}

