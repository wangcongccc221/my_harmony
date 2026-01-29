/**
 * 主页数据管理器        初始化数据  后续需要实现一个add函数可以添加数据
 * 
 * 功能说明：
 * - 管理主页所有表格的数据存储和操作
 * - 提供统一的数据访问接口
 * - 支持数据的增删改查操作
 * - 管理多种类型表格的数据
 * 
 * 支持的数据类型：
 * - 等级表：等级相关数据
 * - 容器表：容器相关数据
 * - 等级统计表：统计相关数据
 * - 动态装箱：装箱相关数据
 * - 成品：成品相关数据
 * 
 * 主要功能：
 * - 数据初始化：为所有表格生成初始数据
 * - 数据添加：向指定表格添加新数据
 * - 数据获取：获取指定表格的数据
 * - 数据清理：清空指定表格的数据
 * - 数据统计：计算表格数据统计信息
 * 
 * 使用方式：
 * ```typescript
 * const dataManager = new HomeDataManager()
 * 
 * // 初始化所有表格数据
 * dataManager.initializeAllTableData()
 * 
 * // 获取等级表数据
 * const levelData = dataManager.getLevelTableData()
 * 
 * // 添加新数据
 * dataManager.addLevelTableData(newData)
 * ```
 */

import { TableRow } from '../../../components/layout/LevelTable'

interface GradeTableConfig {
  sizeGradeNames: string[]
  qualityGradeNames: string[]
}

export class HomeDataManager {
  private static instance: HomeDataManager | null = null
  
  /**
   * 所有表格数据的存储容器
   * 
   * 使用Record类型存储多个表格的数据
   * 键为表格名称，值为表格行数据数组
   * 
   * 示例：
   * {
   *   '等级表': [['A级', '1250.5', '28.5%', '156', '25.2%'], ...],
   *   '容器表': [['容器1', '标准1', '规格1', '等级1'], ...],
   *   ...
   * }
   */
  private allTableData: Record<string, TableRow[]> = {}
  
  /**
   * 当前FSM状态
   */
  private currentFSM: 'FSM1' | 'FSM2' = 'FSM1'

  private static readonly GRADE_TABLE_CONFIG_KEY_PREFIX: string = 'HOME_GRADE_TABLE_CONFIG_'
  
  /**
   * 每个表格的最大数据条数（防止内存泄漏）
   */
  private static readonly MAX_TABLE_ROWS: number = 1000

  /**
   * 私有构造函数，防止外部直接实例化
   */
  private constructor() {}

  private getGradeConfigKey(fsm: 'FSM1' | 'FSM2'): string {
    return `${HomeDataManager.GRADE_TABLE_CONFIG_KEY_PREFIX}${fsm}`
  }

  private getOrCreateGradeTableConfig(fsm: 'FSM1' | 'FSM2'): GradeTableConfig {
    const key = this.getGradeConfigKey(fsm)
    const existing = AppStorage.get(key) as GradeTableConfig | undefined
    if (existing && Array.isArray(existing.sizeGradeNames) && Array.isArray(existing.qualityGradeNames)) {
      return existing
    }
    const defaultConfig: GradeTableConfig = {
      sizeGradeNames: ['30', '20', '10', '0'],
      qualityGradeNames: ['A级', 'B级', 'C级']
    }
    AppStorage.setOrCreate(key, defaultConfig)
    return defaultConfig
  }

  private buildLevelTableRows(config: GradeTableConfig): TableRow[] {
    return config.qualityGradeNames.map((qualityName: string) => {
      const row: string[] = [qualityName]
      config.sizeGradeNames.forEach((sizeName: string) => {
        row.push(`${sizeName}.${qualityName}`)
      })
      return row
    })
  }

  public getLevelTableHeaderTitles(): string[] {
    const config = this.getOrCreateGradeTableConfig(this.currentFSM)
    return ['等级', ...config.sizeGradeNames]
  }

