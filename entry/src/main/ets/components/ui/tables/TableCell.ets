/**
 * 表格数据单元格组件
 * 功能：统一的数据单元格样式
 * 用途：可复用的数据单元格控件，用于 Grid 布局
 */

import { ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../../utils/theme/ThemeUtils'

@Component
export struct TableCell {
  @Prop text: string = ''  // 单元格文本
  @Prop fontSize: number = 16  // 字体大小，默认16
  @Prop cellHeight: number | string = 65  // 单元格高度，默认65
  @Prop cellPadding: number = 2  // 内边距，默认2
  @Prop showRightBorder: boolean = true  // 是否显示右边框
  @Prop showBottomBorder: boolean = true  // 是否显示下边框
  @Prop cellBackgroundColor?: string  // 自定义背景色（可选）
  
  @Consume providedTheme: ExtendedOmniThemeStyle
  
  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.providedTheme)
  }
  
  build() {
    Text(this.text)
      .fontSize(this.fontSize)
      .fontColor(this.getCurrentTheme().textColor)
      .textAlign(TextAlign.Center)
      .width('100%')
      .height(this.cellHeight)
      .padding(this.cellPadding)
      .backgroundColor(this.cellBackgroundColor ?? (this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor))
      .border({ 
        width: { 
          right: this.showRightBorder ? 1 : 0, 
          bottom: this.showBottomBorder ? 1 : 0 
        }, 
        color: this.getCurrentTheme().borderColor 
      })
  }
}

