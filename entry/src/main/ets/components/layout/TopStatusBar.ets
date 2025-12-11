import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { TOP_PRODUCTION_TON_H, TOP_SUM_WEIGHT_TON, TOP_SUM_COUNTS, TOP_AVG_G, TOP_STATUS_TEXT, TOP_ALERT_HIDE, TCP_CONNECTION_STATUS } from '../../constants/TopBarKeys'
import { CompactFsmToggle } from './CompactFsmToggle'
import { IBestAvatar, IBestButton } from '@ibestservices/ibest-ui'
// 已移除自定义对话框
import common from '@ohos.app.ability.common'
import { MinimizeAppUtil } from '../../utils/window/MinimizeAppUtil'
import { AppleDesignStyle } from '../../utils/theme/AppleDesignStyle'
import { AnimatedCloseButton } from '../ui/buttons/AnimatedCloseButton'
import { AnimatedMinimizeButton } from '../ui/buttons/AnimatedMinimizeButton'

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
  
  // 实时时间状态（两行显示）
  @State private currentDate: string = ''
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
      // 左侧 LOGO
      Row() {
        Image($r('app.media.logo'))
          .width('8%')
          .height('100%')
          .objectFit(ImageFit.Contain)
          .margin({ left: '0.5%', right: '1%' })
          .borderRadius(AppleDesignStyle.BORDER_RADIUS_SMALL) // Apple风格：圆角
      }
      .alignItems(VerticalAlign.Center)

      // 中部四项指标（列：上标签+单位，下数值）
      Row() {
        Column() {
          Row() {
            Text('production')
              .fontSize(14) // Apple风格：统一字体大小
              .fontWeight(FontWeight.Medium) // Apple风格：Medium
              .fontColor(this.getCurrentTheme().subTextColor)
            Text('(Ton/h)')
              .fontSize(12) // Apple风格：更小的单位字体
              .fontColor(this.getCurrentTheme().subTextColor)
              .opacity(0.7) // Apple风格：更柔和的透明度
              .margin({ left: 4 })
          }
          .alignItems(VerticalAlign.Center)
          Text(this.productionTonPerHour)
            .fontSize(18)  // 保持数值字体大小
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ right: AppleDesignStyle.SPACING_MEDIUM }) // Apple风格：统一间距

        Divider()
          .vertical(true)
          .strokeWidth(AppleDesignStyle.BORDER_WIDTH_THIN) // Apple风格：细边框
          .color(this.getCurrentTheme().borderColor)
          .height('60%')
          .opacity(0.5) // Apple风格：半透明
          .margin({ left: '1%', right: '1%' })

        Column() {
          Row() {
            Text('SumWeight')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.getCurrentTheme().subTextColor)
            Text('(Ton)')
              .fontSize(12)
              .fontColor(this.getCurrentTheme().subTextColor)
              .opacity(0.7)
              .margin({ left: 4 })
          }
          .alignItems(VerticalAlign.Center)
          Text(this.sumWeightTon)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ right: AppleDesignStyle.SPACING_MEDIUM })

        Divider()
          .vertical(true)
          .strokeWidth(AppleDesignStyle.BORDER_WIDTH_THIN) // Apple风格：细边框
          .color(this.getCurrentTheme().borderColor)
          .height('60%')
          .opacity(0.5) // Apple风格：半透明
          .margin({ left: '1%', right: '1%' })

        Column() {
          Row() {
            Text('SumCounts')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.getCurrentTheme().subTextColor)
            Text('(PCS)')
              .fontSize(12)
              .fontColor(this.getCurrentTheme().subTextColor)
              .opacity(0.7)
              .margin({ left: 4 })
          }
          .alignItems(VerticalAlign.Center)
          Text(this.sumCounts)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ right: AppleDesignStyle.SPACING_MEDIUM })

        Divider()
          .vertical(true)
          .strokeWidth(AppleDesignStyle.BORDER_WIDTH_THIN) // Apple风格：细边框
          .color(this.getCurrentTheme().borderColor)
          .height('60%')
          .opacity(0.5) // Apple风格：半透明
          .margin({ left: '1%', right: '1%' })

        Column() {
          Row() {
            Text('Avg')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.getCurrentTheme().subTextColor)
            Text('(g)')
              .fontSize(12)
              .fontColor(this.getCurrentTheme().subTextColor)
              .opacity(0.7)
              .margin({ left: 4 })
          }
          .alignItems(VerticalAlign.Center)
          Text(this.avgGram)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
      }
      .alignItems(VerticalAlign.Center)
      .margin({ right: '1.5%' })

      // 状态文本与告警提示
      Row({ space: AppleDesignStyle.SPACING_MEDIUM }) { // Apple风格：统一间距
        // TCP连接状态显示
        if (this.tcpConnected) {
          Text('设备连接正常')
            .fontSize(14) // Apple风格：统一字体大小
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getCurrentTheme().primary) // 使用主题色替代硬编码
            .padding({ left: AppleDesignStyle.SPACING_SMALL, right: AppleDesignStyle.SPACING_SMALL, top: AppleDesignStyle.SPACING_XS, bottom: AppleDesignStyle.SPACING_XS })
            .backgroundColor(this.getCurrentTheme().primary + '15') // Apple风格：15%透明度背景
            .borderRadius(AppleDesignStyle.BORDER_RADIUS_SMALL)
        } else {
          Text('设备故障，请排查')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FF3B30') // Apple标准错误红色
            .padding({ left: AppleDesignStyle.SPACING_SMALL, right: AppleDesignStyle.SPACING_SMALL, top: AppleDesignStyle.SPACING_XS, bottom: AppleDesignStyle.SPACING_XS })
            .backgroundColor('#FF3B3015')
            .borderRadius(AppleDesignStyle.BORDER_RADIUS_SMALL)
        }
        
        Text(this.statusText)
          .fontSize(14)
          .fontColor(this.getCurrentTheme().subTextColor)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(VerticalAlign.Center)
      .height('40%')
      .margin({ right: AppleDesignStyle.SPACING_LARGE })

      // 客户公司 LOGO + 农场名称 + 分选种类（放在状态区与FSM切换之间）
      Row({ space: AppleDesignStyle.SPACING_SMALL }) {
        Image(this.customerLogoUrl && this.customerLogoUrl.length > 0 ? this.customerLogoUrl : $r('app.media.customer_logo'))
          .width('4%')
          .height('70%')
          .objectFit(ImageFit.Contain)
          .borderRadius(AppleDesignStyle.BORDER_RADIUS_SMALL) // Apple风格：圆角
          .border({ width: AppleDesignStyle.BORDER_WIDTH_THIN, color: this.getCurrentTheme().borderColor }) // Apple风格：细边框
          .margin({ right: AppleDesignStyle.SPACING_SMALL })

        Column({ space: 2 }) {
          Text(this.farmName && this.farmName.length > 0 ? this.farmName : '— 农场 —')
            .fontSize(14) // Apple风格：统一字体大小
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getCurrentTheme().textColor)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.fruitType && this.fruitType.length > 0 ? this.fruitType : '— 分选种类 —')
            .fontSize(12) // Apple风格：更小的副标题字体
            .fontColor(this.getCurrentTheme().subTextColor)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.Start)
      }
      .alignItems(VerticalAlign.Center)
      .width('auto')
      .margin({ right: AppleDesignStyle.SPACING_LARGE })

      // 使用固定宽度的空白，而不是layoutWeight，减少中间空白
      Blank().width(40)

      // 个人信息区域：FSM切换 + 头像 + 姓名/管理员
      Row({ space: AppleDesignStyle.SPACING_MEDIUM }) {
        // FSM切换按钮
        CompactFsmToggle({
          selectedFSM: this.selectedFSM,
          onFSMChange: (fsm: 'FSM1' | 'FSM2') => {
            if (this.onFSMChange) {
              this.onFSMChange(fsm)
            }
          }
        })

        // 头像和用户信息
        Row({ space: AppleDesignStyle.SPACING_SMALL }) {
          IBestAvatar({
            src: AppStorage.get('SELECTED_AVATAR_URL') || 'https://img1.baidu.com/it/u=700838104,4078529388&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500',
            defaultAvatar: $r('app.media.default_avatar'),
            avatarSize: 36, // Apple风格：稍微小一点
            shape: 'circle',
            onAvatarClick: () => {
              AppStorage.setOrCreate('TEMP_USER_LABEL', this.userLabel)
              AppStorage.setOrCreate('EDIT_USER_LABEL_VISIBLE', true)
            }
          })

          Column({ space: 2 }) {
            Text(this.userLabel)
              .fontSize(13) // Apple风格：统一字体大小
              .fontColor(this.getCurrentTheme().subTextColor)
            Text('管理员')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.getCurrentTheme().textColor)
          }
          .alignItems(HorizontalAlign.Start)
          .onClick(() => {
            AppStorage.setOrCreate('TEMP_USER_LABEL', this.userLabel)
            AppStorage.setOrCreate('EDIT_USER_LABEL_VISIBLE', true)
          })
        }
        .alignItems(VerticalAlign.Center)
      }
      .alignItems(VerticalAlign.Center)
      .margin({ right: AppleDesignStyle.SPACING_MEDIUM })

      // 时间显示（两行：日期+时间）
      Column({ space: 2 }) {
        Text(this.currentDate)
          .fontSize(12) // 日期字体稍小
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getCurrentTheme().subTextColor)
        Text(this.currentTime)
          .fontSize(14) // 时间字体稍大，更突出
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getCurrentTheme().textColor)
      }
      .alignItems(HorizontalAlign.End) // 右对齐
      .margin({ right: AppleDesignStyle.SPACING_MEDIUM })

      // 右上角窗口控制 - Vue 动画效果
      Row({ space: AppleDesignStyle.SPACING_SMALL }) {
        // 最小化按钮 - Vue 动画效果
        AnimatedMinimizeButton({
          onClickHandler: () => { this.minimizeApp() }
        })

        // 关闭按钮 - Vue 动画效果
        AnimatedCloseButton({
          onClickHandler: () => { this.closeApp() }
        })
      }

      // （对话框改为系统级 CustomDialogController 实现）
    }
    .width('100%')
    .height('8%')
    .padding({ left: AppleDesignStyle.SPACING_LARGE, right: AppleDesignStyle.SPACING_LARGE, top: AppleDesignStyle.SPACING_MEDIUM, bottom: AppleDesignStyle.SPACING_MEDIUM }) // Apple风格：统一内边距
    .backgroundColor(this.getCurrentTheme().surfaceColor)
    .border({ width: { bottom: AppleDesignStyle.BORDER_WIDTH_THIN }, color: this.getCurrentTheme().borderColor }) // Apple风格：细边框
    .shadow(AppleDesignStyle.getShadowSmall()) // Apple风格：柔和阴影
  }

}


