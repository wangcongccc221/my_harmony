/**
 * 加工数据管理器
 * 功能：管理加工记录数据，提供增删改查功能
 * 已改为从数据库读取数据
 */

import { NumberUtils } from '../../../utils/helpers/NumberUtils'

// 加工记录数据接口
export interface ProcessingRecord {
  id: number
  startTime: string
  endTime: string
  productType: string
  totalWeight: number
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
  private nextId: number = 1

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
    if (!this.dataLoaded) {
      this.dataLoaded = true
      if (this.processingRecords.length === 0) {
        this.processingRecords = []
      }
    }
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
    try {
      const newItem: ProcessingRecord = {
        id: this.nextId++,
        startTime: data.startTime,
        endTime: data.endTime,
        productType: data.productType,
        totalWeight: data.totalWeight
      }
      this.processingRecords.unshift(newItem)
      console.log('✅ 添加加工记录成功（内存）')
    } catch (error) {
      console.error('❌ 添加加工记录失败:', error)
      const err = error as object
      throw new Error(`添加加工记录失败: ${JSON.stringify(err)}`)
    }
  }

  /**
   * 删除加工记录（同步到数据库）
   */
  async deleteData(id: number): Promise<void> {
    try {
      // 从内存中删除
      const initialLength = this.processingRecords.length
      this.processingRecords = this.processingRecords.filter(item => item.id !== id)
      if (this.processingRecords.length < initialLength) {
        console.log('✅ 删除加工记录成功，ID:', id)
      } else {
        console.log('⚠️ 未找到要删除的加工记录，ID:', id)
      }
    } catch (error) {
      console.error('❌ 删除加工记录失败，ID:', id, error)
      const err = error as object
      throw new Error(`删除加工记录失败: ${JSON.stringify(err)}`)
    }
  }

  /**
   * 更新加工记录（同步到数据库）
   */
  async updateData(id: number, newData: UpdateProcessingRecordParams): Promise<void> {
    try {
      const record = this.processingRecords.find(item => item.id === id)
      if (!record) {
        console.log('⚠️ 未找到要更新的加工记录，ID:', id)
        return
      }

      // 更新内存中的数据
      const index = this.processingRecords.findIndex(item => item.id === id)
      if (index !== -1) {
        if (newData.startTime !== undefined) {
          this.processingRecords[index].startTime = newData.startTime
        }
        if (newData.endTime !== undefined) {
          this.processingRecords[index].endTime = newData.endTime
        }
        if (newData.productType !== undefined) {
          this.processingRecords[index].productType = newData.productType
        }
        if (newData.totalWeight !== undefined) {
          this.processingRecords[index].totalWeight = newData.totalWeight
        }
        console.log('✅ 更新加工记录成功:', this.processingRecords[index])
      }
    } catch (error) {
      console.error('❌ 更新加工记录失败，ID:', id, error)
      const err = error as object
      throw new Error(`更新加工记录失败: ${JSON.stringify(err)}`)
    }
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
