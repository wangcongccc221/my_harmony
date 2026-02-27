/**
 * 实时统计服务
 * 对齐 48 项目思路：
 * - 5 秒计算一次效率/实时产量
 * - 1 分钟落一条曲线点（内存环形缓冲）
 * - 对外提供统一快照与订阅能力
 */

import { getGlobalDataInterface, GlobalDataInterface, StatisticsListener } from './GlobalDataInterface'
import { StStatistics } from './Structures'
import { ConstPreDefine } from './ConstPreDefine'

export interface RealtimeCurvePoint {
  timestamp: number
  label: string
  separationEfficiency: number
  realWeightCountPer: number
  realWeightCountTonH: number
  avgWeightG: number
}

export interface RealtimeStatsSnapshot {
  selectedSubsystem: string
  totalYield: number
  totalWeight: number
  totalCupNum: number
  avgWeightG: number
  speedPerMinute: number
  separationEfficiency: number
  realWeightCountTonH: number
  realWeightCountPer: number
  gradeCount: number[]
  gradeWeight: number[]
  boxGradeCount: number[]
  exitCount: number[]
  exitWeight: number[]
}

interface AggregateTotals {
  totalYield: number
  totalWeight: number
  totalCupNum: number
  speedSum: number
  speedValidCount: number
  gradeCount: number[]
  gradeWeight: number[]
  boxGradeCount: number[]
  exitCount: number[]
  exitWeight: number[]
}

interface CalcMetrics {
  separationEfficiency: number
  realWeightCountTonH: number
  realWeightCountPer: number
  avgWeightG: number
}

interface PrevTotals {
  totalYield: number
  totalWeight: number
  totalCupNum: number
}

interface CurveSeries {
  labels: string[]
  efficiency: number[]
  output: number[]
}

interface AggregateCollection {
  all: AggregateTotals
  subsys: Map<number, AggregateTotals>
}

export type RealtimeStatsListener = () => void

const DEFAULT_SCOPE = 'ALL'
const TIMER_INTERVAL_MS = 5000
const MAX_CURVE_POINTS = 120

export class RealtimeStatsService {
  private static instance: RealtimeStatsService | null = null

  private readonly dataInterface: GlobalDataInterface = getGlobalDataInterface()
  private readonly listeners: Set<RealtimeStatsListener> = new Set()
  private readonly statsListener: StatisticsListener

  private timerId: number = -1
  private lastCalcTs: number = 0

  private prevTotalsByScope: Map<string, PrevTotals> = new Map()
  private latestMetricsByScope: Map<string, CalcMetrics> = new Map()
  private maxOutputTonHByScope: Map<string, number> = new Map()
  private curveByScope: Map<string, RealtimeCurvePoint[]> = new Map()

  static getInstance(): RealtimeStatsService {
    if (!RealtimeStatsService.instance) {
      RealtimeStatsService.instance = new RealtimeStatsService()
    }
    return RealtimeStatsService.instance
  }

  private constructor() {
    this.statsListener = (_stats: StStatistics): void => {
      // 收包后立即通知，保障表格/柱图能实时刷新
      this.notifyListeners()
    }
    this.dataInterface.addStatisticsListener(this.statsListener)
  }

  subscribe(listener: RealtimeStatsListener): void {
    this.listeners.add(listener)
    this.ensureTimerStarted()
  }

  unsubscribe(listener: RealtimeStatsListener): void {
    this.listeners.delete(listener)
  }

  getSnapshot(selectedSubsystem: string): RealtimeStatsSnapshot {
    const scope = this.normalizeScope(selectedSubsystem)
    const allAgg = this.collectAggregates()
    const agg = this.pickAggregate(scope, allAgg)
    const metrics = this.latestMetricsByScope.get(scope) ?? this.createDefaultMetrics(agg)

    return {
      selectedSubsystem: scope,
      totalYield: agg.totalYield,
      totalWeight: agg.totalWeight,
      totalCupNum: agg.totalCupNum,
      avgWeightG: agg.totalYield > 0 ? agg.totalWeight / agg.totalYield : 0,
      speedPerMinute: agg.speedValidCount > 0 ? (agg.speedSum / agg.speedValidCount) : 0,
      separationEfficiency: metrics.separationEfficiency,
      realWeightCountTonH: metrics.realWeightCountTonH,
      realWeightCountPer: metrics.realWeightCountPer,
      gradeCount: agg.gradeCount.slice(),
      gradeWeight: agg.gradeWeight.slice(),
      boxGradeCount: agg.boxGradeCount.slice(),
      exitCount: agg.exitCount.slice(),
      exitWeight: agg.exitWeight.slice()
    }
  }

