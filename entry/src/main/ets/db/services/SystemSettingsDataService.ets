import { getORM } from '@ibestservices/ibest-orm'
import { TbSysConfigs } from '../entities/TbSysConfigs'
import { TbCustomer } from '../entities/TbCustomer'
import { TbBaseFault } from '../entities/TbBaseFault'
import { TbFaultinfo } from '../entities/TbFaultinfo'

export class SystemConfigEntry {
  name: string = ''
  value: string = ''

  constructor(name: string = '', value: string = '') {
    this.name = name
    this.value = value
  }
}

export class CustomerRecord {
  id: number = 0
  name: string = ''
  code: string = ''
  isUse: boolean = false
}

export class BaseFaultRecord {
  id: number = 0
  type: number = 0
  code: string = ''
  module: string = ''
  message: string = ''
}

export class FaultInfoRecord {
  id: number = 0
  type: number = 0
  category: string = ''
  code: string = ''
  module: string = ''
  message: string = ''
  status: string = ''
  startTime: string = ''
  endTime: string = ''
}

export class FaultInfoQuery {
  startDate: string = ''
  endDate: string = ''
  keyword: string = ''
}

interface BaseFaultJsonRow {
  code?: string
  module?: string
  message?: string
  FCode?: string
  FName?: string
  FGroupName?: string
  FMessage?: string
}

export class LabelingSettingsRecord {
  noLabeling: boolean = false
  byExport: boolean = false
  byGrade: boolean = false
  byContainer: boolean = false
  machine1Name: string = ''
  machine1LabelCount: string = ''
  machine1TotalCount: number = 1
  machine2Name: string = ''
  machine2LabelCount: string = ''
  machine2TotalCount: number = 1
  machine3Name: string = ''
  machine3LabelCount: string = ''
  machine3TotalCount: number = 1
  machine4Name: string = ''
  machine4LabelCount: string = ''
  machine4TotalCount: number = 1
}

export class SystemSettingsDataService {
  private static instance: SystemSettingsDataService | null = null

  static getInstance(): SystemSettingsDataService {
    if (!SystemSettingsDataService.instance) {
      SystemSettingsDataService.instance = new SystemSettingsDataService()
    }
    return SystemSettingsDataService.instance
  }

  private readonly defaultConfigEntries: SystemConfigEntry[] = [
    new SystemConfigEntry('拆分器距离', '450'),
    new SystemConfigEntry('出口垂直滚动条', '0'),
    new SystemConfigEntry('大屏开关', '开'),
    new SystemConfigEntry('大屏标题', '大屏实时加工数据'),
    new SystemConfigEntry('大屏端口', '8080'),
    new SystemConfigEntry('ACS-SIM', '关'),
    new SystemConfigEntry('SIM-PLCIP', '192.168.0.0'),
    new SystemConfigEntry('SIM', '开'),
    new SystemConfigEntry('自定义单价', '开'),
    new SystemConfigEntry('MaxRealWeightCount', '66'),
    new SystemConfigEntry('MaxSpeed', '680'),
    new SystemConfigEntry('CheckExport', '关'),
    new SystemConfigEntry('BatchWeightUnit', 'Ton'),
    new SystemConfigEntry('FruitSizeUnit', 'mm'),
    new SystemConfigEntry('FruitWeightUnit', 'g'),
    new SystemConfigEntry('GradeSizeUnit', 'g'),
    new SystemConfigEntry('GradeWeightUnit', 'g'),
    new SystemConfigEntry('ExcelWeightUnit', 'Kg'),
    new SystemConfigEntry('GradeAccuracy', '2'),
    new SystemConfigEntry('ExcelWeightAccuracy', '2'),
    new SystemConfigEntry('BatchWeightAccuracy', '3'),
    new SystemConfigEntry('ProcessInfoWeightAccuracy', '0'),
    new SystemConfigEntry('SumWeightUnit', 'Ton'),
    new SystemConfigEntry('SumWeightAccuracy', '2'),
    new SystemConfigEntry('WeightAccuracy', '1'),
    new SystemConfigEntry('SizeAccuracy', '1'),
    new SystemConfigEntry('DensityAccuracy', '1'),
    new SystemConfigEntry('OpcUaServerUrl', 'opc.tcp://192.168.2.214:4840'),
    new SystemConfigEntry('OpcuaRunning', '0'),
    new SystemConfigEntry('BaseTag', 'Xinjie-Cortex-Linux-SM-CNC'),
    new SystemConfigEntry('I1wCurrentOutletTag', 'To_HMI.ToEIM_IwCurrentOutlet')
  ]

