/**
 * 第一层组件
 * 显示图标和标题信息
 */

import { ThreeLayerCardData } from './types'
import { CardColorConfig } from '../../utils/theme/CardColors'

@Component
export struct FirstLayer {
  @Prop cardData: ThreeLayerCardData
  @Prop cardColors: CardColorConfig

  build() {
    Row() {
      Image($r('app.media.icon_logo'))
        .width(20)
        .height(20)
        .objectFit(ImageFit.Contain)

      Column() {
        // 内容已清空
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 8 })
    }
    .width('100%')
    .height('20%')
    .layoutWeight(0)
    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
    .backgroundColor(Color.Transparent)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .border({ width: 1, color: this.cardColors.cardBorder })
  }
}
