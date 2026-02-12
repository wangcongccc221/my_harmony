/**
 * 第二层组件
 * 显示卡片序号和波浪高度信息
 */

import { ThreeLayerCardData } from './types'
import { CardColorConfig } from '../../utils/theme/CardColors'

@Component
export struct SecondLayer {
  @Prop cardData: ThreeLayerCardData
  @Prop enableWave: boolean
  @Prop cardColors: CardColorConfig
  @Prop cardNumber: number
  @Prop waveHeightPercent: number

  // 实时数据状态
  @State realtimePercent: number = 0

  aboutToAppear() {
    // 建立与 AppStorage 的直接链接，实现毫秒级实时更新
    // 注意：这里我们只读取数据，不写入，所以用 Link 或 Prop 都可以
    // 使用 Link 可以确保双向同步（虽然这里只需要单向读取）
    // 初始化时尝试获取当前值
    const key = `EXIT_PERCENT_${this.cardNumber}`
    if (AppStorage.has(key)) {
      this.realtimePercent = AppStorage.get(key) as number
    } else {
      this.realtimePercent = this.waveHeightPercent
    }
  }

  // 监听全局更新信号，强制刷新
  @StorageProp('GLOBAL_CARD_DATA_UPDATE_SIGNAL') @Watch('onDataUpdate') dataUpdateSignal: number = 0

  onDataUpdate() {
    const key = `EXIT_PERCENT_${this.cardNumber}`
    if (AppStorage.has(key)) {
      this.realtimePercent = AppStorage.get(key) as number
    }
  }

  build() {
    Row() {
      Text(`${this.cardNumber}`)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.cardColors.cardNumberText)

      Blank().layoutWeight(1)

      Column() {
        Text(`${(Number.isFinite(this.realtimePercent) ? this.realtimePercent : this.waveHeightPercent).toFixed(2)}%`)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.cardColors.wavePercentText)
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .height('20%')
    .layoutWeight(0)
    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
    .backgroundColor(Color.Transparent)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .border({ width: 1, color: this.cardColors.cardBorder })
  }
}
