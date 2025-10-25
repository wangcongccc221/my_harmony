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
  private maxPoints: number = 1024 // 最多保留1024个点，用于内存泄漏测试
  private dataPoints: ChartDataItem[] = []
  private currentProgress: number = 0
  private dataCount: number = 0 // 数据计数器
  private clearCount: number = 0 // 清空次数计数器
  @State private followLatest: boolean = true // 是否自动跟随最新数据

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
          width: 3,
          color: this.getCurrentTheme().chartLineColor ?? this.getCurrentTheme().primary
        },
        itemStyle: {
          color: this.getCurrentTheme().chartLineColor ?? this.getCurrentTheme().primary
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
            color: this.getCurrentTheme().chartLineColor ?? this.getCurrentTheme().primary
          },
          itemStyle: {
            color: this.getCurrentTheme().chartLineColor ?? this.getCurrentTheme().primary
          }
        }
      ],
      tooltip: {
        show: true,
        backgroundColor: this.getCurrentTheme().chartBg ?? this.getCurrentTheme().surfaceColor,
        borderColor: this.getCurrentTheme().borderColor,
        textStyle: {
          color: this.getCurrentTheme().textColor
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

  // ===== 模拟：每秒追加一个时间点与随机进度 =====
  private startMockIfNeeded() {
    // 仅当未提供外部 data 时才模拟
    if (this.data && this.data.length > 0) { return }
    // 初始化内部数据为默认数据
    if (this.dataPoints.length === 0) {
      this.dataPoints = [...this.defaultData]
      this.currentProgress = this.dataPoints[this.dataPoints.length - 1]?.value ?? 0
      this.dataCount = this.dataPoints.length
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
      this.dataCount++
      
      // 控制台输出当前数据条数
      console.log(`📊 第${this.dataCount}条数据 - 时间: ${hh}:${mm}:${ss} - 进度: ${this.currentProgress}%`)
      
      // 当数据达到1024个时，清空所有数据重新开始
      if (this.dataCount >= this.maxPoints) {
        console.log(`🔄 数据达到${this.maxPoints}个，开始清空数据... (第${this.clearCount + 1}次清空)`)
        this.dataPoints = []
        this.dataCount = 0
        this.clearCount++
        this.currentProgress = 0
        
        // 重新初始化数据
        this.dataPoints = [...this.defaultData]
        this.dataCount = this.dataPoints.length
        this.currentProgress = this.dataPoints[this.dataPoints.length - 1]?.value ?? 0
        
        console.log(`✅ 数据已清空，重新开始追踪 (清空次数: ${this.clearCount})`)
      }
      
      // 使用 Options.setVal 增量更新（官方推荐）
      this.chartOptions.setVal({
        xAxis: { data: this.getTimeLabels() },
        series: [ { name: '加工进度', data: this.getChartData() } ]
        // 自动追踪最新数据（暂时移除dataZoom配置）
        // dataZoom: {
        //   type: 'inside',
        //   xAxisIndex: 0,
        //   start: this.followLatest ? 100 : 0,
        //   end: 100
        // }
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
      // 数据统计信息显示
      Row() {
        Text(`数据点: ${this.dataCount}/${this.maxPoints}`)
          .fontSize(14)
          .fontColor(this.getCurrentTheme().textColor)
          .margin({ right: 16 })
        
        Text(`清空次数: ${this.clearCount}`)
          .fontSize(14)
          .fontColor(this.getCurrentTheme().primary)
          .margin({ right: 16 })
        
        Text(`当前进度: ${this.currentProgress}%`)
          .fontSize(14)
          .fontColor(this.getCurrentTheme().chartLineColor ?? this.getCurrentTheme().primary)
          .margin({ right: 16 })
        
        // 自动追踪开关（暂时注释掉，默认开启）
        // Text(`自动追踪: ${this.followLatest ? '开启' : '关闭'}`)
        //   .fontSize(14)
        //   .fontColor(this.followLatest ? this.getCurrentTheme().primary : this.getCurrentTheme().subTextColor)
        //   .onClick(() => {
        //     this.followLatest = !this.followLatest
        //   })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
      .borderRadius(4)
      .margin({ bottom: 8 })

      McLineChart({
        options: this.chartOptions
      })
      .width(this.chartWidth)
      .height(this.chartHeight)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.getCurrentTheme().chartBg ?? this.getCurrentTheme().surfaceColor)
  }
}