  public updateSizeGradeNames(names: string[], fsm?: 'FSM1' | 'FSM2'): void {
    const targetFsm = fsm ?? this.currentFSM
    const trimmed = names.map(n => (n ?? '').trim()).filter(n => n.length > 0)
    const prev = this.getOrCreateGradeTableConfig(targetFsm)
    const next: GradeTableConfig = {
      sizeGradeNames: trimmed.length > 0 ? trimmed : prev.sizeGradeNames,
      qualityGradeNames: prev.qualityGradeNames
    }
    AppStorage.setOrCreate(this.getGradeConfigKey(targetFsm), next)
    this.allTableData[`等级表_${targetFsm}`] = this.buildLevelTableRows(next)
  }

  public updateQualityGradeNames(names: string[], fsm?: 'FSM1' | 'FSM2'): void {
    const targetFsm = fsm ?? this.currentFSM
    const trimmed = names.map(n => (n ?? '').trim()).filter(n => n.length > 0)
    const prev = this.getOrCreateGradeTableConfig(targetFsm)
    const next: GradeTableConfig = {
      sizeGradeNames: prev.sizeGradeNames,
      qualityGradeNames: trimmed.length > 0 ? trimmed : prev.qualityGradeNames
    }
    AppStorage.setOrCreate(this.getGradeConfigKey(targetFsm), next)
    this.allTableData[`等级表_${targetFsm}`] = this.buildLevelTableRows(next)
  }

  /**
   * 获取单例实例
   * @returns HomeDataManager实例
   */
  public static getInstance(): HomeDataManager {
    if (!HomeDataManager.instance) {
      HomeDataManager.instance = new HomeDataManager()
    }
    return HomeDataManager.instance
  }

  /**
   * 添加数据到指定表格
   * 
   * 功能说明：
   * - 将新数据追加到指定表格的现有数据中
   * - 如果表格不存在，会先创建空的表格数据
   * - 限制表格最大行数，防止内存泄漏
   * 
   * @param tableName 表格名称（如：'等级表', '容器表'等）
   * @param data 要添加的数据（TableRow数组）
   * 
   * 使用示例：
   * ```typescript
   * const newData = [['新等级', '100', '10%', '50', '5%']]
   * dataManager.addTableData('等级表', newData)
   * ```
   */
  addTableData(tableName: string, data: TableRow[]): void {
    // 如果表格不存在，先创建空的表格数据
    if (!this.allTableData[tableName]) {
      this.allTableData[tableName] = []
    }
    
    // 获取现有数据
    const existingData = this.allTableData[tableName]
    const newLength = existingData.length + data.length
    
    // 如果超过最大限制，只保留最新的数据
    if (newLength > HomeDataManager.MAX_TABLE_ROWS) {
      const keepCount = HomeDataManager.MAX_TABLE_ROWS - data.length
      if (keepCount > 0) {
        // 保留最新的 keepCount 条数据，然后追加新数据
        this.allTableData[tableName] = existingData.slice(-keepCount).concat(data)
      } else {
        // 如果新数据本身就超过限制，只保留最新的数据
        this.allTableData[tableName] = data.slice(-HomeDataManager.MAX_TABLE_ROWS)
      }
    } else {
      // 未超过限制，直接追加
      this.allTableData[tableName] = existingData.concat(data)
    }
    
    console.log(`添加数据到${tableName}:`, data.length, '条，当前总数:', this.allTableData[tableName].length)
  }

  /**
   * 设置当前FSM状态
   * 
   * @param fsm FSM状态
   */
  setFSM(fsm: 'FSM1' | 'FSM2'): void {
    this.currentFSM = fsm
    console.log(`数据管理器切换到: ${fsm}`)
  }

  /**
   * 获取当前FSM状态
   * 
   * @returns 当前FSM状态
   */
getCurrentFSM(): 'FSM1' | 'FSM2' {
    return this.currentFSM
  }

  /**
   * 更新FSM特定的表格数据
   * 
   * @param tableName 表格名称
   * @param data 新的表格数据
   */
  updateFSMTableData(tableName: string, data: TableRow[]): void {
    const fsmKey = `${tableName}_${this.currentFSM}`
    this.allTableData[fsmKey] = data
    // 减少日志输出，提升性能
  }