  private readonly defaultCustomers: CustomerRecord[] = [
    this.makeCustomer(0, '管理员', 'ADMIN', true),
    this.makeCustomer(0, '操作员', 'OPERATOR', false)
  ]

  private readonly defaultElectricalFaults: BaseFaultRecord[] = [
    this.makeBaseFault(0, 1, 'E101', 'SCM', '主控通信异常'),
    this.makeBaseFault(0, 1, 'E102', 'FSM', '分选模块未响应'),
    this.makeBaseFault(0, 1, 'E103', '电机', '电机过载告警')
  ]

  private readonly defaultSystemFaults: BaseFaultRecord[] = [
    this.makeBaseFault(0, 0, 'S201', '系统', '配置加载失败'),
    this.makeBaseFault(0, 0, 'S202', '网络', '网络连接异常'),
    this.makeBaseFault(0, 0, 'S203', '数据库', '数据库访问异常')
  ]

  private readonly defaultFaultInfos: FaultInfoRecord[] = [
    this.makeFaultInfo(0, 0, '系统', '26', '', '子系统1通道2,杯重异常', '已修复', '2025-12-05 09:05:34', '2025-12-05 09:05:35'),
    this.makeFaultInfo(0, 0, '系统', '28', '', '子系统1通道4,杯重异常', '已修复', '2025-12-05 09:05:34', '2025-12-05 09:05:35'),
    this.makeFaultInfo(0, 0, '系统', '121', '', '子系统1通道1,IQM通信故障', '已修复', '2025-12-04 10:20:15', '2025-12-04 10:25:30'),
    this.makeFaultInfo(0, 0, '系统', '50', '', 'SCM 1与FSM连接失败,立即检查', '故障中', '2025-12-05 14:30:00', ''),
    this.makeFaultInfo(0, 0, '系统', '50', '', 'SCM 20与FSM连接失败,立即检查', '故障中', '2025-12-05 14:32:15', '')
  ]

  private readonly labelingConfigDefaults: SystemConfigEntry[] = [
    new SystemConfigEntry('贴标工作方式', 'none'),
    new SystemConfigEntry('贴标机1', ''),
    new SystemConfigEntry('贴标机1个数', ''),
    new SystemConfigEntry('贴标机1总数', '1'),
    new SystemConfigEntry('贴标机2', ''),
    new SystemConfigEntry('贴标机2个数', ''),
    new SystemConfigEntry('贴标机2总数', '1'),
    new SystemConfigEntry('贴标机3', ''),
    new SystemConfigEntry('贴标机3个数', ''),
    new SystemConfigEntry('贴标机3总数', '1'),
    new SystemConfigEntry('贴标机4', ''),
    new SystemConfigEntry('贴标机4个数', ''),
    new SystemConfigEntry('贴标机4总数', '1')
  ]

  private constructor() {}

  private makeCustomer(id: number, name: string, code: string, isUse: boolean): CustomerRecord {
    const record = new CustomerRecord()
    record.id = id
    record.name = name
    record.code = code
    record.isUse = isUse
    return record
  }

  private makeBaseFault(id: number, type: number, code: string, module: string, message: string): BaseFaultRecord {
    const record = new BaseFaultRecord()
    record.id = id
    record.type = type
    record.code = code
    record.module = module
    record.message = message
    return record
  }

  private makeFaultInfo(id: number, type: number, category: string, code: string, module: string, message: string, status: string, startTime: string, endTime: string): FaultInfoRecord {
    const record = new FaultInfoRecord()
    record.id = id
    record.type = type
    record.category = category
    record.code = code
    record.module = module
    record.message = message
    record.status = status
    record.startTime = startTime
    record.endTime = endTime
    return record
  }

  async ensureDefaults(): Promise<void> {
    await this.ensureConfigDefaults()
    await this.ensureCustomerDefaults()
    await this.ensureBaseFaultDefaults(1)
    await this.ensureBaseFaultDefaults(0)
    await this.ensureFaultInfoDefaults()
    await this.ensureLabelingDefaults()
  }

  private async ensureConfigDefaults(): Promise<void> {
    const orm = getORM()
    const listRaw = orm.query(TbSysConfigs).find() as TbSysConfigs[]
    const list = await Promise.resolve(listRaw)
    if (list.length > 0) return
    for (let i = 0; i < this.defaultConfigEntries.length; i++) {
      const row = new TbSysConfigs()
      row.FModuleName = '系统设置'
      row.FType = this.defaultConfigEntries[i].name
      row.FValue = this.defaultConfigEntries[i].value
      row.FVisible = 1
      row.FCreateDate = new Date().toISOString()
      row.FEnType = this.defaultConfigEntries[i].name
      row.FZhType = this.defaultConfigEntries[i].name
      row.FValueType = 0
      await Promise.resolve(orm.insert(row))
    }
  }

