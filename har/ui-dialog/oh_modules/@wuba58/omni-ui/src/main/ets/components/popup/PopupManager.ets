import { ComponentContent, promptAction, PromptAction, window } from '@kit.ArkUI';
import { bubblePopupBuilder } from './CustomBuilder';
import { PopupBean } from './entity/PopupBean';
import { PopupConfig } from './PopupConfig';
import { CustomNodeController } from './CustomNodeController';
import { PopupType } from './PopupType';

/**
 * 弹窗管理
 */
export class PopupManager {
  private popup?: ComponentContent<object>
  private promptAction?: PromptAction
  /**
   * 自定义节点控制器
   */
  private customNodeController?: CustomNodeController<ESObject>
  /**
   * 自定义弹窗类型
   */
  popupType: PopupType = PopupType.BUBBLE

  /**
   * 完全自定义显示，没有外层包裹
   * @param config
   * @param wrapBuilder
   * @param args
   */
  async show<T extends object>(config: promptAction.BaseDialogOptions, builder: WrappedBuilder<T[]>, args?: T) {
    try {
      const windowClass = await window.getLastWindow(getContext())
      const uiContext = windowClass.getUIContext()
      if (args) {
        this.popup = new ComponentContent(uiContext, builder, args)
      } else {
        this.popup = new ComponentContent(uiContext, builder as WrappedBuilder<[]>)
      }
      this.promptAction = uiContext.getPromptAction()
      this.promptAction.openCustomDialog(this.popup, config)
    } catch (e) {
      console.error(JSON.stringify(e))
    }
  }


  /**
   * 自定义显示,有外层包裹，可控制总体圆角等参数
   * @param config
   * @param popupConfig
   * @param builder
   * @param args
   */
  async wrapShow<T extends object>(config: promptAction.BaseDialogOptions, popupConfig: PopupConfig,
    builder: WrappedBuilder<T[]>, args?: T) {
    try {
      const windowClass = await window.getLastWindow(getContext())
      const uiContext = windowClass.getUIContext()
      let bean = new PopupBean(new CustomNodeController(builder, args), popupConfig)
      this.customNodeController = bean.customNodeController
      bean.maskColor = config.maskColor
      bean.onDismiss = () => {
        this.dismiss()
      }

      bean.popupType = this.popupType
      if (this.popupType == PopupType.BUBBLE) {
        this.popup = new ComponentContent(uiContext, wrapBuilder(bubblePopupBuilder), bean)
      }
      this.promptAction = uiContext.getPromptAction()
      this.promptAction.openCustomDialog(this.popup, config)
    } catch (e) {
      console.error(JSON.stringify(e))
    }
  }


  /**
   * 关闭弹窗
   */
  async dismiss() {
    try {
      const windowClass = await window.getLastWindow(getContext())
      this.promptAction?.closeCustomDialog(this.popup)
      if (this.customNodeController != null) {
        this.customNodeController.dispose()
        this.customNodeController = undefined
      }
    } catch (e) {
      console.error(JSON.stringify(e))
    }
  }
}