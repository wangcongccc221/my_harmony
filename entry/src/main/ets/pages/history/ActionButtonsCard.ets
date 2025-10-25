/**
 * 历史加工操作按钮卡片组件
 * 功能：提供查询、导出、报告、删除、重置、批量导出、等级合并导出等操作按钮
 * 用途：在历史加工页面中作为操作按钮区域显示
 * 
 * 使用示例：
 * ```
 * ActionButtonsCard({
 *   onQueryClick: () => { this.handleQuery() },
 *   onMergeExportClick: () => { this.handleMergeExport() },
 *   onReportClick: () => { this.handleReport() },
 *   onDeleteClick: () => { this.handleDelete() },
 *   onResetClick: () => { this.handleReset() },
 *   onBatchExportClick: () => { this.handleBatchExport() },
 *   onLevelMergeExportClick: () => { this.handleLevelMergeExport() }
 * })
 * ```
 */

import { BaseComponentHelper } from '../../components/common/BaseComponent'
import { OmniThemeManager, ExtendedOmniThemeStyle, OmniThemeType } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { HistoryTableData } from './core/HistoryTableManager'
import fs from '@ohos.file.fs'
import common from '@ohos.app.ability.common'

@Component
export struct ActionButtonsCard {
  // ==================== 日期数据属性 ====================
  /** 开始日期字符串 */
  @Prop startDate: string = ''
  /** 结束日期字符串 */
  @Prop endDate: string = ''
  /** 选中的开始日期 */
  @Prop selectedStartDate: Date = new Date()
  /** 选中的结束日期 */
  @Prop selectedEndDate: Date = new Date()
  /** 客户索引 */
  @Prop customerIndex: number = 0
  /** 农场索引 */
  @Prop farmIndex: number = 0
  /** 水果索引 */
  @Prop fruitIndex: number = 0

  // ==================== 事件回调属性 ====================
  /** 开始日期变化回调函数 */
  onStartDateChange?: (date: string) => void
  /** 结束日期变化回调函数 */
  onEndDateChange?: (date: string) => void
  /** 客户变化回调函数 */
  onCustomerChange?: (index: number) => void
  /** 农场变化回调函数 */
  onFarmChange?: (index: number) => void
  /** 水果变化回调函数 */
  onFruitChange?: (index: number) => void
  /** 查询点击回调函数 */
  onQueryClick?: () => void
  /** 合并导出点击回调函数 */
  onMergeExportClick?: () => void
  /** 报告点击回调函数 */
  onReportClick?: () => void
  /** 删除点击回调函数 */
  onDeleteClick?: () => void
  /** 重置点击回调函数 */
  onResetClick?: () => void
  /** 批量导出点击回调函数 */
  onBatchExportClick?: () => void
  /** 等级合并导出点击回调函数 */
  onLevelMergeExportClick?: () => void
  /** 日期错误回调函数 */
  onDateError?: () => void
  /** 导出成功回调函数 */
  onExportSuccess?: (filePath: string, count: number) => void
  /** 获取表格数据的回调函数 */
  onGetTableData?: () => HistoryTableData[]
  /** 获取选中数据的回调函数 */
  onGetSelectedData?: () => HistoryTableData[]

  // ==================== 文件命名对话框回调 ====================
  /** 显示文件命名对话框回调 */
  onShowFileNameDialog?: (exportType: string) => void

  // ==================== 主题相关属性 ====================
  /** 当前主题样式 */
  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  /** 当前主题类型 */
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: OmniThemeType = OmniThemeManager.getInstance().getCurrentThemeType()
  /** 主题版本号 */
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0
  /** 基础组件助手 */
  private baseComponentHelper = new BaseComponentHelper()
  

