import { McLineChart } from '@mcui/mccharts'
import { Options } from '@mcui/mccharts'
import { ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'

// 数据接口定义
interface ChartDataItem {
  time: string
  value: number
}

/**
 * 加工曲线图表组件
 * 显示加工进度的折线图
 */
// TODO(性能优化-计划):
// 1) 限制图表点数: 保持最大点数 maxPoints(如<=200), 超出丢弃头部数据
// 2) 刷新节流: 实时数据更新时合并到 100~200ms 触发一次 setState
// 3) 动画控制: 高频更新场景关闭 animation, 降低重绘开销
@Component
export struct ProcessingCurveChart {
  @Prop title: string = '加工曲线'
  @Prop chartHeight: number | string = 200
  @Prop chartWidth: string | number = '100%'
  @Prop data: ChartDataItem[] = []

  // 基础组件助手
  @Consume providedTheme: ExtendedOmniThemeStyle
  private readonly emptyData: ChartDataItem[] = [{ time: '--', value: 0 }]

  // 图表配置
  @State chartOptions: Options = new Options({
    title: {
      show: true,
      text: this.title,
      left: 'center',
      top: 10,
      textStyle: {
        fontSize: 24,
        fontWeight: 'bold'
      }
    },
    xAxis: {
      data: this.getTimeLabels(),
      axisLabel: {
        fontSize: 20
      }
    },
    yAxis: {
      name: '加工量(%)',
      nameLocation: 'middle',
      nameGap: 30,
      min: 0,
      max: 120,
      interval: 24,
      axisLabel: {
        fontSize: 20
      }
    },
    series: [
      {
        name: '加工进度',
        data: this.getChartData(),
        type: 'line',
        smooth: true,
        symbol: 'circle',
        symbolSize: 6,
        lineStyle: {
          width: 3,
          color: this.resolveTheme().chartLineColor ?? this.resolveTheme().primary
        },
        itemStyle: {
          color: this.resolveTheme().chartLineColor ?? this.resolveTheme().primary
        }
      }
    ],
    tooltip: {
      show: true
    }
  })

  private resolveTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.providedTheme)
  }

  // 获取时间标签
  private getTimeLabels(): string[] {
    const data = this.getActiveData()
    return data.map(item => item.time)
  }

  // 获取图表数据
  private getChartData(): number[] {
    const data = this.getActiveData()
    return data.map(item => item.value)
  }

  // 选择使用外部数据还是内部模拟数据
  private getActiveData(): ChartDataItem[] {
    if (this.data && this.data.length > 0) { return this.data }
    return this.emptyData
  }

  // 更新图表配置
  private updateChartOptions() {
    this.chartOptions = new Options({
      title: {
        show: true,
        text: this.title,
        left: 'center',
        top: 10,
        textStyle: {
          fontSize: 24,
          fontWeight: 'bold',
          color: this.resolveTheme().textColor
        }
      },
      xAxis: {
        data: this.getTimeLabels(),
        axisLabel: {
          fontSize: 20,
          color: this.resolveTheme().textColor
        },
        axisLine: {
          lineStyle: {
            color: this.resolveTheme().borderColor
          }
        }
      },
      yAxis: {
        name: '加工量(%)',
        nameLocation: 'middle',
        nameGap: 30,
        min: 0,
        max: 120,
        interval: 24,
        axisLabel: {
          fontSize: 20,
          color: this.resolveTheme().textColor
        },
        axisLine: {
          lineStyle: {
            color: this.resolveTheme().borderColor
          }
        }
      },
      series: [
        {
          name: '加工进度',
          data: this.getChartData(),
          type: 'line',
          smooth: true,
          symbol: 'circle',
          symbolSize: 6,
          lineStyle: {
            width: 3,
            color: this.resolveTheme().chartLineColor ?? this.resolveTheme().primary
          },
          itemStyle: {
            color: this.resolveTheme().chartLineColor ?? this.resolveTheme().primary
          }
        }
      ],
      tooltip: {
        show: true,
        backgroundColor: this.resolveTheme().chartBg ?? this.resolveTheme().surfaceColor,
        borderColor: this.resolveTheme().borderColor,
        textStyle: {
          color: this.resolveTheme().textColor
        }
      },
      // 自动追踪最新数据配置（暂时移除，使用其他方式实现）
      // dataZoom: {
      //   type: 'inside',
      //   xAxisIndex: 0,
      //   start: this.followLatest ? 100 : 0,
      //   end: 100
      // }
    })
  }

  aboutToAppear() {
    this.updateChartOptions()
  }

  aboutToUpdate() {
    this.updateChartOptions()
  }

  build() {
    Column() {
      McLineChart({
        options: this.chartOptions
      })
      .width(this.chartWidth)
      .height(this.chartHeight)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.resolveTheme().chartBg ?? this.resolveTheme().surfaceColor)
  }
}