  private async ensureCustomerDefaults(): Promise<void> {
    const orm = getORM()
    const listRaw = orm.query(TbCustomer).find() as TbCustomer[]
    const list = await Promise.resolve(listRaw)
    if (list.length > 0) return
    for (let i = 0; i < this.defaultCustomers.length; i++) {
      const row = new TbCustomer()
      row.FName = this.defaultCustomers[i].name
      row.FCode = this.defaultCustomers[i].code
      row.FPassWord = ''
      row.FIsUse = this.defaultCustomers[i].isUse ? '1' : '0'
      row.FCreateDate = new Date().toISOString()
      await Promise.resolve(orm.insert(row))
    }
  }

  private async ensureBaseFaultDefaults(type: number): Promise<void> {
    const orm = getORM()
    const listRaw = orm.query(TbBaseFault).where({ FType: type }).find() as TbBaseFault[]
    const list = await Promise.resolve(listRaw)
    if (list.length > 0) return
    const defaults = type === 1 ? this.defaultElectricalFaults : this.defaultSystemFaults
    for (let i = 0; i < defaults.length; i++) {
      const row = new TbBaseFault()
      row.FType = type
      row.FCode = defaults[i].code
      row.FName = defaults[i].module
      row.FGroupName = defaults[i].module
      row.FMessage = defaults[i].message
      row.FStatus = 1
      row.FCreateDate = new Date().toISOString()
      await Promise.resolve(orm.insert(row))
    }
  }

  private async ensureFaultInfoDefaults(): Promise<void> {
    const orm = getORM()
    const listRaw = orm.query(TbFaultinfo).find() as TbFaultinfo[]
    const list = await Promise.resolve(listRaw)
    if (list.length > 0) return
    for (let i = 0; i < this.defaultFaultInfos.length; i++) {
      const row = new TbFaultinfo()
      row.FType = this.defaultFaultInfos[i].type
      row.FCode = this.defaultFaultInfos[i].code
      row.FName = this.defaultFaultInfos[i].category
      row.FMessage = this.defaultFaultInfos[i].message
      row.FStatus = this.defaultFaultInfos[i].status === '故障中' ? 1 : 0
      row.FBeginDate = this.defaultFaultInfos[i].startTime
      row.FEndDate = this.defaultFaultInfos[i].endTime
      await Promise.resolve(orm.insert(row))
    }
  }

  private async ensureLabelingDefaults(): Promise<void> {
    const orm = getORM()
    for (let i = 0; i < this.labelingConfigDefaults.length; i++) {
      const existingRaw = orm.query(TbSysConfigs).where({ FType: this.labelingConfigDefaults[i].name }).first() as TbSysConfigs | null
      const existing = await Promise.resolve(existingRaw)
      if (existing) continue
      const row = new TbSysConfigs()
      row.FModuleName = '贴标设置'
      row.FType = this.labelingConfigDefaults[i].name
      row.FValue = this.labelingConfigDefaults[i].value
      row.FVisible = 1
      row.FCreateDate = new Date().toISOString()
      row.FEnType = this.labelingConfigDefaults[i].name
      row.FZhType = this.labelingConfigDefaults[i].name
      row.FValueType = 0
      await Promise.resolve(orm.insert(row))
    }
  }

  async getConfigEntries(): Promise<SystemConfigEntry[]> {
    await this.ensureConfigDefaults()
    const orm = getORM()
    const listRaw = orm.query(TbSysConfigs)
      .orderBy('FID', 'asc')
      .find() as TbSysConfigs[]
    const list = await Promise.resolve(listRaw)
    const result: SystemConfigEntry[] = []
    for (let i = 0; i < list.length; i++) {
      if ((list[i].FVisible ?? 1) === 0) continue
      if (!list[i].FType) continue
      result.push(new SystemConfigEntry(list[i].FType ?? '', list[i].FValue ?? ''))
    }
    return result
  }

