/**
 * 出口状态面板组件
 * 显示各出口的装箱数量和重量
 * 对应48项目的出口状态显示区域
 */

import {
  GlobalDataInterface,
  GlobalRealtimeData,
  getGlobalDataInterface,
  DataChangeListener
} from '../../protocol/GlobalDataInterface'
import { ConstPreDefine } from '../../protocol/ConstPreDefine'
import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { AppleDesignStyle } from '../../utils/theme/AppleDesignStyle'

/**
 * 出口数据展示项
 */
interface ExitData {
  index: number
  count: number
  weight: number
}

/**
 * 出口状态面板组件
 */
@Component
export struct ExitStatusPanel {
  @State private exitData: ExitData[] = []
  @State private maxExits: number = 48
  @State private displayColumns: number = 6

  private dataInterface: GlobalDataInterface = getGlobalDataInterface()
  private dataChangeListener: DataChangeListener | null = null

  getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(OmniThemeManager.getInstance().getCurrentTheme())
  }

  aboutToAppear(): void {
    // 获取初始数据
    this.updateExitData(this.dataInterface.getGlobalData())

    // 注册数据变化监听器
    this.dataChangeListener = (data: GlobalRealtimeData) => {
      this.updateExitData(data)
    }
    this.dataInterface.addDataChangeListener(this.dataChangeListener)
  }

  aboutToDisappear(): void {
    if (this.dataChangeListener) {
      this.dataInterface.removeDataChangeListener(this.dataChangeListener)
      this.dataChangeListener = null
    }
  }

  /**
   * 更新出口数据
   */
  private updateExitData(globalData: GlobalRealtimeData): void {
    const exits: ExitData[] = []
    const count = Math.min(this.maxExits, globalData.exitCount.length)

    for (let i = 0; i < count; i++) {
      if (globalData.exitCount[i] > 0 || i < 12) { // 显示有数据的或前12个
        exits.push({
          index: i,
          count: globalData.exitCount[i],
          weight: globalData.exitWeight[i]
        })
      }
    }

    this.exitData = exits
  }

  /**
   * 格式化重量
   */
  private formatWeight(weightGram: number): string {
    if (weightGram >= 1000) {
      return (weightGram / 1000).toFixed(1) + 'kg'
    }
    return weightGram + 'g'
  }

  /**
   * 获取出口状态颜色
   */
  private getExitColor(count: number): string {
    if (count === 0) return '#E0E0E0'
    if (count < 10) return '#A5D6A7'
    if (count < 50) return '#66BB6A'
    if (count < 100) return '#43A047'
    return '#2E7D32'
  }

  build() {
    Column({ space: 12 }) {
      // 标题
      Row() {
        Text('📦 出口状态')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getCurrentTheme().textColor)
          .layoutWeight(1)

        Text(`共 ${this.exitData.length} 个出口`)
          .fontSize(12)
          .fontColor(this.getCurrentTheme().subTextColor ?? this.getCurrentTheme().textColor)
      }
      .width('100%')

      // 出口网格
      if (this.exitData.length > 0) {
        Grid() {
          ForEach(this.exitData, (exit: ExitData) => {
            GridItem() {
              Column({ space: 4 }) {
                // 出口编号
                Text(`出口 ${exit.index + 1}`)
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.getCurrentTheme().textColor)

                // 数量
                Text(`${exit.count}`)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(exit.count > 0 ? '#2E7D32' : '#9E9E9E')

                // 重量
                Text(this.formatWeight(exit.weight))
                  .fontSize(10)
                  .fontColor(this.getCurrentTheme().subTextColor ?? this.getCurrentTheme().textColor)
              }
              .width('100%')
              .height(80)
              .padding(8)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(this.getExitColor(exit.count))
              .borderRadius(8)
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
            }
          })
        }
        .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr')
        .rowsGap(8)
        .columnsGap(8)
        .width('100%')
      } else {
        // 无数据
        Column() {
          Text('暂无出口数据')
            .fontSize(14)
            .fontColor(this.getCurrentTheme().subTextColor ?? this.getCurrentTheme().textColor)
        }
        .width('100%')
        .height(100)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.getCurrentTheme().surfaceColor ?? this.getCurrentTheme().backgroundColor)
        .borderRadius(AppleDesignStyle.BORDER_RADIUS_MEDIUM)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.getCurrentTheme().surfaceColor ?? this.getCurrentTheme().backgroundColor)
    .borderRadius(AppleDesignStyle.BORDER_RADIUS_MEDIUM)
    .border({ width: 1, color: this.getCurrentTheme().borderColor })
  }
}
