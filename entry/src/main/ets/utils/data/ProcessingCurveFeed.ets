import { hilog } from '@kit.PerformanceAnalysisKit'

const DOMAIN = 0x0000

export interface CurveSnapshot {
  data: number[]
  labels: string[]
  writeIndex: number
  validCount: number
  timeIndex: number
  currentValue: number
}

/**
 * 全局折线图数据源（单例）
 * - 在后台持续生成模拟数据（每秒1点）
 * - 使用固定长度环形缓冲区，内存稳定
 * - UI 页面按需拉取快照进行渲染
 */
export class ProcessingCurveFeed {
  private static instance: ProcessingCurveFeed | null = null

  static getInstance(): ProcessingCurveFeed {
    if (!ProcessingCurveFeed.instance) {
      ProcessingCurveFeed.instance = new ProcessingCurveFeed()
    }
    return ProcessingCurveFeed.instance!
  }

  private readonly MAX_POINTS: number = 60
  private dataBuf: number[] = new Array(this.MAX_POINTS).fill(0)
  private labelBuf: string[] = new Array(this.MAX_POINTS).fill('')
  private writeIndex: number = 0
  private validCount: number = 0
  private timeIndex: number = 0
  private currentValue: number = 50
  private started: boolean = false

  start(): void {
    if (this.started) { return }
    this.started = true
    hilog.info(DOMAIN, 'ProcessingCurveFeed', 'started')
  }

  stop(): void {
    this.started = false
    hilog.info(DOMAIN, 'ProcessingCurveFeed', 'stopped')
  }

  append(value: number, label: string): void {
    this.currentValue = value
    this.dataBuf[this.writeIndex] = value
    this.labelBuf[this.writeIndex] = label
    this.writeIndex = (this.writeIndex + 1) % this.MAX_POINTS
    this.validCount = Math.min(this.validCount + 1, this.MAX_POINTS)
    this.timeIndex++
  }

  // 复用数组对象，避免频繁创建新数组
  private snapshotData: number[] = new Array(this.MAX_POINTS)
  private snapshotLabels: string[] = new Array(this.MAX_POINTS)

  getSnapshot(): CurveSnapshot {
    // 导出环形缓冲区为线性序列（最新窗口）
    // 复用已有数组，避免频繁创建新数组导致内存累积
    const len = this.validCount
    // 如果数组长度不够，才重新创建（通常不会发生）
    if (this.snapshotData.length < len) {
      this.snapshotData = new Array(len)
      this.snapshotLabels = new Array(len)
    }
    for (let i = 0; i < len; i++) {
      const idx = (this.writeIndex - len + i + this.MAX_POINTS) % this.MAX_POINTS
      this.snapshotData[i] = this.dataBuf[idx]
      this.snapshotLabels[i] = this.labelBuf[idx]
    }
    // 返回切片引用（只读），避免创建新数组
    return {
      data: this.snapshotData.slice(0, len),
      labels: this.snapshotLabels.slice(0, len),
      writeIndex: this.writeIndex,
      validCount: this.validCount,
      timeIndex: this.timeIndex,
      currentValue: this.currentValue
    }
  }
}


