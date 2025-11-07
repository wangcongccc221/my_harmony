import { BasePopup } from './BasePopup';
import { componentUtils } from '@kit.ArkUI';
import { PopupPosition } from './PopupPosition';

/**
 * 依附弹窗窗口基类
 */
export abstract class BaseAttachPopup<T extends object> extends BasePopup<T> {
  constructor(customWrappedBuilder: WrappedBuilder<T[]>) {
    super(customWrappedBuilder);
  }

  /**
   * Popup显示之前，可做一些数据处理
   */
  beforeShow(): void {
    if (this.attachViewId != null) {
      let componentInfo = componentUtils.getRectangleById(this.attachViewId)
      this.popupConfig.attachViewComponentInfo = componentInfo
      const y = componentInfo.screenOffset.y
      const x = componentInfo.screenOffset.x
      const h = componentInfo.size.height
      const w = componentInfo.size.width
      const yOffset = px2vp(y)
      const xOffset = px2vp(x)
      const height = px2vp(h)
      const width = px2vp(w)
      if (this.popupConfig.popupPosition == PopupPosition.TOP) {
        //向上弹窗
        this.dialogOptions.alignment = DialogAlignment.BottomStart
        this.dialogOptions.offset = {
          dx: 0,
          dy: -(px2vp(this.screenHeight) - yOffset) + this.getAttachMargin()
        }
      } else if (this.popupConfig.popupPosition == PopupPosition.LEFT) {
        //向左弹窗
        this.dialogOptions.alignment = DialogAlignment.TopEnd
        this.dialogOptions.offset = {
          dx: -(px2vp(this.screenWidth) - xOffset) + this.getAttachMargin(),
          dy: 0
        }
      } else if (this.popupConfig.popupPosition == PopupPosition.RIGHT) {
        //向右弹窗
        this.dialogOptions.alignment = DialogAlignment.TopStart
        this.dialogOptions.offset = {
          dx: xOffset + width + this.getAttachMargin(),
          dy: 0
        }
      } else {
        //向下
        this.dialogOptions.alignment = DialogAlignment.TopStart
        this.dialogOptions.offset = {
          dx: 0,
          dy: yOffset + height + this.getAttachMargin()
        }
      }
    }
  }

  getAttachMargin(): number {
    if (this.popupConfig.popupPosition == PopupPosition.TOP) {
      return -this.popupConfig.attachMargin
    } else if (this.popupConfig.popupPosition == PopupPosition.LEFT) {
      return -this.popupConfig.attachMargin
    } else if (this.popupConfig.popupPosition == PopupPosition.RIGHT) {
      return this.popupConfig.attachMargin
    } else {
      return this.popupConfig.attachMargin
    }

  }
}