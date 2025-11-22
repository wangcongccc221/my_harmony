/**
 * 历史表格数据管理器
 * 负责表格数据的增删改查操作
 * 已改为从数据库读取数据
 */

import { GetIBestORM } from '../../../database/orm';
import { DateValidationUtils } from '../../../utils/helpers/DateValidationUtils'
import { ProcessingHistory } from '../../../database/models/ProcessingHistory'
import { ProcessingHistoryData } from '../../../database/types'

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
      const db = GetIBestORM();
      // 性能监控：记录开始时间
      const startTime = Date.now();
      
      // 执行数据库查询（同步操作，会阻塞主线程）
      const dbRecords = db.Table("processing_history").Find(ProcessingHistory) as ProcessingHistoryData[];
      
      // 性能监控：记录查询耗时
      const queryTime = Date.now() - startTime;
      if (queryTime > 100) {
        console.warn(`⚠️ 数据库查询耗时较长: ${queryTime}ms，查询到 ${dbRecords ? dbRecords.length : 0} 条记录`);
      }
      
      // 性能监控：记录数据转换开始时间
      const convertStartTime = Date.now();
      
      // 数据转换（字段越多，这里耗时越长）
      this.tableData = dbRecords.map((record: ProcessingHistoryData): HistoryTableData => {
        // 处理 ID 字段：查询返回的是 ID（大写），但接口期望 id（小写）
        const recordId = record.ID || record.id || 0;
        const historyData: HistoryTableData = {
          id: recordId,
          customerName: record.CustomerName || '',
          farmName: record.FarmName || '',
          fruitName: record.FruitName || '',
          status: (record.Status as '已完成' | '进行中' | '待开始') || '待开始',
          startTime: record.StartTime || '',
          endTime: record.EndTime || '',
          weight: record.Weight || 0,
          count: record.Quantity || 0
        }
        return historyData
      })
      
      // 性能监控：记录总耗时
      const totalTime = Date.now() - startTime;
      const convertTime = Date.now() - convertStartTime;
      
      if (totalTime > 100) {
        console.warn(`⚠️ 数据加载总耗时: ${totalTime}ms (查询: ${queryTime}ms, 转换: ${convertTime}ms), 记录数: ${this.tableData.length}`);
        console.warn(`💡 提示: 如果字段数量很多，建议优化字段映射逻辑或使用异步加载`);
      }
      
      this.dataLoaded = true
    } catch (error) {
      console.error('❌ 从数据库加载历史加工数据失败:', error)
      this.tableData = []
      this.dataLoaded = true
    }
  }


  /**
   * 添加数据（保存到数据库）
   */
  async addData(data: AddDataParams): Promise<void> {
    try {
      const db = GetIBestORM();
      const historyRecord = new ProcessingHistory(
        data.customerName,
        data.farmName,
        data.fruitName,
        data.status,
        data.startTime,
        data.endTime,
        data.weight,
        data.count
      )
      await db.Create(historyRecord)
      await this.loadDataFromDatabase()
    } catch (error) {
      console.error('❌ 添加数据到数据库失败:', error)
      const err = error as object
      throw new Error(JSON.stringify(err))
    }
  }

  /**
   * 删除数据（从数据库删除）
   */
  async deleteData(id: number): Promise<void> {
    try {
      const db = GetIBestORM();
      db.Table("processing_history").Where('id', id).Delete()
      await this.loadDataFromDatabase()
    } catch (error) {
      console.error('❌ 从数据库删除数据失败:', error)
      const err = error as object
      throw new Error(JSON.stringify(err))
    }
  }

  /**
   * 更新数据（保存到数据库）
   */
  async updateData(id: number, newData: UpdateDataParams): Promise<void> {
    try {
      const currentData = this.tableData.find(item => item.id === id)
      if (!currentData) {
        throw new Error(`未找到要更新的数据，ID: ${id}`)
      }
      const db = GetIBestORM();
      const updatedRecord = new ProcessingHistory(
        newData.customerName !== undefined ? newData.customerName : currentData.customerName,
        newData.farmName !== undefined ? newData.farmName : currentData.farmName,
        newData.fruitName !== undefined ? newData.fruitName : currentData.fruitName,
        newData.status !== undefined ? newData.status : currentData.status,
        newData.startTime !== undefined ? newData.startTime : currentData.startTime,
        newData.endTime !== undefined ? newData.endTime : currentData.endTime,
        newData.weight !== undefined ? newData.weight : currentData.weight,
        newData.count !== undefined ? newData.count : currentData.count
      );
      updatedRecord.ID = id;
      db.Save(updatedRecord);
      await this.loadDataFromDatabase()
    } catch (error) {
      console.error('❌ 更新数据库数据失败:', error)
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
    return this.tableData.slice()
  }
  
  /**
   * 同步获取所有数据（不触发加载，返回当前缓存）
   */
  getDataSync(): HistoryTableData[] {
    return this.tableData.slice()
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
      const db = GetIBestORM();
      for (const id of ids) {
        db.Table("processing_history").Where('id', id).Delete()
      }
      await this.loadDataFromDatabase()
    } catch (error) {
      console.error('❌ 批量删除数据失败:', error)
      const err = error as object
      throw new Error(JSON.stringify(err))
    }
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
