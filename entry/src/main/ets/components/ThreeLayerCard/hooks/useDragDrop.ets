/**
 * 拖拽逻辑 Hook（骨架）
 * 后续将把 ThreeLayerCard 中的拖拽处理逐步迁移至此，降低主组件复杂度
 */

import { ThreeLayerCardData, FirstLayerData, SecondLayerData, ThirdLayerData, FirstLayerDataInterface, SecondLayerDataInterface, ThirdLayerDataInterface, MultiSelectCell, SystemWrapper, DragOuterPayload, LoosePayload } from '../types'
import { UseCardLogic } from './useCardLogic'
import { UseDataSync, SyncState } from './useDataSync'
import { UseCardState, LocalDataState } from './useCardState'
import { UseDragHandlers } from './useDragHandlers'
import { StorageKeys } from '../../../utils/constants/StorageKeys'

interface OuterSummary {
  value?: string | number
  values?: string[]
}

// LocalDataState 类型来自 UseCardState

export class UseDragDrop {
  /**
   * 多选：更新出口等级映射并按等级去重后批量上报
   */
  static updateLevelMapping(cardId: string, cells: MultiSelectCell[], levelNames?: string[], getCardNumber?: () => number): void {
    try {
      const hasLvns = Array.isArray(levelNames) && levelNames.length === cells.length
      if (hasLvns) {
        const mapRaw = AppStorage.get(StorageKeys.CARD_ITEM_LEVEL_MAP) as Record<string, Record<string, string>> | null
        const mapObj: Record<string, Record<string, string>> = mapRaw ? mapRaw : {}
        if (!mapObj[cardId]) { mapObj[cardId] = {} }
        for (let i = 0; i < cells.length; i++) {
          const valStr = String(cells[i]?.value ?? '')
          const ln = String(levelNames![i] ?? '')
          if (valStr && ln) { mapObj[cardId][valStr] = ln }
        }
        AppStorage.setOrCreate(StorageKeys.CARD_ITEM_LEVEL_MAP, mapObj)
      }

      const collected: string[] = Array.isArray(levelNames) ? levelNames : cells.map((_c: MultiSelectCell) => '')
      const uniqueLevels = Array.from(new Set(collected)).filter(s => s && s.length > 0)
      if (uniqueLevels.length > 0 && typeof getCardNumber === 'function') {
        AppStorage.setOrCreate(StorageKeys.LEVEL_STAT_UPDATE_BATCH, { levelNames: uniqueLevels, exit: Number(getCardNumber()) })
      }
    } catch (_e) {}
  }

  /**
   * 处理等级统计：更新映射并按唯一等级名批量上报
   */
  static processLevelStatistics(
    cardData: ThreeLayerCardData,
    cells: MultiSelectCell[],
    levelNames?: string[],
    getCardNumber?: () => number
  ): void {
    try {
      const sourceIsLevelTable = String(cells[0]?.sourceTable || '') === '等级表'
      if (!sourceIsLevelTable) { return }
      UseDragDrop.updateLevelMapping(String(cardData.id || ''), cells, levelNames, getCardNumber)
    } catch (_e) {
      console.warn('处理等级统计时发生错误:', _e)
    }
  }

