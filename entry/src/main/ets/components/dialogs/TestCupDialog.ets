/**
 * 测试果杯对话框组件
 * 功能：显示测试果杯的确认提示信息
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { t, I18N_VERSION_KEY } from '../../utils/i18n/I18nManager'

@Component
export struct TestCupDialog {
  @Prop isVisible: boolean = false
  @Prop message: string = '请确认分选机上无任何水果!'
  @StorageLink(OMNI_THEME_KEY) @Watch('onThemeChange') consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_VERSION_KEY) @Watch('onThemeChange') themeVersion: number = 0
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0

  // 对话框回调
  onConfirm?: () => void
  onCancel?: () => void

  // 获取当前主题配置
  getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.consumedTheme)
  }

  // 监听主题变化
  onThemeChange(): void {
    console.log('TestCupDialog: 主题已变化，重新渲染')
  }

  // 开始测试按钮点击
  private handleStartTest(): void {
    if (this.onConfirm) {
      this.onConfirm()
    }
  }

  // 关闭按钮点击
  private handleCancel(): void {
    if (this.onCancel) {
      this.onCancel()
    }
  }

  build() {
    // 对话框遮罩层
    Stack() {
      if (!this.isVisible) {
        // 不可见时返回空内容
        Blank()
      } else {
      // 背景遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.handleCancel()
        })

      // 对话框内容
      Column() {
        // 标题栏（青色背景）
        Row() {
          Text('测试果杯')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .layoutWeight(1)

          Button() {
            Text('×')
              .fontSize(20)
              .fontColor('#FFFFFF')
          }
          .type(ButtonType.Normal)
          .backgroundColor('transparent')
          .width(28)
          .height(28)
          .onClick(() => {
            this.handleCancel()
          })
        }
        .width('100%')
        .height(40)
        .padding({ left: 16, right: 10, top: 8, bottom: 8 })
        .backgroundColor('#4CAF50') // 青色/绿色背景

        // 消息内容区域
        Column() {
          Text(this.message)
            .fontSize(14)
            .fontColor(this.getCurrentTheme().textColor)
            .textAlign(TextAlign.Center)
            .padding(20)
        }
        .width('100%')
        .backgroundColor('#FFFFFF')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        // 底部按钮区域
        Row() {
          Button('开始测试')
            .type(ButtonType.Normal)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#4CAF50') // 绿色背景
            .borderRadius(4)
            .width(100)
            .height(36)
            .onClick(() => {
              this.handleStartTest()
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ left: 16, right: 16, top: 10, bottom: 16 })
        .backgroundColor('#FFFFFF')
      }
      .width('40%')
      .backgroundColor('#FFFFFF')
      .borderRadius(8)
      .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.3)', offsetY: 4 })
      .alignSelf(ItemAlign.Center)
      .constraintSize({ maxWidth: 400 })
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
  }
}

