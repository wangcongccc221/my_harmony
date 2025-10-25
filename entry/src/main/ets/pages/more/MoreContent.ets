/**
 * 更多页面内容组件
 * 功能：显示系统设置、主题切换、数据管理等功能
 * 用途：在Home页面中作为更多功能页面显示
 */

import { BaseComponentHelper } from '../../components/common/BaseComponent'
import { MoreTabBar } from './MoreTabBar'
import { OmniThemeManager, ExtendedOmniThemeStyle, OmniThemeType } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { useOmniTheme } from '../../utils/theme/useOmniTheme'
import { OmniUIUtils } from '../../utils/helpers/OmniUIUtils'
import { EngineeringSettingsDialog } from '../../components/dialogs/EngineeringSettingsDialog'

// 设置项接口
interface SettingItem {
  icon: string
  title: string
  subtitle: string
  onClick?: () => void
}

@Component
export struct MoreContent {
  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: OmniThemeType = OmniThemeManager.getInstance().getCurrentThemeType()
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0
  private baseComponentHelper = new BaseComponentHelper()
  private omniThemeManager = OmniThemeManager.getInstance()
  private omniUIUtils = OmniUIUtils.getInstance()
  @State showThemeSelector: boolean = false
  @State selectedTheme: OmniThemeType = OmniThemeType.BLUE
  @State showEngineeringSettingsDialog: boolean = false

  // 设置项配置
  private settingItems: SettingItem[] = [
    { icon: '⚙️', title: '工程设置', subtitle: '工程参数配置', onClick: () => this.showEngineeringSettings() },
    { icon: '📱', title: '设备信息', subtitle: '查看设备详细信息' },
    { icon: '🗑️', title: '数据清零', subtitle: '清空所有数据' },
    { icon: '🔧', title: '配置设置', subtitle: '系统配置管理' },
    { icon: '👤', title: '用户设置', subtitle: '用户账户管理' },
    { icon: '⬇️', title: '下载配置', subtitle: '下载配置文件' },
    { icon: '⚠️', title: '故障信息', subtitle: '查看故障记录' },
    { icon: '🔌', title: '电器故障设置', subtitle: '电器故障配置' },
    { icon: '🏷️', title: '贴标设置', subtitle: '标签打印设置' },
    { icon: '🛠️', title: '系统故障设置', subtitle: '系统故障配置' },
    { icon: '🔄', title: '复位掉果杯', subtitle: '重置掉果杯状态' }
  ]

  getCurrentTheme(): ExtendedOmniThemeStyle {
    return this.baseComponentHelper.getCurrentTheme(this.consumedTheme)
  }

  // 主题切换处理
  private handleThemeChange(theme: OmniThemeType): void {
    const hook = useOmniTheme()
    hook.setTheme(theme)
    const themeName = this.omniThemeManager.getThemeName(theme)
    this.omniUIUtils.showSuccess(`已切换到${themeName}`)
  }

  // 工程设置对话框处理
  private showEngineeringSettings(): void {
    this.showEngineeringSettingsDialog = true
  }

  private handleEngineeringSettingsConfirm(): void {
    this.omniUIUtils.showSuccess('工程设置已保存')
    this.showEngineeringSettingsDialog = false
  }

  private handleEngineeringSettingsCancel(): void {
    this.omniUIUtils.showInfo('已取消工程设置')
    this.showEngineeringSettingsDialog = false
  }

  @State private selectedTab: string = '出口'

