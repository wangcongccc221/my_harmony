/**
 * 可拖拽的网格表格组件
 * 功能：使用Grid组件实现拖拽功能
 * 用途：替代SimpleDraggableCell，提供更好的拖拽体验
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'

// 表格数据项
export interface GridTableItem {
  id: string
  text: string
  rowIndex: number
  colIndex: number
  isHeader: boolean
  canDrag: boolean
}

// 拖拽数据
export interface DragData {
  item: GridTableItem
  sourceTable: string
}

// 全局拖拽数据存储键
export const GRID_DRAG_DATA_KEY: string = 'GRID_DRAG_DATA_KEY'
export const GRID_DRAG_ACTIVE_KEY: string = 'GRID_DRAG_ACTIVE_KEY'

@Component
export struct DraggableGridTable {
  @Prop tableName: string = 'default'
  @Prop tableRows: string[][] = [
    ['A级', '15', '8', '5', '2'],
    ['B级', '10', '6', '3', '1'],
    ['C级', '5', '6', '2', '0']
  ]
  @Prop tableTitle: string = '等级表'
  @Prop headerTitles: string[] = ['等级', '30', '20', '10', '0']

  @State private gridItems: GridTableItem[] = []
  private scroller: Scroller = new Scroller()

  private getTheme(): ExtendedOmniThemeStyle {
    return OmniThemeManager.getInstance().getCurrentTheme()
  }

  aboutToAppear() {
    this.initializeGridItems()
  }

  private initializeGridItems() {
    const items: GridTableItem[] = []
    
    // 添加表头
    this.headerTitles.forEach((title, colIndex) => {
      items.push({
        id: `header_${colIndex}`,
        text: title,
        rowIndex: -1,
        colIndex: colIndex,
        isHeader: true,
        canDrag: false
      })
    })
    
    // 添加数据行
    this.tableRows.forEach((row, rowIndex) => {
      row.forEach((cell, colIndex) => {
        items.push({
          id: `data_${rowIndex}_${colIndex}`,
          text: cell,
          rowIndex: rowIndex,
          colIndex: colIndex,
          isHeader: false,
          canDrag: colIndex > 0 // 第0列（等级名）不可拖拽
        })
      })
    })
    
    this.gridItems = items
  }

  @Builder
  private buildGridItem(item: GridTableItem) {
    Text(item.text)
      .fontSize(13)
      .fontColor(item.isHeader ? this.getTheme().textColor : this.getTheme().subTextColor)
      .fontWeight(item.isHeader ? FontWeight.Bold : FontWeight.Normal)
      .textAlign(TextAlign.Center)
      .width('100%')
      .height(40)
      .padding(6)
      .backgroundColor(
        item.isHeader 
          ? (this.getTheme().tableHeaderBg ?? this.getTheme().surfaceColor)
          : this.getTheme().surfaceColor
      )
      .border({ width: { right: 1, bottom: 1 }, color: this.getTheme().borderColor })
      // 完全禁用拖拽功能，避免系统创建任何预览
      .draggable(false)
  }


  private handleItemDragStart(event: ItemDragInfo, itemIndex: number): CustomBuilder {
    const item = this.gridItems[itemIndex]
    console.log('Grid拖拽开始:', item)
    
    if (item.canDrag) {
      const dragData: DragData = {
        item: item,
        sourceTable: this.tableName
      }
      // 写入全局拖拽数据
      AppStorage.set(GRID_DRAG_DATA_KEY, dragData)
    }
    
    // 返回空的拖拽预览，不显示任何预览
    return () => {
      // 空预览
    }
  }

  private handleItemDrop(event: ItemDragInfo, itemIndex: number, insertIndex: number, isSuccess: boolean): void {
    console.log('Grid拖拽结束:', { itemIndex, insertIndex, isSuccess })
    
    if (isSuccess) {
      const item = this.gridItems[itemIndex]
      const dragData: DragData = {
        item: item,
        sourceTable: this.tableName
      }
      // 更新全局拖拽数据
      AppStorage.set(GRID_DRAG_DATA_KEY, dragData)
    }
  }

  build() {
    Column() {
      // 表格标题
      Text(this.tableTitle)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getTheme().textColor)
        .margin({ bottom: 12 })
      
      // 可拖拽的网格表格
      Grid(this.scroller) {
        ForEach(this.gridItems, (item: GridTableItem, index: number) => {
          GridItem() {
            this.buildGridItem(item)
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr') // 5列布局
      .columnsGap(0)
      .rowsGap(0)
      .width('100%')
      .height(200)
      .backgroundColor(this.getTheme().surfaceColor)
      .borderRadius(8)
      // 关闭Grid内建拖拽，避免与跨组件原生拖拽冲突
      .editMode(false)
    }
    .width('100%')
    .padding(16)
  }
}
