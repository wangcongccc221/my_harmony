import { ComponentContent } from '@kit.ArkUI'
import { imageTextContentBuilder } from './OmniToastBuilders'
import { ToastWrapBuilderArgs, ToastTheme } from './OmniToastTheme'

export interface ToastOptions {
  msg?: string,
  duration?: number,
  icon?: PixelMap | ResourceStr | DrawableDescriptor | ImageContent,
  alignment?: DialogAlignment,
  offset?: Offset
  onDismiss?: (() => void)
  theme?: ToastTheme
}

export class OmniToast {
  private static uiContext: UIContext
  private static globalTheme: ToastTheme

  /*
   * 初始化
   * @param uiContext
   * */
  public static initToast(uiContext: UIContext) {
    OmniToast.uiContext = uiContext
  }

  /*
   * 设置全局 toast 主题
   * @param theme
   * */
  public static setTheme(theme: ToastTheme) {
    OmniToast.globalTheme = theme;
  }

  /*
   * 显示文本
   * @param options
   * */
  public static showText(options: ToastOptions) {
    OmniToast.handleShowToast(options)
  }

  /*
   * 成功提示
   * @param options
   * */
  public static showSuccess(options?: ToastOptions) {
    if (options) {
      const op = options
      op.icon = $r('app.media.success')
      OmniToast.handleShowToast(op)
    } else {
      OmniToast.handleShowToast({ icon: $r('app.media.success') })
    }
  }

  /*
   * 失败提示
   * @param options
   * */
  public static showError(options?: ToastOptions) {
    if (options) {
      const op = options
      op.icon = $r('app.media.error')
      OmniToast.handleShowToast(op)
    } else {
      OmniToast.handleShowToast({ icon: $r('app.media.error') })
    }
  }

  /**
   * 警告提示
   * @param options
   */
  public static showWarning(options?: ToastOptions) {
    if (options) {
      const op = options
      op.icon = $r('app.media.warning')
      OmniToast.handleShowToast(op)
    } else {
      OmniToast.handleShowToast({ icon: $r('app.media.warning') })
    }
  }

  private static handleShowToast(options: ToastOptions) {
    if (!OmniToast.uiContext) {
      return
    }

    let wrapBuilderArg: ToastWrapBuilderArgs = {
      msg: options.msg,
      duration: options.duration ?? 2000,
      icon: options.icon,
      theme: options.theme ?? OmniToast.globalTheme
    }

    let uiContext = OmniToast.uiContext
    let promptAction = uiContext.getPromptAction()

    let compContent = new ComponentContent(uiContext, wrapBuilder(imageTextContentBuilder), wrapBuilderArg)

    // 显示 dialog
    promptAction.openCustomDialog(compContent, {
      isModal: false, // 弹窗是否为模态窗口，模态窗口有蒙层，非模态窗口无蒙层。
      autoCancel: false, // 是否允许点击遮障层退出，true表示关闭弹窗。false表示不关闭弹窗。
      alignment: options.alignment,
      offset: options.offset,
      // maskColor: options.theme?.maskColor,
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        if (dismissDialogAction.reason == DismissReason.PRESS_BACK) {
          // PRESS_BACK: 点击三键back、左滑/右滑、键盘ESC。
          dismissDialogAction.dismiss()
        }
      }
    })

    // 定时关闭 dialog
    setTimeout(() => {
      promptAction.closeCustomDialog(compContent).then(() => {
        if (options.onDismiss) {
          options.onDismiss()
        }
      })
    }, options.duration ?? 2000)

  }
}