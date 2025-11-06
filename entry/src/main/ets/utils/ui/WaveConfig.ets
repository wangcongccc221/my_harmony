/**
 * 波浪动画配置管理器
 * 功能：统一管理波浪图参数和计算逻辑
 * 用途：提供标准化的波浪图配置和计算
 */

/**
 * 波浪配置接口
 */
export interface WaveConfig {
  heightPercent: number
  baselinePercent: number
  amplitude: number
  frequency: number
  phase: number
  color: string
}

/**
 * 波浪动画配置管理器
 * 根据卡片ID提供不同的波浪配置
 */
export class WaveConfigManager {
  private static instance: WaveConfigManager
  private configs: Map<number, WaveConfig> = new Map()

  private constructor() {
    this.initializeConfigs()
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): WaveConfigManager {
    if (!WaveConfigManager.instance) {
      WaveConfigManager.instance = new WaveConfigManager()
    }
    return WaveConfigManager.instance
  }

  /**
   * 初始化配置
   */
  private initializeConfigs(): void {
    // 为前20个卡片设置不同的波浪配置
    for (let i = 0; i < 20; i++) {
      const config: WaveConfig = {
        heightPercent: this.getHeightPercent(i),
        baselinePercent: this.getBaselinePercent(i),
        amplitude: this.getAmplitude(i),
        frequency: this.getFrequency(i),
        phase: this.getPhase(i),
        color: this.getColor(i)
      }
      this.configs.set(i, config)
    }
  }

  /**
   * 获取波浪高度百分比
   * @param cardIndex 卡片索引
   */
  private getHeightPercent(cardIndex: number): number {
    // 根据卡片索引返回不同的高度百分比
    // 卡片0: 100%, 卡片1: 30%, 卡片2: 60%
    const heights = [100, 30, 60, 30, 50, 70, 25, 45, 65, 35, 55, 75, 28, 48, 68, 32, 52, 72, 38, 58]
    return heights[cardIndex] || 50
  }

  /**
   * 获取波浪基准位置百分比
   * @param cardIndex 卡片索引
   */
  private getBaselinePercent(cardIndex: number): number {
    // 根据卡片索引返回不同的基准位置百分比
    // 第三个卡片基准位置调低，让60%高度能正确显示
    const baselines = [20, 40, 30, 30, 50, 70, 25, 45, 65, 35, 55, 75, 28, 48, 68, 32, 52, 72, 38, 58]
    return baselines[cardIndex] || 50
  }

  /**
   * 获取波浪振幅
   * @param cardIndex 卡片索引
   */
  private getAmplitude(cardIndex: number): number {
    // 所有卡片统一振幅5
    return 5
  }

  /**
   * 获取波浪频率
   * @param cardIndex 卡片索引
   */
  private getFrequency(cardIndex: number): number {
    // 所有卡片统一频率0.03
    return 0.03
  }

  /**
   * 获取波浪相位
   * @param cardIndex 卡片索引
   */
  private getPhase(cardIndex: number): number {
    // 所有卡片统一相位1.5
    return 1.5
  }

  /**
   * 获取波浪颜色
   * @param cardIndex 卡片索引
   */
  private getColor(cardIndex: number): string {
    // 根据卡片索引返回不同的颜色
    const colors = [
      '#4CAF50', '#2196F3', '#FF9800', '#9C27B0', '#F44336',
      '#00BCD4', '#8BC34A', '#FF5722', '#3F51B5', '#E91E63',
      '#009688', '#FFC107', '#795548', '#607D8B', '#FFEB3B',
      '#9E9E9E', '#CDDC39', '#FF4081', '#00E676', '#FF3D00'
    ]
    return colors[cardIndex] || '#2196F3'
  }

  /**
   * 获取卡片波浪配置
   * @param cardIndex 卡片索引
   */
  public getWaveConfig(cardIndex: number): WaveConfig {
    return this.configs.get(cardIndex) || this.getDefaultConfig()
  }

  /**
   * 获取默认配置
   */
  private getDefaultConfig(): WaveConfig {
    return {
      heightPercent: 50,
      baselinePercent: 50,
      amplitude: 5,
      frequency: 0.03,
      phase: 1.5,
      color: '#2196F3'
    }
  }

  /**
   * 计算波浪高度
   * @param cardIndex 卡片索引
   * @param containerHeight 容器高度
   */
  public calculateWaveHeight(cardIndex: number, containerHeight: number): number {
    const config = this.getWaveConfig(cardIndex)
    return containerHeight * (config.heightPercent / 100)
  }

  /**
   * 计算波浪基准位置
   * @param cardIndex 卡片索引
   * @param containerHeight 容器高度
   */
  public calculateWaveBaseline(cardIndex: number, containerHeight: number): number {
    const config = this.getWaveConfig(cardIndex)
    return containerHeight * (config.baselinePercent / 100)
  }

  /**
   * 计算波浪中心Y坐标
   * @param cardIndex 卡片索引
   * @param containerHeight 容器高度
   */
  public calculateWaveCenterY(cardIndex: number, containerHeight: number): number {
    const config = this.getWaveConfig(cardIndex)
    const waveHeight = this.calculateWaveHeight(cardIndex, containerHeight)
    return containerHeight - (waveHeight * (config.baselinePercent / 100))
  }

  /**
   * 更新卡片配置
   * @param cardIndex 卡片索引
   * @param config 新配置
   */
  public updateWaveConfig(cardIndex: number, config: Partial<WaveConfig>): void {
    const currentConfig = this.getWaveConfig(cardIndex)
    const newConfig: WaveConfig = {
      heightPercent: config.heightPercent ?? currentConfig.heightPercent,
      baselinePercent: config.baselinePercent ?? currentConfig.baselinePercent,
      amplitude: config.amplitude ?? currentConfig.amplitude,
      frequency: config.frequency ?? currentConfig.frequency,
      phase: config.phase ?? currentConfig.phase,
      color: config.color ?? currentConfig.color
    }
    this.configs.set(cardIndex, newConfig)
  }

  /**
   * 重置所有配置
   */
  public resetConfigs(): void {
    this.configs.clear()
    this.initializeConfigs()
  }

  /**
   * 获取所有配置
   */
  public getAllConfigs(): Map<number, WaveConfig> {
    return new Map(this.configs)
  }
}

