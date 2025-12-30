/**
 * 品质参数设置对话框组件
 * 功能：配置品质相关参数
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { t, I18N_VERSION_KEY } from '../../utils/i18n/I18nManager'

@Component
export struct QualitySettingsDialog {
  @Prop isVisible: boolean = false
  @StorageLink(OMNI_THEME_KEY) @Watch('onThemeChange') consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_VERSION_KEY) @Watch('onThemeChange') themeVersion: number = 0
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0

  // 选中的计算单位
  @Prop selectedUnit: string = 'gram'

  // 对话框回调
  onConfirm?: () => void
  onCancel?: () => void
  onUnitChange?: (unit: string) => void

  // 获取当前主题配置
  getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.consumedTheme)
  }

  // 监听主题变化
  onThemeChange(): void {
    console.log('QualitySettingsDialog: 主题已变化，重新渲染')
  }

  // 确认按钮点击
  private handleConfirm(): void {
    if (this.onConfirm) {
      this.onConfirm()
    }
  }

  // 取消/关闭按钮点击
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
          // 标题栏（绿色背景）
          Row() {
            Text('品质参数设置')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)

            Button() {
              Image($r('sys.media.ohos_ic_public_close'))
                .width(20)
                .height(20)
                .fillColor(Color.White)
            }
            .type(ButtonType.Normal)
            .backgroundColor(Color.Transparent)
            .width(32)
            .height(32)
            .onClick(() => {
              this.handleCancel()
            })
          }
          .width('100%')
          .height(48)
          .padding({ left: 20, right: 12, top: 8, bottom: 8 })
          .backgroundColor('#4CAF50')
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)

          // 内容区域
          Scroll() {
            Column() {
              // 计算每箱单位卡片
              Column() {
                // 标题区域（浅蓝色背景）
                Row() {
                  Text(t('计算每箱单位', '计算每箱单位'))
                    .fontSize(20)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Color.White)
                }
                .width('100%')
                .backgroundColor('#87CEEB') // 浅蓝色（天蓝色）
                .borderRadius({ topLeft: 8, topRight: 8 })
                .padding({ left: 12, right: 12, top: 10, bottom: 10 })

                // 内容区域（浅色背景）
                Column() {
                  // 单位选择单选按钮（横向排布）
                  Row() {
                    // 克选项
                    Row() {
                      Radio({ value: 'gram', group: 'unit' })
                        .checked(this.selectedUnit === 'gram')
                        .width(14)
                        .height(14)
                        .onChange((isChecked: boolean) => {
                          if (isChecked && this.onUnitChange) {
                            this.onUnitChange('gram')
                          }
                        })
                      Text(t('克', '克'))
                        .fontSize(22)
                        .fontColor(this.getCurrentTheme().textColor)
                        .margin({ left: 4 })
                    }
                    .alignItems(VerticalAlign.Center)
                    .margin({ right: 16 })

                    // 个选项
                    Row() {
                      Radio({ value: 'piece', group: 'unit' })
                        .checked(this.selectedUnit === 'piece')
                        .width(14)
                        .height(14)
                        .onChange((isChecked: boolean) => {
                          if (isChecked && this.onUnitChange) {
                            this.onUnitChange('piece')
                          }
                        })
                      Text(t('个', '个'))
                        .fontSize(22)
                        .fontColor(this.getCurrentTheme().textColor)
                        .margin({ left: 4 })
                    }
                    .alignItems(VerticalAlign.Center)
                  }
                  .width('100%')
                  .alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.Start)
                  .padding({ top: 12, bottom: 12 })
                }
                .width('100%')
                .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                .borderRadius({ bottomLeft: 8, bottomRight: 8 })
                .padding({ left: 12, right: 12 })
              }
              .width('100%')
              .backgroundColor(Color.Transparent)
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
              .borderRadius(8)
              .shadow({ radius: 8, color: 'rgba(0,0,0,0.15)', offsetY: 2 })
              .margin({ bottom: 20 })
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 20, bottom: 20 })
          }
          .layoutWeight(1)
          .width('100%')
          .scrollBar(BarState.Auto)

          // 底部按钮区域
          Row() {
            Blank().layoutWeight(1)

            // 取消按钮
            Button('取消')
              .fontSize(16)
              .fontColor(this.getCurrentTheme().textColor)
              .backgroundColor(this.getCurrentTheme().backgroundColor)
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
              .borderRadius(8)
              .width(100)
              .height(40)
              .onClick(() => {
                this.handleCancel()
              })

            // 确定按钮
            Button('确定')
              .fontSize(16)
              .fontColor(Color.White)
              .backgroundColor('#4CAF50')
              .borderRadius(8)
              .width(100)
              .height(40)
              .margin({ left: 12 })
              .onClick(() => {
                this.handleConfirm()
              })
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 16, bottom: 20 })
        }
        .width(1200)
        .height(900)
        .backgroundColor(this.getCurrentTheme().surfaceColor)
        .borderRadius(12)
        .shadow({
          radius: 20,
          color: 'rgba(0, 0, 0, 0.1)',
          offsetX: 0,
          offsetY: 4
        })
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
  }
}

