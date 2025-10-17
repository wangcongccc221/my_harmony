/**
 * 卡片通用工具（骨架）
 */
import { ThreeLayerCardData, FirstLayerData, SecondLayerData, ThirdLayerData, FirstLayerDataInterface, SecondLayerDataInterface, ThirdLayerDataInterface } from '../types'

export class CardUtils {
  static createUpdatedCardData(
    originalData: ThreeLayerCardData,
    updates: Partial<{ firstLayer: FirstLayerDataInterface, secondLayer: SecondLayerDataInterface, thirdLayer: ThirdLayerDataInterface }>
  ): ThreeLayerCardData {
    const firstLayer: FirstLayerDataInterface = {
      iconText: updates.firstLayer?.iconText ?? originalData.firstLayer.iconText,
      title: updates.firstLayer?.title ?? originalData.firstLayer.title,
      status: updates.firstLayer?.status ?? originalData.firstLayer.status
    }
    const secondLayer: SecondLayerDataInterface = {
      serialNumber: updates.secondLayer?.serialNumber ?? originalData.secondLayer.serialNumber,
      percent: updates.secondLayer?.percent ?? originalData.secondLayer.percent,
      value: updates.secondLayer?.value ?? originalData.secondLayer.value,
      unit: updates.secondLayer?.unit ?? originalData.secondLayer.unit
    }
    const thirdLayer: ThirdLayerDataInterface = {
      chartType: updates.thirdLayer?.chartType ?? originalData.thirdLayer.chartType,
      chartData: updates.thirdLayer?.chartData ?? originalData.thirdLayer.chartData,
      chartDataStrings: updates.thirdLayer?.chartDataStrings ?? originalData.thirdLayer.chartDataStrings,
      chartConfig: updates.thirdLayer?.chartConfig ?? originalData.thirdLayer.chartConfig
    }
    const result: ThreeLayerCardData = {
      id: originalData.id,
      firstLayer: firstLayer as FirstLayerData,
      secondLayer: secondLayer as SecondLayerData,
      thirdLayer: thirdLayer as ThirdLayerData
    }
    return result
  }

  static validateCardData(data: ThreeLayerCardData): boolean {
    return !!data && !!data.firstLayer && !!data.secondLayer && !!data.thirdLayer
  }
}


