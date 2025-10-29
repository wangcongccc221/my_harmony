import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'

@Component
export struct MoreTabBar {
  @Prop selectedTab: string = '出口'
  onSwitch?: (tab: string) => void

  @StorageLink(OMNI_THEME_KEY) @Watch('onThemeChange') consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_VERSION_KEY) @Watch('onThemeChange') themeVersion: number = 0

  private getTheme(): ExtendedOmniThemeStyle {
    return this.consumedTheme
  }

  // 监听主题变化
  onThemeChange(): void {
    console.log('MoreTabBar: 主题已变化，重新渲染')
  }

  build() {
    Row() {
      this.buildTab('出口')
      this.buildTab('设置')
      this.buildTab('帮助')
    }
    .width('100%')
    .height(50)
    .backgroundColor(this.getTheme().surfaceColor)
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 16, bottom: 16 })
    .justifyContent(FlexAlign.SpaceEvenly)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private buildTab(tabKey: string) {
    Button(tabKey)
      .fontSize(28)  // 字体调大到28px，更有气势！
      .fontWeight(this.selectedTab === tabKey ? FontWeight.Bold : FontWeight.Normal)
      .fontColor(this.selectedTab === tabKey ? this.getTheme().primary : this.getTheme().textColor)
      .backgroundColor(this.selectedTab === tabKey ? this.getTheme().primary + '20' : Color.Transparent)
      .borderRadius(10)  // 圆角也调大
      .padding({ left: 30, right: 30, top: 16, bottom: 16 })  // 内边距调得更大
      .onClick(() => {
        if (this.onSwitch) {
          this.onSwitch(tabKey)
        }
      })
  }
}


