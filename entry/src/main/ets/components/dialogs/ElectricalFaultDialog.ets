/**
 * 电气故障设置对话框组件 (基础故障)
 * 功能：显示电气故障信息列表，支持导入和保存功能
 * 布局：三列表格（代码、模块、信息） + 底部两个按钮（导入、保存）
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { t, I18N_VERSION_KEY } from '../../utils/i18n/I18nManager'
import { getMoreSystemSettingsStorage, MoreFaultItem } from '../../utils/storage/MoreSystemSettingsStorage'

// 电气故障信息接口
interface ElectricalFaultItem {
  code: string         // 代码
  module: string       // 模块
  message: string      // 信息
}

@Component
export struct ElectricalFaultDialog {
  @Prop isVisible: boolean = false
  @StorageLink(OMNI_THEME_KEY) @Watch('onThemeChange') consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_VERSION_KEY) @Watch('onThemeChange') themeVersion: number = 0
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0

  // 故障列表数据（仅用于UI展示，实际数据由外部提供或通过导入加载）
  @State faultList: ElectricalFaultItem[] = []
  @State selectedIndex: number = -1  // 选中的行索引

  // 对话框回调
  onCancel?: () => void
  onLoad?: () => void
  onSave?: () => void

  aboutToAppear(): void {
    const items = getMoreSystemSettingsStorage().getElectricalFaults()
    const nextList: ElectricalFaultItem[] = []
    for (let i = 0; i < items.length; i++) {
      const item: ElectricalFaultItem = { code: items[i].code, module: items[i].module, message: items[i].message }
      nextList.push(item)
    }
    this.faultList = nextList
  }

  // 获取当前主题配置
  getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.consumedTheme)
  }

  // 监听主题变化
  onThemeChange(): void {
    console.log('ElectricalFaultDialog: 主题已变化，重新渲染')
  }

  // 关闭按钮点击
  private handleCancel(): void {
    if (this.onCancel) {
      this.onCancel()
    }
  }

  // 导入按钮点击
  private handleLoad(): void {
    console.log('导入电气故障配置')
    if (this.onLoad) {
      this.onLoad()
    }
    const items = getMoreSystemSettingsStorage().getElectricalFaults()
    const nextList: ElectricalFaultItem[] = []
    for (let i = 0; i < items.length; i++) {
      const item: ElectricalFaultItem = { code: items[i].code, module: items[i].module, message: items[i].message }
      nextList.push(item)
    }
    this.faultList = nextList
  }

  // 保存按钮点击
  private handleSave(): void {
    console.log('保存电气故障配置', this.faultList)
    const items: MoreFaultItem[] = []
    for (let i = 0; i < this.faultList.length; i++) {
      items.push(new MoreFaultItem(this.faultList[i].code, this.faultList[i].module, this.faultList[i].message))
    }
    getMoreSystemSettingsStorage().setElectricalFaults(items)
    if (this.onSave) {
      this.onSave()
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
          // 标题栏（深绿色背景）
          Row() {
            Text(t('基础故障', '基础故障'))
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .layoutWeight(1)
              .textAlign(TextAlign.Start)
              .margin({ left: 12 })

            Button() {
              Text('×')
                .fontSize(20)
                .fontColor(Color.White)
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
          .padding({ left: 0, right: 12 })
          .backgroundColor('#2E7D32')
          .borderRadius({ topLeft: 8, topRight: 8 })

          // 内容区域（表格）
          Column({ space: 0 }) {
            // 固定表头（绿色背景）
            Row() {
              Text(t('代码', '代码'))
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .width(100)
                .textAlign(TextAlign.Center)
                .padding({ top: 8, bottom: 8 })
                .border({ width: 0.5, color: '#1B5E20' })
                .backgroundColor('#4CAF50')

              Text(t('模块', '模块'))
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .width(120)
                .textAlign(TextAlign.Center)
                .padding({ top: 8, bottom: 8 })
                .border({ width: 0.5, color: '#1B5E20' })
                .backgroundColor('#4CAF50')

              Text(t('信息', '信息'))
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
                .padding({ top: 8, bottom: 8, left: 4, right: 4 })
                .border({ width: 0.5, color: '#1B5E20' })
                .backgroundColor('#4CAF50')
            }
            .width('100%')
            .height(40)
            .margin({ bottom: 0 })

            // 可滚动数据区域
            List() {
              ForEach(this.faultList, (item: ElectricalFaultItem, index: number) => {
                ListItem() {
                  Row() {
                    Text(item.code)
                      .fontSize(13)
                      .fontColor(this.getCurrentTheme().textColor)
                      .width(100)
                      .textAlign(TextAlign.Center)
                      .padding({ left: 4, right: 4, top: 6, bottom: 6 })

                    Text(item.module || '')
                      .fontSize(13)
                      .fontColor(this.getCurrentTheme().textColor)
                      .width(120)
                      .textAlign(TextAlign.Center)
                      .padding({ left: 4, right: 4, top: 6, bottom: 6 })

                    Text(item.message)
                      .fontSize(13)
                      .fontColor(this.getCurrentTheme().textColor)
                      .layoutWeight(1)
                      .textAlign(TextAlign.Center)
                      .padding({ left: 4, right: 4, top: 6, bottom: 6 })
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  .width('100%')
                  .height(40)
                  .backgroundColor(this.selectedIndex === index ? '#E3F2FD' : Color.White)
                  .border({ width: { bottom: 1 }, color: '#E0E0E0' })
                  .onClick(() => {
                    this.selectedIndex = index
                  })
                }
              }, (item: ElectricalFaultItem, index: number) => `${item.code}-${index}`)
            }
            .layoutWeight(1)
            .width('100%')
            .scrollBar(BarState.Auto)
            .edgeEffect(EdgeEffect.Spring)
            .friction(100)
          }
          .layoutWeight(1)
          .width('100%')
          .backgroundColor(this.getCurrentTheme().surfaceColor)

          // 底部按钮区域（只有导入和保存两个按钮）
          Row() {
            // 导入按钮
            Button(t('导入', '导入'))
              .type(ButtonType.Normal)
              .fontSize(14)
              .fontColor(this.getCurrentTheme().textColor)
              .backgroundColor(Color.White)
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
              .width(100)
              .height(36)
              .borderRadius(4)
              .margin({ right: 12 })
              .onClick(() => {
                this.handleLoad()
              })

            // 保存按钮
            Button(t('保存', '保存'))
              .type(ButtonType.Normal)
              .fontSize(14)
              .fontColor(Color.White)
              .backgroundColor('#228B22')
              .width(100)
              .height(36)
              .borderRadius(4)
              .onClick(() => {
                this.handleSave()
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.End)
          .padding({ top: 12, bottom: 12, left: 16, right: 16 })
          .backgroundColor(this.getCurrentTheme().surfaceColor)
        }
        .width(850)
        .height(600)
        .backgroundColor(this.getCurrentTheme().surfaceColor)
        .borderRadius(8)
        .shadow({
          radius: 20,
          color: 'rgba(0, 0, 0, 0.3)',
          offsetX: 0,
          offsetY: 4
        })
        .align(Alignment.Center)
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(1000)
  }
}
