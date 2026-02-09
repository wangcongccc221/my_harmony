import { hilog } from '@kit.PerformanceAnalysisKit'

const DOMAIN = 0x0000

// 定义系列数据接口
export interface SeriesData {
  name: string
  color: string
  data: number[]
}

// 定义快照接口
export interface MultiSeriesBarSnapshot {
  categories: string[]
  series: SeriesData[]
}

// 定义内部系列数据结构
interface InternalSeriesData {
  name: string
  color: string
  dataBuf: number[]
  currentValue: number
}

// 定义范围配置接口
interface RangeConfig {
  min: number
  max: number
  step: number
}

/**
 * 全局多系列柱状图数据源（单例）
 * - 在后台持续生成模拟数据（每2.1秒一个点）
 * - 使用固定长度环形缓冲区，内存稳定
 * - UI 页面按需拉取快照进行渲染
 * - 支持多个数据系列
 */
export class MultiSeriesBarFeed {
  private static instance: MultiSeriesBarFeed | null = null

  static getInstance(): MultiSeriesBarFeed {
    if (!MultiSeriesBarFeed.instance) {
      MultiSeriesBarFeed.instance = new MultiSeriesBarFeed()
    }
    return MultiSeriesBarFeed.instance!
  }

  private readonly MAX_POINTS: number = 60
  
  // 多个系列的数据缓冲区
  private seriesData: InternalSeriesData[] = []
  
  private labelBuf: string[] = new Array(this.MAX_POINTS).fill('')
  private writeIndex: number = 0
  private validCount: number = 0
  private started: boolean = false

  constructor() {
    // 初始化系列数据
    this.seriesData = [
      { name: '直接访问', color: '#5470c6', dataBuf: new Array(this.MAX_POINTS).fill(0), currentValue: 200 },
      { name: '邮件营销', color: '#91cc75', dataBuf: new Array(this.MAX_POINTS).fill(0), currentValue: 150 },
      { name: '联盟广告', color: '#fac858', dataBuf: new Array(this.MAX_POINTS).fill(0), currentValue: 100 },
      { name: '视频广告', color: '#ee6666', dataBuf: new Array(this.MAX_POINTS).fill(0), currentValue: 70 }
    ]
  }

  start(): void {
    if (this.started) { return }
    this.started = true
    hilog.info(DOMAIN, 'MultiSeriesBarFeed', 'started')
  }

  stop(): void {
    this.started = false
    hilog.info(DOMAIN, 'MultiSeriesBarFeed', 'stopped')
  }

  push(label: string, values: number[]): void {
    for (let i = 0; i < this.seriesData.length; i++) {
      const v = (i < values.length) ? values[i] : 0
      this.seriesData[i].currentValue = v
      this.seriesData[i].dataBuf[this.writeIndex] = v
    }
    this.labelBuf[this.writeIndex] = label
    this.writeIndex = (this.writeIndex + 1) % this.MAX_POINTS
    this.validCount = Math.min(this.validCount + 1, this.MAX_POINTS)
  }

  getSnapshot(): MultiSeriesBarSnapshot {
    const categories: string[] = []
    const series: SeriesData[] = []
    
    // 初始化系列数组
    for (let i = 0; i < this.seriesData.length; i++) {
      series.push({
        name: this.seriesData[i].name,
        color: this.seriesData[i].color,
        data: []
      })
    }
    
    // 导出线性窗口
    const len = this.validCount
    for (let i = 0; i < len; i++) {
      const idx = (this.writeIndex - len + i + this.MAX_POINTS) % this.MAX_POINTS
      categories.push(this.labelBuf[idx])
      this.seriesData.forEach((s, seriesIndex) => {
        series[seriesIndex].data.push(s.dataBuf[idx])
      })
    }
    
    const snapshot: MultiSeriesBarSnapshot = {
      categories: categories,
      series: series
    }
    return snapshot
  }
}

