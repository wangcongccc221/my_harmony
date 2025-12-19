/**
 * 第三层组件
 * 显示数据列表、波浪图或占位符
 */

import { ThreeLayerCardData } from './types'
import { WaveCard } from '../charts/WaveCard'
import { DragData } from '../../utils/ui/DragManager'
import { DragHandlers } from '../../utils/ui/DragHandlers'
import { CardColorConfig } from '../../utils/theme/CardColors'
import { UseDragHandlers } from './hooks/useDragHandlers'
import { WaveConfigManager } from '../../utils/ui/WaveConfig'

// 运行期日志开关（仅用于屏蔽非关键调试日志）
const DEBUG_LOGS: boolean = false

@Component
export struct ThirdLayer {
  @Prop cardData: ThreeLayerCardData
  @Prop enableWave: boolean
  @Prop localChartData: number[]
  @Prop localChartDataStrings: string[]
  @Prop hasOriginalFormatData: boolean
  @Prop pendingDragValue: string
  @Prop pendingDragIndex: number
  @Prop cardColors: CardColorConfig
  @Prop waveHeightPercent: number
  @Prop waveBaselinePercent: number
  @Prop cardNumber: number
  // 父组件同步拖拽缓存（值与索引），用于 onDragEnd 删除命中
  onCachePending: (value: string, index: number) => void = () => {}
  onDropCallback: (event: DragEvent, extraParams: string) => void = () => {}
  onDragEnterCallback: () => void = () => {}
  onDragLeaveCallback: () => void = () => {}
  onTouchCallback: () => void = () => {}
  onClickCallback: () => void = () => {}
  deleteItemFromThirdLayer: () => void = () => {}

  // 拖拽处理器
  private dragHandlers: DragHandlers = new DragHandlers()
  
  // 滚动控制器，确保新数据从顶部开始显示
  private scroller: Scroller = new Scroller()
  private lastDataLength: number = 0
  @State private scrollKey: number = 0 // 用于强制重新创建Scroll组件
  
  // 双击检测相关
  private lastClickTime: number = 0
  private readonly DOUBLE_CLICK_INTERVAL: number = 300 // 双击间隔时间（毫秒）

  build() {
    Column() {
      // 优先显示数据：有数据就渲染列表；否则显示波浪（所有卡片都可以显示波浪，根据数据动态更新）
      if (this.localChartData && this.localChartData.length > 0) {
        this.buildDataList()
      } else {
        // 所有卡片都显示波浪，即使enableWave为false，也会根据接收到的数据动态更新
        this.buildWaveCard()
      }
    }
    .width('100%')
    .layoutWeight(1) // 第三层：自动填充剩余空间
    .padding({ left: 0, right: 0, top: 0, bottom: 0 })
    .backgroundColor(Color.Transparent) // 第三层：透明背景
    .justifyContent(FlexAlign.Start)
    .border({ width: 1, color: this.cardColors.cardBorder }) // 恢复底部边框
    .onDrop((event: DragEvent, extraParams: string) => {
      if (DEBUG_LOGS) { console.log('第三层onDrop事件触发:', extraParams) }
      this.onDropCallback(event, extraParams)
    })
    .onTouch((event?: TouchEvent) => {
      if (!event) { return }
      
      // 先执行原有的触摸回调（用于拖拽检测）
      this.onTouchCallback()
      
      // 双击检测：当触摸抬起时检查时间间隔
      if (event.type === TouchType.Up) {
        const currentTime = Date.now()
        const timeSinceLastClick = currentTime - this.lastClickTime
        
        // 如果两次点击间隔在阈值内，认为是双击
        if (timeSinceLastClick > 0 && timeSinceLastClick <= this.DOUBLE_CLICK_INTERVAL) {
          // 双击事件
          console.log('第三层被双击，通知父组件显示详情对话框')
          if (this.onClickCallback) {
            this.onClickCallback()
          }
          // 重置时间戳，避免连续触发
          this.lastClickTime = 0
        } else {
          // 更新最后点击时间
          this.lastClickTime = currentTime
        }
      }
    })
    .onDragEnter((event: DragEvent) => {
      if (DEBUG_LOGS) { console.log('第三层onDragEnter事件触发') }
      this.onDragEnterCallback()
    })
    .onDragLeave((event: DragEvent) => {
      if (DEBUG_LOGS) { console.log('第三层onDragLeave事件触发') }
      this.onDragLeaveCallback()
    })
    .onTouch((event?: TouchEvent) => {
      if (!event) { return }
      // 检测双击：当触摸抬起时检查时间间隔
      if (event.type === TouchType.Up) {
        const currentTime = Date.now()
        const timeSinceLastClick = currentTime - this.lastClickTime
        
        // 如果两次点击间隔在阈值内，认为是双击
        if (timeSinceLastClick > 0 && timeSinceLastClick <= this.DOUBLE_CLICK_INTERVAL) {
          // 双击事件
          console.log('第三层被双击，通知父组件显示详情对话框')
          if (this.onClickCallback) {
            this.onClickCallback()
          }
          // 重置时间戳，避免连续触发
          this.lastClickTime = 0
        } else {
          // 更新最后点击时间
          this.lastClickTime = currentTime
        }
      }
    })
  }

