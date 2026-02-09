import { DateValidationUtils } from '../../../utils/helpers/DateValidationUtils'
import { getORM } from '@ibestservices/ibest-orm'
import { TbFruitinfo } from '../../../db/entities/TbFruitinfo'
/*
import { GetIBestORM } from '../../../database/orm';
import { FruitInfo } from '../../../database/models/FruitInfo';
*/

// 注意：历史加工数据表对应水果信息表（tb_fruitinfo）
// 字段映射关系：
// - 序号：FBatchNo (f_batch_no)
// - 客户名称：CustomerName (customer_name)
// - 农场名称：FarmName (farm_name)
// - 水果名称：FruitName (fruit_name)
// - 加工状态：根据 StartedState 和 CompletedState 判断
// - 开始时间：StartTime (start_time)
// - 完成时间：EndTime (end_time)
// - 批重量：BatchWeight (batch_weight)
// - 批个数：BatchNumber (batch_number)

// 表格数据接口定义
export interface HistoryTableData {
  id: number  // CustomerID (主键)
  batchNo: string  // FBatchNo (批次号，不是序号)
  customerName: string  // CustomerName
  farmName: string  // FarmName
  fruitName: string  // FruitName
  status: '已完成' | '进行中' | '待开始'  // 根据 StartedState 和 CompletedState 判断
  startTime: string  // StartTime
  endTime: string  // EndTime
  weight: number  // BatchWeight (批重量)
  count: number  // BatchNumber (批个数)
  // 注意：序号（serialNumber）是自增的，在表格显示时使用 rowIdx + 1，不需要存储
}

// 添加数据的接口
export interface AddDataParams {
  customerID?: number
  customerName: string
  farmName: string
  fruitName: string
  status: '已完成' | '进行中' | '待开始'
  startTime: string
  endTime: string
  weight: number
  count: number
  batchNo?: string
  orderID?: number
  programName?: string
  channelNum?: number
  exportSum?: number
  qualityGradeSum?: number
  weightOrSizeGradeSum?: number
  completedState?: string
}

// 更新数据的接口
export interface UpdateDataParams {
  customerID?: number
  customerName?: string
  farmName?: string
  fruitName?: string
  status?: '已完成' | '进行中' | '待开始'
  startTime?: string
  endTime?: string
  weight?: number
  count?: number
  batchNo?: string
  orderID?: number
  programName?: string
  channelNum?: number
  exportSum?: number
  qualityGradeSum?: number
  weightOrSizeGradeSum?: number
  completedState?: string
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
 * 从水果信息表（tb_fruitinfo）读取数据
 */
export class HistoryTableManager {
  private static instance: HistoryTableManager
  private tableData: HistoryTableData[] = []
  private dataLoaded: boolean = false

  private constructor() {
    // 从数据库加载数据
  }

  /**
   * 根据 StartedState 和 CompletedState 判断加工状态
   */
  private static determineStatus(startedState?: string, completedState?: string, startTime?: string): '已完成' | '进行中' | '待开始' {
    // 如果 CompletedState 有值且表示已完成
    if (completedState && (completedState === '已完成' || completedState === '完成' || completedState === '1' || completedState.toLowerCase() === 'completed')) {
      return '已完成';
    }
    
    // 如果 StartedState 有值或 StartTime 有值，但未完成 -> 进行中
    if ((startedState && startedState.trim() !== '') || (startTime && startTime.trim() !== '')) {
      return '进行中';
    }
    
    // 否则 -> 待开始
    return '待开始';
  }

  /**
   * 将 FruitInfo 转换为 HistoryTableData
   */
  private static mapFruitInfoToHistoryData(fruitInfo: TbFruitinfo): HistoryTableData {
    const id = fruitInfo.CustomerID || 0;
    const status = HistoryTableManager.determineStatus(
      fruitInfo.StartedState,
      fruitInfo.CompletedState,
      fruitInfo.StartTime
    );
    
    return {
      id: id,
      batchNo: fruitInfo.FBatchNo || '',
      customerName: fruitInfo.CustomerName || '',
      farmName: fruitInfo.FarmName || '',
      fruitName: fruitInfo.FruitName || '',
      status: status,
      startTime: fruitInfo.StartTime || '',
      endTime: fruitInfo.EndTime || '',
      weight: fruitInfo.BatchWeight || 0,
      count: fruitInfo.BatchNumber || 0
    };
  }

  public static getInstance(): HistoryTableManager {
    if (!HistoryTableManager.instance) {
      HistoryTableManager.instance = new HistoryTableManager()
    }
    return HistoryTableManager.instance
  }

