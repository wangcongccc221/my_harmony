import { ArrowLocation } from './ArrowLocation'

/**
 * 气泡组件
 */
@Component
export struct BubbleComponent {
  /**
   * 用来配置CanvasRenderingContext2D对象的参数，包括是否开启抗锯齿，true表明开启抗锯齿。
   */
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  /**
   * 用来创建CanvasRenderingContext2D对象，通过在canvas中调用CanvasRenderingContext2D对象来绘制。
   */
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  @Builder
  content() {
  }

  /**
   * 内容
   */
  @BuilderParam contentBuilder: () => void = this.content
  /**
   * 组件的宽度，单位：vp
   */
  @Prop mWidth: number = 0
  /**
   * 组件的高度，单位：vp
   */
  @Prop mHeight: number = 0
  /**
   * 箭头偏移量，单位：vp
   */
  @Prop arrowOffset: number = 0
  /**
   * 箭头是否居中
   */
  @Prop isArrowPositionCenter: boolean = true
  /**
   * 箭头是否在右方/下方
   */
  @Prop isArrowPositionEnd: boolean = false
  /**
   * 阴影颜色
   */
  @Prop mShadowColor: string = ""
  /**
   * 阴影半径，单位：vp
   */
  @Prop mShadowRadius: number = 0
  /**
   * 阴影X轴，单位：vp
   */
  @Prop mShadowX: number = 0
  /**
   * 阴影Y轴，单位：vp
   */
  @Prop mShadowY: number = 0
  /**
   * 箭头尖左边弧度，单位：vp
   */
  @Prop mArrowTopLeftRadius: number = 2
  /**
   * 箭头尖右边弧度，单位：vp
   */
  @Prop mArrowTopRightRadius: number = 2
  /**
   * 箭头底部左边弧度，单位：vp
   */
  @Prop mArrowDownLeftRadius: number = 2
  /**
   * 箭头底部右边弧度，单位：vp
   */
  @Prop mArrowDownRightRadius: number = 2
  /**
   * 气泡圆角，单位：vp
   */
  @Prop mBubbleRadius: number = 12
  /**
   * 气泡左上圆角，单位：vp
   */
  @Prop mBubbleTopLeftRadius: number = -1
  /**
   * 气泡右上圆角，单位：vp
   */
  @Prop mBubbleTopRightRadius: number = -1
  /**
   * 气泡右下圆角，单位：vp
   */
  @Prop mBubbleBottomRightRadius: number = -1
  /**
   * 气泡左下圆角，单位：vp
   */
  @Prop mBubbleBottomLeftRadius: number = -1
  /**
   * 箭头宽度，单位：vp
   */
  @Prop mArrowWidth: number = 20
  /**
   * 箭头高度，单位：vp
   */
  @Prop mArrowHeight: number = 8
  /**
   * 箭头的位置，默认顶部
   */
  @Prop mArrowLocation: ArrowLocation = ArrowLocation.TOP
  /**
   * 气泡背景颜色
   */
  @Prop mBubbleBackground: number | string | Color = Color.White
  /**
   * 气泡边框颜色
   */
  @Prop mBubbleBorderColor: number = Color.Transparent
  /**
   * 气泡边框大小，单位：vp
   */
  @Prop mBubbleBorderSize: number = 0
  /**
   * 气泡内边距，单位：vp
   */
  @Prop mBubblePadding: number = 0
  /**
   * 气泡左内边距，单位：vp
   */
  @Prop mBubbleLeftPadding: number = -1
  /**
   * 气泡左右边距，单位：vp
   */
  @Prop mBubbleRightPadding: number = -1
  /**
   * 气泡上内边距，单位：vp
   */
  @Prop mBubbleTopPadding: number = -1
  /**
   * 气泡下内边距，单位：vp
   */
  @Prop mBubbleBottomPadding: number = -1
  /**
   * 箭头实际位置，单位：vp
   */
  private mArrowPosition: number = 0
  /**
   * 左，单位：vp
   */
  private mLeft: number = 0
  /**
   * 上，单位：vp
   */
  private mTop: number = 0
  /**
   * 下，单位：vp
   */
  private mBottom: number = 0
  /**
   * 右，单位：vp
   */
  private mRight: number = 0

