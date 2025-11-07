import { promptAction } from '@kit.ArkUI'
import { Config } from './Config'
import { PopupConfig } from './PopupConfig'
import { PopupInfo } from './entity/PopupInfo'
import { PopupCallback } from './PopupCallback'
import { PopupPosition } from './PopupPosition'
import { BasePopup } from './BasePopup'
import { BubblePopup } from './BubblePopup'

export class Builder {
  /**
   * 弹窗配置
   */
  private dialogOptions: promptAction.BaseDialogOptions = Config.getDialogOptions()
  /**
   * 弹窗设置
   */
  private popupConfig: PopupConfig = Config.getPopupConfig()
  /**
   * 获取弹窗内数据设置
   */
  private popupOptions: PopupInfo = Config.getPopupOptions()
  /**
   * 弹窗回调
   */
  private popupCallback?: PopupCallback
  /**
   * 依附View的ID
   */
  private attachViewId?: string

  /**
   * 设置配置
   * @param config 设置配置
   * @returns
   */
  setDialogOptions(config: promptAction.BaseDialogOptions): Builder {
    this.dialogOptions = config
    return this
  }

  /**
   * 弹窗遮蔽层区域，在遮蔽层区域内的事件不透传，在遮蔽层区域外的事件透传。大小不能超过主窗口
   * @param maskRect
   * @returns
   */
  setMaskRect(maskRect?: Rectangle): Builder {
    this.dialogOptions.maskRect = maskRect
    return this
  }

  /**
   * 弹窗在竖直方向上的对齐方式
   * @param alignment
   * @returns
   */
  setAlignment(alignment?: DialogAlignment): Builder {
    this.dialogOptions.alignment = alignment
    return this
  }

  /**
   * 弹窗相对alignment所在位置的偏移量
   * @param offset
   * @returns
   */
  setOffset(offset?: Offset): Builder {
    this.dialogOptions.offset = offset
    return this
  }

  /**
   * 是否在子窗口中显示
   * @param showInSubWindow
   * @returns
   */
  setInSubWindow(showInSubWindow: boolean): Builder {
    this.dialogOptions.showInSubWindow = showInSubWindow
    return this
  }

  /**
   * 模态对话框
   * @param isModal
   * @returns
   */
  setModal(isModal: boolean): Builder {
    this.dialogOptions.isModal = isModal
    return this
  }

  /**
   * 允许用户单击遮罩层退出
   * @param dismiss
   * @returns
   */
  setDismissOnTouchOutside(dismiss: boolean): Builder {
    this.dialogOptions.autoCancel = dismiss
    return this
  }

  /**
   * 打开/关闭自定义对话框的动画参数
   * @param transition
   * @returns
   */
  setTransition(transition?: TransitionEffect): Builder {
    this.dialogOptions.transition = transition
    return this
  }

  /**
   * 设置遮罩层颜色
   * @param maskColor
   * @returns
   */
  setMaskColor(maskColor?: ResourceColor): Builder {
    this.dialogOptions.maskColor = maskColor
    return this
  }

  /**
   * 设置弹窗回调
   * @param callback
   * @returns
   */
  setPopupCallback(callback: PopupCallback): Builder {
    this.popupCallback = callback
    this.dialogOptions.onWillDismiss = callback.onBackPressed
    this.dialogOptions.onWillAppear = callback.beforeShow
    this.dialogOptions.onWillDisappear = callback.beforeDismiss
    this.dialogOptions.onDidAppear = callback.onShow
    this.dialogOptions.onDidDisappear = callback.onDismiss
    return this
  }

  /**
   * 弹窗宽度，仅限于wrap=true，底部和顶部弹窗默认 100% ，中间弹窗默认90%
   */
  setWidth(width: Length): Builder {
    this.popupConfig.width = width
    return this
  }

  /**
   * 弹窗高度，仅限于wrap = true，默认50%
   */
  setHeight(height: Length): Builder {
    this.popupConfig.height = height
    return this
  }

  /**
   * 弹窗最大宽度，仅限于wrap=true
   */
  setMaxWidth(maxWidth: Length): Builder {
    this.popupConfig.maxWidth = maxWidth
    return this
  }

  /**
   * 弹窗最小宽度，仅限于wrap=true
   */
  setMinWidth(minWidth: Length): Builder {
    this.popupConfig.minWidth = minWidth
    return this
  }

  /**
   * 弹窗最大高度，仅限于wrap=true
   */
  setMaxHeight(maxHeight: Length): Builder {
    this.popupConfig.maxHeight = maxHeight
    return this
  }

  /**
   * 弹窗最小高度，仅限于wrap=true
   */
  setMinHeight(minHeight: Length): Builder {
    this.popupConfig.minHeight = minHeight
    return this
  }

