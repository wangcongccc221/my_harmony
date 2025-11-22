import { HomeContent } from './home/HomeContent'
import { LevelContent } from './level/LevelContent'
import { QualityContent } from './quality/QualityContent'
import { HistoryContent } from './history/HistoryContent'
import { EndProcessingContent } from './endprocessing/EndProcessingContent'
import { LiquidCardsArea } from './home/LiquidCardsArea'
// import { ThemeSelector } from '../components/ThemeSelector'
import { ArrowToggleButton } from '../components/ui/buttons/ArrowToggleButton'
import { NavButton } from '../components/ui/buttons/NavButton'
import { LeftNavigationTabBar } from '../components/layout/LeftNavigationTabBar'
import { FruitInfoDialog } from '../components/feedback/FruitInfoDialog'
import { RealtimeStatsDialog } from '../components/feedback/RealtimeStatsDialog'
import { LoadProgramDialog } from '../components/dialogs/LoadProgramDialog'
import { SaveProgramDialog } from '../components/dialogs/SaveProgramDialog'
import { SortingStatusDialog } from '../components/dialogs/SortingStatusDialog'
import { FloatingWindow } from '../components/ui/layout/FloatingWindow'
import { EngineeringSettingsDialog } from '../components/dialogs/EngineeringSettingsDialog'
import { getCurrentTheme as resolveTheme } from '../utils/theme/ThemeUtils'
import { NavigationUtils } from '../utils/helpers/NavigationUtils'
import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../utils/theme/OmniThemeManager'
import { useOmniTheme, OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../utils/theme/useOmniTheme'
import { OmniUIInit } from '../utils/helpers/OmniUIInit'
import { OmniUIUtils } from '../utils/helpers/OmniUIUtils'
// 导入 IBest-UI 组件
import { IBestButton, IBestIcon, IBestTag, IBestInit, IBestAvatar, IBestAvatarGroup } from '@ibestservices/ibest-ui'
import { window } from '@kit.ArkUI'
import { RectButton } from '../components/ui/buttons/RectButton'
import { TopStatusBar } from '../components/layout/TopStatusBar'
import { BottomControlBar } from '../components/layout/BottomControlBar'
// 移除 BottomBar 集成


// 导航按钮配置接口
interface NavigationButton {
  text: string // 展示文字（中文）
  pageName: string // 英文页面键（用于路由/比较）
}

// 页面处理策略类型
type PageHandler = () => void

// 页面内容渲染器类型
type PageRenderer = () => void

interface FruitInfo {
  name: string
  type: string
  weight: number
  color: string
  ripeness: string
  origin: string
  harvestDate: string
  quality: string
}

interface ProgramInfo {
  id: string
  name: string
  description: string
  version: string
  createDate: string
  lastModified: string
}

// 保存用户配置信息接口（仅保留名称、描述、标签）
interface SaveProgramInfo {
  name: string
  description: string
  tags: string
}

@Entry
@Component
struct Page {
  @State currentPage: string = 'home'
  @StorageLink('HOME_SELECTED_FSM') selectedFSM: 'FSM1' | 'FSM2' = 'FSM1'
  @State showThemeSelector: boolean = false  // 控制主题选择器显示
  @State sideBarStatus: boolean = true  // 控制侧边栏展开/收缩状态
  @State showFruitInfoDialog: boolean = false  // 控制水果信息对话框显示
  @State showRealtimeDialog: boolean = false   // 控制实时统计对话框显示
  @State showLoadProgramDialog: boolean = false  // 控制载入程序对话框显示
  @State showSaveProgramDialog: boolean = false  // 控制保存程序对话框显示
  @State showSortingStatusDialog: boolean = false  // 控制分选状态对话框显示
  @StorageLink(OMNI_THEME_KEY) @Watch('onThemeChange') consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_TYPE_KEY) @Watch('onThemeChange') consumedThemeType: OmniThemeType = OmniThemeManager.getInstance().getCurrentThemeType()
  @StorageLink(OMNI_THEME_VERSION_KEY) @Watch('onThemeChange') themeVersion: number = 0
  
  // FSM主题保存状态
  @State fsm1Theme: OmniThemeType = OmniThemeType.PROFESSIONAL_BLUE
  @State fsm2Theme: OmniThemeType = OmniThemeType.WARM_AMBER
  private omniThemeManager = OmniThemeManager.getInstance()  // Omni-UI 主题管理器实例
  private omniUIInit = OmniUIInit.getInstance()  // Omni-UI 初始化实例
  private omniUIUtils = OmniUIUtils.getInstance()  // Omni-UI 工具实例
  // 通用快捷对话框状态
  @State quickDialogVisible: boolean = false
  @State quickDialogTitle: string = ''
  @State quickDialogContent: string = ''
  private quickDialogConfirm?: () => void
  @State private quickDialogIndex: number = -1
  private bottomButtonsCount: number = 10
  // 打印按钮悬停状态
  @State showPrintSubButtons: boolean = false
  // 顶部个人信息 - 全屏居中编辑弹窗全局状态
  @StorageLink('EDIT_USER_LABEL_VISIBLE') private editUserLabelVisible: boolean = false
  @State private tempUserLabel: string = '姓名'
  @State private selectedAvatarUrl: string = ''
  
  // 可选头像列表
  private avatarOptions: string[] = [
    'https://img1.baidu.com/it/u=700838104,4078529388&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500',
    'https://img0.baidu.com/it/u=447148445,3812237851&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500',
    'https://img0.baidu.com/it/u=1596600438,2136408442&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500',
    'https://img0.baidu.com/it/u=2816983398,655618517&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500',
    'https://pics4.baidu.com/feed/1ad5ad6eddc451da34d4638413f67668d016325c.jpeg',
    'https://img0.baidu.com/it/u=2397297586,1192210697&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500',
    'https://img0.baidu.com/it/u=781626259,587761743&fm=253&fmt=auto&app=138&f=JPEG?w=300&h=300',
    'https://img0.baidu.com/it/u=3731477373,291511913&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500'
  ]
  
  // 悬浮窗相关状态
  @State showFloatingWindow: boolean = false
  @State floatingWindowTitle: string = ''
  @State floatingWindowContent: string = ''
  @State selectedFloatingTab: string = 'export'
  
  // 主题选择器状态
  @State selectedTheme: OmniThemeType = OmniThemeType.BLUE
  
  // 工程设置对话框状态
  @State showEngineeringSettingsDialog: boolean = false
  
  
  
  // 页面初始化时初始化 Omni-UI 和 IBest-UI
  aboutToAppear() {
    this.omniUIInit.init()
    this.omniThemeManager.init()
  }
  
  
  
  // 获取当前主题配置的方法
  getCurrentTheme(): ExtendedOmniThemeStyle {
    // 引用 themeVersion，确保主题版本变化触发本组件重建
    const __version: number = this.themeVersion
    return resolveTheme(this.consumedTheme)
  }

  // 监听主题变化
  onThemeChange(): void {
    console.log('Home: 主题已变化，重新渲染')
  }

  // 将页面键映射为展示标题（中文）
  private getPageTitle(pageKey: string): string {
    const map: Record<string, string> = {
      'home': '主页',
      'quality': '品质',
      'level': '等级',
      'fruit': '水果信息',
      'load': '载入程序',
      'save': '保存程序',
      'history': '历史加工',
      'end': '结束加工',
      'print': '打印',
      'more': '更多'
    }
    return map[pageKey] || pageKey
  }

  // 页面处理策略映射（按英文 pageKey）
  private getPageHandlers(): Record<string, PageHandler> {
    return {
      'fruit': (): void => this.showFruitInfo(),
      'realtime': (): void => this.showRealtimeStats(),
      'load': (): void => this.showLoadProgram(),
      'save': (): void => this.showSaveProgram(),
      'print': (): void => this.handlePrintClick(),
      'quality': (): void => { this.currentPage = 'quality' },
      'level': (): void => { this.currentPage = 'level' },
      'history': (): void => { this.currentPage = 'history' },
      'end': (): void => { this.currentPage = 'end' },
      'more': (): void => this.displayFloatingWindow('更多设置', '这里是更多设置和系统配置。\n\n• 系统设置\n• 用户管理\n• 数据备份\n• 系统维护'),
      // 默认处理：正常页面切换
      'default': (): void => { this.currentPage = this.currentPage }
    }
  }

  // 页面切换处理方法
  private handlePageChange(pageName: string): void {
    const handlers = this.getPageHandlers()
    const handler = handlers[pageName] || handlers['default']
    
    if (handler === handlers['default']) {
      // 对于默认处理，需要设置正确的页面名称
      this.currentPage = pageName
    } else {
      handler()
    }
  }

  // 水果信息功能封装
  private showFruitInfo(): void {
    this.showFruitInfoDialog = true
  }

  // 实时统计弹窗功能封装（与水果信息同风格）
  private showRealtimeStats(): void {
    this.showRealtimeDialog = true
  }

  // 处理水果信息对话框确认
  private handleFruitInfoConfirm(fruitInfo: FruitInfo): void {
    this.omniUIUtils.showInfo(`已确认水果信息：${fruitInfo.name}`)
    this.showFruitInfoDialog = false
  }

  // 处理水果信息对话框取消
  private handleFruitInfoCancel(): void {
    this.omniUIUtils.showInfo('已取消查看水果信息')
    this.showFruitInfoDialog = false
  }

  // 载入程序功能封装
  private showLoadProgram(): void {
    this.showLoadProgramDialog = true
  }

  // 处理载入程序对话框确认
  private handleLoadProgramConfirm(programInfo: ProgramInfo): void {
    this.omniUIUtils.showInfo(`已载入程序：${programInfo.name} (${programInfo.version})`)
    this.showLoadProgramDialog = false
  }

  // 处理载入程序对话框取消
  private handleLoadProgramCancel(): void {
    this.omniUIUtils.showInfo('已取消载入程序')
    this.showLoadProgramDialog = false
  }

  // 保存程序功能封装
  private showSaveProgram(): void {
    this.showSaveProgramDialog = true
  }

  // 处理保存程序对话框确认
  private handleSaveProgramConfirm(saveProgramInfo: SaveProgramInfo): void {
    // 这里可以添加实际的保存逻辑，比如保存到本地存储
    console.log('保存程序信息:', saveProgramInfo)
    this.omniUIUtils.showSuccess(`程序 "${saveProgramInfo.name}" 已保存到本地`)
    this.showSaveProgramDialog = false
  }

  // 处理保存程序对话框取消
  private handleSaveProgramCancel(): void {
    this.omniUIUtils.showInfo('已取消保存程序')
    this.showSaveProgramDialog = false
  }

  // 分选状态功能封装
  private showSortingStatus(): void {
    this.showSortingStatusDialog = true
  }

  // 处理分选状态对话框确认
  private handleSortingStatusConfirm(isNormal: boolean): void {
    const statusText = isNormal ? '正常分选' : '异常分选'
    this.omniUIUtils.showInfo(`分选状态已设置为：${statusText}`)
    this.showSortingStatusDialog = false
  }

  // 处理分选状态对话框取消
  private handleSortingStatusCancel(): void {
    this.omniUIUtils.showInfo('已取消分选状态设置')
    this.showSortingStatusDialog = false
  }

  // 处理打印按钮点击显示子按钮
  private handlePrintClick(): void {
    this.showPrintSubButtons = !this.showPrintSubButtons
  }

  // 处理打印子按钮点击
  private handlePrintSubButtonClick(subButtonName: string): void {
    this.omniUIUtils.showInfo(`已点击${subButtonName}`)
    // 点击子按钮后不自动隐藏，保持子按钮显示状态
  }

  // 处理悬浮窗显示
  private displayFloatingWindow(title: string, content: string): void {
    this.floatingWindowTitle = title
    this.floatingWindowContent = content
    this.showFloatingWindow = true
  }

  // 处理悬浮窗关闭
  private handleFloatingWindowClose(): void {
    this.showFloatingWindow = false
    this.floatingWindowTitle = ''
    this.floatingWindowContent = ''
  }

  // 处理主题切换
  private handleThemeChange(theme: OmniThemeType): void {
    const hook = useOmniTheme()
    hook.setTheme(theme)
    const themeName = this.omniThemeManager.getThemeName(theme)
    this.omniUIUtils.showSuccess(`已切换到${themeName}`)
    this.showThemeSelector = false
  }

  // 处理工程设置
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

  // 处理出口清空功能
  private handleExportClear(): void {
    console.log('开始清空液体卡片数据...')
    
    // 从AppStorage获取LiquidCardsArea引用
    const liquidCardsAreaRef: LiquidCardsArea | null = AppStorage.get('LIQUID_CARDS_AREA_REF') as LiquidCardsArea | null
    if (liquidCardsAreaRef) {
      liquidCardsAreaRef.clearAllCardData()
      this.omniUIUtils.showSuccess('清空成功！')//提示弹窗
      // 显示系统对话框，确保用户可见
      AlertDialog.show({
        title: '提示',
        message: '清空成功！',
        confirm: { value: '确定', action: () => {} }
      })
    } else {
      console.error('液体卡片区域引用为空，无法清空数据')
      this.omniUIUtils.showError('清空失败：液体卡片区域未初始化')
    }
  }

  // 构建悬浮窗Tab按钮
  @Builder
  private buildFloatingTabButton(title: string, tabKey: string): void {
    Button(title)
      .fontSize(14)
      .fontWeight(this.selectedFloatingTab === tabKey ? FontWeight.Bold : FontWeight.Normal)
      .fontColor(this.selectedFloatingTab === tabKey ? this.getCurrentTheme().primary : this.getCurrentTheme().textColor)
      .backgroundColor(this.selectedFloatingTab === tabKey ? this.getCurrentTheme().primary + '20' : Color.Transparent)
      .borderRadius(6)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .layoutWeight(1)
      .margin({ left: 4, right: 4 })
      .onClick(() => {
        this.selectedFloatingTab = tabKey
      })
  }

  // 构建出口Tab内容
  @Builder
  private buildExportTabContent(): void {
    Text('出口管理')
      .fontSize(18)
      .fontWeight(FontWeight.Bold)
      .fontColor(this.getCurrentTheme().textColor)
      .margin({ bottom: 16 })
      .alignSelf(ItemAlign.Start)

    // 按钮网格 - 4列布局
    Grid() {
      GridItem() { this.buildFloatingButton('🗑️', '出口清空') }
      GridItem() { this.buildFloatingButton('⚡', '电磁阀测试') }
      GridItem() { this.buildFloatingButton('🔧', '电机使能') }
      GridItem() { this.buildFloatingButton('🔄', '复位果杯') }
      GridItem() { this.buildFloatingButton('🧪', '测试果杯') }
      GridItem() { this.buildFloatingButton('📦', '纸箱规格') }
      GridItem() { this.buildFloatingButton('📺', '出口屏显示') }
      GridItem() { this.buildFloatingButton('⚙️', '出口屏设置') }
    }
    .columnsTemplate('1fr 1fr 1fr 1fr')
    .rowsGap(16)
    .columnsGap(16)
    .width('100%')
  }

  // 构建设置Tab内容
  @Builder
  private buildSettingsTabContent(): void {
    Text('系统设置')
      .fontSize(18)
      .fontWeight(FontWeight.Bold)
      .fontColor(this.getCurrentTheme().textColor)
      .margin({ bottom: 16 })
      .alignSelf(ItemAlign.Start)

    // 按钮网格 - 4列布局
    Grid() {
      GridItem() { this.buildFloatingButton('⚙️', '工程设置') }
      GridItem() { this.buildFloatingButton('📱', '设备信息') }
      GridItem() { this.buildFloatingButton('🗑️', '数据清零') }
      GridItem() { this.buildFloatingButton('🔧', '配置设置') }
      GridItem() { this.buildFloatingButton('👨', '用户设置') }
      GridItem() { this.buildFloatingButton('⬇️', '下载配置') }
      GridItem() { this.buildFloatingButton('⚠️', '故障信息') }
      GridItem() { this.buildFloatingButton('🔌', '电器故障设置') }
      GridItem() { this.buildFloatingButton('🏷️', '贴标设置') }
      GridItem() { this.buildFloatingButton('🛠️', '系统故障设置') }
      GridItem() { this.buildFloatingButton('🔄', '复位掉果杯') }
      GridItem() { this.buildFloatingButton('🎨', '主题切换') }
    }
    .columnsTemplate('1fr 1fr 1fr 1fr')
    .rowsGap(16)
    .columnsGap(16)
    .width('100%')
  }

  // 构建帮助Tab内容
  @Builder
  private buildHelpTabContent(): void {
    Text('帮助支持')
      .fontSize(18)
      .fontWeight(FontWeight.Bold)
      .fontColor(this.getCurrentTheme().textColor)
      .margin({ bottom: 16 })
      .alignSelf(ItemAlign.Start)

    // 按钮网格 - 4列布局
    Grid() {
      GridItem() { this.buildFloatingButton('📖', '用户手册') }
      GridItem() { this.buildFloatingButton('🔄', '检查新版本') }
      GridItem() { this.buildFloatingButton('💾', '备份设置') }
      GridItem() { this.buildFloatingButton('📥', '恢复设置') }
      GridItem() { this.buildFloatingButton('🔌', '关闭IPM') }
      GridItem() { this.buildFloatingButton('📋', '分选日志') }
      GridItem() { this.buildFloatingButton('ℹ️', '关于') }
      GridItem() { this.buildFloatingButton('🌐', '语言') }
      GridItem() { this.buildFloatingButton('🚪', '退出') }
      GridItem() { this.buildFloatingButton('👨', '用户切换') }
    }
    .columnsTemplate('1fr 1fr 1fr 1fr')
    .rowsGap(16)
    .columnsGap(16)
    .width('100%')
  }

  // 构建主题选择器
  @Builder
  private buildThemeSelector(): void {
    Stack() {
      // 背景遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.showThemeSelector = false
        })
      
      // 主题选择器内容
      Column() {
        // 标题
        Text('选择主题')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getCurrentTheme().textColor)
          .margin({ bottom: 20 })
        
        // 主题选项
        Column() {
          this.buildThemeOption(OmniThemeType.BLUE, '🔵 蓝色主题', '#1976D2')
          this.buildThemeOption(OmniThemeType.GREEN, '🟢 绿色主题', '#388E3C')
          this.buildThemeOption(OmniThemeType.PURPLE, '🟣 紫色主题', '#7B1FA2')
          this.buildThemeOption(OmniThemeType.ORANGE, '🟠 橙色主题', '#F57C00')
          this.buildThemeOption(OmniThemeType.PINK, '🌸 粉色主题', '#C2185B')
          this.buildThemeOption(OmniThemeType.TEAL, '🌊 青色主题', '#00796B')
          this.buildThemeOption(OmniThemeType.DEEP_BLUE, '💙 冷静深蓝', '#1565C0')
          this.buildThemeOption(OmniThemeType.WARM_AMBER, '🧡 暖色质感', '#FF8F00')
          this.buildThemeOption(OmniThemeType.MINIMAL, '⚫ 极简黑白', '#424242')
          this.buildThemeOption(OmniThemeType.FRESH_GREEN, '🌿 清新绿意', '#4CAF50')
          this.buildThemeOption(OmniThemeType.ELEGANT_PURPLE, '💜 优雅紫调', '#9C27B0')
          this.buildThemeOption(OmniThemeType.PROFESSIONAL_BLUE, '🎯 专业蓝色', '#1976D2')
        }
        .width('100%')
        .margin({ top: 12, bottom: 12 })
      }
      .width(350)
      .padding(20)
      .backgroundColor(this.getCurrentTheme().surfaceColor + 'E6') // 添加90%透明度
      .borderRadius(12)
      .shadow({
        radius: 20,
        color: 'rgba(0, 0, 0, 0.15)',
        offsetX: 0,
        offsetY: 8
      })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .zIndex(2000)
  }

  // 构建主题选项
  @Builder
  private buildThemeOption(theme: OmniThemeType, name: string, color: string): void {
    Row() {
      // 颜色指示器
      Column()
        .width(20)
        .height(20)
        .backgroundColor(color)
        .borderRadius(10)
        .margin({ right: 12 })
      
      // 主题名称
      Text(name)
        .fontSize(16)
        .fontColor(this.getCurrentTheme().textColor)
        .layoutWeight(1)
      
      // 选中指示器
      if (this.selectedTheme === theme) {
        Text('✓')
          .fontSize(16)
          .fontColor(this.getCurrentTheme().textColor)
          .fontWeight(FontWeight.Bold)
      }
    }
    .width('100%')
    .height(50)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.selectedTheme === theme ? this.getCurrentTheme().textColor + '20' : Color.Transparent)
    .borderRadius(8)
    .border({ 
      width: this.selectedTheme === theme ? 2 : 1, 
      color: this.selectedTheme === theme ? this.getCurrentTheme().textColor : this.getCurrentTheme().borderColor 
    })
    .onClick(() => {
      this.handleThemeChange(theme)
    })
  }

  // 构建悬浮窗按钮
  @Builder
  private buildFloatingButton(icon: string, title: string): void {
    Button() {
      Column() {
        Text(icon)
          .fontSize(32)
          .margin({ bottom: 8 })
        
        Text(title)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getCurrentTheme().textColor)
          .textAlign(TextAlign.Center)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height(120)
    .backgroundColor(this.getCurrentTheme().surfaceColor)
    .border({ width: 1, color: this.getCurrentTheme().borderColor })
    .borderRadius(8)
    .onClick(() => {
      console.log('悬浮窗按钮被点击:', title)
      if (title === '主题切换') {
        this.selectedTheme = this.consumedThemeType // 初始化选中主题为当前主题
        this.showThemeSelector = true
      } else if (title === '工程设置') {
        this.showEngineeringSettings()
      } else if (title === '出口清空') {
        this.handleExportClear()
      } else {
        this.omniUIUtils.showInfo(`已点击${title}`)
      }
    })
  }



  // 创建导航按钮配置（pageName 使用英文键）
  private getNavigationButtons(): NavigationButton[] {
    return [
      { text: '主   页', pageName: 'home' },
      { text: '品   质', pageName: 'quality' },
      { text: '等   级', pageName: 'level' },
      { text: '水果信息', pageName: 'fruit' },
      { text: '载入程序', pageName: 'load' },
      { text: '保存程序', pageName: 'save' },
      { text: '历史加工', pageName: 'history' },
      { text: '实时统计', pageName: 'realtime' },
      { text: '结束加工', pageName: 'end' },
      { text: '打    印', pageName: 'print' },
      { text: '更    多', pageName: 'more' }
    ]
  }

  // 渲染页面内容
  @Builder
  private renderPageContent(): void {
    if (this.currentPage === 'home') {
      HomeContent()
    } else if (this.currentPage === 'level') {
      LevelContent()
    } else if (this.currentPage === 'quality') {
      QualityContent()
    } else if (this.currentPage === 'realtime') {
      // 实时统计占位页面（后续可替换为真实组件）
      Column() {
        Text('实时统计')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getCurrentTheme().primary)
          .margin({ top: 20 })
      }
      .width('100%')
      .height('100%')
    } else if (this.currentPage === 'history') {
      HistoryContent()
    } else if (this.currentPage === 'end') {
      EndProcessingContent()
    } else {
      // 默认页面内容
      this.renderDefaultPage()
    }
  }

  // 渲染默认页面内容
  @Builder
  private renderDefaultPage(): void {
    Column() {
      Text(`${this.getPageTitle(this.currentPage)}页面`)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getCurrentTheme().textColor)
        .margin({ top: 50 })
      Text(`这里将显示${this.getPageTitle(this.currentPage)}功能`)
        .fontSize(16)
        .fontColor(this.getCurrentTheme().subTextColor)
        .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  // 获取当前主题的主色调（基于页面状态）
  getThemePrimaryColor(): string {
    const themeConfigs = this.omniThemeManager.getAllThemes()
    const themeType = this.consumedThemeType ?? this.omniThemeManager.getCurrentThemeType()
    const primaryColor = themeConfigs[themeType]?.primary
    return typeof primaryColor === 'string' ? primaryColor : '#007AFF'
  }

  // 根据当前页面获取左侧导航背景色（未配置则回退到通用 navBg）
  private getNavBgForCurrentPage(): string | number {
    const theme = this.getCurrentTheme()
    const page = this.currentPage
    if (page === 'home' && theme.navBgHome) return theme.navBgHome
    if (page === 'level' && theme.navBgLevel) return theme.navBgLevel
    if (page === 'quality' && theme.navBgQuality) return theme.navBgQuality
    if (page === 'history' && theme.navBgHistory) return theme.navBgHistory
    if (page === 'more' && theme.navBgMore) return theme.navBgMore
    return theme.navBg ?? theme.surfaceColor
  }

  // 统一弹出快捷对话框
  private openQuickDialog(title: string, content: string, onConfirm?: () => void): void {
    this.quickDialogTitle = title
    this.quickDialogContent = content
    this.quickDialogConfirm = onConfirm
    this.quickDialogVisible = true
  }

  // 根据索引弹出快捷对话框（用于底部按钮1~10）
  private openQuickDialogForIndex(index: number, onConfirm?: () => void): void {
    this.quickDialogIndex = index
    const title = `${index}号出口`
    const content = `你点击了底部按钮 ${index}`
    this.openQuickDialog(title, content, onConfirm)
  }

  // 切换到上一个/下一个
  private navigateQuickDialog(delta: number): void {
    if (!this.quickDialogVisible || this.quickDialogIndex < 1) {
      return
    }
    const count = this.bottomButtonsCount
    let nextIndex = ((this.quickDialogIndex - 1 + delta) % count + count) % count + 1
    this.openQuickDialogForIndex(nextIndex)
  }

  // 构建打印子按钮（向下展开，带缩进）
  @Builder
  private buildPrintSubButtons() {
    if (this.showPrintSubButtons) {
      Column() {
        // 子按钮1：打印报告
        Button('打印报告')
          .width('70%')
          .height(36)
          .margin({ bottom: 4, left: 20, right: 20 })
          .fontSize(12)
          .fontWeight(FontWeight.Bolder)
          .fontColor(this.getCurrentTheme().textColor)
          .backgroundColor(this.getCurrentTheme().surfaceColor)
          .border({ 
            width: 1, 
            color: this.getCurrentTheme().borderColor 
          })
          .borderRadius(0)
          .onClick(() => {
            this.handlePrintSubButtonClick('打印报告')
          })

        // 子按钮2：打印标签
        Button('打印标签')
          .width('70%')
          .height(36)
          .margin({ left: 20, right: 20 })
          .fontSize(12)
          .fontWeight(FontWeight.Bolder)
          .fontColor(this.getCurrentTheme().textColor)
          .backgroundColor(this.getCurrentTheme().surfaceColor)
          .border({ 
            width: 1, 
            color: this.getCurrentTheme().borderColor 
          })
          .borderRadius(0)
          .onClick(() => {
            this.handlePrintSubButtonClick('打印标签')
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ top: 4 })
    }
  }


  // 渲染快捷对话框
  @Builder
  private renderQuickDialog() {
    Stack() {
      Column() {
        Row() {
          Text(this.quickDialogTitle || '提示')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .layoutWeight(1)
          
          // 右上角：上一个/下一个按钮
          Row() {
            Button('上一个')
              .fontSize(12)
              .fontColor(this.getCurrentTheme().textColor)
              .backgroundColor(this.getCurrentTheme().backgroundColor)
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
              .borderRadius(6)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .onClick(() => { this.navigateQuickDialog(-1) })

            Button('下一个')
              .fontSize(12)
              .fontColor(this.getCurrentTheme().textColor)
              .backgroundColor(this.getCurrentTheme().backgroundColor)
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
              .borderRadius(6)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .margin({ left: 8 })
              .onClick(() => { this.navigateQuickDialog(1) })
          }
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 15, bottom: 15 })
        .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })

        // 内容区域暂时留空
        Blank()
          .height(60)

        // 右下角：确认/取消按钮
        Row() {
          Blank()
          
          Row() {
            Button('取消')
              .fontSize(14)
              .fontColor(this.getCurrentTheme().textColor)
              .backgroundColor(this.getCurrentTheme().backgroundColor)
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
              .borderRadius(8)
              .padding({ left: 20, right: 20, top: 10, bottom: 10 })
              .onClick(() => { this.quickDialogVisible = false })

            Button('确认')
              .fontSize(14)
              .fontColor(Color.White)
              .backgroundColor(this.getThemePrimaryColor())
              .borderRadius(8)
              .padding({ left: 20, right: 20, top: 10, bottom: 10 })
              .margin({ left: 10 })
              .onClick(() => {
                if (this.quickDialogConfirm) {
                  this.quickDialogConfirm()
                } else {
                  this.omniUIUtils.showSuccess('已确认')
                }
                this.quickDialogVisible = false
              })
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
        .alignItems(VerticalAlign.Center)
        .padding({ left: 20, right: 20, top: 0, bottom: 20 })
      }
      .width('80%')
      .constraintSize({ maxWidth: 500 })
      .backgroundColor(this.getCurrentTheme().surfaceColor)
      .borderRadius(12)
      .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 4 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0, 0, 0, 0.5)')
    .alignContent(Alignment.Center)
    .onClick(() => { this.quickDialogVisible = false })
    .visibility(this.quickDialogVisible ? Visibility.Visible : Visibility.None)
  }

  @Builder
  renderPage() {
    Stack() {
      Column() {
      
      Row() {
        // 左侧竖向导航（自定义展开/收缩）
        Stack() {
          // 导航按钮内容
          if (this.sideBarStatus) {
            LeftNavigationTabBar({
              currentPage: this.currentPage,
              showPrintSubButtons: this.showPrintSubButtons,
              onPageChange: (pageKey: string) => {
                this.handlePageChange(pageKey)
                // 只有非水果信息页面才显示切换消息
                if (pageKey !== 'fruit' && pageKey !== 'realtime') {
                  this.omniUIUtils.showInfo(`已切换到${this.getPageTitle(pageKey)}页面`)
                }
              },
              onPrintSubButtonClick: (subButtonName: string) => {
                this.handlePrintSubButtonClick(subButtonName)
              }
            })
          }

          // 箭头按钮 - 贴在右边边缘，垂直居中，更突出
          ArrowToggleButton({
            isExpanded: this.sideBarStatus,
            onToggle: () => {
              this.sideBarStatus = !this.sideBarStatus
            }
          })
          .position({ x: this.sideBarStatus ? 120 : 5, y: '50%' })
          .translate({ y: -20 })
          .zIndex(10) // 确保在最上层
        }
        .width(this.sideBarStatus ? 150 : 50)
        .height('100%')
        // .padding({ left: 8, right: 8, top: 8, bottom: 8 })
        .backgroundColor(this.sideBarStatus ? this.getNavBgForCurrentPage() : this.getCurrentTheme().backgroundColor)

        // 右侧内容
        Column() {
          this.renderPageContent()
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.getCurrentTheme().pageBg ?? this.getCurrentTheme().surfaceColor)
        .padding({ bottom: 12 })
        .layoutWeight(1)

      }
      .width('100%')
      .height('100%')
      .layoutWeight(1)

      //（已按需移除底部任务栏）
      }
      .height('100%')
      .width('100%')
      
      // 移除底部栏
      
      // 主题选择器弹窗
      // if (this.showThemeSelector) {
      //   ThemeSelector({
      //     onThemeSelected: (theme: OmniThemeType) => {
      //       const hook = useOmniTheme()
      //       hook.setTheme(theme)
      //       this.showThemeSelector = false
      //       const themeName = this.omniThemeManager.getThemeName(theme)
      //       this.omniUIUtils.showSuccess(`已切换到${themeName}`)
      //     },
      //     onCancel: () => {
      //       this.showThemeSelector = false
      //     }
      //   })
      // }

      // 水果信息对话框
      if (this.showFruitInfoDialog) {
        FruitInfoDialog({
          isVisible: this.showFruitInfoDialog,
          onConfirm: (fruitInfo: FruitInfo) => {
            this.handleFruitInfoConfirm(fruitInfo)
          },
          onCancel: () => {
            this.handleFruitInfoCancel()
          }
        })
      }

      // 载入程序对话框
      if (this.showLoadProgramDialog) {
        LoadProgramDialog({
          isVisible: this.showLoadProgramDialog,
          onConfirm: (programInfo: ProgramInfo) => {
            this.handleLoadProgramConfirm(programInfo)
          },
          onCancel: () => {
            this.handleLoadProgramCancel()
          }
        })
      }

      // 实时统计对话框（与水果信息同风格：统一为独立弹窗组件）
      if (this.showRealtimeDialog) {
        RealtimeStatsDialog({
          isVisible: this.showRealtimeDialog,
          onConfirm: (_stats) => {
            this.omniUIUtils.showInfo('已确认实时统计')
            this.showRealtimeDialog = false
          },
          onCancel: () => {
            this.omniUIUtils.showInfo('已取消查看实时统计')
            this.showRealtimeDialog = false
          }
        })
      }

      // 保存程序对话框
      if (this.showSaveProgramDialog) {
        SaveProgramDialog({
          isVisible: this.showSaveProgramDialog,
          onConfirm: (saveProgramInfo: SaveProgramInfo) => {
            this.handleSaveProgramConfirm(saveProgramInfo)
          },
          onCancel: () => {
            this.handleSaveProgramCancel()
          }
        })
      }

      // 分选状态对话框 - 悬浮在底部控制栏上方
      if (this.showSortingStatusDialog) {
        Stack() {
          SortingStatusDialog({
            isVisible: this.showSortingStatusDialog,
            onConfirm: (isNormal: boolean) => {
              this.handleSortingStatusConfirm(isNormal)
            },
            onCancel: () => {
              this.handleSortingStatusCancel()
            }
          })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .onClick(() => {
          // 点击外部区域关闭弹窗
          this.showSortingStatusDialog = false
        })
      }

      // 通用快捷对话框
      this.renderQuickDialog()

      // 全屏居中：个人信息编辑弹窗（由页面根部渲染，覆盖全屏）
      if (this.editUserLabelVisible) {
        Stack() {
          Scroll() {
            Column() {
            // 标题
            Row() {
              Text('修改个人信息')
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.getCurrentTheme().textColor)
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 16, bottom: 10 })
            .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })

            // 个人信息设置区域
            Column() {
              // 当前头像和姓名预览
              Row() {
                Text('当前设置：')
                  .fontSize(20)
                  .fontColor(this.getCurrentTheme().textColor)
                  .margin({ right: 12 })
                
                IBestAvatar({
                  src: this.selectedAvatarUrl || this.avatarOptions[0],
                  defaultAvatar: $r('app.media.default_avatar'),
                  avatarSize: 60,
                  shape: 'circle'
                })
                
                Text(this.tempUserLabel)
                  .fontSize(20)
                  .fontColor(this.getCurrentTheme().textColor)
                  .margin({ left: 12 })
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)
              .margin({ bottom: 20 })

              // 头像选择
              Column() {
                Text('选择头像：')
                  .fontSize(20)
                  .fontColor(this.getCurrentTheme().textColor)
                  .alignSelf(ItemAlign.Start)
                  .margin({ bottom: 12 })
                
                // 头像网格
                Grid() {
                  ForEach(this.avatarOptions, (avatarUrl: string, index: number) => {
                    GridItem() {
                      IBestAvatar({
                        src: avatarUrl,
                        defaultAvatar: $r('app.media.default_avatar'),
                        avatarSize: 60,
                        shape: 'circle',
                        onAvatarClick: () => {
                          console.log('选择头像:', avatarUrl)
                          this.selectedAvatarUrl = avatarUrl
                        }
                      })
                      .border({
                        width: this.selectedAvatarUrl === avatarUrl ? 3 : 1,
                        color: this.selectedAvatarUrl === avatarUrl ? '#EA7A10' : this.getCurrentTheme().borderColor
                      })
                      .borderRadius(8)
                      .padding(4)
                    }
                  })
                }
                .columnsTemplate('1fr 1fr 1fr 1fr')
                .rowsGap(12)
                .columnsGap(12)
                .width('100%')
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .margin({ bottom: 20 })

              // 姓名输入框
              Row() {
                Text('姓名设置：')
                  .fontSize(20)
                  .fontColor(this.getCurrentTheme().textColor)
                  .margin({ right: 12 })
                
                TextInput({ 
                  text: this.tempUserLabel, 
                  placeholder: '请输入显示标签' 
                })
                  .fontSize(18)
                  .fontColor(this.getCurrentTheme().textColor)
                  .backgroundColor(this.getCurrentTheme().backgroundColor)
                  .border({ width: 1, color: this.getCurrentTheme().borderColor })
                  .borderRadius(8)
                  .padding({ left: 12, right: 12, top: 12, bottom: 12 })
                  .layoutWeight(1)
                  .onChange((v: string) => { this.tempUserLabel = v })
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 16, bottom: 16 })
            .alignItems(HorizontalAlign.Start)

            // 底部操作按钮
            Row() {
              Button('取消')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.getCurrentTheme().textColor)
                .backgroundColor(this.getCurrentTheme().backgroundColor)
                .border({ width: 2, color: this.getCurrentTheme().borderColor })
                .borderRadius(8)
                .padding({ left: 40, right: 40, top: 16, bottom: 16 })
                .layoutWeight(1)
                .onClick(() => { 
                  AppStorage.set('EDIT_USER_LABEL_VISIBLE', false) 
                })

              Button('确认')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor(Color.White)
                .backgroundColor(this.getThemePrimaryColor())
                .borderRadius(8)
                .padding({ left: 40, right: 40, top: 16, bottom: 16 })
                .layoutWeight(1)
                .margin({ left: 12 })
                .onClick(() => {
                  const text = (this.tempUserLabel || '').trim()
                  if (text.length > 0) {
                    AppStorage.setOrCreate('TOP_USER_LABEL', text)
                  }
                  // 保存选中的头像
                  console.log('保存头像:', this.selectedAvatarUrl)
                  AppStorage.setOrCreate('SELECTED_AVATAR_URL', this.selectedAvatarUrl)
                  AppStorage.set('EDIT_USER_LABEL_VISIBLE', false)
                })
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 20, bottom: 20 })
            .backgroundColor(this.getCurrentTheme().surfaceColor)
            .border({ width: { top: 1 }, color: this.getCurrentTheme().borderColor })
            }
            .width('80%')
            .constraintSize({ maxWidth: 460 })
            .backgroundColor(this.getCurrentTheme().surfaceColor)
            .borderRadius(12)
            .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 4 })
            .onAppear(() => {
              this.tempUserLabel = AppStorage.get('TOP_USER_LABEL') || '姓名'
              this.selectedAvatarUrl = AppStorage.get('SELECTED_AVATAR_URL') || this.avatarOptions[0]
              console.log('弹窗打开，当前头像URL:', this.selectedAvatarUrl)
              console.log('头像选项列表:', this.avatarOptions)
            })
          }
          .scrollable(ScrollDirection.Vertical)
          .scrollBar(BarState.Auto)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .alignContent(Alignment.Center)
      }


    }
  }

  build() {
    Column() {
      // 顶部状态栏（全局可见）
      TopStatusBar({ 
        currentPage: this.currentPage,
        selectedFSM: this.selectedFSM,
        onFSMChange: (fsm: 'FSM1' | 'FSM2') => {
          console.log(`🔄 FSM切换开始: ${this.selectedFSM} -> ${fsm}`)

          // 先保存当前主题到当前FSM状态（在切换之前）
          const currentTheme = this.omniThemeManager.getCurrentThemeType()
          
          // 使用组件内部状态保存主题
          if (this.selectedFSM === 'FSM1') {
            this.fsm1Theme = currentTheme
            console.log(`💾 保存当前FSM1的主题设置:`, currentTheme, `状态变量: fsm1Theme`)
          } else {
            this.fsm2Theme = currentTheme
            console.log(`💾 保存当前FSM2的主题设置:`, currentTheme, `状态变量: fsm2Theme`)
          }
          
          // 立即验证保存是否成功
          const currentThemeValue = this.selectedFSM === 'FSM1' ? this.fsm1Theme : this.fsm2Theme
          console.log(`✅ 验证保存结果:`, currentThemeValue, `状态变量: ${this.selectedFSM === 'FSM1' ? 'fsm1Theme' : 'fsm2Theme'}`)
          
          // 更新全局FSM状态
          AppStorage.set('HOME_SELECTED_FSM', fsm)
          console.log(`🔄 已更新FSM状态为: ${fsm}`)

          // 恢复目标FSM状态的主题设置
          const targetTheme = fsm === 'FSM1' ? this.fsm1Theme : this.fsm2Theme
          console.log(`🔍 查找目标${fsm}的主题设置:`, targetTheme, `状态变量: ${fsm === 'FSM1' ? 'fsm1Theme' : 'fsm2Theme'}`)
          
          // 检查组件状态中所有的FSM主题
          console.log(`🔍 检查组件状态中的FSM主题:`)
          console.log(`  fsm1Theme:`, this.fsm1Theme, `(类型: ${typeof this.fsm1Theme})`)
          console.log(`  fsm2Theme:`, this.fsm2Theme, `(类型: ${typeof this.fsm2Theme})`)
          
          if (targetTheme) {
            // 如果目标FSM有保存的主题设置，则恢复
            this.omniThemeManager.setTheme(targetTheme)
            console.log(`✅ 恢复${fsm}的主题设置:`, targetTheme)
          } else {
            // 如果目标FSM没有保存的主题设置，则使用默认主题
            if (fsm === 'FSM2') {
              this.omniThemeManager.setTheme(OmniThemeType.WARM_AMBER)
              console.log(`🎨 使用${fsm}的默认主题: WARM_AMBER`)
            } else {
              this.omniThemeManager.setTheme(OmniThemeType.PROFESSIONAL_BLUE)
              console.log(`🎨 使用${fsm}的默认主题: PROFESSIONAL_BLUE`)
            }
          }

          console.log(`✅ FSM切换完成: ${fsm}`)
        }
      })

      // 主体内容区域（可伸缩，占据中间空间）
      Column() {
        if ((this.themeVersion % 2) === 0) {
          this.renderPage()
        } else {
          this.renderPage()
        }
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ bottom: 0 })

      // 底部控制栏（全局固定）
      BottomControlBar({
        onSortingStatusClick: () => {
          this.showSortingStatus()
        },
        onOutletClick: (outletNumber: number) => {
          console.log(`出口${outletNumber}被点击`)
          // 可以在这里处理出口点击逻辑
        },
        onFruitCupClick: (cupNumber: number) => {
          console.log(`果杯${cupNumber}被点击`)
          // 可以在这里处理果杯点击逻辑
        },
        onSCMClick: () => {
          console.log('SCM按钮被点击')
          // 可以在这里处理SCM点击逻辑
        }
      })
      .width('100%')
      .zIndex(100) // 确保在最上层

      // 悬浮窗组件
      if (this.showFloatingWindow) {
        FloatingWindow({
          isVisible: this.showFloatingWindow,
          title: this.floatingWindowTitle,
          windowWidth: '27.78%',
          windowHeight: '48.61%',
          windowPosition: { x: 120, y: 400 },
          onClose: () => {
            this.handleFloatingWindowClose()
          }
        }) {
          // 悬浮窗内容 - 3个Tab的设置页面
          Column() {
            // Tab导航栏
            Row() {
              this.buildFloatingTabButton('出口', 'export')
              this.buildFloatingTabButton('设置', 'settings')
              this.buildFloatingTabButton('帮助', 'help')
            }
            .width('100%')
            .height('3.47%')
            .backgroundColor(this.getCurrentTheme().surfaceColor)
            .borderRadius(8)
            .margin({ bottom: 16 })

            // Tab内容区域
            if (this.floatingWindowTitle === '更多设置') {
              if (this.selectedFloatingTab === 'export') {
                this.buildExportTabContent()
              } else if (this.selectedFloatingTab === 'settings') {
                this.buildSettingsTabContent()
              } else if (this.selectedFloatingTab === 'help') {
                this.buildHelpTabContent()
              }
            } else {
              // 其他页面的简单内容
              Text(this.floatingWindowContent)
                .fontSize(14)
                .fontColor(this.getCurrentTheme().textColor)
                .lineHeight(24)
                .padding(16)
                .width('100%')
                .textAlign(TextAlign.Start)
            }
          }
          .width('100%')
          .height('100%')
        }
      }
      
      // 主题选择器
      if (this.showThemeSelector) {
        Stack() {
          this.buildThemeSelector()
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(2000) // 主题选择器层级
      }
      
      // 工程设置对话框
      if (this.showEngineeringSettingsDialog) {
        Stack() {
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
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(3000) // 确保在最上层
      }
    }
    .width('100%')
    .height('100%')
  }
}
