import { OmniTabBar, TabConfig, TabBarDirection } from '../ui/layout/OmniTabBar'
import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { t, I18N_VERSION_KEY } from '../../utils/i18n/I18nManager'
import { AppleDesignStyle } from '../../utils/theme/AppleDesignStyle'

@Component
export struct LeftNavigationTabBar {
  
  // 主题相关
  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: OmniThemeType = OmniThemeManager.getInstance().getCurrentThemeType()
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0  // 监听语言变化，触发 UI 更新
  
  // 提供主题给子组件
  @Provide providedTheme: ExtendedOmniThemeStyle = this.consumedTheme

  // 当前选中的页面
  @Prop currentPage: string = 'home'
  
  // 点击回调
  onPageChange?: (pageKey: string) => void
  
  // 打印子按钮相关
  @Prop showPrintSubButtons: boolean = false
  onPrintSubButtonClick?: (subButtonName: string) => void
  
  // 悬浮窗相关
  @Prop showFloatingWindow: boolean = false
  @Prop floatingWindowTitle: string = ''
  onFloatingWindowClose?: () => void
  @Prop layoutDirection: TabBarDirection = TabBarDirection.VERTICAL
  @Prop useChrome: boolean = true
  @Prop customTabs: TabConfig[] = []

  // 获取当前主题配置
  private resolveTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.consumedTheme)
  }

  // 获取导航Tab配置（依赖 i18nVersion 确保语言变化时重新计算）
  private getNavigationTabs(): TabConfig[] {
    // 引用 i18nVersion 确保语言变化时重新计算
    const _version = this.i18nVersion
    return [
      { key: 'home', label: t('主页', '主页') },
      { key: 'quality', label: t('品质', '品质') },
      { key: 'level', label: t('等级', '等级') },
      { key: 'history', label: t('历史加工', '历史加工') },
      { 
        key: 'print', 
        label: t('打印', '打印'),
        subItems: [
          {
            key: 'print_report',
            label: t('打印报告', '打印报告'),
            onClick: () => {
              if (this.onPrintSubButtonClick) {
                this.onPrintSubButtonClick('打印报告')
              }
            }
          },
          {
            key: 'print_label',
            label: t('打印标签', '打印标签'),
            onClick: () => {
              if (this.onPrintSubButtonClick) {
                this.onPrintSubButtonClick('打印标签')
              }
            }
          }
        ]
      },
      { key: 'fruit', label: t('水果信息', '水果信息') },
      { key: 'load', label: t('载入程序', '载入程序') },
      { key: 'save', label: t('保存程序', '保存程序') },
      { key: 'realtime', label: t('实时统计', '实时统计') },
      { key: 'end', label: t('结束加工', '结束加工') },
      { key: 'more', label: t('更多', '更多') }
    ]
  }

  // 处理页面切换
  private handlePageChange(pageKey: string) {
    if (this.onPageChange) {
      this.onPageChange(pageKey)
    }
  }
  
  // 处理悬浮窗关闭
  private handleFloatingWindowClose() {
    if (this.onFloatingWindowClose) {
      this.onFloatingWindowClose()
    }
  }

  build() {
    Column() {
      // TabBar导航（引用 i18nVersion 确保语言变化时重新构建）
      OmniTabBar({
        tabs: this.customTabs.length > 0 ? this.customTabs : this.getNavigationTabs(),
        selectedTab: this.currentPage,
        layoutDirection: this.layoutDirection,
        showSeparator: false,
        useChrome: this.useChrome,
        onTabClick: (tabKey: string) => {
          this.handlePageChange(tabKey)
        }
      })
      .opacity(this.i18nVersion >= 0 ? 1 : 1)  // 引用 i18nVersion 触发重建
    }
    .width('100%')
    .height('100%')
    .justifyContent(this.layoutDirection === TabBarDirection.HORIZONTAL ? FlexAlign.Center : FlexAlign.Start)
    .padding(0) // 移除内边距，确保内容填满
    .backgroundColor(this.layoutDirection === TabBarDirection.HORIZONTAL ? 'transparent' : (this.resolveTheme().navBg ?? this.resolveTheme().backgroundColor))
  }
}
