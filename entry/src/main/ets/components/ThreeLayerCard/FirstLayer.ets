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

  @State private isHovered: boolean = false

  build() {
    Row() {
      // 圆形按钮样式的图标
      Button() {
        Image($r('app.media.icon_logo'))
          .width(16)
          .height(16)
          .objectFit(ImageFit.Contain)
      }
      .width(32)
      .height(32)
      .borderRadius(16) // 圆形按钮
      .backgroundColor(this.isHovered ? 'rgba(74, 144, 226, 0.1)' : Color.Transparent) // 悬停时淡蓝色背景
      .border({ width: 1, color: this.cardColors.cardBorder })
      .onClick(() => {
        // 可以添加点击事件
      })
      .onHover((isHover: boolean) => {
        this.isHovered = isHover
      })
      .animation({ duration: 200, curve: Curve.EaseInOut })

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
