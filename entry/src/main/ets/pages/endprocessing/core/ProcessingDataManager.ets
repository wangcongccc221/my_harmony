/**
 * 加工数据管理器
 * 功能：管理加工记录数据，提供增删改查功能
 * 已改为从数据库读取数据
 */

import { RdbService, ProcessingRow } from '../../../db/RdbService'
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
    try {
      const rows = await RdbService.queryAllProcessing()
      // 转换数据库数据为ProcessingRecord格式
      this.processingRecords = rows.map((row: ProcessingRow): ProcessingRecord => {
        // 计算总重量：总重量 = 批重量 × 批个数
        // weight: 批重量(kg), count: 批个数(个)
        // totalWeight: 总重量(吨)
        let calculatedWeight = 0
        
        // 优先使用 weight 和 count 计算：总重量(吨) = 批重量(kg) × 批个数(个) / 1000
        if (row.weight && row.count && row.weight > 0 && row.count > 0) {
          calculatedWeight = NumberUtils.calculateTotalWeight(row.weight, row.count)
          console.log(`计算总重量: 批重量=${row.weight}kg × 批个数=${row.count}个 = ${calculatedWeight}吨(四舍五入)`)
        } 
        // 如果数据库中的totalWeight有值且大于0，使用它（可能已经计算过）
        else if (row.totalWeight && row.totalWeight > 0) {
          calculatedWeight = NumberUtils.roundToDecimal(row.totalWeight, 1)
        } 
        // 如果只有批重量，使用批重量（假设批个数为1）
        else if (row.weight && row.weight > 0) {
          calculatedWeight = NumberUtils.calculateTotalWeight(row.weight, 1)
        } 
        // 其他情况设为0
        else {
          calculatedWeight = 0
          console.warn(`⚠️ 记录ID=${row.id} 无法计算总重量: weight=${row.weight}, count=${row.count}, totalWeight=${row.totalWeight}`)
        }
        
        return {
          id: row.id,
          startTime: row.startTime || '-',
          endTime: row.endTime || '-',
          productType: row.productType || row.fruitName || '未知',
          totalWeight: calculatedWeight
        }
      })
      this.dataLoaded = true
      console.log(`✅ 从数据库加载加工记录成功，共 ${this.processingRecords.length} 条`)
    } catch (error) {
      console.error('❌ 从数据库加载加工记录失败:', error)
      this.dataLoaded = false
      // 如果加载失败，使用空数组
      this.processingRecords = []
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
      // 保存到数据库
      await RdbService.insertProcessing(
        data.startTime,
        data.endTime,
        data.productType,
        data.totalWeight
      )
      // 重新加载数据以获取数据库生成的ID
      await this.loadDataFromDatabase()
      console.log('✅ 添加加工记录成功，已保存到数据库')
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
      // 从数据库删除
      await RdbService.deleteProcessingById(id)
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

      // 更新数据库
      await RdbService.updateProcessingById(
        id,
        newData.startTime ?? record.startTime,
        newData.endTime ?? record.endTime,
        newData.productType ?? record.productType,
        newData.totalWeight ?? record.totalWeight
      )

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
