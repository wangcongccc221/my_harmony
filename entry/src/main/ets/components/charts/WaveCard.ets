import { WavePhaseManager } from '../../utils/ui/WavePhaseManager'

@Component
export struct WaveCard {
  @Prop amplitude: number = 10
  @Prop frequency: number = 0.01
  @Prop speed: number = 0.02
  @Prop @Watch('onWavePropsChanged') waveHeightPercent: number = 70  // 波浪图高度百分比（默认70%）
  @Prop @Watch('onWavePropsChanged') baselinePercent: number = 50    // 波浪基准位置百分比（默认50%，即中间位置）
  @Prop gradientLeft: string = 'rgba(52, 152, 219, 0.7)'
  @Prop gradientMid: string = 'rgba(41, 128, 185, 0.8)'
  @Prop gradientRight: string = 'rgba(52, 152, 219, 0.7)'
  @Prop cardBackground: string | Color = Color.Transparent

  // 使用全局相位管理器，所有卡片共享同一个相位（确保同步）
  private phaseManager: WavePhaseManager = WavePhaseManager.getInstance()
  // 使用箭头函数绑定，确保 callback 引用唯一且稳定
  private phaseUpdateCallback: () => void = () => {
    // 移除 isVisible 检查，解决部分场景下可见性检测异常导致动画停止的问题
    // 只要有尺寸就进行绘制，系统会自动处理屏幕外 Canvas 的渲染优化
    if (this.canvasWidth > 0 && this.canvasHeight > 0) {
      this.drawWave()
    }
  }
  @State private canvasWidth: number = 0
  @State private canvasHeight: number = 0

  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private cachedGradient: CanvasGradient | null = null
  private cachedGradientWidth: number = 0  // 缓存渐变对应的宽度
  private areaDebounceId: number = 0
  private isVisible: boolean = false
  private isListenerRegistered: boolean = false

  aboutToAppear() {
    this.isVisible = true
    if (!this.isListenerRegistered) {
      this.phaseManager.addListener(this.phaseUpdateCallback)
      this.isListenerRegistered = true
    }
    if (this.canvasWidth > 0 && this.canvasHeight > 0) {
      this.drawWave()
    }
  }

  onWavePropsChanged() {
    if (this.canvasWidth > 0 && this.canvasHeight > 0) {
      this.drawWave()
    }
  }

  aboutToDisappear() {
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

  build() {
    Canvas(this.context)
      .width('100%')
      .height('100%')
      .backgroundColor(this.cardBackground as Color)
      .onReady(() => this.drawWave())
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
            if (this.canvasWidth > 0 && this.canvasHeight > 0) {
              this.drawWave()
            }
          }, 150) as number
        }
      })
      .onVisibleAreaChange([0.01], (isExpanding: boolean, ratio: number) => {
        const nowVisible = ratio > 0
        if (this.isVisible !== nowVisible) {
          this.isVisible = nowVisible
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
    
    // 计算波浪图从底部开始的实际高度
    const waveHeight = height * (this.waveHeightPercent / 100)
    
    // 计算波浪基准位置：让最高点刚好到达目标高度
    // 基准位置 = 目标高度 - 振幅，这样最高点就是目标高度
    const centerY = height - waveHeight + this.amplitude

    // 清除整个画布（保持简单，避免计算错误）
    this.context.clearRect(0, 0, width, height)

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
    // 小画布（<100px）：每像素绘制（保持平滑）
    // 中等画布（100-200px）：每2像素绘制
    // 大画布（>200px）：每3像素绘制
    // 平衡性能和视觉效果
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
    
    // 优化版本（已注释）：
    // // 如果画布尺寸无效，不绘制
    // if (width <= 0 || height <= 0) {
    //   return
    // }
    // 
    // // 性能优化：减少绘制点数量
    // // 原来每像素画一次，现在每2-3像素画一次，减少计算量
    // // 对于120px宽的卡片，从120次计算减少到40-60次，性能提升约50%
    // const step = width > 200 ? 3 : (width > 100 ? 2 : 1)  // 大卡片步长更大
    // 
    // for (let x = 0; x <= width; x += step) {
    //   const y = centerY + Math.sin(x * this.frequency + this.phase) * this.amplitude
    //   this.context.lineTo(x, y)
    // }
    //
    // // 确保最后一点连接到右边界
    // if (width % step !== 0) {
    //   const y = centerY + Math.sin(width * this.frequency + this.phase) * this.amplitude
    //   this.context.lineTo(width, y)
    // }
  }
}
