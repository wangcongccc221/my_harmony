import { Config } from './Config'
import { PopupInfo } from './entity/PopupInfo'
import { Builder } from './Builder'
import { BasePopup } from './BasePopup'

export class OmniPopup {
  private constructor() {
  }

  /**
   * 全局设置 - 弹窗
   * @param options
   */
  static setPopupOptions(options: PopupInfo) {
    Config.popupOptions = options
  }

  /**
   * 全局设置-设置弹窗背景
   * @param color
   */
  static setBackgroundColor(color: ResourceColor) {
    Config.popupConfig.backgroundColor = color
  }

  /**
   * 全局设置-圆角
   * @param borderRadius
   */
  static setBorderRadius(borderRadius: Length | BorderRadiuses | LocalizedBorderRadiuses) {
    Config.popupConfig.borderRadius = borderRadius
  }

  /**
   * 全局设置-弹窗内边距
   * @param popupPadding
   */
  static setPopupPadding(popupPadding: Padding | Length | LocalizedPadding) {
    Config.popupConfig.popupPadding = popupPadding
  }

  /**
   * 全局设置-主要颜色
   * @param primaryColor
   */
  static setPrimaryColor(primaryColor: ResourceColor) {
    Config.popupConfig.primaryColor = primaryColor
  }

  /**
   * 全局设置-操作完成后是否自动关闭弹窗,默认true,比如点击ConfirmPopup的确认按钮，默认自动关闭；如果为false，则不会关闭
   * @param autoDismiss
   */
  static setAutoDismiss(autoDismiss: boolean) {
    Config.popupConfig.autoDismiss = autoDismiss
  }

  /**
   * 全局设置-设置遮罩层颜色
   * @param maskColor
   * @returns
   */
  static setMaskColor(maskColor?: ResourceColor) {
    Config.dialogOptions.maskColor = maskColor
  }

  /**
   * 全局设置-模态对话框
   * @param isModal
   * @returns
   */
  static setModal(isModal: boolean) {
    Config.dialogOptions.isModal = isModal
  }

  /**
   * 全局设置-是否在子窗口中显示
   * @param showInSubWindow
   * @returns
   */
  static setInSubWindow(showInSubWindow: boolean) {
    Config.dialogOptions.showInSubWindow = showInSubWindow
  }

  /**
   * 全局设置-允许用户单击遮罩层退出
   * @param dismiss
   * @returns
   */
  static setDismissOnTouchOutside(dismiss: boolean) {
    Config.dialogOptions.autoCancel = dismiss
  }

  /**
   * 全局设置-设置是否支持按返回键关闭弹窗
   * @param dismiss
   * @returns
   */
  static setDismissOnBackPressed(dismiss: boolean) {
    Config.dismissOnBackPressed = dismiss
  }

  /**
   * 全局设置-自定义组件时，是否NodeContainer包裹
   * @param wrap true:参数可统一设置，比如弹窗圆角、内边距等;
   *             false:所有内容都需要自己在使用地方配置，比如圆角，内边距等
   */
  static setWrap(wrap: boolean) {
    Config.wrap = wrap
  }

  /**
   * 隐藏全部弹窗
   */
  static dismissAll() {
    BasePopup.dismissAll()
  }

  /**
   * 关闭最上层弹窗
   */
  static dismissTop() {
    BasePopup.dismissTop()
  }

  static Builder(): Builder {
    return new Builder()
  }
}