  /**
   * 开始绘制
   */
  private onDraw() {
    if (this.isArrowPositionCenter) {
      //箭头居中
      this.mArrowPosition = (this.mArrowLocation == ArrowLocation.LEFT || this.mArrowLocation == ArrowLocation.RIGHT) ?
        (this.mHeight / 2 - this.mArrowWidth / 2) : (this.mWidth / 2 - this.mArrowWidth / 2)
    }
    //再加偏移量
    this.mArrowPosition += this.arrowOffset - this.mBubbleBorderSize
    //处理阴影
    this.mArrowPosition -= this.mShadowRadius
    if (this.mArrowLocation == ArrowLocation.TOP || this.mArrowLocation == ArrowLocation.BOTTOM) {
      this.mArrowPosition += (this.mShadowX < 0 ? this.mShadowX / 2 : 0)
    } else {
      this.mArrowPosition += (this.mShadowY < 0 ? this.mShadowY / 2 : 0)
    }

    this.mTop = this.mBubbleBorderSize + this.mShadowRadius + (this.mShadowY < 0 ? -this.mShadowY : 0) +
      (this.mArrowLocation == ArrowLocation.TOP ? this.mArrowHeight : 0)
    this.mLeft = this.mBubbleBorderSize + this.mShadowRadius + (this.mShadowX < 0 ? -this.mShadowX : 0) +
      (this.mArrowLocation == ArrowLocation.LEFT ? this.mArrowHeight : 0)
    this.mRight = this.mWidth - this.mShadowRadius - this.mBubbleBorderSize + (this.mShadowX > 0 ? -this.mShadowX : 0) -
      (this.mArrowLocation == ArrowLocation.RIGHT ? this.mArrowHeight : 0)
    this.mBottom =
      this.mHeight - this.mShadowRadius - this.mBubbleBorderSize + (this.mShadowY > 0 ? -this.mShadowY : 0) -
        (this.mArrowLocation == ArrowLocation.BOTTOM ? this.mArrowHeight : 0)

    //重置画笔
    this.context.reset()
    //左右箭头时偏移量
    let topOffset: number = this.mArrowPosition
    topOffset =
      (topOffset + this.mArrowWidth) > this.mBottom ? (this.mBottom - this.mTop - this.mArrowWidth) : topOffset
    topOffset = Math.max(topOffset, this.mShadowRadius)
    //上下箭头时偏移量
    let leftOffset: number = this.mArrowPosition
    leftOffset =
      (leftOffset + this.mArrowWidth) > this.mRight ? (this.mRight - this.mLeft - this.mArrowWidth) : leftOffset
    leftOffset = Math.max(leftOffset, this.mShadowRadius)

    if (this.isArrowPositionEnd) {
      topOffset = this.mBottom - this.mTop - topOffset - this.mArrowHeight - this.mShadowRadius
      leftOffset = this.mRight - this.mLeft - leftOffset - this.mArrowWidth
    }

    const region = new Path2D()
    switch (this.mArrowLocation) {
      case ArrowLocation.LEFT:
        region.moveTo(this.mLeft, this.mTop + topOffset)
        region.bezierCurveTo(
          this.mLeft,
          this.mTop + topOffset + this.mArrowDownRightRadius,
          this.mLeft - this.mArrowHeight,
          this.mTop + topOffset + this.mArrowWidth / 2 - this.mArrowTopRightRadius,
          this.mLeft - this.mArrowHeight,
          this.mTop + topOffset + this.mArrowWidth / 2
        )
        region.bezierCurveTo(
          this.mLeft - this.mArrowHeight,
          this.mTop + topOffset + this.mArrowWidth / 2 + this.mArrowTopLeftRadius, this.mLeft,
          this.mTop + topOffset + this.mArrowWidth - this.mArrowDownLeftRadius,
          this.mLeft,
          this.mTop + topOffset + this.mArrowWidth
        )
        if (this.mTop + topOffset + this.mArrowWidth < this.mBottom - this.getBubbleBottomLeftRadius()) {
          region.lineTo(this.mLeft, this.mBottom - this.getBubbleBottomLeftRadius())
        }
        region.quadraticCurveTo(this.mLeft, this.mBottom, this.mLeft + this.getBubbleBottomLeftRadius(), this.mBottom)
        region.lineTo(this.mRight - this.getBubbleBottomRightRadius(), this.mBottom)
        region.quadraticCurveTo(this.mRight, this.mBottom, this.mRight,
          this.mBottom - this.getBubbleBottomRightRadius())
        region.lineTo(this.mRight, this.mTop + this.getBubbleTopRightRadius())
        region.quadraticCurveTo(this.mRight, this.mTop, this.mRight - this.getBubbleTopRightRadius(), this.mTop)
        region.lineTo(this.mLeft + this.getBubbleTopLeftRadius(), this.mTop)
        if (topOffset < this.getBubbleTopLeftRadius()) {
          region.quadraticCurveTo(this.mLeft, this.mTop, this.mLeft, this.mTop + topOffset)
        } else {
          region.quadraticCurveTo(this.mLeft, this.mTop, this.mLeft, this.mTop + this.getBubbleTopLeftRadius())
        }
        break
      case ArrowLocation.TOP:
        region.moveTo(this.mLeft + leftOffset, this.mTop)
        region.bezierCurveTo(
          this.mLeft + leftOffset + this.mArrowDownLeftRadius,
          this.mTop,
          this.mLeft + leftOffset + this.mArrowWidth / 2 - this.mArrowTopLeftRadius,
          this.mTop - this.mArrowHeight,
          this.mLeft + leftOffset + this.mArrowWidth / 2,
          this.mTop - this.mArrowHeight
        )
        region.bezierCurveTo(
          this.mLeft + leftOffset + this.mArrowWidth / 2 + this.mArrowTopRightRadius,
          this.mTop - this.mArrowHeight,
          this.mLeft + leftOffset + this.mArrowWidth - this.mArrowDownRightRadius,
          this.mTop,
          this.mLeft + leftOffset + this.mArrowWidth,
          this.mTop
        )
        if (this.mLeft + leftOffset + this.mArrowWidth < this.mRight - this.getBubbleTopRightRadius()) {
          region.lineTo(this.mRight - this.getBubbleTopRightRadius(), this.mTop)
        }
        region.quadraticCurveTo(this.mRight, this.mTop, this.mRight, this.mTop + this.getBubbleTopRightRadius())
        region.lineTo(this.mRight, this.mBottom - this.getBubbleBottomRightRadius())
        region.quadraticCurveTo(this.mRight, this.mBottom, this.mRight - this.getBubbleBottomRightRadius(),
          this.mBottom)
        region.lineTo(this.mLeft + this.getBubbleBottomLeftRadius(), this.mBottom)
        region.quadraticCurveTo(this.mLeft, this.mBottom, this.mLeft, this.mBottom - this.getBubbleBottomLeftRadius())
        region.lineTo(this.mLeft, this.mTop + this.getBubbleTopLeftRadius())
        if (leftOffset < this.getBubbleTopLeftRadius()) {
          region.quadraticCurveTo(this.mLeft, this.mTop, this.mLeft + leftOffset, this.mTop)
        } else {
          region.quadraticCurveTo(this.mLeft, this.mTop, this.mLeft + this.getBubbleTopLeftRadius(), this.mTop)
        }
        break
      case ArrowLocation.RIGHT:
        region.moveTo(this.mRight, this.mTop + topOffset)
        region.bezierCurveTo(
          this.mRight,
          this.mTop + topOffset + this.mArrowDownLeftRadius,
          this.mRight + this.mArrowHeight,
          this.mTop + topOffset + this.mArrowWidth / 2 - this.mArrowTopLeftRadius,
          this.mRight + this.mArrowHeight,
          this.mTop + topOffset + this.mArrowWidth / 2
        )
        region.bezierCurveTo(
          this.mRight + this.mArrowHeight,
          this.mTop + topOffset + this.mArrowWidth / 2 + this.mArrowTopRightRadius,
          this.mRight,
          this.mTop + topOffset + this.mArrowWidth - this.mArrowDownRightRadius,
          this.mRight,
          this.mTop + topOffset + this.mArrowWidth
        )
        if (this.mTop + topOffset + this.mArrowWidth < this.mBottom - this.getBubbleBottomRightRadius()) {
          region.lineTo(this.mRight, this.mBottom - this.getBubbleBottomRightRadius())
        }
        region.quadraticCurveTo(
          this.mRight,
          this.mBottom,
          this.mRight - this.getBubbleBottomRightRadius(),
          this.mBottom
        )
        region.lineTo(this.mLeft + this.getBubbleBottomLeftRadius(), this.mBottom)
        region.quadraticCurveTo(this.mLeft, this.mBottom, this.mLeft, this.mBottom - this.getBubbleBottomLeftRadius())
        region.lineTo(this.mLeft, this.mTop + this.getBubbleTopLeftRadius())
        region.quadraticCurveTo(this.mLeft, this.mTop, this.mLeft + this.getBubbleTopLeftRadius(), this.mTop)
        region.lineTo(this.mRight - this.getBubbleTopRightRadius(), this.mTop)
        if (topOffset < this.getBubbleTopRightRadius()) {
          region.quadraticCurveTo(this.mRight, this.mTop, this.mRight, this.mTop + topOffset)
        } else {
          region.quadraticCurveTo(this.mRight, this.mTop, this.mRight, this.mTop + this.getBubbleTopRightRadius())
        }
        break
      case ArrowLocation.BOTTOM:
        region.moveTo(this.mLeft + leftOffset, this.mBottom)
        region.bezierCurveTo(
          this.mLeft + leftOffset + this.mArrowDownRightRadius,
          this.mBottom,
          this.mLeft + leftOffset + this.mArrowWidth / 2 - this.mArrowTopRightRadius,
          this.mBottom + this.mArrowHeight,
          this.mLeft + leftOffset + this.mArrowWidth / 2,
          this.mBottom + this.mArrowHeight
        )
        region.bezierCurveTo(
          this.mLeft + leftOffset + this.mArrowWidth / 2 + this.mArrowTopLeftRadius,
          this.mBottom + this.mArrowHeight,
          this.mLeft + leftOffset + this.mArrowWidth - this.mArrowDownLeftRadius,
          this.mBottom,
          this.mLeft + leftOffset + this.mArrowWidth,
          this.mBottom
        )
        if (this.mLeft + leftOffset + this.mArrowWidth < this.mRight - this.getBubbleBottomRightRadius()) {
          region.lineTo(this.mRight - this.getBubbleBottomRightRadius(), this.mBottom)
        }
        region.quadraticCurveTo(this.mRight, this.mBottom, this.mRight,
          this.mBottom - this.getBubbleBottomRightRadius())
        region.lineTo(this.mRight, this.mTop + this.getBubbleTopRightRadius())
        region.quadraticCurveTo(this.mRight, this.mTop, this.mRight - this.getBubbleTopRightRadius(), this.mTop)
        region.lineTo(this.mLeft + this.getBubbleTopLeftRadius(), this.mTop)
        region.quadraticCurveTo(this.mLeft, this.mTop, this.mLeft, this.mTop + this.getBubbleTopLeftRadius())
        region.lineTo(this.mLeft, this.mBottom - this.getBubbleBottomLeftRadius())
        if (leftOffset < this.getBubbleBottomLeftRadius()) {
          region.quadraticCurveTo(this.mLeft, this.mBottom, this.mLeft + leftOffset, this.mBottom)
        } else {
          region.quadraticCurveTo(this.mLeft, this.mBottom, this.mLeft + this.getBubbleBottomLeftRadius(), this.mBottom)
        }
        break
    }
    region.closePath()
    //设置阴影
    this.context.shadowBlur = this.mShadowRadius
    this.context.shadowColor = this.mShadowColor
    this.context.shadowOffsetX = this.mShadowX
    this.context.shadowOffsetY = this.mShadowY
    //设置边框
    if (this.mBubbleBorderSize > 0) {
      this.context.strokeStyle = this.mBubbleBorderColor
      this.context.lineWidth = this.mBubbleBorderSize
      this.context.stroke(region)
    }
    //设置填充颜色
    this.context.fillStyle = this.mBubbleBackground
    this.context.fill(region, "evenodd")

    this.context.closePath()
  }

