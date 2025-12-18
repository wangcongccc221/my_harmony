/**
 * 工程设置对话框组件
 * 功能：显示工程参数配置，包含确认和取消按钮
 * 用途：在点击"工程设置"按钮时弹出
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { DialogButtons } from '../ui/dialogs/DialogButtons'
import { DialogHeader } from '../ui/dialogs/DialogHeader'
import { t, I18N_VERSION_KEY } from '../../utils/i18n/I18nManager'
import { SystemStructurePage } from './pages/SystemStructurePage'
import { ChannelRangePage } from './pages/ChannelRangePage'
import { ChannelExportPage } from './pages/ChannelExportPage'
import { WeightSettingsPage } from './pages/WeightSettingsPage'
import { FruitInfoPage } from './pages/FruitInfoPage'

// Tab配置接口
interface TabConfig {
  key: string
  label: string
}

@Component
export struct EngineeringSettingsDialog {
  @Prop isVisible: boolean = false
  @State selectedTab: string = '系统结构设置'
  @StorageLink(OMNI_THEME_KEY) @Watch('onThemeChange') consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_VERSION_KEY) @Watch('onThemeChange') themeVersion: number = 0
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0  // 监听语言变化，触发 UI 更新
  
  // Tab配置映射（依赖 i18nVersion 确保语言变化时重新计算）
  private getTabConfig(): TabConfig[] {
    const _version = this.i18nVersion
    return [
      { key: '系统结构设置', label: t('系统结构设置', '系统结构设置') },
      { key: '通道范围设置', label: t('通道范围设置', '通道范围设置') },
      { key: '通道出口设置', label: t('通道出口设置', '通道出口设置') },
      { key: '重量设置', label: t('重量设置', '重量设置') },
      { key: '水果信息设置', label: t('水果信息设置', '水果信息设置') }
    ]
  }

  // 对话框回调
  onConfirm?: () => void
  onCancel?: () => void

  // 获取当前主题配置
  getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.consumedTheme)
  }

  // 监听主题变化
  onThemeChange(): void {
    console.log('EngineeringSettingsDialog: 主题已变化，重新渲染')
  }


  // 确认按钮点击
  private handleConfirm() {
    if (this.onConfirm) {
      this.onConfirm()
    }
  }

  // 取消按钮点击
  private handleCancel() {
    if (this.onCancel) {
      this.onCancel()
    }
  }

  // 构建Tab导航栏
  @Builder
  buildTabBar() {
    Row() {
      ForEach(this.getTabConfig(), (tab: TabConfig) => {
        this.buildTab(tab.key, tab.label)
      })
    }
    .width('100%')
    .height(50)
    .backgroundColor(getCurrentTheme(this.consumedTheme).surfaceColor)
    .borderRadius(8)
    .margin({ left: 16, right: 16, top: 8, bottom: 8 })
    .justifyContent(FlexAlign.SpaceEvenly)
    .alignItems(VerticalAlign.Center)
    .opacity(this.i18nVersion >= 0 ? 1 : 1)  // 引用 i18nVersion 确保语言变化时重新渲染
  }

  // 构建单个Tab
  @Builder
  buildTab(tabKey: string, label: string) {
    Button(label)
      .fontSize(18)  // Tab按钮字体调大到18px
      .fontWeight(this.selectedTab === tabKey ? FontWeight.Bold : FontWeight.Normal)
      .fontColor(this.selectedTab === tabKey ? getCurrentTheme(this.consumedTheme).primary : getCurrentTheme(this.consumedTheme).textColor)
      .backgroundColor(this.selectedTab === tabKey ? getCurrentTheme(this.consumedTheme).primary + '20' : Color.Transparent)
      .borderRadius(8)  // 圆角调大
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })  // 内边距调大
      .onClick(() => {
        this.selectedTab = tabKey
      })
  }

  build() {
    if (this.isVisible) {
      // 遮罩层
      Stack() {
        // 对话框内容
        Column() {
          // 标题栏
          DialogHeader({
            title: t('工程设置', '工程设置'),
            onClose: () => {
              this.handleCancel()
            }
          })
          .opacity(this.i18nVersion >= 0 ? 1 : 1)  // 引用 i18nVersion 确保语言变化时重新渲染

          // Tab导航栏
          this.buildTabBar()

          // 内容区域 - 根据选中的Tab显示不同页面
          Column() {
            if (this.selectedTab === '系统结构设置') {
              SystemStructurePage({
                onCancel: (): void => this.handleCancel(),
                onSave: (): void => this.handleConfirm()
              })
            } else if (this.selectedTab === '通道范围设置') {
              ChannelRangePage()
            } else if (this.selectedTab === '通道出口设置') {
              ChannelExportPage({
                onCancel: (): void => this.handleCancel(),
                onSave: (): void => this.handleConfirm()
              })
            } else if (this.selectedTab === '重量设置') {
              WeightSettingsPage({
                onCancel: (): void => this.handleCancel(),
                onSave: (): void => this.handleConfirm()
              })
            } else if (this.selectedTab === '水果信息设置') {
              FruitInfoPage()
            }
          }
          .width('100%')
          .layoutWeight(1)
          .opacity(this.i18nVersion >= 0 ? 1 : 1)  // 引用 i18nVersion 确保语言变化时重新渲染

          // 底部按钮栏（使用DialogButtons组件）
          if (this.selectedTab !== '系统结构设置' && this.selectedTab !== '通道出口设置' && this.selectedTab !== '重量设置') {
            DialogButtons({
              confirmText: t('确认', '确认'),
              cancelText: t('取消', '取消'),
              showCancel: true,
              confirmDisabled: false,
              onConfirm: () => {
                this.handleConfirm()
              },
              onCancel: () => {
                this.handleCancel()
              }
            })
            .opacity(this.i18nVersion >= 0 ? 1 : 1)  // 引用 i18nVersion 确保语言变化时重新渲染
            .width('100%')
            .padding({ left: 12, right: 12, top: 10, bottom: 12 })
          }
        }
        .width('85%')
        .height('90%')
        .backgroundColor(getCurrentTheme(this.consumedTheme).surfaceColor)
        .borderRadius(12)
        .shadow({
          radius: 20,
          color: 'rgba(0, 0, 0, 0.1)',
          offsetX: 0,
          offsetY: 4
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('rgba(0, 0, 0, 0.5)')
      .alignContent(Alignment.Center)
    }
  }
}
