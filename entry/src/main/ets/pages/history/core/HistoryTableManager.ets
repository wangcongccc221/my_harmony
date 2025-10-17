/**
 * 历史表格数据管理器
 * 负责表格数据的增删改查操作
 */

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

/**
 * 历史表格数据管理器
 */
export class HistoryTableManager {
  private static instance: HistoryTableManager
  private tableData: HistoryTableData[] = []

  private constructor() {
    // 初始化数据
    this.initDefaultData()
  }

  public static getInstance(): HistoryTableManager {
    if (!HistoryTableManager.instance) {
      HistoryTableManager.instance = new HistoryTableManager()
    }
    return HistoryTableManager.instance
  }

  /**
   * 初始化默认数据
   */
  private initDefaultData(): void {
    this.addData({
      customerName: '客户A',
      farmName: '农场A',
      fruitName: '苹果',
      status: '已完成',
      startTime: '2025-09-15 08:30',
      endTime: '2025-09-15 16:45',
      weight: 2.5,
      count: 150
    })

    this.addData({
      customerName: '客户B',
      farmName: '农场B',
      fruitName: '橙子',
      status: '进行中',
      startTime: '2025-09-18 09:15',
      endTime: '-',
      weight: 1.8,
      count: 120
    })

    this.addData({
      customerName: '客户C',
      farmName: '农场C',
      fruitName: '香蕉',
      status: '已完成',
      startTime: '2025-09-20 07:45',
      endTime: '2025-09-20 14:20',
      weight: 3.2,
      count: 200
    })

    this.addData({
      customerName: '客户A',
      farmName: '农场A',
      fruitName: '葡萄',
      status: '待开始',
      startTime: '2025-09-22 10:00',
      endTime: '-',
      weight: 1.5,
      count: 90
    })

    // 添加更多模拟数据
    this.addData({
      customerName: '客户D',
      farmName: '农场D',
      fruitName: '草莓',
      status: '已完成',
      startTime: '2025-09-16 06:30',
      endTime: '2025-09-16 12:15',
      weight: 0.8,
      count: 60
    })

    this.addData({
      customerName: '客户E',
      farmName: '农场E',
      fruitName: '桃子',
      status: '进行中',
      startTime: '2025-09-19 08:00',
      endTime: '-',
      weight: 2.8,
      count: 180
    })

    this.addData({
      customerName: '客户B',
      farmName: '农场B',
      fruitName: '梨子',
      status: '已完成',
      startTime: '2025-09-17 07:20',
      endTime: '2025-09-17 15:30',
      weight: 3.5,
      count: 220
    })

    this.addData({
      customerName: '客户F',
      farmName: '农场F',
      fruitName: '樱桃',
      status: '待开始',
      startTime: '2025-09-23 09:30',
      endTime: '-',
      weight: 0.6,
      count: 45
    })

    this.addData({
      customerName: '客户C',
      farmName: '农场C',
      fruitName: '柠檬',
      status: '已完成',
      startTime: '2025-09-21 10:15',
      endTime: '2025-09-21 17:45',
      weight: 1.2,
      count: 80
    })

    this.addData({
      customerName: '客户G',
      farmName: '农场G',
      fruitName: '芒果',
      status: '进行中',
      startTime: '2025-09-20 11:00',
      endTime: '-',
      weight: 4.2,
      count: 280
    })

    this.addData({
      customerName: '客户A',
      farmName: '农场A',
      fruitName: '西瓜',
      status: '已完成',
      startTime: '2025-09-18 05:45',
      endTime: '2025-09-18 13:20',
      weight: 8.5,
      count: 120
    })

    this.addData({
      customerName: '客户H',
      farmName: '农场H',
      fruitName: '蓝莓',
      status: '待开始',
      startTime: '2025-09-24 08:45',
      endTime: '-',
      weight: 0.4,
      count: 35
    })

    this.addData({
      customerName: '客户D',
      farmName: '农场D',
      fruitName: '猕猴桃',
      status: '已完成',
      startTime: '2025-09-19 09:30',
      endTime: '2025-09-19 16:00',
      weight: 2.1,
      count: 140
    })

    this.addData({
      customerName: '客户I',
      farmName: '农场I',
      fruitName: '火龙果',
      status: '进行中',
      startTime: '2025-09-21 14:00',
      endTime: '-',
      weight: 1.8,
      count: 95
    })

    this.addData({
      customerName: '客户E',
      farmName: '农场E',
      fruitName: '石榴',
      status: '已完成',
      startTime: '2025-09-17 08:15',
      endTime: '2025-09-17 14:30',
      weight: 1.6,
      count: 110
    })

    this.addData({
      customerName: '客户J',
      farmName: '农场J',
      fruitName: '椰子',
      status: '待开始',
      startTime: '2025-09-25 07:00',
      endTime: '-',
      weight: 5.2,
      count: 85
    })

    this.addData({
      customerName: '客户K',
      farmName: '农场K',
      fruitName: '菠萝',
      status: '已完成',
      startTime: '2025-09-16 14:30',
      endTime: '2025-09-16 20:15',
      weight: 2.3,
      count: 160
    })

    this.addData({
      customerName: '客户L',
      farmName: '农场L',
      fruitName: '荔枝',
      status: '进行中',
      startTime: '2025-09-22 09:45',
      endTime: '-',
      weight: 1.1,
      count: 75
    })

    this.addData({
      customerName: '客户M',
      farmName: '农场M',
      fruitName: '龙眼',
      status: '已完成',
      startTime: '2025-09-19 11:20',
      endTime: '2025-09-19 18:30',
      weight: 0.9,
      count: 65
    })

    this.addData({
      customerName: '客户N',
      farmName: '农场N',
      fruitName: '山竹',
      status: '待开始',
      startTime: '2025-09-26 08:30',
      endTime: '-',
      weight: 1.7,
      count: 110
    })

    this.addData({
      customerName: '客户O',
      farmName: '农场O',
      fruitName: '榴莲',
      status: '已完成',
      startTime: '2025-09-18 16:00',
      endTime: '2025-09-18 22:45',
      weight: 6.8,
      count: 45
    })

    this.addData({
      customerName: '客户P',
      farmName: '农场P',
      fruitName: '百香果',
      status: '进行中',
      startTime: '2025-09-23 13:15',
      endTime: '-',
      weight: 0.5,
      count: 40
    })

    this.addData({
      customerName: '客户Q',
      farmName: '农场Q',
      fruitName: '番石榴',
      status: '已完成',
      startTime: '2025-09-17 10:30',
      endTime: '2025-09-17 16:20',
      weight: 1.4,
      count: 95
    })

    this.addData({
      customerName: '客户R',
      farmName: '农场R',
      fruitName: '莲雾',
      status: '待开始',
      startTime: '2025-09-27 07:45',
      endTime: '-',
      weight: 0.8,
      count: 55
    })

    this.addData({
      customerName: '客户S',
      farmName: '农场S',
      fruitName: '释迦',
      status: '已完成',
      startTime: '2025-09-20 12:00',
      endTime: '2025-09-20 17:30',
      weight: 2.6,
      count: 130
    })

    this.addData({
      customerName: '客户T',
      farmName: '农场T',
      fruitName: '红毛丹',
      status: '进行中',
      startTime: '2025-09-24 15:20',
      endTime: '-',
      weight: 1.3,
      count: 85
    })
  }

