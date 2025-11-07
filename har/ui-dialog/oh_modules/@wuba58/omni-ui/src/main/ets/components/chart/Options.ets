import { InterfaceObj, LegendInterface, TooltipInterface, SeriesInterface, AxisInterface, RadarInterface, OptionInterface } from './utils/chartInterface'
import { xAxisOpt, yAxisOpt, tooltip, legend, legendTextStyle, radar } from './utils/defaultOption'
import { deepCopy, assign } from './utils/index'

export class Options<T> {
  options: OptionInterface<T> = {
    color: ['#296DFF', '#ff5495fd', '#ff1acffd', '#ff72e4fd', '#7B72F7', '#F85758', '#FFBF29', '#D1E9F9', '#F5FAFC', '#5A657A'],
    title: {},
    legend: deepCopy(legend),
    tooltip: deepCopy(tooltip),
    radar: deepCopy(radar),
    xAxis: deepCopy(xAxisOpt),
    yAxis: deepCopy(yAxisOpt),
    series: []
  }
  cPaddingT: number = 30;
  cPaddingB: number = 30;
  cPaddingL: number = 30;
  cPaddingR: number = 20;
  color: Array<string> = [];
  title: InterfaceObj = {};
  legend: LegendInterface = {};
  tooltip: TooltipInterface = {};
  radar: RadarInterface = {};
  xAxis: AxisInterface = {};
  yAxis: AxisInterface | AxisInterface[] = {};
  series: Array<SeriesInterface<T>> = [];

  constructor(options: OptionInterface<T>) {
    this.setVal(options)
  }

  setVal (options: OptionInterface<T>) {
    const oldOptions: OptionInterface<T> = deepCopy(this.options)
    const keys = ['cPaddingT', 'cPaddingB', 'cPaddingL', 'cPaddingR', 'color', 'title', 'legend', 'xAxis', 'yAxis', 'tooltip', 'radar', 'dataZoom', 'series']
    for (let i = 0; i < keys.length; i++) {
      const item = keys[i]
      if (options[item] === undefined) continue
      switch (item) {
        case 'tooltip':
          oldOptions.tooltip = options[item]
          break
        case 'title':
          oldOptions.title = assign(oldOptions.title, options[item])
          break
        case 'color':
          oldOptions.color = options[item]
          break
        case 'legend':
          oldOptions.legend = assign(oldOptions.legend, options[item])
          break
        case 'xAxis':
          oldOptions.xAxis = assign(oldOptions.xAxis, options[item])
          break
        case 'yAxis':
          oldOptions.yAxis = assign(oldOptions.yAxis, options[item])
          break
        case 'radar':
          oldOptions.radar = assign(oldOptions.radar, options[item])
          break
        case 'series':
          const seriesData: SeriesInterface<T>[] | undefined = options[item]
          if (oldOptions.series && seriesData) {
            if (oldOptions.series.length === seriesData.length) {
              oldOptions.series = oldOptions.series.map((item: SeriesInterface<T>, index): SeriesInterface<T> => {
                item = assign(item, seriesData[index])
                return item
              })
            } else {
              oldOptions.series = options[item]
            }
          } else {
            oldOptions.series = options[item]
          }
          break
      }
    }
    this.options = oldOptions
  }
}