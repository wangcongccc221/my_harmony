/**
 * 数据转换工具
 * 将数据库查询结果转换为接口类型
 */

import { relationalStore } from '@kit.ArkData'
import { ProcessingHistoryData } from '../types'
import { ProcessingHistory } from '../models/ProcessingHistory'
import { TestModel } from '../models/TestModel'
import { setValueIfNotEmpty, setValueWithDefault } from './ValueBucketHelper'

/**
 * 从查询结果中获取值（支持多种字段名格式）
 */
export function getValueFromResult(item: Record<string, ESObject>, key: string): ESObject | undefined {
  return item[key]
}

/**
 * 将 ProcessingHistory 实体对象转换为 ValuesBucket（用于 Insert/Update）
 * 自动处理空字符串：空字符串字段不设置，让数据库使用默认值或 NULL
 * @param historyRecord 历史加工记录实体对象
 * @returns ValuesBucket 对象
 */
export function processingHistoryToValueBucket(historyRecord: ProcessingHistory): relationalStore.ValuesBucket {
  const valueBucket: relationalStore.ValuesBucket = {}
  
  // 使用辅助函数，自动处理空字符串
  // 如果字段是空字符串，则不设置该字段（让数据库使用默认值或 NULL）
  setValueIfNotEmpty(valueBucket, 'customer_name', historyRecord.CustomerName)
  setValueIfNotEmpty(valueBucket, 'farm_name', historyRecord.FarmName)
  setValueIfNotEmpty(valueBucket, 'fruit_name', historyRecord.FruitName)
  setValueIfNotEmpty(valueBucket, 'status', historyRecord.Status)
  setValueIfNotEmpty(valueBucket, 'start_time', historyRecord.StartTime)
  
  // end_time 特殊处理：如果未完成，允许为空字符串（表示进行中）
  setValueWithDefault(valueBucket, 'end_time', historyRecord.EndTime, '')
  
  // 数字类型直接设置（如果 undefined 则不设置）
  if (historyRecord.Weight !== undefined) {
    valueBucket.weight = historyRecord.Weight
  }
  if (historyRecord.Quantity !== undefined) {
    valueBucket.quantity = historyRecord.Quantity
  }
  
  return valueBucket
}

/**
 * 将数据库查询结果转换为 ProcessingHistoryData
 * @param item 数据库查询结果项
 * @returns ProcessingHistoryData 对象
 */
export function convertToProcessingHistoryData(item: Record<string, ESObject>): ProcessingHistoryData {
  const getValue = (key: string): ESObject | undefined => {
    return item[key]
  }
  
  return {
    id: (getValue('id') as number) || undefined,
    CustomerName: (getValue('CustomerName') as string) || 
                 (getValue('customer_name') as string) || undefined,
    FarmName: (getValue('FarmName') as string) || 
             (getValue('farm_name') as string) || undefined,
    FruitName: (getValue('FruitName') as string) || 
              (getValue('fruit_name') as string) || undefined,
    Status: (getValue('Status') as string) || 
           (getValue('status') as string) || undefined,
    StartTime: (getValue('StartTime') as string) || 
              (getValue('start_time') as string) || undefined,
    EndTime: (getValue('EndTime') as string) || 
            (getValue('end_time') as string) || undefined,
    Weight: (getValue('Weight') as number) || 
           (getValue('weight') as number) || undefined,
    Quantity: (getValue('Quantity') as number) || 
             (getValue('quantity') as number) || undefined,
    created_at: getValue('created_at') as string,
    updated_at: getValue('updated_at') as string
  }
}

export function testModelToValueBucket(testRecord: TestModel): relationalStore.ValuesBucket {
  const valueBucket: relationalStore.ValuesBucket = {}
  setValueIfNotEmpty(valueBucket, 'title', testRecord.Title)
  setValueIfNotEmpty(valueBucket, 'description', testRecord.Description)
  if (testRecord.Count !== undefined) {
    valueBucket.count = testRecord.Count
  }
  if (testRecord.IsEnabled !== undefined) {
    valueBucket.is_enabled = testRecord.IsEnabled
  }
  return valueBucket
}

