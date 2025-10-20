// 数据接口定义
import { BaseComponentHelper } from './common/BaseComponent'
import { ExtendedOmniThemeStyle } from '../utils/theme/OmniThemeManager'
export interface ChartData {
  time: string;
  value: number;
}

// 图表组件参数接口
export interface ChartComponentParams {
  dataCount?: number; // 数据点数量，默认50
  startHour?: number; // 开始小时，默认15
  startMinute?: number; // 开始分钟，默认0
  chartHeight?: number; // 图表高度，默认300
  barWidth?: number; // 柱子宽度，默认20
  barSpacing?: number; // 柱子间距，默认50
  showScrollBar?: boolean; // 是否显示滚动条，默认false
  onDataClick?: (data: ChartData, event: ClickEvent) => void; // 数据点击回调
  axisFontSizePx?: number; // Y轴刻度字体大小
  labelFontSizePx?: number; // X轴标签字体大小
  axisFontBold?: boolean; // Y轴文字加粗
  labelFontBold?: boolean; // X轴文字加粗
}

@Component
export struct ChartComponent {
  // 主题接入
  private baseComponentHelper = new BaseComponentHelper()
  @Consume providedTheme: ExtendedOmniThemeStyle
  @State chartData: ChartData[] = [];
  @State dataCount: number = 50;
  @State startHour: number = 15;
  @State startMinute: number = 0;
  @State chartHeight: number = 300;
  @State barWidth: number = 20;
  @State barSpacing: number = 50;
  @State showScrollBar: boolean = false;
  @State axisFontSizePx: number = 12;
  @State labelFontSizePx: number = 16;
  @State axisFontBold: boolean = false;
  @State labelFontBold: boolean = false;
  @State tooltipVisible: boolean = false;
  @State tooltipText: string = '';
  @State tooltipX: number = 0;
  @State tooltipY: number = 0;
  @Prop params: ChartComponentParams = {};
  scroller: Scroller = new Scroller();
  
  // 实时数据更新相关
  private timerId?: number;
  private currentValue: number = 50; // 当前数值
  @State private followLatest: boolean = true; // 是否自动跟随最新
  @State private lastScrollX: number = 0; // 最近一次滚动位置
  private currentTimeIndex: number = 0; // 当前时间索引

  // 生成时间标签
  generateTimeLabels(count: number): string[] {
    const labels: string[] = [];
    
    for (let i = 0; i < count; i++) {
      const hour = this.startHour + Math.floor((this.startMinute + i) / 60);
      const minute = (this.startMinute + i) % 60;
      
      const hourStr = hour.toString().padStart(2, '0');
      const minuteStr = minute.toString().padStart(2, '0');
      
      labels.push(`${hourStr}:${minuteStr}`);
    }
    
    return labels;
  }

  // 生成随机数据
  generateData(): void {
    const timeLabels = this.generateTimeLabels(this.dataCount);
    this.chartData = timeLabels.map((time: string, index: number): ChartData => ({
      time: time,
      value: Math.floor(Math.random() * 90) + 10 // 10-100之间的随机数
    }));
  }

  // 生成新的时间标签（基于初始时间继续）
  private generateNewTimeLabel(): string {
    // 基于初始时间继续，每分钟一个数据点
    const totalMinutes = this.startMinute + this.currentTimeIndex;
    const hour = this.startHour + Math.floor(totalMinutes / 60);
    const minute = totalMinutes % 60;
    
    const hourStr = hour.toString().padStart(2, '0');
    const minuteStr = minute.toString().padStart(2, '0');
    
    this.currentTimeIndex++;
    return `${hourStr}:${minuteStr}`;
  }

  // 生成新的数值（随机游走）
  private generateNewValue(): number {
    const step = (Math.random() * 10) - 5; // -5 ~ +5
    this.currentValue = Math.max(10, Math.min(100, Math.round(this.currentValue + step)));
    return this.currentValue;
  }

  // 启动实时数据更新
  private startRealTimeUpdate(): void {
    if (this.timerId) return;
    
    this.timerId = setInterval(() => {
      const newTime = this.generateNewTimeLabel();
      const newValue = this.generateNewValue();
      
      // 添加新数据点（无上限）
      this.chartData.push({ time: newTime, value: newValue });
      
      // 仅在跟随最新时，自动滚动到末尾
      if (this.followLatest) {
        setTimeout(() => {
          this.scroller.scrollTo({ xOffset: this.chartData.length * (this.barWidth + this.barSpacing), yOffset: 0 });
        }, 100);
      }
      
    }, 1000) as number;
  }

  // 停止实时数据更新
  private stopRealTimeUpdate(): void {
    if (this.timerId) {
      clearInterval(this.timerId);
      this.timerId = undefined;
    }
  }

  // 显示提示框
  showTooltip(data: ChartData, event: ClickEvent): void {
    this.tooltipText = `时间: ${data.time}\n数值: ${data.value}`;
    this.tooltipX = event.x + 10;
    this.tooltipY = event.y - 40;
    this.tooltipVisible = true;
  }

  // 隐藏提示框
  hideTooltip(): void {
    this.tooltipVisible = false;
  }

  // 处理数据点击
  handleDataClick(data: ChartData, event: ClickEvent): void {
    if (this.params.onDataClick) {
      this.params.onDataClick(data, event);
    } else {
      this.showTooltip(data, event);
    }
  }

