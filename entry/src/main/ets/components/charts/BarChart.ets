// 定义接口
import { ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { MultiSeriesBarFeed } from '../../utils/MultiSeriesBarFeed'

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

/**
 * 动态并列柱状图组件
 * 
 * @param title 图表标题，默认为"动态并列柱状图"
 * @param chartHeight 图表高度（px），默认为300
 * @param maxDataCount 最大数据点数量，默认为60
 * @param itemWidth 每个数据点的宽度（px），默认为60
 * @param updateInterval 数据更新间隔（毫秒），默认为2100
 * @param chartBackgroundColor 背景颜色，默认为"#F1F3F5"
 * @param seriesConfig 数据系列配置数组，包含name（名称）和color（颜色）
 */
@Component
export struct BarChart {
  // 主题接入
  @Consume providedTheme: ExtendedOmniThemeStyle
  
  // 可配置参数
  @Prop title: string = '加工柱状图';
  @Prop chartHeight: number = 380;
  private maxDataCount: number = 60;
  private itemWidth: number = 60;
  private updateInterval: number = 2100;
  private seriesConfig: SeriesConfig[] = [
    { name: '直接访问', color: '#5470c6', data: [] },
    { name: '邮件营销', color: '#91cc75', data: [] },
    { name: '联盟广告', color: '#fac858', data: [] },
    { name: '视频广告', color: '#ee6666', data: [] }
  ];
  
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  
  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.providedTheme)
  }
  
  // 画布尺寸
  @State private canvasWidth: number = 0;
  private canvasHeight: number = 0;
  private minCanvasWidth: number = 0; // 最小画布宽度（显示区域）
  
  // 图表区域边距
  private chartPadding: ChartPadding = {
    top: 30,
    right: 25,
    bottom: 30,
    left: 50
  };
  
  // 数据
  @State categories: string[] = [];
  @State data1: number[] = [];
  @State data2: number[] = [];
  @State data3: number[] = [];
  @State data4: number[] = [];
  
  // 全局数据源
  private dataFeed = MultiSeriesBarFeed.getInstance()
  
  // 定时器ID（用于刷新UI，数据源在后台持续更新）
  private refreshTimerId: number = -1;
  
  aboutToAppear() {
    // 确保全局数据源在后台运行（持续记录数据）
    this.dataFeed.start();
    // 从全局数据源同步数据
    this.syncDataFromFeed();
    // 启动刷新定时器，定期从数据源同步数据并重绘
    this.startRefreshTimer();
  }
  
  aboutToDisappear() {
    // 清理刷新定时器，防止内存泄漏
    if (this.refreshTimerId !== -1) {
      clearInterval(this.refreshTimerId);
      this.refreshTimerId = -1;
    }
    // 注意：不清空数据数组，因为数据源会持续运行
  }
  
  // 从全局数据源同步数据
  private syncDataFromFeed(): void {
    const snapshot = this.dataFeed.getSnapshot();
    this.categories = snapshot.categories;
    
    // 更新各个系列的数据
    if (snapshot.series.length >= 4) {
      this.data1 = snapshot.series[0].data;
      this.data2 = snapshot.series[1].data;
      this.data3 = snapshot.series[2].data;
      this.data4 = snapshot.series[3].data;
      
      // 更新系列配置中的数据
      this.seriesConfig[0].data = this.data1;
      this.seriesConfig[1].data = this.data2;
      this.seriesConfig[2].data = this.data3;
      this.seriesConfig[3].data = this.data4;
    }
    
    // 更新画布宽度
    this.updateCanvasWidth();
    
    // 重绘
    if (this.context) {
      this.draw();
    }
  }
  
  // 启动刷新定时器（定期从数据源同步数据）
  private startRefreshTimer(): void {
    // 防止重复启动定时器，先清理旧的
    if (this.refreshTimerId !== -1) {
      clearInterval(this.refreshTimerId);
      this.refreshTimerId = -1;
    }
    
    // 每500ms刷新一次UI（数据源每2.1秒更新一次数据）
    this.refreshTimerId = setInterval(() => {
      // 检查组件是否还存在
      if (!this.context) {
        if (this.refreshTimerId !== -1) {
          clearInterval(this.refreshTimerId);
          this.refreshTimerId = -1;
        }
        return;
      }
      
      // 从全局数据源同步最新数据
      this.syncDataFromFeed();
    }, 500) as number;
  }
  
  // 更新画布宽度
  updateCanvasWidth() {
    const dataCount = this.categories.length;
    // 画布宽度 = 左边距 + 数据点数量 * 每个数据点宽度 + 右边距
    // 当数据达到最大数量时，固定为最大数量的宽度，支持滚动
    const actualDataCount = dataCount >= this.maxDataCount ? this.maxDataCount : dataCount;
    this.canvasWidth = this.chartPadding.left + actualDataCount * this.itemWidth + this.chartPadding.right;
    // 确保最小宽度（显示区域宽度）
    if (this.canvasWidth < this.minCanvasWidth) {
      this.canvasWidth = this.minCanvasWidth;
    }
  }
  
  // 滚动到末尾（最新数据）- 暂时不使用控制器
  // scrollToEnd() {
  //   if (this.scrollController) {
  //     this.scrollController.scrollToEdge(Edge.End, true);
  //   }
  // }
  
  // 绘制图表
  draw() {
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
  drawTitle() {
    const theme = this.getCurrentTheme()
    this.context.save();
    this.context.font = '18px sans-serif';
    this.context.fillStyle = theme.textColor as string;
    this.context.textAlign = 'center';
    this.context.fillText(this.title, this.canvasWidth / 2, 20);
    this.context.restore();
  }
  
  // 绘制图例
  drawLegend() {
    const legendX = this.canvasWidth - this.chartPadding.right;
    const legendY = this.chartPadding.top;
    const itemHeight = 20;
    const itemSpacing = 5;
    
    this.context.save();
    this.context.font = '13px sans-serif';
    
    this.seriesConfig.forEach((series, index) => {
      const y = legendY + index * (itemHeight + itemSpacing);
      
      // 绘制颜色方块
      this.context.fillStyle = series.color;
      this.context.fillRect(legendX - 80, y - 10, 12, 12);
      
      // 绘制文字
      const theme = this.getCurrentTheme()
      this.context.fillStyle = theme.textColor as string;
      this.context.textAlign = 'left';
      this.context.fillText(series.name, legendX - 65, y);
    });
    
    this.context.restore();
  }
  
  // 绘制坐标轴
  drawAxes(chartWidth: number, chartHeight: number) {
    const startX = this.chartPadding.left;
    const startY = this.chartPadding.top;
    const endX = this.chartPadding.left + chartWidth;
    const endY = this.chartPadding.top + chartHeight;
    
    // 只声明一次 theme 变量，避免重复声明
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
    
    this.context.font = '12px sans-serif';
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
      this.context.fillText(Math.round(value).toString(), startX - 10, y + 4);
    }
    
    // 绘制X轴刻度
    const dataCount = this.categories.length;
    // 使用固定的每个数据点宽度
    const barGroupWidth = this.itemWidth;
    
    this.context.textAlign = 'center';
    this.context.font = '12px sans-serif';
    this.context.fillStyle = theme.textColor as string;
    
    this.categories.forEach((category, index) => {
      const x = startX + index * barGroupWidth + barGroupWidth / 2;
      
      // 绘制刻度线
      this.context.beginPath();
      this.context.moveTo(x, endY);
      this.context.lineTo(x, endY + 5);
      this.context.stroke();
      
      // 绘制刻度值（水平显示）
      this.context.fillText(category, x, endY + 18);
    });
    
    this.context.restore();
  }
  
  // 获取最大值
  getMaxValue(): number {
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
  drawBars(chartWidth: number, chartHeight: number) {
    const dataCount = this.categories.length;
    // 使用固定的每个数据点宽度，而不是平均分配
    const barGroupWidth = this.itemWidth;
    const barWidth = barGroupWidth * 0.8 / this.seriesConfig.length; // 每个柱子的宽度
    const barSpacing = barGroupWidth * 0.2 / (this.seriesConfig.length + 1); // 柱子之间的间距
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
        
        // 绘制柱子
        this.context.fillRect(barX, barY, barWidth, barHeight);
        
        // 绘制数值标签（可选，如果柱子足够高）
        if (barHeight > 15) {
          const theme = this.getCurrentTheme()
          this.context.save();
          this.context.fillStyle = theme.textColor as string;
          this.context.font = '12px sans-serif';
          this.context.textAlign = 'center';
          this.context.fillText(value.toString(), barX + barWidth / 2, barY - 3);
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
            
            // 初始化绘制（数据已在 aboutToAppear 中同步）
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

