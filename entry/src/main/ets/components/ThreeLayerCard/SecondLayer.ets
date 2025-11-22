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

  build() {
    Row() {
      Text(`${this.cardNumber}`)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.cardColors.cardNumberText)

      Blank().layoutWeight(1)

      if (this.enableWave) {
        Text(`${this.waveHeightPercent}%`)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.cardColors.wavePercentText)
      }
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
