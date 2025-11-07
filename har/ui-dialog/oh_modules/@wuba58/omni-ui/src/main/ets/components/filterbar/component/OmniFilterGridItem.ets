import { OmniFilterItemBean } from "../bean/OmniFilterItemBean"
import { OmniTheme, OmniThemeStyle } from "../../../theme/OmniTheme"
import { OmniFilterStyle } from "../OmniFilterThemeConfig"

@Component
@Preview
export struct OmniFilterGridItem {
  private static DEFAULT_ROW_COUNT = 3//默认网格数
  @StorageLink(OmniTheme.KEY)
  baseStyle: OmniThemeStyle = OmniTheme.getDefaultStyle()
  @Consume filterStyle: OmniFilterStyle
  @Prop item: OmniFilterItemBean
  @Prop focusedIndex: number
  @Prop listIndex: number
  @Prop @Require componentWidth: number = 0
  gridItemSelect?: () => void

  build() {
    Column() {
      Text(`${this.item.title}`)
        .fontColor(this.itemFontColor())
        .fontSize(this.itemFontSize())
        .fontWeight(this.itemFontWeight())
    }
    .borderRadius(2)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width(this.tagWidth())
    .height(34)
    .backgroundColor(this.tagBackgroundColor())
    .onClick(() => {
      //TODO 最大选择数量
      this.gridItemSelect?.()
    })
  }

  private tagWidth(): number {
    const baseWidth = this.componentWidth
    const rowCount = this.filterStyle.gridStyle?.rowCount ?? OmniFilterGridItem.DEFAULT_ROW_COUNT
    return Math.floor(
      (baseWidth - 40 - 12 * (rowCount - 1)) / rowCount
    );
  }

  private itemFontSize(): number | string | Resource {
    if (this.isItemFocused()) {
      return this.filterStyle.gridStyle?.itemSelectedTextStyle?.fontSize ?? this.baseStyle.fontSizeMd
    } else {
      return this.filterStyle.gridStyle?.itemTextStyle?.fontSize ?? this.baseStyle.fontSizeMd
    }
  }

  private itemFontColor(): ResourceColor {
    if (this.isItemFocused()) {
      return this.filterStyle.gridStyle?.itemSelectedTextStyle?.fontColor ?? this.baseStyle.primary
    } else {
      return this.filterStyle.gridStyle?.itemTextStyle?.fontColor ?? Color.Black
    }
  }

  private itemFontWeight(): number | FontWeight | string {
    if (this.isItemFocused()) {
      return this.filterStyle.gridStyle?.itemSelectedTextStyle?.fontWeight ?? FontWeight.Regular
    } else {
      return this.filterStyle.gridStyle?.itemTextStyle?.fontWeight ?? FontWeight.Regular
    }
  }

  private tagBackgroundColor(): ResourceColor {
    if (this.isItemFocused()) {
      return this.filterStyle.gridStyle?.itemSelectedBgColor ?? this.baseStyle.primaryColorWithOpacity(0.12)
    } else {
      return this.filterStyle.gridStyle?.itemBgColor ?? 0xFFF8F8F8
    }
  }

  private isItemFocused(): boolean {
    let isFocused = this.focusedIndex == this.listIndex;
    if (!isFocused && this.item.isSelected && this.item.isInLastLevel()) {
      isFocused = true;
    }
    return isFocused;
  }
}