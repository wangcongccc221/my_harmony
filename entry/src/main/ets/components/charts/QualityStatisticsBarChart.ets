/**
 * 品质统计信息柱状图组件
 * 功能：
 * - 垂直柱状图（纵向）
 * - 显示两个系列：个数和重量
 * - 根据子系统选择显示不同的数据
 * - ALL: 显示FSM1和FSM2的数据（每个X轴标签两个条形）
 * - 1或2: 只显示对应FSM的数据（每个X轴标签一个条形）
 */

import { ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { getRealtimeStatsService, RealtimeStatsService, RealtimeStatsListener } from '../../protocol/RealtimeStatsService'

interface ChartPadding {
  top: number;
  right: number;
  bottom: number;
  left: number;
}

@Component
export struct QualityStatisticsBarChart {
  // 主题接入
  @Consume providedTheme: ExtendedOmniThemeStyle
  
  // 可配置参数
  @Prop title: string = '品质统计信息';
  @Prop chartHeight: number = 400;
  @Prop selectedSubsystem: string = 'ALL'; // 'ALL' | '1' | '2'
  
  // 出口数量
  @StorageLink('OutletCount_FSM1') private outletCountFSM1: number = 20
  @StorageLink('OutletCount_FSM2') private outletCountFSM2: number = 20
  
  // 用于同步 selectedSubsystem
  @State private currentSubsystem: string = 'ALL'
  @State private refreshKey: number = 0
  @State private dataUpdateKey: number = 0
  @State private showCanvas: boolean = true
  
  // 图表区域边距
  private chartPadding: ChartPadding = {
    top: 20,
    right: 20,
    bottom: 40,
    left: 20
  };
  
  // 每个条形的固定宽度
  private fixedBarWidth: number = 100
  
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  
  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.providedTheme)
  }
  
  // 画布尺寸
  @State private canvasWidth: number = 0;
  @State private canvasHeight: number = 0;
  
  // 数据：个数和重量
  @State categories: string[] = []; // X轴标签（品质等级）
  @State countData: number[] = []; // 个数数据
  @State weightData: number[] = []; // 重量数据（kg）
  private readonly statsService: RealtimeStatsService = getRealtimeStatsService()
  private statsListener: RealtimeStatsListener | null = null
  
  aboutToAppear() {
    this.currentSubsystem = this.selectedSubsystem
    this.showCanvas = true
    this.dataUpdateKey = 0
    this.statsListener = () => {
      this.updateData()
    }
    this.statsService.subscribe(this.statsListener)
    this.updateData()
  }

  aboutToDisappear() {
    if (this.statsListener) {
      this.statsService.unsubscribe(this.statsListener)
      this.statsListener = null
    }
  }
  
  aboutToUpdate() {
    if (this.selectedSubsystem !== this.currentSubsystem) {
      this.currentSubsystem = this.selectedSubsystem
      this.dataUpdateKey++
      this.refreshKey++
      
      this.showCanvas = false
      setTimeout(() => {
        this.showCanvas = true
        setTimeout(() => {
          this.updateData()
        }, 20)
      }, 10)
    }
  }
  
  /**
   * 更新数据
   */
  private updateData(): void {
    try {
      // 根据子系统选择确定X轴标签数量
      let maxOutlets: number
      const subsystem = this.selectedSubsystem
      if (subsystem === 'ALL') {
        maxOutlets = Math.max(this.outletCountFSM1, this.outletCountFSM2)
        maxOutlets = Math.min(20, maxOutlets)
      } else if (subsystem === '1') {
        maxOutlets = Math.min(20, this.outletCountFSM1)
      } else {
        maxOutlets = Math.min(20, this.outletCountFSM2)
      }
      
      // 生成X轴标签（品质等级：A级、B级、C级等）
      this.categories = []
      const gradeNames = ['A级', 'B级', 'C级', 'D级', 'E级', 'F级', 'G级', 'H级']
      for (let i = 0; i < Math.min(maxOutlets, gradeNames.length); i++) {
        this.categories.push(gradeNames[i])
      }
      
      const snapshot = this.statsService.getSnapshot(this.selectedSubsystem)
      this.countData = new Array(this.categories.length).fill(0)
      this.weightData = new Array(this.categories.length).fill(0)
      for (let i = 0; i < this.categories.length; i++) {
        this.countData[i] = Number(snapshot.gradeCount[i] ?? 0)
        this.weightData[i] = Number(snapshot.gradeWeight[i] ?? 0)
      }
      
      // 计算画布宽度
      this.canvasWidth = this.categories.length * this.fixedBarWidth + this.chartPadding.left + this.chartPadding.right
      
      // 重绘
      if (this.canvasHeight > 0) {
        this.draw()
      }
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error(`[QualityStatisticsBarChart] 更新数据失败: ${errorMsg}`)
    }
  }
  
  /**
   * 绘制图表（垂直柱状图）
   */
  private draw(): void {
    if (!this.context || this.canvasWidth === 0 || this.canvasHeight === 0) {
      return
    }
    
    const theme = this.getCurrentTheme()
    const ctx = this.context
    
    // 清空画布
    ctx.clearRect(0, 0, this.canvasWidth, this.canvasHeight)
    
    // 计算图表区域
    const chartWidth = this.canvasWidth - this.chartPadding.left - this.chartPadding.right
    const chartHeight = this.canvasHeight - this.chartPadding.top - this.chartPadding.bottom
    
    if (chartWidth <= 0 || chartHeight <= 0 || this.categories.length === 0) {
      return
    }
    
    // 找到最大值（用于计算比例）
    const subsystem = this.selectedSubsystem
    let maxCount = 0
    let maxWeight = 0
    
    for (let i = 0; i < this.categories.length; i++) {
      maxCount = Math.max(maxCount, this.countData[i] || 0)
      maxWeight = Math.max(maxWeight, this.weightData[i] || 0)
    }
    
    // 归一化：将个数和重量统一到同一个比例尺
    // 使用较大的最大值作为统一比例尺
    let maxValue = Math.max(maxCount, maxWeight)
    
    if (maxValue === 0) {
      maxValue = 1
    }
    
    // 计算每个条形的位置
    const actualBarWidth = this.fixedBarWidth * 0.8
    const barGap = this.fixedBarWidth * 0.1
    const barWidth = this.fixedBarWidth
    const baseY = this.canvasHeight - this.chartPadding.bottom
    
    ctx.font = '20px sans-serif'  // 增大条形数字字体
    ctx.textBaseline = 'bottom'
    ctx.textAlign = 'center'
    
    for (let i = 0; i < this.categories.length; i++) {
      const centerX = this.chartPadding.left + i * barWidth + barWidth / 2
      const x = this.chartPadding.left + i * barWidth + barGap
      
      // 个数条形（蓝色，左侧）
      const countValue = this.countData[i] || 0
      const countBarHeight = (countValue / maxValue) * chartHeight
      ctx.fillStyle = '#4A90E2' // 蓝色（个数）
      ctx.fillRect(
        x,
        baseY - countBarHeight,
        actualBarWidth / 2 - barGap / 2,
        countBarHeight
      )
      
      if (countValue > 0) {
        ctx.fillStyle = theme.textColor
        ctx.fillText(countValue.toString(), x + (actualBarWidth / 2 - barGap / 2) / 2, baseY - countBarHeight - 5)
      }
      
      // 重量条形（橙色，右侧）
      const weightValue = this.weightData[i] || 0
      const weightBarHeight = (weightValue / maxValue) * chartHeight
      ctx.fillStyle = '#FE8A02' // 橙色（重量）
      ctx.fillRect(
        x + actualBarWidth / 2 + barGap / 2,
        baseY - weightBarHeight,
        actualBarWidth / 2 - barGap / 2,
        weightBarHeight
      )
      
      if (weightValue > 0) {
        ctx.fillStyle = theme.textColor
        ctx.fillText(weightValue.toString(), x + actualBarWidth / 2 + barGap / 2 + (actualBarWidth / 2 - barGap / 2) / 2, baseY - weightBarHeight - 5)
      }
    }
    
    // 绘制X轴（底部横线）
    ctx.beginPath()
    ctx.moveTo(this.chartPadding.left, this.canvasHeight - this.chartPadding.bottom)
    ctx.lineTo(this.canvasWidth - this.chartPadding.right, this.canvasHeight - this.chartPadding.bottom)
    ctx.stroke()
    
    // 绘制X轴标签（品质等级，在底部水平排列）
    ctx.font = '20px sans-serif'  // 增大X轴标签字体
    ctx.textAlign = 'center'
    ctx.textBaseline = 'top'
    ctx.fillStyle = theme.textColor
    
    for (let i = 0; i < this.categories.length; i++) {
      const centerX = this.chartPadding.left + i * this.fixedBarWidth + this.fixedBarWidth / 2
      ctx.fillText(this.categories[i], centerX, this.canvasHeight - this.chartPadding.bottom + 5)
    }
    
    // 绘制图例（放大：提升可读性）
    const legendX = this.chartPadding.left + 12
    const legendY = this.chartPadding.top + 12
    const legendBox = 24
    const legendGap = 36
    
    // 个数图例
    ctx.fillStyle = '#4A90E2'
    ctx.fillRect(legendX, legendY, legendBox, legendBox)
    ctx.fillStyle = theme.textColor
    ctx.font = '24px sans-serif'
    ctx.textAlign = 'left'
    ctx.textBaseline = 'middle'
    ctx.fillText('个数', legendX + legendBox + 10, legendY + legendBox / 2)
    
    // 重量图例
    ctx.fillStyle = '#FE8A02'
    ctx.fillRect(legendX, legendY + legendGap, legendBox, legendBox)
    ctx.fillStyle = theme.textColor
    ctx.fillText('重量', legendX + legendBox + 10, legendY + legendGap + legendBox / 2)
  }
  
  build() {
    Column() {
      Scroll() {
        if (this.showCanvas) {
          Canvas(this.context)
            .width(this.canvasWidth)
            .height(this.canvasHeight)
            .key(`quality-chart-${this.selectedSubsystem}-${this.dataUpdateKey}-${this.refreshKey}`)
            .onReady(() => {
              this.canvasHeight = this.chartHeight
              this.currentSubsystem = this.selectedSubsystem
              this.updateData()
            })
            .onAreaChange((oldValue: Area, newValue: Area) => {
              if (this.selectedSubsystem !== this.currentSubsystem) {
                this.currentSubsystem = this.selectedSubsystem
                this.dataUpdateKey++
                this.updateData()
              }
            })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Auto)
      .width('100%')
      .height(this.chartHeight)
    }
    .width('100%')
    .onAppear(() => {
      if (this.selectedSubsystem !== this.currentSubsystem) {
        this.currentSubsystem = this.selectedSubsystem
        this.dataUpdateKey++
        this.updateData()
      }
    })
  }
}

