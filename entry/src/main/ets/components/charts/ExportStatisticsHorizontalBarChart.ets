/**
 * 出口统计信息水平条形图组件
 * 功能：
 * - 水平条形图（横向）
 * - 根据子系统选择显示不同的数据
 * - ALL: 显示FSM1和FSM2的数据（每个X轴标签两个条形）
 * - 1或2: 只显示对应FSM的数据（每个X轴标签一个条形）
 */

import { ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'

interface ChartPadding {
  top: number;
  right: number;
  bottom: number;
  left: number;
}

@Component
export struct ExportStatisticsHorizontalBarChart {
  // 主题接入
  @Consume providedTheme: ExtendedOmniThemeStyle
  
  // 可配置参数
  @Prop title: string = '出口统计信息';
  @Prop chartHeight: number = 400;
  @Prop selectedSubsystem: string = 'ALL'; // 'ALL' | '1' | '2'
  
  // 出口数量
  @StorageLink('OutletCount_FSM1') private outletCountFSM1: number = 20
  @StorageLink('OutletCount_FSM2') private outletCountFSM2: number = 20
  
  // 用于同步 selectedSubsystem，以便使用 @Watch
  @State private currentSubsystem: string = 'ALL'
  @State private refreshKey: number = 0  // 用于强制Canvas重新渲染
  @State private dataUpdateKey: number = 0  // 用于触发数据更新
  @State private showCanvas: boolean = true  // 用于强制Canvas重新创建
  
  // 图表区域边距
  private chartPadding: ChartPadding = {
    top: 20,
    right: 20,
    bottom: 40,  // 底部留更多空间给X轴标签
    left: 20     // 左侧不需要Y轴，减少padding
  };
  
  // 每个条形的高度
  private barHeight: number = 30
  private barSpacing: number = 10  // 条形之间的间距
  // 每个条形的固定宽度（确保切换子系统时条形大小一致）
  private fixedBarWidth: number = 100
  
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  
  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.providedTheme)
  }
  
  // 画布尺寸
  @State private canvasWidth: number = 0;
  @State private canvasHeight: number = 0;
  
  // 数据
  @State categories: string[] = []; // X轴标签（出口编号）
  @State fsm1Data: number[] = []; // FSM1的数据（个数）
  @State fsm2Data: number[] = []; // FSM2的数据（个数）
  
  aboutToAppear() {
    console.log(`[ExportStatisticsHorizontalBarChart] aboutToAppear, selectedSubsystem=${this.selectedSubsystem}`)
    this.currentSubsystem = this.selectedSubsystem
    this.showCanvas = true  // 确保Canvas显示
    this.dataUpdateKey = 0  // 重置更新key
    this.updateData()
  }
  
  aboutToUpdate() {
    // 每次组件更新时检查 selectedSubsystem 是否变化
    if (this.selectedSubsystem !== this.currentSubsystem) {
      console.log(`[ExportStatisticsHorizontalBarChart] aboutToUpdate检测到变化: ${this.currentSubsystem} -> ${this.selectedSubsystem}`)
      this.currentSubsystem = this.selectedSubsystem
      this.dataUpdateKey++  // 触发数据更新和Canvas重新创建（key变化会强制Canvas重新创建）
      this.refreshKey++  // 增加refreshKey，强制Canvas重新创建
      
      // 强制Canvas重新创建：先隐藏，再显示
      this.showCanvas = false
      // 使用setTimeout确保Canvas完全销毁后再重新创建
      setTimeout(() => {
        this.showCanvas = true
        // 延迟更新数据，确保Canvas已创建
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
      // 同步 selectedSubsystem 到 currentSubsystem
      if (this.selectedSubsystem !== this.currentSubsystem) {
        this.currentSubsystem = this.selectedSubsystem
      }
      
      // 根据子系统选择确定X轴标签数量（直接使用selectedSubsystem确保使用最新值）
      let maxOutlets: number
      const subsystem = this.selectedSubsystem  // 使用最新的selectedSubsystem
      if (subsystem === 'ALL') {
        // ALL模式：使用最大的出口数量（最多20个）
        maxOutlets = Math.max(this.outletCountFSM1, this.outletCountFSM2)
        maxOutlets = Math.min(20, maxOutlets)
      } else if (subsystem === '1') {
        // FSM1模式
        maxOutlets = Math.min(20, this.outletCountFSM1)
      } else {
        // FSM2模式
        maxOutlets = Math.min(20, this.outletCountFSM2)
      }
      
      // 生成Y轴标签（出口编号：0, 1, 2, ...）
      this.categories = []
      for (let i = 0; i < maxOutlets; i++) {
        this.categories.push(i.toString())
      }
      
      // 生成模拟数据（TODO: 后续可以替换为真实数据）
      this.fsm1Data = []
      this.fsm2Data = []
      for (let i = 0; i < maxOutlets; i++) {
        // FSM1数据：随机值 50-200
        this.fsm1Data.push(Math.floor(Math.random() * 150) + 50)
        // FSM2数据：随机值 30-180
        this.fsm2Data.push(Math.floor(Math.random() * 150) + 30)
      }
      
      // 对于垂直柱状图，高度使用传入的 chartHeight
      // 宽度需要根据出口数量计算，支持滚动（进一步放大条形）
      // 使用固定的条形宽度，确保切换子系统时条形大小一致
      this.canvasWidth = maxOutlets * this.fixedBarWidth + this.chartPadding.left + this.chartPadding.right
      
      // 重绘（确保画布尺寸有效）
      if (this.canvasHeight > 0) {
        this.draw()
      }
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error(`[ExportStatisticsHorizontalBarChart] 更新数据失败: ${errorMsg}`)
    }
  }
  
  
  /**
   * 绘制图表（水平条形图）
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
    
    // 找到最大值（用于计算比例）- 直接使用selectedSubsystem确保使用最新值
    const subsystem = this.selectedSubsystem
    let maxValue = 0
    if (subsystem === 'ALL') {
      // ALL模式：找FSM1和FSM2的最大值
      for (let i = 0; i < this.categories.length; i++) {
        maxValue = Math.max(maxValue, this.fsm1Data[i] || 0, this.fsm2Data[i] || 0)
      }
    } else if (subsystem === '1') {
      // FSM1模式
      for (let i = 0; i < this.categories.length; i++) {
        maxValue = Math.max(maxValue, this.fsm1Data[i] || 0)
      }
    } else {
      // FSM2模式
      for (let i = 0; i < this.categories.length; i++) {
        maxValue = Math.max(maxValue, this.fsm2Data[i] || 0)
      }
    }
    
    // 如果最大值为0，设置为1避免除零
    if (maxValue === 0) {
      maxValue = 1
    }
    
    // 计算每个条形的位置（垂直柱状图：条形从底部向上延伸）
    // 使用固定的条形宽度，确保切换子系统时条形大小一致
    const actualBarWidth = this.fixedBarWidth * 0.8  // 实际条形宽度（80%用于条形，20%用于间距）
    const barGap = this.fixedBarWidth * 0.1  // 条形之间的间距
    const barWidth = this.fixedBarWidth  // 每个条形占用的总宽度（包括间距）
    const baseY = this.canvasHeight - this.chartPadding.bottom  // 条形底部位置
    
    // 绘制条形（垂直方向：从底部向上延伸）
    ctx.font = '20px sans-serif'  // 增大条形数字字体
    ctx.textBaseline = 'bottom'
    ctx.textAlign = 'center'
    
    for (let i = 0; i < this.categories.length; i++) {
      const centerX = this.chartPadding.left + i * barWidth + barWidth / 2
      const x = this.chartPadding.left + i * barWidth + barGap
      
      // 直接使用selectedSubsystem确保使用最新值
      const subsystem = this.selectedSubsystem
      if (subsystem === 'ALL') {
        // ALL模式：绘制两个条形并排（FSM1和FSM2）
        // FSM1条形（绿色，左侧）
        const value1 = this.fsm1Data[i] || 0
        const barHeight1 = (value1 / maxValue) * chartHeight
        ctx.fillStyle = '#00B894' // 绿色
        ctx.fillRect(
          x,
          baseY - barHeight1,
          actualBarWidth / 2 - barGap / 2,
          barHeight1
        )
        
        // 绘制FSM1数值标签（在条形顶部）
        if (value1 > 0) {
          ctx.fillStyle = theme.textColor
          ctx.fillText(value1.toString(), x + (actualBarWidth / 2 - barGap / 2) / 2, baseY - barHeight1 - 5)
        }
        
        // FSM2条形（黄色，右侧）
        const value2 = this.fsm2Data[i] || 0
        const barHeight2 = (value2 / maxValue) * chartHeight
        ctx.fillStyle = '#FDCB6E' // 黄色
        ctx.fillRect(
          x + actualBarWidth / 2 + barGap / 2,
          baseY - barHeight2,
          actualBarWidth / 2 - barGap / 2,
          barHeight2
        )
        
        // 绘制FSM2数值标签（在条形顶部）
        if (value2 > 0) {
          ctx.fillStyle = theme.textColor
          ctx.fillText(value2.toString(), x + actualBarWidth / 2 + barGap / 2 + (actualBarWidth / 2 - barGap / 2) / 2, baseY - barHeight2 - 5)
        }
      } else if (subsystem === '1') {
        // FSM1模式：只绘制FSM1的条形
        const value = this.fsm1Data[i] || 0
        const barHeight = (value / maxValue) * chartHeight
        ctx.fillStyle = '#00B894' // 绿色
        ctx.fillRect(
          x,
          baseY - barHeight,
          actualBarWidth,
          barHeight
        )
        
        // 绘制数值标签（在条形顶部）
        if (value > 0) {
          ctx.fillStyle = theme.textColor
          ctx.fillText(value.toString(), centerX, baseY - barHeight - 5)
        }
      } else {
        // FSM2模式：只绘制FSM2的条形
        const value = this.fsm2Data[i] || 0
        const barHeight = (value / maxValue) * chartHeight
        ctx.fillStyle = '#FDCB6E' // 黄色
        ctx.fillRect(
          x,
          baseY - barHeight,
          actualBarWidth,
          barHeight
        )
        
        // 绘制数值标签（在条形顶部）
        if (value > 0) {
          ctx.fillStyle = theme.textColor
          ctx.fillText(value.toString(), centerX, baseY - barHeight - 5)
        }
      }
    }
    
    // 绘制X轴（底部横线）
    ctx.beginPath()
    ctx.moveTo(this.chartPadding.left, this.canvasHeight - this.chartPadding.bottom)
    ctx.lineTo(this.canvasWidth - this.chartPadding.right, this.canvasHeight - this.chartPadding.bottom)
    ctx.stroke()
    
    // 绘制X轴标签（出口编号0-20，在底部水平排列，对应每个条形的位置）
    ctx.font = '20px sans-serif'  // 增大X轴标签字体
    ctx.textAlign = 'center'
    ctx.textBaseline = 'top'
    ctx.fillStyle = theme.textColor
    
    // 使用固定的条形宽度计算X轴标签位置，确保与条形位置对齐
    for (let i = 0; i < this.categories.length; i++) {
      const centerX = this.chartPadding.left + i * this.fixedBarWidth + this.fixedBarWidth / 2
      ctx.fillText(this.categories[i], centerX, this.canvasHeight - this.chartPadding.bottom + 5)
    }
    
  }
  
  build() {
    Column() {
      // 使用 Scroll 组件支持水平滚动
      Scroll() {
        // 使用双重条件渲染：showCanvas 和 selectedSubsystem，确保Canvas完全重新创建
        if (this.showCanvas && (this.selectedSubsystem === 'ALL' || this.selectedSubsystem === '1' || this.selectedSubsystem === '2')) {
          Canvas(this.context)
            .width(this.canvasWidth)  // 固定宽度，支持滚动
            .height(this.canvasHeight)
            .key(`canvas-${this.selectedSubsystem}-${this.dataUpdateKey}-${this.refreshKey}`)  // 使用 key 强制重新创建Canvas
            .onReady(() => {
              // 设置画布高度
              this.canvasHeight = this.chartHeight
              // 确保使用最新的selectedSubsystem
              this.currentSubsystem = this.selectedSubsystem
              console.log(`[ExportStatisticsHorizontalBarChart] Canvas onReady, selectedSubsystem=${this.selectedSubsystem}, key=${this.dataUpdateKey}-${this.refreshKey}`)
              this.updateData()
            })
            .onAreaChange((oldValue: Area, newValue: Area) => {
              // 检查selectedSubsystem是否变化
              if (this.selectedSubsystem !== this.currentSubsystem) {
                console.log(`[ExportStatisticsHorizontalBarChart] onAreaChange检测到变化`)
                this.currentSubsystem = this.selectedSubsystem
                this.dataUpdateKey++  // 触发数据更新
                this.updateData()
              }
            })
        }
      }
      .scrollable(ScrollDirection.Horizontal)  // 水平滚动
      .scrollBar(BarState.Auto)
      .width('100%')
      .height(this.chartHeight)
    }
    .width('100%')
    .onAppear(() => {
      // 同步 selectedSubsystem 到 currentSubsystem
      if (this.selectedSubsystem !== this.currentSubsystem) {
        this.currentSubsystem = this.selectedSubsystem
        this.dataUpdateKey++  // 触发重新渲染
        this.updateData()
      }
    })
  }
}

