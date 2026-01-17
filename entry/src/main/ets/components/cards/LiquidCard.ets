import { AppleDesignStyle } from '../../utils/theme/AppleDesignStyle'

@Component
export struct LiquidCard {
  @Prop iconText: string = 'A'
  @Prop iconRes: number | Resource | null = null
  /** 顶部栏背景色与高度（可选） */
  @Prop topBarBg: string | number | Color = '#fff5f5'
  @Prop topBarHeight: number = 24

  @BuilderParam topContent?: () => void
  /** 水位百分比 0~100 */
  @Prop percent: number = 67
  /** 液体颜色（支持十六进制字符串、资源色number、Color） */
  @Prop mainColor: string | number | Color = '#EA7A10'
  /** 卡片宽高 */
  @Prop cardWidth: number = 150
  @Prop cardHeight: number = 200
  /** 序列号（第二层左侧数字） */
  @Prop serialNumber: number = 1

  private clampPercent(v: number): number {
    if (v < 0) { return 0 }
    if (v > 100) { return 100 }
    return Math.floor(v)
  }

  build() {
    Column() {
      // 顶部图标条
      Row() {
        if (this.topContent) {
          this.topContent!()
        } else if (this.iconRes !== null) {
          Image(this.iconRes as Resource)
            .width(20)
            .height(20)
            .objectFit(ImageFit.Contain)
        } else {
          Text(this.iconText)
            .width(30)
            .height(30)
            .backgroundColor(this.mainColor)
            .borderRadius(AppleDesignStyle.BORDER_RADIUS_SMALL) // Apple风格：小圆角
            .fontColor(Color.White)
            .fontSize(14)
            .fontWeight(FontWeight.Medium) // Apple风格：使用Medium而非Bold
            .textAlign(TextAlign.Center)
            .lineHeight(30)
        }
      }
      .width('100%')
      .height(this.topBarHeight)
      .backgroundColor(this.topBarBg)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)

      // 中间数字与百分比
      Row() {
        Text(`${this.serialNumber}`)
          .fontSize(20)
          .fontWeight(FontWeight.Medium) // Apple风格：使用Medium（HarmonyOS不支持SemiBold）
          .fontColor('#222222')
        Blank().layoutWeight(1)
        Text(`${this.clampPercent(this.percent).toFixed(2)}%`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium) // Apple风格：使用Medium
          .fontColor(this.mainColor)
      }
      .width('100%')
      .height(24)
      .padding({ left: 15, right: 15 })
      .alignItems(VerticalAlign.Center)

      // 分割线
      Row() {}
        .width('100%')
      .height(2)
        .backgroundColor(this.mainColor)
        .opacity(0.6)
        .borderRadius(2)

      // 底部液体条（简化版本，提升性能）
      Column() {
        // 液体层（简化渲染）
        Row() {}
          .width('100%')
          .height(`${this.clampPercent(this.percent)}%`)
          .backgroundColor(this.mainColor)
          .opacity(0.9)
          .borderRadius({ bottomLeft: AppleDesignStyle.BORDER_RADIUS_MEDIUM, bottomRight: AppleDesignStyle.BORDER_RADIUS_MEDIUM }) // Apple风格：中等圆角
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#00000006')
      .justifyContent(FlexAlign.End)
    }
    .width(this.cardWidth)
    .height(this.cardHeight)
    .backgroundColor(Color.White)
    .borderRadius(AppleDesignStyle.BORDER_RADIUS_MEDIUM) // Apple风格：中等圆角12px
    .shadow(AppleDesignStyle.getShadowMedium('rgba(0, 0, 0, 0.12)')) // Apple风格：柔和阴影
    .clip(true)
  }
}


