/**
 * 通用TabBar组件
 * 
 * 功能说明：
 * - 支持垂直和水平布局
 * - 统一的TabBar设计风格
 * - 支持主题配置
 * - 可复用的TabBar组件
 * 
 * 使用场景：
 * - 左侧导航栏（垂直布局）
 * - 顶部TabBar（水平布局）
 * - 其他需要TabBar的地方
 */

import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../../utils/theme/useOmniTheme'
import { BorderGrowthButton } from '../buttons/BorderGrowthButton'
import { ThreeDButton } from '../buttons/ThreeDButton'
import { AppleDesignStyle } from '../../../utils/theme/AppleDesignStyle'

// 子菜单项配置接口
export interface SubItemConfig {
  key: string
  label: string
  onClick?: () => void
}

// Tab配置接口
export interface TabConfig {
  key: string
  label: string
  icon?: Resource  // 可选的图标资源
  disabled?: boolean  // 是否禁用
  badge?: string  // 徽章文本（如通知数量）
  subItems?: SubItemConfig[] // 可选的子菜单项
  isPageSwitch?: boolean // 是否为页面切换按钮
}

// TabBar布局方向
export enum TabBarDirection {
  HORIZONTAL = 'horizontal',  // 水平布局
  VERTICAL = 'vertical'       // 垂直布局
}

@Component
export struct OmniTabBar {
  
  // 主题相关
  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: OmniThemeType = OmniThemeManager.getInstance().getCurrentThemeType()
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0
  
  // 提供主题给子组件
  @Provide omniTabBarTheme: ExtendedOmniThemeStyle = this.consumedTheme

  // Tab配置
  @Prop tabs: TabConfig[] = []
  
  // 当前选中的Tab
  @Prop selectedTab: string = ''
  
  // 布局方向
  @Prop layoutDirection: TabBarDirection = TabBarDirection.HORIZONTAL
  
  // 是否显示分隔线
  @Prop showSeparator: boolean = false
  @Prop useChrome: boolean = true
  
  // 点击回调
  onTabClick?: (tabKey: string) => void

  // 当前激活的弹出菜单TabKey
  @State activePopupTabKey: string | null = null

