import { OmniChart } from './OmniChart'
import { Options } from './Options'
import { InterfaceObj, OptionInterface } from './utils/chartInterface'
import { globalBuilder } from './Tooltip'
import { DrawBaseViewModel } from './utils/DrawBaseViewModel'
import { DrawRadarViewModel, RadarDataType } from './utils/DrawRadarViewModel'

@Component
export struct OmniRadarChart {
  private drawViewModel?: DrawBaseViewModel<RadarDataType>
  @Prop @Watch('onCountUpdated') options: Options<RadarDataType>;
  @State chartOption: OptionInterface<RadarDataType> = {};
  @State renderType: string = 'init'
  private click: Function = (event: InterfaceObj, params: InterfaceObj) => {
  }
  private tooltipClick: Function = (event: InterfaceObj, params: InterfaceObj) => {
  }
  @BuilderParam customTooltip: (tooltipInfo: InterfaceObj) => void = globalBuilder

  onCountUpdated(): void {
    this.chartOption = this.options.options
  }

  aboutToAppear() {
    this.onCountUpdated()
    this.drawViewModel = new DrawRadarViewModel()
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