  build() {
    Stack() {
      Column() {
        // TabBar 导航（封装为组件）
        MoreTabBar({ selectedTab: this.selectedTab, onSwitch: (tab: string) => { this.selectedTab = tab } })

        // 内容区域
        Scroll() {
          Column() {
            if (this.selectedTab === '出口') {
              this.buildExportContent()
            } else if (this.selectedTab === '设置') {
              this.buildSettingsContent()
            } else if (this.selectedTab === '帮助') {
              this.buildHelpContent()
            }
          }
          .width('100%')
          .backgroundColor(this.getCurrentTheme().pageBg ?? this.getCurrentTheme().backgroundColor)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Auto)
        .scrollBarColor(this.getCurrentTheme().borderColor)
        .scrollBarWidth(6)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.getCurrentTheme().pageBg ?? this.getCurrentTheme().backgroundColor)

      // 主题选择器弹窗 - 使用Stack确保在最上层
      if (this.showThemeSelector) {
        this.buildThemeSelectorDialog()
      }

      // 工程设置对话框
      if (this.showEngineeringSettingsDialog) {
        EngineeringSettingsDialog({
          isVisible: this.showEngineeringSettingsDialog,
          onConfirm: () => {
            this.handleEngineeringSettingsConfirm()
          },
          onCancel: () => {
            this.handleEngineeringSettingsCancel()
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  // 构建Tab按钮
  @Builder
  buildTabButton(title: string, tabKey: string): void {
    Button(title)
      .fontSize(28)  // 字体调大到28px，更有气势！
      .fontWeight(this.selectedTab === tabKey ? FontWeight.Bold : FontWeight.Normal)
      .fontColor(this.selectedTab === tabKey ? this.getCurrentTheme().primary : this.getCurrentTheme().textColor)
      .backgroundColor(this.selectedTab === tabKey ? this.getCurrentTheme().primary + '20' : Color.Transparent)
      .borderRadius(10)  // 圆角调大
      .padding({ left: 30, right: 30, top: 16, bottom: 16 })  // 内边距调得更大
      .onClick(() => {
        this.selectedTab = tabKey
      })
  }

  // 构建出口内容
  @Builder
  buildExportContent(): void {
    Column() {
      Text('出口管理')
        .fontSize(32)  // 字体调大到32px，更有气势！
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getCurrentTheme().textColor)
        .margin({ left: 16, right: 16, bottom: 20 })
        .alignSelf(ItemAlign.Start)

      // 出口功能列表
      Column() {
        this.buildExportItem('🗑️', '出口清空', '清空所有出口数据')
        this.buildExportItem('⚡', '电磁阀测试', '电磁阀测试控制')
        this.buildExportItem('🔧', '电机使能', '电机使能控制')
        this.buildExportItem('🔄', '复位果杯', '复位果杯状态')
        this.buildExportItem('🧪', '测试果杯', '测试果杯功能')
        this.buildExportItem('📦', '纸箱规格', '纸箱规格设置')
        this.buildExportItem('📺', '出口屏显示', '出口屏显示控制')
        this.buildExportItem('⚙️', '出口屏设置', '出口屏参数设置')
      }
      .width('100%')
      .backgroundColor(this.getCurrentTheme().surfaceColor)
      .borderRadius(12)
      .margin({ left: 16, right: 16, bottom: 20 })
      .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)', offsetY: 2 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // 构建设置内容
  @Builder
  buildSettingsContent(): void {
    Column() {
      Text('系统设置')
        .fontSize(32)  // 字体调大到32px，更有气势！
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getCurrentTheme().textColor)
        .margin({ left: 16, right: 16, bottom: 20 })
        .alignSelf(ItemAlign.Start)

      // 主题切换按钮
      this.buildThemeSwitchButton()

      // 设置项列表
      Column() {
        ForEach(this.settingItems, (item: SettingItem) => {
          this.buildSettingItem(item.icon, item.title, item.subtitle, item.onClick)
        })
      }
      .width('100%')
      .backgroundColor(this.getCurrentTheme().surfaceColor)
      .borderRadius(12)
      .margin({ left: 16, right: 16, bottom: 20 })
      .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)', offsetY: 2 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // 构建帮助功能项
  @Builder
  buildHelpItem(icon: string, title: string, subtitle: string): void {
    Row() {
      // 图标
      Text(icon)
        .fontSize(36)  // 图标字体调大到36px，更有气势！
        .margin({ right: 16 })

      // 文字内容
      Column() {
        Text(title)
          .fontSize(26)  // 标题字体调大到26px，更有气势！
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getCurrentTheme().textColor)
          .alignSelf(ItemAlign.Start)

        Text(subtitle)
          .fontSize(22)  // 副标题字体调大到22px，更有气势！
          .fontColor(this.getCurrentTheme().subTextColor)
          .alignSelf(ItemAlign.Start)
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 右箭头
      Text('>')
        .fontSize(26)  // 箭头字体调大到26px，更有气势！
        .fontColor(this.getCurrentTheme().subTextColor)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 16 })
    .onClick(() => {
      console.log('Help item clicked:', title)
      // 这里可以添加具体的功能处理逻辑
    })

    // 分割线（最后一项不显示）
    Divider()
      .color(this.getCurrentTheme().borderColor)
      .strokeWidth(0.5)
      .margin({ left: 20, right: 20 })
  }

  // 构建出口功能项
  @Builder
  buildExportItem(icon: string, title: string, subtitle: string): void {
    Row() {
      // 图标
      Text(icon)
        .fontSize(36)  // 图标字体调大到36px，更有气势！
        .margin({ right: 16 })

      // 文字内容
      Column() {
        Text(title)
          .fontSize(26)  // 标题字体调大到26px，更有气势！
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getCurrentTheme().textColor)
          .alignSelf(ItemAlign.Start)

        Text(subtitle)
          .fontSize(22)  // 副标题字体调大到22px，更有气势！
          .fontColor(this.getCurrentTheme().subTextColor)
          .alignSelf(ItemAlign.Start)
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 右箭头
      Text('>')
        .fontSize(26)  // 箭头字体调大到26px，更有气势！
        .fontColor(this.getCurrentTheme().subTextColor)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 16 })
    .onClick(() => {
      console.log('Export item clicked:', title)
      // 这里可以添加具体的功能处理逻辑
    })

    // 分割线（最后一项不显示）
    Divider()
      .color(this.getCurrentTheme().borderColor)
      .strokeWidth(0.5)
      .margin({ left: 20, right: 20 })
  }

  // 构建设置项
  @Builder
  buildSettingItem(icon: string, title: string, subtitle: string, onClick?: () => void): void {
    Row() {
      // 图标
      Text(icon)
        .fontSize(36)  // 图标字体调大到36px，更有气势！
        .margin({ right: 16 })

      // 文字内容
      Column() {
        Text(title)
          .fontSize(26)  // 标题字体调大到26px，更有气势！
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getCurrentTheme().textColor)
          .alignSelf(ItemAlign.Start)

        Text(subtitle)
          .fontSize(22)  // 副标题字体调大到22px，更有气势！
          .fontColor(this.getCurrentTheme().subTextColor)
          .alignSelf(ItemAlign.Start)
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 右箭头
      Text('>')
        .fontSize(26)  // 箭头字体调大到26px，更有气势！
        .fontColor(this.getCurrentTheme().subTextColor)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 16 })
    .onClick(() => {
      console.log('Setting item clicked:', title)
      if (onClick) {
        onClick()
      }
    })

    // 分割线（最后一项不显示）
    Divider()
      .color(this.getCurrentTheme().borderColor)
      .strokeWidth(0.5)
      .margin({ left: 20, right: 20 })
  }

  // 构建主题切换按钮
  @Builder
  buildThemeSwitchButton(): void {
    Column() {
      Text('主题设置')
        .fontSize(26)  // 字体调大到26px，更有气势！
        .fontWeight(FontWeight.Medium)
        .fontColor(this.getCurrentTheme().textColor)
        .alignSelf(ItemAlign.Start)
        .margin({ left: 20, bottom: 12, top: 20 })

      // 主题切换按钮
      Button() {
        Row() {
          Text('🎨')
            .fontSize(36)  // 图标字体调大到36px，更有气势！
            .margin({ right: 12 })
          
          Column() {
            Text('切换主题')
              .fontSize(26)  // 字体调大到26px，更有气势！
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
            Text('点击选择主题颜色')
              .fontSize(22)  // 字体调大到22px，更有气势！
              .fontColor('#FFFFFF')
              .opacity(0.8)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
      }
      .width('100%')
      .height(60)
      .backgroundColor(this.getCurrentTheme().primary)
      .borderRadius(12)
      .margin({ left: 16, right: 16, bottom: 8 })
      .onClick(() => {
        this.selectedTheme = this.consumedThemeType // 初始化选中主题为当前主题
        this.showThemeSelector = true
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // 构建主题选择器弹窗
  @Builder
  buildThemeSelectorDialog(): void {
    Stack() {
      // 遮罩层
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.showThemeSelector = false
        })
      
      // 弹窗内容
      Column() {
        // 标题栏
        Row() {
          Text('选择主题')
            .fontSize(30)  // 字体调大到30px，更有气势！
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .layoutWeight(1)
          
          // 关闭按钮
          Button() {
            Text('×')
              .fontSize(30)  // 关闭按钮字体调大到30px，更有气势！
              .fontColor(this.getCurrentTheme().textColor)
          }
          .width(30)
          .height(30)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.showThemeSelector = false
          })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 15, bottom: 15 })
        .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })
        
        // 主题选项 - 可滚动
        Scroll() {
          Column() {
            this.buildThemeOption('🔵 蓝色主题', OmniThemeType.BLUE)
            this.buildThemeOption('🟢 绿色主题', OmniThemeType.GREEN)
            this.buildThemeOption('🟣 紫色主题', OmniThemeType.PURPLE)
            this.buildThemeOption('🟠 橙色主题', OmniThemeType.ORANGE)
            this.buildThemeOption('🌸 粉色主题', OmniThemeType.PINK)
            this.buildThemeOption('🌊 青色主题', OmniThemeType.TEAL)
            this.buildThemeOption('💙 冷静深蓝', OmniThemeType.DEEP_BLUE)
            this.buildThemeOption('🧡 暖色质感', OmniThemeType.WARM_AMBER)
            this.buildThemeOption('⚫ 极简黑白', OmniThemeType.MINIMAL)
            this.buildThemeOption('🌿 清新绿意', OmniThemeType.FRESH_GREEN)
            this.buildThemeOption('💜 优雅紫调', OmniThemeType.ELEGANT_PURPLE)
            this.buildThemeOption('🎯 专业蓝色', OmniThemeType.PROFESSIONAL_BLUE)
          }
          .width('100%')
          .padding(20)
        }
        .width('100%')
        .height(400)
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Auto)
        
        // 底部按钮
        Row() {
          Button('取消')
            .fontSize(26)  // 字体调大到26px，更有气势！
            .fontColor(this.getCurrentTheme().textColor)
            .backgroundColor(this.getCurrentTheme().backgroundColor)
            .border({ width: 1, color: this.getCurrentTheme().borderColor })
            .borderRadius(10)  // 圆角调大
            .padding({ left: 30, right: 30, top: 16, bottom: 16 })  // 内边距调得更大
            .layoutWeight(1)
            .margin({ right: 10 })
            .onClick(() => {
              this.showThemeSelector = false
            })

          Button('确认')
            .fontSize(26)  // 字体调大到26px，更有气势！
            .fontColor(Color.White)
            .backgroundColor(this.getCurrentTheme().primary)
            .borderRadius(10)  // 圆角调大
            .padding({ left: 30, right: 30, top: 16, bottom: 16 })  // 内边距调得更大
            .layoutWeight(1)
            .margin({ left: 10 })
            .onClick(() => {
              this.handleThemeChange(this.selectedTheme)
              this.showThemeSelector = false
            })
        }
        .width('100%')
        .padding({ left: 20, right: 20, bottom: 20 })
      }
      .width('85%')
      .constraintSize({ maxWidth: 400, maxHeight: 600 })
      .backgroundColor(this.getCurrentTheme().surfaceColor)
      .borderRadius(12)
      .shadow({
        radius: 20,
        color: 'rgba(0, 0, 0, 0.1)',
        offsetX: 0,
        offsetY: 4
      })
      .alignSelf(ItemAlign.Center)
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
  }
  
  // 构建主题选项
  @Builder
  buildThemeOption(text: string, theme: OmniThemeType): void {
    Row() {
      Text(text)
        .fontSize(26)  // 主题选项字体调大到26px，更有气势！
        .fontColor(this.getCurrentTheme().textColor)
        .layoutWeight(1)
      
      // 当前选中主题标识
      if (this.selectedTheme === theme) {
        Text('✓')
          .fontSize(26)  // 选中标识字体调大到26px，更有气势！
          .fontColor(this.getCurrentTheme().primary)
          .fontWeight(FontWeight.Bold)
      }
    }
    .width('100%')
    .padding({ top: 12, bottom: 12, left: 16, right: 16 })
    .backgroundColor(this.selectedTheme === theme ? this.getCurrentTheme().primary + '20' : Color.Transparent)
    .borderRadius(8)
    .margin({ bottom: 8 })
    .onClick(() => {
      this.selectedTheme = theme // 只更新选中状态，不立即应用主题
    })
  }

  // 构建帮助内容
  @Builder
  buildHelpContent(): void {
    Column() {
      Text('帮助支持')
        .fontSize(32)  // 字体调大到32px，更有气势！
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getCurrentTheme().textColor)
        .margin({ left: 16, right: 16, bottom: 20 })
        .alignSelf(ItemAlign.Start)

      // 帮助功能列表
      Column() {
        this.buildHelpItem('📖', '用户手册', '查看系统使用说明')
        this.buildHelpItem('🔄', '检查新版本', '检查系统更新')
        this.buildHelpItem('💾', '备份设置', '备份当前系统设置')
        this.buildHelpItem('📥', '恢复设置', '从备份恢复设置')
        this.buildHelpItem('🔌', '关闭IPM', '关闭IPM服务')
        this.buildHelpItem('📋', '分选日志', '查看分选操作日志')
        this.buildHelpItem('ℹ️', '关于', '查看系统信息')
        this.buildHelpItem('🌐', '语言', '切换系统语言')
        this.buildHelpItem('🚪', '退出', '退出系统')
        this.buildHelpItem('👤', '用户切换', '切换用户账户')
      }
      .width('100%')
      .backgroundColor(this.getCurrentTheme().surfaceColor)
      .borderRadius(12)
      .margin({ left: 16, right: 16, bottom: 20 })
      .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)', offsetY: 2 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}