  private static getUniqueLevels(levelNames?: string[], cells?: MultiSelectCell[]): string[] {
    let collected: string[] = Array.isArray(levelNames) ? levelNames : []
    if (!Array.isArray(levelNames) || levelNames.length === 0) {
      collected = (cells || []).map((_c: MultiSelectCell) => '')
    }
    return Array.from(new Set(collected)).filter(s => s && s.length > 0)
  }
  /**
   * 统一解析 extraParams，返回 LoosePayload
   */
  static parseDragData(extraParams: string): LoosePayload {
    let payloadStr = extraParams
    if (extraParams && extraParams.indexOf('"extraInfo"') >= 0) {
      const wrapper: SystemWrapper = JSON.parse(extraParams) as SystemWrapper
      payloadStr = String(wrapper.extraInfo ?? extraParams)
    }
    
    let parsed: LoosePayload
    try {
      parsed = JSON.parse(payloadStr) as LoosePayload
    } catch (error) {
      console.error('解析拖拽数据失败:', error, '原始数据:', payloadStr)
      return { type: 'error', value: payloadStr }
    }
    
    // 处理多选拖拽数据（来自 GridTable 的多选拖拽）
    if (parsed.type === 'multi_select' && parsed.values && Array.isArray(parsed.values)) {
      console.log('🎯 检测到多选拖拽数据:', parsed.values.length, '个值')
      
      // 数据已经在 GridTable 中优化过了，直接使用
      parsed.count = parsed.count || parsed.values.length
      
      console.log('🎯 多选拖拽解析结果:', {
        values: parsed.values,
        count: parsed.count
      })
    }
    
    // 处理 fullRowData 字段（来自 GridTable 的整行拖拽）
    if (parsed.fullRowData && !parsed.rowData) {
      try {
        const rowDataArray = JSON.parse(parsed.fullRowData) as string[]
        if (Array.isArray(rowDataArray)) {
          parsed.rowData = rowDataArray
          parsed.type = 'row'
          console.log('🎯 解析 fullRowData:', parsed.fullRowData, '转换为 rowData:', parsed.rowData)
        }
      } catch (error) {
        console.error('解析 fullRowData 失败:', error)
      }
    }
    
    // 处理 fullColumnData 字段（来自 GridTable 的整列拖拽）
    if (parsed.fullColumnData && !parsed.columnData) {
      try {
        const columnDataArray = JSON.parse(parsed.fullColumnData) as string[]
        if (Array.isArray(columnDataArray)) {
          parsed.columnData = columnDataArray
          parsed.type = 'column'
          console.log('🎯 解析 fullColumnData:', parsed.fullColumnData, '转换为 columnData:', parsed.columnData)
        }
      } catch (error) {
        console.error('解析 fullColumnData 失败:', error)
      }
    }
    
    return parsed
  }

  /**
   * 处理单元格拖拽（占位，后续迁移 ThreeLayerCard 内实现）
   */
  static handleCellDragDrop(cardData: ThreeLayerCardData, value: string, sourceTable: string, rowIndex: number, colIndex: number, onCardDrop?: (data: ThreeLayerCardData) => void): void {
    // 正确处理百分比符号，去掉%后再解析数字
    const v: number = Number.parseFloat(value.replace('%', '')) || 0
    const chartData: number[] = [v]
    const chartConfig: Record<string, string | number> = {}
    chartConfig['sourceTable'] = sourceTable || '等级表'
    chartConfig['rowIndex'] = rowIndex || 0
    chartConfig['colIndex'] = colIndex || 0

    const firstLayerData: FirstLayerDataInterface = {
      iconText: cardData.firstLayer.iconText,
      title: cardData.firstLayer.title,
      status: cardData.firstLayer.status
    }
    const secondLayerData: SecondLayerDataInterface = {
      serialNumber: cardData.secondLayer.serialNumber,
      percent: cardData.secondLayer.percent,
      value: cardData.secondLayer.value,
      unit: cardData.secondLayer.unit
    }
    const thirdLayerData: ThirdLayerDataInterface = {
      chartType: cardData.thirdLayer.chartType,
      chartData: chartData,
      chartConfig: chartConfig
    }
    const newCardData: ThreeLayerCardData = {
      id: cardData.id,
      firstLayer: firstLayerData as FirstLayerData,
      secondLayer: secondLayerData as SecondLayerData,
      thirdLayer: thirdLayerData as ThirdLayerData
    }
    onCardDrop?.(newCardData)
  }

  /**
   * 处理 Grid 拖拽（占位）
   */
  static handleGridDragDrop(cardData: ThreeLayerCardData, textValue: string, sourceTable: string, rowIndex: number, colIndex: number, onCardDrop?: (data: ThreeLayerCardData) => void): void {
    UseDragDrop.handleCellDragDrop(cardData, textValue, sourceTable, rowIndex, colIndex, onCardDrop)
  }