  @Builder
  private buildDataList() {
    Scroll(this.scroller) {
      Column() {
        ForEach(this.localChartData as number[], (num: number, idx: number) => {
          this.buildDataItem(num, idx)
        })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .align(Alignment.TopStart) // 强制从顶部开始对齐
    }
    .width('100%')
    .height('100%')
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Auto)
    .scrollBarColor(this.cardColors.cardBorder)
    .scrollBarWidth(4)
    .edgeEffect(EdgeEffect.Spring)
    .align(Alignment.TopStart) // Scroll组件也从顶部开始
    .key(`${this.scrollKey}`) // 使用key强制重新创建Scroll组件
  }

  // 组件生命周期：当数据变化时滚动到顶部
  aboutToAppear() {
    this.lastDataLength = this.localChartData.length
  }

  aboutToRender() {
    // 当数据长度变化时，强制重新创建Scroll组件并滚动到顶部
    if (this.localChartData.length !== this.lastDataLength) {
      // 更新scrollKey强制重新创建Scroll组件
      this.scrollKey++
      this.lastDataLength = this.localChartData.length
      console.log('🔄 ThirdLayer - 数据变化，强制重新创建Scroll组件，scrollKey:', this.scrollKey)
    }
  }

  // 当组件出现时，确保滚动到顶部
  onAppear(event: () => void) {
    setTimeout(() => {
      this.scroller.scrollTo({ xOffset: 0, yOffset: 0 })
    }, 100)
    return this
  }

  // 判断是否有数据（不为空且不为0）
  private hasData(num: number, idx: number): boolean {
    const hasNum = num !== 0 && num !== null && num !== undefined
    const str = this.localChartDataStrings[idx]
    const hasStr = str && str.trim() !== '' && str !== '0'
    return hasNum || !!hasStr
  }

