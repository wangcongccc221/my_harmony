/**
 * 拖拽处理器
 * 功能：统一处理拖拽事件和逻辑
 * 用途：提供标准化的拖拽事件处理函数
 */

import { DragManager, DragData, MultiSelectDragData, DragResult } from './DragManager'

/**
 * 拖拽处理器类
 * 提供统一的拖拽事件处理逻辑
 */
export class DragHandlers {
  private dragManager: DragManager

  constructor() {
    this.dragManager = DragManager.getInstance()
  }

  /**
   * 处理拖拽开始事件
   * @param data 拖拽数据
   * @param isMultiSelect 是否多选
   */
  public handleDragStart(data: DragData | MultiSelectDragData, isMultiSelect: boolean = false): void {
    if (!this.dragManager.validateDragData(data)) {
      console.error('❌ 拖拽数据验证失败:', data)
      return
    }

    this.dragManager.startDrag(data, isMultiSelect)
  }

  /**
   * 处理拖拽结束事件
   * @param onDelete 删除回调函数
   * @param onCopy 复制回调函数
   * @param delay 延迟时间（毫秒）
   */
  public handleDragEnd(
    onDelete?: () => void,
    onCopy?: () => void,
    delay: number = 50
  ): void {
    // 使用延迟确保目标组件的onDrop先执行
    setTimeout(() => {
      const isHandled = this.dragManager.isDropHandled()
      
      if (isHandled) {
        // 拖拽被处理（复制模式）
        console.log('🟢 拖拽被处理，执行复制逻辑')
        if (onCopy) {
          onCopy()
        }
      } else {
        // 拖拽未被处理（删除模式）
        console.log('🟡 拖拽未被处理，执行删除逻辑')
        if (onDelete) {
          onDelete()
        }
      }

      // 结束拖拽
      this.dragManager.endDrag()
    }, delay)
  }

  /**
   * 处理拖拽投放事件
   * @param targetId 目标ID
   * @param isHandled 是否被处理
   */
  public handleDrop(targetId: string, isHandled: boolean = true): void {
    this.dragManager.handleDrop(targetId, isHandled)
  }

  /**
   * 处理第三层拖拽投放
   * @param data 拖拽数据
   * @param targetCardId 目标卡片ID
   * @param isFromCard 是否来自其他卡片
   * @param isFromTable 是否来自表格
   */
  public handleThirdLayerDrop(
    data: DragData,
    targetCardId: string,
    isFromCard: boolean,
    isFromTable: boolean
  ): void {
    if (isFromCard) {
      // 从其他卡片拖拽：复制模式
      console.log('🟢 复制模式 移动内容:', data.value)
      this.dragManager.setThirdLayerInfo(data)
      this.dragManager.handleDrop(targetCardId, true)
    } else if (isFromTable) {
      // 从表格拖拽：内容不变
      console.log('🟢 内容不变 移动内容:', data.value)
      this.dragManager.handleDrop(targetCardId, true)
    } else {
      // 其他情况：移动非卡片区域
      console.log('🟡 移动非卡片区域 移动内容:', data.value)
      this.dragManager.handleDrop(targetCardId, false)
    }
  }

  /**
   * 处理卡片外层拖拽投放
   * @param targetCardId 目标卡片ID
   * @param data 拖拽数据
   */
  public handleCardOuterDrop(targetCardId: string, data: DragData): void {
    console.log('🟢 内容不变 移动内容:', data.value)
    this.dragManager.handleDrop(targetCardId, true)
  }

  /**
   * 处理表格拖拽投放
   * @param data 拖拽数据
   * @param isMultiSelect 是否多选
   */
  public handleTableDrop(data: DragData | MultiSelectDragData, isMultiSelect: boolean = false): void {
    if (isMultiSelect) {
      const multiData = data as MultiSelectDragData
      console.log('🟢 内容不变 移动内容:', `多选${multiData.count}项`)
    } else {
      const singleData = data as DragData
      console.log('🟢 内容不变 移动内容:', singleData.value)
    }
    
    this.dragManager.handleDrop('table', true)
  }

  /**
   * 处理拖拽到空白区域
   * @param data 拖拽数据
   */
  public handleBlankAreaDrop(data: DragData | MultiSelectDragData): void {
    if (data.type === 'multi_select') {
      const multiData = data as MultiSelectDragData
      console.log('🟡 移动非卡片区域 移动内容:', `多选${multiData.count}项`)
    } else {
      const singleData = data as DragData
      console.log('🟡 移动非卡片区域 移动内容:', singleData.value)
    }
    
    this.dragManager.handleDrop('blank', false)
  }

  /**
   * 创建拖拽数据
   * @param value 值
   * @param sourceTable 源表格
   * @param rowIndex 行索引
   * @param colIndex 列索引
   * @param sourceCardId 源卡片ID
   * @param sourceValue 源值
   * @param itemIndex 项目索引
   */
  public createDragData(
    value: string,
    sourceTable: string,
    rowIndex?: number,
    colIndex?: number,
    sourceCardId?: string,
    sourceValue?: string,
    itemIndex?: number
  ): DragData {
    return {
      value,
      sourceTable,
      rowIndex,
      colIndex,
      sourceCardId,
      sourceValue,
      itemIndex
    }
  }

  /**
   * 创建多选拖拽数据
   * @param cells 单元格数组
   */
  public createMultiSelectDragData(cells: Array<{
    rowIndex: number
    colIndex: number
    value: string
    sourceTable: string
  }>): MultiSelectDragData {
    return {
      type: 'multi_select',
      cells,
      count: cells.length
    }
  }

  /**
   * 解析拖拽数据字符串
   * @param dataStr 数据字符串
   */
  public parseDragData(dataStr: string): DragData | MultiSelectDragData | null {
    return this.dragManager.deserializeDragData(dataStr)
  }

  /**
   * 检查是否来自其他卡片
   * @param sourceCardId 源卡片ID
   * @param targetCardId 目标卡片ID
   * @param sourceTable 源表格
   */
  public isFromOtherCard(sourceCardId: string, targetCardId: string, sourceTable: string): boolean {
    return (
      (sourceCardId && String(sourceCardId) !== String(targetCardId)) ||
      (sourceTable === 'card_third_layer' && String(sourceCardId) !== String(targetCardId))
    )
  }

  /**
   * 检查是否来自表格
   * @param sourceTable 源表格
   */
  public isFromTable(sourceTable: string): boolean {
    return sourceTable === '等级表' || sourceTable === 'card_third_layer'
  }
}