  /**
   * 获取左上圆角
   * @returns
   */
  getBubbleTopLeftRadius(): number {
    return this.mBubbleTopLeftRadius == -1 ? this.mBubbleRadius : this.mBubbleTopLeftRadius
  }

  /**
   * 获取右上圆角
   * @returns
   */
  getBubbleTopRightRadius(): number {
    return this.mBubbleTopRightRadius == -1 ? this.mBubbleRadius : this.mBubbleTopRightRadius
  }

  /**
   * 获取右下圆角
   * @returns
   */
  getBubbleBottomRightRadius(): number {
    return this.mBubbleBottomRightRadius == -1 ? this.mBubbleRadius : this.mBubbleBottomRightRadius
  }

  /**
   * 获取左下圆角
   * @returns
   */
  getBubbleBottomLeftRadius(): number {
    return this.mBubbleBottomLeftRadius == -1 ? this.mBubbleRadius : this.mBubbleBottomLeftRadius
  }

  /**
   * 顶部内边距
   * @returns
   */
  getBubbleTopPadding(): number {
    const p = this.mShadowRadius + this.mBubbleBorderSize
    const topPadding =
      p + (this.mShadowY < 0 ? -this.mShadowY : 0) + (this.mArrowLocation == ArrowLocation.TOP ? this.mArrowHeight : 0)
    return topPadding + (this.mBubbleTopPadding == -1 ? this.mBubblePadding : this.mBubbleTopPadding)
  }

