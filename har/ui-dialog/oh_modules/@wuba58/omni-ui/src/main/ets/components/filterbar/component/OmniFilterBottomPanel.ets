import { OmniTheme, OmniThemeStyle } from "../../../theme/OmniTheme"
import { OmniFilterStyle } from "../OmniFilterThemeConfig"

@Component
export struct OmniFilterBottomPanel {
  private static DEFAULT_RESET_TEXT = `重置`
  private static DEFAULT_CONFIRM_TEXT = `确定`
  @StorageLink(OmniTheme.KEY)
  baseStyle: OmniThemeStyle = OmniTheme.getDefaultStyle()
  @Consume filterStyle: OmniFilterStyle
  onResetClick?: () => void
  onConfirmClick?: () => void

  build() {
    Column() {
      Divider()
        .color(0xFFCCCCCC)
        .height(1)
        .width(`100%`)
      Row() {
        Column() {
          Image(this.filterStyle.bottomPanelStyle?.resetIcon ?? $r('app.media.icon_filter_reset'))
            .width(24)
            .height(24)
          Text(this.filterStyle.bottomPanelStyle?.resetText ?? OmniFilterBottomPanel.DEFAULT_RESET_TEXT)
            .fontColor(this.filterStyle?.bottomPanelStyle?.resetTextStyle?.fontColor ?? Color.Black)
            .fontWeight(this.filterStyle?.bottomPanelStyle?.resetTextStyle?.fontWeight ?? FontWeight.Medium)
            .fontSize(this.filterStyle?.bottomPanelStyle?.resetTextStyle?.fontSize ?? this.baseStyle.fontSizeMd)
        }
        .padding({ left: 12, right: 20 })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          this.onResetClick?.()
        })

        Button(this.filterStyle.bottomPanelStyle?.confirmText ?? OmniFilterBottomPanel.DEFAULT_CONFIRM_TEXT,
          { type: ButtonType.Normal, stateEffect: true })
          .fontColor(this.filterStyle?.bottomPanelStyle?.confirmTextStyle?.fontColor ?? Color.White)
          .fontWeight(this.filterStyle?.bottomPanelStyle?.confirmTextStyle?.fontWeight ?? FontWeight.Medium)
          .fontSize(this.filterStyle?.bottomPanelStyle?.confirmTextStyle?.fontSize ?? this.baseStyle.fontSizeMd)
          .width('100%')
          .backgroundColor(this.filterStyle?.bottomPanelStyle?.confirmButtonColor ?? this.baseStyle.primary)
          .borderRadius(8)
          .layoutWeight(1)
          .onClick(() => {
            this.onConfirmClick?.()
          })
      }
      .padding({
        left: 10,
        top: 10,
        right: 10,
        bottom: 10
      })
      .alignItems(VerticalAlign.Center)
    }
    .backgroundColor(Color.White)
    .width('100%')
  }
}