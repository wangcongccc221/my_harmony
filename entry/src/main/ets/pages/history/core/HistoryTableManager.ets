/**
 * 历史表格数据管理器
 * 负责表格数据的增删改查操作
 * 已改为从数据库读取数据
 */

import { RdbService, ProcessingRow, ProcessingInsertParams } from '../../../db/RdbService'
import { DateValidationUtils } from '../../../utils/helpers/DateValidationUtils'

// 表格数据接口定义
export interface HistoryTableData {
  id: number
  customerName: string
  farmName: string
  fruitName: string
  status: '已完成' | '进行中' | '待开始'
  startTime: string
  endTime: string
  weight: number
  count: number
}

// 添加数据的接口
export interface AddDataParams {
  customerName: string
  farmName: string
  fruitName: string
  status: '已完成' | '进行中' | '待开始'
  startTime: string
  endTime: string
  weight: number
  count: number
}

// 更新数据的接口
export interface UpdateDataParams {
  customerName?: string
  farmName?: string
  fruitName?: string
  status?: '已完成' | '进行中' | '待开始'
  startTime?: string
  endTime?: string
  weight?: number
  count?: number
}

// 筛选参数接口
export interface FilterParams {
  startDate?: string
  endDate?: string
  customerName?: string
  farmName?: string
  fruitName?: string
  status?: '已完成' | '进行中' | '待开始'
}

/**
 * 历史表格数据管理器
 * 从数据库读取数据
 */
export class HistoryTableManager {
  private static instance: HistoryTableManager
  private tableData: HistoryTableData[] = []
  private dataLoaded: boolean = false

  private constructor() {
    // 不再初始化默认数据，改为从数据库加载
  }

  public static getInstance(): HistoryTableManager {
    if (!HistoryTableManager.instance) {
      HistoryTableManager.instance = new HistoryTableManager()
    }
    return HistoryTableManager.instance
  }

  /**
   * 从数据库加载数据
   */
  public async loadDataFromDatabase(): Promise<void> {
    try {
      const rows = await RdbService.queryAllProcessing()
      // 转换数据库数据为HistoryTableData格式
      this.tableData = rows.map((row: ProcessingRow): HistoryTableData => {
        // 处理状态：如果数据库中没有status，根据endTime判断
        let status: '已完成' | '进行中' | '待开始' = '已完成'
        if (row.status) {
          if (row.status === '已完成' || row.status === '进行中' || row.status === '待开始') {
            status = row.status
          }
        } else {
          // 根据endTime判断：如果是'-'或空，则为进行中或待开始
          if (!row.endTime || row.endTime === '-' || row.endTime.trim() === '') {
            status = '进行中'
          } else {
            status = '已完成'
          }
        }
        
        return {
          id: row.id,
          customerName: row.customerName || '',
          farmName: row.farmName || '',
          // 以数据库中的 productType 为准展示与筛选，避免 fruitName/别名不一致导致显示混乱
          fruitName: row.productType || row.fruitName || '',
          status: status,
          startTime: row.startTime || '',
          endTime: row.endTime || '-',
          weight: row.weight || row.totalWeight || 0,
          count: row.count || 0
        }
      })
      this.dataLoaded = true
      console.log('从数据库加载数据成功，共', this.tableData.length, '条')
    } catch (error) {
      console.error('从数据库加载数据失败:', error)
      this.tableData = []
      this.dataLoaded = false
    }
  }


  /**
   * 添加数据（保存到数据库）
   */
  async addData(data: AddDataParams): Promise<void> {
    try {
      const insertParams: ProcessingInsertParams = {
        startTime: data.startTime,
        endTime: data.endTime,
        productType: data.fruitName, // 使用fruitName作为productType
        totalWeight: data.weight,
        customerName: data.customerName,
        farmName: data.farmName,
        fruitName: data.fruitName,
        status: data.status,
        count: data.count,
        weight: data.weight
      }
      
      await RdbService.insertProcessingFull(insertParams)
      // 重新加载数据
      await this.loadDataFromDatabase()
      console.log('添加数据到数据库成功')
    } catch (error) {
      console.error('添加数据到数据库失败:', error)
      const err = error as object
      throw new Error(JSON.stringify(err))
    }
  }

  /**
   * 删除数据（从数据库删除）
   */
  async deleteData(id: number): Promise<void> {
    try {
      await RdbService.deleteProcessingById(id)
      // 重新加载数据
      await this.loadDataFromDatabase()
      console.log('从数据库删除数据成功，ID:', id)
    } catch (error) {
      console.error('从数据库删除数据失败:', error)
      const err = error as object
      throw new Error(JSON.stringify(err))
    }
  }

