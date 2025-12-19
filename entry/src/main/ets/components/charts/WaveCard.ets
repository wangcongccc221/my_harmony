import { WavePhaseManager } from '../../utils/ui/WavePhaseManager'
import { StWaveInfo, WAVE_POINT_COUNT } from '../../utils/network/tcp/types/StWaveInfo'

@Component
export struct WaveCard {
  @Prop amplitude: number = 10
  @Prop frequency: number = 0.01
  @Prop speed: number = 0.02
  @Prop waveHeightPercent: number = 70  // 波浪图高度百分比（默认70%）
  @Prop baselinePercent: number = 50    // 波浪基准位置百分比（默认50%，即中间位置）
  @Prop gradientLeft: string = 'rgba(52, 152, 219, 0.7)'
  @Prop gradientMid: string = 'rgba(41, 128, 185, 0.8)'
  @Prop gradientRight: string = 'rgba(52, 152, 219, 0.7)'
  @Prop cardBackground: string | Color = Color.Transparent
  // 真实波形数据（可选，如果提供则使用真实数据，否则使用动画）
  @Prop realWaveData: StWaveInfo | null = null
  @Prop channelId: number = -1  // 通道ID，用于从AppStorage获取波形数据

  // 使用全局相位管理器，所有卡片共享同一个相位（确保同步）
  private phaseManager: WavePhaseManager = WavePhaseManager.getInstance()
  // 使用箭头函数绑定，确保 callback 引用唯一且稳定
  private phaseUpdateCallback: () => void = () => {
    if (this.isVisible && this.canvasWidth > 0 && this.canvasHeight > 0) {
      this.drawWave()
    }
  }
  @State private canvasWidth: number = 0
  @State private canvasHeight: number = 0
  @State private currentWaveData: StWaveInfo | null = null
  @State private canvasKey: number = 0  // 用于强制Canvas重新渲染
  @StorageLink('TCP_WAVEINFO_UPDATE') @Watch('onWaveDataUpdate') private waveInfoUpdate: number = 0

  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private cachedGradient: CanvasGradient | null = null
  private cachedGradientWidth: number = 0  // 缓存渐变对应的宽度
  private areaDebounceId: number = 0
  private isVisible: boolean = false
  private isListenerRegistered: boolean = false

  aboutToAppear() {
    console.log(`[WaveCard] aboutToAppear - channelId: ${this.channelId}`)
    // 加载波形数据
    this.loadWaveData()
    // 启动定时器，定期检查数据更新
    this.startDataCheckTimer()
  }

  aboutToDisappear() {
    // 停止定时器
    this.stopDataCheckTimer()
    // 移除监听器
    if (this.isListenerRegistered) {
      this.phaseManager.removeListener(this.phaseUpdateCallback)
      this.isListenerRegistered = false
    }
    // 清理定时器
    if (this.areaDebounceId) {
      clearTimeout(this.areaDebounceId)
      this.areaDebounceId = 0
    }
    // 清理渐变缓存（释放Native资源）
    this.cachedGradient = null
  }

  private dataCheckTimerId: number = -1

  private startDataCheckTimer() {
    if (this.dataCheckTimerId === -1) {
      this.dataCheckTimerId = setInterval(() => {
        // 定期检查数据更新
        this.loadWaveData()
        if (this.isVisible && this.canvasWidth > 0 && this.canvasHeight > 0) {
          this.drawWave()
        }
      }, 500) as number  // 每500ms检查一次
    }
  }

  private stopDataCheckTimer() {
    if (this.dataCheckTimerId !== -1) {
      clearInterval(this.dataCheckTimerId)
      this.dataCheckTimerId = -1
    }
  }

  onWaveDataUpdate() {
    console.log(`[WaveCard] 波形数据更新 - channelId: ${this.channelId}, waveInfoUpdate: ${this.waveInfoUpdate}`)
    // 波形数据更新时重新加载
    this.loadWaveData()
    // 强制Canvas重新渲染
    this.canvasKey = Date.now()
    if (this.isVisible && this.canvasWidth > 0 && this.canvasHeight > 0) {
      this.drawWave()
    }
  }

  private loadWaveData() {
    // 如果提供了realWaveData，直接使用
    if (this.realWaveData) {
      this.currentWaveData = this.realWaveData
      console.log(`[WaveCard] 使用提供的realWaveData - 通道ID: ${this.realWaveData.nChannelId}, 水果重量: ${this.realWaveData.fruitweight}g`)
      return
    }
    // 否则从AppStorage获取对应通道的波形数据
    if (this.channelId >= 0) {
      try {
        const channelKey = `waveInfoList_${this.channelId}`
        const waveList: StWaveInfo[] = AppStorage.get<StWaveInfo[]>(channelKey) || []
        if (waveList.length > 0) {
          // 使用最新的波形数据
          this.currentWaveData = waveList[waveList.length - 1]
          console.log(`[WaveCard] 从AppStorage加载波形数据 - 通道ID: ${this.channelId}, 水果重量: ${this.currentWaveData.fruitweight}g, 列表长度: ${waveList.length}`)
        } else {
          this.currentWaveData = null
          console.log(`[WaveCard] 通道ID ${this.channelId} 没有波形数据`)
        }
      } catch (e) {
        this.currentWaveData = null
        console.error(`[WaveCard] 加载波形数据失败: ${e}`)
      }
    } else {
      this.currentWaveData = null
    }
  }


