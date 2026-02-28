export const MORE_DEVICE_INFO_KEY: string = 'MoreDeviceInfoJson'
export const MORE_CONFIG_SETTINGS_KEY: string = 'MoreConfigSettingsJson'
export const MORE_LABELING_SETTINGS_KEY: string = 'MoreLabelingSettingsJson'
export const MORE_ELECTRICAL_FAULTS_KEY: string = 'MoreElectricalFaultsJson'
export const MORE_SYSTEM_FAULTS_KEY: string = 'MoreSystemFaultsJson'
export const MORE_USER_ACCOUNTS_KEY: string = 'MoreUserAccountsJson'

PersistentStorage.PersistProp(MORE_DEVICE_INFO_KEY, '{}')
PersistentStorage.PersistProp(MORE_CONFIG_SETTINGS_KEY, '[]')
PersistentStorage.PersistProp(MORE_LABELING_SETTINGS_KEY, '{}')
PersistentStorage.PersistProp(MORE_ELECTRICAL_FAULTS_KEY, '[]')
PersistentStorage.PersistProp(MORE_SYSTEM_FAULTS_KEY, '[]')
PersistentStorage.PersistProp(MORE_USER_ACCOUNTS_KEY, '[]')

export class MoreDeviceInfoRecord {
  deviceNumber: string = 'RMFC20258013-1'
  deviceName: string = ''
  customerName: string = ''
  fruitVariety: string = ''
  exFactoryDate: string = '2021-05-11'
  expirationDate: string = '2021-05-11'
  personInCharge: string = ''
  contactPhone: string = ''
  location1: string = ''
  location2: string = ''
  location3: string = ''
  location4: string = ''
  detailedAddress: string = ''
  ipmVersion: string = ''
  rssVersion: string = ''
  scmVersion: string = ''
  fsmVersion: string = ''
  dwmVersion: string = ''
  wamVersion: string = ''
  iqmVersion: string = ''
  bdmVersion: string = ''
  debugger: string = ''
  updater: string = ''
  remarks: string = ''
}

export class MoreConfigEntry {
  name: string = ''
  value: string = ''

  constructor(name: string = '', value: string = '') {
    this.name = name
    this.value = value
  }
}

export class MoreLabelingSettingsRecord {
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

export class MoreFaultItem {
  code: string = ''
  module: string = ''
  message: string = ''

  constructor(code: string = '', module: string = '', message: string = '') {
    this.code = code
    this.module = module
    this.message = message
  }
}

export class MoreUserAccountRecord {
  id: number = 0
  name: string = ''
  password: string = ''
  role: string = ''
  isAdmin: boolean = false

  constructor(id: number = 0, name: string = '', password: string = '', role: string = '', isAdmin: boolean = false) {
    this.id = id
    this.name = name
    this.password = password
    this.role = role
    this.isAdmin = isAdmin
  }
}

export class MoreSettingsSnapshot {
  deviceInfo: MoreDeviceInfoRecord = new MoreDeviceInfoRecord()
  configEntries: MoreConfigEntry[] = []
  labelingSettings: MoreLabelingSettingsRecord = new MoreLabelingSettingsRecord()
  electricalFaults: MoreFaultItem[] = []
  systemFaults: MoreFaultItem[] = []
  userAccounts: MoreUserAccountRecord[] = []
}

export class MoreSystemSettingsStorage {
  private static instance: MoreSystemSettingsStorage | null = null

  static getInstance(): MoreSystemSettingsStorage {
    if (MoreSystemSettingsStorage.instance === null) {
      MoreSystemSettingsStorage.instance = new MoreSystemSettingsStorage()
    }
    return MoreSystemSettingsStorage.instance
  }

  private constructor() {}

  private createDefaultConfigEntries(): MoreConfigEntry[] {
    const result: MoreConfigEntry[] = []
    result.push(new MoreConfigEntry('MaxRealWeightCount', '66'))
    result.push(new MoreConfigEntry('MaxSpeed', '680'))
    result.push(new MoreConfigEntry('CheckExport', '关'))
    result.push(new MoreConfigEntry('BatchWeightUnit', 'Ton'))
    result.push(new MoreConfigEntry('FruitSizeUnit', 'mm'))
    result.push(new MoreConfigEntry('FruitWeightUnit', 'g'))
    result.push(new MoreConfigEntry('GradeAccuracy', '2'))
    result.push(new MoreConfigEntry('BatchWeightAccuracy', '3'))
    result.push(new MoreConfigEntry('WeightAccuracy', '1'))
    result.push(new MoreConfigEntry('SizeAccuracy', '1'))
    result.push(new MoreConfigEntry('OpcUaServerUrl', 'opc.tcp://192.168.2.214:4840'))
    result.push(new MoreConfigEntry('ExitDisplay', 'false'))
    return result
  }

  private createDefaultElectricalFaults(): MoreFaultItem[] {
    const result: MoreFaultItem[] = []
    result.push(new MoreFaultItem('0x30001001', 'SCM', '通信超时'))
    result.push(new MoreFaultItem('0x30001002', 'FSM', '出口传感器异常'))
    result.push(new MoreFaultItem('0x30001003', 'WAM', '称重模块离线'))
    return result
  }

