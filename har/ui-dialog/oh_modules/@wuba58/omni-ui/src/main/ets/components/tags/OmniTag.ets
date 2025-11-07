import { TagItemInfo, TagMode, TagStyle } from './TagItemInfo'
import { LengthMetrics } from '@kit.ArkUI'
import { OmniTheme, OmniThemeStyle } from '../../theme/OmniTheme'

@Component
export struct OmniTag {
  @StorageLink(OmniTheme.KEY)
  private baseStyle: OmniThemeStyle = OmniTheme.getDefaultStyle()
  @Link tagItems: TagItemInfo[]
  selectable: boolean = true // 默认可点击
  isSelectedBold: boolean = false // 选中状态文字是否加粗，默认不加粗
  mode: TagMode = TagMode.HORIZONTAL_SCROLL
  @Prop horizontalSpace: number | string = 20 // 每个tag间的水平间隔
  @Prop flexSpace: FlexSpaceOptions = { main: LengthMetrics.vp(20), cross: LengthMetrics.vp(20) }
  @Prop style?: TagStyle = {
    itemBorder: { radius: 3 },
    textMargin: { left: 4, right: 4 },
    fontSize: this.baseStyle.fontSizeSm,
    fontColor: 0xFF666666,
    backgroundColor: 0xFFF7F7F7,
    itemPadding: {
      left: 8,
      right: 8,
      top: 5,
      bottom: 5
    },
  }
  onItemClick?: (tagItemInfo: TagItemInfo, index: number) => void // 对外暴露的点击回调接口

  @Builder
  horizontalScrollTagBuilder() {
    List({ space: this.horizontalSpace ?? 20 }) {
      ForEach(this.tagItems, (item: TagItemInfo, index: number) => {
        ListItem() {
          OmniTagItem({
            tagItem: item,
            index: index,
            isSelectedBold: this.isSelectedBold,
            selectable: this.selectable,
            onItemClick: this.onItemClick,
            style: this.style
          })
        }
      })
    }
    .width("100%")
    .listDirection(Axis.Horizontal)
    .alignListItem(ListItemAlign.Center)
    .scrollBar(BarState.Off)
  }

  @Builder
  flexTagBuilder() {
    Row() {
      Flex({
        wrap: FlexWrap.Wrap,
        space: this.flexSpace,
        alignItems: ItemAlign.Center
      }) {
        ForEach(this.tagItems, (item: TagItemInfo, index: number) => {
          OmniTagItem({
            tagItem: item,
            index: index,
            isSelectedBold: this.isSelectedBold,
            selectable: this.selectable,
            onItemClick: this.onItemClick,
            style: this.style
          })
        })
      }
    }
  }

  build() {
    if (this.mode == TagMode.HORIZONTAL_SCROLL) {
      this.horizontalScrollTagBuilder()
    } else {
      this.flexTagBuilder()
    }
  }
}

@Component
struct OmniTagItem {
  @StorageLink(OmniTheme.KEY)
  private baseStyle: OmniThemeStyle = OmniTheme.getDefaultStyle()
  @ObjectLink tagItem: TagItemInfo
  index: number = 0
  selectable: boolean = true // 默认可点击
  isSelectedBold: boolean = false // 选中状态文字是否加粗，默认不加粗
  @Prop style?: TagStyle = {
    itemBorder: { radius: 3 },
    textMargin: { left: 4, right: 4 },
    fontSize: this.baseStyle.fontSizeSm,
    fontColor: 0xFF666666,
    backgroundColor: 0xFFF7F7F7,
    itemPadding: {
      left: 8,
      right: 8,
      top: 5,
      bottom: 5
    },
  }
  onItemClick?: (tagItemInfo: TagItemInfo, index: number) => void // 对外暴露的点击回调接口
  private DEFAULT_ICON_SIZE: SizeOptions = { width: 15, height: 15 }

  build() {
    Column() {
      if (this.tagItem.icons?.top) {
        Image(this.tagItem.icons.top.icon)
          .size(this.tagItem.icons.top.iconSize ?? this.DEFAULT_ICON_SIZE)
      }
      Row() {
        if (this.tagItem.icons?.left) {
          Image(this.tagItem.icons.left.icon)
            .size(this.tagItem.icons.left.iconSize ?? this.DEFAULT_ICON_SIZE)
        }
        if (this.tagItem.title) {
          Text(this.tagItem.title)
            .fontColor(this.getFontColor())
            .fontWeight(this.getFontWeight())
            .fontSize(this.getFontSize())
            .margin(this.tagItem.tagStyle?.textMargin ?? this.style?.textMargin)
        }
        if (this.tagItem.icons?.right) {
          Image(this.tagItem.icons.right.icon)
            .size(this.tagItem.icons.right.iconSize ?? this.DEFAULT_ICON_SIZE)
        }
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)

      if (this.tagItem.icons?.bottom) {
        Image(this.tagItem.icons.bottom.icon)
          .size(this.tagItem.icons.bottom.iconSize ?? this.DEFAULT_ICON_SIZE)
      }
    }
    .size(this.tagItem.tagStyle?.itemSize ?? this.style?.itemSize)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .border(this.getBorder())
    .backgroundColor(this.getBgColor())
    .onClick(() => {
      if (!this.selectable) {
        return
      }
      this.tagItem.isSelected = !this.tagItem.isSelected
      if (this.onItemClick) {
        this.onItemClick(this.tagItem, this.index)
      }
    })
    .padding(this.tagItem.tagStyle?.itemPadding ?? this.style?.itemPadding)
  }

  private getFontWeight() {
    return this.tagItem.isSelected && this.isSelectedBold ? FontWeight.Bold : FontWeight.Normal
  }

  private getFontSize() {
    return this.tagItem.isSelected ?
      this.tagItem?.tagStyle?.selectedFontSize ?? this.style?.selectedFontSize ??
        this.tagItem.tagStyle?.fontSize ?? this.style?.fontSize :
      this.tagItem.tagStyle?.fontSize ?? this.style?.fontSize
  }

  private getFontColor() {
    return this.tagItem.isSelected ?
      this.tagItem?.tagStyle?.selectedFontColor ?? this.style?.selectedFontColor ??
        this.tagItem.tagStyle?.fontColor ?? this.style?.fontColor :
      this.tagItem.tagStyle?.fontColor ?? this.style?.fontColor
  }

  private getBorder() {
    return this.tagItem.isSelected ?
      this.tagItem.tagStyle?.selectedItemBorder ?? this.style?.selectedItemBorder ??
        this.tagItem.tagStyle?.itemBorder ?? this.style?.itemBorder :
      this.tagItem.tagStyle?.itemBorder ?? this.style?.itemBorder
  }

  private getBgColor() {
    return this.tagItem.isSelected ?
      this.tagItem?.tagStyle?.selectedBackgroundColor ?? this.style?.selectedBackgroundColor ??
        this.tagItem.tagStyle?.backgroundColor ?? this.style?.backgroundColor :
      this.tagItem.tagStyle?.backgroundColor ?? this.style?.backgroundColor
  }
}