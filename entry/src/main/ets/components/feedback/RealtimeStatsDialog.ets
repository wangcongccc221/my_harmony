/**
 * 实时统计对话框组件
 * 功能：以弹窗形式展示实时统计摘要，交互样式与“水果信息”一致（标题/遮罩/按钮布局）
 */

import { ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { DialogButtons } from '../ui/dialogs/DialogButtons'
import { RectButton } from '../ui/buttons/RectButton'
import { ProcessingCurveChart } from '../charts/ProcessingCurveChart'
import { ChartComponent, ChartComponentParams, ChartData } from '../ChartComponent'
import { McPieChart, Options } from '@mcui/mccharts'

interface RealtimeStats {
  productionTonH: string
  sumWeightTon: string
  sumCounts: string
  avgG: string
}

// 图表数据项接口
interface ChartDataItem {
  time: string
  value: number
}

@Component
export struct RealtimeStatsDialog {
  @Prop isVisible: boolean = false
  // 为子图表提供主题，避免 @Consume 解析失败
  @Provide providedTheme: ExtendedOmniThemeStyle = getCurrentTheme()

  // 简要统计占位（可由外部传入或后续联动替换）
  @State stats: RealtimeStats = {
    productionTonH: '--',
    sumWeightTon: '--',
    sumCounts: '--',
    avgG: '--'
  }

  onConfirm?: (stats: RealtimeStats) => void
  onCancel?: () => void

  // 实时统计弹窗：按钮切换所对应的键集合与当前选中项
  private readonly tabLabels: string[] = [
    '出口统计信息',
    '品质统计信息',
    '外观品质统计信息',
    '内部品质统计信息',
    '重量/尺寸统计信息',
    '重量/尺寸统计表',
    '等级统计表',
    '时间效率图'
  ]

  // 为不同按钮提供不同的模拟数据
  private getChartDataForTab(tabName: string): ChartDataItem[] {
    const baseData: ChartDataItem[] = [
      { time: '08:00', value: 0 },
      { time: '08:30', value: 20 },
      { time: '09:00', value: 40 },
      { time: '09:30', value: 60 },
      { time: '10:00', value: 80 },
      { time: '10:30', value: 90 },
      { time: '11:00', value: 100 }
    ]

    switch (tabName) {
      case '出口统计信息':
        return baseData.map(item => {
          const newItem: ChartDataItem = { time: item.time, value: item.value * 1.2 }
          return newItem
        })
      case '品质统计信息':
        return baseData.map(item => {
          const newItem: ChartDataItem = { time: item.time, value: item.value * 0.8 }
          return newItem
        })
      case '外观品质统计信息':
        return baseData.map(item => {
          const newItem: ChartDataItem = { time: item.time, value: item.value * 0.9 }
          return newItem
        })
      case '内部品质统计信息':
        return baseData.map(item => {
          const newItem: ChartDataItem = { time: item.time, value: item.value * 0.85 }
          return newItem
        })
      case '重量/尺寸统计信息':
        return baseData.map(item => {
          const newItem: ChartDataItem = { time: item.time, value: item.value * 1.1 }
          return newItem
        })
      case '重量/尺寸统计表':
        return baseData.map(item => {
          const newItem: ChartDataItem = { time: item.time, value: item.value * 0.95 }
          return newItem
        })
      case '等级统计表':
        return baseData.map(item => {
          const newItem: ChartDataItem = { time: item.time, value: item.value * 1.05 }
          return newItem
        })
      case '时间效率图':
        return baseData.map(item => {
          const newItem: ChartDataItem = { time: item.time, value: item.value * 0.75 }
          return newItem
        })
      default:
        return baseData
    }
  }
  @State private selectedTabIndex: number = 0
  @State private contentRefreshKey: number = 0
  @State private currentInnerPage: string = '出口统计信息'

  private handleConfirm() {
    if (this.onConfirm) {
      this.onConfirm(this.stats)
    }
  }

  private handleCancel() {
    if (this.onCancel) {
      this.onCancel()
    }
  }

  build(): void {
    if (this.isVisible) {
      Stack() {
        // 内容卡片
        Column() {
          // 标题栏
          Row() {
            Text('实时统计')
              .fontSize(24)  // 标题字体调大到24px
              .fontWeight(FontWeight.Bold)
              .fontColor(getCurrentTheme().textColor)
              .layoutWeight(1)

            Button() {
              Text('×')
                .fontSize(24)  // 关闭按钮字体调大到24px
                .fontColor(getCurrentTheme().textColor)
            }
            .width(30)
            .height(30)
            .backgroundColor(Color.Transparent)
            .onClick(() => this.handleCancel())
          }
          .width('100%')
          .padding({ left: 12, right: 12, top: 10, bottom: 10 })
          .border({ width: { bottom: 1 }, color: getCurrentTheme().borderColor })

          // 清空内容，仅保留标题（去掉与标题的间距，贴紧顶部）
          Blank().height(0)

          // 一行8个按钮的卡片容器（顶部贴紧）
          Column() {
            // 按钮行
            Row() {
              ForEach(this.tabLabels, (label: string, idx: number) => {
                // 参考主页风格，使用 RectButton
                Column() {
                  RectButton({
                    text: label,
                    widthPx: 120,  // 按钮宽度调大到120px
                    heightPx: 44,  // 按钮高度调大到44px
                    marginLeftPx: 2,
                    marginRightPx: 2,
                    fontSizePx: 16,  // 按钮字体调大到16px
                    isActive: this.selectedTabIndex === idx,
                    borderRadiusPx: 8,  // 圆角调大到8px
                    enableClickFeedback: true,
                    onTap: () => {
                      this.selectedTabIndex = idx
                      this.currentInnerPage = label
                      this.contentRefreshKey++
                    }
                  })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Center)
              }, (_label: string, idx: number) => `${idx}`)
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .padding(12)
          .backgroundColor(Color.Transparent)
          .border({ width: 0, color: Color.Transparent })
          .borderRadius(0)
          .margin({ top: 0, bottom: 8, left: 12, right: 12 })

          // 下方大卡片：占据剩余空间，依据所选按钮切换内容（仿主页 if/else 渲染）
          Column() {
            if (this.currentInnerPage === '出口统计信息') {
              ProcessingCurveChart({ 
                title: '出口统计信息', 
                chartHeight: '80%',  // 图表高度调整为80%
                chartWidth: '100%'
                // 不传入data，让组件自动模拟数据
              })
                .width('100%').height('100%')
            } else if (this.currentInnerPage === '品质统计信息') {
              ChartComponent({
                params: {
                  dataCount: 80,
                  startHour: 8,
                  startMinute: 0,
                  chartHeight: 300,
                  barWidth: 15,
                  barSpacing: 60, // 品质统计信息使用较宽松的间距
                  showScrollBar: true,
                  onDataClick: (data: ChartData, event: ClickEvent) => {
                    console.log(`点击了品质数据: ${data.time} - ${data.value}`);
                  }
                }
              })
            } else if (this.currentInnerPage === '外观品质统计信息') {
              McPieChart({
                options: new Options({
                  title: {
                    show: true,
                    text: '外观品质统计信息',
                    left: 'center',
                    top: 10,
                    textStyle: {
                      fontSize: 16,
                      color: getCurrentTheme().textColor
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
                .width('100%').height('100%')
            } else if (this.currentInnerPage === '内部品质统计信息') {
              ProcessingCurveChart({ 
                title: '内部品质统计信息', 
                chartHeight: '80%',  // 图表高度调整为80% 
                chartWidth: '100%',
                data: this.getChartDataForTab('内部品质统计信息')
              })
                .width('100%').height('100%')
            } else if (this.currentInnerPage === '重量/尺寸统计信息') {
              ProcessingCurveChart({ 
                title: '重量/尺寸统计信息', 
                chartHeight: '80%',  // 图表高度调整为80% 
                chartWidth: '100%',
                data: this.getChartDataForTab('重量/尺寸统计信息')
              })
                .width('100%').height('100%')
            } else if (this.currentInnerPage === '重量/尺寸统计表') {
              ProcessingCurveChart({ 
                title: '重量/尺寸统计表', 
                chartHeight: '80%',  // 图表高度调整为80% 
                chartWidth: '100%',
                data: this.getChartDataForTab('重量/尺寸统计表')
              })
                .width('100%').height('100%')
            } else if (this.currentInnerPage === '等级统计表') {
              ProcessingCurveChart({ 
                title: '等级统计表', 
                chartHeight: '80%',  // 图表高度调整为80% 
                chartWidth: '100%',
                data: this.getChartDataForTab('等级统计表')
              })
                .width('100%').height('100%')
            } else if (this.currentInnerPage === '时间效率图') {
              ProcessingCurveChart({ 
                title: '时间效率图', 
                chartHeight: '80%',  // 图表高度调整为80% 
                chartWidth: '100%',
                data: this.getChartDataForTab('时间效率图')
              })
                .width('100%').height('100%')
            }
          }
          .width('100%')
          .layoutWeight(1)
          .padding(12)
          .backgroundColor(getCurrentTheme().surfaceColor)
          .border({ width: 1, color: getCurrentTheme().borderColor })
          .borderRadius(10)
          .margin({ top: 0, bottom: 12, left: 8, right: 8 })
          .id(`rt-page-${this.currentInnerPage}-${this.contentRefreshKey}`)
        }
        .width('80%')  // 调整宽度为80%
        .padding({ left: 10, right: 10, top: 0, bottom: 12 })
        .height('80%')
        .backgroundColor(getCurrentTheme().surfaceColor)
        .borderRadius(12)
        .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 4 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('rgba(0, 0, 0, 0.5)')
      .alignContent(Alignment.Center)
    }
  }

  @Builder
  private buildStatRow(label: string, value: string): void {
    Row() {
      Text(label)
        .fontSize(18)  // 统计标签字体调大到18px
        .fontColor(getCurrentTheme().textColor)
        .layoutWeight(1)
        .textOverflow({ overflow: TextOverflow.Clip })
      Text(value)
        .fontSize(18)  // 统计值字体调大到18px
        .fontColor(getCurrentTheme().primary)
        .textAlign(TextAlign.End)
        .constraintSize({ minWidth: 80 })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .padding({ top: 6, bottom: 6 })
  }
}