  aboutToAppear(): void {
    // 应用参数
    this.dataCount = this.params.dataCount || 50;
    this.startHour = this.params.startHour || 15;
    this.startMinute = this.params.startMinute || 0;
    this.chartHeight = this.params.chartHeight || 300;
    this.barWidth = this.params.barWidth || 20;
    this.barSpacing = this.params.barSpacing || 50;
    this.showScrollBar = this.params.showScrollBar || false;
    this.axisFontSizePx = this.params.axisFontSizePx || 12;
    this.labelFontSizePx = this.params.labelFontSizePx || 16;
    this.axisFontBold = !!this.params.axisFontBold;
    this.labelFontBold = !!this.params.labelFontBold;
    
    // 初始化时间索引（从初始数据量开始）
    this.currentTimeIndex = this.dataCount;
    
    // 初始化数据
    this.generateData();
    
    // 启动实时数据更新
    this.startRealTimeUpdate();
  }

  aboutToDisappear(): void {
    // 停止实时数据更新
    this.stopRealTimeUpdate();
  }

  getCurrentTheme(): ExtendedOmniThemeStyle {
    return this.baseComponentHelper.getCurrentTheme(this.providedTheme)
  }

  build() {
    Stack() {
      Column() {
        // 图表容器
        Column() {
          // 图表主体区域
          Row() {
            // Y轴标签
            Column() {
              ForEach([100, 80, 60, 40, 20, 0], (value: number) => {
                Text(value.toString())
                  .fontSize(this.axisFontSizePx)
                  .fontWeight(this.axisFontBold ? FontWeight.Bold : FontWeight.Regular)
                  .fontColor(this.getCurrentTheme().subTextColor)
                  .width(40)
                  .textAlign(TextAlign.End)
                  .margin({ right: 5 })
              })
            }
            .width(45)
            .height(this.chartHeight)
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ top: 10, bottom: 10 })
            .border({ width: 1, color: this.getCurrentTheme().borderColor })

            // 图表区域（可滚动）
            Scroll(this.scroller) {
              Row() {
                ForEach(this.chartData, (data: ChartData, index: number) => {
                  Column() {
                    // 数值标签（在柱子顶部）
                    Text(data.value.toString())
                      .fontSize(16)
                      .fontColor(this.getCurrentTheme().textColor)
                      .fontWeight(FontWeight.Bold)
                      .margin({ bottom: 2 })
                      .textAlign(TextAlign.Center)

                    // 柱子
                    Column()
                      .width(this.barWidth) // 使用可配置的柱子宽度
                      .height(data.value * 2.5) // 根据数值设置高度
                      .backgroundColor(this.getCurrentTheme().chartLineColor ?? this.getCurrentTheme().primary)
                      .borderRadius({ topLeft: 3, topRight: 3 })
                      .onClick((event: ClickEvent) => {
                        this.handleDataClick(data, event);
                      })
                      .onTouch((event: TouchEvent) => {
                        if (event.type === TouchType.Down) {
                          const clickEvent: ClickEvent = {
                            x: event.touches[0].x,
                            y: event.touches[0].y
                          } as ClickEvent;
                          this.handleDataClick(data, clickEvent);
                        } else if (event.type === TouchType.Up) {
                          this.hideTooltip();
                        }
                      })

                    // 时间标签
                    Text(data.time)
                      .fontSize(this.labelFontSizePx)
                      .fontWeight(this.labelFontBold ? FontWeight.Bold : FontWeight.Regular)
                      .fontColor(this.getCurrentTheme().subTextColor)
                      .margin({ top: 5 })
                      .textAlign(TextAlign.Center)
                  }
                  .margin({ left: this.barSpacing / 2, right: this.barSpacing / 2 }) // 使用可配置的间距
                  .alignItems(HorizontalAlign.Center)
                })
              }
              .width(this.chartData.length * (this.barWidth + this.barSpacing)) // 使用可配置的宽度计算
              .height(this.chartHeight)
              .alignItems(VerticalAlign.Bottom)
              .padding({ left: 10, right: 10 })
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(this.showScrollBar ? BarState.Auto : BarState.Off)
            .scrollBarColor(this.getCurrentTheme().borderColor)
            .scrollBarWidth(8)
            .layoutWeight(1)
            .border({ width: 1, color: this.getCurrentTheme().borderColor })
            .borderRadius(4)
            .backgroundColor(this.getCurrentTheme().chartBg ?? this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
            .onScroll((x: number, y: number) => {
              // 用户向左滚动（回看历史）则关闭自动跟随
              if (x < this.lastScrollX - 1) {
                this.followLatest = false;
              } else {
                // 当滚动接近末尾若干柱宽度范围内，自动恢复跟随
                const contentWidth = this.chartData.length * (this.barWidth + this.barSpacing);
                const nearTailThreshold = 5 * (this.barWidth + this.barSpacing);
                if (x >= Math.max(0, contentWidth - nearTailThreshold)) {
                  this.followLatest = true;
                }
              }
              this.lastScrollX = x;
            })
          }
          .width('100%')
          .height(this.chartHeight)

        }
        .width('100%')
        .padding(20)
        .backgroundColor(this.getCurrentTheme().chartBg ?? this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
        .borderRadius(8)
        .shadow({
          radius: 10,
          color: 'rgba(0, 0, 0, 0.1)',
          offsetX: 0,
          offsetY: 2
        })
      }
      .width('100%')
      .height('100%')
      .padding(20)
        .backgroundColor(this.getCurrentTheme().pageBg ?? this.getCurrentTheme().surfaceColor)
      .justifyContent(FlexAlign.Start)

      // 提示框
      if (this.tooltipVisible) {
        Text(this.tooltipText)
          .fontSize(12)
          .fontColor('#FFFFFF')
          .backgroundColor('rgba(0, 0, 0, 0.8)')
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .borderRadius(4)
          .position({ x: this.tooltipX, y: this.tooltipY })
          .zIndex(100)
      }
    }
    .width('100%')
    .height('100%')
  }
}
