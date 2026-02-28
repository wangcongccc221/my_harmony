import { ConstPreDefine } from '../../protocol/ConstPreDefine'

export const EXIT_DISPLAY_ENABLED_KEY: string = 'ExitDisplayEnabled'
export const EXIT_SCREEN_SLEEP_ENABLED_KEY: string = 'ExitScreenSleepEnabled'
export const EXIT_SCREEN_ON_TIME_KEY: string = 'ExitScreenOnTime'
export const EXIT_SCREEN_OFF_TIME_KEY: string = 'ExitScreenOffTime'
export const EXIT_SCREEN_CONFIGS_JSON_KEY: string = 'ExitScreenConfigsJson'

PersistentStorage.PersistProp(EXIT_DISPLAY_ENABLED_KEY, false)
PersistentStorage.PersistProp(EXIT_SCREEN_SLEEP_ENABLED_KEY, true)
PersistentStorage.PersistProp(EXIT_SCREEN_ON_TIME_KEY, '08:00:00')
PersistentStorage.PersistProp(EXIT_SCREEN_OFF_TIME_KEY, '20:00:00')
PersistentStorage.PersistProp(EXIT_SCREEN_CONFIGS_JSON_KEY, '[]')

export class ExitScreenConfigRecord {
  exitNo: number = 0
  customName: string = ''
  additionalInfo: string = ''
  useAutoName: boolean = true

  constructor(exitNo: number = 0, customName: string = '', additionalInfo: string = '', useAutoName: boolean = true) {
    this.exitNo = exitNo
    this.customName = customName
    this.additionalInfo = additionalInfo
    this.useAutoName = useAutoName
  }
}

export class ExitDisplayBroadcastItem {
  exitNo: number = 0
  displayName: string = ''
  additionalInfo: string = ''
  sourceType: string = ''

  constructor(exitNo: number = 0, displayName: string = '', additionalInfo: string = '', sourceType: string = '') {
    this.exitNo = exitNo
    this.displayName = displayName
    this.additionalInfo = additionalInfo
    this.sourceType = sourceType
  }
}

export class ExitDisplayBroadcastSnapshot {
  enabled: boolean = false
  sleepEnabled: boolean = true
  screenOnTime: string = '08:00:00'
  screenOffTime: string = '20:00:00'
  items: ExitDisplayBroadcastItem[] = []
}

export class ExitScreenStorage {
  private static instance: ExitScreenStorage | null = null

  static getInstance(): ExitScreenStorage {
    if (ExitScreenStorage.instance === null) {
      ExitScreenStorage.instance = new ExitScreenStorage()
    }
    return ExitScreenStorage.instance
  }

  private constructor() {
  }

  private getDefaultExitCount(): number {
    const count = AppStorage.get('OutletCount_FSM1') as number | undefined
    if (count !== undefined && count > 0) {
      return Math.min(count, 20)
    }
    return Math.min(ConstPreDefine.MAX_EXIT_NUM, 20)
  }

  createDefaultConfigs(): ExitScreenConfigRecord[] {
    const count = this.getDefaultExitCount()
    const result: ExitScreenConfigRecord[] = []
    for (let i = 0; i < count; i++) {
      result.push(new ExitScreenConfigRecord(i + 1, '', '', true))
    }
    return result
  }

  private toJson(configs: ExitScreenConfigRecord[]): string {
    return JSON.stringify(configs)
  }

  parseConfigs(jsonText: string): ExitScreenConfigRecord[] {
    if (!jsonText || jsonText.length === 0) {
      return this.createDefaultConfigs()
    }
    try {
      const parsed = JSON.parse(jsonText) as ExitScreenConfigRecord[]
      const result: ExitScreenConfigRecord[] = []
      for (let i = 0; i < parsed.length; i++) {
        const item = parsed[i]
        const record = new ExitScreenConfigRecord(
          typeof item.exitNo === 'number' ? item.exitNo : i + 1,
          typeof item.customName === 'string' ? item.customName : '',
          typeof item.additionalInfo === 'string' ? item.additionalInfo : '',
          typeof item.useAutoName === 'boolean' ? item.useAutoName : true
        )
        result.push(record)
      }
      return result.length > 0 ? result : this.createDefaultConfigs()
    } catch (_) {
      return this.createDefaultConfigs()
    }
  }