  /**
   * 从数据库加载数据（从水果信息表读取）
   */
  public async loadDataFromDatabase(): Promise<void> {
    try {
      const orm = getORM()
      const listRaw = orm.query(TbFruitinfo)
        .orderBy('CustomerID', 'desc')
        .find() as TbFruitinfo[]
      const list = await Promise.resolve(listRaw)
      const visibleList = list.filter(item => item.FVisible === undefined || item.FVisible === null || item.FVisible !== 0)
      this.tableData = visibleList.map(item => HistoryTableManager.mapFruitInfoToHistoryData(item))
      this.dataLoaded = true;
    } catch (error) {
      console.error('从数据库加载历史加工数据失败:', error);
      this.tableData = [];
      this.dataLoaded = true;
    }
  }

  /**
   * 加载所有数据（从水果信息表读取）
   */
  public async loadAllData(): Promise<HistoryTableData[]> {
    await this.loadDataFromDatabase();
    return this.tableData.slice();
  }


  /**
   * 添加数据（已禁用：历史加工数据来自水果信息表，不支持直接添加）
   */
  async addData(data: AddDataParams): Promise<void> {
    // 注意：历史加工数据来自水果信息表，不支持通过此接口添加
    // 如需添加数据，请使用 FruitInfoService
    console.warn('历史加工数据来自水果信息表，不支持通过此接口添加');
  }

  /**
   * 删除数据（已禁用：历史加工数据来自水果信息表，不支持直接删除）
   */
  async deleteData(id: number): Promise<void> {
    const orm = getORM()
    await Promise.resolve(
      orm.query(TbFruitinfo)
        .where({ CustomerID: id })
        .update({ FVisible: 0 })
    )
    this.dataLoaded = false
  }

  /**
   * 更新数据（已禁用：历史加工数据来自水果信息表，不支持直接更新）
   */
  async updateData(id: number, newData: UpdateDataParams): Promise<void> {
    const orm = getORM()
    const updateObj: Partial<TbFruitinfo> = {}
    if (newData.customerName !== undefined) updateObj.CustomerName = newData.customerName
    if (newData.farmName !== undefined) updateObj.FarmName = newData.farmName
    if (newData.fruitName !== undefined) updateObj.FruitName = newData.fruitName
    if (newData.startTime !== undefined) updateObj.StartTime = newData.startTime
    if (newData.endTime !== undefined) updateObj.EndTime = newData.endTime
    if (newData.batchNo !== undefined) updateObj.FBatchNo = newData.batchNo
    if (newData.weight !== undefined) updateObj.BatchWeight = newData.weight
    if (newData.count !== undefined) updateObj.BatchNumber = newData.count
    if (newData.completedState !== undefined) updateObj.CompletedState = newData.completedState

    await Promise.resolve(
      orm.query(TbFruitinfo)
        .where({ CustomerID: id })
        .update(updateObj)
    )
    this.dataLoaded = false
  }

  /**
   * 获取所有数据（如果未加载则先加载）
   */
  async getData(): Promise<HistoryTableData[]> {
    if (!this.dataLoaded) {
      await this.loadDataFromDatabase();
    }
    return this.tableData.slice();
  }
  
