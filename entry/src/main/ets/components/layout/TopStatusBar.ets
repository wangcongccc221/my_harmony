import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { TOP_PRODUCTION_TON_H, TOP_SUM_WEIGHT_TON, TOP_SUM_COUNTS, TOP_AVG_G, TOP_STATUS_TEXT, TOP_ALERT_HIDE, TCP_CONNECTION_STATUS } from '../../constants/TopBarKeys'
// 已移除自定义对话框

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
  
  // 实时时间状态
  @State private currentTime: string = ''
  private timeTimer: number | null = null

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
    this.currentTime = `${y}-${m}-${d} ${hh}:${mm}:${ss}`
  }

  build() {
    Row() {
      // 左侧 LOGO
      Row() {
        Image($r('app.media.logo'))
          .width(200)
          .height('100%')
          .objectFit(ImageFit.Contain)
          .margin({ left: 5, right: 20 })
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
          .width(1)
          .height(26)
          .backgroundColor(this.getCurrentTheme().borderColor)
          .margin({ left: 12, right: 12 })

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
          .width(1)
          .height(26)
          .backgroundColor(this.getCurrentTheme().borderColor)
          .margin({ left: 12, right: 12 })

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
          .width(1)
          .height(26)
          .backgroundColor(this.getCurrentTheme().borderColor)
          .margin({ left: 12, right: 12 })

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
      .margin({ right: 15 })

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
      .height(24)
      .margin({ right: 12 })

      Blank().layoutWeight(1)

      // 个人信息：头像 + 姓名/管理员（同一列），点击触发全屏居中弹窗（由页面根部渲染）
      Row() {
        Image($r('app.media.default_avatar'))
          .width(28)
          .height(28)
          .objectFit(ImageFit.Cover)
          .borderRadius(14)
          .border({ width: 1, color: this.getCurrentTheme().borderColor })

        Column() {
          Text(this.userLabel)
            .fontSize(16)  // 调大到16px
            .fontColor(this.getCurrentTheme().subTextColor)
          Text('管理员')
            .fontSize(16)  // 调大到16px
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getCurrentTheme().textColor)
        }
        .margin({ left: 8 })
        .alignItems(HorizontalAlign.Start)
      }
      .alignItems(VerticalAlign.Center)
      .margin({ right: 8 })
      .onClick(() => {
        AppStorage.setOrCreate('TEMP_USER_LABEL', this.userLabel)
        AppStorage.setOrCreate('EDIT_USER_LABEL_VISIBLE', true)
      })

      Text(this.currentTime)
        .fontSize(16)  // 调大到16px
        .fontColor(this.getCurrentTheme().subTextColor)

      // （对话框改为系统级 CustomDialogController 实现）
    }
    .width('100%')
    .height(56)
    .padding({ left: 5, right: 10 })
    .backgroundColor(this.getCurrentTheme().surfaceColor)
    .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })
  }

}


