@Preview
@Component
export struct LineWrapLayout {
  gap: number = 10
  singleLine: Boolean = false
  hasRightPart: Boolean = false
  private measuredSize: SizeResult = {
    width: 0,
    height: 0
  }

  @Builder
  doNothingBuilder() {
  }

  @BuilderParam
  builder: () => void = this.doNothingBuilder

  onPlaceChildren(selfLayoutInfo: GeometryInfo, children: Array<Layoutable>, constraint: ConstraintSizeOptions) {
    let maxRemainWidth = constraint.maxWidth as number

    if (maxRemainWidth) {
      let currentWidth = 0
      let childrenLen = children.length
      if (this.hasRightPart && this.singleLine) {
        let lastChild = children[childrenLen - 1]
        let childWidth = lastChild.measureResult.width
        lastChild.layout({ x: maxRemainWidth - childWidth, y: 0 })
        for (let i = 0; i < childrenLen - 1; i++) {
          let child = children[i]
          let childWidth = child.measureResult.width
          child.layout({ x: currentWidth, y: 0 })
          currentWidth += childWidth
          currentWidth += this.gap
        }
      } else {
        children.forEach((child) => {
          let childWidth = child.measureResult.width
          child.layout({ x: currentWidth, y: 0 })
          currentWidth += childWidth
          currentWidth += this.gap
        })
      }
    }
  }

  onMeasureSize(selfLayoutInfo: GeometryInfo, children: Array<Measurable>, constraint: ConstraintSizeOptions) {
    let maxRemainWidth = constraint.maxWidth as number

    if (maxRemainWidth) {
      let layoutWidth = 0
      let layoutHeight = 0
      let childrenLen = children.length
      // 如果有rightPart，先计算rightPart的尺寸
      if (this.singleLine && this.hasRightPart) {
        let lastChild = children[childrenLen - 1]
        let result: MeasureResult = lastChild.measure({
          minHeight: constraint.minHeight,
          minWidth: constraint.minWidth,
          maxWidth: maxRemainWidth,
          maxHeight: constraint.maxHeight
        })
        layoutWidth += result.width

        for (let i = 0; i < childrenLen - 1; i++) {
          let child = children[i]
          let result: MeasureResult = child.measure({
            minHeight: constraint.minHeight,
            minWidth: constraint.minWidth,
            maxWidth: maxRemainWidth - layoutWidth,
            maxHeight: constraint.maxHeight
          })

          if (result.height >= layoutHeight) {
            layoutHeight = result.height
          }
          layoutWidth += result.width
          layoutWidth += this.gap
        }
      } else {
        children.forEach((child, index) => {
          let result: MeasureResult = child.measure({
            minHeight: constraint.minHeight,
            minWidth: constraint.minWidth,
            maxWidth: maxRemainWidth - layoutWidth,
            maxHeight: constraint.maxHeight
          })

          if (result.height >= layoutHeight) {
            layoutHeight = result.height
          }
          layoutWidth += result.width
          layoutWidth += this.gap
        })
      }
      if (this.singleLine) {
        this.measuredSize.width = maxRemainWidth
      } else {
        this.measuredSize.width = Math.min(layoutWidth, maxRemainWidth)
      }
      this.measuredSize.height = layoutHeight
    }

    return this.measuredSize
  }

  build() {
    this.builder()
  }
}