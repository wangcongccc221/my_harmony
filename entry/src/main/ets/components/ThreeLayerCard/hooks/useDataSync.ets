/**
 * 数据同步与更新 hooks
 * - 同步父层数据到本地渲染数组
 * - 删除本地第三层条目（字符串优先匹配）
 * - 生成新的 ThreeLayerCardData 并回调上层
 */

import { ThreeLayerCardData, FirstLayerData, SecondLayerData, ThirdLayerData, FirstLayerDataInterface, SecondLayerDataInterface, ThirdLayerDataInterface } from '../types'
import { UseCardLogic } from './useCardLogic'

export interface SyncState {
  localChartData: number[]
  localChartDataStrings: string[]
  hasOriginalFormatData: boolean
}

export class UseDataSync {
  /**
   * 将父层的第三层数据同步到本地渲染数组（字符串优先使用父层的 chartDataStrings）
   */
  static syncLocalData(cardData: ThreeLayerCardData, current: SyncState): SyncState {
    const currentData: number[] = UseCardLogic.safeSlice(cardData?.thirdLayer?.chartData)
    const currentDataStrings: string[] = UseCardLogic.safeSlice(cardData?.thirdLayer?.chartDataStrings)

    if (!UseCardLogic.deepEqual(current.localChartData, currentData)) {
      let nextStrings: string[] = current.localChartDataStrings
      let hasOriginal = current.hasOriginalFormatData
      // 优先从父数据同步字符串数组
      if (currentDataStrings.length > 0) {
        nextStrings = currentDataStrings
        if (currentDataStrings.some(str => str.includes('%'))) {
          hasOriginal = true
        }
      } else if (nextStrings.length === 0) {
        nextStrings = currentData.map(num => String(num))
      } else if (nextStrings.length !== currentData.length) {
        const currentLength = nextStrings.length
        const missingCount = currentData.length - currentLength
        if (missingCount > 0) {
          for (let i = 0; i < missingCount; i++) {
            nextStrings.push(String(currentData[currentLength + i]))
          }
        } else if (missingCount < 0) {
          nextStrings = nextStrings.slice(0, currentData.length)
        }
      }
      return {
        localChartData: currentData,
        localChartDataStrings: nextStrings,
        hasOriginalFormatData: hasOriginal
      }
    }
    return current
  }

  /**
   * 删除本地第三层条目（字符串优先匹配，失败再数值匹配）
   */
  static deleteItemFromThirdLayer(state: SyncState, pendingDragValue: string, pendingDragIndex: number): SyncState {
    const currentList: number[] = UseCardLogic.safeSlice(state.localChartData)
    const currentStringList: string[] = UseCardLogic.safeSlice(state.localChartDataStrings)
    let indexToRemove: number = -1

    if (pendingDragIndex >= 0) {
      indexToRemove = pendingDragIndex
    } else if (pendingDragValue) {
      indexToRemove = currentStringList.findIndex((v: string) => v === pendingDragValue)
      if (indexToRemove < 0) {
        const valueNum: number = Number.parseFloat(pendingDragValue.replace('%', ''))
        indexToRemove = currentList.findIndex((v: number) => v === valueNum)
        if (indexToRemove < 0) {
          indexToRemove = currentList.findIndex((v: number) => Number.isFinite(valueNum) && Math.abs(v - valueNum) < 1e-6)
        }
      }
    }

    if (indexToRemove < 0 && pendingDragValue) {
      const sIdx = currentStringList.indexOf(pendingDragValue)
      if (sIdx >= 0) {
        indexToRemove = sIdx
      }
    }
    if (indexToRemove >= currentList.length) {
      indexToRemove = currentList.length - 1
    }

    if (indexToRemove >= 0 && indexToRemove < currentList.length) {
      currentList.splice(indexToRemove, 1)
      currentStringList.splice(indexToRemove, 1)
      return {
        localChartData: currentList,
        localChartDataStrings: currentStringList,
        hasOriginalFormatData: state.hasOriginalFormatData
      }
    }
    return state
  }

  /**
   * 生成新的 ThreeLayerCardData 并回调到上层（保存字符串数组）
   */
  static updateCardData(cardData: ThreeLayerCardData, newChartData: number[], localStrings: string[], onCardDrop?: (data: ThreeLayerCardData) => void): void {
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
    const chartConfig: Record<string, string | number> = {}
    chartConfig['sourceTable'] = String(cardData?.thirdLayer?.chartConfig?.['sourceTable'] ?? 'card_third_layer')
    const thirdLayerData: ThirdLayerDataInterface = {
      chartType: cardData.thirdLayer.chartType,
      chartData: newChartData,
      chartDataStrings: localStrings,
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
}