  private createDefaultSystemFaults(): MoreFaultItem[] {
    const result: MoreFaultItem[] = []
    result.push(new MoreFaultItem('0x30002001', 'RSS', '数据库初始化失败'))
    result.push(new MoreFaultItem('0x30002002', 'RSS', '配置文件缺失'))
    result.push(new MoreFaultItem('0x30002003', 'IPM', '图像服务未连接'))
    return result
  }

  private createDefaultUsers(): MoreUserAccountRecord[] {
    const result: MoreUserAccountRecord[] = []
    result.push(new MoreUserAccountRecord(1, 'admin', '123456', '管理员', true))
    result.push(new MoreUserAccountRecord(2, 'operator', '123456', '操作员', false))
    return result
  }

  getDeviceInfo(): MoreDeviceInfoRecord {
    const jsonText = (AppStorage.get(MORE_DEVICE_INFO_KEY) as string | undefined) ?? '{}'
    try {
      const parsed = JSON.parse(jsonText) as MoreDeviceInfoRecord
      const record = new MoreDeviceInfoRecord()
      record.deviceNumber = parsed.deviceNumber || record.deviceNumber
      record.deviceName = parsed.deviceName || ''
      record.customerName = parsed.customerName || ''
      record.fruitVariety = parsed.fruitVariety || ''
      record.exFactoryDate = parsed.exFactoryDate || record.exFactoryDate
      record.expirationDate = parsed.expirationDate || record.expirationDate
      record.personInCharge = parsed.personInCharge || ''
      record.contactPhone = parsed.contactPhone || ''
      record.location1 = parsed.location1 || ''
      record.location2 = parsed.location2 || ''
      record.location3 = parsed.location3 || ''
      record.location4 = parsed.location4 || ''
      record.detailedAddress = parsed.detailedAddress || ''
      record.ipmVersion = parsed.ipmVersion || ''
      record.rssVersion = parsed.rssVersion || ''
      record.scmVersion = parsed.scmVersion || ''
      record.fsmVersion = parsed.fsmVersion || ''
      record.dwmVersion = parsed.dwmVersion || ''
      record.wamVersion = parsed.wamVersion || ''
      record.iqmVersion = parsed.iqmVersion || ''
      record.bdmVersion = parsed.bdmVersion || ''
      record.debugger = parsed.debugger || ''
      record.updater = parsed.updater || ''
      record.remarks = parsed.remarks || ''
      return record
    } catch (_) {
      return new MoreDeviceInfoRecord()
    }
  }

  setDeviceInfo(record: MoreDeviceInfoRecord): void {
    AppStorage.setOrCreate(MORE_DEVICE_INFO_KEY, JSON.stringify(record))
  }

  getConfigEntries(): MoreConfigEntry[] {
    const jsonText = (AppStorage.get(MORE_CONFIG_SETTINGS_KEY) as string | undefined) ?? '[]'
    try {
      const parsed = JSON.parse(jsonText) as MoreConfigEntry[]
      const result: MoreConfigEntry[] = []
      for (let i = 0; i < parsed.length; i++) {
        result.push(new MoreConfigEntry(parsed[i].name || '', parsed[i].value || ''))
      }
      return result.length > 0 ? result : this.createDefaultConfigEntries()
    } catch (_) {
      return this.createDefaultConfigEntries()
    }
  }

  setConfigEntries(entries: MoreConfigEntry[]): void {
    AppStorage.setOrCreate(MORE_CONFIG_SETTINGS_KEY, JSON.stringify(entries))
  }

  getLabelingSettings(): MoreLabelingSettingsRecord {
    const jsonText = (AppStorage.get(MORE_LABELING_SETTINGS_KEY) as string | undefined) ?? '{}'
    try {
      const parsed = JSON.parse(jsonText) as MoreLabelingSettingsRecord
      const record = new MoreLabelingSettingsRecord()
      record.noLabeling = parsed.noLabeling
      record.byExport = parsed.byExport
      record.byGrade = parsed.byGrade
      record.byContainer = parsed.byContainer
      record.machine1Name = parsed.machine1Name || ''
      record.machine1LabelCount = parsed.machine1LabelCount || ''
      record.machine1TotalCount = parsed.machine1TotalCount > 0 ? parsed.machine1TotalCount : 1
      record.machine2Name = parsed.machine2Name || ''
      record.machine2LabelCount = parsed.machine2LabelCount || ''
      record.machine2TotalCount = parsed.machine2TotalCount > 0 ? parsed.machine2TotalCount : 1
      record.machine3Name = parsed.machine3Name || ''
      record.machine3LabelCount = parsed.machine3LabelCount || ''
      record.machine3TotalCount = parsed.machine3TotalCount > 0 ? parsed.machine3TotalCount : 1
      record.machine4Name = parsed.machine4Name || ''
      record.machine4LabelCount = parsed.machine4LabelCount || ''
      record.machine4TotalCount = parsed.machine4TotalCount > 0 ? parsed.machine4TotalCount : 1
      return record
    } catch (_) {
      return new MoreLabelingSettingsRecord()
    }
  }

