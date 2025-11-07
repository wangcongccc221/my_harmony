@Preview
@Component
export struct AutoLineWrapLayout {
  lineGap: number = 10
  lineMaxNum: number = 2
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
      let currentLineWidth = 0
      let currentLineHeight = 0
      let numPerLine = 0
      let lastChildWidth = 0
      let lastChildHeight = 0
      children.forEach((child, index) => {
        let childWidth = child.measureResult.width
        let childHeight = child.measureResult.height
        currentLineWidth += childWidth
        currentLineHeight += (lastChildHeight + this.lineGap)
        /**
         * 换行条件：
         * 1.上一个child占>1/2屏幕宽度
         * 2.当前child占>1/2屏幕宽度
         * 3.每行最多`${lineMaxNum}`个item
         */
        let needSwitchLine = (lastChildWidth > maxRemainWidth / this.lineMaxNum) || (childWidth > maxRemainWidth / this.lineMaxNum) || numPerLine >= this.lineMaxNum
        if (index != 0 && needSwitchLine) {
          child.layout({ x: 0, y: currentLineHeight })
          currentLineWidth = childWidth
          numPerLine = 1
        } else {
          numPerLine++
          currentLineHeight -= (lastChildHeight + this.lineGap)
          child.layout({
            x: index == 0 ? 0 : Math.max(maxRemainWidth / this.lineMaxNum, currentLineWidth - childWidth),
            y: currentLineHeight
          })
        }
        //记录一下上一个child的宽度，以便于判断是否要换行
        lastChildWidth = childWidth
        lastChildHeight = childHeight
      })
    }
  }

  //GeometryInfo包含了border margin padding等信息，可以计算出实际child的宽高
  onMeasureSize(selfLayoutInfo: GeometryInfo, children: Array<Measurable>, constraint: ConstraintSizeOptions) {
    let maxRemainWidth = constraint.maxWidth as number

    if (maxRemainWidth) {
      let layoutWidth = 0
      let layoutHeight = 0

      let numPerLine = 0
      let lastChildWidth = 0

      children.forEach((child, index) => {
        let result: MeasureResult = child.measure({
          minHeight: constraint.minHeight,
          minWidth: constraint.minWidth,
          maxWidth: constraint.maxWidth,
          maxHeight: constraint.maxHeight
        })

        if (index == 0) {
          layoutHeight = result.height
        }

        let needSwitchLine = (lastChildWidth > maxRemainWidth / this.lineMaxNum) || (result.width > maxRemainWidth / this.lineMaxNum) || numPerLine >= this.lineMaxNum
        if (needSwitchLine) {
          if (index != 0) {
            layoutHeight += (result.height + this.lineGap)
          }
          numPerLine = 1
        } else {
          numPerLine++
        }

        layoutWidth += result.width
        lastChildWidth = result.width
      })
      this.measuredSize.width = Math.min(layoutWidth, maxRemainWidth);
      this.measuredSize.height = layoutHeight;
    }

    return this.measuredSize;
  }

  build() {
    this.builder()
  }
}