/**
 * 历史表格数据管理器
 * 负责表格数据的增删改查操作
 * 已改为从数据库读取数据
 */

import { GetIBestORM } from '../../../database/orm';
import { DateValidationUtils } from '../../../utils/helpers/DateValidationUtils'
import { ProcessingHistory } from '../../../database/models/ProcessingHistory'
import { ProcessingHistoryData } from '../../../database/types'
import { DatabaseQueueManager } from '../../../utils/network/database';
import GlobalStore from '../../../database/orm/model/GlobalStore';
import { relationalStore } from '@kit.ArkData';
import { taskpool } from '@kit.ArkTS';
import { Context } from '@kit.AbilityKit';

/**
 * 在 TaskPool 中执行带过滤条件的计数查询
 */
@Concurrent
async function countFilteredRecords(ctx: Context, filters: FilterParams): Promise<number> {
  const db = GetIBestORM();
  const core = db.GetCore();
  let sql = "SELECT COUNT(*) AS cnt FROM processing_history WHERE 1=1";
  const parts: string[] = [];
  const cn = filters.customerName && filters.customerName.trim().length > 0 ? filters.customerName.trim() : '';
  const fn = filters.farmName && filters.farmName.trim().length > 0 ? filters.farmName.trim() : '';
  const tn = filters.fruitName && filters.fruitName.trim().length > 0 ? filters.fruitName.trim() : '';
  const st = filters.status ? String(filters.status) : '';
  if (cn) parts.push(` AND customer_name='${cn.replace(/'/g, "''")}'`);
  if (fn) parts.push(` AND farm_name='${fn.replace(/'/g, "''")}'`);
  if (tn) parts.push(` AND fruit_name='${tn.replace(/'/g, "''")}'`);
  if (st) parts.push(` AND status='${st.replace(/'/g, "''")}'`);
  const sd = filters.startDate ? DateValidationUtils.extractDatePart(filters.startDate) : '';
  const ed = filters.endDate ? DateValidationUtils.extractDatePart(filters.endDate) : '';
  if (sd && DateValidationUtils.isValidDateFormat(sd)) {
    parts.push(` AND start_time>='${sd}'`);
  }
  if (ed && DateValidationUtils.isValidDateFormat(ed)) {
    parts.push(` AND end_time<='${ed} 23:59:59'`);
  }
  sql += parts.join('');
  const rs = core!.querySqlSync(sql);
  let total = 0;
  if (rs.columnCount > 0 && rs.goToFirstRow()) {
    const col = rs.columnNames[0];
    total = rs.getDouble(rs.getColumnIndex(col)) as number;
  }
  rs.close();
  return total;
}

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
      const data = await this.getPage(1, 50)
      this.tableData = data
      this.dataLoaded = true
    } catch (error) {
      console.error('❌ 从数据库加载历史加工数据失败:', error)
      this.tableData = []
      this.dataLoaded = true
    }
  }

  /**
   * 加载所有数据（用于重置功能）
   * 使用查询 Dispatch 队列 + TaskPool，避免阻塞 UI
   * 每次调用都会执行查询，不使用缓存
   */
  public async loadAllData(): Promise<HistoryTableData[]> {
    try {
      const ctx = GlobalStore.context
      if (!ctx) {
        // 回退：未初始化 Context 时直接查询
        const db = GetIBestORM()
        const dbRecords = db.Table('processing_history').OrderByDesc('id').Find(ProcessingHistory) as ProcessingHistoryData[]
        this.tableData = dbRecords.map(record => this.mapRecord(record))
        this.dataLoaded = true
        return this.tableData.slice()
      }

      // 使用 TaskPool 异步加载所有数据（每次都会查询数据库）
      const dbRecords = await DatabaseQueueManager.queryAll(ctx)
      const out: HistoryTableData[] = []
      for (let i = 0; i < dbRecords.length; i++) {
        out.push(this.mapRecord(dbRecords[i]))
      }
      this.tableData = out
      this.dataLoaded = true
      
      return out.slice()
    } catch (error) {
      console.error('❌ 从数据库加载全部历史加工数据失败:', error)
      const err = error instanceof Error ? error : new Error(String(error))
      throw err
    }
  }


  /**
   * 添加数据（保存到数据库）
   * 使用 Dispatch 队列管理，避免阻塞 UI 线程
   */
  async addData(data: AddDataParams): Promise<void> {
    try {
      const ctx = GlobalStore.context;
      if (!ctx) {
        throw new Error('Context 未初始化');
      }
      
      const values: relationalStore.ValuesBucket = {
        customer_name: data.customerName,
        farm_name: data.farmName,
        fruit_name: data.fruitName,
        status: data.status,
        start_time: data.startTime,
        end_time: data.endTime,
        weight: data.weight,
        quantity: data.count
      };
      
      await DatabaseQueueManager.insert(ctx, values);
      await this.loadDataFromDatabase()
    } catch (error) {
      console.error('❌ 添加数据到数据库失败:', error)
      const err = error as object
      throw new Error(JSON.stringify(err))
    }
  }

  /**
   * 删除数据（从数据库删除）
   * 使用 Dispatch 队列管理，避免阻塞 UI 线程
   */
  async deleteData(id: number): Promise<void> {
    try {
      const ctx = GlobalStore.context;
      if (!ctx) {
        throw new Error('Context 未初始化');
      }
      
      await DatabaseQueueManager.delete(ctx, id);
      await this.loadDataFromDatabase()
    } catch (error) {
      console.error('❌ 从数据库删除数据失败:', error)
      const err = error as object
      throw new Error(JSON.stringify(err))
    }
  }

  /**
   * 更新数据（保存到数据库）
   * 使用 Dispatch 队列管理，避免阻塞 UI 线程
   */
  async updateData(id: number, newData: UpdateDataParams): Promise<void> {
    try {
      const currentData = this.tableData.find(item => item.id === id)
      if (!currentData) {
        throw new Error(`未找到要更新的数据，ID: ${id}`)
      }
      
      const ctx = GlobalStore.context;
      if (!ctx) {
        throw new Error('Context 未初始化');
      }
      
      const values: relationalStore.ValuesBucket = {};
      if (newData.customerName !== undefined) values['customer_name'] = newData.customerName;
      if (newData.farmName !== undefined) values['farm_name'] = newData.farmName;
      if (newData.fruitName !== undefined) values['fruit_name'] = newData.fruitName;
      if (newData.status !== undefined) values['status'] = newData.status;
      if (newData.startTime !== undefined) values['start_time'] = newData.startTime;
      if (newData.endTime !== undefined) values['end_time'] = newData.endTime;
      if (newData.weight !== undefined) values['weight'] = newData.weight;
      if (newData.count !== undefined) values['quantity'] = newData.count;
      
      await DatabaseQueueManager.update(ctx, id, values);
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
   * 使用 Dispatch 队列管理，避免阻塞 UI 线程
   */
  async deleteBatchData(ids: number[]): Promise<void> {
    try {
      const ctx = GlobalStore.context;
      if (!ctx) {
        throw new Error('Context 未初始化');
      }
      
      // 批量删除：使用串行队列，逐个删除
      for (const id of ids) {
        await DatabaseQueueManager.delete(ctx, id);
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
    const data = await this.getPage(1, 50)
    this.tableData = data
    this.dataLoaded = true
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

  private mapRecord(record: ProcessingHistoryData): HistoryTableData {
    const recordId = record.ID || record.id || 0
    return {
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
  }

  /**
   * 获取分页数据
   * 使用 Dispatch 队列管理，避免阻塞 UI 线程
   */
  public async getPage(page: number, size: number): Promise<HistoryTableData[]> {
    const ctx = GlobalStore.context;
    if (!ctx) {
      // 如果没有 Context，回退到直接查询（兼容性）
      const db = GetIBestORM();
      const p = Math.max(1, page)
      const s = Math.max(1, Math.min(200, size))
      const offset = (p - 1) * s
      const dbRecords = db.Table('processing_history').OrderByDesc('id').Limit(s).Offset(offset).Find(ProcessingHistory) as ProcessingHistoryData[]
      const out: HistoryTableData[] = []
      for (let i = 0; i < dbRecords.length; i++) {
        out.push(this.mapRecord(dbRecords[i]))
      }
      return out
    }
    
    const p = Math.max(1, page)
    const s = Math.max(1, Math.min(200, size))
    const dbRecords = await DatabaseQueueManager.queryPage(ctx, p, s);
    const out: HistoryTableData[] = []
    for (let i = 0; i < dbRecords.length; i++) {
      out.push(this.mapRecord(dbRecords[i]))
    }
    return out
  }

  public async refreshDataPage(page: number, size: number, append: boolean = false): Promise<number> {
    const data = await this.getPage(page, size)
    if (append) {
      this.tableData = this.tableData.concat(data)
    } else {
      this.tableData = data
    }
    this.dataLoaded = true
    return data.length
  }

  /**
   * 优化后的计数方法：使用数据库查询而不是内存过滤
   * 性能提升：从O(n)降低到O(1)，n为总记录数
   * 使用 TaskPool 执行，避免阻塞 UI 线程
   */
  public async countFilteredPaginated(filters: FilterParams, pageSize: number = 200): Promise<number> {
    try {
      const ctx = GlobalStore.context;
      if (!ctx) {
        // 如果没有 Context，回退到直接查询（兼容性）
        const db = GetIBestORM();
        const core = db.GetCore();
        let sql = "SELECT COUNT(*) AS cnt FROM processing_history WHERE 1=1";
        const parts: string[] = [];
        const cn = filters.customerName && filters.customerName.trim().length > 0 ? filters.customerName.trim() : '';
        const fn = filters.farmName && filters.farmName.trim().length > 0 ? filters.farmName.trim() : '';
        const tn = filters.fruitName && filters.fruitName.trim().length > 0 ? filters.fruitName.trim() : '';
        const st = filters.status ? String(filters.status) : '';
        if (cn) parts.push(` AND customer_name='${cn.replace(/'/g, "''")}'`);
        if (fn) parts.push(` AND farm_name='${fn.replace(/'/g, "''")}'`);
        if (tn) parts.push(` AND fruit_name='${tn.replace(/'/g, "''")}'`);
        if (st) parts.push(` AND status='${st.replace(/'/g, "''")}'`);
        const sd = filters.startDate ? DateValidationUtils.extractDatePart(filters.startDate) : '';
        const ed = filters.endDate ? DateValidationUtils.extractDatePart(filters.endDate) : '';
        if (sd && DateValidationUtils.isValidDateFormat(sd)) {
          parts.push(` AND start_time>='${sd}'`);
        }
        if (ed && DateValidationUtils.isValidDateFormat(ed)) {
          parts.push(` AND end_time<='${ed} 23:59:59'`);
        }
        sql += parts.join('');
        const rs = core!.querySqlSync(sql);
        let total = 0;
        if (rs.columnCount > 0 && rs.goToFirstRow()) {
          const col = rs.columnNames[0];
          total = rs.getDouble(rs.getColumnIndex(col)) as number;
        }
        rs.close();
        return total;
      }
      
      // 使用 TaskPool 执行查询
      const countTask = new taskpool.Task(countFilteredRecords, ctx, filters);
      const result = await taskpool.execute(countTask);
      return result as number;
    } catch (error) {
      console.error('❌ 计数查询失败:', error);
      // 降级到原来的方法
      let total = 0
      let page = 1
      while (true) {
        const data = await this.getPage(page, pageSize)
        if (data.length === 0) {
          break
        }
        const filtered = HistoryTableManager.filterArray(data, filters)
        total += filtered.length
        if (data.length < pageSize) {
          break
        }
        page++
      }
      return total
    }
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
