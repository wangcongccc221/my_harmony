import { ConstPreDefine } from '../../../protocol/ConstPreDefine'
import { StGradeInfo } from '../../../protocol/Structures'
import { HomeDataManager } from './HomeDataManager'
import { ExitConfigManager, FsmKey, OutletConfig } from './ExitConfigManager'
import { util } from '@kit.ArkTS'

export class GradeLabelRow {
  gradeIndex: number = 0
  gradeName: string = ''
  labelIndex: number = 0
}

export class GradeInfoConfigManager {
  private static instance: GradeInfoConfigManager | null = null

  static getInstance(): GradeInfoConfigManager {
    if (!GradeInfoConfigManager.instance) {
      GradeInfoConfigManager.instance = new GradeInfoConfigManager()
    }
    return GradeInfoConfigManager.instance
  }

  private constructor() {}

  private getStorageKey(fsm: FsmKey): string {
    return `FULL_GRADE_INFO_CONFIG_${fsm}`
  }

  private getLabelerNameKey(index: number): string {
    return `LABELER_NAME_${index}`
  }

  private writeNameBytes(dst: Uint8Array, index: number, name: string): void {
    const base = index * ConstPreDefine.MAX_TEXT_LENGTH
    for (let i = 0; i < ConstPreDefine.MAX_TEXT_LENGTH; i++) {
      dst[base + i] = 0
    }
    const encoder = new util.TextEncoder()
    const bytes: Uint8Array = encoder.encodeInto(name)
    const maxCopy = Math.min(bytes.length, ConstPreDefine.MAX_TEXT_LENGTH - 1)
    for (let i = 0; i < maxCopy; i++) {
      dst[base + i] = bytes[i]
    }
  }

  private buildBaseGradeInfo(fsm: FsmKey): StGradeInfo {
    const info = new StGradeInfo()
    const dm = HomeDataManager.getInstance()
    dm.setFSM(fsm)
    const header = dm.getLevelTableHeaderTitles()
    const sizeNames = header.slice(1)
    const rows = dm.getTableData('等级表')
    const qualityNames = rows.map(r => (r[0] ?? '').toString()).filter(v => v.length > 0)

    info.nSizeGradeNum = Math.min(255, sizeNames.length)
    info.nQualityGradeNum = Math.min(255, qualityNames.length)
    info.nClassifyType = (info.nSizeGradeNum > 0 && info.nQualityGradeNum > 0) ? 1 : 0

    for (let i = 0; i < sizeNames.length && i < ConstPreDefine.MAX_SIZE_GRADE_NUM; i++) {
      this.writeNameBytes(info.strSizeGradeName, i, sizeNames[i])
    }
    for (let i = 0; i < qualityNames.length && i < ConstPreDefine.MAX_QUALITY_GRADE_NUM; i++) {
      this.writeNameBytes(info.strQualityGradeName, i, qualityNames[i])
    }

    return info
  }

  getOrCreateGradeInfo(fsm: FsmKey): StGradeInfo {
    const key = this.getStorageKey(fsm)
    const existing = AppStorage.get(key) as StGradeInfo | undefined
    if (existing instanceof StGradeInfo) {
      return existing
    }
    const built = this.buildBaseGradeInfo(fsm)
    AppStorage.setOrCreate(key, built)
    return built
  }

  private decodeNameBytes(buffer: Uint8Array, index: number): string {
    const base = index * ConstPreDefine.MAX_TEXT_LENGTH
    const end = base + ConstPreDefine.MAX_TEXT_LENGTH
    let len = 0
    for (let i = base; i < end; i++) {
      if (buffer[i] === 0) {
        break
      }
      len++
    }
    if (len <= 0) {
      return ''
    }
    const slice = buffer.slice(base, base + len)
    const decoder = new util.TextDecoder('utf-8', { ignoreBOM: true })
    try {
      return decoder.decodeWithStream(slice)
    } catch (_) {
      return ''
    }
  }

  setLabelerNames(names: string[]): void {
    for (let i = 0; i < 4; i++) {
      const name = (names[i] ?? '').toString()
      AppStorage.setOrCreate(this.getLabelerNameKey(i + 1), name)
    }
  }

  getLabelerName(labelIndex: number): string {
    if (!Number.isFinite(labelIndex) || labelIndex <= 0) {
      return ''
    }
    const key = this.getLabelerNameKey(Math.floor(labelIndex))
    const name = AppStorage.get(key) as string | undefined
    if (name && name.trim().length > 0) {
      return name
    }
    return `贴标机${Math.floor(labelIndex)}`
  }

  applyLabelSettings(fsm: FsmKey, labelType: number): StGradeInfo {
    const info = this.rebuildBaseFromHomeGradeTable(fsm)
    info.nLabelType = Math.max(0, Math.min(2, Math.floor(labelType)))
    AppStorage.setOrCreate(this.getStorageKey(fsm), info)
    return info
  }

  getGradeLabelRows(fsm: FsmKey): GradeLabelRow[] {
    const info = this.rebuildBaseFromHomeGradeTable(fsm)
    const qualityNum = info.nQualityGradeNum > 0 ? info.nQualityGradeNum : 1
    const sizeNum = info.nSizeGradeNum > 0 ? info.nSizeGradeNum : 1
    const rows: GradeLabelRow[] = []
    for (let q = 0; q < qualityNum; q++) {
      for (let s = 0; s < sizeNum; s++) {
        const gradeIdx = q * ConstPreDefine.MAX_SIZE_GRADE_NUM + s
        if (gradeIdx < 0 || gradeIdx >= info.grades.length) {
          continue
        }
        const sizeName = this.decodeNameBytes(info.strSizeGradeName, s)
        const qualityName = this.decodeNameBytes(info.strQualityGradeName, q)
        const row = new GradeLabelRow()
        row.gradeIndex = gradeIdx
        row.gradeName = (sizeName && qualityName) ? `${sizeName}.${qualityName}` : (sizeName || qualityName || `等级${gradeIdx + 1}`)
        row.labelIndex = info.grades[gradeIdx].sbLabelbyGrade > 0 ? info.grades[gradeIdx].sbLabelbyGrade : 0
        rows.push(row)
      }
    }
    return rows
  }