  /**
   * 处理多选拖拽（占位，返回新的本地渲染状态供主组件更新）
   */
  static handleMultiSelectDrop(cardData: ThreeLayerCardData, cells: MultiSelectCell[], levelNames?: string[], onCardDrop?: (data: ThreeLayerCardData) => void): LocalDataState {
    const values: number[] = []
    const originalValues: string[] = []
    for (let i = 0; i < cells.length; i++) {
      // 正确处理百分比符号，去掉%后再解析数字
      const cellValue = String(cells[i]?.value ?? '')
      const vv = Number.parseFloat(cellValue.replace('%', '')) || 0
      values.push(vv)
      originalValues.push(cellValue)
    }

    const prevList: number[] = Array.isArray(cardData?.thirdLayer?.chartData) ? [...(cardData.thirdLayer.chartData as number[])] : []
    for (let i = 0; i < values.length; i++) { prevList.push(values[i]) }

    const prevStrings: string[] = Array.isArray(cardData?.thirdLayer?.chartDataStrings)
      ? [...(cardData.thirdLayer.chartDataStrings as string[])]
      : (prevList.length > values.length ? prevList.slice(0, prevList.length - values.length).map(n => String(n)) : [])
    for (let i = 0; i < originalValues.length; i++) { prevStrings.push(originalValues[i]) }

    // 保存字符串数组供后续映射与删除使用
    const thirdLayerData: ThirdLayerDataInterface = {
      chartType: cardData.thirdLayer.chartType,
      chartData: prevList,
      chartDataStrings: prevStrings,
      chartConfig: cardData.thirdLayer.chartConfig
    }
    const firstLayerData: FirstLayerDataInterface = {
      iconText: cardData.firstLayer.iconText,
      title: cardData.firstLayer.title,
      status: cardData.firstLayer.status
    }
    const secondLayerData: SecondLayerDataInterface = {
      serialNumber: cardData.secondLayer.serialNumber,
      percent: cardData.secondLayer.percent,
      value: cardData.secondLayer.value,
      unit: cardData.secondLayer.unit
    }
    const newCardData: ThreeLayerCardData = {
      id: cardData.id,
      firstLayer: firstLayerData as FirstLayerData,
      secondLayer: secondLayerData as SecondLayerData,
      thirdLayer: thirdLayerData as ThirdLayerData
    }
    onCardDrop?.(newCardData)

    const hasOriginal: boolean = prevStrings.some(v => v.indexOf('%') >= 0)
    return {
      localChartData: prevList,
      localChartDataStrings: prevStrings,
      hasOriginalFormatData: hasOriginal
    }
  }

