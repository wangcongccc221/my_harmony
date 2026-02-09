/**
 * 实时统计页面内容组件
 * 功能：显示多种类型的实时统计图表
 * 用途：在Home页面中作为实时统计页面显示
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme as resolveTheme } from '../../utils/theme/ThemeUtils'
import { McBarChart, Options } from '@mcui/mccharts'
import { ProcessingCurveChart } from '../../components/charts/ProcessingCurveChart'
import { CustomPieChart, PieChartsOptions, PieChartsData } from '../../components/charts/CustomPieChart'
import { ConstPreDefine } from '../../protocol/ConstPreDefine'
import { GlobalDataInterface, getGlobalDataInterface, DataChangeListener } from '../../protocol/GlobalDataInterface'
import { GlobalRealtimeData } from '../../protocol/Structures'

// 饼图数据类
class PieData implements PieChartsData {
  constructor(public value: number) {}
  getValue(): number {
    return this.value
  }
}

@Component
export struct RealtimeStatsContent {
  @StorageLink('OMNI_THEME_VERSION_KEY') private themeVersion: number = 0

  private dataInterface: GlobalDataInterface = getGlobalDataInterface()
  private dataChangeListener: DataChangeListener | null = null

  // 饼图数据状态
  @State private pieData: PieData[] = [
    new PieData(0),
    new PieData(0),
    new PieData(0),
    new PieData(0)
  ]
  
  @State private pieLabels: string[] = ['优质', '良好', '一般', '较差']
  @State private pieColors: string[] = ['#00B894', '#00CEC9', '#FDCB6E', '#E17055']
  
  // 品质统计数据
  @State private qualityData: number[] = [0, 0, 0, 0, 0]
  
  
  // 出口产量数据
  @State private outletData: number[] = [0, 0, 0, 0, 0, 0, 0, 0]

  getCurrentTheme(): ExtendedOmniThemeStyle {
    return resolveTheme()
  }

  private updateFromRealtimeData(data: GlobalRealtimeData): void {
    const qualityBuckets: number[] = [0, 0, 0, 0, 0]
    const qCount = Math.min(5, ConstPreDefine.MAX_QUALITY_GRADE_NUM)
    const sCount = ConstPreDefine.MAX_SIZE_GRADE_NUM
    for (let q = 0; q < qCount; q++) {
      let sum = 0
      for (let s = 0; s < sCount; s++) {
        const idx = q * sCount + s
        if (idx >= 0 && idx < data.gradeCount.length) {
          sum += data.gradeCount[idx] || 0
        }
      }
      qualityBuckets[q] = sum
    }
    this.qualityData = qualityBuckets

    const outlet: number[] = new Array(8).fill(0)
    for (let i = 0; i < outlet.length; i++) {
      const wG = (i < data.exitWeight.length) ? (data.exitWeight[i] || 0) : 0
      outlet[i] = Number((wG / 1000).toFixed(2))
    }
    this.outletData = outlet

    const total = data.totalQualified + data.totalUnqualified
    const goodPct = total > 0 ? Number(((data.totalQualified / total) * 100).toFixed(1)) : 0
    const badPct = total > 0 ? Number((100 - goodPct).toFixed(1)) : 0
    this.pieData = [
      new PieData(goodPct),
      new PieData(0),
      new PieData(0),
      new PieData(badPct)
    ]
  }

  // 组件生命周期
  aboutToAppear() {
    const initial = this.dataInterface.getGlobalData()
    this.updateFromRealtimeData(initial)
    this.dataChangeListener = (data: GlobalRealtimeData) => {
      this.updateFromRealtimeData(data)
    }
    this.dataInterface.addDataChangeListener(this.dataChangeListener)
  }

  aboutToDisappear() {
    if (this.dataChangeListener) {
      this.dataInterface.removeDataChangeListener(this.dataChangeListener)
      this.dataChangeListener = null
    }
  }

  build() {
    Scroll() {
      Column() {
        // 页面标题
        Text('实时统计')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getCurrentTheme().textColor)
          .margin({ top: 20, bottom: 20 })
          .alignSelf(ItemAlign.Center)

        // 第一行：折线图 + 柱状图
        Row() {
          // 使用封装好的加工曲线图组件
          ProcessingCurveChart({
            title: '加工进度趋势',
            chartHeight: 200,
            chartWidth: '100%'
          })
          .width('48%')
          .height(280)
          .padding(16)
          .backgroundColor(this.getCurrentTheme().surfaceColor)
          .borderRadius(12)
          .border({ width: 1, color: this.getCurrentTheme().borderColor })
          .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)', offsetY: 2 })

          // 品质统计柱状图卡片
          Column() {
            Text('品质统计')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.getCurrentTheme().textColor)
              .margin({ bottom: 12 })
            
            McBarChart({
              options: new Options({
                title: {
                  show: true,
                  text: '品质等级统计',
                  left: 'center',
                  top: 10,
                  textStyle: {
                    fontSize: 16,
                    color: this.getCurrentTheme().textColor
                  }
                },
                xAxis: {
                  type: 'category',
                  data: ['A级', 'B级', 'C级', 'D级', 'E级']
                },
                yAxis: {
                  type: 'value',
                  name: '数量(个)'
                },
                series: [{
                  name: '品质统计',
                  type: 'bar',
                  data: this.qualityData,
                  itemStyle: {
                    color: this.getCurrentTheme().primary
                  }
                }]
              })
            })
            .width('100%')
            .height(200)
          }
          .width('48%')
          .height(280)
          .padding(16)
          .backgroundColor(this.getCurrentTheme().surfaceColor)
          .borderRadius(12)
          .border({ width: 1, color: this.getCurrentTheme().borderColor })
          .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)', offsetY: 2 })
          .margin({ left: 16 })
        }
        .width('100%')
        .margin({ bottom: 20 })

        // 第二行：外观品质饼图 + 折线图
        Row() {
          // 自定义饼图组件
          Column() {
            Text('外观品质统计')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.getCurrentTheme().textColor)
              .margin({ bottom: 12 })
            
            CustomPieChart({
              options: new PieChartsOptions({
                radius: 60,
                innerRadius: 0,
                data: this.pieData,
                animate: true,
                duration: 1000,
                labelFn: (data: PieChartsData, index: number) => {
                  return `${this.pieLabels[index]} ${data.getValue()}%`
                },
                labelStyleFn: (data: PieChartsData, index: number) => {
                  return {
                    fontSize: 12,
                    fontColor: this.pieColors[index]
                  }
                },
                colorFn: (data: PieChartsData, index: number) => {
                  return this.pieColors[index]
                },
                leaderLineColorFn: (data: PieChartsData, index: number) => {
                  return this.pieColors[index]
                }
              })
            })
            .width('100%')
            .height(200)
          }
          .width('48%')
          .height(280)
          .padding(16)
          .backgroundColor(this.getCurrentTheme().surfaceColor)
          .borderRadius(12)
          .border({ width: 1, color: this.getCurrentTheme().borderColor })
          .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)', offsetY: 2 })

          // 温度监控折线图
          ProcessingCurveChart({
            title: '温度监控',
            chartHeight: 200,
            chartWidth: '100%'
          })
          .width('48%')
          .height(280)
          .padding(16)
          .backgroundColor(this.getCurrentTheme().surfaceColor)
          .borderRadius(12)
          .border({ width: 1, color: this.getCurrentTheme().borderColor })
          .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)', offsetY: 2 })
          .margin({ left: 16 })
        }
        .width('100%')
        .margin({ bottom: 20 })

        // 第三行：柱状图（全宽）
        Column() {
          Text('出口产量对比')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getCurrentTheme().textColor)
            .margin({ bottom: 12 })
          
          McBarChart({
            options: new Options({
              title: {
                show: true,
                text: '各出口产量统计',
                left: 'center',
                top: 10,
                textStyle: {
                  fontSize: 16,
                  color: this.getCurrentTheme().textColor
                }
              },
              xAxis: {
                type: 'category',
                data: ['出口1', '出口2', '出口3', '出口4', '出口5', '出口6', '出口7', '出口8']
              },
              yAxis: {
                type: 'value',
                name: '产量(kg)'
              },
              series: [{
                name: '产量',
                type: 'bar',
                data: this.outletData,
                itemStyle: {
                  color: this.getCurrentTheme().primary
                }
              }]
            })
          })
          .width('100%')
          .height(250)
        }
        .width('100%')
        .height(320)
        .padding(16)
        .backgroundColor(this.getCurrentTheme().surfaceColor)
        .borderRadius(12)
        .border({ width: 1, color: this.getCurrentTheme().borderColor })
        .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)', offsetY: 2 })
        .margin({ bottom: 20 })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Auto)
    .scrollBarColor(this.getCurrentTheme().borderColor)
    .scrollBarWidth(6)
  }
}