  applyGradeLabelRows(fsm: FsmKey, rows: GradeLabelRow[]): StGradeInfo {
    const info = this.rebuildBaseFromHomeGradeTable(fsm)
    for (let i = 0; i < info.grades.length; i++) {
      info.grades[i].sbLabelbyGrade = 0
    }
    for (let i = 0; i < rows.length; i++) {
      const gradeIdx = rows[i].gradeIndex
      if (gradeIdx < 0 || gradeIdx >= info.grades.length) {
        continue
      }
      const labelIndex = Math.max(0, Math.min(4, Math.floor(rows[i].labelIndex)))
      info.grades[gradeIdx].sbLabelbyGrade = labelIndex
    }
    AppStorage.setOrCreate(this.getStorageKey(fsm), info)
    return info
  }

  applyOutletLeftFields(fsm: FsmKey, exitIndex: number, config: OutletConfig): StGradeInfo {
    const info = this.getOrCreateGradeInfo(fsm)
    const exit0 = Math.max(0, Math.min(ConstPreDefine.MAX_EXIT_NUM - 1, exitIndex - 1))

    let switchLabel = 0x7f
    let switchNum = 0x7f7f7f7f
    if (config.countChecked) {
      switchLabel = 0
      switchNum = Math.max(0, Math.floor(config.countValue))
    } else if (config.weightChecked) {
      switchLabel = 1
      switchNum = Math.max(0, Math.floor(config.weightValue))
    } else if (config.volumeChecked) {
      switchLabel = 2
      switchNum = Math.max(0, Math.floor(config.volumeValue))
    }
    info.nSwitchLabel[exit0] = switchLabel
    info.nExitSwitchNum[exit0] = switchNum

    let label = 0
    if (config.label1Checked) label = 1
    else if (config.label2Checked) label = 2
    else if (config.label3Checked) label = 3
    else if (config.label4Checked) label = 4
    if (label > 0) {
      info.nLabelType = 2
      info.nLabelbyExit[exit0] = label
    } else {
      info.nLabelbyExit[exit0] = 0
    }

    AppStorage.setOrCreate(this.getStorageKey(fsm), info)
    return info
  }

  rebuildBaseFromHomeGradeTable(fsm: FsmKey): StGradeInfo {
    const existing = this.getOrCreateGradeInfo(fsm)
    const rebuilt = this.buildBaseGradeInfo(fsm)
    rebuilt.grades = existing.grades
    rebuilt.nExitSwitchNum = existing.nExitSwitchNum
    rebuilt.nSwitchLabel = existing.nSwitchLabel
    rebuilt.nLabelbyExit = existing.nLabelbyExit
    rebuilt.nLabelType = existing.nLabelType
    AppStorage.setOrCreate(this.getStorageKey(fsm), rebuilt)
    return rebuilt
  }

  applyAllOutletLeftFields(fsm: FsmKey): StGradeInfo {
    const info = this.getOrCreateGradeInfo(fsm)
    const exits = ExitConfigManager.getInstance().getAllExitConfigs(fsm)
    exits.forEach(cfg => {
      this.applyOutletLeftFields(fsm, cfg.exitIndex, cfg)
    })
    return info
  }

  applyExitMappingFromGradeNames(fsm: FsmKey, exitIndex: number, gradeNames: string[]): StGradeInfo {
    const info = this.rebuildBaseFromHomeGradeTable(fsm)
    const dm = HomeDataManager.getInstance()
    dm.setFSM(fsm)
    const sizeNames = dm.getLevelTableHeaderTitles().slice(1).map(s => (s ?? '').toString().trim())
    const qualityNames = dm.getTableData('等级表').map(r => (r[0] ?? '').toString().trim()).filter(v => v.length > 0)

    const sizeIndexMap = new Map<string, number>()
    sizeNames.forEach((name: string, idx: number) => sizeIndexMap.set(name, idx))
    const qualityIndexMap = new Map<string, number>()
    qualityNames.forEach((name: string, idx: number) => qualityIndexMap.set(name, idx))

    const exit0 = Math.max(0, Math.min(ConstPreDefine.MAX_EXIT_NUM - 1, exitIndex - 1))
    const bit = exit0 < 32 ? ((1 << exit0) >>> 0) : 0

    const list: string[] = Array.isArray(gradeNames) ? gradeNames : []
    for (let i = 0; i < list.length; i++) {
      const raw = (list[i] ?? '').toString().trim()
      if (!raw) { continue }
      const dot = raw.indexOf('.')
      if (dot <= 0 || dot >= raw.length - 1) { continue }
      const sizeName = raw.slice(0, dot).trim()
      const qualityName = raw.slice(dot + 1).trim()
      const sizeIdx = sizeIndexMap.get(sizeName)
      const qualityIdx = qualityIndexMap.get(qualityName)
      if (sizeIdx === undefined || qualityIdx === undefined) { continue }

      const gradeIdx = qualityIdx * ConstPreDefine.MAX_SIZE_GRADE_NUM + sizeIdx
      if (gradeIdx < 0 || gradeIdx >= info.grades.length) { continue }
      if (bit !== 0) {
        info.grades[gradeIdx].exit = (info.grades[gradeIdx].exit | bit) >>> 0
      }
    }

    AppStorage.setOrCreate(this.getStorageKey(fsm), info)
    return info
  }
}