  /**
   * 底部内边距
   * @returns
   */
  getBubbleBottomPadding(): number {
    const p = this.mShadowRadius + this.mBubbleBorderSize
    const bottomPadding =
      p + (this.mShadowY > 0 ? this.mShadowY : 0) +
        (this.mArrowLocation == ArrowLocation.BOTTOM ? this.mArrowHeight : 0)
    return bottomPadding + (this.mBubbleBottomPadding == -1 ? this.mBubblePadding : this.mBubbleBottomPadding)
  }

  /**
   * 左部内边距
   * @returns
   */
  getBubbleLeftPadding(): number {
    const p = this.mShadowRadius + this.mBubbleBorderSize
    const leftPadding =
      p + (this.mShadowX < 0 ? -this.mShadowX : 0) + (this.mArrowLocation == ArrowLocation.LEFT ? this.mArrowHeight : 0)
    return leftPadding + (this.mBubbleLeftPadding == -1 ? this.mBubblePadding : this.mBubbleLeftPadding)
  }

  /**
   * 右部内边距
   * @returns
   */
  getBubbleRightPadding(): number {
    const p = this.mShadowRadius + this.mBubbleBorderSize
    const rightPadding =
      p + (this.mShadowX > 0 ? this.mShadowX : 0) + (this.mArrowLocation == ArrowLocation.RIGHT ? this.mArrowHeight : 0)
    return rightPadding + (this.mBubbleRightPadding == -1 ? this.mBubblePadding : this.mBubbleRightPadding)
  }

