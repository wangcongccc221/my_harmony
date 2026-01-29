import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { TOP_PRODUCTION_TON_H, TOP_SUM_WEIGHT_TON, TOP_SUM_COUNTS, TOP_AVG_G, TOP_STATUS_TEXT, TOP_ALERT_HIDE, TCP_CONNECTION_STATUS } from '../../constants/TopBarKeys'
import { CompactFsmToggle } from './CompactFsmToggle'
import { IBestAvatar, IBestButton } from '@ibestservices/ibest-ui'
// 已移除自定义对话框
import common from '@ohos.app.ability.common'
import { MinimizeAppUtil } from '../../utils/window/MinimizeAppUtil'
import { AppleDesignStyle } from '../../utils/theme/AppleDesignStyle'
import { ThreeDButton } from '../ui/buttons/ThreeDButton'
import { ProfileInfoBar } from './ProfileInfoBar'

/**
 * 顶部状态栏组件（精简版，无个人信息/头像/对话框）
 */
@Component
export struct TopStatusBar {
  @Prop currentPage: string = ''
  @StorageLink(TOP_PRODUCTION_TON_H) productionTonPerHour: string = '--'
  @StorageLink(TOP_SUM_WEIGHT_TON) sumWeightTon: string = '--'
  @StorageLink(TOP_SUM_COUNTS) sumCounts: string = '--'
  @StorageLink(TOP_AVG_G) avgGram: string = '--'
  @StorageLink(TOP_STATUS_TEXT) statusText: string = ''
  @StorageLink(TOP_ALERT_HIDE) alertHide: boolean = true
  @StorageLink(TCP_CONNECTION_STATUS) tcpConnected: boolean = false
  @StorageLink(OMNI_THEME_VERSION_KEY) private themeVersion: number = 0
  @StorageLink('TOP_USER_LABEL') private userLabel: string = '姓名'
  @StorageLink('SELECTED_AVATAR_URL') private selectedAvatarUrl: string = 'https://img1.baidu.com/it/u=700838104,4078529388&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500'
  // 客户信息（可由其他页面写入 AppStorage，不改动业务含义）
  @StorageLink('CUSTOMER_LOGO_URL') private customerLogoUrl: string = ''
  @StorageLink('FARM_NAME') private farmName: string = ''
  @StorageLink('FRUIT_TYPE') private fruitType: string = ''
  
  // FSM状态
  @Prop selectedFSM: 'FSM1' | 'FSM2' = 'FSM1'
  onFSMChange?: (fsm: 'FSM1' | 'FSM2') => void
  
  // 实时时间状态（两行显示）
  @State private currentDate: string = ''
  @State private currentTime: string = ''
  private timeTimer: number | null = null
  
  // 模拟数据定时器
  private dataTimer: number | null = null

  private async minimizeApp() { //最小化
    try {
      const ctx = getContext(this) as common.UIAbilityContext
      const ok = await MinimizeAppUtil.getInstance(ctx, {
        maxRetries: 3,
        retryDelay: 800,
        enableLogging: true,
        onError: (_) => {}
      }).minimize()
      if (!ok) {
        // 兜底：退到后台
        interface MoveMinimize { moveMissionToBackground?: () => Promise<void> }
        const maybe = ctx as MoveMinimize
        if (typeof maybe.moveMissionToBackground === 'function') {
          await maybe.moveMissionToBackground()
        } else {
          console.warn('[TopStatusBar] 不支持最小化且无退后台接口，已跳过')
        }
      }
    } catch (e) {
      console.error('[TopStatusBar] 最小化失败:', JSON.stringify(e))
    }
  }

  private async closeApp() { //关闭程序
    try {
      const ctx = getContext(this) as common.UIAbilityContext
      await ctx.terminateSelf()
    } catch (e) {
      console.error('[TopStatusBar] 关闭应用失败:', JSON.stringify(e))
    }
  }

  private getCurrentTheme(): ExtendedOmniThemeStyle { //获取主题
    const __v: number = this.themeVersion
    return OmniThemeManager.getInstance().getCurrentTheme()
  }

  aboutToAppear() {
    // 初始化时间
    this.updateCurrentTime()
    // 启动定时器，每秒更新一次
    this.timeTimer = setInterval(() => {
      this.updateCurrentTime()
    }, 1000)
    
    // 【测试用】暂时注释掉模拟数据，测试卡顿问题
    // this.initializeMockData()
    // // 启动模拟数据定时器，每3秒更新一次
    // this.dataTimer = setInterval(() => {
    //   this.updateMockData()
    // }, 3000)

    // 确保从 AppStorage 获取初始值
    // this.productionTonPerHour = AppStorage.get(TOP_PRODUCTION_TON_H) || '0.00'
    // this.sumWeightTon = AppStorage.get(TOP_SUM_WEIGHT_TON) || '0.000'
    // this.sumCounts = AppStorage.get(TOP_SUM_COUNTS) || '0'
    // this.avgGram = AppStorage.get(TOP_AVG_G) || '0.0'
  }

