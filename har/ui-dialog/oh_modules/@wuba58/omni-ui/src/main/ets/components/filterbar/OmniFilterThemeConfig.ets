import { OmniResourceColor } from "../../theme/OmniTheme"

export interface OmniFilterStyle {
  menuStyle?: OmniFilterMenuStyle
  gridStyle?: OmniFilterGridStyle
  listStyle?: OmniFilterListStyle
  bottomPanelStyle?: OmniFilterBottomPanelStyle
}

export interface OmniFilterMenuStyle {
  menuTextStyle?: OmniFilterTextStyle //菜单文字常规样式
  menuSelectedTextStyle?: OmniFilterTextStyle //菜单文字选中样式
}

export interface OmniFilterListStyle {
  maxHeight?:number
  itemTextStyle?: OmniFilterTextStyle; // 列表文字常规样式
  itemSelectedTextStyle?: OmniFilterTextStyle; // 列表文字选中样式
  itemMultiSelectIconUnselected?: OmniFilterIcon //多选icon
  itemMultiSelectIconSelected?: OmniFilterIcon //多选icon（选中）
}

export interface OmniFilterGridStyle {
  maxHeight?:number
  rowCount?:number//每行个数
  titleTextStyle?: OmniFilterTextStyle //网格标题样式
  itemTextStyle?: OmniFilterTextStyle //网格文字常规样式
  itemSelectedTextStyle?: OmniFilterTextStyle //网格文字选中样式
  itemBgColor?: OmniResourceColor //item背景色
  itemSelectedBgColor?: OmniResourceColor //item背景色（选中）
}

export interface OmniFilterBottomPanelStyle {
  resetText?:string
  resetTextStyle?: OmniFilterTextStyle //重置文字样式
  resetIcon?: OmniFilterIcon //重置图标
  confirmText?:string
  confirmTextStyle?: OmniFilterTextStyle //确定文字样式
  confirmButtonColor?: OmniResourceColor //确定按钮颜色
}

export declare type OmniFilterIcon = PixelMap | ResourceStr | DrawableDescriptor | ImageContent

export interface OmniFilterTextStyle {
  fontColor?: OmniResourceColor //文字颜色
  fontSize?: number | string | Resource //文字大小
  fontWeight?: number | FontWeight | string //文字粗细
}
