import { OmniTheme, OmniThemeStyle } from "../../../theme/OmniTheme"
import { OmniFilterMenuItemBean } from "../bean/OmniFilterMenuItemBean"
import { OmniFilterStyle } from "../OmniFilterThemeConfig"

@Component
export struct OmniFilterMenuItemComponent {
  @ObjectLink menuItem: OmniFilterMenuItemBean
  @Consume filterStyle: OmniFilterStyle
  @StorageLink(OmniTheme.KEY)
  baseStyle: OmniThemeStyle = OmniTheme.getDefaultStyle()

  build() {
    Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      Text(this.menuItem.menuTitle)
        .fontSize(this.menuFontSize())
        .fontColor(this.menuFontColor())
        .fontWeight(this.menuFontWeight())
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .ellipsisMode(EllipsisMode.END)
        .flexBasis('auto')
      Image(this.menuItem.active ? $r('app.media.icon_arrow_up') : $r('app.media.icon_arrow_down'))
        .width(12)
        .height(6)
        .fillColor(this.menuFontColor())
        .margin({ left: 4 })
    }
    .width(`100%`)
    .padding({ left: 10, right: 10 })
  }

  private menuFontSize(): number | string | Resource {
    if (this.menuItem.isHighLight || this.menuItem.active) {
      return this.filterStyle.menuStyle?.menuSelectedTextStyle?.fontSize ?? this.baseStyle.fontSizeLg
    } else {
      return this.filterStyle.menuStyle?.menuTextStyle?.fontSize ?? this.baseStyle.fontSizeLg
    }
  }

  private menuFontColor(): ResourceColor {
    if (this.menuItem.isHighLight || this.menuItem.active) {
      return this.filterStyle.menuStyle?.menuSelectedTextStyle?.fontColor ?? this.baseStyle.primary
    } else {
      return this.filterStyle.menuStyle?.menuTextStyle?.fontColor ?? Color.Black
    }
  }

  private menuFontWeight(): number | FontWeight | string {
    if (this.menuItem.isHighLight || this.menuItem.active) {
      return this.filterStyle.menuStyle?.menuSelectedTextStyle?.fontWeight ?? FontWeight.Regular
    } else {
      return this.filterStyle.menuStyle?.menuTextStyle?.fontWeight ?? FontWeight.Regular
    }
  }
}
