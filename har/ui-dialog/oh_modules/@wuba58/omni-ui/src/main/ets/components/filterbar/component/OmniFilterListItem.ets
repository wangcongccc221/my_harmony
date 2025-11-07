import { OmniTheme, OmniThemeStyle } from "../../../theme/OmniTheme"
import { OmniFilterItemBean } from "../bean/OmniFilterItemBean"
import { OmniFilterStyle } from "../OmniFilterThemeConfig"
import { OmniFilterUtil } from "../util/OmniFilterUtil"

@Component
@Preview
export struct OmniFilterListItem {
  @StorageLink(OmniTheme.KEY)
  baseStyle: OmniThemeStyle = OmniTheme.getDefaultStyle()
  @Consume filterStyle: OmniFilterStyle
  @Prop item: OmniFilterItemBean
  listBackgroundColor: number = 1
  selectedBackgroundColor: number = 1
  @Prop focusedIndex: number
  @Prop listIndex: number
  @Prop isFirstLevel: boolean = false
  singleListItemSelect?: () => void

  build() {
    Row() {
      Text(this.item.title + this.getSelectedItemCount())
        .fontColor(this.itemFontColor())
        .fontSize(this.itemFontSize())
        .fontWeight(this.itemFontWeight())
        .maxLines(1)
        .textAlign(OmniFilterUtil.getTotalLevel(this.item) == 1 && this.isFirstLevel ? TextAlign.Center : TextAlign.Start)
        .ellipsisMode(EllipsisMode.END)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)

      if (!this.item.isUnLimit() && this.item.isInLastLevel() && this.item.hasCheckBoxBrother()) {
        Image(this.isHighLight() ?
          this.filterStyle.listStyle?.itemMultiSelectIconSelected ?? $r('app.media.icon_filter_select') :
          this.filterStyle.listStyle?.itemMultiSelectIconUnselected ?? $r('app.media.icon_filter_unselect'))
          .width(20)
          .height(20)
          .fillColor(this.filterStyle.listStyle?.itemSelectedTextStyle?.fontColor ?? this.baseStyle.primary)
      }
    }
    .width("100%")
    .padding({
      left: 20,
      top: 10,
      right: 20,
      bottom: 10
    })
    .backgroundColor(this.getItemBGColor())
    .onClick(() => {
      this.singleListItemSelect?.()
    })
  }

  private itemFontSize(): number | string | Resource {
    if (this.isHighLight()) {
      return this.filterStyle.listStyle?.itemSelectedTextStyle?.fontSize ?? this.baseStyle.fontSizeMd
    } else {
      return this.filterStyle.listStyle?.itemTextStyle?.fontSize ?? this.baseStyle.fontSizeMd
    }
  }

  private itemFontColor(): ResourceColor {
    if (this.isHighLight()) {
      return this.filterStyle.listStyle?.itemSelectedTextStyle?.fontColor ?? this.baseStyle.primary
    } else {
      return this.filterStyle.listStyle?.itemTextStyle?.fontColor ?? Color.Black
    }
  }

  private itemFontWeight(): number | FontWeight | string {
    if (this.isHighLight()) {
      return this.filterStyle.listStyle?.itemSelectedTextStyle?.fontWeight ?? FontWeight.Regular
    } else {
      return this.filterStyle.listStyle?.itemTextStyle?.fontWeight ?? FontWeight.Regular
    }
  }

  private getItemBGColor(): ResourceColor {
    if (this.isCurrentFocused()) {
      return this.selectedBackgroundColor;
    } else {
      return this.listBackgroundColor;
    }
  }

  private isHighLight(): boolean {
    if (this.item.isInLastLevel()) {
      if (this.item.isUnLimit()) {
        return this.isCurrentFocused();
      } else {
        return this.item.isSelected;
      }
    } else {
      return this.isCurrentFocused();
    }
  }

  private isCurrentFocused(): boolean {
    return this.isItemFocused(this.listIndex)
  }

  private isItemFocused(itemIndex: number): boolean {
    console.log(`isItemFocused title=${this.item.title} focusedIndex=${this.focusedIndex} listIndex=${this.listIndex}`);
    let isFocused = this.focusedIndex == itemIndex;
    if (!isFocused && this.item.isSelected && this.item.isInLastLevel()) {
      isFocused = true;
    }
    return isFocused;
  }

  private getSelectedItemCount(): string {
    const item: OmniFilterItemBean = this.item
    let itemCount = "";
    // 判断是否为三级以下节点或者是否为第一层级
    if ((OmniFilterUtil.getTotalLevel(item) < 3 || !this.isFirstLevel) && item.children.length > 0) {
      const selectedChildren = item.children.filter(child => child.isSelected && !child.isUnLimit());

      if (selectedChildren.length > 1) {
        return `(${selectedChildren.length})`;
      } else if (selectedChildren.length === 1 && item.hasCheckBoxBrother()) {
        return `(${selectedChildren.length})`;
      } else {
        const unLimited = item.children.filter(child => child.isSelected && child.isUnLimit());
        if (unLimited.length > 0) {
          return "(全部)";
        }
      }
    }

    return itemCount;
  }
}