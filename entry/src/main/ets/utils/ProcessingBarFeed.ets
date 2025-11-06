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
  private data: BarData[] = []
  private timerId?: number
  private started: boolean = false
  private currentValue: number = 50
  private timeIndex: number = 0

  start(): void {
    if (this.started) { return }
    this.started = true
    if (this.data.length === 0) {
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
    this.data.push({ time: label, value: this.currentValue })
    if (this.data.length > this.MAX_POINTS) { this.data = this.data.slice(this.data.length - this.MAX_POINTS) }
    this.timeIndex++
  }

  getSnapshot(): BarData[] { return this.data.slice() }
}


