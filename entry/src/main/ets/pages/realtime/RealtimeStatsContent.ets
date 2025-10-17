/**
 * 实时统计页面内容组件
 * 功能：显示多种类型的实时统计图表
 * 用途：在Home页面中作为实时统计页面显示
 */

import { BaseComponentHelper } from '../../components/common/BaseComponent'
import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { McLineChart, McBarChart, McPieChart, Options } from '@mcui/mccharts'

@Component
export struct RealtimeStatsContent {
  @StorageLink('OMNI_THEME_VERSION_KEY') private themeVersion: number = 0
  private baseComponentHelper = new BaseComponentHelper()

  getCurrentTheme(): ExtendedOmniThemeStyle {
    return this.baseComponentHelper.getCurrentTheme()
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
          // 折线图卡片
          Column() {
            Text('加工进度趋势')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.getCurrentTheme().textColor)
              .margin({ bottom: 12 })
            
            McLineChart({
              options: new Options({
                title: {
                  show: true,
                  text: '实时加工进度',
                  left: 'center',
                  top: 10,
                  textStyle: {
                    fontSize: 16,
                    color: this.getCurrentTheme().textColor
                  }
                },
                xAxis: {
                  type: 'category',
                  data: ['08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00']
                },
                yAxis: {
                  type: 'value',
                  name: '进度(%)'
                },
                series: [{
                  name: '加工进度',
                  type: 'line',
                  data: [20, 35, 50, 65, 80, 90, 95],
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
                  data: [120, 200, 150, 80, 50],
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
          // 外观品质统计饼图
          Column() {
            Text('外观品质统计')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.getCurrentTheme().textColor)
              .margin({ bottom: 12 })
            
            McPieChart({
              options: new Options({
                title: {
                  show: true,
                  text: '外观品质分布',
                  left: 'center',
                  top: 10,
                  textStyle: {
                    fontSize: 16,
                    color: this.getCurrentTheme().textColor
                  }
                },
                series: [{
                  name: '外观品质',
                  type: 'pie',
                  radius: ['40%', '70%'],
                  center: ['50%', '50%'],
                  data: [
                    { name: '优质', value: 35, itemStyle: { color: '#00B894' } },
                    { name: '良好', value: 30, itemStyle: { color: '#00CEC9' } },
                    { name: '一般', value: 25, itemStyle: { color: '#FDCB6E' } },
                    { name: '较差', value: 10, itemStyle: { color: '#E17055' } }
                  ]
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

          // 温度监控折线图
          Column() {
            Text('温度监控')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.getCurrentTheme().textColor)
              .margin({ bottom: 12 })
            
            McLineChart({
              options: new Options({
                title: {
                  show: true,
                  text: '温度变化',
                  left: 'center',
                  top: 10,
                  textStyle: {
                    fontSize: 16,
                    color: this.getCurrentTheme().textColor
                  }
                },
                xAxis: {
                  type: 'category',
                  data: ['00:00', '04:00', '08:00', '12:00', '16:00', '20:00', '24:00']
                },
                yAxis: {
                  type: 'value',
                  name: '温度(°C)'
                },
                series: [{
                  name: '温度',
                  type: 'line',
                  data: [22, 25, 28, 26, 24, 23, 21],
                  itemStyle: {
                    color: '#FF6B6B'
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
                data: [120, 200, 150, 80, 70, 90, 110, 95],
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

