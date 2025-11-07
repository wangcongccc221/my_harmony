import { ArrowLocation } from './ArrowLocation';
import { PopupPosition } from './PopupPosition';
import { PopupType } from './PopupType';
import { BaseAttachPopup } from './BaseAttachPopup';

/**
 * 气泡弹窗
 */
export class BubblePopup<T extends object> extends BaseAttachPopup<T> {
  /**
   * 默认阴影半径
   */
  private readonly defaultShadowRadius: number = 15

  constructor(customBuilder: WrappedBuilder<T[]>) {
    super(customBuilder)
    this.popupType = PopupType.BUBBLE
  }

  /**
   * Popup显示之前，可做一些数据处理
   */
  beforeShow(): void {
    if (this.popupConfig.shadowRadius == null) {
      this.popupConfig.shadowRadius = this.defaultShadowRadius
    }
    this.popupConfig.wrap = true
    super.beforeShow()
    //处理箭头方向
    if (this.popupConfig.popupPosition == PopupPosition.TOP) {
      this.popupConfig.arrowLocation = ArrowLocation.BOTTOM
    } else if (this.popupConfig.popupPosition == PopupPosition.LEFT) {
      this.popupConfig.arrowLocation = ArrowLocation.RIGHT
    } else if (this.popupConfig.popupPosition == PopupPosition.RIGHT) {
      this.popupConfig.arrowLocation = ArrowLocation.LEFT
    } else {
      this.popupConfig.arrowLocation = ArrowLocation.TOP
    }
  }

  getAttachMargin(): number {
    if (this.popupConfig.popupPosition == PopupPosition.TOP) {
      return -this.popupConfig.attachMargin + (this.popupConfig.shadowRadius ?? 0)
    } else if (this.popupConfig.popupPosition == PopupPosition.LEFT) {
      return -this.popupConfig.attachMargin + (this.popupConfig.shadowRadius ?? 0)
    } else if (this.popupConfig.popupPosition == PopupPosition.RIGHT) {
      return this.popupConfig.attachMargin - (this.popupConfig.shadowRadius ?? 0)
    } else {
      return this.popupConfig.attachMargin - (this.popupConfig.shadowRadius ?? 0)
    }
  }
}