  /**
   * 获取指定表格的数据
   * 
   * 功能说明：
   * - 根据表格名称获取对应的表格数据
   * - 如果表格不存在，返回空数组
   * - 返回的数据是表格行数据的数组
   * - 根据FSM状态返回不同的数据
   * 
   * @param tableName 表格名称（如：'等级表', '容器表'等）
   * @returns 表格数据（TableRow数组），如果表格不存在则返回空数组
   * 
   * 使用示例：
   * ```typescript
   * const levelData = dataManager.getTableData('等级表')
   * console.log('等级表数据:', levelData)
   * ```
   */
  getTableData(tableName: string): TableRow[] {
    // 根据FSM状态返回不同的数据
    const fsmKey = `${tableName}_${this.currentFSM}`
    return this.allTableData[fsmKey] || this.allTableData[tableName] || []
  }

  /**
   * 清空指定表格数据
   * 
   * 功能说明：
   * - 清空指定表格的所有数据
   * - 表格结构保持不变，只是数据被清空
   * - 用于重置表格数据或重新开始数据录入
   * 
   * @param tableName 表格名称（如：'等级表', '容器表'等）
   * 
   * 使用示例：
   * ```typescript
   * dataManager.clearTableData('等级表')
   * // 等级表数据被清空
   * ```
   */
  clearTableData(tableName: string): void {
    this.allTableData[tableName] = []
    console.log(`清空${tableName}数据`)
  }

  /**
   * 清空所有表格数据
   * 
   * 功能说明：
   * - 清空所有表格的数据
   * - 重置数据管理器到初始状态
   * - 用于系统重置或数据清理
   * 
   * 使用示例：
   * ```typescript
   * dataManager.clearAllTableData()
   * // 所有表格数据被清空
   * ```
   */
  clearAllTableData(): void {
    this.allTableData = {}
    console.log('所有表格数据已清空')
  }

  /**
   * 清空等级统计表的出口信息
   * 
   * 功能说明：
   * - 清空等级统计表中所有等级的出口信息
   * - 保留其他数据（重量、个数、占比等）
   * - 将出口列重置为空字符串
   * - 同时清空FSM1和FSM2的数据
   * 
   * 使用示例：
   * ```typescript
   * dataManager.clearStatisticsTableExits()
   * // 等级统计表的出口信息被清空
   * ```
   */
  clearStatisticsTableExits(): void {
    const tableName = '等级统计表'
    // 记录清空前的FSM，避免副作用
    const prevFSM = this.currentFSM
    
    // 清空FSM1的数据
    this.currentFSM = 'FSM1'
    const rows1: TableRow[] = this.getTableData(tableName)
    if (rows1.length > 0) {
      const updatedRows1: TableRow[] = rows1.map(row => {
        const newRow: TableRow = [...row]
        newRow[2] = '' // 清空出口列
        return newRow
      })
      this.updateFSMTableData(tableName, updatedRows1)
    }
    
    // 清空FSM2的数据
    this.currentFSM = 'FSM2'
    const rows2: TableRow[] = this.getTableData(tableName)
    if (rows2.length > 0) {
      const updatedRows2: TableRow[] = rows2.map(row => {
        const newRow: TableRow = [...row]
        newRow[2] = '' // 清空出口列
        return newRow
      })
      this.updateFSMTableData(tableName, updatedRows2)
    }
    // 恢复原FSM，避免影响后续上报与显示
    this.currentFSM = prevFSM
    console.log('等级统计表出口信息已清空（FSM1和FSM2）')
  }

  /**
   * 初始化等级表数据
   * 
   * 功能说明：
   * - 为等级表生成初始的示例数据
   * - 包含不同等级的分拣数据
   * - 数据包含等级、重量、百分比、个数等信息
   * 
   * 数据说明：
   * - A级：最高等级，重量1250.5，占比28.5%
   * - B级：次高等级，重量980.2，占比22.3%
   * - C级：中等等级，重量756.8，占比17.2%
   * - D级：较低等级，重量654.3，占比14.9%
   * 
   * 使用示例：
   * ```typescript
   * dataManager.initializeLevelTableData()
   * // 等级表数据被初始化
   * ```
   */
  initializeLevelTableData(): void {
    const config = this.getOrCreateGradeTableConfig(this.currentFSM)
    const fsmKey = `等级表_${this.currentFSM}`
    this.allTableData[fsmKey] = this.buildLevelTableRows(config)
  }