  // 获取当前主题配置
  private resolveTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.consumedTheme)
  }

  // 构建子菜单内容
  @Builder
  private buildSubMenu(subItems: SubItemConfig[]) {
    Column() {
      ForEach(subItems, (item: SubItemConfig, index: number) => {
        Button() {
          Text(item.label)
            .fontSize(this.resolveTheme().fontLevel4 ?? 18)
            .fontColor(this.resolveTheme().textColor)
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Center) // 居中显示
            .width('100%')
        }
        .width(140) // 保持合适宽度，不要过长
        .height(48) // 舒适的高度
        .backgroundColor(Color.Transparent) // 透明背景，依靠Hover效果
        .stateEffect(true) // 开启点击效果
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          // 点击子项后关闭菜单
          this.activePopupTabKey = null
          if (item.onClick) {
            item.onClick()
          }
        })
        
        // 分隔线（除了最后一项）
        if (index < subItems.length - 1) {
          Divider()
            .color(this.resolveTheme().borderColor + '40')
            .width('90%')
        }
      })
    }
    .width(160) // 限制菜单容器宽度，防止过长
    .padding(4)
    .backgroundColor(this.resolveTheme().surfaceColor)
    .borderRadius(12)
    .shadow(AppleDesignStyle.getShadowMedium()) // 较深的阴影
    .border({ width: 1, color: this.resolveTheme().borderColor + '40' })
  }

  // 构建水平TabBar
  @Builder
  private buildHorizontalTabBar() {
    if (this.useChrome) {
      Row() {
        ForEach(this.tabs, (tab: TabConfig, index: number) => {
          this.buildTab(tab)
          if (this.showSeparator && index < this.tabs.length - 1) {
            Column()
              .width(1)
              .height(30)
              .backgroundColor(this.resolveTheme().borderColor)
              .margin({ left: 8, right: 8 })
          }
        })
      }
      .width('100%')
      .height(50)
      .backgroundColor(this.resolveTheme().surfaceColor)
      .borderRadius(AppleDesignStyle.BORDER_RADIUS_MEDIUM)
      .shadow(AppleDesignStyle.getShadowSmall('rgba(0, 0, 0, 0.08)'))
      .margin({ left: 16, right: 16, top: 16, bottom: 8 })
      .padding({ left: 20 })
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
    } else {
      Row() {
        ForEach(this.tabs, (tab: TabConfig, index: number) => {
          this.buildTab(tab)
          if (this.showSeparator && index < this.tabs.length - 1) {
            Column()
              .width(1)
              .height(30)
              .backgroundColor(this.resolveTheme().borderColor)
              .margin({ left: 8, right: 8 })
          }
        })
      }
      .width('100%')
      .height(50)
      .backgroundColor(Color.Transparent)
      .margin({ left: 0, right: 0, top: 0, bottom: 0 })
      .padding({ left: 0, right: 0 })
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
    }
  }

  // 构建垂直TabBar
  @Builder
  private buildVerticalTabBar() {
    Scroll() {
      Column() {
        ForEach(this.tabs, (tab: TabConfig, index: number) => {
          // 给第一个按钮添加顶部边距
          if (index === 0) {
            Column().height(20) // 减少顶部间距 30 -> 20
          }
          
          this.buildTab(tab)
          
          // 在按钮之间添加分隔线（如果需要）
          if (this.showSeparator && index < this.tabs.length - 1) {
            Row()
              .width('80%')
              .height(1)
              .backgroundColor(this.resolveTheme().borderColor)
              .margin({ top: 8, bottom: 8 })
          }
        })
        
        // 底部留白
        Column().height(20)
      }
      .width('100%')
      // .height('100%') // 去除固定高度，由内容撑开
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off) // 隐藏滚动条
    .backgroundColor(this.resolveTheme().surfaceColor)
    .borderRadius(AppleDesignStyle.BORDER_RADIUS_MEDIUM) // Apple风格：中等圆角
    .shadow(AppleDesignStyle.getShadowSmall('rgba(0, 0, 0, 0.08)')) // Apple风格：柔和阴影
    .padding(0) // 移除内边距，确保内容填满
    .align(Alignment.Top)
  }

  // 构建单个Tab
  @Builder
  private buildTab(tab: TabConfig) {
    // 垂直布局时使用ThreeDButton（与主页等级表按钮风格一致）
    if (this.layoutDirection === TabBarDirection.VERTICAL) {
      ThreeDButton({
        text: tab.label,
        buttonWidth: 140, // 增加宽度以适应 24px 字体
        buttonHeight: 64, // 增加高度以适应 24px 字体
        isSelected: this.selectedTab === tab.key,
        onClickCallback: () => {
          if (!tab.disabled) {
            if (tab.subItems && tab.subItems.length > 0) {
              // 如果有子菜单，切换弹出状态
              if (this.activePopupTabKey === tab.key) {
                this.activePopupTabKey = null
              } else {
                this.activePopupTabKey = tab.key
              }
            }
            // 总是触发点击回调（允许父组件处理选中状态或其它逻辑）
            if (this.onTabClick) {
              this.onTabClick(tab.key)
            }
          }
        }
      })
      .bindPopup(this.activePopupTabKey === tab.key, {
        builder: this.buildSubMenu(tab.subItems || []),
        placement: Placement.Right, // 显示在右侧
        mask: false, // 不显示遮罩
        popupColor: Color.Transparent, // 透明背景，由 builder 自身控制
        enableArrow: false, // 禁用小三角（尖嘴）
        onStateChange: (e) => {
          if (!e.isVisible) {
            this.activePopupTabKey = null
          }
        }
      })
      .opacity(tab.disabled ? 0.4 : 1)
      .enabled(!tab.disabled)
      .margin({ 
        top: 10,    // 恢复垂直间距 8 -> 10 (增加一点呼吸感)
        bottom: 10, // 恢复垂直间距 8 -> 10
        left: 0,
        right: 0
      })
      .alignSelf(ItemAlign.Center) // 确保按钮在父容器中居中
    } else {
      // 水平布局保持原有样式
      Button() {
        Row() {
          // 图标（如果有）
          if (tab.icon) {
            Image(tab.icon)
              .width(16)
              .height(16)
              .fillColor(this.selectedTab === tab.key ? this.resolveTheme().primary : this.resolveTheme().textColor)
              .margin({ right: 8 })
          }
          
          // 文字
          Text(tab.label)
            .fontSize(this.selectedTab === tab.key ? (this.resolveTheme().fontLevel3 ?? 24) : (this.resolveTheme().fontLevel4 ?? 18)) // 选中用 Level 3 (24px), 未选中 Level 4 (18px)
            .fontWeight(this.selectedTab === tab.key ? (this.resolveTheme().fontWeightBold ?? FontWeight.Bold) : (this.resolveTheme().fontWeightMedium ?? FontWeight.Normal))
            .fontColor(tab.disabled ? this.resolveTheme().textColor + '60' : 
                      (this.selectedTab === tab.key ? this.resolveTheme().primary : this.resolveTheme().textColor))
          
          // 徽章（如果有）
          if (tab.badge) {
            Text(tab.badge)
              .fontSize(10)
              .fontColor(Color.White)
              .backgroundColor('#FF4444')
              .borderRadius(8)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .margin({ left: 4 })
          }
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }
      .width('auto')
      .height(44)
      .backgroundColor(tab.disabled ? this.resolveTheme().surfaceColor + '40' :
                      (this.selectedTab === tab.key ? this.resolveTheme().primary + '15' : Color.Transparent))
      .borderRadius(8)
      .border({ 
        width: tab.isPageSwitch ? 0 : 1, 
        color: tab.disabled ? this.resolveTheme().borderColor + '40' :
               (this.selectedTab === tab.key ? this.resolveTheme().primary : this.resolveTheme().borderColor)
      })
      .padding({ 
        left: 14, 
        right: 14, 
        top: 8, 
        bottom: 8 
      })
      .margin({ 
        left: 8, 
        right: 8
      })
      .enabled(!tab.disabled)
      .onClick(() => {
        if (!tab.disabled && this.onTabClick) {
          this.onTabClick(tab.key)
        }
      })
      .animation({
        duration: 200,
        curve: Curve.EaseInOut
      })
    }
  }

  build() {
    if (this.layoutDirection === TabBarDirection.HORIZONTAL) {
      this.buildHorizontalTabBar()
    } else {
      this.buildVerticalTabBar()
    }
  }
}