  build() {
    Canvas(this.context)
      .key(`waveCard_${this.channelId}_${this.canvasKey}`)
      .width('100%')
      .height('100%')
      .backgroundColor(this.cardBackground as Color)
      .onReady(() => {
        console.log(`[WaveCard] Canvas onReady - channelId: ${this.channelId}, canvasKey: ${this.canvasKey}`)
        this.drawWave()
      })
      .onAreaChange((oldRect, newRect) => {
        const w: number = Number.parseFloat(String(newRect.width))
        const h: number = Number.parseFloat(String(newRect.height))
        const cw: number = Number.isFinite(w) && w > 0 ? Math.floor(w) : 0
        const ch: number = Number.isFinite(h) && h > 0 ? Math.floor(h) : 0
        if (cw !== this.canvasWidth || ch !== this.canvasHeight) {
          this.canvasWidth = cw
          this.canvasHeight = ch
          // 尺寸变化去抖，且重建渐变以匹配新尺寸
          // 注意：不在这里调用 drawWave()，让定时器统一控制绘制，避免速度异常
          if (this.areaDebounceId) { clearTimeout(this.areaDebounceId) }
          this.areaDebounceId = setTimeout((): void => {
            this.cachedGradient = null
            // 只在尺寸变化时立即绘制一次，之后由定时器控制
            if (this.isVisible && this.canvasWidth > 0 && this.canvasHeight > 0) {
              this.drawWave()
            }
          }, 150) as number
        }
      })
      .onVisibleAreaChange([0.01], (isExpanding: boolean, ratio: number) => {
        const nowVisible = ratio > 0
        if (this.isVisible !== nowVisible) {
          this.isVisible = nowVisible
          if (this.isVisible && !this.isListenerRegistered) {
            this.phaseManager.addListener(this.phaseUpdateCallback)
            this.isListenerRegistered = true
            // 可见时立即加载数据并绘制
            this.loadWaveData()
            if (this.canvasWidth > 0 && this.canvasHeight > 0) {
              this.drawWave()
            }
          } else if (!this.isVisible && this.isListenerRegistered) {
            this.phaseManager.removeListener(this.phaseUpdateCallback)
            this.isListenerRegistered = false
          }
        }
      })
  }

  private drawWave() {
    const width = this.canvasWidth || 1
    const height = this.canvasHeight || 1
    
    // 性能优化：如果尺寸无效，直接返回
    if (width <= 0 || height <= 0) {
      return
    }
    
    // 根据水果重量动态计算波浪高度百分比
    let dynamicWaveHeightPercent = 0  // 默认高度为0（没有数据时不显示）
    if (this.currentWaveData && this.currentWaveData.fruitweight > 0) {
      // 根据水果重量计算高度百分比
      // 假设重量范围：0-300g 对应 0-100%的高度
      // 可以根据实际需求调整这个范围
      const minWeight = 0    // 最小重量（g）
      const maxWeight = 300  // 最大重量（g）
      const weight = this.currentWaveData.fruitweight
      
      // 计算百分比：限制在0-100%之间
      let percent = ((weight - minWeight) / (maxWeight - minWeight)) * 100
      percent = Math.max(0, Math.min(100, percent)) // 限制在0-100%
      
      dynamicWaveHeightPercent = percent
      console.log(`[WaveCard] 计算波浪高度 - 通道ID: ${this.channelId}, 水果重量: ${weight}g, 高度百分比: ${percent.toFixed(2)}%`)
    } else {
      // 没有数据时，高度为0（不显示波浪）
      dynamicWaveHeightPercent = 0
    }
    
    // 清除整个画布
    this.context.clearRect(0, 0, width, height)

    // 使用动画波浪，但高度根据水果重量动态调整
    this.drawAnimatedWave(width, height, dynamicWaveHeightPercent)
  }


  private drawAnimatedWave(width: number, height: number, dynamicHeightPercent?: number) {
    // 使用动态高度百分比，如果没有提供则使用默认值
    const heightPercent = dynamicHeightPercent !== undefined ? dynamicHeightPercent : this.waveHeightPercent
    // 计算波浪图从底部开始的实际高度
    const waveHeight = height * (heightPercent / 100)
    
    // 计算波浪基准位置：让最高点刚好到达目标高度
    // 基准位置 = 目标高度 - 振幅，这样最高点就是目标高度
    const centerY = height - waveHeight + this.amplitude

    // 缓存渐变对象，避免每帧创建
    if (!this.cachedGradient || this.cachedGradientWidth !== width) {
      const gradient = this.context.createLinearGradient(0, 0, width, 0)
      gradient.addColorStop(0, this.gradientLeft)
      gradient.addColorStop(0.5, this.gradientMid)
      gradient.addColorStop(1, this.gradientRight)
      this.cachedGradient = gradient
      this.cachedGradientWidth = width
    }
    this.context.fillStyle = this.cachedGradient as CanvasGradient
    this.context.beginPath()
    this.context.moveTo(0, centerY)

    // 从全局相位管理器获取共享的相位值
    const phase = this.phaseManager.getPhase()
    
    // 性能优化：根据画布宽度动态调整绘制步长
    const step = width > 200 ? 3 : (width > 100 ? 2 : 1)
    
    // 性能优化：预计算频率和振幅，减少重复访问
    const freq = this.frequency
    const amp = this.amplitude
    
    for (let x = 0; x <= width; x += step) {
      const y = centerY + Math.sin(x * freq + phase) * amp
      this.context.lineTo(x, y)
    }
    
    // 确保最后一点连接到右边界（如果步长导致未到达边界）
    if (width % step !== 0) {
      const y = centerY + Math.sin(width * freq + phase) * amp
      this.context.lineTo(width, y)
    }

    this.context.lineTo(width, height)
    this.context.lineTo(0, height)
    this.context.closePath()
    this.context.fill()
  }
}
