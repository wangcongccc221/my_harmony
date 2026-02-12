import { StGradeInfo, GlobalRealtimeData, ConstPreDefine } from '../../protocol/Structures'
import { GlobalDataInterface } from '../../protocol/GlobalDataInterface'
import { TextDecoder } from '@ohos.util'

@Component
export struct GradeStatisticsTable {
  @Link globalData: GlobalRealtimeData
  @State @Watch('onGradeInfoChange') gradeInfo: StGradeInfo = new StGradeInfo()
  private dataInterface: GlobalDataInterface = GlobalDataInterface.getInstance()
  private textDecoder: TextDecoder = new TextDecoder("utf-8", { ignoreBOM: true })
  
  onGradeInfoChange() {
    console.info('GradeStatisticsTable: gradeInfo updated via listener')
  }

  private gradeInfoListener: (info: StGradeInfo) => void = (info: StGradeInfo) => {
    // Force assignment to trigger update
    this.gradeInfo = info
  }

  aboutToAppear() {
    const info = this.dataInterface.getLatestGradeInfo()
    if (info) {
      this.gradeInfo = info
    }
    this.dataInterface.addGradeInfoListener(this.gradeInfoListener)
  }

  aboutToDisappear() {
    this.dataInterface.removeGradeInfoListener(this.gradeInfoListener)
  }

  build() {
    Column() {
      // Header
      Row() {
        this.HeaderCell("等级名称", 2)
        this.HeaderCell("分选范围", 2)
        this.HeaderCell("个数", 1)
        this.HeaderCell("比例%", 1)
        this.HeaderCell("重量", 1)
        this.HeaderCell("比例%", 1)
        this.HeaderCell("箱数", 1)
        this.HeaderCell("比例%", 1)
      }
      .width('100%')
      .height(40)
      .backgroundColor('#F0F0F0')
      .border({ width: { bottom: 1 }, color: '#E0E0E0' })

      // Content
      if (this.getRows().length > 0) {
        List() {
          ForEach(this.getRows(), (row: GradeRowData, index: number) => {
            ListItem() {
              Row() {
                this.DataCell(row.gradeName, 2)
                this.DataCell(row.range, 2)
                this.DataCell(row.count.toString(), 1)
                this.DataCell(row.countPercent, 1)
                this.DataCell(row.weight.toString(), 1)
                this.DataCell(row.weightPercent, 1)
                this.DataCell(row.boxCount.toString(), 1)
                this.DataCell(row.boxCountPercent, 1)
              }
              .width('100%')
              .height(40)
              .backgroundColor(index % 2 === 0 ? '#FFFFFF' : '#FAFAFA')
              .border({ width: { bottom: 1 }, color: '#EEEEEE' })
            }
          }, (row: GradeRowData, index: number) => `${row.gradeName}_${index}_${row.count}_${row.weight}`)
          
          // Total Row
          ListItem() {
            Row() {
              this.DataCell("合计", 4) // Spanning name + range
              this.DataCell(this.getTotalCount().toString(), 1)
              this.DataCell("100%", 1)
              this.DataCell(this.getTotalWeight().toString(), 1)
              this.DataCell("100%", 1)
              this.DataCell(this.getTotalBox().toString(), 1)
              this.DataCell("100%", 1)
            }
            .width('100%')
            .height(40)
            .backgroundColor('#E6F7FF')
          }
        }
        .width('100%')
        .layoutWeight(1)
      } else {
        Column() {
          Text("暂无分级配置信息")
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 50 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Top)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  HeaderCell(text: string, weight: number) {
    Text(text)
      .fontSize(14)
      .fontWeight(FontWeight.Bold)
      .textAlign(TextAlign.Center)
      .layoutWeight(weight)
      .padding(5)
  }

  @Builder
  DataCell(text: string, weight: number) {
    Text(text)
      .fontSize(14)
      .textAlign(TextAlign.Center)
      .layoutWeight(weight)
      .padding(5)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .maxLines(1)
  }

  private getTotalCount(): number {
    return this.globalData.gradeCount.reduce((a, b) => a + b, 0)
  }

  private getTotalWeight(): number {
    return this.globalData.gradeWeight.reduce((a, b) => a + b, 0)
  }

  private getTotalBox(): number {
    return this.globalData.boxGradeCount.reduce((a, b) => a + b, 0)
  }

  private getRows(): GradeRowData[] {
    const rows: GradeRowData[] = []
    const totalCount = this.getTotalCount() || 1
    const totalWeight = this.getTotalWeight() || 1
    const totalBox = this.getTotalBox() || 1

    const maxQuality = ConstPreDefine.MAX_QUALITY_GRADE_NUM
    const maxSize = ConstPreDefine.MAX_SIZE_GRADE_NUM
    
    // Use configured grade numbers, default to 0 if not set
    const qualityNum = this.gradeInfo.nQualityGradeNum
    const sizeNum = this.gradeInfo.nSizeGradeNum

    for (let q = 0; q < qualityNum; q++) {
       for (let s = 0; s < sizeNum; s++) {
         // Indexing must use the MAX stride
         const index = q * maxSize + s
         
         const count = this.globalData.gradeCount[index] || 0
         const weight = this.globalData.gradeWeight[index] || 0
         const box = this.globalData.boxGradeCount[index] || 0
         
         // Parse Name
         const name = this.getGradeName(q, s)
         // Optional: Filter empty rows if count is 0 and name is empty, 
         // but usually we want to show all configured grades.
         
         rows.push({
           gradeName: name || `Grade ${q+1}-${s+1}`,
           range: this.getGradeRange(index),
           count: count,
           countPercent: (count * 100 / totalCount).toFixed(2) + '%',
           weight: weight,
           weightPercent: (weight * 100 / totalWeight).toFixed(2) + '%',
           boxCount: box,
           boxCountPercent: (box * 100 / totalBox).toFixed(2) + '%'
         })
       }
    }
    return rows
  }

  private getGradeName(qualityIdx: number, sizeIdx: number): string {
    const sizeName = this.decodeName(this.gradeInfo.strSizeGradeName, sizeIdx)
    const qualityName = this.decodeName(this.gradeInfo.strQualityGradeName, qualityIdx)
    
    if (qualityName && sizeName) return `${qualityName} - ${sizeName}`
    if (sizeName) return sizeName
    if (qualityName) return qualityName
    return ""
  }

  private getGradeRange(index: number): string {
     if (index < this.gradeInfo.grades.length) {
       const grade = this.gradeInfo.grades[index]
       return `${grade.nMinSize.toFixed(1)} - ${grade.nMaxSize.toFixed(1)}`
     }
     return "" 
  }
  
  private decodeName(buffer: Uint8Array, index: number): string {
    const start = index * ConstPreDefine.MAX_TEXT_LENGTH
    const end = start + ConstPreDefine.MAX_TEXT_LENGTH
    const slice = buffer.slice(start, end)
    // Find null terminator
    let len = 0
    while(len < slice.length && slice[len] !== 0) len++
    if (len === 0) return ""
    try {
        // Assume GBK or UTF-8. Harmony often uses UTF-8. 
        // If legacy C++ sends GBK, we might need a GBK decoder or assume ASCII if simple.
        // For now use TextDecoder (UTF-8).
        const text = this.textDecoder.decode(slice.slice(0, len))
        return text
    } catch (e) {
        return ""
    }
  }
}

interface GradeRowData {
  gradeName: string
  range: string
  count: number
  countPercent: string
  weight: number
  weightPercent: string
  boxCount: number
  boxCountPercent: string
}
