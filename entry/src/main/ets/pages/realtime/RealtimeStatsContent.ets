/**
 * 实时统计页面内容（按 48 项目实时页结构对齐）
 * 结构：顶部实时指标 + 中部等级网格/出口表 + 底部等级统计明细
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme as resolveTheme } from '../../utils/theme/ThemeUtils'
import { ConstPreDefine } from '../../protocol/ConstPreDefine'
import { GlobalDataInterface, getGlobalDataInterface, DataChangeListener } from '../../protocol/GlobalDataInterface'
import { GlobalRealtimeData, createDefaultGlobalRealtimeData, copyGlobalRealtimeData, StGradeInfo } from '../../protocol/Structures'
import { GradeStatisticsTable } from './GradeStatisticsTable'
import { TextDecoder } from '@ohos.util'

interface MetricItem {
  label: string
  value: string
}

@Component
export struct RealtimeStatsContent {
  @StorageLink('OMNI_THEME_VERSION_KEY') private themeVersion: number = 0
  @State private currentGlobalData: GlobalRealtimeData = createDefaultGlobalRealtimeData()
  @State private gradeInfo: StGradeInfo = new StGradeInfo()

  private dataInterface: GlobalDataInterface = getGlobalDataInterface()
  private dataChangeListener: DataChangeListener | null = null
  private gradeInfoListener: ((info: StGradeInfo) => void) | null = null
  private decoder: TextDecoder = new TextDecoder('utf-8', { ignoreBOM: true })

  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return resolveTheme()
  }

  private updateFromRealtimeData(data: GlobalRealtimeData): void {
    this.currentGlobalData = copyGlobalRealtimeData(data)
  }

  aboutToAppear() {
    const initial = this.dataInterface.getGlobalData()
    this.updateFromRealtimeData(initial)

    const info = this.dataInterface.getLatestGradeInfo()
    if (info) {
      this.gradeInfo = info
    }

    this.dataChangeListener = (data: GlobalRealtimeData) => {
      this.updateFromRealtimeData(data)
    }
    this.gradeInfoListener = (info: StGradeInfo) => {
      this.gradeInfo = info
    }
    this.dataInterface.addDataChangeListener(this.dataChangeListener)
    this.dataInterface.addGradeInfoListener(this.gradeInfoListener)
  }

  aboutToDisappear() {
    if (this.dataChangeListener) {
      this.dataInterface.removeDataChangeListener(this.dataChangeListener)
      this.dataChangeListener = null
    }
    if (this.gradeInfoListener) {
      this.dataInterface.removeGradeInfoListener(this.gradeInfoListener)
      this.gradeInfoListener = null
    }
  }

  private formatStartTime(ts: number): string {
    if (!ts || ts <= 0) {
      return '--:--:--'
    }
    const d = new Date(ts)
    const hh = d.getHours().toString().padStart(2, '0')
    const mm = d.getMinutes().toString().padStart(2, '0')
    const ss = d.getSeconds().toString().padStart(2, '0')
    return `${hh}:${mm}:${ss}`
  }

  private sum(arr: number[]): number {
    let s = 0
    for (let i = 0; i < arr.length; i++) {
      s += arr[i] || 0
    }
    return s
  }

  private buildMetrics(): MetricItem[] {
    const totalNum = this.currentGlobalData.totalYield
    const totalWeightKg = this.currentGlobalData.totalWeight / 1000.0
    const avgWeight = totalNum > 0 ? (this.currentGlobalData.totalWeight / totalNum) : 0
    const runningSec = this.currentGlobalData.runningTime > 0 ? this.currentGlobalData.runningTime : 1
    const realtimePerMin = (totalNum / runningSec) * 60

    return [
      { label: '本批个数', value: `${totalNum}` },
      { label: '本批重量', value: `${totalWeightKg.toFixed(2)} kg` },
      { label: '开始时间', value: this.formatStartTime(this.currentGlobalData.startTime) },
      { label: '分选效率', value: `${this.currentGlobalData.efficiency.toFixed(2)} %` },
      { label: '平均果重', value: `${avgWeight.toFixed(2)} g` },
      { label: '实时产量', value: `${realtimePerMin.toFixed(2)} 个/分` },
      { label: '间隔速度', value: '--' }
    ]
  }

  private decodeName(buffer: Uint8Array, index: number): string {
    const start = index * ConstPreDefine.MAX_TEXT_LENGTH
    const end = start + ConstPreDefine.MAX_TEXT_LENGTH
    if (start < 0 || end > buffer.length) {
      return ''
    }
    const slice = buffer.slice(start, end)
    let len = 0
    while (len < slice.length && slice[len] !== 0) {
      len++
    }
    if (len <= 0) {
      return ''
    }
    try {
      return this.decoder.decode(slice.slice(0, len))
    } catch (_e) {
      return ''
    }
  }

  private getQualityNames(): string[] {
    const names: string[] = []
    const qNum = this.gradeInfo.nQualityGradeNum > 0 ? this.gradeInfo.nQualityGradeNum : 1
    for (let q = 0; q < qNum; q++) {
      const n = this.decodeName(this.gradeInfo.strQualityGradeName, q)
      names.push(n.length > 0 ? n : `Q${q + 1}`)
    }
    return names
  }

  private getSizeNames(): string[] {
    const names: string[] = []
    const sNum = this.gradeInfo.nSizeGradeNum > 0 ? this.gradeInfo.nSizeGradeNum : 1
    for (let s = 0; s < sNum; s++) {
      const n = this.decodeName(this.gradeInfo.strSizeGradeName, s)
      names.push(n.length > 0 ? n : `S${s + 1}`)
    }
    return names
  }

  private getGradeMatrixRows(): string[][] {
    const rows: string[][] = []
    const qNames = this.getQualityNames()
    const sNames = this.getSizeNames()
    for (let q = 0; q < qNames.length; q++) {
      const row: string[] = [qNames[q]]
      for (let s = 0; s < sNames.length; s++) {
        row.push(`${qNames[q]}.${sNames[s]}`)
      }
      rows.push(row)
    }
    return rows
  }

  private getContainerRows(): string[][] {
    const rows: string[][] = []
    const max = Math.min(8, this.currentGlobalData.exitCount.length)
    for (let i = 0; i < max; i++) {
      const count = this.currentGlobalData.exitCount[i] || 0
      const weightKg = ((this.currentGlobalData.exitWeight[i] || 0) / 1000.0).toFixed(2)
      rows.push([`出口${i + 1}`, `${count}`, `${weightKg}`])
    }
    return rows
  }

  @Builder
  private headerCell(text: string, weight: number) {
    Text(text)
      .fontSize(14)
      .fontWeight(FontWeight.Bold)
      .fontColor(this.getCurrentTheme().textColor)
      .textAlign(TextAlign.Center)
      .layoutWeight(weight)
      .padding(6)
      .border({ width: { right: 1, bottom: 1 }, color: this.getCurrentTheme().borderColor })
      .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
  }

  @Builder
  private dataCell(text: string, weight: number, odd: boolean) {
    Text(text)
      .fontSize(13)
      .fontColor(this.getCurrentTheme().textColor)
      .textAlign(TextAlign.Center)
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .layoutWeight(weight)
      .padding(6)
      .border({ width: { right: 1, bottom: 1 }, color: this.getCurrentTheme().borderColor })
      .backgroundColor(odd ? (this.getCurrentTheme().surfaceColor) : (this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor))
  }

  @Builder
  private gradeGridPanel() {
    const sizeNames = this.getSizeNames()
    const rows = this.getGradeMatrixRows()
    Column() {
      Text('等级表')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getCurrentTheme().textColor)
        .margin({ bottom: 8 })

      Row() {
        this.headerCell('等级', 1)
        ForEach(sizeNames, (name: string) => {
          this.headerCell(name, 1)
        })
      }
      .width('100%')

      List() {
        ForEach(rows, (row: string[], idx: number) => {
          ListItem() {
            Row() {
              ForEach(row, (cell: string, cIdx: number) => {
                this.dataCell(cell, 1, idx % 2 === 1)
              })
            }
            .width('100%')
          }
        })
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('49%')
    .height('100%')
    .padding(10)
    .backgroundColor(this.getCurrentTheme().surfaceColor)
    .border({ width: 1, color: this.getCurrentTheme().borderColor })
    .borderRadius(8)
  }

  @Builder
  private containerPanel() {
    const rows = this.getContainerRows()
    Column() {
      Text('容器表')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getCurrentTheme().textColor)
        .margin({ bottom: 8 })

      Row() {
        this.headerCell('出口', 1)
        this.headerCell('个数', 1)
        this.headerCell('重量(kg)', 1)
      }
      .width('100%')

      List() {
        ForEach(rows, (row: string[], idx: number) => {
          ListItem() {
            Row() {
              this.dataCell(row[0], 1, idx % 2 === 1)
              this.dataCell(row[1], 1, idx % 2 === 1)
              this.dataCell(row[2], 1, idx % 2 === 1)
            }
            .width('100%')
          }
        })
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('49%')
    .height('100%')
    .padding(10)
    .backgroundColor(this.getCurrentTheme().surfaceColor)
    .border({ width: 1, color: this.getCurrentTheme().borderColor })
    .borderRadius(8)
  }

  build() {
    const metrics = this.buildMetrics()
    Column() {
      Text('实时统计')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getCurrentTheme().textColor)
        .margin({ top: 10, bottom: 10 })
        .alignSelf(ItemAlign.Center)

      Row() {
        ForEach(metrics, (item: MetricItem) => {
          Column() {
            Text(item.label)
              .fontSize(14)
              .fontColor(this.getCurrentTheme().subTextColor ?? '#888888')
              .margin({ bottom: 6 })
            Text(item.value)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getCurrentTheme().textColor)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width('14.2%')
          .padding({ left: 6, right: 6, top: 8, bottom: 8 })
          .alignItems(HorizontalAlign.Start)
        })
      }
      .width('100%')
      .padding(10)
      .backgroundColor(this.getCurrentTheme().surfaceColor)
      .border({ width: 1, color: this.getCurrentTheme().borderColor })
      .borderRadius(8)
      .margin({ bottom: 10 })

      Row() {
        this.gradeGridPanel()
        Blank().width('2%')
        this.containerPanel()
      }
      .width('100%')
      .height('32%')
      .margin({ bottom: 10 })

      Column() {
        Text('等级统计表')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getCurrentTheme().textColor)
          .margin({ bottom: 8 })
        GradeStatisticsTable({ globalData: $currentGlobalData })
          .layoutWeight(1)
          .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .padding(10)
      .backgroundColor(this.getCurrentTheme().surfaceColor)
      .border({ width: 1, color: this.getCurrentTheme().borderColor })
      .borderRadius(8)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 12, right: 12, top: 6, bottom: 10 })
    .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
  }
}