  /**
   * 布局大小变化
   * @param oldValue
   * @param newValue
   */
  private _onAreaChange = (oldValue: Area, newValue: Area) => {
    if (((oldValue.width == 0 && newValue.width > 0) || (oldValue.height == 0 && newValue.height > 0)) &&
      (this.mWidth == 0 || this.mHeight == 0)) {
      try {
        const w = parseFloat(`${newValue.width.valueOf()}`)
        const h = parseFloat(`${newValue.height.valueOf()}`)
        this.mWidth = w + 2 * this.mShadowRadius + Math.abs(this.mShadowX) + 2 * this.mBubbleBorderSize +
          (this.mBubbleLeftPadding != -1 ? this.mBubbleLeftPadding : this.mBubblePadding) +
          (this.mBubbleRightPadding != -1 ? this.mBubbleRightPadding : this.mBubblePadding) +
          (this.mArrowLocation == ArrowLocation.LEFT || this.mArrowLocation == ArrowLocation.RIGHT ? this.mArrowHeight :
            0)
        this.mHeight = h + 2 * this.mShadowRadius + Math.abs(this.mShadowY) + 2 * this.mBubbleBorderSize +
          (this.mBubbleTopPadding != -1 ? this.mBubbleTopPadding : this.mBubblePadding) +
          (this.mBubbleBottomPadding != -1 ? this.mBubbleBottomPadding : this.mBubblePadding) +
          (this.mArrowLocation == ArrowLocation.TOP || this.mArrowLocation == ArrowLocation.BOTTOM ? this.mArrowHeight :
            0)
        this.onDraw()
      } catch (e) {
      }
    }
  }

  build() {
    Stack() {
      Canvas(this.context)
        .width("100%")
        .height("100%")
        .onReady(() => {
          if (this.mWidth > 0 && this.mHeight > 0) {
            this.onDraw()
          }
        })
      Stack() {
        this.contentBuilder()
      }
      .onAreaChange(this._onAreaChange)
      .margin({
        top: this.getBubbleTopPadding(),
        bottom: this.getBubbleBottomPadding(),
        left: this.getBubbleLeftPadding(),
        right: this.getBubbleRightPadding()
      })
      .borderRadius({
        topLeft: this.getBubbleTopLeftRadius(),
        topRight: this.getBubbleTopRightRadius(),
        bottomLeft: this.getBubbleBottomLeftRadius(),
        bottomRight: this.getBubbleBottomRightRadius()
      })
      .clip(true)
    }.width(this.mWidth == 0 ? null : this.mWidth)
    .height(this.mHeight == 0 ? null : this.mHeight)
  }
}