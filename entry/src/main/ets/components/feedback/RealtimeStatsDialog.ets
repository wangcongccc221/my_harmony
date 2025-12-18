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
import { ExportStatisticsContent } from './ExportStatisticsContent'
import { ExportStatisticsBarChart } from '../charts/ExportStatisticsBarChart'
import { HOME_SELECTED_FSM } from '../../constants/TopBarKeys'

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

  // 获取当前选中的子系统值（用于下拉框显示）
  private getSelectedSubsystemValue(): string {
    const currentFSM = AppStorage.get<string>(HOME_SELECTED_FSM) || 'FSM1'
    return currentFSM === 'FSM1' ? '1' : '2'
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
               // 使用新的出口统计柱状图组件（2个数据系列，与FSM联动）
              ExportStatisticsBarChart({
                title: '出口统计信息',
                chartHeight: 350
              })
                .width('100%')
                .layoutWeight(1)
              
              // 底部控制栏
              Row() {
                // 左侧：子系统下拉框
                Row() {
                  Text('子系统:')
                    .fontSize(16)  // 从14增加到16
                    .fontWeight(FontWeight.Medium)  // 加粗，更清晰
                    .fontColor(getCurrentTheme().textColor)
                    .margin({ right: 10 })
                  
                  Select([{ value: '1' }, { value: '2' }])
                    .value(this.getSelectedSubsystemValue())
                    .font({ size: 16 })  // 下拉框字体也调大
                    .onSelect((index: number, value: string) => {
                      // 切换FSM
                      const newFSM = value === '1' ? 'FSM1' : 'FSM2'
                      AppStorage.set(HOME_SELECTED_FSM, newFSM)
                    })
                }
                .layoutWeight(1)
                .justifyContent(FlexAlign.Start)
                
                // 右侧：按钮组
                Row() {
                  Button('批次比例刷新')
                    .fontSize(14)  // 从12增加到14
                    .fontWeight(FontWeight.Medium)  // 加粗
                    .backgroundColor(getCurrentTheme().controlBg || getCurrentTheme().surfaceColor)
                    .fontColor(getCurrentTheme().textColor)
                    .height(36)  // 增加按钮高度
                    .onClick(() => {
                      console.log('批次比例刷新')
                    })
                    .margin({ right: 10 })
                  
                  Button('实时比例刷新')
                    .fontSize(14)  // 从12增加到14
                    .fontWeight(FontWeight.Medium)  // 加粗
                    .backgroundColor(getCurrentTheme().controlBg || getCurrentTheme().surfaceColor)
                    .fontColor(getCurrentTheme().textColor)
                    .height(36)  // 增加按钮高度
                    .onClick(() => {
                      console.log('实时比例刷新')
                    })
                    .margin({ right: 10 })
                  
                  Button('导出')
                    .fontSize(14)  // 从12增加到14
                    .fontWeight(FontWeight.Medium)  // 加粗
                    .backgroundColor(getCurrentTheme().primary)
                    .fontColor(Color.White)
                    .height(36)  // 增加按钮高度
                    .onClick(() => {
                      console.log('导出')
                    })
                    .margin({ right: 10 })
                  
                  Button('打印')
                    .fontSize(14)  // 从12增加到14
                    .fontWeight(FontWeight.Medium)  // 加粗
                    .backgroundColor(getCurrentTheme().primary)
                    .fontColor(Color.White)
                    .height(36)  // 增加按钮高度
                    .onClick(() => {
                      console.log('打印')
                    })
                }
                .justifyContent(FlexAlign.End)
              }
              .width('100%')
              .height(56)  // 从50增加到56，给更大的空间
              .padding({ left: 16, right: 16, top: 10, bottom: 10 })  // 增加内边距
              .backgroundColor(getCurrentTheme().controlBg || '#808080')
              .alignItems(VerticalAlign.Center)
            } else {
              // 其他标签页内容已清空
              Column() {
                Text('')
                  .fontSize(16)
                  .fontColor(getCurrentTheme().subTextColor)
              }
              .width('100%')
              .height('100%')
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
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