  /**
   * 添加数据
   */
  addData(data: AddDataParams): void {
    const newId = this.getNextId()
    const newData: HistoryTableData = {
      id: newId,
      customerName: data.customerName,
      farmName: data.farmName,
      fruitName: data.fruitName,
      status: data.status,
      startTime: data.startTime,
      endTime: data.endTime,
      weight: data.weight,
      count: data.count
    }
    
    this.tableData.push(newData)
    console.log('添加数据成功:', newData)
  }

  /**
   * 删除数据
   */
  deleteData(id: number): void {
    const index = this.tableData.findIndex(item => item.id === id)
    if (index !== -1) {
      const deletedData = this.tableData.splice(index, 1)[0]
      console.log('删除数据成功:', deletedData)
    } else {
      console.log('未找到要删除的数据，ID:', id)
    }
  }

  /**
   * 更新数据
   */
  updateData(id: number, newData: UpdateDataParams): void {
    const index = this.tableData.findIndex(item => item.id === id)
    if (index !== -1) {
      if (newData.customerName !== undefined) {
        this.tableData[index].customerName = newData.customerName
      }
      if (newData.farmName !== undefined) {
        this.tableData[index].farmName = newData.farmName
      }
      if (newData.fruitName !== undefined) {
        this.tableData[index].fruitName = newData.fruitName
      }
      if (newData.status !== undefined) {
        this.tableData[index].status = newData.status
      }
      if (newData.startTime !== undefined) {
        this.tableData[index].startTime = newData.startTime
      }
      if (newData.endTime !== undefined) {
        this.tableData[index].endTime = newData.endTime
      }
      if (newData.weight !== undefined) {
        this.tableData[index].weight = newData.weight
      }
      if (newData.count !== undefined) {
        this.tableData[index].count = newData.count
      }
      console.log('更新数据成功:', this.tableData[index])
    } else {
      console.log('未找到要更新的数据，ID:', id)
    }
  }

  /**
   * 获取所有数据
   */
  getData(): HistoryTableData[] {
    console.log('history:mycum', this.tableData.length)
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
   * 重置为初始数据
   */
  resetToDefault(): void {
    this.clearData()
    this.initDefaultData()
    console.log('重置为初始数据')
  }
}