  /**
   * 同步获取所有数据（不触发加载，返回当前缓存）
   */
  getDataSync(): HistoryTableData[] {
    return this.tableData.slice();
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
   * 从数据库查询数据（支持筛选条件）
   */
  public async queryFromDB(filters: FilterParams): Promise<HistoryTableData[]> {
    try {
      const orm = getORM()
      let qb = orm.query(TbFruitinfo)

      if (filters.customerName && filters.customerName.trim() !== '') {
        qb = qb.where({ CustomerName: { like: `%${filters.customerName.trim()}%` } })
      }
      if (filters.farmName && filters.farmName.trim() !== '') {
        qb = qb.where({ FarmName: { like: `%${filters.farmName.trim()}%` } })
      }
      if (filters.fruitName && filters.fruitName.trim() !== '') {
        qb = qb.where({ FruitName: { like: `%${filters.fruitName.trim()}%` } })
      }

      const hasStart = !!filters.startDate
      const hasEnd = !!filters.endDate
      if (hasStart || hasEnd) {
        const startDay = (filters.startDate && filters.startDate.trim() !== '') ? filters.startDate.trim() : '1970-01-01'
        const endDay = (filters.endDate && filters.endDate.trim() !== '') ? filters.endDate.trim() : '9999-12-31'
        const startTime = `${startDay} 00:00:00`
        const endTime = `${endDay} 23:59:59`
        qb = qb.whereBetween('StartTime', startTime, endTime)
      }

      const listRaw = qb.orderBy('CustomerID', 'desc').find() as TbFruitinfo[]
      const list = await Promise.resolve(listRaw)
      const visibleList = list.filter(item => item.FVisible === undefined || item.FVisible === null || item.FVisible !== 0)
      let result = visibleList.map(item => HistoryTableManager.mapFruitInfoToHistoryData(item))

      if (filters.status) {
        result = result.filter(item => item.status === filters.status)
      }

      return result
    } catch (error) {
      console.error('数据库查询失败:', error);
      return [];
    }
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
   * 批量删除数据（已禁用：历史加工数据来自水果信息表，不支持直接删除）
   */
  async deleteBatchData(ids: number[]): Promise<void> {
    const orm = getORM()
    await Promise.resolve(
      orm.transaction(async () => {
        for (const id of ids) {
          await Promise.resolve(
            orm.query(TbFruitinfo)
              .where({ CustomerID: id })
              .update({ FVisible: 0 })
          )
        }
      })
    )
    this.dataLoaded = false
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
    await this.loadDataFromDatabase();
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

  /**
   * 获取分页数据（从内存数据分页）
   */
  public async getPage(page: number, size: number): Promise<HistoryTableData[]> {
    const p = Math.max(1, page);
    const s = Math.max(1, Math.min(200, size));
    const start = (p - 1) * s;
    const orm = getORM()
    const listRaw = orm.query(TbFruitinfo)
      .orderBy('CustomerID', 'desc')
      .limit(s)
      .offset(start)
      .find() as TbFruitinfo[]
    const list = await Promise.resolve(listRaw)
    const visibleList = list.filter(item => item.FVisible === undefined || item.FVisible === null || item.FVisible !== 0)
    return visibleList.map(item => HistoryTableManager.mapFruitInfoToHistoryData(item))
  }

  public async refreshDataPage(page: number, size: number, append: boolean = false): Promise<number> {
    const data = await this.getPage(page, size);
    if (append) {
      // 追加模式：合并数据（去重）
      const existingIds = new Set(this.tableData.map(item => item.id));
      const newData = data.filter(item => !existingIds.has(item.id));
      this.tableData = this.tableData.concat(newData);
    } else {
      // 替换模式：重新加载所有数据
      await this.loadDataFromDatabase();
    }
    this.dataLoaded = true;
    return data.length;
  }

  /**
   * 计数方法（从内存数据过滤计数）
   */
  public async countFilteredPaginated(filters: FilterParams, pageSize: number = 200): Promise<number> {
    // 如果未加载，先加载数据
    if (!this.dataLoaded) {
      await this.loadDataFromDatabase();
    }
    
    const filtered = this.filterData(filters);
    return filtered.length;
  }

  static filterArray(source: HistoryTableData[], filters: FilterParams): HistoryTableData[] {
    let filteredData = [...source]
    if (filters.startDate || filters.endDate) {
      filteredData = filteredData.filter(item => {
        if (!item.startTime) return false
        const itemStartDate = DateValidationUtils.extractDatePart(item.startTime)
        if (!DateValidationUtils.isValidDateFormat(itemStartDate)) {
          return false
        }
        let itemEndDate = itemStartDate
        if (item.endTime && item.endTime !== '-' && item.endTime.trim() !== '') {
          const endDateStr = DateValidationUtils.extractDatePart(item.endTime)
          if (DateValidationUtils.isValidDateFormat(endDateStr)) {
            itemEndDate = endDateStr
          } else {
            itemEndDate = itemStartDate
          }
        } else {
          itemEndDate = '9999-12-31'
        }
        let queryStartDate = '1970-01-01'
        if (filters.startDate) {
          const extracted = DateValidationUtils.extractDatePart(filters.startDate)
          if (DateValidationUtils.isValidDateFormat(extracted)) {
            queryStartDate = extracted
          } else {
            queryStartDate = '1970-01-01'
          }
        }
        let queryEndDate = '9999-12-31'
        if (filters.endDate) {
          const extracted = DateValidationUtils.extractDatePart(filters.endDate)
          if (DateValidationUtils.isValidDateFormat(extracted)) {
            queryEndDate = extracted
          } else {
            queryEndDate = '9999-12-31'
          }
        }
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
        return shouldShow
      })
    }
    if (filters.customerName && filters.customerName.trim().length > 0) {
      const target = filters.customerName.trim()
      filteredData = filteredData.filter(item => (item.customerName || '').trim() === target)
    }
    if (filters.farmName && filters.farmName.trim().length > 0) {
      const target = filters.farmName.trim()
      filteredData = filteredData.filter(item => (item.farmName || '').trim() === target)
    }
    if (filters.fruitName && filters.fruitName.trim().length > 0) {
      const target = filters.fruitName.trim()
      filteredData = filteredData.filter(item => (item.fruitName || '').trim() === target)
    }
    if (filters.status) {
      filteredData = filteredData.filter(item => item.status === filters.status)
    }
    return filteredData
  }
}
