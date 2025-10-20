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

// 拖拽数据接口
interface DragData {
  rowIndex: number
  colIndex: number
  value: string
  sourceTable: string
}

@Component
export struct GridTable {
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

  // 当前主题样式
  private currentTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()

  /**
   * 获取当前主题配置
   */
  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return this.currentTheme
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

    const dragData: DragData = {
      rowIndex,
      colIndex,
      value: cellValue,
      sourceTable: this.tableName
    }

    const dragDataStr = JSON.stringify(dragData)
    console.log('🚀 GridTable - 开始拖拽:', dragDataStr)

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

    const fromRowIndex = fromData.rowIndex
    const fromColIndex = fromData.colIndex

    // 如果是同一个单元格，不处理
    if (fromRowIndex === toRowIndex && fromColIndex === toColIndex) {
      return
    }

    console.log('🎯 GridTable - 拖拽交换:', fromData, '到', toRowIndex, toColIndex)

    // 交换单元格内容
    const fromValue = this.tableRows[fromRowIndex][fromColIndex]
    const toValue = this.tableRows[toRowIndex][toColIndex]

    // 创建新的数据数组（保持响应式）
    const newTableRows = this.tableRows.map((row, rowIdx) => {
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

    // 更新数据
    this.tableRows = newTableRows
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
      .fontSize(24)
      .fontColor(this.getCurrentTheme().textColor)
      .textAlign(TextAlign.Center)
      .width('100%')
      .height('100%')
      .backgroundColor(this.getCurrentTheme().surfaceColor)
      .border({ 
        width: { right: 1, bottom: 1 }, 
        color: this.getCurrentTheme().borderColor 
      })
      .padding(8)
  }

  /**
   * 构建表头单元格
   */
  @Builder
  private buildHeaderCell(title: string, colIndex: number) {
    Text(title)
      .fontSize(26)
      .fontWeight(FontWeight.Bold)
      .fontColor(this.getCurrentTheme().textColor)
      .textAlign(TextAlign.Center)
      .width('100%')
      .height('100%')
      .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
      .border({ 
        width: { right: 1, bottom: 1 }, 
        color: this.getCurrentTheme().borderColor 
      })
      .padding(10)
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

      // 表格容器
      Column() {
        // 固定表头Grid
        Grid() {
          ForEach(this.headerTitles, (title: string, colIndex: number) => {
            GridItem() {
              this.buildHeaderCell(title, colIndex)
            }
          })
        }
        .columnsTemplate(this.getColumnsTemplate())
        .columnsGap(0)
        .rowsGap(0)
        .width('100%')
        .height(50)

        // 可滚动数据区域
        Scroll() {
          Grid() {
            ForEach(this.tableRows, (row: TableRow, rowIndex: number) => {
              ForEach(row, (cellValue: string, colIndex: number) => {
                GridItem() {
                  this.buildTableCell(cellValue, rowIndex, colIndex)
                }
                .draggable(this.enableDrag)
                .onDragStart((event: DragEvent, extraParams: string): DragItemInfo => {
                  return this.handleDragStart(rowIndex, colIndex, cellValue)
                })
                .onDrop((event: DragEvent, extraParams: string) => {
                  try {
                    const dragData: DragData = JSON.parse(extraParams)
                    this.handleDrop(dragData, rowIndex, colIndex)
                  } catch (error) {
                    console.error('拖拽数据解析失败:', error)
                  }
                })
              })
            })
          }
          .columnsTemplate(this.getColumnsTemplate())
          .columnsGap(0)
          .rowsGap(0)
          .width('100%')
        }
        .width('100%')
        .height(this.maxHeight)
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Auto)
        .scrollBarColor(this.getCurrentTheme().borderColor)
        .scrollBarWidth(6)
        .friction(0.6)
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
  }
}
