import { IDatabaseSaver } from './DatabaseSync'
import { GlobalRealtimeData } from './Structures'
import { FruitInfoService } from '../db/services/FruitInfoService'

export class OrmDatabaseSaver implements IDatabaseSaver {
  private lastBatchNo: string = ''

  private static formatDateTime(ms: number): string {
    const d = new Date(ms)
    const yyyy = d.getFullYear().toString()
    const mm = (d.getMonth() + 1).toString().padStart(2, '0')
    const dd = d.getDate().toString().padStart(2, '0')
    const hh = d.getHours().toString().padStart(2, '0')
    const mi = d.getMinutes().toString().padStart(2, '0')
    const ss = d.getSeconds().toString().padStart(2, '0')
    return `${yyyy}-${mm}-${dd} ${hh}:${mi}:${ss}`
  }

  private static getBatchNo(batchId: number): string {
    return `B${batchId}`
  }

  async saveStatistics(data: GlobalRealtimeData): Promise<boolean> {
    if (data.startTime <= 0) return true
    const batchNo = OrmDatabaseSaver.getBatchNo(data.startTime)
    this.lastBatchNo = batchNo

    const startTimeStr = OrmDatabaseSaver.formatDateTime(data.startTime)
    const batchWeightTon = data.totalWeight / 1000000
    const batchNumber = data.totalYield

    await FruitInfoService.upsertByBatchNo(batchNo, {
      StartTime: startTimeStr,
      StartedState: '1',
      CompletedState: '0',
      BatchWeight: batchWeightTon,
      BatchNumber: batchNumber,
      FVisible: 1
    })
    return true
  }

  async saveBatchInfo(batchId: number, data: GlobalRealtimeData): Promise<boolean> {
    if (data.startTime <= 0) return true
    const batchNo = OrmDatabaseSaver.getBatchNo(batchId)
    this.lastBatchNo = batchNo

    const startTimeStr = OrmDatabaseSaver.formatDateTime(data.startTime)
    const batchWeightTon = data.totalWeight / 1000000
    const batchNumber = data.totalYield

    await FruitInfoService.upsertByBatchNo(batchNo, {
      StartTime: startTimeStr,
      StartedState: '1',
      CompletedState: '0',
      BatchWeight: batchWeightTon,
      BatchNumber: batchNumber,
      FVisible: 1
    })
    return true
  }

  async saveExitData(exitIndex: number, count: number, weight: number): Promise<boolean> {
    return true
  }

  async endBatch(batchId: number, data: GlobalRealtimeData): Promise<boolean> {
    const batchNo = this.lastBatchNo || OrmDatabaseSaver.getBatchNo(batchId)
    const endTimeStr = OrmDatabaseSaver.formatDateTime(Date.now())
    const batchWeightTon = data.totalWeight / 1000000
    const batchNumber = data.totalYield

    await FruitInfoService.upsertByBatchNo(batchNo, {
      EndTime: endTimeStr,
      CompletedState: '1',
      BatchWeight: batchWeightTon,
      BatchNumber: batchNumber,
      FVisible: 1
    })
    return true
  }
}