  async saveConfigEntries(entries: SystemConfigEntry[]): Promise<void> {
    await this.ensureConfigDefaults()
    const orm = getORM()
    await Promise.resolve(
      orm.transaction(async () => {
        for (let i = 0; i < entries.length; i++) {
          const existingRaw = orm.query(TbSysConfigs).where({ FType: entries[i].name }).first() as TbSysConfigs | null
          const existing = await Promise.resolve(existingRaw)
          if (existing && existing.FID) {
            const updateRow = new TbSysConfigs()
            updateRow.FValue = entries[i].value
            await Promise.resolve(
              orm.query(TbSysConfigs)
                .where({ FID: existing.FID })
                .update(updateRow)
            )
          } else {
            const row = new TbSysConfigs()
            row.FModuleName = '系统设置'
            row.FType = entries[i].name
            row.FValue = entries[i].value
            row.FVisible = 1
            row.FCreateDate = new Date().toISOString()
            row.FEnType = entries[i].name
            row.FZhType = entries[i].name
            row.FValueType = 0
            await Promise.resolve(orm.insert(row))
          }
        }
      })
    )
  }

  async getCustomers(): Promise<CustomerRecord[]> {
    await this.ensureCustomerDefaults()
    const orm = getORM()
    const listRaw = orm.query(TbCustomer).orderBy('FID', 'asc').find() as TbCustomer[]
    const list = await Promise.resolve(listRaw)
    const result: CustomerRecord[] = []
    for (let i = 0; i < list.length; i++) {
      const row = new CustomerRecord()
      row.id = list[i].FID ?? 0
      row.name = list[i].FName ?? ''
      row.code = list[i].FCode ?? ''
      row.isUse = (list[i].FIsUse ?? '0') === '1'
      result.push(row)
    }
    return result
  }

  async setCurrentCustomer(id: number): Promise<void> {
    await this.ensureCustomerDefaults()
    const orm = getORM()
    const listRaw = orm.query(TbCustomer).find() as TbCustomer[]
    const list = await Promise.resolve(listRaw)
    await Promise.resolve(
      orm.transaction(async () => {
        for (let i = 0; i < list.length; i++) {
          const updateRow = new TbCustomer()
          updateRow.FIsUse = (list[i].FID ?? 0) === id ? '1' : '0'
          await Promise.resolve(
            orm.query(TbCustomer)
              .where({ FID: list[i].FID })
              .update(updateRow)
          )
        }
      })
    )
  }

  async getBaseFaults(type: number): Promise<BaseFaultRecord[]> {
    await this.ensureBaseFaultDefaults(type)
    const orm = getORM()
    const listRaw = orm.query(TbBaseFault)
      .where({ FType: type })
      .orderBy('FID', 'asc')
      .find() as TbBaseFault[]
    const list = await Promise.resolve(listRaw)
    const result: BaseFaultRecord[] = []
    for (let i = 0; i < list.length; i++) {
      result.push(this.toBaseFaultRecord(list[i]))
    }
    return result
  }

  async saveBaseFaults(type: number, items: BaseFaultRecord[]): Promise<void> {
    const orm = getORM()
    const existingRaw = orm.query(TbBaseFault).where({ FType: type }).find() as TbBaseFault[]
    const existing = await Promise.resolve(existingRaw)
    await Promise.resolve(
      orm.transaction(async () => {
        for (let i = 0; i < existing.length; i++) {
          if (existing[i].FID !== undefined) {
            await Promise.resolve(orm.query(TbBaseFault).where({ FID: existing[i].FID }).delete())
          }
        }
        for (let i = 0; i < items.length; i++) {
          const row = new TbBaseFault()
          row.FType = type
          row.FCode = items[i].code
          row.FName = items[i].module
          row.FGroupName = items[i].module
          row.FMessage = items[i].message
          row.FStatus = 1
          row.FCreateDate = new Date().toISOString()
          await Promise.resolve(orm.insert(row))
        }
      })
    )
  }

  async replaceBaseFaultsByJson(type: number, jsonText: string): Promise<boolean> {
    try {
      const parsed = JSON.parse(jsonText) as BaseFaultJsonRow[]
      const items: BaseFaultRecord[] = []
      for (let i = 0; i < parsed.length; i++) {
        const row = parsed[i]
        items.push(this.makeBaseFault(0, type, row.code ?? row.FCode ?? '', row.module ?? row.FName ?? row.FGroupName ?? '', row.message ?? row.FMessage ?? ''))
      }
      await this.saveBaseFaults(type, items)
      return true
    } catch (_) {
      return false
    }
  }

