/**
 * 实时统计页面内容组件
 * 功能：显示多种类型的实时统计图表
 * 用途：在Home页面中作为实时统计页面显示
 */

import { BaseComponentHelper } from '../../components/common/BaseComponent'
import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { McBarChart, Options } from '@mcui/mccharts'
import { ProcessingCurveChart } from '../../components/charts/ProcessingCurveChart'
import { CustomPieChart, PieChartsOptions, PieChartsData } from '../../components/charts/CustomPieChart'

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
  private baseComponentHelper = new BaseComponentHelper()

  // 饼图数据状态
  @State private pieData: PieData[] = [
    new PieData(35), // 优质
    new PieData(30), // 良好
    new PieData(25), // 一般
    new PieData(10)  // 较差
  ]
  
  @State private pieLabels: string[] = ['优质', '良好', '一般', '较差']
  @State private pieColors: string[] = ['#00B894', '#00CEC9', '#FDCB6E', '#E17055']
  
  // 品质统计数据
  @State private qualityData: number[] = [120, 200, 150, 80, 50]
  
  
  // 出口产量数据
  @State private outletData: number[] = [120, 200, 150, 80, 70, 90, 110, 95]
  
  // 定时器
  private pieTimerId: number | null = null
  private qualityTimerId: number | null = null
  private outletTimerId: number | null = null

  getCurrentTheme(): ExtendedOmniThemeStyle {
    return this.baseComponentHelper.getCurrentTheme()
  }

  // 初始化所有图表数据
  private initializeAllData() {
    console.log('🚀 初始化所有图表数据...')
    
    // 启动饼图数据更新（每5秒更新一次）
    if (!this.pieTimerId) {
      this.pieTimerId = setInterval(() => {
        console.log('🔄 更新饼图数据...')
        
        // 更新饼图数据（模拟数据变化）
        const newPieData = [...this.pieData]
        for (let i = 0; i < newPieData.length; i++) {
          const variation = (Math.random() - 0.5) * 10 // -5 到 +5 的随机变化
          newPieData[i] = new PieData(Math.max(5, Math.min(50, newPieData[i].getValue() + variation)))
        }
        this.pieData = newPieData
        console.log('📊 饼图数据更新:', this.pieData.map(d => d.getValue()))
      }, 5000) as number
    }
    
    // 启动品质统计数据更新（每3秒更新一次）
    if (!this.qualityTimerId) {
      this.qualityTimerId = setInterval(() => {
        console.log('🔄 更新品质统计数据...')
        
        // 更新品质统计数据
        const newQualityData = [...this.qualityData]
        for (let i = 0; i < newQualityData.length; i++) {
          const variation = (Math.random() - 0.5) * 20 // -10 到 +10 的随机变化
          newQualityData[i] = Math.max(50, Math.min(300, newQualityData[i] + variation))
        }
        this.qualityData = newQualityData
        console.log('📊 品质统计数据更新:', this.qualityData)
      }, 3000) as number
    }
    
    
    // 启动出口产量数据更新（每4秒更新一次）
    if (!this.outletTimerId) {
      this.outletTimerId = setInterval(() => {
        console.log('🔄 更新出口产量数据...')
        
        // 更新出口产量数据
        const newOutletData = [...this.outletData]
        for (let i = 0; i < newOutletData.length; i++) {
          const variation = (Math.random() - 0.5) * 30 // -15 到 +15 的随机变化
          newOutletData[i] = Math.max(50, Math.min(250, newOutletData[i] + variation))
        }
        this.outletData = newOutletData
        console.log('📊 出口产量数据更新:', this.outletData)
      }, 4000) as number
    }
  }

  // 停止所有定时器
  private stopAllTimers() {
    if (this.pieTimerId) {
      clearInterval(this.pieTimerId)
      this.pieTimerId = null
    }
    if (this.qualityTimerId) {
      clearInterval(this.qualityTimerId)
      this.qualityTimerId = null
    }
    if (this.outletTimerId) {
      clearInterval(this.outletTimerId)
      this.outletTimerId = null
    }
  }

  // 组件生命周期
  aboutToAppear() {
    this.initializeAllData()
  }

  aboutToDisappear() {
    this.stopAllTimers()
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

