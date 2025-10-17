import { McLineChart } from '@mcui/mccharts'
import { Options } from '@mcui/mccharts'
import { BaseComponentHelper } from '../common/BaseComponent'
import { OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'

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
  private baseComponentHelper = new BaseComponentHelper()
  @Consume providedTheme: ExtendedOmniThemeStyle

  // 模拟数据与定时器
  private timerId?: number
  private maxPoints: number = 60 // 最多保留60个点
  private dataPoints: ChartDataItem[] = []
  private currentProgress: number = 0

  // 默认数据（初始一组）
  private defaultData: ChartDataItem[] = [
    { time: '08:00', value: 0 },
    { time: '08:30', value: 20 },
    { time: '09:00', value: 40 },
    { time: '09:30', value: 60 },
    { time: '10:00', value: 80 },
    { time: '10:30', value: 90 },
    { time: '11:00', value: 100 }
  ]

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
          width: 3
        },
        itemStyle: {
          color: '#1890ff'
        }
      }
    ],
    tooltip: {
      show: true
    }
  })

  getCurrentTheme(): ExtendedOmniThemeStyle {
    return this.baseComponentHelper.getCurrentTheme(this.providedTheme)
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
    if (this.dataPoints.length > 0) { return this.dataPoints }
    return this.defaultData
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
          color: this.getCurrentTheme().textColor
        }
      },
      xAxis: {
        data: this.getTimeLabels(),
        axisLabel: {
          fontSize: 20,
          color: this.getCurrentTheme().textColor
        },
        axisLine: {
          lineStyle: {
            color: this.getCurrentTheme().borderColor
          }
        }
      },
      yAxis: {
        name: '加工量(%)',
        nameLocation: 'middle',
        nameGap: 30,
        axisLabel: {
          fontSize: 20,
          color: this.getCurrentTheme().textColor
        },
        axisLine: {
          lineStyle: {
            color: this.getCurrentTheme().borderColor
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
            color: this.getCurrentTheme().primary
          },
          itemStyle: {
            color: this.getCurrentTheme().primary
          }
        }
      ],
      tooltip: {
        show: true,
        backgroundColor: this.getCurrentTheme().surfaceColor,
        borderColor: this.getCurrentTheme().borderColor,
        textStyle: {
          color: this.getCurrentTheme().textColor
        }
      }
    })
  }

  // ===== 模拟：每秒追加一个时间点与随机进度 =====
  private startMockIfNeeded() {
    // 仅当未提供外部 data 时才模拟
    if (this.data && this.data.length > 0) { return }
    // 初始化内部数据为默认数据
    if (this.dataPoints.length === 0) {
      this.dataPoints = [...this.defaultData]
      this.currentProgress = this.dataPoints[this.dataPoints.length - 1]?.value ?? 0
    }
    if (this.timerId) { return }
    this.timerId = setInterval(() => {
      const now = new Date()
      const hh = String(now.getHours()).padStart(2, '0')
      const mm = String(now.getMinutes()).padStart(2, '0')
      const ss = String(now.getSeconds()).padStart(2, '0')
      // 随机游走并限制在 0~100
      const step = (Math.random() * 10) - 5 // -5 ~ +5
      this.currentProgress = Math.max(0, Math.min(100, Math.round(this.currentProgress + step)))
      this.dataPoints.push({ time: `${hh}:${mm}:${ss}`, value: this.currentProgress })
      if (this.dataPoints.length > this.maxPoints) {
        this.dataPoints.shift()
      }
      // 使用 Options.setVal 增量更新（官方推荐）
      this.chartOptions.setVal({
        xAxis: { data: this.getTimeLabels() },
        series: [ { name: '加工进度', data: this.getChartData() } ]
      })
    }, 1000) as number
  }

  private stopMock() {
    if (this.timerId) {
      clearInterval(this.timerId)
      this.timerId = undefined
    }
  }

  aboutToAppear() {
    // 初始化配置并尝试启动模拟
    this.dataPoints = (this.data && this.data.length > 0) ? [] : [...this.defaultData]
    this.updateChartOptions()
    this.startMockIfNeeded()
  }

  aboutToUpdate() {
    this.updateChartOptions()
  }

  aboutToDisappear() {
    this.stopMock()
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
  }
}
