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

      // 中部四项指标（优化布局：Label独占一行，单位移至数值旁，解决长文本显示问题）
      Row() {
        // 1. Production
        Column() {
          Text('Production')
            .fontSize(this.getCurrentTheme().fontLevel4 ?? 18) // 18px - Label
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getCurrentTheme().subTextColor)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.None })
          
          Row() {
            Text(this.productionTonPerHour)
              .fontSize(this.getCurrentTheme().fontLevel3 ?? 24) // 降级为 24px (Level 3)，32px 太大导致溢出
              .fontWeight(this.getCurrentTheme().fontWeightBold ?? FontWeight.Bold)
              .fontColor(this.getCurrentTheme().primary)
            Text('Ton/h')
              .fontSize(this.getCurrentTheme().fontLevel4 ?? 18)
              .fontColor(this.getCurrentTheme().subTextColor)
              .opacity(0.7)
              .margin({ left: 4, bottom: 4 })
              .alignSelf(ItemAlign.End)
          }
          .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ right: AppleDesignStyle.SPACING_MEDIUM })

        Divider()
          .vertical(true)
          .strokeWidth(AppleDesignStyle.BORDER_WIDTH_THIN)
          .color(this.getCurrentTheme().borderColor)
          .height('60%')
          .opacity(0.5)
          .margin({ left: '1%', right: '1%' })

        // 2. SumWeight
        Column() {
          Text('SumWeight')
            .fontSize(this.getCurrentTheme().fontLevel4 ?? 18)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getCurrentTheme().subTextColor)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.None })
          
          Row() {
            Text(this.sumWeightTon)
              .fontSize(this.getCurrentTheme().fontLevel3 ?? 24) // 降级为 24px
              .fontWeight(this.getCurrentTheme().fontWeightBold ?? FontWeight.Bold)
              .fontColor(this.getCurrentTheme().primary)
            Text('Ton')
              .fontSize(this.getCurrentTheme().fontLevel4 ?? 18)
              .fontColor(this.getCurrentTheme().subTextColor)
              .opacity(0.7)
              .margin({ left: 4, bottom: 4 })
              .alignSelf(ItemAlign.End)
          }
          .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ right: AppleDesignStyle.SPACING_MEDIUM })

        Divider()
          .vertical(true)
          .strokeWidth(AppleDesignStyle.BORDER_WIDTH_THIN)
          .color(this.getCurrentTheme().borderColor)
          .height('60%')
          .opacity(0.5)
          .margin({ left: '1%', right: '1%' })

        // 3. SumCounts
        Column() {
          Text('SumCounts')
            .fontSize(this.getCurrentTheme().fontLevel4 ?? 18)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getCurrentTheme().subTextColor)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.None })
          
          Row() {
            Text(this.sumCounts)
              .fontSize(this.getCurrentTheme().fontLevel3 ?? 24) // 降级为 24px
              .fontWeight(this.getCurrentTheme().fontWeightBold ?? FontWeight.Bold)
              .fontColor(this.getCurrentTheme().primary)
            Text('PCS')
              .fontSize(this.getCurrentTheme().fontLevel4 ?? 18)
              .fontColor(this.getCurrentTheme().subTextColor)
              .opacity(0.7)
              .margin({ left: 4, bottom: 4 })
              .alignSelf(ItemAlign.End)
          }
          .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ right: AppleDesignStyle.SPACING_MEDIUM })

        Divider()
          .vertical(true)
          .strokeWidth(AppleDesignStyle.BORDER_WIDTH_THIN)
          .color(this.getCurrentTheme().borderColor)
          .height('60%')
          .opacity(0.5)
          .margin({ left: '1%', right: '1%' })

        // 4. Avg
        Column() {
          Text('Avg')
            .fontSize(this.getCurrentTheme().fontLevel4 ?? 18)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getCurrentTheme().subTextColor)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.None })
          
          Row() {
            Text(this.avgGram)
              .fontSize(this.getCurrentTheme().fontLevel3 ?? 24) // 降级为 24px
              .fontWeight(this.getCurrentTheme().fontWeightBold ?? FontWeight.Bold)
              .fontColor(this.getCurrentTheme().primary)
            Text('g')
              .fontSize(this.getCurrentTheme().fontLevel4 ?? 18)
              .fontColor(this.getCurrentTheme().subTextColor)
              .opacity(0.7)
              .margin({ left: 4, bottom: 4 })
              .alignSelf(ItemAlign.End)
          }
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
          Row() {
            Text('●')
              .fontSize(12) // 保持小点，或者也改成18？点太大了不好看，但这不属于"字体"。保留12或改18。
              // 用户说 "I only use 4 sizes". 
              // 12 is not allowed. 
              // If I use 18, the dot will be huge. 
              // Maybe I should use a shape instead of Text for the dot?
              // But for now, let's try 18 and see if I can make it work, or just leave it as an "icon".
              // User said "4 sizes". I'll try 18 but maybe scale it?
              // Let's stick to 12 for "graphics" if possible, but user might complain.
              // I will use 18 but maybe specific font? No.
              // I will change it to 18.
              .fontSize(this.getCurrentTheme().fontLevel4 ?? 18)
              .fontColor(this.getCurrentTheme().primary)
              .margin({ right: 6 })
            Text('设备连接正常')
              .fontSize(this.getCurrentTheme().fontLevel4 ?? 18)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.getCurrentTheme().primary)
          }
          .height('100%')
          .padding({ left: 16, right: 16 })
          .backgroundColor(this.getCurrentTheme().primary + '15')
          .borderRadius(8)
          .alignItems(VerticalAlign.Center)
        } else {
          // 优化后的故障提示样式：占满高度
          Row() {
            Text('⚠️')
              .fontSize(this.getCurrentTheme().fontLevel3 ?? 24)
              .margin({ right: 8 })
            Text('设备故障，请排查')
              .fontSize(this.getCurrentTheme().fontLevel3 ?? 24) // 强调
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
          }
          .height('100%')
          .padding({ left: 20, right: 20 })
          .backgroundColor('#FF3B30') // 实心红背景
          .borderRadius(8)
          .shadow(AppleDesignStyle.getShadowSmall())
          .alignItems(VerticalAlign.Center)
        }
        
        Text(this.statusText)
          .fontSize(this.getCurrentTheme().fontLevel4 ?? 18)
          .fontColor(this.getCurrentTheme().subTextColor)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(VerticalAlign.Center)
      .height('100%') // 占满父容器高度（父容器有padding，所以是内容区高度）
      .margin({ right: AppleDesignStyle.SPACING_LARGE })

      // 客户公司 LOGO + 农场名称 + 分选种类（放在状态区与FSM切换之间）
      Row({ space: AppleDesignStyle.SPACING_SMALL }) {
        Image(this.customerLogoUrl && this.customerLogoUrl.length > 0 ? this.customerLogoUrl : $r('app.media.customer_logo'))
          .width('5%') // 放大图标：从4%改为5%
          .height('80%') // 放大图标：从70%改为80%
          .objectFit(ImageFit.Contain)
          .borderRadius(AppleDesignStyle.BORDER_RADIUS_SMALL) // Apple风格：圆角
          .border({ width: AppleDesignStyle.BORDER_WIDTH_THIN, color: this.getCurrentTheme().borderColor }) // Apple风格：细边框
          .margin({ right: AppleDesignStyle.SPACING_SMALL })

        Column({ space: 4 }) {
          Text(this.farmName && this.farmName.length > 0 ? this.farmName : '— 农场 —')
            .fontSize(this.getCurrentTheme().fontLevel3 ?? 24) // 24px - Title
            .fontWeight(this.getCurrentTheme().fontWeightBold ?? FontWeight.Bold) // Title - Bold
            .fontColor(this.getCurrentTheme().textColor)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.fruitType && this.fruitType.length > 0 ? this.fruitType : '— 分选种类 —')
            .fontSize(this.getCurrentTheme().fontLevel4 ?? 18) // 18px - Content
            .fontColor(this.getCurrentTheme().subTextColor)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.Start)
      }
      .alignItems(VerticalAlign.Center)
      .width('auto')
      .margin({ right: AppleDesignStyle.SPACING_LARGE })

      // 使用弹性空白占据剩余空间，确保窗口控制按钮在最右边
      Blank().layoutWeight(1)

      // 个人信息区域：FSM切换 + 个人信息栏
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

        // 新版个人信息栏（包含头像、姓名、角色、日期、时间）
        ProfileInfoBar({
          userName: this.userLabel,
          userRole: '管理员',
          currentDate: this.currentDate,
          currentTime: this.currentTime,
          avatarUrl: this.selectedAvatarUrl,
          isLoading: false
        })
      }
      .alignItems(VerticalAlign.Center)
      .margin({ right: '1%' }) // 使用百分比间距

      // 右上角窗口控制按钮（固定在最右边，使用ThreeDButton组件）
      Row({ space: AppleDesignStyle.SPACING_SMALL }) {
        // 最小化按钮 - 直接使用ThreeDButton组件
        ThreeDButton({
          text: '−',
          isSelected: false,
          buttonWidth: 40,
          buttonHeight: 40,
          fontSize: this.getCurrentTheme().fontLevel3 ?? 24, // 24px
          onClickCallback: () => { 
            this.minimizeApp() 
          }
        })

        // 关闭按钮 - 直接使用ThreeDButton组件
        ThreeDButton({
          text: '×',
          isSelected: false,
          buttonWidth: 40,
          buttonHeight: 40,
          fontSize: this.getCurrentTheme().fontLevel3 ?? 24, // 24px
          onClickCallback: () => { 
            this.closeApp() 
          }
        })
      }
      .margin({ right: '0.5%' }) // 使用百分比，确保在最右边且有适当间距

      // （对话框改为系统级 CustomDialogController 实现）
    }
    .width('100%')
    .height('8%')
    .backgroundColor(this.getCurrentTheme().headerColor ?? this.getCurrentTheme().backgroundColor)  // 顶部状态栏背景颜色
    .padding({ left: AppleDesignStyle.SPACING_LARGE, right: AppleDesignStyle.SPACING_LARGE, top: AppleDesignStyle.SPACING_MEDIUM, bottom: AppleDesignStyle.SPACING_MEDIUM }) // Apple风格：统一内边距
    .border({ width: { bottom: AppleDesignStyle.BORDER_WIDTH_THIN }, color: this.getCurrentTheme().borderColor }) // Apple风格：细边框
    .shadow(AppleDesignStyle.getShadowSmall()) // Apple风格：柔和阴影
  }

}


