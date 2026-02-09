import { StExitSetting } from '../../../protocol/Structures'
import { ConfigSender } from '../../../protocol/ConfigSender'
import { ConstPreDefine } from '../../../protocol/ConstPreDefine'

export type FsmKey = 'FSM1' | 'FSM2'

export interface OutletConfig {
  exitIndex: number
  enabled: boolean
  exportMode: string
  countChecked: boolean
  countValue: number
  weightChecked: boolean
  weightValue: number
  volumeChecked: boolean
  volumeValue: number
  label1Checked: boolean
  label2Checked: boolean
  label3Checked: boolean
  label4Checked: boolean
  motorEnableMode: string
  delayTime: number
  durationTime: number
  outletEnable: string
  spec: string
  netWeight: number
  dimensions: string
  customName: string
  productName: string
  displayNameChecked: boolean
  displayName: string
  isGeneral: boolean
  isMissingBox: boolean
}

export class ExitConfigManager {
  private static instance: ExitConfigManager | null = null
  private configsFSM1: OutletConfig[] = []
  private configsFSM2: OutletConfig[] = []

  static getInstance(): ExitConfigManager {
    if (!ExitConfigManager.instance) {
      ExitConfigManager.instance = new ExitConfigManager()
    }
    return ExitConfigManager.instance
  }

  private constructor() {
    this.loadFromStorage('FSM1')
    this.loadFromStorage('FSM2')
  }

  private normalizeConfig(source: OutletConfig | undefined, exitIndex: number): OutletConfig {
    const base = this.createDefaultConfig(exitIndex)
    if (!source) {
      return base
    }
    const next: OutletConfig = this.createDefaultConfig(exitIndex)
    next.enabled = source.enabled
    next.exportMode = source.exportMode
    next.countChecked = source.countChecked
    next.countValue = source.countValue
    next.weightChecked = source.weightChecked
    next.weightValue = source.weightValue
    next.volumeChecked = source.volumeChecked
    next.volumeValue = source.volumeValue
    next.label1Checked = source.label1Checked
    next.label2Checked = source.label2Checked
    next.label3Checked = source.label3Checked
    next.label4Checked = source.label4Checked
    next.motorEnableMode = source.motorEnableMode
    next.delayTime = source.delayTime
    next.durationTime = source.durationTime
    next.outletEnable = source.outletEnable
    next.spec = source.spec
    next.netWeight = source.netWeight
    next.dimensions = source.dimensions
    next.customName = source.customName
    next.productName = source.productName
    next.displayNameChecked = source.displayNameChecked
    next.displayName = source.displayName
    next.isGeneral = source.isGeneral
    next.isMissingBox = source.isMissingBox
    return next
  }

  createDefaultConfig(exitIndex: number): OutletConfig {
    const index = exitIndex < 1 ? 1 : exitIndex
    return {
      exitIndex: index,
      enabled: true,
      exportMode: '默认',
      countChecked: true,
      countValue: 50,
      weightChecked: false,
      weightValue: 0,
      volumeChecked: false,
      volumeValue: 0,
      label1Checked: false,
      label2Checked: false,
      label3Checked: false,
      label4Checked: false,
      motorEnableMode: '装箱量',
      delayTime: 0,
      durationTime: 0,
      outletEnable: '开启',
      spec: '',
      netWeight: 1,
      dimensions: '',
      customName: '',
      productName: '',
      displayNameChecked: false,
      displayName: '',
      isGeneral: true,
      isMissingBox: false
    }
  }

  private getStorageKey(fsm: FsmKey): string {
    return `HOME_EXIT_CONFIG_${fsm}`
  }

  private loadFromStorage(fsm: FsmKey): void {
    const key = this.getStorageKey(fsm)
    const raw = AppStorage.get(key) as string | undefined
    if (typeof raw === 'string' && raw.length > 0) {
      try {
        const parsed = JSON.parse(raw) as OutletConfig[]
        if (Array.isArray(parsed)) {
          const result: OutletConfig[] = []
          parsed.forEach((item: OutletConfig) => {
            const index = item.exitIndex < 1 ? 1 : item.exitIndex
            result.push(this.normalizeConfig(item, index))
          })
          if (fsm === 'FSM1') {
            this.configsFSM1 = result
          } else {
            this.configsFSM2 = result
          }
        }
      } catch (e) {
        if (fsm === 'FSM1') {
          this.configsFSM1 = []
        } else {
          this.configsFSM2 = []
        }
      }
    }
  }

  private saveToStorage(fsm: FsmKey): void {
    const key = this.getStorageKey(fsm)
    const list = fsm === 'FSM1' ? this.configsFSM1 : this.configsFSM2
    try {
      const json = JSON.stringify(list)
      AppStorage.setOrCreate(key, json)
    } catch (e) {
    }
  }

  getExitConfig(fsm: FsmKey, exitIndex: number): OutletConfig {
    const index = exitIndex < 1 ? 1 : exitIndex
    const array = fsm === 'FSM1' ? this.configsFSM1 : this.configsFSM2
    const found = array.find((item: OutletConfig) => item.exitIndex === index)
    if (found) {
      return this.normalizeConfig(found, index)
    }
    const cfg = this.createDefaultConfig(index)
    this.setExitConfig(fsm, cfg)
    return cfg
  }

  setExitConfig(fsm: FsmKey, config: OutletConfig): void {
    const index = config.exitIndex < 1 ? 1 : config.exitIndex
    const array = fsm === 'FSM1' ? this.configsFSM1.slice() : this.configsFSM2.slice()
    const pos = array.findIndex((item: OutletConfig) => item.exitIndex === index)
    const merged = this.normalizeConfig(config, index)
    if (pos >= 0) {
      array[pos] = merged
    } else {
      array.push(merged)
    }
    if (fsm === 'FSM1') {
      this.configsFSM1 = array
    } else {
      this.configsFSM2 = array
    }
    this.saveToStorage(fsm)
  }

  getAllExitConfigs(fsm: FsmKey): OutletConfig[] {
    return (fsm === 'FSM1' ? this.configsFSM1 : this.configsFSM2).slice()
  }

  private toExitSetting(config: OutletConfig): StExitSetting {
    const setting = new StExitSetting()
    setting.exitIndex = config.exitIndex - 1
    const enableFlag = config.outletEnable === '开启'
    setting.enabled = enableFlag && config.enabled
    setting.targetSizeGrade = 0
    setting.targetQualityGrade = 0
    setting.boxCapacity = config.countChecked ? Math.max(0, Math.floor(config.countValue)) : 0
    const name = config.displayNameChecked && config.displayName.trim().length > 0
      ? config.displayName.trim()
      : (config.customName.trim().length > 0
        ? config.customName.trim()
        : (config.productName.trim().length > 0 ? config.productName.trim() : `出口${config.exitIndex}`))
    setting.exitName = name
    return setting
  }

  async sendExitConfig(fsm: FsmKey): Promise<boolean> {
    const sender = ConfigSender.getInstance()
    const fsmId = fsm === 'FSM1' ? ConstPreDefine.getFsmId(0) : ConstPreDefine.getFsmId(1)
    const maxExit = ConstPreDefine.MAX_EXIT_NUM
    const list = fsm === 'FSM1' ? this.configsFSM1 : this.configsFSM2
    const settings: StExitSetting[] = []
    for (let i = 0; i < maxExit; i++) {
      const index = i + 1
      const found = list.find((item: OutletConfig) => item.exitIndex === index)
      const cfg = found ? found : this.createDefaultConfig(index)
      settings.push(this.toExitSetting(cfg))
    }
    return sender.sendExitConfig(fsmId, settings)
  }
}
