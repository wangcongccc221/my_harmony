/**
 * 实时数据面板组件
 * 显示产量、总重、效率等核心统计数据
 * 对应48项目的实时数据显示区域
 */

import {
  GlobalDataInterface,
  GlobalRealtimeData,
  getGlobalDataInterface,
  DataChangeListener
} from '../../protocol/GlobalDataInterface'
import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { AppleDesignStyle } from '../../utils/theme/AppleDesignStyle'

/**
 * 实时数据面板组件
 * 显示关键统计指标
 */
@Component
export struct RealtimeDataPanel {
  @State private realtimeData: GlobalRealtimeData | null = null
  @State private isProcessing: boolean = false

  private dataInterface: GlobalDataInterface = getGlobalDataInterface()
  private dataChangeListener: DataChangeListener | null = null

  getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(OmniThemeManager.getInstance().getCurrentTheme())
  }

  aboutToAppear(): void {
    // 获取初始数据
    this.realtimeData = this.dataInterface.getGlobalData()
    this.isProcessing = this.dataInterface.isCurrentlyProcessing()

    // 注册数据变化监听器
    this.dataChangeListener = (data: GlobalRealtimeData) => {
      this.realtimeData = data
      this.isProcessing = this.dataInterface.isCurrentlyProcessing()
    }
    this.dataInterface.addDataChangeListener(this.dataChangeListener)
  }

  aboutToDisappear(): void {
    // 移除监听器
    if (this.dataChangeListener) {
      this.dataInterface.removeDataChangeListener(this.dataChangeListener)
      this.dataChangeListener = null
    }
  }

  /**
   * 格式化重量（克 -> 千克）
   */
  private formatWeight(weightGram: number): string {
    if (weightGram >= 1000000) {
      return (weightGram / 1000000).toFixed(2) + ' 吨'
    } else if (weightGram >= 1000) {
      return (weightGram / 1000).toFixed(2) + ' kg'
    }
    return weightGram.toFixed(0) + ' g'
  }

  /**
   * 格式化时间（秒 -> 时:分:秒）
   */
  private formatTime(seconds: number): string {
    const hours = Math.floor(seconds / 3600)
    const minutes = Math.floor((seconds % 3600) / 60)
    const secs = Math.floor(seconds % 60)

    if (hours > 0) {
      return `${hours}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
    }
    return `${minutes}:${secs.toString().padStart(2, '0')}`
  }

  /**
   * 构建统计卡片
   */
  @Builder
  private buildStatCard(title: string, value: string, unit: string, color: string, icon: string) {
    Column({ space: 8 }) {
      Row({ space: 8 }) {
        Text(icon)
          .fontSize(24)

        Text(title)
          .fontSize(14)
          .fontColor(this.getCurrentTheme().subTextColor ?? this.getCurrentTheme().textColor)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Row() {
        Text(value)
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor(color)

        Text(unit)
          .fontSize(14)
          .fontColor(this.getCurrentTheme().subTextColor ?? this.getCurrentTheme().textColor)
          .margin({ left: 4, bottom: 4 })
      }
      .alignItems(VerticalAlign.Bottom)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.getCurrentTheme().surfaceColor ?? this.getCurrentTheme().backgroundColor)
    .borderRadius(AppleDesignStyle.BORDER_RADIUS_MEDIUM)
    .border({ width: 1, color: this.getCurrentTheme().borderColor })
    .shadow(AppleDesignStyle.getShadowSmall())
  }

  build() {
    Column({ space: 16 }) {
      // 标题行
      Row() {
        Text('📊 实时统计')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getCurrentTheme().textColor)
          .layoutWeight(1)

        // 状态指示
        Row({ space: 8 }) {
          Circle()
            .width(10)
            .height(10)
            .fill(this.isProcessing ? '#4CAF50' : '#9E9E9E')

          Text(this.isProcessing ? '加工中' : '待机')
            .fontSize(12)
            .fontColor(this.isProcessing ? '#4CAF50' : '#9E9E9E')
        }
      }
      .width('100%')

      // 主要统计卡片
      if (this.realtimeData) {
        // 第一行：产量和总重
        Row({ space: 12 }) {
          Column() {
            this.buildStatCard(
              '产量',
              this.realtimeData.totalYield.toString(),
              '个',
              '#2196F3',
              '🍎'
            )
          }
          .layoutWeight(1)

          Column() {
            this.buildStatCard(
              '总重',
              this.formatWeight(this.realtimeData.totalWeight),
              '',
              '#4CAF50',
              '⚖️'
            )
          }
          .layoutWeight(1)
        }
        .width('100%')

        // 第二行：合格率和效率
        Row({ space: 12 }) {
          Column() {
            const total = this.realtimeData.totalQualified + this.realtimeData.totalUnqualified
            const rate = total > 0 ? ((this.realtimeData.totalQualified / total) * 100).toFixed(1) : '0.0'
            this.buildStatCard(
              '合格率',
              rate,
              '%',
              '#FF9800',
              '✅'
            )
          }
          .layoutWeight(1)

          Column() {
            this.buildStatCard(
              '效率',
              this.realtimeData.efficiency.toFixed(1),
              '个/分',
              '#9C27B0',
              '⚡'
            )
          }
          .layoutWeight(1)
        }
        .width('100%')

        // 第三行：运行时间和设备状态
        Row({ space: 12 }) {
          Column() {
            this.buildStatCard(
              '运行时间',
              this.formatTime(this.realtimeData.runningTime),
              '',
              '#607D8B',
              '⏱️'
            )
          }
          .layoutWeight(1)

          Column() {
            this.buildStatCard(
              '合格/不合格',
              `${this.realtimeData.totalQualified}/${this.realtimeData.totalUnqualified}`,
              '',
              '#E91E63',
              '📈'
            )
          }
          .layoutWeight(1)
        }
        .width('100%')

        // 等级分布（可选展开）
        Column({ space: 8 }) {
          Text('等级分布')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getCurrentTheme().textColor)
            .width('100%')

          Row() {
            ForEach(this.realtimeData.gradeCount.slice(0, 8), (count: number, index: number) => {
              if (count > 0) {
                Column({ space: 4 }) {
                  Text(`${count}`)
                    .fontSize(12)
                    .fontColor(this.getCurrentTheme().textColor)

                  Text(`等级${index + 1}`)
                    .fontSize(10)
                    .fontColor(this.getCurrentTheme().subTextColor ?? this.getCurrentTheme().textColor)
                }
                .padding(8)
                .backgroundColor(this.getGradeColor(index))
                .borderRadius(6)
                .margin({ right: 4 })
              }
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.getCurrentTheme().surfaceColor ?? this.getCurrentTheme().backgroundColor)
        .borderRadius(AppleDesignStyle.BORDER_RADIUS_MEDIUM)
        .border({ width: 1, color: this.getCurrentTheme().borderColor })
      } else {
        // 无数据时显示
        Column() {
          Text('暂无统计数据')
            .fontSize(16)
            .fontColor(this.getCurrentTheme().subTextColor ?? this.getCurrentTheme().textColor)
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.getCurrentTheme().surfaceColor ?? this.getCurrentTheme().backgroundColor)
        .borderRadius(AppleDesignStyle.BORDER_RADIUS_MEDIUM)
      }
    }
    .width('100%')
    .padding(16)
  }

  /**
   * 获取等级对应的颜色
   */
  private getGradeColor(gradeIndex: number): string {
    const colors = [
      '#E3F2FD', '#BBDEFB', '#90CAF9', '#64B5F6',
      '#42A5F5', '#2196F3', '#1E88E5', '#1976D2'
    ]
    return colors[gradeIndex % colors.length]
  }
}
