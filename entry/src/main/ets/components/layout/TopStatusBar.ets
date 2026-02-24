import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { TOP_PRODUCTION_TON_H, TOP_SUM_WEIGHT_TON, TOP_SUM_COUNTS, TOP_AVG_G, TOP_STATUS_TEXT, TOP_ALERT_HIDE, TCP_CONNECTION_STATUS } from '../../constants/TopBarKeys'
import { CompactFsmToggle } from './CompactFsmToggle'
import { IBestAvatar, IBestButton } from '@ibestservices/ibest-ui'
import common from '@ohos.app.ability.common'
import { MinimizeAppUtil } from '../../utils/window/MinimizeAppUtil'
import { AppleDesignStyle } from '../../utils/theme/AppleDesignStyle'
import { ThreeDButton } from '../ui/buttons/ThreeDButton'
import { ProfileInfoBar } from './ProfileInfoBar'

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
  onEditCustomer?: () => void
  @Prop layoutMode: 'top' | 'side' = 'top'
  
  // 实时时间状态（两行显示）
  @State private currentDate: string = ''
  @State private currentTime: string = ''
  @State private showSubsystemDropdown: boolean = false
  private timeTimer: number | null = null

  // 模拟数据
  @State private mockFaults: string[] = [
    '[user]: 通信异常 11111111111，换行测试。',
    '[user1]: 运行正常',
    '[user2]: 通信异常 11111111111，换行测试，换行会...'
  ]

  @State private mockLogs: string[] = [
    '[ERR]: 通信异常 11111111111，换行测试。',
    '[ERR1]: 运行正常',
    '[ERR2]: 通信异常 11111111111，换行测试，换行会...',
    '[ERR3]: 通信异常 11111111111，换行测试。'
  ]

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
  }

  aboutToDisappear() {
    // 清理定时器
    if (this.timeTimer) {
      clearInterval(this.timeTimer)
      this.timeTimer = null
    }
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

  private getSubsystemLabel(): string {
    return this.selectedFSM === 'FSM1' ? '子系统 1' : '子系统 2'
  }

  @Builder
  private buildSubsystemMenuItem(label: string, fsm: 'FSM1' | 'FSM2') {
    Row() {
      Text(label)
        .fontSize(16)
        .fontColor('#333')
    }
    .width('100%')
    .height(40)
    .padding({ left: 12, right: 12 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor(this.selectedFSM === fsm ? '#e6f0ff' : Color.White)
    .onClick(() => {
      this.showSubsystemDropdown = false
      if (this.onFSMChange) {
        this.onFSMChange(fsm)
      }
    })
  }

  @Builder
  private buildSubsystemMenu() {
    Column() {
      this.buildSubsystemMenuItem('子系统 1', 'FSM1')
      this.buildSubsystemMenuItem('子系统 2', 'FSM2')
    }
    .width(140)
    .backgroundColor(Color.White)
    .border({ width: 1, color: '#ddd' })
    .borderRadius(6)
    .padding({ top: 4, bottom: 4 })
  }

  build() {
    if (this.layoutMode === 'side') {
      Stack() {
        Column() {
          Row() {
            Row() {
              Text(this.getSubsystemLabel())
                .fontSize(16)
                .fontColor('#333')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text('▼')
                .fontSize(11)
                .fontColor('#666')
                .margin({ left: 6 })
            }
            .width(140)
            .height(44)
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
              .backgroundColor(Color.White)
              .border({ width: 1, color: '#ddd' })
              .borderRadius(6)
              .padding({ left: 14, right: 14 })
              .onClick(() => {
                this.showSubsystemDropdown = !this.showSubsystemDropdown
              })
              .bindPopup(this.showSubsystemDropdown, {
                builder: this.buildSubsystemMenu(),
                placement: Placement.Bottom,
                mask: false,
                popupColor: Color.Transparent,
                enableArrow: false,
                onStateChange: (e) => {
                  if (!e.isVisible) {
                    this.showSubsystemDropdown = false
                  }
                }
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .margin({ top: 10, bottom: 24 })
          .padding({ left: 10, right: 10 })
          Scroll() {
          Column() {
            Row({ space: 12 }) {
            Text('👨‍🌾')
              .fontSize(28)
              .fontColor(Color.White)
              .width(44)
              .height(44)
              .textAlign(TextAlign.Center)
              .backgroundColor('#4a90e2')
              .borderRadius(22)

            Column() {
              Text(this.userLabel)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Text(this.farmName)
                .fontSize(15)
                .fontColor('#999')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Start)
          .margin({ bottom: 36 })
          .onClick(() => {
            if (this.onEditCustomer) {
              this.onEditCustomer()
            }
          })

          Row({ space: 12 }) {
            Text('🍊')
              .fontSize(28)
              .fontColor(Color.White)
              .width(44)
              .height(44)
              .textAlign(TextAlign.Center)
              .backgroundColor('#ff8c00')
              .borderRadius(22)

            Text(this.fruitType)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333')
              .maxLines(1)
              .textAlign(TextAlign.Start)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Start)
          .margin({ bottom: 24 })
          .onClick(() => {
            if (this.onEditCustomer) {
              this.onEditCustomer()
            }
          })


          Column() {
            Text('状态监控')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333')
              .padding({ left: 0, right: 0, top: 6, bottom: 0 })
              .textAlign(TextAlign.Start) // 
              .width('100%') // 占满容器宽度
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start) // 容器内元素左对齐
          .margin({ bottom: 6 })

          Column() {
            this.buildStatusRow('效率(吨/小时)', this.productionTonPerHour)
            this.buildStatusRow('总量(吨)', this.sumWeightTon)
            this.buildStatusRow('总个数', this.sumCounts)
            this.buildStatusRow('平均重量(克)', this.avgGram)
          }
          .width('100%')
          .height(160)
          .justifyContent(FlexAlign.SpaceEvenly)
          .backgroundColor(Color.White)
          .border({ width: 1, color: '#ddd' })
          .borderRadius(4)
          .padding(8)

          this.buildLogSection('系统故障', this.mockFaults, 230)
          this.buildLogSection('操作日志', this.mockLogs, 230)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .align(Alignment.TopStart)
        }
        .height('100%')
      }
      .align(Alignment.TopStart)
      .width(150)
      .height('100%')
      .backgroundColor('#f8f8f8')
      .border({ width: { right: 1 }, color: '#ddd' })
    } else {
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

  @Builder
  private buildStatusRow(label: string, value: string) {
    Column() {
      Text(label)
        .fontSize(13)
        .fontColor('#666')
        .textAlign(TextAlign.Start)
        .width('100%')

      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .textAlign(TextAlign.Start)
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 2, right: 2 })
  }

  private getPrefixColor(prefix: string): string {
    if (prefix.includes('user') && !prefix.includes('1') && !prefix.includes('2')) return '#FF0000' // Red
    if (prefix.includes('ERR') && !prefix.includes('1') && !prefix.includes('2')) return '#FF0000' // Red
    if (prefix.includes('1')) return '#008000' // Green
    if (prefix.includes('2')) return '#FFA500' // Orange
    return '#333'
  }

  @Builder
  private buildLogItem(text: string) {
    if (text.startsWith('[') && text.indexOf(']') > -1) {
      Text() {
        Span(text.substring(0, text.indexOf(']') + 1))
          .fontColor(this.getPrefixColor(text.substring(0, text.indexOf(']') + 1)))
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
        Span(text.substring(text.indexOf(']') + 1))
          .fontColor('#333')
          .fontSize(13)
      }
      .width('100%')
      .textAlign(TextAlign.Start)
    } else {
      Text(text)
        .fontSize(13)
        .fontColor('#333')
        .width('100%')
        .textAlign(TextAlign.Start)
    }
  }

  @Builder
  private buildLogSection(title: string, data: string[], height: number) {
    Column() {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .padding({ left: 0, right: 0, top: 6, bottom: 0 })
        .textAlign(TextAlign.Start)
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 6 })

    List() {
      ForEach(data, (item: string) => {
        ListItem() {
          this.buildLogItem(item)
        }
        .width('100%')
        .margin({ bottom: 4 })
      })
    }
    .width('100%')
    .height(height)
    .backgroundColor(Color.White)
    .border({ width: 1, color: '#ddd' })
    .borderRadius(4)
    .padding(8)
    .alignListItem(ListItemAlign.Start)
    .scrollBar(BarState.Auto)
  }
}

@Component
export struct WindowControlButtons {
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
        interface MoveMinimize { moveMissionToBackground?: () => Promise<void> }
        const maybe = ctx as MoveMinimize
        if (typeof maybe.moveMissionToBackground === 'function') {
          await maybe.moveMissionToBackground()
        } else {
          console.warn('[WindowControlButtons] 不支持最小化且无退后台接口，已跳过')
        }
      }
    } catch (e) {
      console.error('[WindowControlButtons] 最小化失败:', JSON.stringify(e))
    }
  }

  private async closeApp() {
    try {
      const ctx = getContext(this) as common.UIAbilityContext
      await ctx.terminateSelf()
    } catch (e) {
      console.error('[WindowControlButtons] 关闭应用失败:', JSON.stringify(e))
    }
  }

  build() {
    Row({ space: 8 }) {
      ThreeDButton({
        text: '−',
        isSelected: false,
        buttonWidth: 36,
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
