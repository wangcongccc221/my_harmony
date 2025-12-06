import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'

export interface CellDragData {
  rowIndex: number
  colIndex: number
  value: string
  sourceTable: string
}

export const CELL_DRAG_STORAGE_KEY: string = 'CELL_DRAG_DATA'
export const CELL_DRAG_ACTIVE_KEY: string = 'CELL_DRAG_ACTIVE'
export const CELL_DRAG_POINT_KEY: string = 'CELL_DRAG_POINT' // { x:number, y:number }

// 多选相关常量
export const MULTI_SELECT_CELLS_KEY: string = 'MULTI_SELECT_CELLS'
export const MULTI_SELECT_ACTIVE_KEY: string = 'MULTI_SELECT_ACTIVE'
export const CLEAR_ALL_HIGHLIGHTS_KEY: string = 'CLEAR_ALL_HIGHLIGHTS'

// 多选单元格数据接口
export interface MultiSelectCell {
  rowIndex: number
  colIndex: number
  value: string
  sourceTable: string
  cellId: string // 唯一标识符
}

// 多选状态接口
export interface MultiSelectState {
  cells: MultiSelectCell[]
  isActive: boolean
}

@Component
export struct SimpleDraggableCell {
  @Prop text: string = ''
  @Prop rowIndex: number = 0
  @Prop colIndex: number = 0
  @Prop fontSize: number = 13
  @Prop cellPadding: number = 6
  @Prop sourceTable: string = '等级表'
  @Prop isHeader: boolean = false
  @Prop canDrag: boolean = true

  @State private isDragging: boolean = false
  @State private isSelected: boolean = false
  
  // 监听全局清除高亮信号
  @StorageLink(CLEAR_ALL_HIGHLIGHTS_KEY) private clearAllHighlights: boolean = false

  private getTheme(): ExtendedOmniThemeStyle {
    return OmniThemeManager.getInstance().getCurrentTheme()
  }

  private beginDrag() {
    if (!this.canDrag || this.isHeader) { return }
    this.isDragging = true
    const data: CellDragData = {
      rowIndex: this.rowIndex,
      colIndex: this.colIndex,
      value: this.text,
      sourceTable: this.sourceTable
    }
    AppStorage.setOrCreate(CELL_DRAG_STORAGE_KEY, data)
    AppStorage.setOrCreate(CELL_DRAG_ACTIVE_KEY, true)
    // 初始指针坐标由顶层代理层跟踪，这里仅标记激活
    console.log('Cell drag selected:', JSON.stringify(data))
  }

  private endDrag() {
    if (!this.canDrag || this.isHeader) { return }
    this.isDragging = false
    // 拖拽结束后取消高亮
    this.isSelected = false
    console.log('🧹 拖拽结束，已取消高亮:', this.text)
    // 不在此强制结束全局drag，交由顶层代理在投放/取消时更新
  }

  // 切换选中状态
  private toggleSelection() {
    if (this.isHeader || !this.canDrag) {
      console.log('🚫 表头或不可拖拽单元格，无法选中')
      return
    }
    
    this.isSelected = !this.isSelected
    console.log('🔄 单元格选中状态:', this.text, this.isSelected ? '✅ 已选中' : '❌ 未选中')
    
    // 更新全局多选状态
    this.updateMultiSelectState()
    
    // 强制刷新AppStorage，确保状态同步
    setTimeout(() => {
      const currentState = AppStorage.get(MULTI_SELECT_CELLS_KEY) as MultiSelectState
      console.log('🔄 延迟检查多选状态:', JSON.stringify(currentState))
    }, 50)
  }
  
  // 收集所有选中的单元格
  private collectAllSelectedCells() {
    // 如果当前单元格被选中，收集所有选中的单元格
    if (this.isSelected) {
      const currentState = AppStorage.get(MULTI_SELECT_CELLS_KEY) as MultiSelectState || { cells: [], isActive: false }
      
      // 确保当前单元格在多选列表中
      const cellId = `${this.sourceTable}_${this.rowIndex}_${this.colIndex}`
      const currentCell: MultiSelectCell = {
        rowIndex: this.rowIndex,
        colIndex: this.colIndex,
        value: this.text,
        sourceTable: this.sourceTable,
        cellId: cellId
      }
      
      // 检查是否已存在，如果不存在则添加
      const exists = currentState.cells.some(cell => cell.cellId === cellId)
      if (!exists) {
        const newState: MultiSelectState = {
          cells: [...(currentState.cells || []), currentCell],
          isActive: true
        }
        AppStorage.set(MULTI_SELECT_CELLS_KEY, newState)
        AppStorage.set(MULTI_SELECT_ACTIVE_KEY, true)
        console.log('🔍 拖拽时添加当前单元格到多选列表:', currentCell)
      }
    }
  }

