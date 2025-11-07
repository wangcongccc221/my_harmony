export interface TagItemInfoParams {
  title?: string
  icons?: IconInfo
  tagStyle?: TagStyle
  isSelected?: boolean
}

@Observed
export class TagItemInfo {
  title?: string
  icons?: IconInfo
  tagStyle?: TagStyle
  isSelected: boolean

  constructor(params: TagItemInfoParams) {
    this.title = params.title
    this.icons = params.icons
    this.tagStyle = params.tagStyle
    this.isSelected = params.isSelected ?? false
  }
}

export interface IconInfo {
  top?: IconItemInfo,
  bottom?: IconItemInfo,
  left?: IconItemInfo,
  right?: IconItemInfo
}

export interface IconItemInfo {
  icon?: PixelMap | ResourceStr | DrawableDescriptor
  iconSize?: SizeOptions
}

export interface TagStyle {
  textMargin?: Margin | Length | LocalizedMargin
  fontSize?: string | number | Resource
  fontColor?: ResourceColor
  backgroundColor?: ResourceColor
  selectedFontSize?: string | number | Resource
  selectedBackgroundColor?: ResourceColor
  selectedFontColor?: ResourceColor
  itemBorder?: BorderOptions
  selectedItemBorder?: BorderOptions
  itemPadding?: Padding | Length | LocalizedPadding
  itemSize?: SizeOptions
}

export enum TagMode {
  HORIZONTAL_SCROLL,
  FLEX
}