  /**
   * 背景颜色,默认Color.White
   */
  setBackgroundColor(backgroundColor: ResourceColor): Builder {
    this.popupConfig.backgroundColor = backgroundColor
    return this
  }

  /**
   * 圆角,默认16vp
   */
  setBorderRadius(borderRadius: Length | BorderRadiuses | LocalizedBorderRadiuses): Builder {
    this.popupConfig.borderRadius = borderRadius
    return this
  }

  /**
   * Popup弹窗内边距,默认值20vp
   */
  setPopupPadding(popupPadding: Padding | Length | LocalizedPadding): Builder {
    this.popupConfig.popupPadding = popupPadding
    return this
  }

  /**
   * 主要颜色
   */
  setpPrimaryColor(primaryColor: ResourceColor): Builder {
    this.popupConfig.primaryColor = primaryColor
    return this
  }

  /**
   * 操作完成后是否自动关闭弹窗,默认true,比如点击ConfirmPopup的确认按钮，默认自动关闭；如果为false，则不会关闭
   * @param autoDismiss
   */
  setAutoDismiss(autoDismiss: boolean): Builder {
    this.popupConfig.autoDismiss = autoDismiss
    return this
  }

  /**
   * 手动指定弹窗位置，只有Attach、Drawer、PartShadow类型有效，PartShadow类型只支持上下
   * @param popupPosition
   * @returns
   */
  setPopupPosition(popupPosition: PopupPosition): Builder {
    this.popupConfig.popupPosition = popupPosition
    return this
  }

  /**
   * 设置是否支持按返回键关闭弹窗
   * @param dismiss
   * @returns
   */
  setDismissOnBackPressed(dismiss: boolean): Builder {
    this.popupConfig.dismissOnBackPressed = dismiss
    return this
  }

  /**
   * 自定义组件时，是否NodeContainer包裹
   * @param wrap true:参数可统一设置，比如弹窗圆角、内边距等;
   *             false:所有内容都需要自己在使用地方配置，比如圆角，内边距等
   */
  setWrap(wrap: boolean): Builder {
    this.popupConfig.wrap = wrap
    return this
  }

  /**
   * 设置依附组件、气泡组件与原始点击组件的相对居中
   * @param attachMargin
   * @returns
   */
  setAttachCenter(isAttachCenter: boolean): Builder {
    this.popupConfig.isAttachCenter = isAttachCenter
    return this
  }

  /**
   * 设置依附组件、气泡组件距离原始点击组件的距离
   * @param attachMargin
   * @returns
   */
  setAttachMargin(attachMargin: number): Builder {
    this.popupConfig.attachMargin = attachMargin
    return this
  }

  /**
   * 设置箭头偏移量，气泡弹窗有效
   * @param arrowOffset
   * @returns
   */
  setArrowOffset(arrowOffset: number): Builder {
    this.popupConfig.arrowOffset = arrowOffset
    return this
  }

  /**
   * 设置箭头是否居中，气泡弹窗有效
   * @param isArrowPositionCenter
   * @returns
   */
  setArrowPositionCenter(isArrowPositionCenter: boolean): Builder {
    this.popupConfig.isArrowPositionCenter = isArrowPositionCenter
    return this
  }

  /**
   * 设置阴影颜色
   * @param shadowColor
   * @returns
   */
  setShadowColor(shadowColor: string): Builder {
    this.popupConfig.shadowColor = shadowColor
    return this
  }

  /**
   * 设置阴影半径，单位：vp
   * @param shadowRadius
   * @returns
   */
  setShadowRadius(shadowRadius: number): Builder {
    this.popupConfig.shadowRadius = shadowRadius
    return this
  }

  /**
   * 阴影X轴，单位：vp
   * @param shadowX
   * @returns
   */
  setShadowX(shadowX: number): Builder {
    this.popupConfig.shadowX = shadowX
    return this
  }

  /**
   * 阴影Y轴，单位：vp
   * @param shadowY
   * @returns
   */
  setShadowY(shadowY: number): Builder {
    this.popupConfig.shadowY = shadowY
    return this
  }

  /**
   * 箭头尖左边弧度，单位：vp，气泡弹窗有效
   * @param arrowTopLeftRadius
   * @returns
   */
  setArrowTopLeftRadius(arrowTopLeftRadius: number): Builder {
    this.popupConfig.arrowTopLeftRadius = arrowTopLeftRadius
    return this
  }

  /**
   * 箭头尖右边弧度，单位：vp ，气泡弹窗有效
   * @param arrowTopRightRadius
   * @returns
   */
  setArrowTopRightRadius(arrowTopRightRadius: number): Builder {
    this.popupConfig.arrowTopRightRadius = arrowTopRightRadius
    return this
  }

  /**
   * 箭头底部左边弧度，单位：vp，气泡弹窗有效
   * @param arrowDownLeftRadius
   * @returns
   */
  setArrowDownLeftRadius(arrowDownLeftRadius: number): Builder {
    this.popupConfig.arrowDownLeftRadius = arrowDownLeftRadius
    return this
  }

