import { OmniUIUtils } from '../../../utils/helpers/OmniUIUtils'
import { getCurrentTheme } from '../../../utils/theme/ThemeUtils'

@Component
export struct RectButton {
  text: string = ''
  widthPx: number = 56
  heightPx: number = 36
  marginLeftPx: number = 0
  marginRightPx: number = 8
  fontSizePx: number = 14
  @Prop isActive: boolean = false
  enableClickFeedback: boolean = true
  onTap: () => void = () => {}
  // 可选：自定义圆角像素。不传则按 min(width,height)/2 自动胶囊化
  borderRadiusPx?: number

  @State private isPressed: boolean = false

  build() {
    // 纯矩形按钮，无圆角
    Column() {
      Text(this.text)
        .fontSize(this.fontSizePx)
        .fontColor(this.isActive ? Color.White : getCurrentTheme().textColor)
        .textAlign(TextAlign.Center)
        .maxLines(1)
    }
    .width(this.widthPx)
    .height(this.heightPx)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(this.isActive
      ? getCurrentTheme().primary
      : (this.isPressed ? getCurrentTheme().borderColor : getCurrentTheme().surfaceColor))
    .border({ width: 1, color: this.isActive ? getCurrentTheme().primary : getCurrentTheme().borderColor })
    .borderRadius(this.borderRadiusPx !== undefined ? this.borderRadiusPx : Math.floor(Math.min(this.widthPx, this.heightPx) / 2))
    .margin({ left: this.marginLeftPx, right: this.marginRightPx })
    .opacity(this.isPressed ? 0.9 : 1)
    .onTouch((event) => {
      if (event.type === TouchType.Down) {
        this.isPressed = true
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isPressed = false
      }
    })
    .onClick(() => {
      if (this.enableClickFeedback) {
        OmniUIUtils.getInstance().showInfo(`已点击：${this.text}`)
      }
      this.onTap()
    })
  }
}