  aboutToDisappear() {
    // 清理定时器
    if (this.timeTimer) {
      clearInterval(this.timeTimer)
      this.timeTimer = null
    }
    // 【测试用】暂时注释掉模拟数据定时器清理
    // if (this.dataTimer) {
    //   clearInterval(this.dataTimer)
    //   this.dataTimer = null
    // }
  }

  private updateCurrentTime() {
    const now = new Date()
    const y = now.getFullYear()
    const m = String(now.getMonth() + 1).padStart(2, '0')
    const d = String(now.getDate()).padStart(2, '0')
    const hh = String(now.getHours()).padStart(2, '0')
    const mm = String(now.getMinutes()).padStart(2, '0')
    const ss = String(now.getSeconds()).padStart(2, '0')
    // 第一行：日期
    this.currentDate = `${y}-${m}-${d}`
    // 第二行：时间
    this.currentTime = `${hh}:${mm}:${ss}`
  }

  /**
   * 初始化模拟数据
   */
  private initializeMockData() {
    // 设置初始模拟数据
    this.productionTonPerHour = '1.25'
    this.sumWeightTon = '45.8'
    this.sumCounts = '1250'
    this.avgGram = '36.6'
    this.statusText = '分选进行中'
  }

  /**
   * 更新模拟数据
   */
  private updateMockData() {
    // 模拟产量变化 (0.8 - 2.0 吨/小时)
    const productionBase = 1.2
    const productionVariation = (Math.random() - 0.5) * 0.8
    this.productionTonPerHour = (productionBase + productionVariation).toFixed(2)

    // 模拟总重量增长 (每次增加 0.1-0.3 吨)
    const currentWeight = parseFloat(this.sumWeightTon) || 0
    const weightIncrease = 0.1 + Math.random() * 0.2
    this.sumWeightTon = (currentWeight + weightIncrease).toFixed(1)

    // 模拟总计数增长 (每次增加 20-50 个)
    const currentCounts = parseInt(this.sumCounts) || 0
    const countsIncrease = 20 + Math.floor(Math.random() * 31)
    this.sumCounts = (currentCounts + countsIncrease).toString()

    // 模拟平均重量变化 (30-45 克)
    const avgBase = 37.5
    const avgVariation = (Math.random() - 0.5) * 8
    this.avgGram = (avgBase + avgVariation).toFixed(1)

    // 模拟状态文本变化
    const statusTexts = ['分选进行中', '设备运行正常', '数据采集中', '质量检测中', '包装准备中']
    this.statusText = statusTexts[Math.floor(Math.random() * statusTexts.length)]

    // TCP连接状态改为由真实网络模块更新（不再在此模拟）
  }

