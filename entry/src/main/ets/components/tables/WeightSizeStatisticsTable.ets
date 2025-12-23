/**
 * 重量/尺寸统计表组件
 * 功能：显示重量/尺寸统计数据的表格
 */

import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { TableRowComponent } from '../ui/tables/TableRow'

// 表格数据项接口
interface WeightSizeTableItem {
  gradeName: string      // 等级名称
  weight: number         // 重量
  gradeCount: number    // 等级个数
  countPercent: number  // 个数百分比
  gradeWeight: number   // 等级重量(kg)
  weightPercent: number // 重量百分比
  boxCount: number      // 箱数
  boxCountPercent: number // 箱数百分比
}

@Component
export struct WeightSizeStatisticsTable {
  @Prop selectedSubsystem: string = 'ALL'
  
  @State private tableData: WeightSizeTableItem[] = []
  
  aboutToAppear() {
    this.updateData()
  }
  
  aboutToUpdate() {
    // 当子系统改变时更新数据
    this.updateData()
  }
  
  private updateData(): void {
    // 生成模拟数据
    const tempData: WeightSizeTableItem[] = []
    
    const grades = ['23', '27', '32', '40']
    const subsystems = this.selectedSubsystem === 'ALL' ? ['1', '2'] : [this.selectedSubsystem]
    
    // 先收集所有数据
    for (const subsystem of subsystems) {
      for (const grade of grades) {
        const gradeName = `Sys-${subsystem}-${grade}`
        
        // 生成随机数据
        const gradeCount = Math.floor(Math.random() * 10000) + 1000
        const gradeWeight = Math.floor(Math.random() * 5000) + 500
        const boxCount = Math.floor(Math.random() * 5000000) + 100000
        const weight = Math.random() * 200 + 200
        
        tempData.push({
          gradeName,
          weight: parseFloat(weight.toFixed(2)),
          gradeCount,
          countPercent: 0,  // 稍后计算
          gradeWeight: parseFloat(gradeWeight.toFixed(1)),
          weightPercent: 0,  // 稍后计算
          boxCount,
          boxCountPercent: 0  // 稍后计算
        })
      }
    }
    
    // 计算总和
    const totalCount = tempData.reduce((sum, item) => sum + item.gradeCount, 0)
    const totalWeight = tempData.reduce((sum, item) => sum + item.gradeWeight, 0)
    const totalBox = tempData.reduce((sum, item) => sum + item.boxCount, 0)
    
    // 计算百分比
    this.tableData = tempData.map((item: WeightSizeTableItem): WeightSizeTableItem => {
      return {
        gradeName: item.gradeName,
        weight: item.weight,
        gradeCount: item.gradeCount,
        countPercent: totalCount > 0 ? parseFloat(((item.gradeCount / totalCount) * 100).toFixed(2)) : 0,
        gradeWeight: item.gradeWeight,
        weightPercent: totalWeight > 0 ? parseFloat(((item.gradeWeight / totalWeight) * 100).toFixed(2)) : 0,
        boxCount: item.boxCount,
        boxCountPercent: totalBox > 0 ? parseFloat(((item.boxCount / totalBox) * 100).toFixed(2)) : 0
      }
    })
  }
  
  private formatRowData(item: WeightSizeTableItem): string[] {
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
  
  build() {
    Column() {
      // 表头
      TableRowComponent({
        rowData: [
          '等级名称',
          '重量',
          '等级个数',
          '个数百分比(%)',
          '等级重量(kg)',
          '重量百分比(%)',
          '箱数',
          '箱数百分比(%)'
        ],
        isHeader: true,
        rowIndex: 0,
        fontSize: 14,
        cellPadding: 8
      })
      
      // 数据行
      List() {
        ForEach(this.tableData, (item: WeightSizeTableItem, index: number) => {
          ListItem() {
            TableRowComponent({
              rowData: this.formatRowData(item),
              isHeader: false,
              rowIndex: index,
              fontSize: 14,
              cellPadding: 8
            })
          }
        })
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