  @Builder
  private buildDataItem(num: number, idx: number) {
    Row() {
      // 移除序号显示，直接显示数据内容
      Text(this.localChartDataStrings[idx] || String(num))
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.cardColors.dataListText)
        .draggable(true)
        .onDragStart((event: DragEvent, extraParams: string): DragItemInfo => {
          // 使用模块化的拖拽管理器
          // 尝试从映射中取等级名，便于跨卡片移动时直接携带
          let carriedLevelName: string = ''
          try {
            const cardId = String(this.cardData.id || '')
            const mapRaw = AppStorage.get('CARD_ITEM_LEVEL_MAP') as Record<string, Record<string, string>> | null
            const mapObj: Record<string, Record<string, string>> = mapRaw ? mapRaw : {}
            // 使用原始字符串进行映射查找
            const originalValue = this.localChartDataStrings[idx] || String(num)
            carriedLevelName = (mapObj[cardId] && mapObj[cardId][originalValue]) ? String(mapObj[cardId][originalValue]) : ''
          } catch (_e) {}
          const originalValue = this.localChartDataStrings[idx] || String(num)
          console.log('🚀 卡片拖拽开始:')
          console.log('  - idx:', idx)
          console.log('  - num:', num)
          console.log('  - localChartDataStrings[idx]:', this.localChartDataStrings[idx])
          console.log('  - originalValue:', originalValue)
          console.log('  - cardId:', String(this.cardData.id ?? ''))
          
          const dragData: DragData = {
            value: String(num),
            sourceTable: 'card_third_layer',
            rowIndex: 0,
            colIndex: 0,
            sourceCardId: String(this.cardData.id ?? ''),
            sourceValue: originalValue, // 使用原始字符串
            itemIndex: Number(idx),
            levelName: carriedLevelName // 添加等级名称
          }
          console.log('  - dragData:', JSON.stringify(dragData))
          
          // 使用拖拽处理器开始拖拽
          this.dragHandlers.handleDragStart(dragData)
          
          // 立即标记为已处理，防止LevelTable的拖拽逻辑干扰
          UseDragHandlers.markDropHandled()
          
          // 本地兜底缓存
          this.pendingDragValue = originalValue // 使用原始字符串
          this.pendingDragIndex = Number(idx)
          // 同步父组件缓存，避免 onDragEnd 时父侧拿不到原始字符串
          this.onCachePending(this.pendingDragValue, this.pendingDragIndex)
          
          const extra: string = JSON.stringify(dragData)
          const info: DragItemInfo = {
            pixelMap: undefined,
            builder: undefined,
            extraInfo: String(extra)
          }
          return info
        })
        .onDragEnd(() => {
          // 使用模块化的拖拽处理器处理拖拽结束
          this.dragHandlers.handleDragEnd(
            () => {
              // 删除逻辑：拖拽到空白区域
              console.log('🟡 移动非卡片区域，执行删除逻辑')
              console.log('🗑️ 删除逻辑详情: idx=', idx, 'num=', num, 'cardId=', String(this.cardData.id || ''))
              try {
                const valStr = this.pendingDragValue || this.localChartDataStrings[idx] || String(num)
                const cardId = String(this.cardData.id || '')
                if (DEBUG_LOGS) {
                  console.log('🗑️ 删除逻辑调试: idx=', idx, 'num=', num, 'valStr=', valStr, 'cardId=', cardId)
                }
                UseDragHandlers.emitRemoveLevelExit(cardId, valStr, this.cardNumber)
              } catch (_e) {}
              this.deleteItemFromThirdLayer()
            },
            () => {
              // 复制逻辑：拖拽到其他卡片
              console.log('🟢 拖拽到其他卡片，执行复制逻辑')
              console.log('🟢 复制逻辑详情: idx=', idx, 'num=', num, 'cardId=', String(this.cardData.id || ''))
            }
          )
        })
    }
    .width('100%')
    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
    .margin({ bottom: 2 })
    .borderRadius(4) // 添加圆角
    .backgroundColor(this.hasData(num, idx) ? 'rgba(135, 206, 235, 0.2)' : Color.Transparent) // 有数据时添加淡蓝色背景（天蓝色，20%透明度）
  }

  @Builder
  private buildWaveCard() {
    WaveCard({
      amplitude: this.getWaveAmplitude(),
      frequency: this.getWaveFrequency(),
      speed: 0.02,
      waveHeightPercent: this.waveHeightPercent,
      baselinePercent: this.waveBaselinePercent,
      cardBackground: Color.Transparent,
      gradientLeft: this.cardColors.waveGradientLeft,
      gradientMid: this.cardColors.waveGradientMid,
      gradientRight: this.cardColors.waveGradientRight,
      channelId: this.getCardIndex() + 1  // 通道ID = 卡片索引 + 1（通道ID从1开始，卡片索引从0开始）
    })
      .width('100%')
      .height('100%')
  }
  
  // 获取卡片索引（从0开始）
  private getCardIndex(): number {
    const cardId = String(this.cardData.id || '')
    // 从 card_0, card_1 等格式中提取数字
    const match = cardId.match(/card_(\d+)/)
    return match ? parseInt(match[1]) : 0
  }
  
  // 获取波浪振幅
  private getWaveAmplitude(): number {
    const cardIndex = this.getCardIndex()
    const waveConfig = WaveConfigManager.getInstance().getWaveConfig(cardIndex)
    return waveConfig.amplitude
  }
  
  // 获取波浪频率
  private getWaveFrequency(): number {
    const cardIndex = this.getCardIndex()
    const waveConfig = WaveConfigManager.getInstance().getWaveConfig(cardIndex)
    return waveConfig.frequency
  }

  @Builder
  private buildPlaceholder() {
    Column() {
      // 占位内容
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}