  build() {
    Row() {
      // ===============================================
      // 左侧区域：Logo + 生产指标 (紧凑布局)
      // ===============================================
      Row() {
        // 1. Logo
        Image($r('app.media.logo'))
          .height('60%')
          .objectFit(ImageFit.Contain)
          .margin({ right: 16 })
        
        // 2. 分割线
        Divider()
          .vertical(true)
          .height('40%')
          .color(this.getCurrentTheme().borderColor)
          .opacity(0.5)
          .margin({ right: 16 })

        // 3. 生产指标 (使用 Flex 自动换行或 Row 紧凑排列)
        Row({ space: 24 }) { // 增加间距，减少拥挤感
          MetricItem({ label: 'Production', value: this.productionTonPerHour, unit: 'Ton/h' })
          MetricItem({ label: 'SumWeight', value: this.sumWeightTon, unit: 'Ton' })
          MetricItem({ label: 'SumCounts', value: this.sumCounts, unit: 'PCS' })
          MetricItem({ label: 'Avg', value: this.avgGram, unit: 'g' })
        }
      }
      .layoutWeight(0) // 左侧根据内容自适应宽度
      .height('100%')
      .alignItems(VerticalAlign.Center)

      // ===============================================
      // 中间区域：状态告警 + 客户信息 (弹性空间)
      // ===============================================
      Row() {
        Blank() // 填充左边空间，让中间内容居中或偏右

        // status & Customer Group
        Row({ space: 16 }) {
           // 状态/告警信息
           this.buildStatusAlert()

           // 客户信息 (Logo + 农场名)
           this.buildCustomerInfo()
        }
        
        Blank() // 填充右边空间
      }
      .layoutWeight(1) // 占据剩余所有空间
      .height('100%')
      .alignItems(VerticalAlign.Center)
      
      // ===============================================
      // 右侧区域：FSM切换 + 个人信息 + 窗口控制 (固定在右侧)
      // ===============================================
      Row({ space: 12 }) {
        // FSM 切换
        CompactFsmToggle({
          selectedFSM: this.selectedFSM,
          onFSMChange: (fsm: 'FSM1' | 'FSM2') => {
            if (this.onFSMChange) {
              this.onFSMChange(fsm)
            }
          }
        })

        // 个人信息
        ProfileInfoBar({
          userName: this.userLabel,
          userRole: '管理员',
          currentDate: this.currentDate,
          currentTime: this.currentTime,
          avatarUrl: this.selectedAvatarUrl,
          isLoading: false
        })

        // 分割线
        Divider()
          .vertical(true)
          .height('40%')
          .color(this.getCurrentTheme().borderColor)
          .opacity(0.5)
          .margin({ left: 4, right: 4 })

        // 窗口控制按钮
        Row({ space: 8 }) {
          ThreeDButton({
            text: '−',
            isSelected: false,
            buttonWidth: 36, // 稍微调小一点，更精致
            buttonHeight: 36,
            fontSize: 20,
            onClickCallback: () => { this.minimizeApp() }
          })

          ThreeDButton({
            text: '×',
            isSelected: false,
            buttonWidth: 36,
            buttonHeight: 36,
            fontSize: 20,
            onClickCallback: () => { this.closeApp() }
          })
        }
      }
      .layoutWeight(0) // 右侧自适应宽度，确保显示
      .height('100%')
      .alignItems(VerticalAlign.Center)

    }
    .width('100%')
    .height('8%') // 保持原有高度设置
    .backgroundColor(this.getCurrentTheme().headerColor ?? this.getCurrentTheme().backgroundColor)
    .padding({ left: 16, right: 16 }) // 减少 padding，让出更多空间
    .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })
    .shadow({ radius: 6, color: 'rgba(0,0,0,0.05)', offsetY: 2 }) // 更柔和的阴影
  }

  // Helper: 状态/告警条
  @Builder
  buildStatusAlert() {
    if (this.tcpConnected) {
      // 正常状态：简洁的胶囊样式
      Row() {
        Circle({ width: 8, height: 8 })
          .fill('#4CAF50') // 绿色
          .margin({ right: 8 })
        Text(this.statusText || '系统就绪')
          .fontSize(16)
          .fontColor(this.getCurrentTheme().primary)
      }
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor(this.getCurrentTheme().surfaceColor)
      .borderRadius(16)
      .border({ width: 1, color: this.getCurrentTheme().borderColor })
    } else {
      // 故障/断开状态：醒目但不突兀的胶囊样式
      Row() {
        Text('⚠️')
          .fontSize(16)
          .margin({ right: 6 })
        Text('连接断开')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF3B30')
      }
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor('#FFF0F0') // 浅红背景
      .borderRadius(16)
      .border({ width: 1, color: '#FFcccc' })
    }
  }

  // Helper: 客户信息
  @Builder
  buildCustomerInfo() {
    Row() {
       Image(this.customerLogoUrl || $r('app.media.customer_logo'))
        .width(32)
        .height(32)
        .objectFit(ImageFit.Contain)
        .borderRadius(4)
        .margin({ right: 8 })
      
      Column() {
        Text(this.farmName || '未选定农场')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getCurrentTheme().textColor)
        Text(this.fruitType || '—')
          .fontSize(12)
          .fontColor(this.getCurrentTheme().subTextColor)
      }
      .alignItems(HorizontalAlign.Start)
    }
    .padding({ left: 12, right: 12, top: 4, bottom: 4 })
  }
}

/**
 * 独立的指标项组件，确保响应式更新
 */
@Component
struct MetricItem {
  @Prop label: string
  @Prop value: string
  @Prop unit: string
  @StorageLink(OMNI_THEME_VERSION_KEY) private themeVersion: number = 0

  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return OmniThemeManager.getInstance().getCurrentTheme()
  }

  build() {
    Column() {
      Text(this.label)
        .fontSize(14)
        .fontColor(this.getCurrentTheme().subTextColor)
        .margin({ bottom: 2 })
      
      Row() {
        Text(this.value)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getCurrentTheme().primary)
        Text(this.unit)
          .fontSize(12)
          .fontColor(this.getCurrentTheme().subTextColor)
          .opacity(0.8)
          .margin({ left: 2, top: 4 }) // 单位稍微下沉
      }
    }
    .alignItems(HorizontalAlign.Start)
  }
}