  /**
   * 更新数据（保存到数据库）
   */
  async updateData(id: number, newData: UpdateDataParams): Promise<void> {
    try {
      // 先获取当前数据
      const currentData = this.tableData.find(item => item.id === id)
      if (!currentData) {
        throw new Error(`未找到要更新的数据，ID: ${id}`)
      }
      
      // 合并更新数据
      const updateParams: ProcessingInsertParams = {
        startTime: newData.startTime !== undefined ? newData.startTime : currentData.startTime,
        endTime: newData.endTime !== undefined ? newData.endTime : currentData.endTime,
        productType: newData.fruitName !== undefined ? newData.fruitName : currentData.fruitName,
        totalWeight: newData.weight !== undefined ? newData.weight : currentData.weight,
        customerName: newData.customerName !== undefined ? newData.customerName : currentData.customerName,
        farmName: newData.farmName !== undefined ? newData.farmName : currentData.farmName,
        fruitName: newData.fruitName !== undefined ? newData.fruitName : currentData.fruitName,
        status: newData.status !== undefined ? newData.status : currentData.status,
        count: newData.count !== undefined ? newData.count : currentData.count,
        weight: newData.weight !== undefined ? newData.weight : currentData.weight
      }
      
      // 使用insertProcessingFull来更新（因为updateProcessingById不支持扩展字段）
      // 先删除旧数据，再插入新数据（简单实现）
      await RdbService.deleteProcessingById(id)
      await RdbService.insertProcessingFull(updateParams)
      // 重新加载数据
      await this.loadDataFromDatabase()
      console.log('更新数据库数据成功，ID:', id)
    } catch (error) {
      console.error('更新数据库数据失败:', error)
      const err = error as object
      throw new Error(JSON.stringify(err))
    }
  }

  /**
   * 获取所有数据（如果未加载则先加载）
   */
  async getData(): Promise<HistoryTableData[]> {
    if (!this.dataLoaded) {
      await this.loadDataFromDatabase()
    }
    return [...this.tableData]
  }
  
  /**
   * 同步获取所有数据（不触发加载，返回当前缓存）
   */
  getDataSync(): HistoryTableData[] {
    return [...this.tableData]
  }

  /**
   * 根据ID获取数据
   */
  getDataById(id: number): HistoryTableData | undefined {
    return this.tableData.find(item => item.id === id)
  }

  /**
   * 清空所有数据
   */
  clearData(): void {
    this.tableData = []
    console.log('清空所有数据')
  }

  /**
   * 根据状态筛选数据
   */
  getDataByStatus(status: '已完成' | '进行中' | '待开始'): HistoryTableData[] {
    return this.tableData.filter(item => item.status === status)
  }

  /**
   * 根据客户名称筛选数据
   */
  getDataByCustomer(customerName: string): HistoryTableData[] {
    return this.tableData.filter(item => item.customerName === customerName)
  }

