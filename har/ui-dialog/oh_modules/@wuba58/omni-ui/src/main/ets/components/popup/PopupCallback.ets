import { PopupAction } from './PopupAction'

export interface PopupCallback {
  /**
   * 弹窗准备显示
   */
  beforeShow?: () => void
  /**
   * 弹窗完全显示
   */
  onShow?: () => void
  /**
   * 弹窗完全消失
   */
  onDismiss?: () => void
  /**
   * 弹窗准备消失
   */
  beforeDismiss?: () => void
  /**
   * 返回按钮
   */
  onBackPressed?: (data: DismissDialogAction) => void
  /**
   * 确认等操作数据返回
   */
  onAction?: (data?: PopupAction) => void

}