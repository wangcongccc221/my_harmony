/**
 * 拖拽管理器
 * 功能：统一管理拖拽状态、数据和事件处理
 * 用途：减少拖拽相关代码重复，提供统一的拖拽API
 */

// AppStorage is globally available

// 拖拽数据接口
export interface DragData {
  value: string
  sourceTable: string
  rowIndex?: number
  colIndex?: number
  sourceCardId?: string
  sourceValue?: string
  itemIndex?: number
  levelName?: string // 添加等级名称字段
}

// 多选单元格接口
export interface MultiSelectCell {
  rowIndex: number
  colIndex: number
  value: string
  sourceTable: string
}

// 多选拖拽数据接口
export interface MultiSelectDragData {
  type: 'multi_select'
  cells: MultiSelectCell[]
  count: number
}

// 移除源数据接口
export interface RemoveSourceData {
  sourceCardId: string
  sourceValue: string
}

// 拖拽状态枚举
export enum DragStatus {
  IDLE = 'idle',
  DRAGGING = 'dragging',
  DROPPING = 'dropping'
}

// 拖拽结果枚举
export enum DragResult {
  SUCCESS = 'success',
  FAILED = 'failed',
  CANCELLED = 'cancelled'
}

// 全局拖拽存储键接口
export interface DragStorageKeys {
  GLOBAL_DROP_HANDLED: string
  GLOBAL_DROP_VALUE: string
  GLOBAL_DROP_THIRD_INFO: string
  REMOVE_SOURCE_DATA: string
  CELL_DRAG_ACTIVE_KEY: string
  MULTI_SELECT_CELLS_KEY: string
  CLEAR_ALL_HIGHLIGHTS_KEY: string
}

// 全局拖拽存储键
export const DRAG_STORAGE_KEYS: DragStorageKeys = {
  GLOBAL_DROP_HANDLED: 'GLOBAL_DROP_HANDLED',
  GLOBAL_DROP_VALUE: 'GLOBAL_DROP_VALUE',
  GLOBAL_DROP_THIRD_INFO: 'GLOBAL_DROP_THIRD_INFO',
  REMOVE_SOURCE_DATA: 'REMOVE_SOURCE_DATA',
  CELL_DRAG_ACTIVE_KEY: 'CELL_DRAG_ACTIVE_KEY',
  MULTI_SELECT_CELLS_KEY: 'MULTI_SELECT_CELLS_KEY',
  CLEAR_ALL_HIGHLIGHTS_KEY: 'CLEAR_ALL_HIGHLIGHTS_KEY'
}

/**
 * 拖拽管理器
 * 提供统一的拖拽状态管理和数据处理
 */
export class DragManager {
  private static instance: DragManager
  private currentStatus: DragStatus = DragStatus.IDLE
  private dragData: DragData | null = null
  private multiSelectData: MultiSelectDragData | null = null

