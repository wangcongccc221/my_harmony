/**
 * 等级统计表组件
 * 功能：显示等级统计数据的表格
 */

import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { TableRowComponent } from '../ui/tables/TableRow'
import { GradeItem } from '../../protocol/Structures'

@Component
export struct GradeStatisticsTable {
  @Prop selectedSubsystem: string = 'ALL'
  
  @StorageProp('GlobalGradeList') tableData: GradeItem[] = []
  @State private enablePrice: boolean = true  // 是否启用价格功能
  
  aboutToAppear() {
    
  }
  
  aboutToUpdate() {
    
  }
  
  private getHeaders(): string[] {
    if (this.enablePrice) {
      return [
        '等级名称',
        '单价',
        '重量',
        '等级个数',
        '个数百分比(%)',
        '等级重量(kg)',
        '重量百分比(%)',
        '箱数',
        '箱数百分比(%)'
      ]
    } else {
      return [
        '等级名称',
        '重量',
        '等级个数',
        '个数百分比(%)',
        '等级重量(kg)',
        '重量百分比(%)',
        '箱数',
        '箱数百分比(%)'
      ]
    }
  }
  
  private formatRowData(item: GradeItem): string[] {
    if (this.enablePrice) {
      return [
        item.gradeName,
        item.unitPrice.toFixed(2),
        item.weight.toString(),
        item.gradeCount.toString(),
        `${item.countPercent.toFixed(2)}%`,
        item.gradeWeight.toString(),
        `${item.weightPercent.toFixed(2)}%`,
        item.boxCount.toString(),
        `${item.boxCountPercent.toFixed(2)}%`
      ]
    } else {
      return [
        item.gradeName,
        item.weight.toString(),
        item.gradeCount.toString(),
        `${item.countPercent.toFixed(2)}%`,
        item.gradeWeight.toString(),
        `${item.weightPercent.toFixed(2)}%`,
        item.boxCount.toString(),
        `${item.boxCountPercent.toFixed(2)}%`
      ]
    }
  }
  
  build() {
    Column() {
      // 表头
      TableRowComponent({
        rowData: this.getHeaders(),
        isHeader: true,
        rowIndex: 0,
        fontSize: 14,
        cellPadding: 8
      })
      
      // 数据行
      List() {
        ForEach(this.tableData, (item: GradeItem, index: number) => {
          ListItem() {
            TableRowComponent({
              rowData: this.formatRowData(item),
              isHeader: false,
              rowIndex: index,
              fontSize: 14,
              cellPadding: 8
            })
          }
        }, (item: GradeItem) => JSON.stringify(item))
      }
      .width('100%')
      .layoutWeight(1)
      .divider({ 
        strokeWidth: 1, 
        color: getCurrentTheme().borderColor,
        startMargin: 0,
        endMargin: 0
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(getCurrentTheme().surfaceColor)
    .border({ width: 1, color: getCurrentTheme().borderColor })
    .borderRadius(8)
    .padding(8)
  }
}

