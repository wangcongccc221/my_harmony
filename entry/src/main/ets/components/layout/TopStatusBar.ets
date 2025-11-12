import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { TOP_PRODUCTION_TON_H, TOP_SUM_WEIGHT_TON, TOP_SUM_COUNTS, TOP_AVG_G, TOP_STATUS_TEXT, TOP_ALERT_HIDE, TCP_CONNECTION_STATUS } from '../../constants/TopBarKeys'
import { CompactFsmToggle } from './CompactFsmToggle'
import { IBestAvatar, IBestButton } from '@ibestservices/ibest-ui'
// 已移除自定义对话框
import common from '@ohos.app.ability.common'
import { MinimizeAppUtil } from '../../utils/window/MinimizeAppUtil'

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
  // 客户信息（可由其他页面写入 AppStorage，不改动业务含义）
  @StorageLink('CUSTOMER_LOGO_URL') private customerLogoUrl: string = ''
  @StorageLink('FARM_NAME') private farmName: string = ''
  @StorageLink('FRUIT_TYPE') private fruitType: string = ''
  
  // FSM状态
  @Prop selectedFSM: 'FSM1' | 'FSM2' = 'FSM1'
  onFSMChange?: (fsm: 'FSM1' | 'FSM2') => void
  
  // 实时时间状态
  @State private currentTime: string = ''
  private timeTimer: number | null = null
  
  // 模拟数据定时器
  private dataTimer: number | null = null

  private async minimizeApp() {
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

  private async closeApp() {
    try {
      const ctx = getContext(this) as common.UIAbilityContext
      await ctx.terminateSelf()
    } catch (e) {
      console.error('[TopStatusBar] 关闭应用失败:', JSON.stringify(e))
    }
  }

  private getCurrentTheme(): ExtendedOmniThemeStyle {
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
    this.currentTime = `${y}-${m}-${d} ${hh}:${mm}:${ss}`
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
      // 左侧 LOGO
      Row() {
        Image($r('app.media.logo'))
          .width('8%')
          .height('100%')
          .objectFit(ImageFit.Contain)
          .margin({ left: '0.5%', right: '1%' })
      }
      .alignItems(VerticalAlign.Center)

      // 中部四项指标（列：上标签+单位，下数值）
      Row() {
        Column() {
          Row() {
            Text('production')
              .fontSize(16)  // 调大到16px
              .fontColor(this.getCurrentTheme().subTextColor)
            Text('(Ton/h)')
              .fontSize(16)  // 调大到16px
              .fontColor(this.getCurrentTheme().subTextColor)
              .margin({ left: 2 })
          }
          .alignItems(VerticalAlign.Center)
          Text(this.productionTonPerHour)
            .fontSize(18)  // 调大到18px
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ right: 12 })

        Row() {}
          .width('0.2%')
          .height('60%')
          .backgroundColor(this.getCurrentTheme().borderColor)
          .margin({ left: '1%', right: '1%' })

        Column() {
          Row() {
            Text('SumWeight')
              .fontSize(16)  // 调大到16px
              .fontColor(this.getCurrentTheme().subTextColor)
            Text('(Ton)')
              .fontSize(16)  // 调大到16px
              .fontColor(this.getCurrentTheme().subTextColor)
              .margin({ left: 2 })
          }
          .alignItems(VerticalAlign.Center)
          Text(this.sumWeightTon)
            .fontSize(18)  // 调大到18px
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ right: 12 })

        Row() {}
          .width('0.2%')
          .height('60%')
          .backgroundColor(this.getCurrentTheme().borderColor)
          .margin({ left: '1%', right: '1%' })

        Column() {
          Row() {
            Text('SumCounts')
              .fontSize(16)  // 调大到16px
              .fontColor(this.getCurrentTheme().subTextColor)
            Text('(PCS)')
              .fontSize(16)  // 调大到16px
              .fontColor(this.getCurrentTheme().subTextColor)
              .margin({ left: 2 })
          }
          .alignItems(VerticalAlign.Center)
          Text(this.sumCounts)
            .fontSize(18)  // 调大到18px
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ right: 12 })

        Row() {}
          .width('0.2%')
          .height('60%')
          .backgroundColor(this.getCurrentTheme().borderColor)
          .margin({ left: '1%', right: '1%' })

        Column() {
          Row() {
            Text('Avg')
              .fontSize(16)  // 调大到16px
              .fontColor(this.getCurrentTheme().subTextColor)
            Text('(g)')
              .fontSize(16)  // 调大到16px
              .fontColor(this.getCurrentTheme().subTextColor)
              .margin({ left: 2 })
          }
          .alignItems(VerticalAlign.Center)
          Text(this.avgGram)
            .fontSize(18)  // 调大到18px
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
      }
      .alignItems(VerticalAlign.Center)
      .margin({ right: '1.5%' })

      // 状态文本与告警提示
      Row() {
        // TCP连接状态显示
        if (this.tcpConnected) {
          Text('设备连接正常')
            .fontSize(16)  // 调大到16px
            .fontColor('#34A853')
            .margin({ right: 12 })
        } else {
          Text('设备故障，请排查')
            .fontSize(16)  // 调大到16px
            .fontColor('#D93025')
            .margin({ right: 12 })
        }
        
        Text(this.statusText)
          .fontSize(16)  // 调大到16px
          .fontColor(this.getCurrentTheme().subTextColor)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .height('40%')
      .margin({ right: '1%' })

      // 客户公司 LOGO + 农场名称 + 分选种类（放在状态区与FSM切换之间）
      Row() {
        Image(this.customerLogoUrl && this.customerLogoUrl.length > 0 ? this.customerLogoUrl : $r('app.media.customer_logo'))
          .width('4%')
          .height('70%')
          .objectFit(ImageFit.Contain)
          .borderRadius(6)
          .margin({ right: '0.6%' })

        Column() {
          Text(this.farmName && this.farmName.length > 0 ? this.farmName : '— 农场 —')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getCurrentTheme().textColor)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.fruitType && this.fruitType.length > 0 ? this.fruitType : '— 分选种类 —')
            .fontSize(14)
            .fontColor(this.getCurrentTheme().subTextColor)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.Start)
      }
      .alignItems(VerticalAlign.Center)
      .width('auto')
      .margin({ right: '1%' })

      Blank().layoutWeight(1)

      // 个人信息区域：FSM切换 + 头像 + 姓名/管理员
      Row() {
        // FSM切换按钮
        CompactFsmToggle({
          selectedFSM: this.selectedFSM,
          onFSMChange: (fsm: 'FSM1' | 'FSM2') => {
            if (this.onFSMChange) {
              this.onFSMChange(fsm)
            }
          }
        })
        .margin({ left: 15, right: 8 })

        // 头像和用户信息
        Row() {
          IBestAvatar({
            src: AppStorage.get('SELECTED_AVATAR_URL') || 'https://img1.baidu.com/it/u=700838104,4078529388&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500',
            defaultAvatar: $r('app.media.default_avatar'),
            avatarSize: 40,
            shape: 'circle',
            onAvatarClick: () => {
              AppStorage.setOrCreate('TEMP_USER_LABEL', this.userLabel)
              AppStorage.setOrCreate('EDIT_USER_LABEL_VISIBLE', true)
            }
          })

          Column() {
            Text(this.userLabel)
              .fontSize(18)  // 调大到18px
              .fontColor(this.getCurrentTheme().subTextColor)
            Text('管理员')
              .fontSize(18)  // 调大到18px
              .fontWeight(FontWeight.Medium)
              .fontColor(this.getCurrentTheme().textColor)
          }
          .margin({ left: '1%' })
          .alignItems(HorizontalAlign.Start)
          .onClick(() => {
            AppStorage.setOrCreate('TEMP_USER_LABEL', this.userLabel)
            AppStorage.setOrCreate('EDIT_USER_LABEL_VISIBLE', true)
          })
        }
        .alignItems(VerticalAlign.Center)
      }
      .alignItems(VerticalAlign.Center)
      .margin({ right: 8 })

      Text(this.currentTime)
        .fontSize(16)  // 调大到16px
        .fontColor(this.getCurrentTheme().subTextColor)
        .margin({ right: 8 })

      // 右上角窗口控制（使用 iBest 方形按钮包裹 'X'）
      Row() {
        IBestButton({
          text: '—',
          type: 'default',
          onBtnClick: () => { this.minimizeApp() }
        })
          .margin({ right: 4 })

        IBestButton({
          text: 'X',
          type: 'default',
          onBtnClick: () => { this.closeApp() }
        })
      }

      // （对话框改为系统级 CustomDialogController 实现）
    }
    .width('100%')
    .height('8%')
    .padding({ left: '0.5%', right: 8 })
    .backgroundColor(this.getCurrentTheme().surfaceColor)
    .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })
  }

}


