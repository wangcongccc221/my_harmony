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
import { TABLE_CONFIG } from '../HomeConstants'
import { GlobalDataInterface } from '../../../protocol/GlobalDataInterface'
import { ConstPreDefine } from '../../../protocol/ConstPreDefine'
import { StGradeInfo, StStatistics } from '../../../protocol/Structures'
import { LevelData } from '../../level/core/LevelDataManager'
import { CartonSpecRecord, getPackingSpecStorage } from '../../../utils/storage/PackingSpecStorage'
import util from '@ohos.util'

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
  private dataInterface: GlobalDataInterface = GlobalDataInterface.getInstance()
  private textDecoder: util.TextDecoder = new util.TextDecoder("utf-8", { ignoreBOM: true })

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

  private getLocalLevelData(): LevelData[] {
    const stored = AppStorage.get('LEVEL_TABLE_DATA') as LevelData[] | undefined
    return Array.isArray(stored) ? stored : []
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

  private getPackingSpecById(id: number): CartonSpecRecord {
    const specs = getPackingSpecStorage().getConfigs()
    for (let i = 0; i < specs.length; i++) {
      if (specs[i].id === id) {
        return specs[i]
      }
    }
    if (specs.length > 0) {
      return specs[0]
    }
    return new CartonSpecRecord(1, '默认纸箱', '0', '0', '0', '0', '')
  }

  private buildPackingSpecText(spec: CartonSpecRecord): string {
    return `${spec.length}x${spec.width}x${spec.height}`
  }

  private buildDynamicPackingRow(exitLabel: string, serial: string, grade: string, boxCount: string, specId: number, perMinute: string): TableRow {
    const spec = this.getPackingSpecById(specId)
    return [
      exitLabel,
      serial,
      spec.name,
      grade,
      boxCount,
      this.buildPackingSpecText(spec),
      spec.netWeight,
      perMinute
    ]
  }

  private buildFinishedProductRow(productCode: string, exitLabel: string, serial: string, containerName: string, grade: string, packTime: string, specId: number): TableRow {
    const spec = this.getPackingSpecById(specId)
    return [
      productCode,
      exitLabel,
      serial,
      containerName,
      grade,
      packTime,
      this.buildPackingSpecText(spec),
      spec.netWeight
    ]
  }

  public getLevelTableHeaderTitles(): string[] {
    const config = this.getOrCreateGradeTableConfig(this.currentFSM)
    return ['等级', ...config.sizeGradeNames]
  }

  public getSizeGradeNames(fsm?: 'FSM1' | 'FSM2'): string[] {
    const targetFsm = fsm ?? this.currentFSM
    const config = this.getOrCreateGradeTableConfig(targetFsm)
    return config.sizeGradeNames.slice()
  }

  public getQualityGradeNames(fsm?: 'FSM1' | 'FSM2'): string[] {
    const targetFsm = fsm ?? this.currentFSM
    const config = this.getOrCreateGradeTableConfig(targetFsm)
    return config.qualityGradeNames.slice()
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

  public syncStatisticsTableLevels(levelNames: string[], fsm?: 'FSM1' | 'FSM2'): void {
    const targetFsm = fsm ?? this.currentFSM
    const trimmed = levelNames.map(name => (name ?? '').trim()).filter(name => name.length > 0)
    const prevFsm = this.currentFSM
    this.currentFSM = targetFsm
    const rows = this.getTableData('等级统计表')
    const rowLength = rows.length > 0 ? rows[0].length : TABLE_CONFIG.STATISTICS_TABLE.headers.length
    if (trimmed.length === 0) {
      this.updateFSMTableData('等级统计表', [])
      this.currentFSM = prevFsm
      return
    }
    const rowMap = new Map<string, TableRow>()
    rows.forEach(row => {
      const name = String(row[0] ?? '').trim()
      if (name.length > 0) {
        rowMap.set(name, row)
      }
    })
    const nextRows: TableRow[] = trimmed.map(name => {
      const existing = rowMap.get(name)
      if (existing) {
        const nextRow = this.ensureStatisticsRowLength(existing, rowLength)
        nextRow[0] = name
        return nextRow
      }
      return this.ensureStatisticsRowLength([name], rowLength)
    })
    this.updateFSMTableData('等级统计表', nextRows)
    this.currentFSM = prevFsm
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

  private ensureStatisticsRowLength(row: TableRow, targetLength: number): TableRow {
    const next: TableRow = [...row]
    while (next.length < targetLength) {
      next.push('')
    }
    return next
  }

  private splitExitLabels(value: string): string[] {
    if (!value) {
      return []
    }
    return value
      .split(/[,，/、\s]+/)
      .map(item => item.trim())
      .filter(item => item.length > 0)
  }

  private joinExitLabels(labels: string[]): string {
    return labels.join('、')
  }

  public updateStatisticsTableExit(levelName: string, exit: number): void {
    if (!levelName || exit <= 0) {
      return
    }
    const tableName = '等级统计表'
    const rows = this.getTableData(tableName)
    const rowLength = rows.length > 0 ? rows[0].length : TABLE_CONFIG.STATISTICS_TABLE.headers.length
    const exitLabel = `出口${exit}`
    let found = false
    const updatedRows: TableRow[] = rows.map(row => {
      if (row[0] === levelName) {
        found = true
        const nextRow = this.ensureStatisticsRowLength(row, rowLength)
        const existing = this.splitExitLabels(String(nextRow[2] ?? ''))
        if (!existing.includes(exitLabel)) {
          existing.push(exitLabel)
        }
        nextRow[2] = this.joinExitLabels(existing)
        return nextRow
      }
      return row
    })
    if (!found) {
      const newRow: TableRow = this.ensureStatisticsRowLength([levelName, '', exitLabel], rowLength)
      updatedRows.push(newRow)
    }
    this.updateFSMTableData(tableName, updatedRows)
  }

  public updateStatisticsTableExits(levelNames: string[], exit: number): void {
    if (!Array.isArray(levelNames) || levelNames.length === 0 || exit <= 0) {
      return
    }
    const tableName = '等级统计表'
    const rows = this.getTableData(tableName)
    const rowLength = rows.length > 0 ? rows[0].length : TABLE_CONFIG.STATISTICS_TABLE.headers.length
    const exitLabel = `出口${exit}`
    const targetSet = new Set(levelNames.map(name => String(name ?? '')).filter(name => name.length > 0))
    const seen = new Set<string>()
    const updatedRows: TableRow[] = rows.map(row => {
      const levelName = String(row[0] ?? '')
      if (targetSet.has(levelName)) {
        seen.add(levelName)
        const nextRow = this.ensureStatisticsRowLength(row, rowLength)
        const existing = this.splitExitLabels(String(nextRow[2] ?? ''))
        if (!existing.includes(exitLabel)) {
          existing.push(exitLabel)
        }
        nextRow[2] = this.joinExitLabels(existing)
        return nextRow
      }
      return row
    })
    targetSet.forEach(levelName => {
      if (!seen.has(levelName)) {
        const newRow: TableRow = this.ensureStatisticsRowLength([levelName, '', exitLabel], rowLength)
        updatedRows.push(newRow)
      }
    })
    this.updateFSMTableData(tableName, updatedRows)
  }

  public removeStatisticsTableExit(levelName: string, exit: number): void {
    if (!levelName || exit <= 0) {
      return
    }
    const tableName = '等级统计表'
    const rows = this.getTableData(tableName)
    if (rows.length === 0) {
      return
    }
    const exitLabel = `出口${exit}`
    const updatedRows: TableRow[] = rows.map(row => {
      if (row[0] === levelName) {
        const nextRow: TableRow = [...row]
        const existing = this.splitExitLabels(String(nextRow[2] ?? ''))
        const nextList = existing.filter(item => item !== exitLabel)
        nextRow[2] = this.joinExitLabels(nextList)
        return nextRow
      }
      return row
    })
    this.updateFSMTableData(tableName, updatedRows)
  }

  private getCurrentSubsysIndex(): number {
    return this.currentFSM === 'FSM2' ? 1 : 0
  }

  private resolveSubsysIndex(value: number): number {
    if (value > 0xFF) {
      return ConstPreDefine.getSubsysIndex(value)
    }
    return value
  }

  private decodeName(buffer: Uint8Array, index: number): string {
    const start = index * ConstPreDefine.MAX_TEXT_LENGTH
    const end = start + ConstPreDefine.MAX_TEXT_LENGTH
    const slice = buffer.slice(start, end)
    let len = 0
    while (len < slice.length && slice[len] !== 0) len++
    if (len === 0) return ''
    try {
      return this.textDecoder.decode(slice.slice(0, len))
    } catch (_e) {
      return ''
    }
  }

  private buildGradeName(info: StGradeInfo, qualityIdx: number, sizeIdx: number): string {
    const sizeName = this.decodeName(info.strSizeGradeName, sizeIdx)
    const qualityName = this.decodeName(info.strQualityGradeName, qualityIdx)
    if (info.nQualityGradeNum > 0 && info.nClassifyType > 0) {
      if (sizeName && qualityName) return `${sizeName}.${qualityName}`
      if (sizeName) return sizeName
      if (qualityName) return qualityName
      return ''
    }
    return sizeName || qualityName || ''
  }

  private getMeasureValue(info: StGradeInfo, index: number): string {
    const grade = info.grades[index]
    if (!grade) return ''
    const value = Number(grade.nMinSize)
    if (!Number.isFinite(value) || Math.abs(value) > 1e8) return ''
    return value.toFixed(2)
  }

  private buildExitLabels(info: StGradeInfo, index: number): string {
    const grade = info.grades[index]
    if (!grade) return ''
    const exit = grade.exit >>> 0
    const labels: string[] = []
    for (let i = 0; i < ConstPreDefine.MAX_EXIT_NUM; i++) {
      if (i < 32) {
        if (((exit >>> i) & 1) === 1) labels.push(`出口${i + 1}`)
      }
    }
    return labels.join('、')
  }

  private formatPercent(value: number, total: number): string {
    if (total <= 0) return '0.00%'
    return ((value * 100) / total).toFixed(2) + '%'
  }

  private getLabelText(labelIndex: number): string {
    if (!Number.isFinite(labelIndex) || labelIndex <= 0) return ''
    const key = `LABELER_NAME_${Math.floor(labelIndex)}`
    const saved = AppStorage.get(key) as string | undefined
    if (saved && saved.trim().length > 0) {
      return saved
    }
    return `贴标机${labelIndex}`
  }

  private buildStatisticsTableData(): TableRow[] {
    const latestGradeInfo = this.dataInterface.getLatestGradeInfo()
    const hasGradeInfo = !!latestGradeInfo && (latestGradeInfo.nQualityGradeNum > 0 || latestGradeInfo.nSizeGradeNum > 0)
    const gradeInfo = latestGradeInfo ?? new StGradeInfo()
    const totalSize = ConstPreDefine.MAX_QUALITY_GRADE_NUM * ConstPreDefine.MAX_SIZE_GRADE_NUM
    const gradeCount: number[] = new Array<number>(totalSize).fill(0)
    const gradeWeight: number[] = new Array<number>(totalSize).fill(0)
    const boxCount: number[] = new Array<number>(totalSize).fill(0)
    const boxWeight: number[] = new Array<number>(totalSize).fill(0)
    const targetSubsysIndex = this.getCurrentSubsysIndex()

    const allStats = this.dataInterface.getAllChannelStatistics()
    allStats.forEach((stats: StStatistics) => {
      const subsysIndex = this.resolveSubsysIndex(stats.nSubsysId)
      if (subsysIndex !== targetSubsysIndex) return
      for (let i = 0; i < totalSize; i++) {
        gradeCount[i] += stats.nGradeCount[i] || 0
        gradeWeight[i] += stats.nWeightGradeCount[i] || 0
        boxCount[i] += stats.nBoxGradeCount[i] || 0
        boxWeight[i] += stats.nBoxGradeWeight[i] || 0
      }
    })

    let totalNumSum = 0
    let totalWeightSum = 0
    let totalBoxSum = 0
    for (let i = 0; i < totalSize; i++) {
      totalNumSum += gradeCount[i]
      totalWeightSum += gradeWeight[i]
      totalBoxSum += boxCount[i]
    }

    const qualityNames = hasGradeInfo ? [] : this.getQualityGradeNames()
    const sizeNames = hasGradeInfo ? [] : this.getSizeGradeNames()
    const localLevelData = hasGradeInfo ? [] : this.getLocalLevelData()
    const packingBySize = new Map<string, number>()
    localLevelData.forEach((item: LevelData) => {
      const key = (item.levelName ?? '').trim()
      if (key.length > 0) {
        packingBySize.set(key, item.packingWeight ?? 0)
      }
    })
    const qualityNum = hasGradeInfo
      ? (gradeInfo.nQualityGradeNum > 0 && gradeInfo.nClassifyType > 0 ? gradeInfo.nQualityGradeNum : 1)
      : Math.max(1, qualityNames.length)
    const sizeNum = hasGradeInfo
      ? (gradeInfo.nSizeGradeNum > 0 ? gradeInfo.nSizeGradeNum : 1)
      : Math.max(1, sizeNames.length)
    if (qualityNum <= 0 || sizeNum <= 0) return []

    const rows: TableRow[] = []
    const rowLength = TABLE_CONFIG.STATISTICS_TABLE.headers.length
    const showPackingAmount = hasGradeInfo
      ? ((gradeInfo.nClassifyType & 0x03) > 0 || (gradeInfo.nClassifyType & 0x1C) > 0)
      : packingBySize.size > 0
    const showBoxWeight = hasGradeInfo ? ((gradeInfo.nClassifyType & 0x03) > 0) : boxWeight.some((v: number) => v > 0)
    const showLabel = hasGradeInfo && gradeInfo.nLabelType === 1

    for (let q = 0; q < qualityNum; q++) {
      for (let s = 0; s < sizeNum; s++) {
        const index = q * ConstPreDefine.MAX_SIZE_GRADE_NUM + s
        const count = gradeCount[index] || 0
        const weight = gradeWeight[index] || 0
        const box = boxCount[index] || 0
        const sizeName = hasGradeInfo ? '' : (sizeNames[s] ?? '')
        const qualityName = hasGradeInfo ? '' : (qualityNames[q] ?? '')
        const rowName = hasGradeInfo
          ? this.buildGradeName(gradeInfo, q, s)
          : (sizeName && qualityName ? `${sizeName}.${qualityName}` : (sizeName || qualityName || ''))
        const measureValue = hasGradeInfo ? this.getMeasureValue(gradeInfo, index) : sizeName
        const exitLabel = hasGradeInfo ? this.buildExitLabels(gradeInfo, index) : ''
        const packingAmount = showPackingAmount
          ? (hasGradeInfo
              ? String(gradeInfo.grades[index]?.nFruitNum ?? '')
              : String(packingBySize.get(sizeName) ?? ''))
          : ''
        const weightPerBox = showBoxWeight ? String(boxWeight[index] || 0) : ''
        const label = showLabel ? this.getLabelText(gradeInfo.grades[index]?.sbLabelbyGrade ?? 0) : ''
        const row: TableRow = [
          rowName,
          measureValue,
          exitLabel,
          String(count),
          this.formatPercent(count, totalNumSum),
          String(weight),
          this.formatPercent(weight, totalWeightSum),
          String(box),
          this.formatPercent(box, totalBoxSum),
          packingAmount,
          weightPerBox,
          label
        ]
        rows.push(this.ensureStatisticsRowLength(row, rowLength))
      }
    }
    return rows
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
    const fsmKey = `等级统计表_${this.currentFSM}`
    const statisticsData = this.buildStatisticsTableData()
    this.allTableData[fsmKey] = statisticsData
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
    const packingStorage = getPackingSpecStorage()
    const primarySpecId = packingStorage.getPrimarySpecId()
    const secondarySpecId = packingStorage.getSecondarySpecId()
    
    if (this.currentFSM === 'FSM1') {
      // FSM1的动态装箱表数据
      dynamicPackingData = [
        this.buildDynamicPackingRow('出口1', 'LS001', 'A级', '15', primarySpecId, '3.2'),
        this.buildDynamicPackingRow('出口2', 'LS002', 'B级', '8', secondarySpecId, '2.1'),
        this.buildDynamicPackingRow('出口3', 'LS003', 'A级', '12', primarySpecId, '2.8'),
        this.buildDynamicPackingRow('出口1', 'LS004', 'C级', '6', secondarySpecId, '1.5')
      ]
    } else if (this.currentFSM === 'FSM2') {
      // FSM2的动态装箱表数据（不同的装箱配置）
      dynamicPackingData = [
        this.buildDynamicPackingRow('出口1', 'LS101', '特级', '18', primarySpecId, '4.2'),
        this.buildDynamicPackingRow('出口2', 'LS102', '优级', '12', secondarySpecId, '3.1'),
        this.buildDynamicPackingRow('出口3', 'LS103', '良级', '9', primarySpecId, '2.3'),
        this.buildDynamicPackingRow('出口4', 'LS104', '合格', '6', secondarySpecId, '1.8'),
        this.buildDynamicPackingRow('出口5', 'LS105', '次品', '3', primarySpecId, '1.2')
      ]
    } else {
      // 默认情况，使用FSM1数据
      dynamicPackingData = [
        this.buildDynamicPackingRow('出口1', 'LS001', 'A级', '15', primarySpecId, '3.2'),
        this.buildDynamicPackingRow('出口2', 'LS002', 'B级', '8', secondarySpecId, '2.1'),
        this.buildDynamicPackingRow('出口3', 'LS003', 'A级', '12', primarySpecId, '2.8'),
        this.buildDynamicPackingRow('出口1', 'LS004', 'C级', '6', secondarySpecId, '1.5')
      ]
    }
    
    // 使用FSM特定的键名存储数据
    const fsmKey = `动态装箱_${this.currentFSM}`
    this.allTableData[fsmKey] = dynamicPackingData
    console.log(`初始化${this.currentFSM}动态装箱表数据:`, dynamicPackingData)
    console.log(`[PACKING_SPEC_TABLE] ${this.currentFSM} dynamic primary=${primarySpecId} secondary=${secondarySpecId}`)
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
    const packingStorage = getPackingSpecStorage()
    const primarySpecId = packingStorage.getPrimarySpecId()
    const secondarySpecId = packingStorage.getSecondarySpecId()
    
    if (this.currentFSM === 'FSM1') {
      // FSM1的成品表数据
      finishedProductsData = [
        this.buildFinishedProductRow('CP001', '出口1', 'LS001', '标准容器', 'A级', '2025-01-15 14:30', primarySpecId),
        this.buildFinishedProductRow('CP002', '出口2', 'LS002', '小容器', 'B级', '2025-01-15 15:45', secondarySpecId),
        this.buildFinishedProductRow('CP003', '出口3', 'LS003', '标准容器', 'A级', '2025-01-15 16:20', primarySpecId),
        this.buildFinishedProductRow('CP004', '出口1', 'LS004', '大容器', 'C级', '2025-01-15 17:10', secondarySpecId)
      ]
    } else if (this.currentFSM === 'FSM2') {
      // FSM2的成品表数据（不同的成品配置）
      finishedProductsData = [
        this.buildFinishedProductRow('CP201', '出口1', 'LS101', '智能容器', '特级', '2025-01-15 14:30', primarySpecId),
        this.buildFinishedProductRow('CP202', '出口2', 'LS102', '精密容器', '优级', '2025-01-15 15:45', secondarySpecId),
        this.buildFinishedProductRow('CP203', '出口3', 'LS103', '标准容器', '良级', '2025-01-15 16:20', primarySpecId),
        this.buildFinishedProductRow('CP204', '出口4', 'LS104', '小容器', '合格', '2025-01-15 17:10', secondarySpecId),
        this.buildFinishedProductRow('CP205', '出口5', 'LS105', '回收容器', '次品', '2025-01-15 18:30', primarySpecId)
      ]
    } else {
      // 默认情况，使用FSM1数据
      finishedProductsData = [
        this.buildFinishedProductRow('CP001', '出口1', 'LS001', '标准容器', 'A级', '2025-01-15 14:30', primarySpecId),
        this.buildFinishedProductRow('CP002', '出口2', 'LS002', '小容器', 'B级', '2025-01-15 15:45', secondarySpecId),
        this.buildFinishedProductRow('CP003', '出口3', 'LS003', '标准容器', 'A级', '2025-01-15 16:20', primarySpecId),
        this.buildFinishedProductRow('CP004', '出口1', 'LS004', '大容器', 'C级', '2025-01-15 17:10', secondarySpecId)
      ]
    }
    
    // 使用FSM特定的键名存储数据
    const fsmKey = `成品_${this.currentFSM}`
    this.allTableData[fsmKey] = finishedProductsData
    console.log(`初始化${this.currentFSM}成品表数据:`, finishedProductsData)
    console.log(`[PACKING_SPEC_TABLE] ${this.currentFSM} finished primary=${primarySpecId} secondary=${secondarySpecId}`)
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
    const primarySpecId = getPackingSpecStorage().getPrimarySpecId()
    const secondarySpecId = getPackingSpecStorage().getSecondarySpecId()
    const newDynamicPackingData: TableRow[] = [
      this.buildDynamicPackingRow('出口7', 'LS007', 'I级', '5', primarySpecId, '1.0'),
      this.buildDynamicPackingRow('出口8', 'LS008', 'J级', '3', secondarySpecId, '0.8')
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