  getCurveSeries(selectedSubsystem: string, minutes: number = 30): CurveSeries {
    const scope = this.normalizeScope(selectedSubsystem)
    const safeMinutes = Math.max(1, Math.min(120, minutes))
    const points = this.curveByScope.get(scope) ?? []
    const pointMap: Map<number, RealtimeCurvePoint> = new Map()
    for (let i = 0; i < points.length; i++) {
      pointMap.set(points[i].timestamp, points[i])
    }

    const now = Date.now()
    const nowMinuteTs = now - (now % 60000)

    const labels: string[] = []
    const efficiency: number[] = []
    const output: number[] = []

    for (let i = safeMinutes - 1; i >= 0; i--) {
      const ts = nowMinuteTs - i * 60000
      const p = pointMap.get(ts)
      labels.push(this.toMinuteLabel(ts))
      efficiency.push(p ? p.separationEfficiency : 0)
      output.push(p ? p.realWeightCountPer : 0)
    }

    const series: CurveSeries = {
      labels: labels,
      efficiency: efficiency,
      output: output
    }
    return series
  }

  private ensureTimerStarted(): void {
    if (this.timerId >= 0) {
      return
    }
    this.lastCalcTs = Date.now()
    this.timerId = setInterval((): void => {
      this.calculateTick()
    }, TIMER_INTERVAL_MS)
  }

  private calculateTick(): void {
    const now = Date.now()
    let deltaSec = 5
    if (this.lastCalcTs > 0) {
      deltaSec = (now - this.lastCalcTs) / 1000
      if (deltaSec < 1) {
        deltaSec = 1
      }
    }
    this.lastCalcTs = now

    const allAgg: AggregateCollection = this.collectAggregates()
    const scopes: string[] = [DEFAULT_SCOPE]
    allAgg.subsys.forEach((_v: AggregateTotals, k: number) => {
      scopes.push(k.toString())
    })

    for (let i = 0; i < scopes.length; i++) {
      const scope = scopes[i]
      const agg = this.pickAggregate(scope, allAgg)
      const prev = this.prevTotalsByScope.get(scope) ?? this.createPrevTotals(agg.totalYield, agg.totalWeight, agg.totalCupNum)
      const metrics = this.calcMetrics(scope, agg, prev, deltaSec)
      this.latestMetricsByScope.set(scope, metrics)
      this.prevTotalsByScope.set(scope, this.createPrevTotals(agg.totalYield, agg.totalWeight, agg.totalCupNum))
      this.upsertMinutePoint(scope, now, metrics)
    }

    this.notifyListeners()
  }

  private calcMetrics(scope: string, nowAgg: AggregateTotals, prevAgg: PrevTotals, deltaSec: number): CalcMetrics {
    const deltaYield = Math.max(0, nowAgg.totalYield - prevAgg.totalYield)
    const deltaWeight = Math.max(0, nowAgg.totalWeight - prevAgg.totalWeight)
    const deltaCup = Math.max(0, nowAgg.totalCupNum - prevAgg.totalCupNum)

    let separationEfficiency = 0
    if (deltaCup > 0) {
      separationEfficiency = this.clamp((deltaYield * 100.0) / deltaCup, 0, 100)
    }

    const realWeightCountTonH = (deltaWeight / 1000000.0) * (3600.0 / deltaSec)
    const maxOutput = Math.max(this.maxOutputTonHByScope.get(scope) ?? 0, realWeightCountTonH, 0.01)
    this.maxOutputTonHByScope.set(scope, maxOutput)
    const realWeightCountPer = this.clamp((realWeightCountTonH / maxOutput) * 100.0, 0, 100)

    const avgWeightG = nowAgg.totalYield > 0 ? (nowAgg.totalWeight / nowAgg.totalYield) : 0

    return {
      separationEfficiency,
      realWeightCountTonH,
      realWeightCountPer,
      avgWeightG
    }
  }

  private upsertMinutePoint(scope: string, now: number, metrics: CalcMetrics): void {
    const minuteTs = now - (now % 60000)
    const points = this.curveByScope.get(scope) ?? []
    const last = points.length > 0 ? points[points.length - 1] : null

    // 填补缺口分钟，避免曲线断层
    if (last && minuteTs - last.timestamp > 60000) {
      let fillTs = last.timestamp + 60000
      while (fillTs < minuteTs) {
        points.push({
          timestamp: fillTs,
          label: this.toMinuteLabel(fillTs),
          separationEfficiency: 0,
          realWeightCountPer: 0,
          realWeightCountTonH: 0,
          avgWeightG: 0
        })
        fillTs += 60000
      }
    }

    const point: RealtimeCurvePoint = {
      timestamp: minuteTs,
      label: this.toMinuteLabel(minuteTs),
      separationEfficiency: metrics.separationEfficiency,
      realWeightCountPer: metrics.realWeightCountPer,
      realWeightCountTonH: metrics.realWeightCountTonH,
      avgWeightG: metrics.avgWeightG
    }

    if (last && last.timestamp === minuteTs) {
      points[points.length - 1] = point
    } else {
      points.push(point)
    }

    while (points.length > MAX_CURVE_POINTS) {
      points.shift()
    }

    this.curveByScope.set(scope, points)
  }

