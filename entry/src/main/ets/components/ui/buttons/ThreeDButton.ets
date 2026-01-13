import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'

@Component
export struct ThreeDButton {
  @Prop text: string
  @Prop isSelected: boolean
  @Prop buttonWidth: number | string = 140 // 支持自定义宽度
  @Prop buttonHeight: number = 48 // 支持自定义高度
  @Prop fontSize: number = 17 // 支持自定义字体大小
  onClickCallback?: () => void

  @State isHovered: boolean = false
  @State isPressed: boolean = false

  // 获取当前主题
  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return OmniThemeManager.getInstance().getCurrentTheme()
  }

  build() {
    Button() {
      Text(this.text)
        .fontSize(this.fontSize)
        .fontColor(this.isSelected ? this.getCurrentTheme().primary : this.getCurrentTheme().textColor)
        .fontWeight(FontWeight.Medium)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(1)
    }
    .width(this.buttonWidth)
    .height(this.buttonHeight)
    .type(ButtonType.Normal)
    .borderRadius(12)
    .backgroundColor(this.isSelected ? (this.getCurrentTheme().primary + '20') : (this.getCurrentTheme().surfaceColor ?? '#FFFFFF'))
    .border({
      width: 1,
      color: this.isSelected ? this.getCurrentTheme().primary : this.getCurrentTheme().borderColor,
      style: BorderStyle.Solid
    })
    .translate({ y: 0 })
    .animation({
      duration: 150,
      curve: Curve.EaseInOut
    })
    .onClick(() => {
      if (this.onClickCallback) {
        this.onClickCallback()
      }
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isPressed = true
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isPressed = false
      }
    })
    .onHover((isHover: boolean) => {
      this.isHovered = isHover
    })
  }
}