  /**
   * 初始化容器表数据
   * 
   * 功能说明：
   * - 为容器表生成初始的示例数据
   * - 包含不同容器的配置信息
   * - 数据包含容器名称、分选标准、规格、等级等信息
   * 
   * 数据说明：
   * - A01：重量+尺寸分选，规格600×400×300，A级
   * - B02：外观+颜色分选，规格500×350×280，B级
   * - C03：尺寸分选，规格400×300×250，C级
   * - D04：重量分选，规格550×380×290，A级
   * 
   * 使用示例：
   * ```typescript
   * dataManager.initializeContainerTableData()
   * // 容器表数据被初始化
   * ```
   */
  initializeContainerTableData(): void {
    let containerData: TableRow[]
    
    if (this.currentFSM === 'FSM1') {
      // FSM1的容器表数据
      containerData = [
        ['A01', '重量+尺寸', '600×400×300', 'A级'],
        ['B02', '外观+颜色', '500×350×280', 'B级'],
        ['C03', '尺寸', '400×300×250', 'C级'],
        ['D04', '重量', '550×380×290', 'A级']
      ]
    } else if (this.currentFSM === 'FSM2') {
      // FSM2的容器表数据（不同的容器配置）
      containerData = [
        ['T01', '全自动分选', '800×500×400', '特级'],
        ['Y01', '智能识别', '700×450×350', '优级'],
        ['L01', '精密分选', '600×400×300', '良级'],
        ['H01', '标准分选', '500×350×280', '合格'],
        ['C01', '基础分选', '400×300×250', '次品']
      ]
    } else {
      // 默认情况，使用FSM1数据
      containerData = [
        ['A01', '重量+尺寸', '600×400×300', 'A级'],
        ['B02', '外观+颜色', '500×350×280', 'B级'],
        ['C03', '尺寸', '400×300×250', 'C级'],
        ['D04', '重量', '550×380×290', 'A级']
      ]
    }
    
    // 使用FSM特定的键名存储数据
    const fsmKey = `容器表_${this.currentFSM}`
    this.allTableData[fsmKey] = containerData
    console.log(`初始化${this.currentFSM}容器表数据:`, containerData)
  }

