import { OmniTheme, OmniThemeStyle } from '../../theme/OmniTheme'
import { TextUtils } from '../../utils/TextUtils'
import { ToastWrapBuilderArgs } from './OmniToastTheme'

@Builder
export function imageTextContentBuilder(args: ToastWrapBuilderArgs) {
  OmniToastComponent({ args })
}

@Component
struct OmniToastComponent {
  @StorageLink(OmniTheme.KEY)
  private baseStyle: OmniThemeStyle = OmniTheme.getDefaultStyle()
  @Prop args: ToastWrapBuilderArgs

  build() {
    Row() {
      if (this.args.icon) {
        Image(this.args.icon)
          .width(this.args.theme?.iconWidth ?? 25)
          .height(this.args.theme?.iconWidth ?? 25)
          .margin((this.args.icon && !TextUtils.isBlank(this.args.msg ?? '')) ? { right: 5 } : { right: 0 })
      }
      if (!TextUtils.isBlank(this.args.msg ?? '')) {
        Text(this.args.msg)
          .fontSize(this.args.theme?.fontSize ?? this.baseStyle.fontSizeLg)
          .fontColor(this.args.theme?.textColor ?? Color.White)
      }
    }
    .height(this.args.theme?.height)
    .width(this.args.theme?.width)
    .margin({ left: 12, right: 12 })
    .padding(12)
    .backgroundColor(this.args.theme?.backgroundColor ?? 0xDD000000)
    .backgroundBlurStyle(this.args.theme?.backgroundBlurStyle)
    .shadow(this.args.theme?.shadow)
    .borderRadius(this.args.theme?.borderRadius ?? 10)
    .borderWidth(this.args.theme?.borderWidth)
    .borderStyle(this.args.theme?.borderStyle)
    .borderColor(this.args.theme?.borderColor)
  }
}