@Component
export struct LiquidCard {
  /**
   * 顶部小图标文字（默认方案）
   * - 未提供 iconRes / topContent 时生效
   * - 例如：'A'、'1'、'出'
   */
  @Prop iconText: string = 'A'
  /**
   * 顶部小图标图片资源（优先于 iconText 渲染）
   * - 类型：资源引用，如 $r('app.media.logo') / $r('app.media.icon_svg')
   * - 支持 png/jpg/svg 等放在 resources/media 下的资源
   * - 示例：
   *   LiquidCard({ iconRes: $r('app.media.logo') })
   */
  @Prop iconRes: number | Resource | null = null
  /** 顶部栏背景色与高度（可选） */
  @Prop topBarBg: string | number | Color = '#fff5f5'
  @Prop topBarHeight: number = 24
  /**
   * 顶部完全自定义内容（若提供，则覆盖 iconRes 与 iconText 的渲染）
   * - 适合：更复杂的布局、矢量/SVG、动态状态等
   * - 使用示例：
   *   LiquidCard({
   *     topContent: () => {
   *       // 方案1：直接使用图片资源（包含 svg）
   *       Image($r('app.media.icon_svg')).width(20).height(20).objectFit(ImageFit.Contain)
   *
   *       // 方案2：任意自定义布局
   *       // Row() { Text('A').fontSize(12).fontColor(Color.White) }.height(24)
   *     }
   *   })
   */
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
            .borderRadius(6)
            .fontColor(Color.White)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
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
          .fontWeight(FontWeight.Bold)
          .fontColor('#222222')
        Blank().layoutWeight(1)
        Text(`${this.clampPercent(this.percent)}%`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
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
          .borderRadius({ bottomLeft: 12, bottomRight: 12 })
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#00000006')
      .justifyContent(FlexAlign.End)
    }
    .width(this.cardWidth)
    .height(this.cardHeight)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 10, color: 'rgba(0,0,0,0.12)', offsetX: 0, offsetY: 4 })
    .clip(true)
  }
}