  /**
   * 获取当前主题配置
   * 
   * 功能说明：
   * - 从基础组件助手获取当前主题样式
   * - 用于组件样式配置
   * - 支持主题切换时的样式更新
   * 
   * @returns 当前主题样式配置
   */
  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return this.baseComponentHelper.getCurrentTheme()
  }

  /**
   * 处理查询操作
   * 
   * 功能说明：
   * - 执行历史数据查询操作
   * - 调用查询回调函数
   * - 处理查询结果
   */
  private async handleQuery(): Promise<void> {
    console.log('执行查询操作')
    if (this.onQueryClick) {
      this.onQueryClick()
    }
  }

  /**
   * 处理合并导出操作
   * 
   * 功能说明：
   * - 执行历史数据合并导出操作
   * - 生成CSV文件并保存
   * - 显示导出成功对话框
   */
  private async handleMergeExport(): Promise<void> {
    console.log('执行合并导出操作')
    if (this.onShowFileNameDialog) {
      this.onShowFileNameDialog('merge')
    }
  }

  /**
   * 处理报告操作
   * 
   * 功能说明：
   * - 执行历史数据报告生成操作
   * - 调用报告回调函数
   * - 处理报告结果
   */
  private async handleReport(): Promise<void> {
    console.log('执行报告操作')
    if (this.onReportClick) {
      this.onReportClick()
    }
  }

  /**
   * 处理删除操作
   * 
   * 功能说明：
   * - 执行历史数据删除操作
   * - 调用删除回调函数
   * - 处理删除结果
   */
  private async handleDelete(): Promise<void> {
    console.log('执行删除操作')
    if (this.onDeleteClick) {
      this.onDeleteClick()
    }
  }

  /**
   * 处理重置操作
   * 
   * 功能说明：
   * - 执行历史数据重置操作
   * - 调用重置回调函数
   * - 处理重置结果
   */
  private async handleReset(): Promise<void> {
    console.log('执行重置操作')
    if (this.onResetClick) {
      this.onResetClick()
    }
  }

  /**
   * 处理批量导出操作
   * 
   * 功能说明：
   * - 执行历史数据批量导出操作
   * - 调用批量导出回调函数
   * - 处理批量导出结果
   */
  private async handleBatchExport(): Promise<void> {
    console.log('执行批量导出操作')
    if (this.onShowFileNameDialog) {
      this.onShowFileNameDialog('batch')
    }
  }


  /**
   * 处理等级合并导出操作
   * 
   * 功能说明：
   * - 执行历史数据等级合并导出操作
   * - 调用等级合并导出回调函数
   * - 处理等级合并导出结果
   */
  private async handleLevelMergeExport(): Promise<void> {
    console.log('执行等级合并导出操作')
    if (this.onLevelMergeExportClick) {
      this.onLevelMergeExportClick()
    }
  }

  /**
   * 生成历史加工CSV数据
   */
  private generateHistoryCSVData(): string {
    // CSV头部
    let csvContent = '加工时间,结束时间,加工品种,总重量(吨),客户名称,农场名称,水果类型,等级,出口编号\n';
    
    // 获取所有历史加工数据
    const allHistoryData = this.getAllHistoryData();
    
    // 添加所有数据行
    allHistoryData.forEach(row => {
      csvContent += row.join(',') + '\n';
    });
    
    return csvContent;
  }

  /**
   * 生成批量导出CSV数据
   */
  private generateBatchCSVData(selectedData: HistoryTableData[]): string {
    // CSV头部
    let csvContent = '加工时间,结束时间,加工品种,总重量(吨),客户名称,农场名称,水果类型,等级,出口编号\n';
    
    // 添加选中的数据行
    selectedData.forEach(item => {
      csvContent += [
        item.startTime || '',
        item.endTime || '',
        item.fruitName || '',
        item.weight?.toString() || '',
        item.customerName || '',
        item.farmName || '',
        item.fruitName || '',
        item.status || '',
        item.id?.toString() || ''
      ].join(',') + '\n';
    });
    
    return csvContent;
  }

  /**
   * 获取所有历史加工数据
   */
  private getAllHistoryData(): string[][] {
    // 优先从表格获取数据
    if (this.onGetTableData) {
      const tableData = this.onGetTableData();
      return tableData.map(item => [
        item.startTime || '',
        item.endTime || '',
        item.fruitName || '',
        item.weight?.toString() || '',
        item.customerName || '',
        item.farmName || '',
        item.fruitName || '',
        item.status || '',
        item.id?.toString() || ''
      ]);
    }
    
    // 如果没有表格数据，返回空数组
    return [];
  }

  /**
   * 保存到公共目录
   */
  private async saveToPublicDirectory(filePath: string, fileName: string, csvContent: string): Promise<void> {
    try {
      const targetPaths = [
        '/storage/media/100/local/files/Docs/Download/',
        '/storage/emulated/0/Download/',
        '/storage/emulated/0/Documents/',
        '/sdcard/Download/',
        '/sdcard/Documents/'
      ];
      
      let successCount = 0;
      let successPaths: string[] = [];
      
      // 读取原文件内容
      const file = fs.openSync(filePath, fs.OpenMode.READ_ONLY);
      const stat = fs.statSync(filePath);
      const buffer = new ArrayBuffer(stat.size);
      fs.readSync(file.fd, buffer);
      fs.closeSync(file);
      
      // 尝试保存到每个路径
      for (const targetPath of targetPaths) {
        try {
          const targetFile = fs.openSync(`${targetPath}${fileName}`, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
          fs.writeSync(targetFile.fd, buffer);
          fs.closeSync(targetFile);
          successCount++;
          successPaths.push(`${targetPath}${fileName}`);
          console.info(`成功保存到: ${targetPath}${fileName}`);
        } catch (error) {
          console.warn(`保存到 ${targetPath} 失败:`, error);
        }
      }
      
      if (successCount > 0) {
        console.log(`文件已保存到 ${successCount} 个位置:`, successPaths);
        // 触发导出成功回调
        if (this.onExportSuccess) {
          this.onExportSuccess(successPaths[0], this.getAllHistoryData().length);
        }
      } else {
        console.log('所有路径保存失败');
      }
    } catch (error) {
      console.error('保存到公共目录失败:', error);
    }
  }

  /**
   * 构建操作按钮卡片的UI结构
   * 
   * 功能说明：
   * - 构建包含查询、导出、报告、删除、重置、批量导出、等级合并导出等按钮的UI
   * - 支持主题样式配置
   * - 响应按钮点击事件
   * 
   * @returns 操作按钮卡片的UI结构
   */
  build() {
    Stack() {
      Column() {
        // ==================== 上面4个按钮 ====================
        Row() {
          // 查询按钮
          Button('查询')
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor(this.getCurrentTheme().primary)
            .borderRadius(6)
            .height(40)
            .layoutWeight(1)
            .margin({ right: 4 })
            .onClick(async () => {
              await this.handleQuery()
            })

          // 合并导出按钮
          Button('合并导出')
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor(this.getCurrentTheme().primary)
            .borderRadius(6)
            .height(40)
            .layoutWeight(1)
            .margin({ left: 2, right: 4 })
            .onClick(async () => {
              await this.handleMergeExport()
            })

          // 报告按钮
          Button('报告')
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor(this.getCurrentTheme().primary)
            .borderRadius(6)
            .height(40)
            .layoutWeight(1)
            .margin({ left: 2, right: 4 })
            .onClick(async () => {
              await this.handleReport()
            })

          // 删除按钮
          Button('删除')
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor(this.getCurrentTheme().primary)
            .borderRadius(6)
            .height(40)
            .layoutWeight(1)
            .margin({ left: 2 })
            .onClick(async () => {
              await this.handleDelete()
            })
        }
        .width('100%')
        .margin({ bottom: 8 })

        // ==================== 下面3个按钮 ====================
        Row() {
          // 重置按钮
          Button('重置')
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor(this.getCurrentTheme().primary)
            .borderRadius(6)
            .height(40)
            .layoutWeight(1)
            .margin({ right: 4 })
            .onClick(async () => {
              await this.handleReset()
            })

          // 批量导出按钮
          Button('批量导出')
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor(this.getCurrentTheme().primary)
            .borderRadius(6)
            .height(40)
            .layoutWeight(1)
            .margin({ left: 2, right: 4 })
            .onClick(async () => {
              await this.handleBatchExport()
            })

          // 等级合并导出按钮
          Button('等级合并导出')
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor(this.getCurrentTheme().primary)
            .borderRadius(6)
            .height(40)
            .layoutWeight(1)
            .margin({ left: 2 })
            .onClick(async () => {
              await this.handleLevelMergeExport()
            })
        }
        .width('100%')
      }
      .width('100%')
      .height('auto')
      .padding(0)
      .backgroundColor(Color.Transparent)
    }
  }
}