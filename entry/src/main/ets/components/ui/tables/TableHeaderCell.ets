/**
 * 表格表头单元格组件
 * 功能：统一的表头单元格样式
 * 用途：可复用的表头单元格控件，用于 Grid 布局
 */

import { ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../../utils/theme/ThemeUtils'

@Component
export struct TableHeaderCell {
  @Prop text: string = ''  // 表头文本
  @Prop fontSize: number = 20  // 字体大小，默认20
  @Prop cellHeight: number | string = 50  // 单元格高度，默认50
  @Prop cellPadding: number = 6  // 内边距，默认6
  @Prop showRightBorder: boolean = true  // 是否显示右边框
  @Prop showBottomBorder: boolean = true  // 是否显示下边框
  
  @Consume providedTheme: ExtendedOmniThemeStyle
  
  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.providedTheme)
  }
  
  build() {
    Text(this.text)
      .fontSize(this.fontSize)
      .fontWeight(FontWeight.Bold)
      .fontColor(this.getCurrentTheme().tableHeaderTextColor ?? this.getCurrentTheme().textColor)
      .textAlign(TextAlign.Center)
      .width('100%')
      .height(this.cellHeight)
      .padding(this.cellPadding)
      .backgroundColor(this.getCurrentTheme().tableHeaderBg ?? this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
      .border({ 
        width: { 
          right: this.showRightBorder ? 1 : 0, 
          bottom: this.showBottomBorder ? 1 : 0 
        }, 
        color: this.getCurrentTheme().borderColor 
      })
  }
}

