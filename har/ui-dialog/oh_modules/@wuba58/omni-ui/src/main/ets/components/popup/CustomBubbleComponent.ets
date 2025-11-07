import { ArrowLocation } from './ArrowLocation'
import { PopupBean } from './entity/PopupBean'
import { BubbleComponent } from './BubbleComponent'
import { display } from '@kit.ArkUI'
import { PopupPosition } from './PopupPosition'

/**
 * 气泡弹窗
 */
@Component
export struct CustomBubbleComponent {
  @Prop data: PopupBean<ESObject>
  @State yOffset: number = 0
  @State xOffset: number = 0
  @State isArrowPositionEnd: boolean = false
  /**
   * 屏幕宽
   */
  private readonly screenWidth: number = display.getDefaultDisplaySync().width
  /**
   * 屏幕高
   */
  private readonly screenHeight: number = display.getDefaultDisplaySync().height

  private _onAreaChange(data: Area) {
    if (this.data.popupConfig.attachViewComponentInfo) {
      const y = this.data.popupConfig.attachViewComponentInfo.screenOffset.y
      const x = this.data.popupConfig.attachViewComponentInfo.screenOffset.x
      const h = this.data.popupConfig.attachViewComponentInfo.size.height
      const w = this.data.popupConfig.attachViewComponentInfo.size.width
      const isLeft = (x + w / 2) < this.screenWidth / 2
      const isTop = (y + h / 2) < this.screenHeight / 2
      const isAttachCenter = this.data.popupConfig.isAttachCenter
      const shadowRadius = this.data.popupConfig.shadowRadius ?? 0
      if (this.data.popupConfig.arrowLocation == ArrowLocation.LEFT ||
        this.data.popupConfig.arrowLocation == ArrowLocation.RIGHT) {
        let componentHeight = vp2px(data.height.valueOf() as number)
        let yOffset = 0
        if (isAttachCenter) {
          yOffset = px2vp(y - (componentHeight - h) / 2)
        } else {
          yOffset = isTop ? (px2vp(y) - shadowRadius) : (px2vp(y - (componentHeight - h)) + shadowRadius)
          if (this.data.popupConfig.popupPosition == PopupPosition.LEFT ||
            this.data.popupConfig.popupPosition == PopupPosition.RIGHT) {
            this.isArrowPositionEnd = !isTop && (componentHeight > h)
          }
        }
        this.yOffset = yOffset
      } else {
        let componentWidth = vp2px(data.width.valueOf() as number)
        let xOffset = 0
        if (isAttachCenter) {
          xOffset = px2vp(x - (componentWidth - w) / 2)
        } else {
          xOffset = isLeft ? (px2vp(x) - shadowRadius) : (px2vp(x - (componentWidth - w)) + shadowRadius)
          if (this.data.popupConfig.popupPosition == PopupPosition.TOP ||
            this.data.popupConfig.popupPosition == PopupPosition.BOTTOM) {
            this.isArrowPositionEnd = !isLeft && (componentWidth > w)
          }
        }
        this.xOffset = xOffset
      }
    }
  }

  private getWidth(): number | undefined {
    const w = this.data.popupConfig.width
    if (typeof w == "number") {
      return w
    } else {
      return undefined
    }
  }

  private getHeight(): number | undefined {
    const h = this.data.popupConfig.height
    if (typeof h == "number") {
      return h
    } else {
      return undefined
    }
  }

  private getBackground(): number | string | Color | undefined {
    const bg = this.data.popupConfig.backgroundColor
    if (typeof bg == "number" || typeof bg == "string") {
      return bg
    }
    return undefined
  }

  private getBubbleRadius(): number {
    const radius = this.data.popupConfig.borderRadius
    if (typeof radius == "number") {
      return radius
    } else {
      return 0
    }
  }

  private getBubbleTopLeftRadius(): number {
    const radius = this.data.popupConfig.borderRadius
    try {
      if ((radius as BorderRadiuses)?.topLeft) {
        return parseFloat(`${(radius as BorderRadiuses).topLeft?.valueOf()}}`)
      } else if ((radius as LocalizedBorderRadiuses)?.topStart) {
        return parseFloat(`${(radius as LocalizedBorderRadiuses).topStart?.valueOf()}}`)
      } else {
        return -1
      }
    } catch (e) {
      return -1
    }
  }

  private getBubbleTopRightRadius(): number {
    const radius = this.data.popupConfig.borderRadius
    try {
      if ((radius as BorderRadiuses)?.topRight) {
        return parseFloat(`${(radius as BorderRadiuses).topRight?.valueOf()}}`)
      } else if ((radius as LocalizedBorderRadiuses)?.topEnd) {
        return parseFloat(`${(radius as LocalizedBorderRadiuses).topEnd?.valueOf()}}`)
      } else {
        return -1
      }
    } catch (e) {
      return -1
    }
  }

  private getBubbleBottomRightRadius(): number {
    const radius = this.data.popupConfig.borderRadius
    try {
      if ((radius as BorderRadiuses)?.bottomRight) {
        return parseFloat(`${(radius as BorderRadiuses).bottomRight?.valueOf()}}`)
      } else if ((radius as LocalizedBorderRadiuses)?.bottomEnd) {
        return parseFloat(`${(radius as LocalizedBorderRadiuses).bottomEnd?.valueOf()}}`)
      } else {
        return -1
      }
    } catch (e) {
      return -1
    }
  }

