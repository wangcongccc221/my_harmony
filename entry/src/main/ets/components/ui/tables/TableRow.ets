/**
 * 表格行组件
 * 功能：统一的表格行样式和布局
 * 用途：可复用的表格行控件
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'

@Component
export struct TableRowComponent {
  @Prop rowData: string[] = []  // 行数据
  @Prop isHeader: boolean = false  // 是否为表头
  @Prop rowIndex: number = 0  // 行索引（用于斑马纹）
  @Prop cellPadding: number = 4  // 单元格内边距
  @Prop fontSize: number = 12  // 字体大小
  @Prop fontWeight: FontWeight = FontWeight.Normal  // 字体粗细

  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return OmniThemeManager.getInstance().getCurrentTheme()
  }

  build() {
    Row() {
      ForEach(this.rowData, (cell: string, index: number) => {
        Text(cell)
          .fontSize(this.fontSize)
          .fontWeight(this.isHeader ? FontWeight.Bold : this.fontWeight)
          .fontColor(this.isHeader ? 
            (this.getCurrentTheme().tableHeaderTextColor ?? this.getCurrentTheme().textColor) : 
            this.getCurrentTheme().textColor)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .padding({ 
            left: this.cellPadding, 
            right: this.cellPadding, 
            top: this.cellPadding, 
            bottom: this.cellPadding 
          })
          .border({ 
            width: { right: index < this.rowData.length - 1 ? 1 : 0 }, 
            color: this.getCurrentTheme().borderColor 
          })
      })
    }
    .width('100%')
    .backgroundColor(this.isHeader ? 
      (this.getCurrentTheme().tableHeaderBg ?? this.getCurrentTheme().primary) : 
      (this.rowIndex % 2 === 1 ? 
        (this.getCurrentTheme().tableRowAltBg ?? this.getCurrentTheme().surfaceColor) : 
        this.getCurrentTheme().surfaceColor))
    .border({ 
      width: { bottom: 1 }, 
      color: this.getCurrentTheme().borderColor 
    })
  }
}