  /**
   * 初始化等级统计表数据
   * 
   * 功能说明：
   * - 为等级统计表生成初始的示例数据
   * - 包含各等级的详细统计信息
   * - 数据包含等级名称、重量、出口、个数、百分比等信息
   * 
   * 数据说明：
   * - A级：重量1250.5，出口1，156个，占比25.2%，箱数8，箱重15.6
   * - B级：重量980.2，出口2，98个，占比15.8%，箱数6，箱重16.3
   * - C级：重量756.8，出口3，78个，占比12.6%，箱数5，箱重15.1
   * - D级：重量654.3，出口4，65个，占比10.5%，箱数4，箱重16.4
   * 
   * 使用示例：
   * ```typescript
   * dataManager.initializeStatisticsTableData()
   * // 等级统计表数据被初始化
   * ```
   */
  initializeStatisticsTableData(): void {
    // 检查当前FSM状态的数据是否已存在，如果存在则不重新初始化
    const fsmKey = `等级统计表_${this.currentFSM}`
    if (this.allTableData[fsmKey] && this.allTableData[fsmKey].length > 0) {
      console.log(`${this.currentFSM}等级统计表数据已存在，跳过初始化`)
      return
    }
    
    let statisticsData: TableRow[]
    
    if (this.currentFSM === 'FSM1') {
      // FSM1的等级统计表数据
      statisticsData = [
        ['A级', '1250.5', '出口1', '156', '25.2%', '1250.5', '28.5%', '8', '26.7%', '156.3', '15.6'],
        ['B级', '980.2', '出口2', '98', '15.8%', '980.2', '22.3%', '6', '20.0%', '163.4', '16.3'],
        ['C级', '756.8', '出口3', '78', '12.6%', '756.8', '17.2%', '5', '16.7%', '151.4', '15.1'],
        ['D级', '654.3', '出口4', '65', '10.5%', '654.3', '14.9%', '4', '13.3%', '163.6', '16.4']
      ]
    } else if (this.currentFSM === 'FSM2') {
      // FSM2的等级统计表数据（不同的等级和数值）
      statisticsData = [
        ['特级', '1580.3', '出口1', '189', '28.7%', '1580.3', '32.1%', '12', '35.3%', '131.7', '13.2'],
        ['优级', '1120.7', '出口2', '134', '20.3%', '1120.7', '22.8%', '9', '26.5%', '124.5', '12.5'],
        ['良级', '890.4', '出口3', '107', '16.2%', '890.4', '18.1%', '7', '20.6%', '127.2', '12.7'],
        ['合格', '720.6', '出口4', '87', '13.2%', '720.6', '14.6%', '5', '14.7%', '144.1', '14.4'],
        ['次品', '450.2', '出口5', '54', '8.2%', '450.2', '9.1%', '3', '8.8%', '150.1', '15.0']
      ]
    } else {
      // 默认情况，使用FSM1数据
      statisticsData = [
        ['A级', '1250.5', '出口1', '156', '25.2%', '1250.5', '28.5%', '8', '26.7%', '156.3', '15.6'],
        ['B级', '980.2', '出口2', '98', '15.8%', '980.2', '22.3%', '6', '20.0%', '163.4', '16.3'],
        ['C级', '756.8', '出口3', '78', '12.6%', '756.8', '17.2%', '5', '16.7%', '151.4', '15.1'],
        ['D级', '654.3', '出口4', '65', '10.5%', '654.3', '14.9%', '4', '13.3%', '163.6', '16.4']
      ]
    }
    
    // 使用FSM特定的键名存储数据
    this.allTableData[fsmKey] = statisticsData
    console.log(`初始化${this.currentFSM}等级统计表数据:`, statisticsData)
  }

  /**
   * 初始化动态装箱表数据
   * 
   * 功能说明：
   * - 为动态装箱表生成初始的示例数据
   * - 包含装箱过程的详细信息
   * - 数据包含出口、流水码、装箱规格、等级、箱数等信息
   * 
   * 数据说明：
   * - 出口1：流水码LS001，标准箱，A级，15箱，大号，净重12.5，箱数/分3.2
   * - 出口2：流水码LS002，小箱，B级，8箱，中号，净重8.3，箱数/分2.1
   * - 出口3：流水码LS003，标准箱，A级，12箱，大号，净重11.8，箱数/分2.8
   * - 出口1：流水码LS004，大箱，C级，6箱，特大号，净重15.2，箱数/分1.5
   * 
   * 使用示例：
   * ```typescript
   * dataManager.initializeDynamicPackingTableData()
   * // 动态装箱表数据被初始化
   * ```
   */
  initializeDynamicPackingTableData(): void {
    let dynamicPackingData: TableRow[]
    
    if (this.currentFSM === 'FSM1') {
      // FSM1的动态装箱表数据
      dynamicPackingData = [
        ['出口1', 'LS001', '标准箱', 'A级', '15', '大号', '12.5', '3.2'],
        ['出口2', 'LS002', '小箱', 'B级', '8', '中号', '8.3', '2.1'],
        ['出口3', 'LS003', '标准箱', 'A级', '12', '大号', '11.8', '2.8'],
        ['出口1', 'LS004', '大箱', 'C级', '6', '特大号', '15.2', '1.5']
      ]
    } else if (this.currentFSM === 'FSM2') {
      // FSM2的动态装箱表数据（不同的装箱配置）
      dynamicPackingData = [
        ['出口1', 'LS101', '智能箱', '特级', '18', '超大号', '15.8', '4.2'],
        ['出口2', 'LS102', '精密箱', '优级', '12', '大号', '11.2', '3.1'],
        ['出口3', 'LS103', '标准箱', '良级', '9', '中号', '8.9', '2.3'],
        ['出口4', 'LS104', '小箱', '合格', '6', '小号', '6.7', '1.8'],
        ['出口5', 'LS105', '回收箱', '次品', '3', '特小号', '4.5', '1.2']
      ]
    } else {
      // 默认情况，使用FSM1数据
      dynamicPackingData = [
        ['出口1', 'LS001', '标准箱', 'A级', '15', '大号', '12.5', '3.2'],
        ['出口2', 'LS002', '小箱', 'B级', '8', '中号', '8.3', '2.1'],
        ['出口3', 'LS003', '标准箱', 'A级', '12', '大号', '11.8', '2.8'],
        ['出口1', 'LS004', '大箱', 'C级', '6', '特大号', '15.2', '1.5']
      ]
    }
    
    // 使用FSM特定的键名存储数据
    const fsmKey = `动态装箱_${this.currentFSM}`
    this.allTableData[fsmKey] = dynamicPackingData
    console.log(`初始化${this.currentFSM}动态装箱表数据:`, dynamicPackingData)
  }