  private collectAggregates(): AggregateCollection {
    const all = this.createEmptyAggregate()
    const subsysMap: Map<number, AggregateTotals> = new Map()

    const statsMap = this.dataInterface.getAllChannelStatistics()
    statsMap.forEach((stats: StStatistics) => {
      const subsysId = this.normalizeSubsysId(stats.nSubsysId)
      const subsysAgg = subsysMap.get(subsysId) ?? this.createEmptyAggregate()
      this.accumulateStats(all, stats)
      this.accumulateStats(subsysAgg, stats)
      subsysMap.set(subsysId, subsysAgg)
    })

    const collection: AggregateCollection = {
      all: all,
      subsys: subsysMap
    }
    return collection
  }

  private pickAggregate(scope: string, data: AggregateCollection): AggregateTotals {
    if (scope === DEFAULT_SCOPE) {
      return data.all
    }
    const subsys = Number(scope)
    return data.subsys.get(subsys) ?? this.createEmptyAggregate()
  }

  private accumulateStats(target: AggregateTotals, stats: StStatistics): void {
    target.totalYield += Number(stats.nYield)
    target.totalWeight += Number(stats.nTotalWeight)
    target.totalCupNum += Number(stats.nTotalCupNum)

    const speed = Number(stats.nIntervalSumperminute)
    if (speed > 0) {
      target.speedSum += speed
      target.speedValidCount += 1
    }

    this.accumulateArray(target.gradeCount, stats.nGradeCount)
    this.accumulateArray(target.gradeWeight, stats.nWeightGradeCount)
    this.accumulateArray(target.boxGradeCount, stats.nBoxGradeCount)

    const hasExitCount = this.hasAnyPositive(stats.nExitCount)
    const hasExitWeight = this.hasAnyPositive(stats.nExitWeightCount)
    if (hasExitCount) {
      this.accumulateArray(target.exitCount, stats.nExitCount)
    } else {
      this.accumulateArray(target.exitCount, stats.ExitBoxNum)
    }
    if (hasExitWeight) {
      this.accumulateArray(target.exitWeight, stats.nExitWeightCount)
    } else {
      this.accumulateArray(target.exitWeight, stats.ExitWeight)
    }
  }

  private hasAnyPositive(arr: ArrayLike<number>): boolean {
    for (let i = 0; i < arr.length; i++) {
      if (Number(arr[i]) > 0) {
        return true
      }
    }
    return false
  }

  private accumulateArray(target: number[], src: ArrayLike<number>): void {
    const len = Math.min(target.length, src.length)
    for (let i = 0; i < len; i++) {
      target[i] += Number(src[i])
    }
  }

  private createEmptyAggregate(): AggregateTotals {
    return {
      totalYield: 0,
      totalWeight: 0,
      totalCupNum: 0,
      speedSum: 0,
      speedValidCount: 0,
      gradeCount: new Array(ConstPreDefine.MAX_QUALITY_GRADE_NUM * ConstPreDefine.MAX_SIZE_GRADE_NUM).fill(0),
      gradeWeight: new Array(ConstPreDefine.MAX_QUALITY_GRADE_NUM * ConstPreDefine.MAX_SIZE_GRADE_NUM).fill(0),
      boxGradeCount: new Array(ConstPreDefine.MAX_QUALITY_GRADE_NUM * ConstPreDefine.MAX_SIZE_GRADE_NUM).fill(0),
      exitCount: new Array(ConstPreDefine.MAX_EXIT_NUM).fill(0),
      exitWeight: new Array(ConstPreDefine.MAX_EXIT_NUM).fill(0)
    }
  }

  private createPrevTotals(totalYield: number, totalWeight: number, totalCupNum: number): PrevTotals {
    const totals: PrevTotals = {
      totalYield: totalYield,
      totalWeight: totalWeight,
      totalCupNum: totalCupNum
    }
    return totals
  }

  private createDefaultMetrics(agg: AggregateTotals): CalcMetrics {
    return {
      separationEfficiency: 0,
      realWeightCountTonH: 0,
      realWeightCountPer: 0,
      avgWeightG: agg.totalYield > 0 ? (agg.totalWeight / agg.totalYield) : 0
    }
  }

  private normalizeSubsysId(raw: number): number {
    if (raw > 0) {
      return raw
    }
    return 1
  }

  private normalizeScope(scope: string): string {
    if (scope === '1' || scope === '2' || scope === '3' || scope === '4') {
      return scope
    }
    return DEFAULT_SCOPE
  }

  private clamp(v: number, min: number, max: number): number {
    if (v < min) {
      return min
    }
    if (v > max) {
      return max
    }
    return v
  }

  private toMinuteLabel(ts: number): string {
    const d = new Date(ts)
    const hh = String(d.getHours()).padStart(2, '0')
    const mm = String(d.getMinutes()).padStart(2, '0')
    return `${hh}:${mm}`
  }

  private notifyListeners(): void {
    this.listeners.forEach((listener: RealtimeStatsListener) => {
      try {
        listener()
      } catch (_e) {}
    })
  }
}

export function getRealtimeStatsService(): RealtimeStatsService {
  return RealtimeStatsService.getInstance()
}
