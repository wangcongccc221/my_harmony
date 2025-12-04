/**
 * Grid表格组件 - 支持拖拽功能
 * 
 * 功能说明：
 * - 使用Grid组件实现表格布局
 * - 支持拖拽交换单元格内容
 * - 固定表头，可滚动数据区域
 * - 兼容原有的TableRow数据结构
 * 
 * 基于华为官方最佳实践：
 * https://developer.huawei.com/consumer/cn/doc/best-practices/bpta-grid-drag-swap
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { TableRow } from './LevelTable'
import { MultiSelectCell, MultiSelectState } from '../ThreeLayerCard/types'
import { StorageKeys } from '../../utils/constants/StorageKeys'
import { HomeDataManager } from '../../pages/home/core/HomeDataManager'

// 拖拽数据接口
interface DragData {
  rowIndex: number
  colIndex: number
  value: string
  sourceTable: string
  fullRowData?: string // 完整行数据（用于整行拖拽）
  fullColumnData?: string // 完整列数据（用于整列拖拽）
  levelName?: string // 等级名称（用于等级统计表联动）
  levelNames?: string[] // 等级名称数组（用于整列拖拽联动）
}

@Component
export struct GridTable {
  // 表格名字 - 用于数据管理
  @Prop tableName: string = 'default'
  // 是否允许拖拽（默认true，主页可按业务关闭）
  @Prop enableDrag: boolean = true
  
  // 导入HomeDataManager
  private homeDataManager: HomeDataManager = HomeDataManager.getInstance()
  
  // 多选状态管理
  @State private selectedCells: Set<string> = new Set()
  @State private isMultiSelectMode: boolean = false
  
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
  
  // 表头行高（可配置）
  @Prop headerHeight: number = 50
  
  // 数据行行高（可配置）
  @Prop dataRowHeight: number = 65
  
  // 分割线高度（可配置）
  @Prop dividerHeight: number = 50
  
  // 边框宽度（可配置）
  @Prop customBorderWidth: number = 1
  
  // 是否启用滚动（可配置）
  @Prop enableScroll: boolean = false 

  // 当前主题样式
  private currentTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()

  /**
   * 获取当前主题配置
   */
  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return this.currentTheme
  }

  /**
   * 等级/容器名称列禁用拖拽判定
   */
  private isDragDisabledForCell(colIndex: number): boolean {
    const header = this.headerTitles[colIndex]
    if (this.tableTitle === '等级表' && header === '等级') return true
    if (this.tableTitle === '容器表' && header === '容器名称') return true
    return false
  }


  /**
   * 切换单元格选中状态
   */
  private toggleCellSelection(rowIndex: number, colIndex: number, cellText: string) {
    if (!this.enableDrag) {
      return
    }
    
    const cellId = `${rowIndex}_${colIndex}`

    // 从 AppStorage 读取是否按下左 Ctrl（由页面级监听维护）
    const ctrlPressedRaw = AppStorage.get('HOME_CTRL_PRESSED') as boolean | undefined
    const isCtrlMultiSelect = ctrlPressedRaw === true

    if (isCtrlMultiSelect) {
      // Ctrl 多选模式：点击时切换当前单元格选中状态（不清空其他）
      if (this.selectedCells.has(cellId)) {
        // 取消选中
        this.selectedCells.delete(cellId)
      } else {
        // 追加选中
        this.selectedCells.add(cellId)
      }
    } else {
      // 单选模式：清空已有选中，只保留当前单元格
      this.selectedCells.clear()
      this.selectedCells.add(cellId)
    }

    // 更新多选模式状态
    this.isMultiSelectMode = this.selectedCells.size > 1
    
    // 更新全局多选状态
    this.updateGlobalMultiSelectState()
    
  }

  /**
   * 更新全局多选状态
   */
  private updateGlobalMultiSelectState() {
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
    
    AppStorage.set(StorageKeys.MULTI_SELECT_CELLS_KEY, multiSelectState)
    AppStorage.set(StorageKeys.MULTI_SELECT_ACTIVE_KEY, multiSelectState.isActive)
    
  }

  /**
   * 清除所有选中状态
   */
  private clearAllSelections() {
    this.selectedCells.clear()
    this.isMultiSelectMode = false
    
    // 清除全局多选状态
    AppStorage.set(StorageKeys.MULTI_SELECT_CELLS_KEY, { cells: [], isActive: false })
    AppStorage.set(StorageKeys.MULTI_SELECT_ACTIVE_KEY, false)
    
  }

  /**
   * 检查单元格是否被选中
   */
  private isCellSelected(rowIndex: number, colIndex: number): boolean {
    const cellId = `${rowIndex}_${colIndex}`
    return this.selectedCells.has(cellId)
  }

  /**
   * 获取列模板字符串
   * 根据表头数量动态生成等宽列模板
   */
  private getColumnsTemplate(): string {
    const columnCount = this.headerTitles.length
    return Array(columnCount).fill('1fr').join(' ')
  }

  /**
   * 处理拖拽开始事件
   * 基于华为官方最佳实践实现
   */
  private handleDragStart(rowIndex: number, colIndex: number, cellValue: string): DragItemInfo {
    if (!this.enableDrag) {
      return { pixelMap: undefined, builder: undefined, extraInfo: '' }
    }

    // 检查是否有多个选中的单元格
    if (this.isMultiSelectMode && this.selectedCells.size > 1) {
      // 多选拖拽：使用所有选中的单元格数据
      
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
      
      // 优化多选拖拽数据格式，减少数据量
      const values = selectedCellsArray.map(cell => cell.value)
      // 收集所有涉及的等级名称（从第一列获取）
      const levelNames = selectedCellsArray.map(cell => this.tableRows[cell.rowIndex]?.[0] || '')
      const dragDataStr = JSON.stringify({
        type: 'multi_select',
        values: values,
        levelNames: levelNames, // 添加等级名称数组
        count: selectedCellsArray.length
      })
      
      
      // 拖拽完成后清除选中状态
      setTimeout(() => {
        this.clearAllSelections()
      }, 100)
      
      return {
        pixelMap: undefined,
        builder: undefined,
        extraInfo: dragDataStr
      }
    } else {
      // 单选拖拽：使用当前单元格数据
      // 获取当前行的等级名称（第一列的值）
      const levelName = this.tableRows[rowIndex]?.[0] || ''
      
      const dragData: DragData = {
        rowIndex,
        colIndex,
        value: cellValue,
        sourceTable: this.tableName,
        levelName: levelName // 添加等级名称字段，用于等级统计表联动
      }

    const dragDataStr = JSON.stringify(dragData)

      return {
        pixelMap: undefined,
        builder: undefined,
        extraInfo: dragDataStr
      }
    }
  }

  /**
   * 处理整行拖拽开始
   */
  private handleRowDragStart(rowIndex: number, row: TableRow): DragItemInfo {
    if (!this.enableDrag) {
      return { pixelMap: undefined, builder: undefined, extraInfo: '' }
    }

    // 对于整行拖拽，我们传递第一列的值作为主要标识
    const primaryValue = row[0] || ''
    
    // 排除第一列（等级名称），只传递后面的数据内容
    const dataWithoutFirstColumn = row.slice(1)
    
    const dragData: DragData = {
      rowIndex,
      colIndex: -1, // -1表示整行拖拽
      value: primaryValue,
      sourceTable: this.tableName,
      fullRowData: JSON.stringify(dataWithoutFirstColumn), // 排除第一列的数据
      levelName: primaryValue // 添加等级名称字段，用于等级统计表联动
    }

    const dragDataStr = JSON.stringify(dragData)

    return {
      pixelMap: undefined,
      builder: undefined,
      extraInfo: dragDataStr
    }
  }

  /**
   * 处理拖拽放置事件
   * 实现单元格内容交换
   */
  private handleDrop(fromData: DragData, toRowIndex: number, toColIndex: number): void {
    if (!this.enableDrag) return

    const fromRowIndex = fromData.rowIndex || 0
    const fromColIndex = fromData.colIndex || 0

    // 如果是同一个单元格且是同一表格，不处理
    const isSameTable = fromData.sourceTable === this.tableName
    if (fromRowIndex === toRowIndex && fromColIndex === toColIndex && isSameTable) {
      return
    }

    // 检查是否是跨表格拖拽
    const isCrossTableDrag = fromData.sourceTable && fromData.sourceTable !== this.tableName
    const isLevelToContainer = fromData.sourceTable === '等级表' && this.tableName === '容器表'
    const isContainerToLevel = fromData.sourceTable === '容器表' && this.tableName === '等级表'
    
    // 获取源值和目标值
    const fromValue = this.tableRows[fromRowIndex][fromColIndex]
    const toValue = this.tableRows[toRowIndex][toColIndex]

    let newTableRows: string[][]

    if (isLevelToContainer || isContainerToLevel) {
      // 跨表格拖拽：覆盖模式（使用拖拽数据中的value）
      const dragValue = fromData.value || fromValue
      newTableRows = this.tableRows.map((row, rowIdx) => {
        if (rowIdx === toRowIndex) {
          return row.map((cell, colIdx) => {
            if (colIdx === toColIndex) {
              return dragValue // 使用拖拽数据中的值覆盖
            }
            return cell
          })
        }
        return row
      })
      console.log(`跨表格拖拽: ${fromData.sourceTable} -> ${this.tableName}, 值: ${dragValue}`)
    } else {
      // 同表格内拖拽：交换模式
      newTableRows = this.tableRows.map((row, rowIdx) => {
        if (rowIdx === fromRowIndex) {
          return row.map((cell, colIdx) => {
            if (colIdx === fromColIndex) {
              return toValue
            }
            return cell
          })
        } else if (rowIdx === toRowIndex) {
          return row.map((cell, colIdx) => {
            if (colIdx === toColIndex) {
              return fromValue
            }
            return cell
          })
        }
        return row
      })
    }

    // 更新数据
    this.tableRows = newTableRows
    
    // 直接保存到HomeDataManager
    this.homeDataManager.updateFSMTableData(this.tableName, newTableRows)
    console.log(`GridTable ${this.tableName} 已更新HomeDataManager数据，当前FSM: ${this.homeDataManager.getCurrentFSM()}`)
    
    // 验证数据是否已保存
    const savedData = this.homeDataManager.getTableData(this.tableName)
    console.log(`GridTable ${this.tableName} 验证保存的数据:`, savedData)
  }

  /**
   * 处理整行拖拽放置事件
   * 实现整行交换
   */
  private handleRowDrop(fromData: DragData, toRowIndex: number): void {
    if (!this.enableDrag) return

    const fromRowIndex = fromData.rowIndex || 0

    // 如果是同一行且是同一表格，不处理
    const isSameTable = fromData.sourceTable === this.tableName
    if (fromRowIndex === toRowIndex && isSameTable) {
      return
    }

    // 检查索引是否有效
    if (fromRowIndex < 0 || fromRowIndex >= this.tableRows.length || 
        toRowIndex < 0 || toRowIndex >= this.tableRows.length) {
      return
    }

    // 检查是否是跨表格拖拽
    const isLevelToContainer = fromData.sourceTable === '等级表' && this.tableName === '容器表'
    const isContainerToLevel = fromData.sourceTable === '容器表' && this.tableName === '等级表'

    // 获取完整的行数据
    const fromRow = [...this.tableRows[fromRowIndex]] // 深拷贝
    const toRow = [...this.tableRows[toRowIndex]] // 深拷贝

    let newTableRows: string[][]

    if (isLevelToContainer || isContainerToLevel) {
      // 跨表格拖拽：覆盖模式（根据拖拽值决定替换哪一列）
      const dragValue = fromData.value || fromRow[0]
      
      // 根据拖拽值决定替换策略
      newTableRows = this.tableRows.map((row, rowIdx) => {
        if (rowIdx === toRowIndex) {
          // 如果是等级名称（A级、B级等），替换第一列（容器名称）
          if (dragValue.includes('级')) {
            return row.map((cell, colIdx) => {
              if (colIdx === 0) {
                return dragValue // 替换容器名称
              }
              return cell
            })
          } else {
            // 如果是其他数据，替换整行
            return fromRow
          }
        }
        return row
      })
      console.log(`跨表格行拖拽: ${fromData.sourceTable} -> ${this.tableName}, 值: ${dragValue}`)
    } else {
      // 同表格内拖拽：交换模式
      newTableRows = this.tableRows.map((row, rowIdx) => {
        if (rowIdx === fromRowIndex) {
          return toRow
        } else if (rowIdx === toRowIndex) {
          return fromRow
        }
        return row
      })
    }

    // 更新数据
    this.tableRows = newTableRows
    
    // 直接保存到HomeDataManager
    this.homeDataManager.updateFSMTableData(this.tableName, newTableRows)
  }

  /**
   * 处理整列拖拽开始
   */
  private handleColumnDragStart(colIndex: number): DragItemInfo {
    if (!this.enableDrag) {
      return { pixelMap: undefined, builder: undefined, extraInfo: '' }
    }

    // 获取整列数据
    const columnData = this.tableRows.map(row => row[ colIndex])
    // 获取对应的等级名称（每行的第一列）
    const levelNames = this.tableRows.map(row => row[0] || '')
    
    const dragData: DragData = {
      rowIndex: -1, // -1表示整列拖拽
      colIndex,
      value: this.headerTitles[colIndex] || '',
      sourceTable: this.tableName,
      fullColumnData: JSON.stringify(columnData),
      levelNames: levelNames // 添加等级名称数组，用于等级统计表联动
    }

    const dragDataStr = JSON.stringify(dragData)

    return {
      pixelMap: undefined,
      builder: undefined,
      extraInfo: dragDataStr
    }
  }

  /**
   * 处理整列拖拽放置事件
   * 实现整列交换
   */
  private handleColumnDrop(fromData: DragData, toColIndex: number): void {
    if (!this.enableDrag) return

    const fromColIndex = fromData.colIndex

    // 如果是同一列，不处理
    if (fromColIndex === toColIndex) {
      return
    }


    // 检查列索引是否有效
    if (fromColIndex < 0 || fromColIndex >= this.headerTitles.length ||
        toColIndex < 0 || toColIndex >= this.headerTitles.length) {
      return
    }

    // 检查表格数据是否为空
    if (this.tableRows.length === 0) {
      return
    }

    // 交换整列数据
    const newTableRows = this.tableRows.map(row => {
      const newRow = [...row]
      // 确保列索引有效
      if (fromColIndex < newRow.length && toColIndex < newRow.length) {
        const temp = newRow[fromColIndex]
        newRow[fromColIndex] = newRow[toColIndex]
        newRow[toColIndex] = temp
      }
      return newRow
    })

    // 交换表头
    const newHeaderTitles = [...this.headerTitles]
    // 确保表头索引有效
    if (fromColIndex < newHeaderTitles.length && toColIndex < newHeaderTitles.length) {
      const temp = newHeaderTitles[fromColIndex]
      newHeaderTitles[fromColIndex] = newHeaderTitles[toColIndex]
      newHeaderTitles[toColIndex] = temp
    }

    // 更新数据
    this.tableRows = newTableRows
    this.headerTitles = newHeaderTitles
  }

  /**
   * 构建拖拽预览
   */
  @Builder
  private buildDragPreview(cellValue: string) {
    Text(cellValue)
      .fontSize(24)
      .fontColor(Color.White)
      .backgroundColor('#007DFF')
      .padding(8)
      .borderRadius(6)
      .shadow({ radius: 8, color: 'rgba(0,0,0,0.3)', offsetY: 2 })
  }

  /**
   * 构建表格单元格
   */
  @Builder
  private buildTableCell(cellValue: string, rowIndex: number, colIndex: number) {
    Text(cellValue)
      .fontSize(16)
      .fontColor(this.getCurrentTheme().textColor)
      .textAlign(TextAlign.Center)
      .layoutWeight(1)
      .height('100%')
      .backgroundColor(this.isCellSelected(rowIndex, colIndex) ? '#E3F2FD' : (this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)) // 选中时高亮背景
      .border({
        width: { right: this.customBorderWidth, bottom: this.customBorderWidth },
        color: this.isCellSelected(rowIndex, colIndex) ? '#2196F3' : this.getCurrentTheme().borderColor // 选中时蓝色边框
      })
      .padding(2)
      .draggable(this.enableDrag && !this.isDragDisabledForCell(colIndex))
      .onClick(() => {
        // 点击切换选中状态
        this.toggleCellSelection(rowIndex, colIndex, cellValue)
      })
      .onDragStart((event: DragEvent, extraParams: string): DragItemInfo => {
        return this.handleDragStart(rowIndex, colIndex, cellValue)
      })
      .onDrop((event: DragEvent, extraParams: string) => {
        try {
          const rawData: Record<string, string> = JSON.parse(extraParams)
          const dragData: DragData = rawData.extraInfo ? JSON.parse(rawData.extraInfo) : rawData
          this.handleDrop(dragData, rowIndex, colIndex)
        } catch (error) {
          console.error('拖拽数据解析失败:', error)
        }
      })
  }

  /**
   * 构建表头单元格
   */
  @Builder
  private buildHeaderCell(title: string, colIndex: number) {
    Text(title)
      .fontSize(18)
      .fontWeight(FontWeight.Bold)
      .fontColor(this.getCurrentTheme().tableHeaderTextColor ?? this.getCurrentTheme().textColor)
      .textAlign(TextAlign.Center)
      .width('100%')
      .height('100%')
      .backgroundColor(this.getCurrentTheme().tableHeaderBg ?? this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
      .border({
        width: { right: this.customBorderWidth, bottom: this.customBorderWidth },
        color: this.getCurrentTheme().borderColor
      })
      .padding(2)
  }

  /**
   * 构建表头左上角空白区域
   */
  @Builder
  private buildHeaderCorner() {
    Text('')
      .width(40)
      .height('100%')
      .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
      .border({
        width: { right: this.customBorderWidth, bottom: this.customBorderWidth },
        color: this.getCurrentTheme().borderColor
      })
  }

  /**
   * 构建列头 - 支持整列拖拽
   */
  @Builder
  private buildColumnHeader(title: string, colIndex: number) {
    Text(title)
      .fontSize(20)
      .fontWeight(FontWeight.Bold)
      .fontColor(this.getCurrentTheme().tableHeaderTextColor ?? this.getCurrentTheme().textColor)
      .textAlign(TextAlign.Center)
      .layoutWeight(1)
      .height('100%')
      .backgroundColor(this.getCurrentTheme().tableHeaderBg ?? this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
      .border({
        width: { right: this.customBorderWidth, bottom: this.customBorderWidth },
        color: this.getCurrentTheme().borderColor
      })
      .padding(6)
      .draggable(this.enableDrag && !this.isDragDisabledForCell(colIndex))
      .onDragStart((event: DragEvent, extraParams: string): DragItemInfo => {
        return this.handleColumnDragStart(colIndex)
      })
      .onDrop((event: DragEvent, extraParams: string) => {
        try {
          const dragData: DragData = JSON.parse(extraParams)
          this.handleColumnDrop(dragData, colIndex)
        } catch (error) {
          console.error('拖拽数据解析失败:', error)
        }
      })
  }

  /**
   * 构建第一列单元格 - 支持整行拖拽
   */
  @Builder
  private buildRowDragCell(cellValue: string, rowIndex: number, colIndex: number) {
    Text(cellValue)
      .fontSize(16)
      .fontColor(this.getCurrentTheme().textColor)
      .textAlign(TextAlign.Center)
      .layoutWeight(1)
      .height('100%')
      .backgroundColor(this.isCellSelected(rowIndex, colIndex) ? '#E3F2FD' : (this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)) // 选中时高亮背景
      .border({
        width: { right: this.customBorderWidth, bottom: this.customBorderWidth },
        color: this.isCellSelected(rowIndex, colIndex) ? '#2196F3' : this.getCurrentTheme().borderColor // 选中时蓝色边框
      })
      .padding(2)
      .draggable(this.enableDrag)
      .onClick(() => {
        // 点击切换选中状态
        this.toggleCellSelection(rowIndex, colIndex, cellValue)
      })
      .onDragStart((event: DragEvent, extraParams: string): DragItemInfo => {
        return this.handleRowDragStart(rowIndex, this.tableRows[rowIndex])
      })
      .onDrop((event: DragEvent, extraParams: string) => {
        try {
          const rawData: Record<string, string> = JSON.parse(extraParams)
          const dragData: DragData = rawData.extraInfo ? JSON.parse(rawData.extraInfo) : rawData
          this.handleRowDrop(dragData, rowIndex)
        } catch (error) {
          console.error('拖拽数据解析失败:', error)
        }
      })
  }

  build() {
    Column() {
      // 表格标题
      Text(this.tableTitle)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.getCurrentTheme().textColor)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 4 })

      // 表格容器
      Column() {
        // 固定表头
        Row() {
          // 列头 - 整列拖拽
          ForEach(this.headerTitles, (title: string, colIndex: number) => {
            this.buildColumnHeader(title, colIndex)
          })
        }
        .width('100%')
        .height(this.headerHeight) 

        // 可滚动数据区域
        Scroll() {
          Column() {
            ForEach(this.tableRows, (row: TableRow, rowIndex: number) => {
              Row() {
                // 数据单元格 - 第一列支持整行拖拽，其他列支持单格拖拽
                ForEach(row, (cellValue: string, colIndex: number) => {
                  if (colIndex === 0) {
                    // 第一列（如"A级"、"B级"）支持整行拖拽
                    this.buildRowDragCell(cellValue, rowIndex, colIndex)
                  } else {
                    // 其他列支持单格拖拽
                    this.buildTableCell(cellValue, rowIndex, colIndex)
                  }
                })
              }
              .width('100%')
              .height(this.dataRowHeight)
            })
          }
          .width('100%')
        }
        .width('100%')
        .height(this.maxHeight)
        .scrollable(this.enableScroll ? ScrollDirection.Vertical : ScrollDirection.None)
        .scrollBar(this.enableScroll ? BarState.Auto : BarState.Off)
        .scrollBarColor(this.getCurrentTheme().borderColor)
        .scrollBarWidth(6)
        .friction(0.6)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width(this.tableWidth)
    .backgroundColor(this.containerBg || (this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor))
    .border({ width: 1, color: this.getCurrentTheme().borderColor })
    .borderRadius(6)
    .padding(4)
    .margin({ top: 4, left: 4, right: 4, bottom: 2 })
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}
