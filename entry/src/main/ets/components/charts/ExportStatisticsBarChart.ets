/**
 * 出口统计信息柱状图组件
 * 功能：
 * - 不动态更新数据（静态数据）
 * - 只显示2个数据系列
 * - X轴与FSM液体卡片联动（根据选中的FSM显示对应出口数量）
 */

import { ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { HOME_SELECTED_FSM } from '../../constants/TopBarKeys'

interface ChartPadding {
  top: number;
  right: number;
  bottom: number;
  left: number;
}

interface SeriesConfig {
  name: string;
  color: string;
  data: number[];
}

@Component
export struct ExportStatisticsBarChart {
  // 主题接入
  @Consume providedTheme: ExtendedOmniThemeStyle
  
  // 可配置参数
  @Prop title: string = '出口统计信息';
  @Prop chartHeight: number = 400;
  
  // FSM联动（使用@Watch监听变化）
  @StorageLink(HOME_SELECTED_FSM) @Watch('onFSMChange') private selectedFSM: 'FSM1' | 'FSM2' = 'FSM1'
  @StorageLink('OutletCount_FSM1') private outletCountFSM1: number = 20
  @StorageLink('OutletCount_FSM2') private outletCountFSM2: number = 20
  
  private itemWidth: number = 90;  // 从60增加到90，让柱子更大更宽
  
  // 图表区域边距
  private chartPadding: ChartPadding = {
    top: 30,
    right: 25,
    bottom: 30,
    left: 50
  };
  
  // 只保留2个数据系列
  private seriesConfig: SeriesConfig[] = [
    { name: '指标1', color: '#00B894', data: [] },  // 绿色
    { name: '指标2', color: '#FDCB6E', data: [] }   // 黄色
  ];
  
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  
  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.providedTheme)
  }
  
  // 画布尺寸
  @State private canvasWidth: number = 0;
  private canvasHeight: number = 0;
  private minCanvasWidth: number = 0;
  
  // 数据（静态，不动态更新）
  @State categories: string[] = [];
  @State data1: number[] = [];
  @State data2: number[] = [];
  
  aboutToAppear() {
    // 初始化静态数据（不启动定时器）
    this.initStaticData();
  }
  
  // 初始化静态数据
  private initStaticData(): void {
    // 根据选中的FSM获取出口数量
    const outletCount = this.selectedFSM === 'FSM1' ? this.outletCountFSM1 : this.outletCountFSM2;
    const maxOutlets = Math.min(20, outletCount); // 最多显示20个出口
    
    // 生成X轴标签（出口1, 出口2, ...）
    this.categories = [];
    for (let i = 1; i <= maxOutlets; i++) {
      this.categories.push(`出口${i}`);
    }
    
    // 生成静态模拟数据（两个指标）
    this.data1 = [];
    this.data2 = [];
    for (let i = 0; i < maxOutlets; i++) {
      // 第一个指标：随机值 100-200
      this.data1.push(Math.floor(Math.random() * 100) + 100);
      // 第二个指标：随机值 50-150
      this.data2.push(Math.floor(Math.random() * 100) + 50);
    }
    
    // 更新系列配置中的数据
    this.seriesConfig[0].data = this.data1;
    this.seriesConfig[1].data = this.data2;
    
    // 更新画布宽度
    this.updateCanvasWidth();
    
    // 重绘
    if (this.context) {
      this.draw();
    }
  }
  
  // 监听FSM变化（使用@Watch装饰器，立即响应）
  onFSMChange(): void {
    console.log(`ExportStatisticsBarChart: FSM状态变化到 ${this.selectedFSM}`)
    // 立即重新初始化数据并重绘
    this.initStaticData()
  }
  
  // 更新画布宽度
  private updateCanvasWidth(): void {
    const dataCount = this.categories.length;
    const actualDataCount = dataCount;
    this.canvasWidth = this.chartPadding.left + actualDataCount * this.itemWidth + this.chartPadding.right;
    if (this.canvasWidth < this.minCanvasWidth) {
      this.canvasWidth = this.minCanvasWidth;
    }
  }
  
  // 绘制图表
  private draw(): void {
    if (!this.context || this.canvasWidth === 0 || this.canvasHeight === 0) {
      return;
    }
    
    // 清空画布
    this.context.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
    
    // 计算图表区域
    const chartWidth = this.canvasWidth - this.chartPadding.left - this.chartPadding.right;
    const chartHeight = this.canvasHeight - this.chartPadding.top - this.chartPadding.bottom;
    
    // 绘制标题
    this.drawTitle();
    
    // 绘制图例
    this.drawLegend();
    
    // 绘制坐标轴
    this.drawAxes(chartWidth, chartHeight);
    
    // 绘制柱状图
    this.drawBars(chartWidth, chartHeight);
  }
  
  // 绘制标题
  private drawTitle(): void {
    const theme = this.getCurrentTheme()
    this.context.save();
    this.context.font = '18px sans-serif';
    this.context.fillStyle = theme.textColor as string;
    this.context.textAlign = 'center';
    this.context.fillText(this.title, this.canvasWidth / 2, 20);
    this.context.restore();
  }
  
  // 绘制图例（用卡片包裹，适中尺寸）
  private drawLegend(): void {
    const legendX = this.canvasWidth - this.chartPadding.right;
    const legendY = this.chartPadding.top;
    const itemHeight = 28;  // 适中的高度
    const itemSpacing = 8;  // 适中的间距
    const iconSize = 16;     // 适中的图标大小
    const cardPadding = 8;  // 适中的内边距
    const cardWidth = 110;   // 适中的卡片宽度
    const cardHeight = (itemHeight + itemSpacing) * this.seriesConfig.length - itemSpacing + cardPadding * 2;  // 卡片高度
    
    const theme = this.getCurrentTheme()
    this.context.save();
    
    // 绘制卡片背景（带圆角和边框）
    const cardX = legendX - cardWidth;
    const cardY = legendY;
    const radius = 10;  // 圆角半径稍微增大
    
    // 绘制圆角矩形卡片背景
    this.context.fillStyle = theme.surfaceColor as string;
    this.context.beginPath();
    // 使用arc绘制圆角矩形
    this.context.moveTo(cardX + radius, cardY);
    this.context.lineTo(cardX + cardWidth - radius, cardY);
    this.context.arc(cardX + cardWidth - radius, cardY + radius, radius, -Math.PI / 2, 0);
    this.context.lineTo(cardX + cardWidth, cardY + cardHeight - radius);
    this.context.arc(cardX + cardWidth - radius, cardY + cardHeight - radius, radius, 0, Math.PI / 2);
    this.context.lineTo(cardX + radius, cardY + cardHeight);
    this.context.arc(cardX + radius, cardY + cardHeight - radius, radius, Math.PI / 2, Math.PI);
    this.context.lineTo(cardX, cardY + radius);
    this.context.arc(cardX + radius, cardY + radius, radius, Math.PI, -Math.PI / 2);
    this.context.closePath();
    this.context.fill();
    
    // 绘制卡片边框
    this.context.strokeStyle = theme.borderColor as string;
    this.context.lineWidth = 1.5;  // 边框稍微加粗
    this.context.stroke();
    
    // 绘制图例内容
    this.context.font = '12px sans-serif';  // 适中的字体大小
    
    this.seriesConfig.forEach((series, index) => {
      const y = legendY + cardPadding + index * (itemHeight + itemSpacing) + itemHeight / 2;
      
      // 绘制颜色方块（适中的图标）
      this.context.fillStyle = series.color;
      this.context.fillRect(cardX + cardPadding, y - iconSize / 2, iconSize, iconSize);
      
      // 绘制文字
      this.context.fillStyle = theme.textColor as string;
      this.context.textAlign = 'left';
      this.context.fillText(series.name, cardX + cardPadding + iconSize + 6, y + 3);  // 调整文字位置
    });
    
    this.context.restore();
  }
  
  // 绘制坐标轴
  private drawAxes(chartWidth: number, chartHeight: number): void {
    const startX = this.chartPadding.left;
    const startY = this.chartPadding.top;
    const endX = this.chartPadding.left + chartWidth;
    const endY = this.chartPadding.top + chartHeight;
    
    const theme = this.getCurrentTheme()
    this.context.save();
    this.context.strokeStyle = theme.borderColor as string;
    this.context.lineWidth = 1;
    
    // 绘制Y轴
    this.context.beginPath();
    this.context.moveTo(startX, startY);
    this.context.lineTo(startX, endY);
    this.context.stroke();
    
    // 绘制X轴
    this.context.beginPath();
    this.context.moveTo(startX, endY);
    this.context.lineTo(endX, endY);
    this.context.stroke();
    
    // 绘制Y轴刻度
    const maxValue = this.getMaxValue();
    const yTickCount = 5;
    const yTickStep = maxValue / yTickCount;
    
    this.context.font = '18px sans-serif';  // 从16px增加到18px，让Y轴字体更大
    this.context.fillStyle = theme.textColor as string;
    this.context.textAlign = 'right';
    
    for (let i = 0; i <= yTickCount; i++) {
      const value = maxValue - i * yTickStep;
      const y = startY + (i * chartHeight / yTickCount);
      
      // 绘制刻度线
      this.context.beginPath();
      this.context.moveTo(startX - 5, y);
      this.context.lineTo(startX, y);
      this.context.stroke();
      
      // 绘制刻度值
      this.context.fillText(Math.round(value).toString(), startX - 15, y + 6);  // 调整位置以适应更大的字体
    }
    
    // 绘制X轴刻度
    const dataCount = this.categories.length;
    const barGroupWidth = this.itemWidth;
    
    this.context.textAlign = 'center';
    this.context.font = '14px sans-serif';  // 从10px增加到14px，让X轴字体更大
    this.context.fillStyle = theme.textColor as string;
    
    this.categories.forEach((category, index) => {
      const x = startX + index * barGroupWidth + barGroupWidth / 2;
      
      // 绘制刻度线
      this.context.beginPath();
      this.context.moveTo(x, endY);
      this.context.lineTo(x, endY + 5);
      this.context.stroke();
      
      // 绘制刻度值（旋转显示，避免重叠）
      this.context.save();
      this.context.translate(x, endY + 20);  // 稍微下移以适应更大的字体
      this.context.rotate(-Math.PI / 4); // 旋转45度
      this.context.fillText(category, 0, 0);
      this.context.restore();
    });
    
    this.context.restore();
  }
  
  // 获取最大值
  private getMaxValue(): number {
    let max = 0;
    this.seriesConfig.forEach(series => {
      series.data.forEach(value => {
        if (value > max) {
          max = value;
        }
      });
    });
    // 向上取整到最近的50的倍数
    return Math.ceil(max / 50) * 50;
  }
  
  // 绘制柱状图
  private drawBars(chartWidth: number, chartHeight: number): void {
    const dataCount = this.categories.length;
    const barGroupWidth = this.itemWidth;
    const barWidth = barGroupWidth * 0.85 / this.seriesConfig.length; // 每个柱子的宽度（从0.8增加到0.85，让柱子更宽）
    const barSpacing = barGroupWidth * 0.15 / (this.seriesConfig.length + 1); // 柱子之间的间距
    const maxValue = this.getMaxValue();
    const startX = this.chartPadding.left;
    const startY = this.chartPadding.top;
    const baseY = startY + chartHeight;
    
    this.context.save();
    
    this.seriesConfig.forEach((series, seriesIndex) => {
      this.context.fillStyle = series.color;
      
      series.data.forEach((value, dataIndex) => {
        const barHeight = (value / maxValue) * chartHeight;
        const groupStartX = startX + dataIndex * barGroupWidth;
        const barX = groupStartX + barSpacing + seriesIndex * (barWidth + barSpacing);
        const barY = baseY - barHeight;
        
        // 绘制柱子（更粗更大）
        this.context.fillRect(barX, barY, barWidth, barHeight);
        
        // 绘制数值标签（字体调大，更容易看清）
        if (barHeight > 12) {
          const theme = this.getCurrentTheme()
          this.context.save();
          this.context.fillStyle = theme.textColor as string;
          this.context.font = '14px sans-serif';  // 从10px增加到14px
          this.context.textAlign = 'center';
          this.context.fillText(value.toString(), barX + barWidth / 2, barY - 5);  // 位置稍微上移
          this.context.restore();
        }
      });
    });
    
    this.context.restore();
  }
  
  build() {
    Column() {
      Scroll() {
        Canvas(this.context)
          .width(this.canvasWidth > 0 ? this.canvasWidth : 1000)
          .height(this.chartHeight)
          .backgroundColor((this.getCurrentTheme().chartBg ?? this.getCurrentTheme().surfaceColor) as string)
          .onReady(() => {
            // 获取显示区域的宽度作为最小宽度
            this.minCanvasWidth = this.context.width;
            this.canvasHeight = this.chartHeight;
            
            // 初始化画布宽度
            this.updateCanvasWidth();
            
            // 初始化绘制
            this.draw();
          })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.On)
      .scrollBarWidth(4)
      .scrollBarColor('#888888')
      .friction(0.6)
      .width('100%')
      .height(this.chartHeight)
    }
    .width('100%')
    .height('100%')
  }
}

