export const PACKING_SPEC_CONFIGS_JSON_KEY: string = 'PackingSpecConfigsJson'
export const PACKING_SPEC_PRIMARY_ID_KEY: string = 'PackingSpecPrimaryId'
export const PACKING_SPEC_SECONDARY_ID_KEY: string = 'PackingSpecSecondaryId'

PersistentStorage.PersistProp(PACKING_SPEC_CONFIGS_JSON_KEY, '[]')
PersistentStorage.PersistProp(PACKING_SPEC_PRIMARY_ID_KEY, 1)
PersistentStorage.PersistProp(PACKING_SPEC_SECONDARY_ID_KEY, 2)

export class CartonSpecRecord {
  id: number = 0
  name: string = ''
  length: string = ''
  width: string = ''
  height: string = ''
  netWeight: string = ''
  note: string = ''

  constructor(id: number = 0, name: string = '', length: string = '', width: string = '', height: string = '', netWeight: string = '', note: string = '') {
    this.id = id
    this.name = name
    this.length = length
    this.width = width
    this.height = height
    this.netWeight = netWeight
    this.note = note
  }
}

export class PackingSpecStorage {
  private static instance: PackingSpecStorage | null = null

  static getInstance(): PackingSpecStorage {
    if (PackingSpecStorage.instance === null) {
      PackingSpecStorage.instance = new PackingSpecStorage()
    }
    return PackingSpecStorage.instance
  }

  private constructor() {
  }

  createDefaultSpecs(): CartonSpecRecord[] {
    const specs: CartonSpecRecord[] = []
    specs.push(new CartonSpecRecord(1, '标准箱 A', '600', '400', '300', '10.0', '对应常规出口包装'))
    specs.push(new CartonSpecRecord(2, '标准箱 B', '550', '380', '290', '7.5', '适合中果规格'))
    specs.push(new CartonSpecRecord(3, '周转箱 C', '500', '350', '260', '5.0', '轻量化纸箱'))
    specs.push(new CartonSpecRecord(4, '礼盒 D', '420', '280', '160', '3.0', '礼盒/精品果'))
    return specs
  }

  private parseNetWeight(text: string): number {
    const num = Number(text)
    if (isNaN(num) || num < 0) {
      return 0
    }
    return num
  }

  getConfigs(): CartonSpecRecord[] {
    const jsonText = (AppStorage.get(PACKING_SPEC_CONFIGS_JSON_KEY) as string | undefined) ?? '[]'
    return this.parseConfigs(jsonText)
  }

  parseConfigs(jsonText: string): CartonSpecRecord[] {
    if (!jsonText || jsonText.length === 0) {
      return this.createDefaultSpecs()
    }
    try {
      const parsed = JSON.parse(jsonText) as CartonSpecRecord[]
      const result: CartonSpecRecord[] = []
      for (let i = 0; i < parsed.length; i++) {
        const item = parsed[i]
        result.push(new CartonSpecRecord(
          typeof item.id === 'number' ? item.id : i + 1,
          typeof item.name === 'string' ? item.name : '',
          typeof item.length === 'string' ? item.length : '',
          typeof item.width === 'string' ? item.width : '',
          typeof item.height === 'string' ? item.height : '',
          typeof item.netWeight === 'string' ? item.netWeight : '',
          typeof item.note === 'string' ? item.note : ''
        ))
      }
      return result.length > 0 ? result : this.createDefaultSpecs()
    } catch (_) {
      return this.createDefaultSpecs()
    }
  }

  setConfigs(configs: CartonSpecRecord[]): void {
    AppStorage.setOrCreate(PACKING_SPEC_CONFIGS_JSON_KEY, JSON.stringify(configs))
  }

  getPrimarySpecId(): number {
    return (AppStorage.get(PACKING_SPEC_PRIMARY_ID_KEY) as number | undefined) ?? 1
  }

  setPrimarySpecId(id: number): void {
    AppStorage.setOrCreate(PACKING_SPEC_PRIMARY_ID_KEY, id)
  }

  getSecondarySpecId(): number {
    return (AppStorage.get(PACKING_SPEC_SECONDARY_ID_KEY) as number | undefined) ?? 2
  }

  setSecondarySpecId(id: number): void {
    AppStorage.setOrCreate(PACKING_SPEC_SECONDARY_ID_KEY, id)
  }

  private findSpecWeight(id: number, specs: CartonSpecRecord[]): number {
    for (let i = 0; i < specs.length; i++) {
      if (specs[i].id === id) {
        return this.parseNetWeight(specs[i].netWeight)
      }
    }
    return 0
  }

  syncToLevelPackingWeights(): void {
    const specs = this.getConfigs()
    const weight1 = this.findSpecWeight(this.getPrimarySpecId(), specs)
    const weight2 = this.findSpecWeight(this.getSecondarySpecId(), specs)
    AppStorage.setOrCreate('LevelPackingWeight1', weight1)
    AppStorage.setOrCreate('LevelPackingWeight2', weight2)
    console.log(`[PACKING_SPEC_SYNC] spec1=${this.getPrimarySpecId()} weight1=${weight1} spec2=${this.getSecondarySpecId()} weight2=${weight2}`)
  }

  ensureDefaults(): void {
    const specs = this.getConfigs()
    if (specs.length === 0) {
      this.setConfigs(this.createDefaultSpecs())
    }
    this.syncToLevelPackingWeights()
  }
}

export function getPackingSpecStorage(): PackingSpecStorage {
  return PackingSpecStorage.getInstance()
}
