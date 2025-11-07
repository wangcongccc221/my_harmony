import { PopupPosition } from './PopupPosition'
import { componentUtils } from '@kit.ArkUI'
import { ArrowLocation } from './ArrowLocation'

export class PopupConfig {
  /**
   * 弹窗宽度，仅限于wrap=true，底部和顶部弹窗默认 100% ，中间弹窗默认90%
   */
  width?: Length
  /**
   * 弹窗高度，仅限于wrap = true，默认50%
   */
  height?: Length
  /**
   * 弹窗最大宽度，仅限于wrap=true
   */
  maxWidth?: Length
  /**
   * 弹窗最小宽度，仅限于wrap=true
   */
  minWidth?: Length
  /**
   * 弹窗最大高度，仅限于wrap=true
   */
  maxHeight?: Length
  /**
   * 弹窗最小高度，仅限于wrap=true
   */
  minHeight?: Length
  /**
   * 背景颜色
   */
  backgroundColor: ResourceColor = Color.White
  /**
   * 圆角
   */
  borderRadius: Length | BorderRadiuses | LocalizedBorderRadiuses = 16
  /**
   * Popup弹窗内边距
   */
  popupPadding: Padding | Length | LocalizedPadding = 20
  /**
   * 主要颜色
   */
  primaryColor?: ResourceColor
  /**
   * 侧滑关闭
   */
  dismissOnBackPressed: boolean = true
  /**
   * 自定义组件时，是否NodeContainer包裹，wrap=true:参数可统一设置，比如弹窗圆角、内边距等;wrap=false:所有内容都需要自己在使用地方配置，比如圆角，内边距等
   */
  wrap: boolean = true
  /**
   * 操作完成后是否自动关闭弹窗,默认true,比如点击ConfirmPopup的确认按钮，默认自动关闭；如果为false，则不会关闭
   */
  autoDismiss: boolean = true
  /**
   * 弹窗位置
   */
  popupPosition?: PopupPosition
  /**
   * 依赖View型数据
   */
  attachViewComponentInfo?: componentUtils.ComponentInfo
  /**
   * 依附弹窗是否对组件居中
   */
  isAttachCenter:boolean = true
  /**
   * 依附组件距离指定组件的距离，默认为0
   */
  attachMargin: number = 0
  /**
   * 气泡弹窗，箭头偏移，单位vp
   */
  arrowOffset: number = 0
  /**
   * 气泡弹窗，箭头是否居中
   */
  isArrowPositionCenter: boolean = true
  /**
   * 阴影颜色
   */
  shadowColor: string = "#FF444444"
  /**
   * 阴影半径，单位：vp
   */
  shadowRadius?: number
  /**
   * 阴影X轴，单位：vp
   */
  shadowX: number = 0
  /**
   * 阴影Y轴，单位：vp
   */
  shadowY: number = 0
  /**
   * 气泡弹窗，箭头尖左边弧度，单位：vp
   */
  arrowTopLeftRadius: number = 2
  /**
   * 气泡弹窗，箭头尖右边弧度，单位：vp
   */
  arrowTopRightRadius: number = 2
  /**
   * 气泡弹窗，箭头底部左边弧度，单位：vp
   */
  arrowDownLeftRadius: number = 2
  /**
   * 气泡弹窗，箭头底部右边弧度，单位：vp
   */
  arrowDownRightRadius: number = 2
  /**
   * 气泡弹窗，箭头宽度，单位：vp
   */
  arrowWidth: number = 20
  /**
   * 气泡弹窗，箭头高度，单位：vp
   */
  arrowHeight: number = 8
  /**
   * 气泡弹窗，箭头的位置，默认顶部
   */
  arrowLocation: ArrowLocation = ArrowLocation.TOP
  /**
   * 边框颜色
   */
  borderColor: number = Color.Transparent
  /**
   * 边框大小，单位：vp
   */
  borderSize: number = 0
}