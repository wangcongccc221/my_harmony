/**
 * 时间效率折线图
 * 展示最近30分钟的分选效率与实时产量，两条折线
 */

import { McLineChart, Options } from '@mcui/mccharts'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'

// 数据系列接口
interface SeriesData {
  efficiency: number[]
  output: number[]
}

@Component
export struct TimeEfficiencyLineChart {
  @Prop chartHeight: number | string = 400
  @Prop selectedSubsystem: string = 'ALL'

  @State private options: Options = new Options({})

  aboutToAppear() {
    this.updateOptions()
  }

  aboutToUpdate() {
    this.updateOptions()
  }

  /**
   * 生成最近30分钟的时间刻度（每5分钟一个点）
   */
  private getTimeLabels(): string[] {
    const labels: string[] = []
    const now = new Date()
    // 6个间隔 + 当前，共7个点
    for (let i = 6; i >= 0; i--) {
      const ts = new Date(now.getTime() - i * 5 * 60 * 1000)
      const hh = String(ts.getHours()).padStart(2, '0')
      const mm = String(ts.getMinutes()).padStart(2, '0')
      labels.push(`${hh}:${mm}`)
    }
    return labels
  }

  private getSeries(len: number): SeriesData {
    return {
      efficiency: new Array(len).fill(0),
      output: new Array(len).fill(0)
    }
  }

  private updateOptions(): void {
    const theme = getCurrentTheme()
    const labels = this.getTimeLabels()
    const seriesData = this.getSeries(labels.length)

    this.options = new Options({
      legend: {
        show: true,
        top: 10,
        right: 10,
        textStyle: {
          color: theme.textColor,
          fontSize: 14
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
          symbolSize: 6,
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
          data: seriesData.output,
          symbol: 'circle',
          symbolSize: 6,
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

