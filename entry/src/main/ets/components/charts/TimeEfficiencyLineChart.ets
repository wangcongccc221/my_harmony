/**
 * 时间效率折线图
 * 展示最近30分钟的分选效率与实时产量，两条折线
 */

import { McLineChart, Options } from '@mcui/mccharts'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { getRealtimeStatsService, RealtimeStatsService, RealtimeStatsListener } from '../../protocol/RealtimeStatsService'

@Component
export struct TimeEfficiencyLineChart {
  @Prop chartHeight: number | string = 400
  @Prop selectedSubsystem: string = 'ALL'

  @State private options: Options = new Options({})
  private readonly statsService: RealtimeStatsService = getRealtimeStatsService()
  private statsListener: RealtimeStatsListener | null = null

  aboutToAppear() {
    this.statsListener = () => {
      this.updateOptions()
    }
    this.statsService.subscribe(this.statsListener)
    this.updateOptions()
  }

  aboutToUpdate() {
    this.updateOptions()
  }

  aboutToDisappear() {
    if (this.statsListener) {
      this.statsService.unsubscribe(this.statsListener)
      this.statsListener = null
    }
  }

  private updateOptions(): void {
    const theme = getCurrentTheme()
    const seriesData = this.statsService.getCurveSeries(this.selectedSubsystem, 30)
    const labels = seriesData.labels

    this.options = new Options({
      grid: {
        top: 90,
        left: 70,
        right: 40,
        bottom: 60,
        containLabel: true
      },
      legend: {
        show: true,
        top: 24,
        right: 20,
        itemWidth: 22,
        itemHeight: 18,
        itemGap: 18,
        textStyle: {
          color: theme.textColor,
          fontSize: 20
        }
      },
      xAxis: {
        data: labels,
        axisLabel: {
          fontSize: 16,
          color: theme.textColor
        },
        axisLine: {
          lineStyle: {
            color: theme.borderColor
          }
        }
      },
      yAxis: {
        name: '百分比(%)',
        nameLocation: 'middle',
        nameGap: 40,
        min: 0,
        max: 100,
        interval: 20,
        axisLabel: {
          formatter: '{value}%',
          fontSize: 16,
          color: theme.textColor
        },
        nameTextStyle: {
          fontSize: 16,
          color: theme.textColor
        },
        axisLine: {
          lineStyle: {
            color: theme.borderColor
          }
        },
        splitLine: {
          lineStyle: { color: '#E0E0E0' }
        }
      },
      tooltip: {
        show: true,
        backgroundColor: theme.surfaceColor,
        borderColor: theme.borderColor,
        textStyle: {
          color: theme.textColor
        }
      },
      series: [
        {
          name: '分选效率',
          type: 'line',
          smooth: true,
          data: seriesData.efficiency,
          symbol: 'circle',
          symbolSize: 10,
          lineStyle: {
            width: 3,
            color: '#FE8A02'
          },
          itemStyle: {
            color: '#FE8A02'
          }
        },
        {
          name: '实时产量',
          type: 'line',
          smooth: true,
          data: seriesData.output, // 与 48 对齐：实时产量百分比曲线
          symbol: 'circle',
          symbolSize: 10,
          lineStyle: {
            width: 3,
            color: '#97CC31'
          },
          itemStyle: {
            color: '#97CC31'
          }
        }
      ]
    })
  }

  build() {
    Column() {
      // 标题栏
      Text('时间效率图（分选效率 / 实时产量）')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(getCurrentTheme().textColor)
        .margin({ bottom: 8 })

      McLineChart({
        options: this.options
      })
        .width('100%')
        .height(this.chartHeight)
        .backgroundColor(getCurrentTheme().surfaceColor)
    }
    .width('100%')
    .height('100%')
    .padding(12)
    .backgroundColor(getCurrentTheme().surfaceColor)
  }
}

