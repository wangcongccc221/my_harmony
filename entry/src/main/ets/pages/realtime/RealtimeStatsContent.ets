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
import { RealtimeDataManager } from '../../utils/managers/RealtimeDataManager'
import { HOME_SELECTED_FSM } from '../../constants/TopBarKeys'

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
  @StorageLink(HOME_SELECTED_FSM) private selectedFSM: 'FSM1' | 'FSM2' = 'FSM1'
  @StorageLink('TCP_STATISTICS_GLOBAL_UPDATE') @Watch('onTcpDataUpdate') private tcpDataUpdate: number = 0

  // 实时数据管理器
  private realtimeDataManager: RealtimeDataManager = RealtimeDataManager.getInstance()

  // 饼图数据状态（从TCP数据计算）
  @State private pieData: PieData[] = [
    new PieData(0), // 优质
    new PieData(0), // 良好
    new PieData(0), // 一般
    new PieData(0)  // 较差
  ]
  
  @State private pieLabels: string[] = ['优质', '良好', '一般', '较差']
  @State private pieColors: string[] = ['#00B894', '#00CEC9', '#FDCB6E', '#E17055']
  
  // 品质统计数据（从TCP数据获取）
  @State private qualityData: number[] = [0, 0, 0, 0, 0]
  
  // 出口产量数据（从TCP数据获取）
  @State private outletData: number[] = []

  getCurrentTheme(): ExtendedOmniThemeStyle {
    return resolveTheme()
  }

  /**
   * 监听TCP数据更新
   */
  onTcpDataUpdate(): void {
    this.updateFromTcpData()
  }

  /**
   * 从TCP数据更新所有图表数据
   */
  private updateFromTcpData(): void {
    try {
      const subsysId: number = this.selectedFSM === 'FSM1' ? 0 : 1
      const statistics = this.realtimeDataManager.getStatistics(subsysId)
      
      // 更新饼图数据（根据各品质等级的个数计算占比）
      // 假设前4个品质等级对应：优质、良好、一般、较差
      const totalCount: number = statistics.nTotalCount
      if (totalCount > 0) {
        const MAX_SIZE_GRADE_NUM = 16
        const pieValues: number[] = []
        for (let quality = 0; quality < 4; quality++) {
          let gradeCount = 0
          // 累加该品质等级下所有尺寸等级的个数
          for (let size = 0; size < MAX_SIZE_GRADE_NUM; size++) {
            const index = quality * MAX_SIZE_GRADE_NUM + size
            if (index < statistics.nGradeCount.length) {
              gradeCount += statistics.nGradeCount[index]
            }
          }
          // 计算占比（百分比）
          const percentage = (gradeCount / totalCount) * 100
          pieValues.push(percentage)
        }
        this.pieData = pieValues.map(value => new PieData(value))
    }
    
      // 更新品质统计数据（取前5个品质等级的总个数）
      const qualityValues: number[] = []
      for (let quality = 0; quality < 5; quality++) {
        let gradeCount = 0
        for (let size = 0; size < MAX_SIZE_GRADE_NUM; size++) {
          const index = quality * MAX_SIZE_GRADE_NUM + size
          if (index < statistics.nGradeCount.length) {
            gradeCount += statistics.nGradeCount[index]
          }
        }
        qualityValues.push(gradeCount)
        }
      this.qualityData = qualityValues
      
      // 更新出口产量数据（取前8个出口的个数）
      const outletValues: number[] = []
      for (let i = 0; i < 8 && i < statistics.nExitCount.length; i++) {
        outletValues.push(statistics.nExitCount[i])
        }
      this.outletData = outletValues
      
      console.log(`[RealtimeStatsContent] 数据已更新 - 总个数: ${totalCount}`)
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error(`[RealtimeStatsContent] 更新数据失败: ${errorMsg}`)
    }
  }

  // 组件生命周期
  aboutToAppear() {
    // 初始化时更新一次数据
    this.updateFromTcpData()
  }

  aboutToDisappear() {
    // 不需要清理定时器，因为不再使用定时器
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

