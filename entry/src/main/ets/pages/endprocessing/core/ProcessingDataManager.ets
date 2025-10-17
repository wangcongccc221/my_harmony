/**
 * 加工数据管理器
 * 功能：管理加工记录数据，提供增删改查功能
 */

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
 */
export class ProcessingDataManager {
  private static instance: ProcessingDataManager | null = null
  processingRecords: ProcessingRecord[] = []
  private nextId: number = 1

  private constructor() {
    this.initDefaultData()
  }

  static getInstance(): ProcessingDataManager {
    if (!ProcessingDataManager.instance) {
      ProcessingDataManager.instance = new ProcessingDataManager()
    }
    return ProcessingDataManager.instance
  }

  private getNextId(): number {
    return this.nextId++
  }

  /**
   * 初始化默认数据
   */
  private initDefaultData(): void {
    this.addData({
      startTime: '2025-09-03 08:30',
      endTime: '2025-09-03 12:45',
      productType: '苹果',
      totalWeight: 2.5
    })

    this.addData({
      startTime: '2025-09-05 14:20',
      endTime: '2025-09-05 18:10',
      productType: '橙子',
      totalWeight: 1.8
    })

    this.addData({
      startTime: '2025-09-08 09:15',
      endTime: '2025-09-08 13:30',
      productType: '香蕉',
      totalWeight: 3.2
    })

    this.addData({
      startTime: '2025-09-12 15:45',
      endTime: '2025-09-12 19:20',
      productType: '葡萄',
      totalWeight: 1.5
    })
  }

  /**
   * 添加加工记录
   */
  addData(data: AddProcessingRecordParams): void {
    const newId = this.getNextId()
    const newRecord: ProcessingRecord = {
      id: newId,
      startTime: data.startTime,
      endTime: data.endTime,
      productType: data.productType,
      totalWeight: data.totalWeight
    }
    this.processingRecords.push(newRecord)
    console.log('添加加工记录成功:', newRecord)
  }

  /**
   * 删除加工记录
   */
  deleteData(id: number): void {
    const initialLength = this.processingRecords.length
    this.processingRecords = this.processingRecords.filter(item => item.id !== id)
    if (this.processingRecords.length < initialLength) {
      console.log('删除加工记录成功，ID:', id)
    } else {
      console.log('未找到要删除的加工记录，ID:', id)
    }
  }

  /**
   * 更新加工记录
   */
  updateData(id: number, newData: UpdateProcessingRecordParams): void {
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
      console.log('更新加工记录成功:', this.processingRecords[index])
    } else {
      console.log('未找到要更新的加工记录，ID:', id)
    }
  }

  /**
   * 获取所有加工记录
   */
  getData(): ProcessingRecord[] {
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
