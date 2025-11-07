import { Config } from './Config';
import { PopupConfig } from './PopupConfig';
import { display, promptAction } from '@kit.ArkUI';
import { PopupManager } from './PopupManager';
import { PopupCallback } from './PopupCallback';
import { PopupType } from './PopupType';
import { List } from '@kit.ArkTS';

export abstract class BasePopup<T extends object> {
  /**
   * 弹窗设置
   */
  protected popupConfig: PopupConfig = Config.getPopupConfig()
  /**
   * 弹窗配置
   */
  protected dialogOptions: promptAction.BaseDialogOptions = Config.getDialogOptions()
  /**
   * 自定义Builder
   */
  private customBuilder?: WrappedBuilder<T[]>
  /**
   * 参数
   */
  private args?: T
  /**
   * 弹窗管理
   */
  private popupManager: PopupManager = new PopupManager()
  /**
   * 界面回调
   */
  protected popupCallback?: PopupCallback
  /**
   * 自定义弹窗类型
   */
  protected popupType: PopupType = PopupType.BUBBLE
  /**
   * 屏幕宽
   */
  protected readonly screenWidth: number = display.getDefaultDisplaySync().width
  /**
   * 屏幕高
   */
  protected readonly screenHeight: number = display.getDefaultDisplaySync().height
  /**
   * 依附View的ID
   */
  protected attachViewId?: string
  /**
   * 存储弹窗
   */
  private static popupList: List<BasePopup<ESObject>> = new List()

  constructor(customBuilder: WrappedBuilder<T[]>) {
    this.customBuilder = customBuilder
  }

  /**
   * 设置布局
   * @param wrappedBuilder
   */
  protected setWrappedBuilder(wrappedBuilder: WrappedBuilder<T[]>) {
    this.customBuilder = wrappedBuilder
  }


  /**
   * 设置弹窗配置
   * @param dialogOptions
   */
  setDialogOptions(dialogOptions: promptAction.BaseDialogOptions) {
    this.dialogOptions = dialogOptions
  }

  /**
   * 参数，可以不返回
   * @returns
   */
  setParams(params: T | undefined) {
    this.args = params
  }

  /**
   * 设置弹窗配置
   * @param popupConfig
   */
  setPopupConfig(popupConfig: PopupConfig) {
    this.popupConfig = popupConfig
  }

  /**
   * 设置回调
   * @param popupCallback
   */
  setPopupCallback(popupCallback?: PopupCallback) {
    this.popupCallback = popupCallback
  }

  /**
   * 依附View的ID
   * @param attachViewId
   */
  setAttachViewId(attachViewId?: string): BasePopup<T> {
    this.attachViewId = attachViewId
    return this
  }

  /**
   * Popup显示之前，可做一些数据处理
   */
  beforeShow() {

  }

  /**
   * 显示弹窗
   * @returns
   */
  show(): BasePopup<T> {
    if (this.customBuilder != null) {
      //设置弹窗宽度
      this.popupConfig.width = this.popupConfig.width ?? this.popupWidth()
      //设置弹窗高度
      this.popupConfig.height = this.popupConfig.height ?? this.popupHeight()
      //设置弹窗最大宽度
      this.popupConfig.maxWidth = this.popupConfig.maxWidth ?? this.popupMaxWidth()
      //设置弹窗最大高度
      this.popupConfig.maxHeight = this.popupConfig.maxHeight ?? this.popupMaxHeight()
      //设置圆角
      this.popupConfig.borderRadius = this.popupConfig.borderRadius ?? this.borderRadius()
      this.beforeShow()
      //处理关闭
      if (this.dialogOptions.onWillDismiss == null) {
        this.dialogOptions.onWillDismiss = this._onWillDismiss
      }
      this.popupManager.popupType = this.popupType
      if (this.popupConfig.wrap) {
        this.popupManager.wrapShow(this.dialogOptions, this.popupConfig, this.customBuilder, this.args)
      } else {
        this.popupManager.show(this.dialogOptions, this.customBuilder, this.args)
      }
    }
    BasePopup.popupList.add(this)
    return this
  }

  /**
   * Popup隐藏之前，可做一些数据处理
   */
  beforeDismiss() {

  }

  /**
   * 隐藏弹窗
   * @returns
   */
  dismiss(): BasePopup<T> {
    if (this.popupManager != null) {
      this.beforeDismiss()
      this.popupManager.dismiss()
    }
    BasePopup.popupList.remove(this)
    return this
  }

  /**
   * 隐藏全部弹窗
   */
  static dismissAll() {
    if (BasePopup.popupList != null) {
      BasePopup.popupList.forEach((popup: BasePopup<ESObject>) => {
        popup.dismiss()
      })
    }
  }

  /**
   * 关闭最上层弹窗
   */
  static dismissTop() {
    if (BasePopup.popupList != null && BasePopup.popupList.length > 0) {
      let size: number = BasePopup.popupList.length
      let lastPopup: BasePopup<ESObject> = BasePopup.popupList.get(size - 1)
      lastPopup.dismiss()
    }
  }

  /**
   * 延时隐藏弹窗
   * @param delay 时间，毫秒,默认300ms
   * @returns
   */
  dismissDelay(delay: number = 300): BasePopup<T> {
    setTimeout(() => {
      this.dismiss()
    }, delay)
    return this
  }

  /**
   * 弹窗宽度
   * @returns
   */
  popupWidth(): Length | undefined {
    return undefined
  }

  /**
   * 弹窗高度
   * @returns
   */
  popupHeight(): Length | undefined {
    return undefined
  }

  /**
   * 弹窗最大宽度
   * @returns
   */
  popupMaxWidth(): Length | undefined {
    return undefined
  }

  /**
   * 弹窗最大高度
   * @returns
   */
  popupMaxHeight(): Length | undefined {
    return undefined
  }

  /**
   * 设置圆角
   * @returns
   */
  borderRadius(): Length | BorderRadiuses | LocalizedBorderRadiuses | undefined {
    return undefined
  }

  /**
   * 处理即将关闭
   */
  private _onWillDismiss = (data: DismissDialogAction) => {
    if (data.reason == DismissReason.PRESS_BACK && !this.popupConfig.dismissOnBackPressed) {
      //禁止关闭
    } else {
      data.dismiss()
    }
  }

  /**
   * 处理圆角
   * @param isBottom 是否处理底部
   */
  protected handlePopupRadius(isBottom: boolean) {
    let typeStr = typeof this.popupConfig.borderRadius
    if (typeStr == "object") {
      try {
        let radius = this.popupConfig.borderRadius as BorderRadiuses
        if (isBottom) {
          radius.bottomLeft = 0
          radius.bottomRight = 0
        } else {
          radius.topLeft = 0
          radius.topRight = 0
        }
      } catch (e) {
        let radius = this.popupConfig.borderRadius as LocalizedBorderRadiuses
        if (isBottom) {
          radius.bottomStart = undefined
          radius.bottomEnd = undefined
        } else {
          radius.topStart = undefined
          radius.topEnd = undefined
        }
      }
    } else {
      let radius = this.popupConfig.borderRadius as Length
      if (isBottom) {
        this.popupConfig.borderRadius = {
          topLeft: radius,
          topRight: radius
        }
      } else {
        this.popupConfig.borderRadius = {
          bottomLeft: radius,
          bottomRight: radius
        }
      }

    }
  }
}