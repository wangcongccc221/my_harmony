/**
 * 等级统计表组件
 * 功能：显示等级统计数据的表格
 */

import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { TableRowComponent } from '../ui/tables/TableRow'
import { HomeDataManager } from '../../pages/home/core/HomeDataManager'
import { TableRow } from '../layout/LevelTable'
import { TABLE_CONFIG } from '../../pages/home/HomeConstants'
import { HOME_SELECTED_FSM } from '../../constants/TopBarKeys'
import { GlobalDataInterface } from '../../protocol/GlobalDataInterface'
import { StGradeInfo, StStatistics } from '../../protocol/Structures'

@Component
export struct GradeStatisticsTable {
  @Prop selectedSubsystem: string = 'ALL'
  
  @StorageLink(HOME_SELECTED_FSM) @Watch('onFsmChange') selectedFSM: 'FSM1' | 'FSM2' = 'FSM1'
  @State private tableData: TableRow[] = []

  private dataManager = HomeDataManager.getInstance()
  private dataInterface = GlobalDataInterface.getInstance()
  private statisticsListener: ((stats: StStatistics) => void) | null = null
  private gradeInfoListener: ((info: StGradeInfo) => void) | null = null
  
  aboutToAppear() {
    this.refreshTable()
    this.statisticsListener = (_stats: StStatistics) => {
      this.refreshTable()
    }
    this.gradeInfoListener = (_info: StGradeInfo) => {
      this.refreshTable()
    }
    this.dataInterface.addStatisticsListener(this.statisticsListener)
    this.dataInterface.addGradeInfoListener(this.gradeInfoListener)
  }

  aboutToDisappear() {
    if (this.statisticsListener) {
      this.dataInterface.removeStatisticsListener(this.statisticsListener)
      this.statisticsListener = null
    }
    if (this.gradeInfoListener) {
      this.dataInterface.removeGradeInfoListener(this.gradeInfoListener)
      this.gradeInfoListener = null
    }
  }
  
  private onFsmChange() {
    this.refreshTable()
  }
  
  private getHeaders(): string[] {
    return TABLE_CONFIG.STATISTICS_TABLE.headers
  }

  private refreshTable() {
    this.dataManager.setFSM(this.selectedFSM)
    this.dataManager.initializeStatisticsTableData()
    this.tableData = this.dataManager.getTableData('等级统计表')
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
        ForEach(this.tableData, (row: TableRow, index: number) => {
          ListItem() {
            TableRowComponent({
              rowData: row,
              isHeader: false,
              rowIndex: index,
              fontSize: 14,
              cellPadding: 8
            })
          }
        }, (row: TableRow, index: number) => `${index}-${JSON.stringify(row)}`)
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
