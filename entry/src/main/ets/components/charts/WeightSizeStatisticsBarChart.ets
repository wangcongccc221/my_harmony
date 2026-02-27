/**
 * 重量/尺寸统计信息柱状图组件
 * 功能：
 * - 显示两个柱状图：品质重量/尺寸等级统计信息和品质箱数统计信息
 * - 支持品质类型选择
 * - 根据子系统选择显示不同的数据
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
export struct WeightSizeStatisticsBarChart {
  // 主题接入
  @Consume providedTheme: ExtendedOmniThemeStyle
  
  // 可配置参数
  @Prop title: string = '重量/尺寸统计信息';
  @Prop chartHeight: number = 400;
  @Prop selectedSubsystem: string = 'ALL';
  
  // 品质类型选择
  @State selectedQualityType: string = '';
  
  // 出口数量
  @StorageLink('OutletCount_FSM1') private outletCountFSM1: number = 20
  @StorageLink('OutletCount_FSM2') private outletCountFSM2: number = 20
  
  @State private currentSubsystem: string = 'ALL'
  @State private refreshKey: number = 0
  @State private dataUpdateKey: number = 0
  @State private showCanvas1: boolean = true
  @State private showCanvas2: boolean = true
  
  private chartPadding: ChartPadding = {
    top: 20,
    right: 20,
    bottom: 50,  // 增加底部边距，确保X轴标签有足够空间
    left: 20
  };
  
  private fixedBarWidth: number = 100
  
  private settings1: RenderingContextSettings = new RenderingContextSettings(true);
  private context1: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings1);
  private settings2: RenderingContextSettings = new RenderingContextSettings(true);
  private context2: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings2);
  
  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.providedTheme)
  }
  
  @State private canvasWidth1: number = 0;
  @State private canvasHeight1: number = 0;
  @State private canvasWidth2: number = 0;
  @State private canvasHeight2: number = 0;
  
  @State categories: string[] = [];
  @State countData: number[] = [];
  @State weightData: number[] = [];
  @State boxCountData: number[] = [];
  private readonly statsService: RealtimeStatsService = getRealtimeStatsService()
  private statsListener: RealtimeStatsListener | null = null
  
  aboutToAppear() {
    this.currentSubsystem = this.selectedSubsystem
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
      this.updateData()
    }
  }
  
  private updateData(): void {
    try {
      let maxOutlets: number
      if (this.selectedSubsystem === 'ALL') {
        maxOutlets = Math.max(this.outletCountFSM1, this.outletCountFSM2)
        maxOutlets = Math.min(20, maxOutlets)
      } else if (this.selectedSubsystem === '1') {
        maxOutlets = Math.min(20, this.outletCountFSM1)
      } else {
        maxOutlets = Math.min(20, this.outletCountFSM2)
      }
      
      this.categories = ['23', '27', '32', '40']
      
      const snapshot = this.statsService.getSnapshot(this.selectedSubsystem)
      this.countData = new Array(this.categories.length).fill(0)
      this.weightData = new Array(this.categories.length).fill(0)
      this.boxCountData = new Array(this.categories.length).fill(0)
      for (let i = 0; i < this.categories.length; i++) {
        this.countData[i] = Number(snapshot.gradeCount[i] ?? 0)
        this.weightData[i] = Number(snapshot.gradeWeight[i] ?? 0)
        this.boxCountData[i] = Number(snapshot.boxGradeCount[i] ?? 0)
      }
      
      this.canvasWidth1 = this.categories.length * this.fixedBarWidth + this.chartPadding.left + this.chartPadding.right
      this.canvasWidth2 = this.categories.length * this.fixedBarWidth + this.chartPadding.left + this.chartPadding.right
      
      if (this.canvasHeight1 > 0) {
        this.drawChart1()
      }
      if (this.canvasHeight2 > 0) {
        this.drawChart2()
      }
    } catch (error) {
      console.error(`[WeightSizeStatisticsBarChart] 更新数据失败: ${error}`)
    }
  }
  
  private drawChart1(): void {
    if (!this.context1 || this.canvasWidth1 === 0 || this.canvasHeight1 === 0) {
      return
    }
    
    const theme = this.getCurrentTheme()
    const ctx = this.context1
    
    ctx.clearRect(0, 0, this.canvasWidth1, this.canvasHeight1)
    
    const chartWidth = this.canvasWidth1 - this.chartPadding.left - this.chartPadding.right
    const chartHeight = this.canvasHeight1 - this.chartPadding.top - this.chartPadding.bottom
    
    if (chartWidth <= 0 || chartHeight <= 0 || this.categories.length === 0) {
      return
    }
    
    // 第一个图表：使用重量数据，显示单个橙色系列
    let maxWeight = 0
    let totalWeight = 0
    
    for (let i = 0; i < this.categories.length; i++) {
      maxWeight = Math.max(maxWeight, this.weightData[i] || 0)
      totalWeight += this.weightData[i] || 0
    }
    
    if (maxWeight === 0) {
      maxWeight = 1
    }
    
    const actualBarWidth = this.fixedBarWidth * 0.8
    const barGap = this.fixedBarWidth * 0.1
    const barWidth = this.fixedBarWidth
    const baseY = this.canvasHeight1 - this.chartPadding.bottom
    
    ctx.font = '14px sans-serif'
    ctx.textBaseline = 'bottom'
    ctx.textAlign = 'center'
    
    for (let i = 0; i < this.categories.length; i++) {
      const centerX = this.chartPadding.left + i * barWidth + barWidth / 2
      const x = this.chartPadding.left + i * barWidth + barGap
      
      const weightValue = this.weightData[i] || 0
      const weightBarHeight = (weightValue / maxWeight) * chartHeight
      const weightPercent = totalWeight > 0 ? ((weightValue / totalWeight) * 100).toFixed(2) : '0.00'
      
      // 绘制橙色条形
      ctx.fillStyle = '#FE8A02' // 橙色
      ctx.fillRect(x, baseY - weightBarHeight, actualBarWidth, weightBarHeight)
      
      if (weightValue > 0) {
        ctx.fillStyle = theme.textColor
        ctx.font = '16px sans-serif'
        ctx.fillText(weightValue.toString(), centerX, baseY - weightBarHeight - 25)
        ctx.font = '14px sans-serif'
        ctx.fillText(`${weightPercent}%`, centerX, baseY - weightBarHeight - 8)
      }
    }
    
    // 绘制X轴
    ctx.beginPath()
    ctx.strokeStyle = theme.borderColor
    ctx.moveTo(this.chartPadding.left, this.canvasHeight1 - this.chartPadding.bottom)
    ctx.lineTo(this.canvasWidth1 - this.chartPadding.right, this.canvasHeight1 - this.chartPadding.bottom)
    ctx.stroke()
    
    // 绘制X轴标签（确保清晰可见）
    ctx.save()  // 保存当前状态
    ctx.font = '18px sans-serif'  // 增大字体到18px
    ctx.textAlign = 'center'
    ctx.textBaseline = 'top'
    ctx.fillStyle = '#333333'  // 使用深灰色，确保可见
    
    console.log(`[WeightSizeChart1] 绘制X轴标签: categories=${this.categories.length}, canvasHeight=${this.canvasHeight1}, bottom=${this.chartPadding.bottom}`)
    
    for (let i = 0; i < this.categories.length; i++) {
      const centerX = this.chartPadding.left + i * this.fixedBarWidth + this.fixedBarWidth / 2
      const labelY = this.canvasHeight1 - this.chartPadding.bottom + 20  // 增加间距到20
      // 确保标签在Canvas范围内
      if (labelY < this.canvasHeight1 && centerX >= this.chartPadding.left && centerX <= this.canvasWidth1 - this.chartPadding.right) {
        console.log(`[WeightSizeChart1] 绘制标签 ${i}: ${this.categories[i]}, x=${centerX}, y=${labelY}`)
        ctx.fillText(this.categories[i], centerX, labelY)
      } else {
        console.warn(`[WeightSizeChart1] 标签 ${i} 超出范围: x=${centerX}, y=${labelY}, canvasWidth=${this.canvasWidth1}, canvasHeight=${this.canvasHeight1}`)
      }
    }
    ctx.restore()  // 恢复状态
  }
  
  private drawChart2(): void {
    if (!this.context2 || this.canvasWidth2 === 0 || this.canvasHeight2 === 0) {
      return
    }
    
    const theme = this.getCurrentTheme()
    const ctx = this.context2
    
    ctx.clearRect(0, 0, this.canvasWidth2, this.canvasHeight2)
    
    const chartWidth = this.canvasWidth2 - this.chartPadding.left - this.chartPadding.right
    const chartHeight = this.canvasHeight2 - this.chartPadding.top - this.chartPadding.bottom
    
    if (chartWidth <= 0 || chartHeight <= 0 || this.categories.length === 0) {
      return
    }
    
    let maxBox = 0
    let totalBox = 0
    
    for (let i = 0; i < this.categories.length; i++) {
      maxBox = Math.max(maxBox, this.boxCountData[i] || 0)
      totalBox += this.boxCountData[i] || 0
    }
    
    if (maxBox === 0) {
      maxBox = 1
    }
    
    const actualBarWidth = this.fixedBarWidth * 0.8
    const barGap = this.fixedBarWidth * 0.1
    const barWidth = this.fixedBarWidth
    const baseY = this.canvasHeight2 - this.chartPadding.bottom
    
    ctx.font = '14px sans-serif'
    ctx.textBaseline = 'bottom'
    ctx.textAlign = 'center'
    
    for (let i = 0; i < this.categories.length; i++) {
      const centerX = this.chartPadding.left + i * barWidth + barWidth / 2
      const x = this.chartPadding.left + i * barWidth + barGap
      
      const boxValue = this.boxCountData[i] || 0
      const boxBarHeight = (boxValue / maxBox) * chartHeight
      const boxPercent = totalBox > 0 ? ((boxValue / totalBox) * 100).toFixed(2) : '0.00'
      
      // 绘制蓝色条形
      ctx.fillStyle = '#4A90E2' // 蓝色
      ctx.fillRect(x, baseY - boxBarHeight, actualBarWidth, boxBarHeight)
      
      if (boxValue > 0) {
        ctx.fillStyle = theme.textColor
        ctx.font = '14px sans-serif'
        ctx.fillText(`${boxPercent}%`, centerX, baseY - boxBarHeight - 25)
        ctx.font = '16px sans-serif'
        ctx.fillText(boxValue.toString(), centerX, baseY - boxBarHeight - 8)
      }
    }
    
    // 绘制X轴
    ctx.beginPath()
    ctx.strokeStyle = theme.borderColor
    ctx.moveTo(this.chartPadding.left, this.canvasHeight2 - this.chartPadding.bottom)
    ctx.lineTo(this.canvasWidth2 - this.chartPadding.right, this.canvasHeight2 - this.chartPadding.bottom)
    ctx.stroke()
    
    // 绘制X轴标签（确保清晰可见）
    ctx.save()  // 保存当前状态
    ctx.font = '18px sans-serif'  // 增大字体到18px
    ctx.textAlign = 'center'
    ctx.textBaseline = 'top'
    ctx.fillStyle = '#333333'  // 使用深灰色，确保可见
    
    console.log(`[WeightSizeChart2] 绘制X轴标签: categories=${this.categories.length}, canvasHeight=${this.canvasHeight2}, bottom=${this.chartPadding.bottom}`)
    
    for (let i = 0; i < this.categories.length; i++) {
      const centerX = this.chartPadding.left + i * this.fixedBarWidth + this.fixedBarWidth / 2
      const labelY = this.canvasHeight2 - this.chartPadding.bottom + 20  // 增加间距到20
      // 确保标签在Canvas范围内
      if (labelY < this.canvasHeight2 && centerX >= this.chartPadding.left && centerX <= this.canvasWidth2 - this.chartPadding.right) {
        console.log(`[WeightSizeChart2] 绘制标签 ${i}: ${this.categories[i]}, x=${centerX}, y=${labelY}`)
        ctx.fillText(this.categories[i], centerX, labelY)
      } else {
        console.warn(`[WeightSizeChart2] 标签 ${i} 超出范围: x=${centerX}, y=${labelY}, canvasWidth=${this.canvasWidth2}, canvasHeight=${this.canvasHeight2}`)
      }
    }
    ctx.restore()  // 恢复状态
  }
  
  build() {
    Column() {
      // 品质类型选择器
      Row() {
        Text('品质:')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getCurrentTheme().textColor)
          .margin({ right: 10 })
        
        Select([{ value: '' }])
          .value(this.selectedQualityType)
          .font({ size: 16 })
          .onSelect((index: number, value: string) => {
            this.selectedQualityType = value
            this.dataUpdateKey++
            this.updateData()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor(this.getCurrentTheme().surfaceColor)
      .border({ width: 1, color: this.getCurrentTheme().borderColor })
      .borderRadius(8)
      .margin({ bottom: 12 })
      
      // 第一个图表：品质重量/尺寸等级统计信息（占45%高度）
      Column() {
        Text('品质重量/尺寸等级统计信息')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getCurrentTheme().textColor)
          .margin({ bottom: 10 })
        
        Scroll() {
          if (this.showCanvas1) {
            Canvas(this.context1)
              .width(this.canvasWidth1)
              .height(this.canvasHeight1)
              .key(`weight-size-chart1-${this.selectedSubsystem}-${this.dataUpdateKey}-${this.refreshKey}`)
              .onReady(() => {
                // 增加Canvas高度，确保X轴标签有足够空间
                this.canvasHeight1 = 250
                this.updateData()
              })
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Auto)
        .width('100%')
        .layoutWeight(1)
      }
      .width('100%')
      .height('45%')
      .padding(16)
      .backgroundColor(this.getCurrentTheme().surfaceColor)
      .border({ width: 1, color: this.getCurrentTheme().borderColor })
      .borderRadius(8)
      .margin({ bottom: 6 })
      
      // 第二个图表：品质箱数统计信息（占45%高度）
      Column() {
        Text('品质箱数统计信息')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getCurrentTheme().textColor)
          .margin({ bottom: 10 })
        
        Scroll() {
          if (this.showCanvas2) {
            Canvas(this.context2)
              .width(this.canvasWidth2)
              .height(this.canvasHeight2)
              .key(`weight-size-chart2-${this.selectedSubsystem}-${this.dataUpdateKey}-${this.refreshKey}`)
              .onReady(() => {
                // 增加Canvas高度，确保X轴标签有足够空间
                this.canvasHeight2 = 250
                this.updateData()
              })
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Auto)
        .width('100%')
        .layoutWeight(1)
      }
      .width('100%')
      .height('45%')
      .padding(16)
      .backgroundColor(this.getCurrentTheme().surfaceColor)
      .border({ width: 1, color: this.getCurrentTheme().borderColor })
      .borderRadius(8)
      .margin({ top: 6 })
    }
    .width('100%')
    .height('100%')
    .onAppear(() => {
      if (this.selectedSubsystem !== this.currentSubsystem) {
        this.currentSubsystem = this.selectedSubsystem
        this.dataUpdateKey++
        this.updateData()
      }
    })
  }
}

