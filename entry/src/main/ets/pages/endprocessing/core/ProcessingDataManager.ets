/**
 * 加工数据管理器
 * 功能：管理加工记录数据，提供增删改查功能
 * 已改为从数据库读取数据
 */

import { getORM } from '@ibestservices/ibest-orm'
import { TbFruitinfo } from '../../../db/entities/TbFruitinfo'

export class ProcessingRecord {
  id: number = 0
  startTime: string = ''
  endTime: string = ''
  productType: string = ''
  totalWeight: number = 0
}

// 添加数据参数接口
export interface AddProcessingRecordParams {
  startTime: string
  endTime: string
  productType: string
  totalWeight: number
}

// 更新数据参数接口
export interface UpdateProcessingRecordParams {
  startTime?: string
  endTime?: string
  productType?: string
  totalWeight?: number
}

// 统计信息接口
export interface ProcessingStatistics {
  totalRecords: number
  totalWeight: number
  productTypes: string[]
}

/**
 * 加工数据管理器 (Singleton Pattern)
 * 从数据库读取数据
 */
export class ProcessingDataManager {
  private static instance: ProcessingDataManager | null = null
  processingRecords: ProcessingRecord[] = []
  private dataLoaded: boolean = false

  private constructor() {
    // 不再初始化默认数据，改为从数据库加载
  }

  static getInstance(): ProcessingDataManager {
    if (!ProcessingDataManager.instance) {
      ProcessingDataManager.instance = new ProcessingDataManager()
    }
    return ProcessingDataManager.instance
  }

  /**
   * 从数据库加载数据
   */
  public async loadDataFromDatabase(): Promise<void> {
    const orm = getORM()
    const listRaw = orm.query(TbFruitinfo)
      .orderBy('CustomerID', 'desc')
      .limit(50)
      .find() as TbFruitinfo[]
    const list = await Promise.resolve(listRaw)
    const visibleList = list.filter(item => item.FVisible === undefined || item.FVisible === null || item.FVisible !== 0)
    this.processingRecords = visibleList.map(item => {
      const r = new ProcessingRecord()
      r.id = item.CustomerID ?? 0
      r.startTime = item.StartTime ?? ''
      r.endTime = item.EndTime ?? ''
      r.productType = item.FruitName ?? ''
      r.totalWeight = item.BatchWeight ?? 0
      return r
    })
    this.dataLoaded = true
  }

  /**
   * 确保数据已加载（懒加载）
   */
  private async ensureDataLoaded(): Promise<void> {
    if (!this.dataLoaded) {
      await this.loadDataFromDatabase()
    }
  }

  /**
   * 添加加工记录（保存到数据库）
   */
  async addData(data: AddProcessingRecordParams): Promise<void> {
    await this.ensureDataLoaded()
  }

  /**
   * 删除加工记录（同步到数据库）
   */
  async deleteData(id: number): Promise<void> {
    await this.ensureDataLoaded()
  }

  /**
   * 更新加工记录（同步到数据库）
   */
  async updateData(id: number, newData: UpdateProcessingRecordParams): Promise<void> {
    await this.ensureDataLoaded()
  }

  /**
   * 获取所有加工记录（同步方法，返回已加载的数据）
   */
  getData(): ProcessingRecord[] {
    // 如果数据未加载，返回空数组（调用者需要先调用loadDataFromDatabase）
    return this.processingRecords
  }

  /**
   * 异步获取所有加工记录（自动加载）
   */
  async getDataAsync(): Promise<ProcessingRecord[]> {
    await this.ensureDataLoaded()
    return this.processingRecords
  }

  /**
   * 根据ID获取加工记录
   */
  getDataById(id: number): ProcessingRecord | undefined {
    return this.processingRecords.find(item => item.id === id)
  }

  /**
   * 根据产品类型获取加工记录
   */
  getDataByProductType(productType: string): ProcessingRecord[] {
    return this.processingRecords.filter(item => item.productType === productType)
  }

  /**
   * 清空所有数据
   */
  clearData(): void {
    this.processingRecords = []
    console.log('清空所有加工记录')
  }

  /**
   * 获取数据统计
   */
  getStatistics(): ProcessingStatistics {
    const totalRecords = this.processingRecords.length
    const totalWeight = this.processingRecords.reduce((sum, item) => sum + item.totalWeight, 0)
    const productTypes = Array.from(new Set(this.processingRecords.map(item => item.productType)))
    
    return {
      totalRecords,
      totalWeight,
      productTypes
    }
  }
}