  setLabelingSettings(record: MoreLabelingSettingsRecord): void {
    AppStorage.setOrCreate(MORE_LABELING_SETTINGS_KEY, JSON.stringify(record))
  }

  getElectricalFaults(): MoreFaultItem[] {
    const jsonText = (AppStorage.get(MORE_ELECTRICAL_FAULTS_KEY) as string | undefined) ?? '[]'
    try {
      const parsed = JSON.parse(jsonText) as MoreFaultItem[]
      const result: MoreFaultItem[] = []
      for (let i = 0; i < parsed.length; i++) {
        result.push(new MoreFaultItem(parsed[i].code || '', parsed[i].module || '', parsed[i].message || ''))
      }
      return result.length > 0 ? result : this.createDefaultElectricalFaults()
    } catch (_) {
      return this.createDefaultElectricalFaults()
    }
  }

  setElectricalFaults(items: MoreFaultItem[]): void {
    AppStorage.setOrCreate(MORE_ELECTRICAL_FAULTS_KEY, JSON.stringify(items))
  }

  getSystemFaults(): MoreFaultItem[] {
    const jsonText = (AppStorage.get(MORE_SYSTEM_FAULTS_KEY) as string | undefined) ?? '[]'
    try {
      const parsed = JSON.parse(jsonText) as MoreFaultItem[]
      const result: MoreFaultItem[] = []
      for (let i = 0; i < parsed.length; i++) {
        result.push(new MoreFaultItem(parsed[i].code || '', parsed[i].module || '', parsed[i].message || ''))
      }
      return result.length > 0 ? result : this.createDefaultSystemFaults()
    } catch (_) {
      return this.createDefaultSystemFaults()
    }
  }

  setSystemFaults(items: MoreFaultItem[]): void {
    AppStorage.setOrCreate(MORE_SYSTEM_FAULTS_KEY, JSON.stringify(items))
  }

  getUserAccounts(): MoreUserAccountRecord[] {
    const jsonText = (AppStorage.get(MORE_USER_ACCOUNTS_KEY) as string | undefined) ?? '[]'
    try {
      const parsed = JSON.parse(jsonText) as MoreUserAccountRecord[]
      const result: MoreUserAccountRecord[] = []
      for (let i = 0; i < parsed.length; i++) {
        result.push(new MoreUserAccountRecord(
          parsed[i].id > 0 ? parsed[i].id : i + 1,
          parsed[i].name || '',
          parsed[i].password || '',
          parsed[i].role || '',
          parsed[i].isAdmin
        ))
      }
      return result.length > 0 ? result : this.createDefaultUsers()
    } catch (_) {
      return this.createDefaultUsers()
    }
  }

  setUserAccounts(items: MoreUserAccountRecord[]): void {
    AppStorage.setOrCreate(MORE_USER_ACCOUNTS_KEY, JSON.stringify(items))
  }

  buildSnapshot(): MoreSettingsSnapshot {
    const snapshot = new MoreSettingsSnapshot()
    snapshot.deviceInfo = this.getDeviceInfo()
    snapshot.configEntries = this.getConfigEntries()
    snapshot.labelingSettings = this.getLabelingSettings()
    snapshot.electricalFaults = this.getElectricalFaults()
    snapshot.systemFaults = this.getSystemFaults()
    snapshot.userAccounts = this.getUserAccounts()
    return snapshot
  }

  buildSnapshotJson(): string {
    return JSON.stringify(this.buildSnapshot(), null, 2)
  }

  restoreFromSnapshotJson(text: string): boolean {
    try {
      const parsed = JSON.parse(text) as MoreSettingsSnapshot
      if (parsed.deviceInfo) {
        this.setDeviceInfo(parsed.deviceInfo)
      }
      if (parsed.configEntries && parsed.configEntries.length >= 0) {
        this.setConfigEntries(parsed.configEntries)
      }
      if (parsed.labelingSettings) {
        this.setLabelingSettings(parsed.labelingSettings)
      }
      if (parsed.electricalFaults && parsed.electricalFaults.length >= 0) {
        this.setElectricalFaults(parsed.electricalFaults)
      }
      if (parsed.systemFaults && parsed.systemFaults.length >= 0) {
        this.setSystemFaults(parsed.systemFaults)
      }
      if (parsed.userAccounts && parsed.userAccounts.length >= 0) {
        this.setUserAccounts(parsed.userAccounts)
      }
      return true
    } catch (_) {
      return false
    }
  }

  ensureDefaults(): void {
    if (this.getConfigEntries().length === 0) {
      this.setConfigEntries(this.createDefaultConfigEntries())
    }
    if (this.getElectricalFaults().length === 0) {
      this.setElectricalFaults(this.createDefaultElectricalFaults())
    }
    if (this.getSystemFaults().length === 0) {
      this.setSystemFaults(this.createDefaultSystemFaults())
    }
    if (this.getUserAccounts().length === 0) {
      this.setUserAccounts(this.createDefaultUsers())
    }
  }
}

export function getMoreSystemSettingsStorage(): MoreSystemSettingsStorage {
  return MoreSystemSettingsStorage.getInstance()
}