  getDisplayEnabled(): boolean {
    return (AppStorage.get(EXIT_DISPLAY_ENABLED_KEY) as boolean | undefined) ?? false
  }

  setDisplayEnabled(enabled: boolean): void {
    AppStorage.setOrCreate(EXIT_DISPLAY_ENABLED_KEY, enabled)
  }

  getSleepEnabled(): boolean {
    return (AppStorage.get(EXIT_SCREEN_SLEEP_ENABLED_KEY) as boolean | undefined) ?? true
  }

  setSleepEnabled(enabled: boolean): void {
    AppStorage.setOrCreate(EXIT_SCREEN_SLEEP_ENABLED_KEY, enabled)
  }

  getScreenOnTime(): string {
    return (AppStorage.get(EXIT_SCREEN_ON_TIME_KEY) as string | undefined) ?? '08:00:00'
  }

  setScreenOnTime(timeText: string): void {
    AppStorage.setOrCreate(EXIT_SCREEN_ON_TIME_KEY, timeText)
  }

  getScreenOffTime(): string {
    return (AppStorage.get(EXIT_SCREEN_OFF_TIME_KEY) as string | undefined) ?? '20:00:00'
  }

  setScreenOffTime(timeText: string): void {
    AppStorage.setOrCreate(EXIT_SCREEN_OFF_TIME_KEY, timeText)
  }

  getConfigs(): ExitScreenConfigRecord[] {
    const jsonText = (AppStorage.get(EXIT_SCREEN_CONFIGS_JSON_KEY) as string | undefined) ?? '[]'
    return this.parseConfigs(jsonText)
  }

  setConfigs(configs: ExitScreenConfigRecord[]): void {
    AppStorage.setOrCreate(EXIT_SCREEN_CONFIGS_JSON_KEY, this.toJson(configs))
  }

  buildBroadcastSnapshot(): ExitDisplayBroadcastSnapshot {
    const snapshot = new ExitDisplayBroadcastSnapshot()
    snapshot.enabled = this.getDisplayEnabled()
    snapshot.sleepEnabled = this.getSleepEnabled()
    snapshot.screenOnTime = this.getScreenOnTime()
    snapshot.screenOffTime = this.getScreenOffTime()
    const configs = this.getConfigs()
    for (let i = 0; i < configs.length; i++) {
      const config = configs[i]
      const displayName = config.useAutoName ? `出口${config.exitNo}` : (config.customName.length > 0 ? config.customName : `出口${config.exitNo}`)
      const sourceType = config.useAutoName ? 'auto' : 'custom'
      snapshot.items.push(new ExitDisplayBroadcastItem(config.exitNo, displayName, config.additionalInfo, sourceType))
    }
    return snapshot
  }

  logBroadcastSnapshot(tag: string = '[EXIT_DISPLAY_BROADCAST_PREVIEW]'): void {
    const snapshot = this.buildBroadcastSnapshot()
    console.log(`${tag} enabled=${snapshot.enabled} sleep=${snapshot.sleepEnabled} on=${snapshot.screenOnTime} off=${snapshot.screenOffTime} count=${snapshot.items.length}`)
    for (let i = 0; i < snapshot.items.length; i++) {
      const item = snapshot.items[i]
      console.log(`${tag} exit=${item.exitNo} name=${item.displayName} extra=${item.additionalInfo} source=${item.sourceType}`)
    }
  }
}

export function getExitScreenStorage(): ExitScreenStorage {
  return ExitScreenStorage.getInstance()
}
