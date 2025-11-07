import { MeasureOptions } from "@kit.ArkUI"
import { OmniTheme, OmniThemeStyle } from "../../theme/OmniTheme"

@Component
export struct OmniExpandableText {
  @StorageLink(OmniTheme.KEY)
  private baseStyle: OmniThemeStyle = OmniTheme.getDefaultStyle()
  @State isFold: boolean = true
  @State private showAction: boolean = false
  @Prop @Watch('handleShowAction') content: string = ''
  @Prop @Watch('handleShowAction') maxLine: number = 99
  @State private shadowHeight: Length = 17
  @Prop contentFontColor: ResourceColor = '#43474D'
  @Prop contentFontSize: string | number | Resource = this.baseStyle.fontSizeMd
  @Prop expandFontColor: ResourceColor = '#517A99'
  @Prop expandFontSize: string | number | Resource = this.baseStyle.fontSizeMd
  @Prop foldText: ResourceStr = '收起'
  @Prop expandText: ResourceStr = '展开'
  private uniId: string = ''
  @State private textWidth: number = 0
  @State private textMaxHeight: number = 0
  @State private textHeight: number = 0

  aboutToAppear(): void {
    this.uniId = this.getUniqueId().toString()
    this.handleShowAction()
  }

  //特殊处理换行符
  handleBr(rawHtml: string) {
    const brStr = '<br>'
    while (rawHtml.search(brStr) > 0) {
      rawHtml = rawHtml.replace('<br>', `\n`)
    }
    return rawHtml
  }

  handleShowAction() {
    setTimeout(() => {
      this.textWidth = px2vp(this.getUIContext()
        .getComponentUtils()
        .getRectangleById(this.uniId)
        .size
        .width)
      this.textHeight = this.getTextHeight({
        textContent: this.content,
        fontSize: this.contentFontSize,
        constraintWidth: this.textWidth
      })
      this.textMaxHeight = this.getTextHeight({
        textContent: this.content,
        fontSize: this.contentFontSize,
        constraintWidth: this.textWidth,
        maxLines: this.maxLine
      })
      if (this.textHeight > this.textMaxHeight) {
        this.showAction = true
      }
      this.shadowHeight = px2vp(this.getTextHeight({
        textContent: this.content,
        fontSize: this.contentFontSize,
        constraintWidth: this.textWidth,
        maxLines: 1
      }))
    }, 0)
  }

  /**
   * 返回文本所占布局高度，单位为px
   * @param options
   * @returns
   */
  getTextHeight(options: MeasureOptions) {
    return this.getUIContext().getMeasureUtils().measureTextSize(options).height as number;
  }

  build() {
    Column() {
      Stack() {
        Text(this.handleBr(this.content ?? ''))
          .width('100%')
          .fontColor(this.contentFontColor)
          .fontSize(this.contentFontSize)
          .maxLines(this.isFold ? this.maxLine ?? 99 : 99)
          .id(this.uniId)

        if (this.showAction == true) {
          Stack() {
            Image('https://wos.58cdn.com.cn/cDazYxWcDHJ/picasso/6udkiul3.png')
              .width(100)
              .height(this.shadowHeight)
              .visibility(this.isFold ? Visibility.Visible : Visibility.Hidden)

            Text(this.isFold ? this.expandText : this.foldText)
              .fontColor(this.expandFontColor)
              .fontSize(this.expandFontSize)
              .onClick(() => {
                this.isFold = !this.isFold
              })
          }.alignContent(Alignment.End)
        }
      }.alignContent(Alignment.BottomEnd)
    }
    .alignItems(HorizontalAlign.Start)
  }
}