  /**
   * 根据多个条件筛选数据
   */
  filterData(filters: FilterParams): HistoryTableData[] {
    let filteredData = [...this.tableData]
    
    // 日期范围筛选：要求记录的开始与结束都落在区间内（严格区间）
    if (filters.startDate || filters.endDate) {
      filteredData = filteredData.filter(item => {
        if (!item.startTime) return false
        
        // 使用工具类提取和验证日期部分
        const itemStartDate = DateValidationUtils.extractDatePart(item.startTime)
        if (!DateValidationUtils.isValidDateFormat(itemStartDate)) {
          console.warn('无效的开始日期格式:', item.startTime)
          return false
        }
        
        // 处理结束日期：如果 endTime 存在且不是 '-'，则使用 endTime
        // 如果 endTime 是 '-' 或空，说明记录还在进行中，使用一个很大的日期
        let itemEndDate = itemStartDate
        if (item.endTime && item.endTime !== '-' && item.endTime.trim() !== '') {
          const endDateStr = DateValidationUtils.extractDatePart(item.endTime)
          if (DateValidationUtils.isValidDateFormat(endDateStr)) {
            itemEndDate = endDateStr
          } else {
            console.warn('无效的结束日期格式:', item.endTime)
            // 如果结束日期格式无效，使用开始日期
            itemEndDate = itemStartDate
          }
        } else {
          // 如果 endTime 是 '-'，表示还在进行中，使用一个很大的日期确保包含所有未来日期
          itemEndDate = '9999-12-31'
        }
        
        // 查询区间（DatePickerHelper返回的是 YYYY-MM-DD 格式）
        let queryStartDate = '1970-01-01'
        if (filters.startDate) {
          const extracted = DateValidationUtils.extractDatePart(filters.startDate)
          if (DateValidationUtils.isValidDateFormat(extracted)) {
            queryStartDate = extracted
          } else {
            console.warn('无效的查询开始日期格式:', filters.startDate)
            queryStartDate = '1970-01-01'
          }
        }
        
        let queryEndDate = '9999-12-31'
        if (filters.endDate) {
          const extracted = DateValidationUtils.extractDatePart(filters.endDate)
          if (DateValidationUtils.isValidDateFormat(extracted)) {
            queryEndDate = extracted
          } else {
            console.warn('无效的查询结束日期格式:', filters.endDate)
            queryEndDate = '9999-12-31'
          }
        }
        
        // 严格区间规则：
        // - 当 start 和 end 都提供时：要求 itemStart 与 itemEnd 都在 [queryStartDate, queryEndDate] 内
        // - 仅提供 start 时：要求 itemStart 与 itemEnd 都 >= queryStartDate
        // - 仅提供 end 时：要求 itemStart 与 itemEnd 都 <= queryEndDate
        const startInRange = itemStartDate >= queryStartDate && itemStartDate <= queryEndDate
        const endInRange = itemEndDate >= queryStartDate && itemEndDate <= queryEndDate

        let shouldShow = false
        const hasQueryStart = !!filters.startDate
        const hasQueryEnd = !!filters.endDate
        if (hasQueryStart && hasQueryEnd) {
          shouldShow = startInRange && endInRange
        } else if (hasQueryStart) {
          shouldShow = itemStartDate >= queryStartDate && itemEndDate >= queryStartDate
        } else if (hasQueryEnd) {
          shouldShow = itemStartDate <= queryEndDate && itemEndDate <= queryEndDate
        }

        if (shouldShow) {
          console.log(`日期匹配(严格区间): 记录[${itemStartDate} ~ ${itemEndDate}]`)
        }
        return shouldShow
      })
    }
    
    // 客户名称筛选（精确匹配，去除前后空格，大小写敏感按原样。若需忽略大小写，可改为 toLowerCase 比较）
    if (filters.customerName && filters.customerName.trim().length > 0) {
      const target = filters.customerName.trim()
      filteredData = filteredData.filter(item => (item.customerName || '').trim() === target)
    }
    
    // 农场名称筛选（精确匹配）
    if (filters.farmName && filters.farmName.trim().length > 0) {
      const target = filters.farmName.trim()
      filteredData = filteredData.filter(item => (item.farmName || '').trim() === target)
    }
    
    // 水果名称筛选（精确匹配）
    if (filters.fruitName && filters.fruitName.trim().length > 0) {
      const target = filters.fruitName.trim()
      filteredData = filteredData.filter(item => (item.fruitName || '').trim() === target)
    }
    
    // 状态筛选
    if (filters.status) {
      filteredData = filteredData.filter(item => item.status === filters.status)
    }
    
    return filteredData
  }

  /**
   * 批量删除数据（根据ID数组）
   */
  async deleteBatchData(ids: number[]): Promise<void> {
    try {
      for (const id of ids) {
        await RdbService.deleteProcessingById(id)
      }
      // 重新加载数据
      await this.loadDataFromDatabase()
      console.log('批量删除数据成功，共删除', ids.length, '条')
    } catch (error) {
      console.error('批量删除数据失败:', error)
      const err = error as object
      throw new Error(JSON.stringify(err))
    }
  }

  /**
   * 获取下一个ID
   */
  private getNextId(): number {
    if (this.tableData.length === 0) {
      return 1
    }
    return Math.max(...this.tableData.map(item => item.id)) + 1
  }

  /**
   * 获取数据总数
   */
  getDataCount(): number {
    return this.tableData.length
  }

  /**
   * 重置为初始数据（已废弃，保留用于兼容）
   */
  resetToDefault(): void {
    this.clearData()
  }
  
  /**
   * 刷新数据（从数据库重新加载）
   */
  async refreshData(): Promise<void> {
    await this.loadDataFromDatabase()
  }

  /**
   * 获取所有唯一的客户名称列表
   */
  getUniqueCustomerNames(): string[] {
    const names = new Set<string>()
    this.tableData.forEach(item => {
      if (item.customerName && item.customerName.trim() !== '') {
        names.add(item.customerName)
      }
    })
    return Array.from(names).sort()
  }

  /**
   * 获取所有唯一的农场名称列表
   */
  getUniqueFarmNames(): string[] {
    const names = new Set<string>()
    this.tableData.forEach(item => {
      if (item.farmName && item.farmName.trim() !== '') {
        names.add(item.farmName)
      }
    })
    return Array.from(names).sort()
  }

  /**
   * 获取所有唯一的水果名称列表
   */
  getUniqueFruitNames(): string[] {
    const names = new Set<string>()
    this.tableData.forEach(item => {
      if (item.fruitName && item.fruitName.trim() !== '') {
        names.add(item.fruitName)
      }
    })
    return Array.from(names).sort()
  }
}
