import { PopupConfig } from '../PopupConfig'
import { CustomNodeController } from '../CustomNodeController'
import { PopupType } from '../PopupType'

export class PopupBean<T extends object> {
  customNodeController: CustomNodeController<T>
  popupConfig: PopupConfig
  /**
   * 蒙层颜色
   */
  maskColor?: ResourceColor
  /**
   * 关闭
   */
  onDismiss?: () => void
  /**
   * 弹窗类型
   */
  popupType?: PopupType

  constructor(customNodeController: CustomNodeController<T>, popupConfig: PopupConfig) {
    this.customNodeController = customNodeController
    this.popupConfig = popupConfig
  }
}