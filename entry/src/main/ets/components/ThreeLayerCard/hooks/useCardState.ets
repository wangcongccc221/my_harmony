/**
 * 卡片状态管理 Hook
 * - 统一拖拽状态复位
 * - 统一父层数据同步（包装 UseDataSync.updateCardData）
 */

import { ThreeLayerCardData } from '../types'
import { UseDataSync } from './useDataSync'
import { GRID_DRAG_ACTIVE_KEY, GRID_DRAG_DATA_KEY } from '../../layout/DraggableGridTable'
import { CELL_DRAG_ACTIVE_KEY, CELL_DRAG_STORAGE_KEY, MULTI_SELECT_CELLS_KEY, MULTI_SELECT_ACTIVE_KEY, CLEAR_ALL_HIGHLIGHTS_KEY } from '../../ui/SimpleDraggableCell'

export interface LocalDataState {
  localChartData: number[]
  localChartDataStrings: string[]
  hasOriginalFormatData: boolean
}

export class UseCardState {
  /**
   * 统一更新父层数据
   */
  static updateParent(cardData: ThreeLayerCardData, state: LocalDataState, onCardDrop?: (data: ThreeLayerCardData) => void): void {
    UseDataSync.updateCardData(cardData, state.localChartData, state.localChartDataStrings, onCardDrop)
  }

  /**
   * 统一复位拖拽与多选状态
   */
  static resetDragStates(): void {
    try { AppStorage.set(GRID_DRAG_ACTIVE_KEY, false) } catch (_e) {}
    try { AppStorage.set(CELL_DRAG_ACTIVE_KEY, false) } catch (_e) {}
    try { AppStorage.set(CELL_DRAG_STORAGE_KEY, null) } catch (_e) {}
    try { AppStorage.set(GRID_DRAG_DATA_KEY, null) } catch (_e) {}
    try { AppStorage.set(MULTI_SELECT_CELLS_KEY, { cells: [], isActive: false }) } catch (_e) {}
    try { AppStorage.set(MULTI_SELECT_ACTIVE_KEY, false) } catch (_e) {}
    try {
      AppStorage.set(CLEAR_ALL_HIGHLIGHTS_KEY, true)
      setTimeout(() => {
        AppStorage.set(CLEAR_ALL_HIGHLIGHTS_KEY, false)
      }, 100)
    } catch (_e) {}
  }
}