  async queryFaultInfos(query: FaultInfoQuery): Promise<FaultInfoRecord[]> {
    await this.ensureFaultInfoDefaults()
    const orm = getORM()
    const listRaw = orm.query(TbFaultinfo)
      .orderBy('FID', 'desc')
      .find() as TbFaultinfo[]
    const list = await Promise.resolve(listRaw)
    const keyword = query.keyword.trim().toLowerCase()
    const start = query.startDate.trim()
    const end = query.endDate.trim()
    const result: FaultInfoRecord[] = []
    for (let i = 0; i < list.length; i++) {
      const item = this.toFaultInfoRecord(list[i])
      const startOk = start.length === 0 || item.startTime.slice(0, 10) >= start
      const endOk = end.length === 0 || item.startTime.slice(0, 10) <= end
      const keywordOk = keyword.length === 0 ||
        item.message.toLowerCase().includes(keyword) ||
        item.code.toLowerCase().includes(keyword) ||
        item.category.toLowerCase().includes(keyword)
      if (startOk && endOk && keywordOk) {
        result.push(item)
      }
    }
    return result
  }

  async getLabelingSettings(): Promise<LabelingSettingsRecord> {
    await this.ensureLabelingDefaults()
    const entries = await this.getConfigEntries()
    const map = new Map<string, string>()
    for (let i = 0; i < entries.length; i++) {
      map.set(entries[i].name, entries[i].value)
    }
    const record = new LabelingSettingsRecord()
    const mode = map.get('贴标工作方式') ?? 'none'
    record.noLabeling = mode === 'none'
    record.byExport = mode === 'export'
    record.byGrade = mode === 'grade'
    record.byContainer = mode === 'container'
    record.machine1Name = map.get('贴标机1') ?? ''
    record.machine1LabelCount = map.get('贴标机1个数') ?? ''
    record.machine1TotalCount = this.parseCount(map.get('贴标机1总数'))
    record.machine2Name = map.get('贴标机2') ?? ''
    record.machine2LabelCount = map.get('贴标机2个数') ?? ''
    record.machine2TotalCount = this.parseCount(map.get('贴标机2总数'))
    record.machine3Name = map.get('贴标机3') ?? ''
    record.machine3LabelCount = map.get('贴标机3个数') ?? ''
    record.machine3TotalCount = this.parseCount(map.get('贴标机3总数'))
    record.machine4Name = map.get('贴标机4') ?? ''
    record.machine4LabelCount = map.get('贴标机4个数') ?? ''
    record.machine4TotalCount = this.parseCount(map.get('贴标机4总数'))
    return record
  }

  async saveLabelingSettings(record: LabelingSettingsRecord): Promise<void> {
    const mode = record.byExport ? 'export' : (record.byGrade ? 'grade' : (record.byContainer ? 'container' : 'none'))
    const entries: SystemConfigEntry[] = [
      new SystemConfigEntry('贴标工作方式', mode),
      new SystemConfigEntry('贴标机1', record.machine1Name),
      new SystemConfigEntry('贴标机1个数', record.machine1LabelCount),
      new SystemConfigEntry('贴标机1总数', `${record.machine1TotalCount}`),
      new SystemConfigEntry('贴标机2', record.machine2Name),
      new SystemConfigEntry('贴标机2个数', record.machine2LabelCount),
      new SystemConfigEntry('贴标机2总数', `${record.machine2TotalCount}`),
      new SystemConfigEntry('贴标机3', record.machine3Name),
      new SystemConfigEntry('贴标机3个数', record.machine3LabelCount),
      new SystemConfigEntry('贴标机3总数', `${record.machine3TotalCount}`),
      new SystemConfigEntry('贴标机4', record.machine4Name),
      new SystemConfigEntry('贴标机4个数', record.machine4LabelCount),
      new SystemConfigEntry('贴标机4总数', `${record.machine4TotalCount}`)
    ]
    await this.saveConfigEntries(entries)
  }

  private parseCount(value: string | undefined): number {
    const parsed = Number(value ?? '1')
    if (!Number.isFinite(parsed) || parsed <= 0) {
      return 1
    }
    return Math.floor(parsed)
  }

  private toBaseFaultRecord(row: TbBaseFault): BaseFaultRecord {
    const item = new BaseFaultRecord()
    item.id = row.FID ?? 0
    item.type = row.FType ?? 0
    item.code = row.FCode ?? ''
    item.module = row.FName ?? row.FGroupName ?? ''
    item.message = row.FMessage ?? ''
    return item
  }

  private toFaultInfoRecord(row: TbFaultinfo): FaultInfoRecord {
    const item = new FaultInfoRecord()
    item.id = row.FID ?? 0
    item.type = row.FType ?? 0
    item.category = row.FName ?? '系统'
    item.code = row.FCode ?? ''
    item.module = ''
    item.message = row.FMessage ?? ''
    item.status = (row.FStatus ?? 0) === 1 ? '故障中' : '已修复'
    item.startTime = row.FBeginDate ?? ''
    item.endTime = row.FEndDate ?? ''
    return item
  }
}