  /**
   * 初始化成品表数据
   * 
   * 功能说明：
   * - 为成品表生成初始的示例数据
   * - 包含成品的详细信息
   * - 数据包含成品码、出口、流水码、容器名称、等级、包装时间等信息
   * 
   * 数据说明：
   * - CP001：出口1，流水码LS001，标准容器，A级，包装时间2025-01-15 14:30，大号，净重12.5
   * - CP002：出口2，流水码LS002，小容器，B级，包装时间2025-01-15 15:45，中号，净重8.3
   * - CP003：出口3，流水码LS003，标准容器，A级，包装时间2025-01-15 16:20，大号，净重11.8
   * - CP004：出口1，流水码LS004，大容器，C级，包装时间2025-01-15 17:10，特大号，净重15.2
   * 
   * 使用示例：
   * ```typescript
   * dataManager.initializeFinishedProductsTableData()
   * // 成品表数据被初始化
   * ```
   */
  initializeFinishedProductsTableData(): void {
    let finishedProductsData: TableRow[]
    
    if (this.currentFSM === 'FSM1') {
      // FSM1的成品表数据
      finishedProductsData = [
        ['CP001', '出口1', 'LS001', '标准容器', 'A级', '2025-01-15 14:30', '大号', '12.5'],
        ['CP002', '出口2', 'LS002', '小容器', 'B级', '2025-01-15 15:45', '中号', '8.3'],
        ['CP003', '出口3', 'LS003', '标准容器', 'A级', '2025-01-15 16:20', '大号', '11.8'],
        ['CP004', '出口1', 'LS004', '大容器', 'C级', '2025-01-15 17:10', '特大号', '15.2']
      ]
    } else if (this.currentFSM === 'FSM2') {
      // FSM2的成品表数据（不同的成品配置）
      finishedProductsData = [
        ['CP201', '出口1', 'LS101', '智能容器', '特级', '2025-01-15 14:30', '超大号', '15.8'],
        ['CP202', '出口2', 'LS102', '精密容器', '优级', '2025-01-15 15:45', '大号', '11.2'],
        ['CP203', '出口3', 'LS103', '标准容器', '良级', '2025-01-15 16:20', '中号', '8.9'],
        ['CP204', '出口4', 'LS104', '小容器', '合格', '2025-01-15 17:10', '小号', '6.7'],
        ['CP205', '出口5', 'LS105', '回收容器', '次品', '2025-01-15 18:30', '特小号', '4.5']
      ]
    } else {
      // 默认情况，使用FSM1数据
      finishedProductsData = [
        ['CP001', '出口1', 'LS001', '标准容器', 'A级', '2025-01-15 14:30', '大号', '12.5'],
        ['CP002', '出口2', 'LS002', '小容器', 'B级', '2025-01-15 15:45', '中号', '8.3'],
        ['CP003', '出口3', 'LS003', '标准容器', 'A级', '2025-01-15 16:20', '大号', '11.8'],
        ['CP004', '出口1', 'LS004', '大容器', 'C级', '2025-01-15 17:10', '特大号', '15.2']
      ]
    }
    
    // 使用FSM特定的键名存储数据
    const fsmKey = `成品_${this.currentFSM}`
    this.allTableData[fsmKey] = finishedProductsData
    console.log(`初始化${this.currentFSM}成品表数据:`, finishedProductsData)
  }

