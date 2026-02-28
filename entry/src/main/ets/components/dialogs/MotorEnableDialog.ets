/**
 * 电机使能对话框组件
 * 功能：显示电机使能设置界面，包含出口延时时间和持续时间设置
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { t, I18N_VERSION_KEY } from '../../utils/i18n/I18nManager'
import { NumericInput } from '../ui/inputs/NumericInput'
import { ToastDialog } from './ToastDialog'
import { getConfigSender } from '../../protocol/ConfigSender'
import { ConstPreDefine } from '../../protocol/ConstPreDefine'
import { StMotorInfo } from '../../protocol/Structures'

// 出口数据接口
interface OutletMotorData {
  name: string
  delayTime: number
  durationTime: number
}

@Component
export struct MotorEnableDialog {
  @Prop isVisible: boolean = false
  @StorageLink(OMNI_THEME_KEY) @Watch('onThemeChange') consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_VERSION_KEY) @Watch('onThemeChange') themeVersion: number = 0
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0

  @State private showToastDialog: boolean = false
  @State private toastType: 'success' | 'error' = 'success'
  @State private toastMessage: string = ''

  // 出口数据
  @State outletMotorDataList: OutletMotorData[] = [
    { name: '出口 1', delayTime: 0, durationTime: 0 },
    { name: '出口 2', delayTime: 0, durationTime: 0 },
    { name: '出口 3', delayTime: 0, durationTime: 0 },
    { name: '出口 4', delayTime: 0, durationTime: 0 },
    { name: '出口 5', delayTime: 0, durationTime: 0 },
    { name: '出口 6', delayTime: 0, durationTime: 0 },
    { name: '出口 7', delayTime: 0, durationTime: 0 },
    { name: '出口 8', delayTime: 0, durationTime: 0 },
    { name: '出口 9', delayTime: 0, durationTime: 0 },
    { name: '出口 10', delayTime: 0, durationTime: 0 },
    { name: '出口 11', delayTime: 0, durationTime: 0 },
    { name: '出口 12', delayTime: 0, durationTime: 0 },
    { name: '出口 13', delayTime: 0, durationTime: 0 },
    { name: '出口 14', delayTime: 0, durationTime: 0 },
    { name: '出口 15', delayTime: 0, durationTime: 0 }
  ]

  // 获取当前主题配置
  getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.consumedTheme)
  }

  // 监听主题变化
  onThemeChange(): void {
    console.log('MotorEnableDialog: 主题已变化，重新渲染')
  }

  // 对话框回调
  onCancel?: () => void

  private showToast(type: 'success' | 'error', message: string): void {
    this.toastType = type
    this.toastMessage = message
    this.showToastDialog = true
    setTimeout(() => {
      this.showToastDialog = false
    }, 1500)
  }

  private getSelectedFsmId(): number {
    const selected = (AppStorage.get('HOME_SELECTED_FSM') as ('FSM1' | 'FSM2') | undefined) ?? 'FSM1'
    return selected === 'FSM1' ? ConstPreDefine.getFsmId(0) : ConstPreDefine.getFsmId(1)
  }

  // 关闭对话框
  private handleClose(): void {
    if (this.onCancel) {
      this.onCancel()
    }
  }

  // 出果清框
  private async handleClearFrame(): Promise<void> {
    try {
      const ok = await getConfigSender().sendExitClear()
      if (ok) {
        this.showToast('success', t('出果清框命令已发送', '出果清框命令已发送'))
      } else {
        this.showToast('error', t('出果清框命令发送失败，请检查设备连接', '出果清框命令发送失败，请检查设备连接'))
      }
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e)
      this.showToast('error', t('出果清框失败', '出果清框失败') + ': ' + msg)
    }
  }

  // 全部出框
  private async handleAllFrames(): Promise<void> {
    const fsmId = this.getSelectedFsmId()
    try {
      const ok = await getConfigSender().sendMotorEnable(fsmId)
      if (ok) {
        this.showToast('success', t('全部出框命令已发送', '全部出框命令已发送'))
      } else {
        this.showToast('error', t('全部出框命令发送失败，请检查设备连接', '全部出框命令发送失败，请检查设备连接'))
      }
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e)
      this.showToast('error', t('全部出框失败', '全部出框失败') + ': ' + msg)
    }
  }

  // 立即生效（按行下发 MOTOR_INFO，写入每个出口的延时/持续）
  private async handleApply(): Promise<void> {
    const fsmId = this.getSelectedFsmId()
    try {
      let successCount = 0
      for (let i = 0; i < this.outletMotorDataList.length; i++) {
        const row = this.outletMotorDataList[i]
        const info = new StMotorInfo()
        info.bExitId = i
        info.bMotorSwitch = 2
        info.nMotorEnableSwitchNum = 0
        info.nMotorEnableSwitchWeight = 0
        info.fDelay_time = row.delayTime
        info.fHold_time = row.durationTime
        const ok = await getConfigSender().sendMotorInfo(fsmId, info)
        if (ok) {
          successCount++
        }
      }

      if (successCount > 0) {
        this.showToast('success', t('电机参数已下发', '电机参数已下发') + ` (${successCount}/${this.outletMotorDataList.length})`)
      } else {
        this.showToast('error', t('电机参数发送失败，请检查设备连接', '电机参数发送失败，请检查设备连接'))
      }
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e)
      this.showToast('error', t('电机参数下发失败', '电机参数下发失败') + ': ' + msg)
    }
  }

  // 更新出口数据
  private updateOutletData(index: number, field: 'delayTime' | 'durationTime', value: number): void {
    const newList: OutletMotorData[] = []
    for (let i = 0; i < this.outletMotorDataList.length; i++) {
      if (i === index) {
        const newItem: OutletMotorData = {
          name: this.outletMotorDataList[i].name,
          delayTime: field === 'delayTime' ? value : this.outletMotorDataList[i].delayTime,
          durationTime: field === 'durationTime' ? value : this.outletMotorDataList[i].durationTime
        }
        newList.push(newItem)
      } else {
        newList.push(this.outletMotorDataList[i])
      }
    }
    this.outletMotorDataList = newList
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
          this.handleClose()
        })

      // 对话框内容
      Column() {
        // 标题栏
        Row() {
          Text('电机使能')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .layoutWeight(1)

          Button() {
            Text('×')
              .fontSize(24)
              .fontColor(this.getCurrentTheme().textColor)
          }
          .type(ButtonType.Normal)
          .backgroundColor('transparent')
          .width(32)
          .height(32)
          .onClick(() => {
            this.handleClose()
          })
        }
        .width('100%')
        .height(50)
        .padding({ left: 20, right: 12, top: 12, bottom: 12 })
        .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })

        // 内容区域
        Scroll() {
          Column({ space: 12 }) {
            // 表格
            Column() {
              // 表头
              Row() {
                Text('名称')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.getCurrentTheme().textColor)
                  .width(120)
                  .textAlign(TextAlign.Center)
                  .border({ width: { right: 1, bottom: 1 }, color: this.getCurrentTheme().borderColor })
                  .padding(8)

                Text('延时时间')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.getCurrentTheme().textColor)
                  .layoutWeight(1)
                  .textAlign(TextAlign.Center)
                  .border({ width: { right: 1, bottom: 1 }, color: this.getCurrentTheme().borderColor })
                  .padding(8)

                Text('持续时间')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.getCurrentTheme().textColor)
                  .layoutWeight(1)
                  .textAlign(TextAlign.Center)
                  .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })
                  .padding(8)
              }
              .width('100%')
              .backgroundColor(this.getCurrentTheme().controlBg || this.getCurrentTheme().surfaceColor)

              // 表格内容
              ForEach(this.outletMotorDataList, (item: OutletMotorData, index: number) => {
                Row() {
                  Text(item.name)
                    .fontSize(13)
                    .fontColor(this.getCurrentTheme().textColor)
                    .width(120)
                    .textAlign(TextAlign.Center)
                    .border({ width: { right: 1 }, color: this.getCurrentTheme().borderColor })
                    .padding(8)

                  TextInput({ text: item.delayTime.toString() })
                    .type(InputType.Number)
                    .layoutWeight(1)
                    .height(32)
                    .margin(4)
                    .backgroundColor('#FFFFFF')
                    .border({ width: 1, color: '#CCCCCC' })
                    .borderRadius(4)
                    .fontSize(13)
                    .onChange((value: string) => {
                      const num = parseInt(value)
                      if (!isNaN(num) && num >= 0 && num <= 9999) {
                        this.updateOutletData(index, 'delayTime', num)
                      }
                    })

                  TextInput({ text: item.durationTime.toString() })
                    .type(InputType.Number)
                    .layoutWeight(1)
                    .height(32)
                    .margin(4)
                    .backgroundColor('#FFFFFF')
                    .border({ width: 1, color: '#CCCCCC' })
                    .borderRadius(4)
                    .fontSize(13)
                    .onChange((value: string) => {
                      const num = parseInt(value)
                      if (!isNaN(num) && num >= 0 && num <= 9999) {
                        this.updateOutletData(index, 'durationTime', num)
                      }
                    })
                }
                .width('100%')
                .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })
              })
            }
            .width('100%')
            .border({ width: 1, color: this.getCurrentTheme().borderColor })
            .borderRadius(4)
            .margin({ top: 8 })
          }
          .width('100%')
          .padding(20)
        }
        .layoutWeight(1)
        .width('100%')

        // 底部按钮区域
        Row({ space: 12 }) {
          Button('出果清框')
            .type(ButtonType.Normal)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#4CAF50')
            .borderRadius(4)
            .width(100)
            .height(36)
            .onClick(() => {
              void this.handleClearFrame()
            })

          Button('全部出框')
            .type(ButtonType.Normal)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#4CAF50')
            .borderRadius(4)
            .width(100)
            .height(36)
            .onClick(() => {
              void this.handleAllFrames()
            })

          Blank()

          Button('立即生效')
            .type(ButtonType.Normal)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#4CAF50')
            .borderRadius(4)
            .width(100)
            .height(36)
            .onClick(() => {
              void this.handleApply()
            })

          Button('取消')
            .type(ButtonType.Normal)
            .fontSize(14)
            .fontColor(this.getCurrentTheme().textColor)
            .backgroundColor('#E0E0E0')
            .borderRadius(4)
            .width(100)
            .height(36)
            .onClick(() => {
              this.handleClose()
            })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 12, bottom: 20 })
        .border({ width: { top: 1 }, color: this.getCurrentTheme().borderColor })
      }
      .width('70%')
      .height('75%')
      .backgroundColor(this.getCurrentTheme().surfaceColor)
      .borderRadius(12)
      .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.3)', offsetY: 4 })
      .alignSelf(ItemAlign.Center)
      .constraintSize({ maxWidth: 700, maxHeight: 600 })

      ToastDialog({
        isVisible: this.showToastDialog,
        type: this.toastType,
        message: this.toastMessage
      })
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
  }
}