  /**
   * 处理第三层 onDrop（单条与多选合并入口），返回新的本地渲染状态
   */
  static handleThirdLayerDrop(
    extraParams: string,
    cardData: ThreeLayerCardData,
    currentState: LocalDataState,
    onCardDrop?: (data: ThreeLayerCardData) => void,
    getCardNumber?: () => number
  ): LocalDataState {
    const dragData = UseDragDrop.parseDragData(extraParams)
    
    // 整列拖拽：columnData 格式
    if (dragData.type === 'column' && Array.isArray(dragData.columnData)) {
      console.log('🎯 处理整列拖拽:', dragData.columnHeader, '数据:', dragData.columnData)
      const columnCells: MultiSelectCell[] = dragData.columnData.map((value: string, index: number): MultiSelectCell => ({
        rowIndex: index,
        colIndex: dragData.columnIndex || 0,
        value: value,
        sourceTable: dragData.sourceTable || '等级表',
        cellId: `column_${dragData.columnIndex}_${index}`
      }))
      const state = UseDragDrop.handleMultiSelectDrop(cardData, columnCells, undefined, onCardDrop)
      
      // 从等级表拖拽整列时，需要触发出口联动
      if (dragData.sourceTable === '等级表') {
        // 使用传递过来的等级名称数组
        const levelNames = Array.isArray(dragData.levelNames) ? dragData.levelNames : []
        console.log('🎯 整列拖拽等级名称数组:', levelNames)
        UseDragDrop.updateLevelMapping(String(cardData.id || ''), columnCells, levelNames, getCardNumber)
      } else {
        UseDragDrop.updateLevelMapping(String(cardData.id || ''), columnCells, undefined, getCardNumber)
      }
      return state
    }
    
    // 整行拖拽：rowData 格式
    if (dragData.type === 'row' && Array.isArray(dragData.rowData)) {
      console.log('🎯 处理整行拖拽:', `第${(dragData.rowIndex || 0) + 1}行`, '数据:', dragData.rowData, '出口:', dragData.outletInfo)
      const rowCells: MultiSelectCell[] = dragData.rowData.map((value: string, index: number): MultiSelectCell => ({
        rowIndex: dragData.rowIndex || 0,
        colIndex: index,
        value: value,
        sourceTable: dragData.sourceTable || '等级表',
        cellId: `row_${dragData.rowIndex}_${index}`
      }))
      
      // 如果有出口信息，需要特殊处理
      if (dragData.outletInfo && dragData.sourceTable === '等级统计表') {
        console.log('🎯 等级统计表拖拽，出口信息:', dragData.outletInfo)
        // 从出口信息中提取出口编号
        const outletMatch = dragData.outletInfo.match(/出口(\d+)/)
        if (outletMatch) {
          const outletNumber = parseInt(outletMatch[1])
          console.log('🎯 提取到出口编号:', outletNumber)
          
          // 从rowData中提取等级名称（第一个元素）
          const levelName = dragData.rowData[0] || ''
          console.log('🎯 提取到等级名称:', levelName)
          
          // 为每个cell创建对应的等级名称数组
          const levelNames = rowCells.map(() => levelName)
          console.log('🎯 等级名称数组:', levelNames)
          
          // 更新等级映射，使用出口编号和等级名称
          UseDragDrop.updateLevelMapping(String(cardData.id || ''), rowCells, levelNames, () => outletNumber)
        }
      }
      
      const state = UseDragDrop.handleMultiSelectDrop(cardData, rowCells, undefined, onCardDrop)
      if (!dragData.outletInfo || dragData.sourceTable !== '等级统计表') {
        // 从等级表拖拽整行时，需要触发出口联动
        if (dragData.sourceTable === '等级表') {
          // 使用传递过来的等级名称
          const levelName: string = String(dragData.levelName || '')
          console.log('🎯 整行拖拽等级名称:', levelName)
          // 为每个cell创建对应的等级名称数组
          const levelNames: string[] = rowCells.map((): string => levelName)
          UseDragDrop.updateLevelMapping(String(cardData.id || ''), rowCells, levelNames, getCardNumber)
        } else {
          UseDragDrop.updateLevelMapping(String(cardData.id || ''), rowCells, undefined, getCardNumber)
        }
      }
      return state
    }
    
    // 多选：cells 完整格式
    if (Array.isArray(dragData.cells)) {
      const cells = dragData.cells as MultiSelectCell[]
      const lvns: string[] | undefined = Array.isArray(dragData.levelNames) ? (dragData.levelNames as string[]) : undefined
      const state = UseDragDrop.handleMultiSelectDrop(cardData, cells, lvns, onCardDrop)
      UseDragDrop.updateLevelMapping(String(cardData.id || ''), cells, lvns, getCardNumber)
      return state
    }
    // 多选：values 简化格式
    if (Array.isArray(dragData.values)) {
      const valuesArr = dragData.values as string[]
      const simplifiedCells: MultiSelectCell[] = valuesArr.map((value: string, index: number): MultiSelectCell => ({
        rowIndex: 0,
        colIndex: index,
        value: value,
        sourceTable: '等级表',
        cellId: `simplified_${index}`
      }))
      const lvns: string[] | undefined = Array.isArray(dragData.levelNames) ? (dragData.levelNames as string[]) : undefined
      const state = UseDragDrop.handleMultiSelectDrop(cardData, simplifiedCells, lvns, onCardDrop)
      UseDragDrop.updateLevelMapping(String(cardData.id || ''), simplifiedCells, lvns, getCardNumber)
      return state
    }

    // 单条
    const parsedRes = UseDragHandlers.parseDrop(extraParams)
    const valueStr: string = parsedRes ? parsedRes.valueStr : String((dragData as Record<string, string | number>)['value'] ?? '')
    const originalValue: string = parsedRes ? parsedRes.originalValue : String((dragData as Record<string, string | number>)['sourceValue'] ?? (dragData as Record<string, string | number>)['originalValue'] ?? valueStr)
    const sourceTable: string = parsedRes ? parsedRes.sourceTable : String((dragData as Record<string, string | number>)['sourceTable'] ?? '等级表')
    const rowIndex: number = Number((dragData as Record<string, string | number>)['rowIndex'] ?? 0)
    const colIndex: number = Number((dragData as Record<string, string | number>)['colIndex'] ?? 0)
    const sourceCardId: string = parsedRes ? parsedRes.sourceCardId : String((dragData as Record<string, string | number>)['sourceCardId'] ?? '')
    const dragSession: string = parsedRes ? parsedRes.dragSession : String((dragData as Record<string, string | number>)['dragSession'] ?? '')

    const isFromCard: boolean = UseDragHandlers.isFromCard(sourceTable, sourceCardId, String(cardData.id || ''))
    const isFromTable: boolean = (sourceTable === '等级表' || sourceTable === 'card_third_layer')
    if (isFromCard) {
      UseDragHandlers.markDropHandled()
      if (dragSession) {
        try { AppStorage.setOrCreate(StorageKeys.CARD_DRAG_HANDLED_SESSION, dragSession) } catch (_e) {}
      }
      AppStorage.set(StorageKeys.REMOVE_SOURCE_DATA, {
        sourceCardId: sourceCardId,
        sourceValue: originalValue
      })
    } else if (isFromTable) {
      UseDragHandlers.markDropHandled()
      if (dragSession) {
        try { AppStorage.setOrCreate(StorageKeys.CARD_DRAG_HANDLED_SESSION, dragSession) } catch (_e) {}
      }
    } else {
      UseDragHandlers.markDropUnhandled()
    }

    const v: number = Number.parseFloat(valueStr) || 0
    const localList: number[] = UseCardLogic.safeSlice(currentState.localChartData)
    const localStringList: string[] = UseCardLogic.safeSlice(currentState.localChartDataStrings)
    localList.push(v)
    localStringList.push(originalValue)

    const nextState: LocalDataState = {
      localChartData: localList,
      localChartDataStrings: localStringList,
      hasOriginalFormatData: currentState.hasOriginalFormatData || originalValue.indexOf('%') >= 0
    }
    UseDataSync.updateCardData(cardData, nextState.localChartData, nextState.localChartDataStrings, onCardDrop)

    // 建立/迁移映射与统计
    try {
      if (sourceTable === '等级表') {
        const levelNameFromPayload: string = String((dragData as Record<string, string | number>)['levelName'] || '')
        if (levelNameFromPayload) {
          const cardNum: number = typeof getCardNumber === 'function' ? Number(getCardNumber()) : 0
          const cardId = String(cardData.id || '')
          UseDragHandlers.mapValueToLevel(cardId, originalValue, levelNameFromPayload, cardNum)
        }
      }
      if (sourceTable === 'card_third_layer') {
        const fromCardId: string = String((dragData as Record<string, string | number>)['sourceCardId'] || '')
        const valStr: string = String((dragData as Record<string, string | number>)['sourceValue'] || '')
        const levelName: string = String((dragData as Record<string, string | number>)['levelName'] || '')
        const toExit = typeof getCardNumber === 'function' ? Number(getCardNumber()) : 0
        const toCardId = String(cardData.id || '')
        
        // 检查是否是从同一个卡片拖拽（不应该触发移动逻辑）
        if (fromCardId === toCardId) {
          console.log('🎯 同卡片内拖拽，跳过移动逻辑')
          return nextState
        }
        
        // 如果有等级名称，直接使用等级名称进行追加
        if (levelName) {
          console.log(`🎯 卡片间拖拽，使用等级名称: ${levelName}`)
          UseDragHandlers.mapValueToLevel(toCardId, valStr, levelName, toExit)
        } else {
          // 使用追加逻辑而不是移动逻辑，这样不会删除原来的映射
          UseDragHandlers.appendMappingToCard(fromCardId, valStr, toCardId, toExit)
        }
      }
    } catch (_e) {}

    return nextState
  }

  /**
   * 外层卡片 onDrop 记录摘要（不改 handled 标记）
   */
  static handleOuterDrop(extraParams: string): void {
    let raw = extraParams
    try {
      if (raw && raw.indexOf('"extraInfo"') >= 0) {
        const wrapper: SystemWrapper = JSON.parse(raw) as SystemWrapper
        raw = String(wrapper.extraInfo ?? raw)
      }
      const outer: OuterSummary = JSON.parse(raw) as OuterSummary
      const hasDirectValue: boolean = (typeof outer.value === 'string' || typeof outer.value === 'number')
      const hasValuesArray: boolean = Array.isArray(outer.values)
      const valueStr: string = hasDirectValue ? String(outer.value as string | number) : (hasValuesArray ? 'values[]' : '')
      console.log('🟢 内容不变 移动内容:', valueStr)
    } catch (_e) {
      console.log('🟢 内容不变 移动内容:', raw)
    }
  }
}
