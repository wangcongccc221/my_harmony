/**
 * 左侧导航栏TabBar组件
 * 
 * 功能说明：
 * - 替换原有的NavButton导航栏
 * - 使用统一的TabBar设计风格
 * - 支持垂直布局
 * - 集成主题配置
 */

import { OmniTabBar, TabConfig, TabBarDirection } from '../ui/OmniTabBar'
import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'

@Component
export struct LeftNavigationTabBar {
  
  // 主题相关
  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: OmniThemeType = OmniThemeManager.getInstance().getCurrentThemeType()
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0
  
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

  // 获取当前主题配置
  private resolveTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.consumedTheme)
  }

  // 获取导航Tab配置
  private getNavigationTabs(): TabConfig[] {
    return [
      { key: 'home', label: '主页' },
      { key: 'quality', label: '品质' },
      { key: 'level', label: '等级' },
      { key: 'fruit', label: '水果信息' },
      { key: 'load', label: '载入程序' },
      { key: 'save', label: '保存程序' },
      { key: 'history', label: '历史加工' },
      { key: 'realtime', label: '实时统计' },
      { key: 'end', label: '结束加工' },
      { key: 'print', label: '打印' },
      { key: 'more', label: '更多' }
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

  // 构建打印子按钮
  @Builder
  private buildPrintSubButtons() {
    Column() {
      // 子按钮1：打印报告
      Button() {
        Text('打印报告')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.resolveTheme().textColor)
      }
      .width('85%')
      .height(40)
      .margin({ bottom: 6, left: 16, right: 16 })
      .fontSize(12)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.resolveTheme().textColor)
      .backgroundColor(this.resolveTheme().surfaceColor)
      .border({ 
        width: 1, 
        color: this.resolveTheme().borderColor 
      })
      .borderRadius(8)
      .onClick(() => {
        if (this.onPrintSubButtonClick) {
          this.onPrintSubButtonClick('打印报告')
        }
      })

      // 子按钮2：打印标签
      Button() {
        Text('打印标签')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.resolveTheme().textColor)
      }
      .width('85%')
      .height(40)
      .margin({ bottom: 8, left: 16, right: 16 })
      .fontSize(12)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.resolveTheme().textColor)
      .backgroundColor(this.resolveTheme().surfaceColor)
      .border({ 
        width: 1, 
        color: this.resolveTheme().borderColor 
      })
      .borderRadius(8)
      .onClick(() => {
        if (this.onPrintSubButtonClick) {
          this.onPrintSubButtonClick('打印标签')
        }
      })
    }
    .width('100%')
    .margin({ top: 8 })
    .animation({
      duration: 300,
      curve: Curve.EaseInOut
    })
  }

  build() {
    Column() {
      // TabBar导航
      OmniTabBar({
        tabs: this.getNavigationTabs(),
        selectedTab: this.currentPage,
        layoutDirection: TabBarDirection.VERTICAL,
        showSeparator: false,
        onTabClick: (tabKey: string) => {
          this.handlePageChange(tabKey)
        }
      })
      
      // 打印子按钮（如果显示）
      if (this.showPrintSubButtons) {
        this.buildPrintSubButtons()
      }
    }
    .width('100%')
    .height('100%')
    .padding({ top: 20, bottom: 20 })
    .backgroundColor(this.resolveTheme().surfaceColor)
  }
}
