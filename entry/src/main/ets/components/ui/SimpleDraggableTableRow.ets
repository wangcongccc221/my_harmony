/**
 * 简化的可拖拽表格行组件
 * 功能：支持拖拽的表格行，可以拖动到液体卡片中
 * 用途：等级表的数据行拖拽功能
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'

// 拖拽数据接口
export interface DragData {
  rowIndex: number
  rowData: string[]
  sourceTable: string
}

@Component
export struct SimpleDraggableTableRow {
  @Prop rowData: string[] = []
  @Prop isHeader: boolean = false
  @Prop rowIndex: number = 0
  @Prop fontSize: number = 13
  @Prop cellPadding: number = 6
  @Prop sourceTable: string = '等级表'
  
  // 拖拽回调
  onRowDragStart?: (dragData: DragData) => void
  onRowDragEnd?: () => void
  
  // 拖拽状态
  @State private isDragging: boolean = false

  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return OmniThemeManager.getInstance().getCurrentTheme()
  }

  // 处理拖拽开始
  private handleDragStart() {
    if (this.isHeader) return // 表头不可拖拽
    
    this.isDragging = true
    const dragData: DragData = {
      rowIndex: this.rowIndex,
      rowData: this.rowData,
      sourceTable: this.sourceTable
    }
    
    if (this.onRowDragStart) {
      this.onRowDragStart(dragData)
    }
    
    console.log('开始拖拽行数据:', dragData)
  }

  // 处理拖拽结束
  private handleDragEnd() {
    this.isDragging = false
    
    if (this.onRowDragEnd) {
      this.onRowDragEnd()
    }
    
    console.log('拖拽结束')
  }

  build() {
    Row() {
      ForEach(this.rowData, (cellData: string, cellIndex: number) => {
        Text(cellData)
          .fontSize(this.fontSize)
          .fontColor(this.isHeader ? this.getCurrentTheme().textColor : this.getCurrentTheme().subTextColor)
          .fontWeight(this.isHeader ? FontWeight.Bold : FontWeight.Normal)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .padding(this.cellPadding)
          .backgroundColor(
            this.isHeader 
              ? this.getCurrentTheme().tableHeaderBg ?? this.getCurrentTheme().surfaceColor
              : this.getCurrentTheme().surfaceColor
          )
          .border({ width: { right: 1 }, color: this.getCurrentTheme().borderColor })
      })
    }
    .width('100%')
    .height(40)
    .backgroundColor(
      this.isDragging 
        ? this.getCurrentTheme().primary + '20'  // 拖拽时高亮
        : this.isHeader 
          ? this.getCurrentTheme().tableHeaderBg ?? this.getCurrentTheme().surfaceColor
          : this.getCurrentTheme().surfaceColor
    )
    .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })
    .borderRadius(this.isDragging ? 8 : 0)
    .shadow(
      this.isDragging 
        ? { radius: 10, color: this.getCurrentTheme().primary + '40', offsetX: 0, offsetY: 4 }
        : undefined
    )
    .opacity(this.isDragging ? 0.8 : 1)
    .gesture(
      LongPressGesture({ repeat: false })
        .onAction(() => {
          this.handleDragStart()
        })
    )
    .onTouch(() => {
      this.handleDragEnd()
    })
  }
}
