/**
 * 等级表格组件
 * 功能：显示等级数据的表格
 * 用途：可复用的等级表格控件
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { TableRowComponent } from '../ui/tables/TableRow'
import { SimpleDraggableCell } from '../ui/tables/SimpleDraggableCell'
import { MultiSelectCell, MULTI_SELECT_CELLS_KEY, MULTI_SELECT_ACTIVE_KEY } from '../ui/tables/SimpleDraggableCell'
import { KeyCode } from '@kit.InputKit'; // 键盘键码
// 通用表格行：每行由若干字符串单元格组成
export type TableRow = string[]

// 多选状态接口
interface MultiSelectState {
  cells: MultiSelectCell[]
  isActive: boolean
}

// 拖拽数据接口
interface DragData {
  rowIndex: number
  colIndex: number
  value: string
  sourceTable: string
}

// 多选拖拽数据接口
interface MultiSelectDragData {
  type: string
  cells: MultiSelectCell[]
  count: number
}

// 多选拖拽完整负载（扩展：携带每个单元格对应的等级名列表）
interface MultiSelectPayload {
  type: string
  cells: MultiSelectCell[]
  count: number
  levelNames?: string[]
}

// 简化多选拖拽数据接口
interface SimplifiedMultiSelectData {
  type: string
  count: number
  values: string[]
}

// 多选拖拽简化负载（扩展：携带等级名列表）
interface SimpleMultiSelectPayload {
  type: string
  count: number
  values: string[]
  levelNames?: string[]
}

// 整列拖拽数据接口
interface ColumnDragData {
  type: 'column'
  columnIndex: number
  columnHeader: string
  columnData: string[]
  levelNames: string[] // 添加等级名称数组
  sourceTable: string
}

// 整行拖拽数据接口
interface RowDragData {
  type: 'row'
  rowIndex: number
  rowData: string[]
  levelName: string // 添加等级名称字段
  sourceTable: string
  outletInfo?: string // 出口信息（用于等级统计表）
}

@Component
export struct LevelTable {
  // 表格名字 - 用于数据管理
  @Prop tableName: string = 'default'
  // 是否允许拖拽（默认true，主页可按业务关闭）
  @Prop enableDrag: boolean = true
  
  // 表格数据（二维字符串）
  @Prop tableRows: TableRow[] = [
    ['A级', '15', '8', '5', '2'],
    ['B级', '10', '6', '3', '1'],
    ['C级', '5', '6', '2', '0']
  ]
  
  // 表格标题
  @Prop tableTitle: string = '等级表'
  
  // 表头标题（与每行列数一致）
  @Prop headerTitles: string[] = ['等级', '30', '20', '10', '0']
  
  // 表格宽度
  @Prop tableWidth: string = '55%'
  
  // 表格最大高度（超过此高度可滚动）
  @Prop maxHeight: string = '300px'
  
  // 外层容器背景色（不传则使用主题 surfaceColor）
  @Prop containerBg: string = ''
  
  // 多选状态管理
  @State private selectedCells: Set<string> = new Set()
  @State private isMultiSelectMode: boolean = false
  
  // 拖拽回调（保留占位，当前以单元格投放为主）
  // onRowDragStart?: (dragData: DragData) => void
  // onRowDragEnd?: () => void

  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return OmniThemeManager.getInstance().getCurrentTheme()
  }

  // 切换单元格选中状态
  private toggleCellSelection(rowIndex: number, colIndex: number, cellText: string) {
    // 未开启拖拽/多选时，直接忽略
    if (!this.enableDrag) {
      return
    }
    const cellId = `${rowIndex}_${colIndex}`

    // 从 AppStorage 读取是否按下左 Ctrl（由页面级监听维护）
    const ctrlPressedRaw = AppStorage.get('HOME_CTRL_PRESSED') as boolean | undefined
    const isCtrlMultiSelect = ctrlPressedRaw === true

    if (isCtrlMultiSelect) {
      // Ctrl 多选模式：类似 Excel，点击时切换当前单元格的选中状态（不清空其他选中）
      if (this.selectedCells.has(cellId)) {
        // 取消选中
        this.selectedCells.delete(cellId)
        console.log('🔴 LevelTable - Ctrl 多选模式取消选中单元格:', cellText)
      } else {
        // 追加选中
        this.selectedCells.add(cellId)
        console.log('🟢 LevelTable - Ctrl 多选模式选中单元格:', cellText)
      }
    } else {
      // 单选模式：清空已有选中，只保留当前单元格
      this.selectedCells.clear()
      this.selectedCells.add(cellId)
      console.log('🟢 LevelTable - 单选模式选中单元格:', cellText)
    }

    // 更新多选模式状态
    this.isMultiSelectMode = this.selectedCells.size > 1

    // 更新全局多选状态
    this.updateGlobalMultiSelectState()

    console.log('📊 LevelTable - 当前选中单元格数量:', this.selectedCells.size)
  }

  // 更新全局多选状态
  private updateGlobalMultiSelectState() {
    // 未开启拖拽/多选时，直接忽略
    if (!this.enableDrag) {
      return
    }
    const selectedCellsArray: MultiSelectCell[] = []
    
    this.selectedCells.forEach(cellId => {
      const parts = cellId.split('_')
      const rowIndex = Number(parts[0])
      const colIndex = Number(parts[1])
      const cellText = this.tableRows[rowIndex]?.[colIndex] || ''
      
      selectedCellsArray.push({
        rowIndex: rowIndex,
        colIndex: colIndex,
        value: cellText,
        sourceTable: this.tableName,
        cellId: cellId
      })
    })
    
    const multiSelectState: MultiSelectState = {
      cells: selectedCellsArray,
      isActive: selectedCellsArray.length > 0
    }
    
    AppStorage.set(MULTI_SELECT_CELLS_KEY, multiSelectState)
    AppStorage.set(MULTI_SELECT_ACTIVE_KEY, multiSelectState.isActive)
    
    console.log('🔄 LevelTable - 更新全局多选状态:', JSON.stringify(multiSelectState))
  }

  // 清除所有选中状态
  private clearAllSelections() {
    this.selectedCells.clear()
    this.isMultiSelectMode = false
    this.updateGlobalMultiSelectState()
    console.log('🧹 LevelTable - 清除所有选中状态')
  }

  // 检查单元格是否被选中
  private isCellSelected(rowIndex: number, colIndex: number): boolean {
    const cellId = `${rowIndex}_${colIndex}`
    return this.selectedCells.has(cellId)
  }

  // 统一处理拖拽结束日志与状态清理
  private handleDragEnd(): void {
    console.log('🎯 LevelTable - 拖拽结束事件触发')
    const handled = AppStorage.get('GLOBAL_DROP_HANDLED') as boolean
    const lastValue = AppStorage.get('GLOBAL_DROP_VALUE') as string
    if (!handled && lastValue !== undefined) {
      console.log('🟡 移动非卡片区域 移动内容:', lastValue)
    }
    AppStorage.set('GLOBAL_DROP_HANDLED', false)
    AppStorage.set('GLOBAL_DROP_VALUE', '')
    this.clearAllSelections()
  }

  // 构建自定义单元格
  @Builder
  private buildCustomCell(cellText: string, rowIndex: number, colIndex: number) {
    if (this.tableName === '等级统计表' && colIndex === 2 && rowIndex >= 0) {
      // 用横向 Scroll 包裹 Text，仅该列可左右拖动查看
      Scroll() {
        Row() {
          Text(cellText)
            .fontSize(13)
            .fontColor(this.getCurrentTheme().subTextColor)
            .fontWeight(FontWeight.Normal)
            .textAlign(TextAlign.Start)
            .padding(0)
            .draggable(false) // 禁用拖拽
            .onClick(() => {
              // 允许点击任意列触发选中（包含等级列）
              this.toggleCellSelection(rowIndex, colIndex, cellText)
            })
            .onDragStart((event: DragEvent, extraParams: string): DragItemInfo => {
              return { pixelMap: undefined, builder: undefined, extraInfo: '' }
            })
            .onDragEnd(() => {
              return
            })
        }
      }
      .layoutWeight(1)
      .padding(6)
      // 选中时：背景更鲜艳 + 主题色边框加粗，更显眼
      .backgroundColor(this.isCellSelected(rowIndex, colIndex) ? (this.getCurrentTheme().primary + 'AA') : this.getCurrentTheme().surfaceColor)
      .border({
        width: this.isCellSelected(rowIndex, colIndex) ? { right: 2, top: 2, bottom: 2, left: 2 } : { right: 1 },
        color: this.isCellSelected(rowIndex, colIndex) ? this.getCurrentTheme().primary : this.getCurrentTheme().borderColor
      })
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Auto)
      .scrollBarWidth(6)
    } else {
      // 常规单元格
      Text(cellText)
        .fontSize(26)
        .fontColor(this.isCellSelected(rowIndex, colIndex) ? this.getCurrentTheme().primary : this.getCurrentTheme().subTextColor)
        .fontWeight(this.isCellSelected(rowIndex, colIndex) ? FontWeight.Medium : FontWeight.Normal)
        .textAlign(TextAlign.Center)
        .layoutWeight(1)
        .padding(10)
        // 选中时：背景更鲜艳 + 主题色边框加粗，更显眼
        .backgroundColor(this.isCellSelected(rowIndex, colIndex) ? (this.getCurrentTheme().primary + 'AA') : this.getCurrentTheme().surfaceColor)
        .border({
          width: this.isCellSelected(rowIndex, colIndex) ? { right: 2, top: 2, bottom: 2, left: 2 } : { right: 1 },
          color: this.isCellSelected(rowIndex, colIndex) ? this.getCurrentTheme().primary : this.getCurrentTheme().borderColor
        })
        .draggable(this.enableDrag)
        .onClick(() => {
          // 允许点击任意列触发选中（包含等级列）
          this.toggleCellSelection(rowIndex, colIndex, cellText)
        })
        .onDragStart((event: DragEvent, extraParams: string): DragItemInfo => {
          if (!this.enableDrag) {
            return { pixelMap: undefined, builder: undefined, extraInfo: '' }
          }
          // 第一列（等级列）拖拽整行，其他列拖拽单个单元格
          if (colIndex === 0) {
            return this.handleRowDragStart(rowIndex)
          } else {
            return this.handleDragStart(rowIndex, colIndex, cellText)
          }
        })
        .onDragEnd(() => {
          if (!this.enableDrag) {
            return
          }
          this.handleDragEnd()
        })
    }
  }

  // 处理整列拖拽开始
  private handleColumnDragStart(colIndex: number, columnHeader: string): DragItemInfo {
    // 收集整列数据
    const columnData: string[] = this.tableRows.map(row => row[colIndex] || '')
    // 收集对应的等级名称（每行的第一列）
    const levelNames: string[] = this.tableRows.map(row => row[0] || '')
    
    const columnDragData: ColumnDragData = {
      type: 'column',
      columnIndex: colIndex,
      columnHeader: columnHeader,
      columnData: columnData,
      levelNames: levelNames,
      sourceTable: this.tableName
    }
    
    const dragDataStr: string = JSON.stringify(columnDragData)
    console.log('🚀 LevelTable - 开始整列拖拽:', columnHeader, '数据:', dragDataStr)
    
    // 记录全局未接收状态及拖拽内容（整列用逗号拼接）
    const joined = columnData.join(',')
    // 注意：不要重置GLOBAL_DROP_HANDLED，因为ThirdLayer可能已经设置了它
    AppStorage.set('GLOBAL_DROP_VALUE', joined)
    
    const dragItemInfo: DragItemInfo = {
      pixelMap: undefined,
      builder: undefined,
      extraInfo: dragDataStr
    }
    
    return dragItemInfo
  }

  // 处理整行拖拽开始
  private handleRowDragStart(rowIndex: number): DragItemInfo {
    // 获取整行数据，但排除第一列（等级名称）
    const fullRowData: string[] = this.tableRows[rowIndex] || []
    const rowData: string[] = fullRowData.slice(1) // 排除第一列（等级名称）
    const levelName: string = fullRowData[0] || '' // 第一列是等级名称
    
    // 如果是等级统计表，需要提取出口信息
    let outletInfo: string = ''
    if (this.tableName === '等级统计表' && fullRowData.length > 2) {
      outletInfo = fullRowData[2] || '' // 第3列是出口信息
    }
    
    const rowDragData: RowDragData = {
      type: 'row',
      rowIndex: rowIndex,
      rowData: rowData,
      levelName: levelName, // 添加等级名称
      sourceTable: this.tableName,
      outletInfo: outletInfo // 添加出口信息
    }
    
    const dragDataStr: string = JSON.stringify(rowDragData)
    console.log('🚀 LevelTable - 开始整行拖拽:', `第${rowIndex + 1}行`, '数据:', dragDataStr, '出口:', outletInfo)
    
    // 记录全局未接收状态及拖拽内容（整行用逗号拼接，排除等级名称）
    const joined = rowData.join(',')
    // 注意：不要重置GLOBAL_DROP_HANDLED，因为ThirdLayer可能已经设置了它
    AppStorage.set('GLOBAL_DROP_VALUE', joined)
    
    const dragItemInfo: DragItemInfo = {
      pixelMap: undefined,
      builder: undefined,
      extraInfo: dragDataStr
    }
    
    return dragItemInfo
  }

  // 处理拖拽开始
  private handleDragStart(rowIndex: number, colIndex: number, cellText: string): DragItemInfo {
    // 检查是否有多个选中的单元格
    if (this.isMultiSelectMode && this.selectedCells.size > 1) {
      // 多选拖拽：使用所有选中的单元格数据
      console.log('🎯 LevelTable - 开始多选拖拽，选中单元格数量:', this.selectedCells.size)
      
      const selectedCellsArray: MultiSelectCell[] = []
      this.selectedCells.forEach(cellId => {
        const parts = cellId.split('_')
        const r = Number(parts[0])
        const c = Number(parts[1])
        const text = this.tableRows[r]?.[c] || ''
        selectedCellsArray.push({
          rowIndex: r,
          colIndex: c,
          value: text,
          sourceTable: this.tableName,
          cellId: cellId
        })
      })
      
      // 使用更简洁的数据格式，避免长度限制
      // 生成与cells对齐的等级名数组（取各行首列）
      const levelNamesArr: string[] = selectedCellsArray.map((cell) => {
        return (this.tableRows[cell.rowIndex] && this.tableRows[cell.rowIndex][0]) ? String(this.tableRows[cell.rowIndex][0]) : ''
      })
      const dragData: MultiSelectPayload = {
        type: 'multi_select',
        cells: selectedCellsArray,
        count: selectedCellsArray.length,
        levelNames: levelNamesArr
      }
      const dragDataStr: string = JSON.stringify(dragData)
      console.log('🎯 LevelTable - 多选拖拽数据:', dragDataStr)
      console.log('🎯 LevelTable - 多选拖拽数据长度:', dragDataStr.length)

      // 记录全局未接收状态及拖拽内容（多选使用逗号拼接）
      const joined = selectedCellsArray.map(cell => String(cell.value)).join(',')
      AppStorage.set('GLOBAL_DROP_HANDLED', false)
      AppStorage.set('GLOBAL_DROP_VALUE', joined)
      
      // 如果数据太长，使用简化格式
      if (dragDataStr.length > 100) {
        const simplifiedData: SimpleMultiSelectPayload = {
          type: 'multi_select',
          count: selectedCellsArray.length,
          values: selectedCellsArray.map(cell => cell.value),
          levelNames: levelNamesArr
        }
        const simplifiedStr = JSON.stringify(simplifiedData)
        console.log('🎯 LevelTable - 使用简化数据格式:', simplifiedStr)
        console.log('🎯 LevelTable - 简化数据长度:', simplifiedStr.length)
        
        const dragItemInfo: DragItemInfo = {
          pixelMap: undefined,
          builder: undefined,
          extraInfo: simplifiedStr
        }
        console.log('🎯 LevelTable - 返回的简化DragItemInfo:', JSON.stringify(dragItemInfo))
        return dragItemInfo
      }
      
      const dragItemInfo: DragItemInfo = {
        pixelMap: undefined,
        builder: undefined,
        extraInfo: dragDataStr
      }
      console.log('🎯 LevelTable - 返回的DragItemInfo:', JSON.stringify(dragItemInfo))
      return dragItemInfo
    } else {
      // 单选拖拽：使用当前单元格数据，并附带等级名（取该行第一列）
      const levelName: string = (this.tableRows[rowIndex] && this.tableRows[rowIndex][0]) ? String(this.tableRows[rowIndex][0]) : ''
      const dragDataStr: string = JSON.stringify({
        rowIndex: rowIndex,
        colIndex: colIndex,
        value: cellText,
        sourceTable: this.tableName,
        levelName: levelName
      })
      console.log('🚀 LevelTable - 开始拖拽单元格数据:', dragDataStr)

      // 记录全局未接收状态及拖拽内容（单选）
      // 注意：不要重置GLOBAL_DROP_HANDLED，因为ThirdLayer可能已经设置了它
      AppStorage.set('GLOBAL_DROP_VALUE', String(cellText))
      
      const dragItemInfo: DragItemInfo = {
        pixelMap: undefined,
        builder: undefined,
        extraInfo: dragDataStr
      }
      return dragItemInfo
    }
  }


  build() {
    Column() {
      // 表格标题
      Text(this.tableTitle)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.getCurrentTheme().textColor)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 10 })

      // 通用表格（带滚动功能）
      Column() {
        // 表头（固定不滚动）
        Row() {
          ForEach(this.headerTitles, (title: string, idx: number) => {
            // 第一列（等级列）不允许拖拽，其他列允许整列拖拽
            if (idx === 0) {
              SimpleDraggableCell({
                text: title,
                rowIndex: -1,
                colIndex: idx,
                fontSize: (this.tableName === '等级统计表' ? 24 : 26),
                cellPadding: 10,
                isHeader: true,
                canDrag: false
              })
            } else {
              // 可拖拽的表头单元格
              Text(title)
                .fontSize(this.tableName === '等级统计表' ? 24 : 26)
                .fontColor(this.getCurrentTheme().tableHeaderTextColor ?? this.getCurrentTheme().textColor)
                .fontWeight(FontWeight.Bold)
                .textAlign(TextAlign.Center)
                .layoutWeight(1)
                .padding(10)
                .backgroundColor(this.getCurrentTheme().tableHeaderBg ?? this.getCurrentTheme().surfaceColor)
                .border({ width: { right: 1 }, color: this.getCurrentTheme().borderColor })
                .draggable(this.enableDrag)
                .onDragStart((event: DragEvent, extraParams: string): DragItemInfo => {
                  if (!this.enableDrag) {
                    return { pixelMap: undefined, builder: undefined, extraInfo: '' }
                  }
                  return this.handleColumnDragStart(idx, title)
                })
                .onDragEnd(() => {
                  if (!this.enableDrag) {
                    return
                  }
                  this.handleDragEnd()
                })
            }
          })
        }
        .width('100%')

        // 数据行（可滚动区域）
        Scroll() {
          Column() {
            ForEach(this.tableRows, (row: TableRow, rowIndex: number) => {
              Row() {
                ForEach(row, (cellText: string, colIndex: number) => {
                  this.buildCustomCell(cellText, rowIndex, colIndex)
                })
              }
              .width('100%')
              .draggable(this.enableDrag)
              .onDragStart((event: DragEvent, extraParams: string): DragItemInfo => {
                if (!this.enableDrag) {
                  return { pixelMap: undefined, builder: undefined, extraInfo: '' }
                }
                return this.handleRowDragStart(rowIndex)
              })
              .onDragEnd(() => {
                if (!this.enableDrag) {
                  return
                }
                this.handleDragEnd()
              })
            })
          }
          .width('100%')
        }
        .width('100%')
        .height(this.maxHeight)
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Auto)
        .scrollBarColor(this.getCurrentTheme().borderColor)
        .scrollBarWidth(6)
        .friction(0.6) // 进一步减少摩擦系数，提升流畅度
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width(this.tableWidth)
    .backgroundColor(this.containerBg || this.getCurrentTheme().surfaceColor)
    .border({ width: 1, color: this.getCurrentTheme().borderColor })
    .borderRadius(12)
    .padding(12)
    .margin({ top: 12, left: 12, right: 12, bottom: 8 })
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .focusable(true)
    .onKeyEvent((event) => {
      // 只要检测到左 Ctrl（按下/抬起都会进来）就打印
      if (event.keyCode === KeyCode.KEYCODE_CTRL_LEFT) {
        console.log('按了左Ctrl');
      }
    })
  }
}
