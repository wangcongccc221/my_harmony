import { hilog } from '@kit.PerformanceAnalysisKit'

const DOMAIN = 0x0000

export interface BarData { time: string, value: number }

export class ProcessingBarFeed {
  private static instance: ProcessingBarFeed | null = null
  static getInstance(): ProcessingBarFeed {
    if (!ProcessingBarFeed.instance) {
      ProcessingBarFeed.instance = new ProcessingBarFeed()
    }
    return ProcessingBarFeed.instance!
  }

  private readonly MAX_POINTS: number = 60
  // 固定长度环形缓冲区（避免数组增长和切片复制）
  private valueBuf: number[] = new Array(this.MAX_POINTS).fill(0)
  private labelBuf: string[] = new Array(this.MAX_POINTS).fill('')
  private writeIndex: number = 0
  private validCount: number = 0
  private timerId?: number
  private started: boolean = false
  private currentValue: number = 50
  private timeIndex: number = 0

  start(): void {
    if (this.started) { return }
    this.started = true
    if (this.validCount === 0) {
      // 播种10个点（9:00开始，每分钟一个）
      for (let i = 0; i < 10; i++) { this.pushNext() }
    }
    this.timerId = setInterval(() => this.pushNext(), 1000) as number
    hilog.info(DOMAIN, 'ProcessingBarFeed', 'started')
  }

  stop(): void {
    if (this.timerId) { clearInterval(this.timerId); this.timerId = undefined }
    this.started = false
    hilog.info(DOMAIN, 'ProcessingBarFeed', 'stopped')
  }

  private pushNext(): void {
    const startHour = 9
    const startMinute = 0
    const totalMin = startMinute + this.timeIndex
    const h = startHour + Math.floor(totalMin / 60)
    const m = totalMin % 60
    const label = `${h.toString().padStart(2,'0')}:${m.toString().padStart(2,'0')}`
    const step = (Math.random() * 10) - 5
    this.currentValue = Math.max(10, Math.min(100, Math.round(this.currentValue + step)))
    // 写入环形缓冲区
    this.valueBuf[this.writeIndex] = this.currentValue
    this.labelBuf[this.writeIndex] = label
    this.writeIndex = (this.writeIndex + 1) % this.MAX_POINTS
    this.validCount = Math.min(this.validCount + 1, this.MAX_POINTS)
    this.timeIndex++
  }

  getSnapshot(): BarData[] {
    // 导出线性窗口
    const len = this.validCount
    const out: BarData[] = new Array(len)
    for (let i = 0; i < len; i++) {
      const idx = (this.writeIndex - len + i + this.MAX_POINTS) % this.MAX_POINTS
      out[i] = { time: this.labelBuf[idx], value: this.valueBuf[idx] }
    }
    return out
  }
}