  /**
   * 初始化所有表格数据
   * 
   * 功能说明：
   * - 一次性初始化所有表格的示例数据
   * - 按顺序初始化：等级表、容器表、等级统计表、动态装箱表、成品表
   * - 用于应用启动时的数据初始化
   * 
   * 初始化顺序：
   * 1. 等级表：等级相关数据
   * 2. 容器表：容器配置数据
   * 3. 等级统计表：统计相关数据
   * 4. 动态装箱表：装箱相关数据
   * 5. 成品表：成品相关数据
   * 
   * 使用示例：
   * ```typescript
   * dataManager.initializeAllTableData()
   * // 所有表格数据被初始化
   * ```
   */
  initializeAllTableData(): void {
    // 为FSM1初始化数据
    this.currentFSM = 'FSM1'
    this.initializeLevelTableData()
    this.initializeContainerTableData()
    this.initializeStatisticsTableData()
    this.initializeDynamicPackingTableData()
    this.initializeFinishedProductsTableData()
    
    // 为FSM2初始化数据
    this.currentFSM = 'FSM2'
    this.initializeLevelTableData()
    this.initializeContainerTableData()
    this.initializeStatisticsTableData()
    this.initializeDynamicPackingTableData()
    this.initializeFinishedProductsTableData()
    
    // 重置为FSM1
    this.currentFSM = 'FSM1'
    console.log('所有表格数据初始化完成（FSM1和FSM2）')
  }

  /**
   * 添加新的等级表数据
   * 
   * 功能说明：
   * - 向等级表添加新的等级数据
   * - 用于模拟数据更新或用户添加新等级
   * - 数据包含I级和J级的新等级信息
   * 
   * 新增数据说明：
   * - I级：重量200.5，占比12.5%，25个，占比4.0%
   * - J级：重量150.2，占比9.3%，18个，占比2.9%
   * 
   * 使用示例：
   * ```typescript
   * dataManager.addNewLevelTableData()
   * // 等级表添加了新的I级和J级数据
   * ```
   */
  addNewLevelTableData(): void {
    const newLevelData: TableRow[] = [
      ['I级', '200.5', '12.5%', '25', '4.0%'],
      ['J级', '150.2', '9.3%', '18', '2.9%']
    ]
    this.addTableData('等级表', newLevelData)
  }

  /**
   * 添加新的容器表数据
   * 
   * 功能说明：
   * - 向容器表添加新的容器配置数据
   * - 用于模拟数据更新或用户添加新容器
   * - 数据包含I09和J10的新容器信息
   * 
   * 新增数据说明：
   * - I09：重量+外观分选，规格300×200×180，I级
   * - J10：尺寸+颜色分选，规格280×180×160，J级
   * 
   * 使用示例：
   * ```typescript
   * dataManager.addNewContainerTableData()
   * // 容器表添加了新的I09和J10容器数据
   * ```
   */
  addNewContainerTableData(): void {
    const newContainerData: TableRow[] = [
      ['I09', '重量+外观', '300×200×180', 'I级'],
      ['J10', '尺寸+颜色', '280×180×160', 'J级']
    ]
    this.addTableData('容器表', newContainerData)
  }