  private getBubbleBottomLeftRadius(): number {
    const radius = this.data.popupConfig.borderRadius
    try {
      if ((radius as BorderRadiuses)?.bottomLeft) {
        return parseFloat(`${(radius as BorderRadiuses).bottomLeft?.valueOf()}}`)
      } else if ((radius as LocalizedBorderRadiuses)?.bottomStart) {
        return parseFloat(`${(radius as LocalizedBorderRadiuses).bottomStart?.valueOf()}}`)
      } else {
        return -1
      }
    } catch (e) {
      return -1
    }
  }

  private getBubblePadding(): number {
    const popupPadding = this.data.popupConfig.popupPadding
    if (typeof popupPadding == "number") {
      return popupPadding
    } else {
      return 0
    }
  }

  private getBubbleTopPadding(): number {
    const popupPadding = this.data.popupConfig.popupPadding
    try {
      if ((popupPadding as Padding)?.top) {
        return parseFloat(`${(popupPadding as Padding).top?.valueOf()}}`)
      } else if ((popupPadding as LocalizedPadding)?.top) {
        return parseFloat(`${(popupPadding as LocalizedPadding).top?.valueOf()}}`)
      } else {
        return -1
      }
    } catch (e) {
      return -1
    }
  }

  private getBubbleRightPadding(): number {
    const popupPadding = this.data.popupConfig.popupPadding
    try {
      if ((popupPadding as Padding)?.right) {
        return parseFloat(`${(popupPadding as Padding).right?.valueOf()}}`)
      } else if ((popupPadding as LocalizedPadding)?.end) {
        return parseFloat(`${(popupPadding as LocalizedPadding).end?.valueOf()}}`)
      } else {
        return -1
      }
    } catch (e) {
      return -1
    }
  }

  private getBubbleLeftPadding(): number {
    const popupPadding = this.data.popupConfig.popupPadding
    try {
      if ((popupPadding as Padding)?.left) {
        return parseFloat(`${(popupPadding as Padding).left?.valueOf()}}`)
      } else if ((popupPadding as LocalizedPadding)?.start) {
        return parseFloat(`${(popupPadding as LocalizedPadding).start?.valueOf()}}`)
      } else {
        return -1
      }
    } catch (e) {
      return -1
    }
  }

  private getBubbleBottomPadding(): number {
    const popupPadding = this.data.popupConfig.popupPadding
    try {
      if ((popupPadding as Padding)?.bottom) {
        return parseFloat(`${(popupPadding as Padding).bottom?.valueOf()}}`)
      } else if ((popupPadding as LocalizedPadding)?.bottom) {
        return parseFloat(`${(popupPadding as LocalizedPadding).bottom?.valueOf()}}`)
      } else {
        return -1
      }
    } catch (e) {
      return -1
    }
  }

  build() {
    Stack() {
      BubbleComponent({
        mWidth: this.getWidth(),
        mHeight: this.getHeight(),
        arrowOffset: this.data.popupConfig.arrowOffset,
        isArrowPositionCenter: this.data.popupConfig.isArrowPositionCenter,
        mShadowColor: this.data.popupConfig.shadowColor,
        mShadowRadius: this.data.popupConfig.shadowRadius,
        mShadowX: this.data.popupConfig.shadowX,
        mShadowY: this.data.popupConfig.shadowY,
        mArrowTopLeftRadius: this.data.popupConfig.arrowTopLeftRadius,
        mArrowTopRightRadius: this.data.popupConfig.arrowTopRightRadius,
        mArrowDownLeftRadius: this.data.popupConfig.arrowDownLeftRadius,
        mArrowDownRightRadius: this.data.popupConfig.arrowDownRightRadius,
        mBubbleRadius: this.getBubbleRadius(),
        mBubbleTopLeftRadius: this.getBubbleTopLeftRadius(),
        mBubbleTopRightRadius: this.getBubbleTopRightRadius(),
        mBubbleBottomRightRadius: this.getBubbleBottomRightRadius(),
        mBubbleBottomLeftRadius: this.getBubbleBottomLeftRadius(),
        mArrowWidth: this.data.popupConfig.arrowWidth,
        mArrowHeight: this.data.popupConfig.arrowHeight,
        mArrowLocation: this.data.popupConfig.arrowLocation,
        mBubbleBackground: this.getBackground(),
        mBubbleBorderColor: this.data.popupConfig.borderColor,
        mBubbleBorderSize: this.data.popupConfig.borderSize,
        mBubblePadding: this.getBubblePadding(),
        mBubbleLeftPadding: this.getBubbleLeftPadding(),
        mBubbleRightPadding: this.getBubbleRightPadding(),
        mBubbleTopPadding: this.getBubbleTopPadding(),
        mBubbleBottomPadding: this.getBubbleBottomPadding(),
        isArrowPositionEnd: this.isArrowPositionEnd
      }) {
        NodeContainer(this.data.customNodeController)
      }
    }
    .translate({ y: this.yOffset, x: this.xOffset })
    .onAreaChange((_old: Area, _new: Area) => {
      this._onAreaChange(_new)
    })
  }
}