import { OmniUIUtils } from '../../../utils/helpers/OmniUIUtils'
import { getCurrentTheme } from '../../../utils/theme/ThemeUtils'
import { AppleDesignStyle } from '../../../utils/theme/AppleDesignStyle'

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
  // 可选：自定义圆角像素。不传则按 Apple Design 风格自动设置
  borderRadiusPx?: number

  @State private isPressed: boolean = false

  build() {
    // Apple Design 风格按钮
    Column() {
      Text(this.text)
        .fontSize(this.fontSizePx)
        .fontColor(this.isActive ? Color.White : getCurrentTheme().textColor)
        .fontWeight(this.isActive ? FontWeight.Medium : FontWeight.Regular) // Apple风格：激活时加粗
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
    .border({ 
      width: this.isActive ? 0 : AppleDesignStyle.BORDER_WIDTH_THIN, // Apple风格：激活时无边框
      color: this.isActive ? Color.Transparent : getCurrentTheme().borderColor 
    })
    .borderRadius(this.borderRadiusPx !== undefined ? this.borderRadiusPx : AppleDesignStyle.BORDER_RADIUS_MEDIUM) // Apple风格：中等圆角
    .shadow(this.isActive ? AppleDesignStyle.getShadowSmall('rgba(0, 0, 0, 0.12)') : undefined) // Apple风格：激活时添加柔和阴影
    .transition(AppleDesignStyle.getTransitionNormal()) // Apple风格：流畅过渡动画
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