  /**
   * 添加新的等级统计表数据
   * 
   * 功能说明：
   * - 向等级统计表添加新的统计数据
   * - 用于模拟数据更新或用户添加新统计信息
   * - 数据包含I级和J级的新统计信息
   * 
   * 新增数据说明：
   * - I级：重量200.5，出口7，25个，占比4.0%，箱数2，箱重10.0
   * - J级：重量150.2，出口8，18个，占比2.9%，箱数1，箱重15.0
   * 
   * 使用示例：
   * ```typescript
   * dataManager.addNewStatisticsTableData()
   * // 等级统计表添加了新的I级和J级统计数据
   * ```
   */
  addNewStatisticsTableData(): void {
    const newStatisticsData: TableRow[] = [
      ['I级', '200.5', '出口7', '25', '4.0%', '200.5', '4.6%', '2', '6.7%', '100.3', '10.0'],
      ['J级', '150.2', '出口8', '18', '2.9%', '150.2', '3.4%', '1', '3.3%', '150.2', '15.0']
    ]
    this.addTableData('等级统计表', newStatisticsData)
  }

  /**
   * 添加新的动态装箱表数据
   * 
   * 功能说明：
   * - 向动态装箱表添加新的装箱数据
   * - 用于模拟数据更新或用户添加新装箱信息
   * - 数据包含出口7和出口8的新装箱信息
   * 
   * 新增数据说明：
   * - 出口7：流水码LS007，标准箱，I级，5箱，中号，净重6.5，箱数/分1.0
   * - 出口8：流水码LS008，小箱，J级，3箱，小号，净重4.2，箱数/分0.8
   * 
   * 使用示例：
   * ```typescript
   * dataManager.addNewDynamicPackingTableData()
   * // 动态装箱表添加了新的出口7和出口8装箱数据
   * ```
   */
  addNewDynamicPackingTableData(): void {
    const newDynamicPackingData: TableRow[] = [
      ['出口7', 'LS007', '标准箱', 'I级', '5', '中号', '6.5', '1.0'],
      ['出口8', 'LS008', '小箱', 'J级', '3', '小号', '4.2', '0.8']
    ]
    this.addTableData('动态装箱', newDynamicPackingData)
  }

  /**
   * 添加新的成品表数据
   * 
   * 功能说明：
   * - 向成品表添加新的成品数据
   * - 用于模拟数据更新或用户添加新成品信息
   * - 数据包含CP007和CP008的新成品信息
   * 
   * 新增数据说明：
   * - CP007：出口7，流水码LS007，标准容器，I级，包装时间2025-01-15 20:30，中号，净重6.5
   * - CP008：出口8，流水码LS008，小容器，J级，包装时间2025-01-15 21:15，小号，净重4.2
   * 
   * 使用示例：
   * ```typescript
   * dataManager.addNewFinishedProductsTableData()
   * // 成品表添加了新的CP007和CP008成品数据
   * ```
   */
  addNewFinishedProductsTableData(): void {
    const newFinishedProductsData: TableRow[] = [
      ['CP007', '出口7', 'LS007', '标准容器', 'I级', '2025-01-15 20:30', '中号', '6.5'],
      ['CP008', '出口8', 'LS008', '小容器', 'J级', '2025-01-15 21:15', '小号', '4.2']
    ]
    this.addTableData('成品', newFinishedProductsData)
  }

  /**
   * 添加所有新数据
   * 
   * 功能说明：
   * - 一次性向所有表格添加新的数据
   * - 按顺序添加：等级表、容器表、等级统计表、动态装箱表、成品表
   * - 用于模拟数据更新或批量添加新数据
   * 
   * 添加顺序：
   * 1. 等级表：添加I级和J级数据
   * 2. 容器表：添加I09和J10容器数据
   * 3. 等级统计表：添加I级和J级统计数据
   * 4. 动态装箱表：添加出口7和出口8装箱数据
   * 5. 成品表：添加CP007和CP008成品数据
   * 
   * 使用示例：
   * ```typescript
   * dataManager.addAllNewData()
   * // 所有表格都添加了新的数据
   * ```
   */
  addAllNewData(): void {
    this.addNewLevelTableData()
    this.addNewContainerTableData()
    this.addNewStatisticsTableData()
    this.addNewDynamicPackingTableData()
    this.addNewFinishedProductsTableData()
    console.log('所有新数据已添加')
  }
}
