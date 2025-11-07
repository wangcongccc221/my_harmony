/*
 * 主题设置
 * */
class ToastTheme {
  // 文本颜色 默认白色
  textColor?: ResourceColor
  // 文本大小
  fontSize?: number | string | Resource
  // 背景颜色
  backgroundColor?: ResourceColor
  // 边框圆角
  borderRadius?: Dimension | BorderRadiuses
  // 边框宽度
  borderWidth?: Dimension | EdgeWidths
  // 边框颜色
  borderColor?: ResourceColor | EdgeColors
  // 边框样式
  borderStyle?: BorderStyle | EdgeStyles
  // 背板模糊材质。
  backgroundBlurStyle?: BlurStyle
  // 设置背板的阴影。
  shadow?: ShadowOptions | ShadowStyle
  // toast的宽度
  width?: Dimension
  // toast的高度
  height?: Dimension
  // 图标的宽度，未设置图标不生效
  iconWidth?: Dimension
  // 图标的高度，未设置图标不生效
  iconHeight?: Dimension
}

/*
 * wrap builder args
 * */
interface ToastWrapBuilderArgs {
  msg?: string
  duration: number
  icon?: PixelMap | ResourceStr | DrawableDescriptor | ImageContent
  theme?: ToastTheme
}

export { ToastTheme, ToastWrapBuilderArgs, }