/**
 * 实时统计服务
 * 对齐 48 项目思路：
 * - 5 秒计算一次效率/实时产量
 * - 1 分钟落一条曲线点（内存环形缓冲）
 * - 对外提供统一快照与订阅能力
 */

import { getGlobalDataInterface, GlobalDataInterface, StatisticsListener } from './GlobalDataInterface'
import { StStatistics, StGradeInfo, StGradeItemInfo } from './Structures'
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

export interface FeatureDistribution {
  categories: string[]
  count: number[]
  weight: number[]
}

export type RatioMode = 'batch' | 'realtime'

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
  private ratioMode: RatioMode = 'batch'
  private ratioBaselineByScope: Map<string, AggregateTotals> = new Map()

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

  setRatioModeBatch(): void {
    this.ratioMode = 'batch'
    this.notifyListeners()
  }

  setRatioModeRealtime(selectedSubsystem: string): void {
    const scope = this.normalizeScope(selectedSubsystem)
    this.ratioMode = 'realtime'
    const allAgg: AggregateCollection = this.collectAggregates()
    const agg = this.pickAggregate(scope, allAgg)
    this.ratioBaselineByScope.set(scope, this.cloneAggregate(agg))
    this.notifyListeners()
  }

  getRatioMode(): RatioMode {
    return this.ratioMode
  }

  getSnapshot(selectedSubsystem: string): RealtimeStatsSnapshot {
    const scope = this.normalizeScope(selectedSubsystem)
    const allAgg = this.collectAggregates()
    const aggRaw = this.pickAggregate(scope, allAgg)
    const agg = this.applyRatioMode(scope, aggRaw)
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

  getAppearanceDistribution(selectedSubsystem: string, selectedType: string): FeatureDistribution {
    const scope = this.normalizeScope(selectedSubsystem)
    if (selectedType === '颜色') {
      return this.buildFeatureDistribution(scope, 'color')
    }
    if (selectedType === '形状') {
      return this.buildFeatureDistribution(scope, 'shape')
    }
    if (selectedType === '缺陷等级') {
      return this.buildFeatureDistribution(scope, 'flaw')
    }
    // “全部”按 48 更接近的做法：默认展示颜色分布
    return this.buildFeatureDistribution(scope, 'color')
  }

  getInternalDistribution(selectedSubsystem: string, selectedType: string): FeatureDistribution {
    const scope = this.normalizeScope(selectedSubsystem)
    if (selectedType === '糖度') {
      return this.buildFeatureDistribution(scope, 'sugar')
    }
    if (selectedType === '酸度') {
      return this.buildFeatureDistribution(scope, 'acidity')
    }
    if (selectedType === '硬度') {
      return this.buildFeatureDistribution(scope, 'rigidity')
    }
    if (selectedType === '可溶性固形物') {
      return this.buildFeatureDistribution(scope, 'density')
    }
    // “全部”按 48 更接近的做法：默认展示糖度分布
    return this.buildFeatureDistribution(scope, 'sugar')
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

  private buildFeatureDistribution(scope: string, feature: string): FeatureDistribution {
    const allAgg: AggregateCollection = this.collectAggregates()
    const aggRaw: AggregateTotals = this.pickAggregate(scope, allAgg)
    const agg: AggregateTotals = this.applyRatioMode(scope, aggRaw)
    const gradeInfo: StGradeInfo | null = this.dataInterface.getLatestGradeInfo()
    if (!gradeInfo) {
      return this.buildFallbackDistribution(agg, feature)
    }

    const names = this.resolveFeatureNames(gradeInfo, feature)
    const count: number[] = new Array<number>(names.length).fill(0)
    const weight: number[] = new Array<number>(names.length).fill(0)

    const maxGrade = Math.min(gradeInfo.grades.length, agg.gradeCount.length, agg.gradeWeight.length)
    for (let idx = 0; idx < maxGrade; idx++) {
      const item: StGradeItemInfo = gradeInfo.grades[idx]
      const featureLevel = this.getFeatureLevel(item, feature)
      if (featureLevel < 0 || featureLevel >= names.length) {
        continue
      }
      count[featureLevel] += Number(agg.gradeCount[idx] ?? 0)
      weight[featureLevel] += Number(agg.gradeWeight[idx] ?? 0)
    }

    const distribution: FeatureDistribution = {
      categories: names,
      count: count,
      weight: weight
    }
    return distribution
  }

  private buildFallbackDistribution(agg: AggregateTotals, feature: string): FeatureDistribution {
    const fallbackSize = this.getFeatureFallbackSize(feature)
    const categories: string[] = []
    const count: number[] = new Array(fallbackSize).fill(0)
    const weight: number[] = new Array(fallbackSize).fill(0)
    for (let i = 0; i < fallbackSize; i++) {
      categories.push(`等级${i + 1}`)
      count[i] = Number(agg.gradeCount[i] ?? 0)
      weight[i] = Number(agg.gradeWeight[i] ?? 0)
    }
    const distribution: FeatureDistribution = {
      categories: categories,
      count: count,
      weight: weight
    }
    return distribution
  }

  private getFeatureFallbackSize(feature: string): number {
    if (feature === 'color') return ConstPreDefine.MAX_COLOR_GRADE_NUM
    if (feature === 'shape') return ConstPreDefine.MAX_SHAPE_GRADE_NUM
    if (feature === 'flaw') return ConstPreDefine.MAX_FlAWAREA_GRADE_NUM
    if (feature === 'sugar') return ConstPreDefine.MAX_SUGAR_GRADE_NUM
    if (feature === 'acidity') return ConstPreDefine.MAX_ACIDITY_GRADE_NUM
    if (feature === 'rigidity') return ConstPreDefine.MAX_RIGIDITY_GRADE_NUM
    if (feature === 'density') return ConstPreDefine.MAX_DENSITY_GRADE_NUM
    return 6
  }

  private getFeatureLevel(item: StGradeItemInfo, feature: string): number {
    let v = -1
    if (feature === 'color') v = item.nColorGrade
    else if (feature === 'shape') v = item.sbShapeSize
    else if (feature === 'flaw') v = item.sbFlawArea
    else if (feature === 'sugar') v = item.sbSugar
    else if (feature === 'acidity') v = item.sbAcidity
    else if (feature === 'rigidity') v = item.sbRigidity
    else if (feature === 'density') v = item.sbDensity

    // 48 中 0x7f 表示无效
    if (v === 0x7f || v < 0) {
      return -1
    }
    return v
  }

  private resolveFeatureNames(gradeInfo: StGradeInfo, feature: string): string[] {
    if (feature === 'color') return this.decodeNames(gradeInfo.strColorGradeName, ConstPreDefine.MAX_COLOR_GRADE_NUM, '颜色')
    if (feature === 'shape') return this.decodeNames(gradeInfo.strShapeGradeName, ConstPreDefine.MAX_SHAPE_GRADE_NUM, '形状')
    if (feature === 'flaw') return this.decodeNames(gradeInfo.stFlawareaGradeName, ConstPreDefine.MAX_FlAWAREA_GRADE_NUM, '瑕疵')
    if (feature === 'sugar') return this.decodeNames(gradeInfo.stSugarGradeName, ConstPreDefine.MAX_SUGAR_GRADE_NUM, '糖度')
    if (feature === 'acidity') return this.decodeNames(gradeInfo.stAcidityGradeName, ConstPreDefine.MAX_ACIDITY_GRADE_NUM, '酸度')
    if (feature === 'rigidity') return this.decodeNames(gradeInfo.stRigidityGradeName, ConstPreDefine.MAX_RIGIDITY_GRADE_NUM, '硬度')
    if (feature === 'density') return this.decodeNames(gradeInfo.stDensityGradeName, ConstPreDefine.MAX_DENSITY_GRADE_NUM, '固形物')
    return this.decodeNames(gradeInfo.strQualityGradeName, ConstPreDefine.MAX_QUALITY_GRADE_NUM, '等级')
  }

  private decodeNames(bytes: Uint8Array, itemCount: number, prefix: string): string[] {
    const names: string[] = []
    const itemLen = ConstPreDefine.MAX_TEXT_LENGTH
    for (let i = 0; i < itemCount; i++) {
      const start = i * itemLen
      if (start >= bytes.length) {
        break
      }
      let end = start
      while (end < start + itemLen && end < bytes.length && bytes[end] !== 0) {
        end++
      }
      let text = ''
      for (let j = start; j < end; j++) {
        const code = bytes[j]
        if (code >= 32 && code <= 126) {
          text += String.fromCharCode(code)
        }
      }
      if (!text) {
        text = `${prefix}${i + 1}`
      }
      names.push(text)
    }
    if (names.length === 0) {
      for (let i = 0; i < itemCount; i++) {
        names.push(`${prefix}${i + 1}`)
      }
    }
    return names
  }

  private pickAggregate(scope: string, data: AggregateCollection): AggregateTotals {
    if (scope === DEFAULT_SCOPE) {
      return data.all
    }
    const subsys = Number(scope)
    return data.subsys.get(subsys) ?? this.createEmptyAggregate()
  }

  private applyRatioMode(scope: string, current: AggregateTotals): AggregateTotals {
    if (this.ratioMode !== 'realtime') {
      return current
    }
    const baseline = this.ratioBaselineByScope.get(scope)
    if (!baseline) {
      return current
    }
    return this.diffAggregate(current, baseline)
  }

  private diffAggregate(current: AggregateTotals, baseline: AggregateTotals): AggregateTotals {
    const out = this.createEmptyAggregate()
    out.totalYield = Math.max(0, current.totalYield - baseline.totalYield)
    out.totalWeight = Math.max(0, current.totalWeight - baseline.totalWeight)
    out.totalCupNum = Math.max(0, current.totalCupNum - baseline.totalCupNum)
    out.speedSum = current.speedSum
    out.speedValidCount = current.speedValidCount
    this.diffArray(out.gradeCount, current.gradeCount, baseline.gradeCount)
    this.diffArray(out.gradeWeight, current.gradeWeight, baseline.gradeWeight)
    this.diffArray(out.boxGradeCount, current.boxGradeCount, baseline.boxGradeCount)
    this.diffArray(out.exitCount, current.exitCount, baseline.exitCount)
    this.diffArray(out.exitWeight, current.exitWeight, baseline.exitWeight)
    return out
  }

  private diffArray(out: number[], current: number[], baseline: number[]): void {
    const len = Math.min(out.length, current.length, baseline.length)
    for (let i = 0; i < len; i++) {
      const v = current[i] - baseline[i]
      out[i] = v > 0 ? v : 0
    }
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

  private cloneAggregate(src: AggregateTotals): AggregateTotals {
    const out = this.createEmptyAggregate()
    out.totalYield = src.totalYield
    out.totalWeight = src.totalWeight
    out.totalCupNum = src.totalCupNum
    out.speedSum = src.speedSum
    out.speedValidCount = src.speedValidCount
    this.copyArray(out.gradeCount, src.gradeCount)
    this.copyArray(out.gradeWeight, src.gradeWeight)
    this.copyArray(out.boxGradeCount, src.boxGradeCount)
    this.copyArray(out.exitCount, src.exitCount)
    this.copyArray(out.exitWeight, src.exitWeight)
    return out
  }

  private copyArray(dst: number[], src: number[]): void {
    const len = Math.min(dst.length, src.length)
    for (let i = 0; i < len; i++) {
      dst[i] = src[i]
    }
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