  private constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): DragManager {
    if (!DragManager.instance) {
      DragManager.instance = new DragManager()
    }
    return DragManager.instance
  }

  /**
   * 开始拖拽
   * @param data 拖拽数据
   * @param isMultiSelect 是否多选拖拽
   */
  public startDrag(data: DragData | MultiSelectDragData, isMultiSelect: boolean = false): void {
    this.currentStatus = DragStatus.DRAGGING

    if (isMultiSelect) {
      this.multiSelectData = data as MultiSelectDragData
      this.dragData = null
    } else {
      this.dragData = data as DragData
      this.multiSelectData = null
    }

    // 设置全局状态
    // 注意：不重置GLOBAL_DROP_HANDLED，因为ThirdLayer可能已经设置了它
    
    if (isMultiSelect) {
      const multiData = data as MultiSelectDragData
      AppStorage.set(DRAG_STORAGE_KEYS.GLOBAL_DROP_VALUE, JSON.stringify(multiData))
    } else {
      const singleData = data as DragData
      AppStorage.set(DRAG_STORAGE_KEYS.GLOBAL_DROP_VALUE, singleData.value)
    }

    console.log('🎯 拖拽管理器：开始拖拽', isMultiSelect ? '多选' : '单选')
  }

  /**
   * 结束拖拽
   * @param result 拖拽结果
   */
  public endDrag(result: DragResult = DragResult.SUCCESS): void {
    this.currentStatus = DragStatus.IDLE
    this.dragData = null
    this.multiSelectData = null

    // 清理全局状态
    this.clearGlobalState()
    
    console.log('🧹 拖拽管理器：结束拖拽，结果:', result)
  }

  /**
   * 处理拖拽投放
   * @param targetId 目标ID
   * @param isHandled 是否被处理
   */
  public handleDrop(targetId: string, isHandled: boolean = true): void {
    AppStorage.set(DRAG_STORAGE_KEYS.GLOBAL_DROP_HANDLED, isHandled)
    
    if (isHandled) {
      console.log('🟢 拖拽管理器：拖拽被处理，目标:', targetId)
    } else {
      console.log('🟡 拖拽管理器：拖拽未被处理，目标:', targetId)
    }
  }

  /**
   * 检查拖拽是否被处理
   */
  public isDropHandled(): boolean {
    return AppStorage.get(DRAG_STORAGE_KEYS.GLOBAL_DROP_HANDLED) as boolean || false
  }

  /**
   * 获取拖拽数据
   */
  public getDragData(): DragData | null {
    return this.dragData
  }

  /**
   * 获取多选拖拽数据
   */
  public getMultiSelectData(): MultiSelectDragData | null {
    return this.multiSelectData
  }

  /**
   * 获取当前拖拽状态
   */
  public getCurrentStatus(): DragStatus {
    return this.currentStatus
  }

  /**
   * 设置第三层拖拽信息
   * @param info 第三层拖拽信息
   */
  public setThirdLayerInfo(info: DragData): void {
    AppStorage.set(DRAG_STORAGE_KEYS.GLOBAL_DROP_THIRD_INFO, JSON.stringify(info))
  }

  /**
   * 获取第三层拖拽信息
   */
  public getThirdLayerInfo(): DragData | null {
    const infoStr = AppStorage.get(DRAG_STORAGE_KEYS.GLOBAL_DROP_THIRD_INFO) as string
    if (!infoStr) return null
    
    try {
      return JSON.parse(infoStr) as DragData
    } catch (error) {
      console.error('解析第三层拖拽信息失败:', error)
      return null
    }
  }

  /**
   * 设置移除源数据标志
   * @param sourceCardId 源卡片ID
   * @param sourceValue 源值
   */
  public setRemoveSourceData(sourceCardId: string, sourceValue: string): void {
    const removeData: RemoveSourceData = {
      sourceCardId,
      sourceValue
    }
    AppStorage.set(DRAG_STORAGE_KEYS.REMOVE_SOURCE_DATA, removeData)
  }

  /**
   * 获取移除源数据标志
   */
  public getRemoveSourceData(): RemoveSourceData | null {
    return AppStorage.get(DRAG_STORAGE_KEYS.REMOVE_SOURCE_DATA) as RemoveSourceData | null
  }

  /**
   * 清理全局状态
   */
  private clearGlobalState(): void {
    AppStorage.set(DRAG_STORAGE_KEYS.GLOBAL_DROP_HANDLED, false)
    AppStorage.set(DRAG_STORAGE_KEYS.GLOBAL_DROP_VALUE, '')
    AppStorage.set(DRAG_STORAGE_KEYS.GLOBAL_DROP_THIRD_INFO, '')
    AppStorage.set(DRAG_STORAGE_KEYS.REMOVE_SOURCE_DATA, null)
  }

  /**
   * 验证拖拽数据
   * @param data 拖拽数据
   */
  public validateDragData(data: DragData | MultiSelectDragData): boolean {
    if (!data) return false
    
    if (this.isMultiSelectData(data)) {
      const multiData = data as MultiSelectDragData
      return multiData.cells && Array.isArray(multiData.cells) && multiData.count > 0
    } else {
      const singleData = data as DragData
      return !!(singleData.value && singleData.sourceTable)
    }
  }

  /**
   * 检查是否为多选数据
   * @param data 拖拽数据
   */
  private isMultiSelectData(data: DragData | MultiSelectDragData): boolean {
    return (data as MultiSelectDragData).type === 'multi_select'
  }

  /**
   * 序列化拖拽数据
   * @param data 拖拽数据
   */
  public serializeDragData(data: DragData | MultiSelectDragData): string {
    return JSON.stringify(data)
  }

  /**
   * 反序列化拖拽数据
   * @param dataStr 数据字符串
   */
  public deserializeDragData(dataStr: string): DragData | MultiSelectDragData | null {
    try {
      return JSON.parse(dataStr)
    } catch (error) {
      console.error('反序列化拖拽数据失败:', error)
      return null
    }
  }
}

/**
 * 拖拽处理器
 * 提供统一的拖拽事件处理逻辑
 */
export class DragHandlers {
  private dragManager: DragManager

  constructor() {
    this.dragManager = DragManager.getInstance()
  }

  /**
   * 处理拖拽开始
   * @param data 拖拽数据
   */
  public handleDragStart(data: DragData): void {
    this.dragManager.startDrag(data, false)
  }

  /**
   * 处理拖拽结束
   * @param onDelete 删除回调
   * @param onCopy 复制回调
   */
  public handleDragEnd(onDelete: () => void, onCopy: () => void): void {
    // 使用setTimeout确保目标卡片的onDrop先执行
    setTimeout(() => {
      const isHandled = this.dragManager.isDropHandled()
      console.log('🔍 handleDragEnd - isDropHandled:', isHandled)
      
      if (!isHandled) {
        // 拖拽到空白区域，执行删除
        console.log('🗑️ 执行删除逻辑')
        onDelete()
      } else {
        // 拖拽到其他卡片，执行复制
        console.log('🟢 执行复制逻辑')
        onCopy()
      }
      
      this.dragManager.endDrag()
    }, 100) // 增加延迟时间从50ms到100ms
  }

  /**
   * 处理拖拽投放
   * @param targetId 目标ID
   * @param isHandled 是否被处理
   */
  public handleDrop(targetId: string, isHandled: boolean = true): void {
    this.dragManager.handleDrop(targetId, isHandled)
  }
}