  /**
   * 箭头底部右边弧度，单位：vp，气泡弹窗有效
   * @param arrowDownRightRadius
   * @returns
   */
  setArrowDownRightRadius(arrowDownRightRadius: number): Builder {
    this.popupConfig.arrowDownRightRadius = arrowDownRightRadius
    return this
  }

  /**
   * 箭头宽度，单位：vp，气泡弹窗有效
   * @param arrowWidth
   * @returns
   */
  setArrowWidth(arrowWidth: number): Builder {
    this.popupConfig.arrowWidth = arrowWidth
    return this
  }

  /**
   * 箭头高度，单位：vp，气泡弹窗有效
   * @param arrowHeight
   * @returns
   */
  setArrowHeight(arrowHeight: number): Builder {
    this.popupConfig.arrowHeight = arrowHeight
    return this
  }


  /**
   * 边框颜色
   * @param borderColor
   * @returns
   */
  setBorderColor(borderColor: number): Builder {
    this.popupConfig.borderColor = borderColor
    return this
  }

  /**
   * 边框大小，单位：vp
   * @param borderSize
   * @returns
   */
  setBorderSize(borderSize: number): Builder {
    this.popupConfig.borderSize = borderSize
    return this
  }

  /**
   * 设置Loading文字颜色
   * @param color
   */
  setHintFontColor(color?: ResourceColor): Builder {
    this.popupOptions.hintFontColor = color
    return this
  }

  /**
   * 设置Loading文字大小
   * @param size
   */
  setHintFontSize(size?: number | string | Resource): Builder {
    this.popupOptions.hintFontSize = size
    return this
  }

  /**
   * 标题大小
   * @param titleFontSize
   * @returns
   */
  setTitleFontSize(titleFontSize?: number | string | Resource): Builder {
    this.popupOptions.titleFontSize = titleFontSize
    return this
  }

  /**
   * 标题颜色
   * @param titleFontColor
   * @returns
   */
  setTitleFontColor(titleFontColor?: ResourceColor): Builder {
    this.popupOptions.titleFontColor = titleFontColor
    return this
  }

  /**
   * 标题Weight
   * @param titleFontWeight
   * @returns
   */
  setTitleFontWeight(titleFontWeight?: number | FontWeight | string): Builder {
    this.popupOptions.titleFontWeight = titleFontWeight
    return this
  }

  /**
   * 内容大小,列表时，列表项文字大小
   * @param textFontSize
   * @returns
   */
  setTextFontSize(textFontSize?: number | string | Resource): Builder {
    this.popupOptions.textFontSize = textFontSize
    return this
  }

  /**
   * 内容颜色，列表时，列表项文字颜色
   * @param textFontColor
   * @returns
   */
  setTextFontColor(textFontColor?: ResourceColor): Builder {
    this.popupOptions.textFontColor = textFontColor
    return this
  }

  /**
   * 内容Weight，列表时，列表项文字Weight
   * @param textFontWeight
   * @returns
   */
  setTextFontWeight(textFontWeight?: number | FontWeight | string): Builder {
    this.popupOptions.textFontWeight = textFontWeight
    return this
  }

  /**
   * 文本对齐方式，列表时，列表项文字对齐方式
   */
  setTextTextAlign(textTextAlign?: TextAlign): Builder {
    this.popupOptions.textTextAlign = textTextAlign
    return this
  }

  /**
   * 按钮间间距
   * @param buttonSpace
   * @returns
   */
  setButtonSpace(buttonSpace?: string | number | undefined): Builder {
    this.popupOptions.buttonSpace = buttonSpace
    return this
  }


  /**
   * 依附组件ID
   * @param id
   * @returns
   */
  atView(id: string): Builder {
    this.attachViewId = id
    return this
  }

  /**
   * 自定义视图
   * @param popup
   * @returns
   */
  asCustomPopup<P extends BasePopup<ESObject>>(popup: P): P {
    popup.setAttachViewId(this.attachViewId)
    popup.setDialogOptions(this.dialogOptions)
    popup.setPopupConfig(this.popupConfig)
    popup.setPopupCallback(this.popupCallback)
    return popup
  }

  /**
   * 气泡弹窗
   * @param customBuilder
   * @param args
   * @returns
   */
  asBubble<T extends object>(customBuilder: WrappedBuilder<T[]>, args?: T): BubblePopup<T> {
    let popup = new BubblePopup<T>(customBuilder)
    popup.setAttachViewId(this.attachViewId)
    popup.setDialogOptions(this.dialogOptions)
    popup.setParams(args)
    popup.setPopupConfig(this.popupConfig)
    popup.setPopupCallback(this.popupCallback)
    return popup
  }
}