  // 更新全局多选状态
  private updateMultiSelectState() {
    const currentState = AppStorage.get(MULTI_SELECT_CELLS_KEY) as MultiSelectState || { cells: [], isActive: false }
    const cellId = `${this.sourceTable}_${this.rowIndex}_${this.colIndex}`
    
    // 创建新的状态对象，避免直接修改引用
    const newState: MultiSelectState = {
      cells: [...(currentState.cells || [])],
      isActive: currentState.isActive || false
    }
    
    if (this.isSelected) {
      // 添加到多选列表
      const newCell: MultiSelectCell = {
        rowIndex: this.rowIndex,
        colIndex: this.colIndex,
        value: this.text,
        sourceTable: this.sourceTable,
        cellId: cellId
      }
      
      // 检查是否已存在，避免重复添加
      const exists = newState.cells.some(cell => cell.cellId === cellId)
      if (!exists) {
        newState.cells.push(newCell)
        newState.isActive = true
        AppStorage.set(MULTI_SELECT_CELLS_KEY, newState)
        AppStorage.set(MULTI_SELECT_ACTIVE_KEY, true)
        console.log('📝 添加到多选列表:', newCell)
      }
    } else {
      // 从多选列表移除
      newState.cells = newState.cells.filter(cell => cell.cellId !== cellId)
      newState.isActive = newState.cells.length > 0
      AppStorage.set(MULTI_SELECT_CELLS_KEY, newState)
      AppStorage.set(MULTI_SELECT_ACTIVE_KEY, newState.isActive)
      console.log('🗑️ 从多选列表移除:', cellId)
    }
    
    console.log('📊 当前多选状态:', newState)
  }

  // 监听全局清除高亮信号
  aboutToAppear() {
    // 监听清除高亮信号
    this.clearAllHighlights = false
  }
  
  // 当清除高亮信号变化时，清除当前单元格的高亮
  onClearHighlightsChanged() {
    if (this.clearAllHighlights) {
      this.isSelected = false
      console.log('🧹 全局清除高亮:', this.text)
    }
  }

  build() {
    Text(this.text)
      .fontSize(this.fontSize)
      .fontColor(this.isHeader ? this.getTheme().textColor : this.getTheme().subTextColor)
      .fontWeight(this.isHeader ? FontWeight.Bold : FontWeight.Normal)
      .textAlign(TextAlign.Center)
      .layoutWeight(1)
      .padding(this.cellPadding)
      .backgroundColor(
        this.isHeader 
          ? (this.getTheme().tableHeaderBg ?? this.getTheme().surfaceColor)
          : (this.isDragging 
              ? (this.getTheme().primary + '40') // 拖拽高亮
              : (this.isSelected ? (this.getTheme().primary + '20') : this.getTheme().surfaceColor))
      )
      .border({ 
        width: { right: 1, bottom: 1 }, 
        color: (this.isDragging || this.isSelected) ? this.getTheme().primary : this.getTheme().borderColor 
      })
      .borderRadius((this.isDragging || this.isSelected) ? 4 : 0) // 拖拽或选中时添加圆角
      .shadow(
        (this.isDragging || this.isSelected)
          ? { radius: 4, color: this.getTheme().primary + '30', offsetX: 0, offsetY: 2 }
          : undefined
      )
      .onClick(() => {
        this.toggleSelection()
      })
      .onDragStart((event: DragEvent, extraParams: string): DragItemInfo => {
        // 重新收集所有选中的单元格
        this.collectAllSelectedCells()
        
        // 检查是否有多个选中的单元格
        const multiSelectState = AppStorage.get(MULTI_SELECT_CELLS_KEY) as MultiSelectState
        const hasMultiSelect = multiSelectState && multiSelectState.cells && multiSelectState.cells.length > 1
        
        console.log('🔍 拖拽开始检查多选状态:', {
          multiSelectState: JSON.stringify(multiSelectState),
          hasMultiSelect,
          cellsLength: multiSelectState?.cells?.length || 0,
          cells: multiSelectState?.cells
        })
        
        if (hasMultiSelect) {
          // 多选拖拽：使用所有选中的单元格数据
          console.log('🎯 开始多选拖拽，选中单元格数量:', multiSelectState.cells.length)
          console.log('🎯 多选单元格数据:', multiSelectState.cells)
          
          const dragDataStr: string = JSON.stringify({
            type: 'multi_select',
            cells: multiSelectState.cells,
            count: multiSelectState.cells.length
          })
          
          const dragItemInfo: DragItemInfo = {
            pixelMap: undefined,
            builder: undefined,
            extraInfo: dragDataStr
          }
          return dragItemInfo
        } else {
          // 单选拖拽：使用当前单元格数据
          const dragData: CellDragData = {
            rowIndex: this.rowIndex,
            colIndex: this.colIndex,
            value: this.text,
            sourceTable: this.sourceTable
          }
          
          const dragDataStr: string = JSON.stringify(dragData)
          console.log('开始拖拽单元格数据:', dragDataStr)
          
          const dragItemInfo: DragItemInfo = {
            pixelMap: undefined,
            builder: undefined,
            extraInfo: dragDataStr
          }
          return dragItemInfo
        }
      })
      .onDragEnd(() => {
        this.endDrag()
        console.log('🎯 拖拽结束事件触发')
        
        // 清除所有高亮
        AppStorage.set(CLEAR_ALL_HIGHLIGHTS_KEY, true)
        setTimeout(() => {
          AppStorage.set(CLEAR_ALL_HIGHLIGHTS_KEY, false)
        }, 100)
      })
  }
}

export const getCurrentCellDragData = (): CellDragData | null => {
  const d = AppStorage.get(CELL_DRAG_STORAGE_KEY) as CellDragData | null
  if (d && typeof d.rowIndex === 'number' && typeof d.colIndex === 'number' && typeof d.value !== 'undefined' && typeof d.sourceTable === 'string') {
    return d
  }
  return null
}


