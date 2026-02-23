import { HomeContent } from './home/HomeContent'
import { LevelContent } from './level/LevelContent'
import { QualityContent } from './quality/QualityContent'
import { HistoryContent } from './history/HistoryContent'
import { EndProcessingContent } from './endprocessing/EndProcessingContent'
import { EndProcessingConfirmDialog } from './endprocessing/EndProcessingConfirmDialog'
import { LiquidCardsArea } from './home/LiquidCardsArea'
import { OutletDialog } from './home/OutletDialog'
import { HomeDataManager } from './home/core/HomeDataManager'
import { TableRow } from '../components/layout/LevelTable'
import { ExitConfigManager, OutletConfig } from './home/core/ExitConfigManager'
import { GradeInfoConfigManager } from './home/core/GradeInfoConfigManager'
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
import { ValveTestDialog } from '../components/dialogs/ValveTestDialog'
import { MotorEnableDialog } from '../components/dialogs/MotorEnableDialog'
import { ResetCupConfirmDialog } from '../components/dialogs/ResetCupConfirmDialog'
import { TestCupDialog } from '../components/dialogs/TestCupDialog'
import { DeviceInfoDialog } from '../components/dialogs/DeviceInfoDialog'
import { ConfigInfoDialog } from '../components/dialogs/ConfigInfoDialog'
import { AlarmInfoDialog } from '../components/dialogs/AlarmInfoDialog'
import { ElectricalFaultDialog } from '../components/dialogs/ElectricalFaultDialog'
import { SystemFaultDialog } from '../components/dialogs/SystemFaultDialog'
import { LabelingSettingsDialog } from '../components/dialogs/LabelingSettingsDialog'
import { ExitScreenSettingsDialog } from '../components/dialogs/ExitScreenSettingsDialog'
import { getCurrentTheme as resolveTheme } from '../utils/theme/ThemeUtils'
import { NavigationUtils } from '../utils/helpers/NavigationUtils'
import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../utils/theme/OmniThemeManager'
import { useOmniTheme, OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../utils/theme/useOmniTheme'
import { AppleDesignStyle } from '../utils/theme/AppleDesignStyle'
import { OmniUIInit } from '../utils/helpers/OmniUIInit'
import { OmniUIUtils } from '../utils/helpers/OmniUIUtils'
// 导入 IBest-UI 组件
import { IBestButton, IBestIcon, IBestTag, IBestInit, IBestAvatar, IBestAvatarGroup } from '@ibestservices/ibest-ui'
import { I18nManager, t, I18N_LANGUAGE_KEY, I18N_VERSION_KEY } from '../utils/i18n/I18nManager'
/*
import GlobalStore from '../database/orm/model/GlobalStore'
*/
import { window } from '@kit.ArkUI'
import { fileIo as fs } from '@kit.CoreFileKit'
import { buffer } from '@kit.ArkTS'
import { RectButton } from '../components/ui/buttons/RectButton'
import { TopStatusBar, WindowControlButtons } from '../components/layout/TopStatusBar'
import { BottomControlBar } from '../components/layout/BottomControlBar'
import { TabBarDirection, TabConfig } from '../components/ui/layout/OmniTabBar'
import { KeyCode } from '@kit.InputKit';
import { UserInfoStorage } from '../utils/storage/UserInfoStorage'
import common from '@ohos.app.ability.common'
import { PrintManager } from '../utils/print/PrintManager'
import { getConfigSender } from '../protocol/ConfigSender'
import { getDatabaseSync } from '../protocol/DatabaseSync'
import { getGlobalDataInterface } from '../protocol/GlobalDataInterface'
import { ConstPreDefine } from '../protocol/ConstPreDefine'
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

// 翻译项接口
interface TranslationItem {
  key: string  // 显示文本（当前语言的翻译或中文键）
  originalKey: string  // 原始中文键（用于保存）
  value: string  // 用户编辑的翻译文本
}

// 翻译记录类型
type TranslationRecord = Record<string, string>

@Entry
@Component
struct Page {
  @State currentPage: string = 'home'
  @State pageTabIndex: number = 0
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
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0  // 监听语言变化，触发 UI 更新
  
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
  @StorageLink('HOME_LIQUID_CARD_DOUBLE_CLICK_INDEX') @Watch('onLiquidCardDoubleClickIndexChange') private liquidCardDoubleClickIndex: number = 0
  private bottomButtonsCount: number = 10
  @State private showOutletDialog: boolean = false
  @State private outletDialogIndex: number = 1
  @State private outletDialogLevelTableData: TableRow[] = []
  @State private outletDialogConfig: OutletConfig | null = null
  // 打印按钮悬停状态
  @State showPrintSubButtons: boolean = false
  @State showEndProcessingConfirmDialog: boolean = false
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
  
  // 电磁阀测试对话框状态
  @State showValveTestDialog: boolean = false
  
  // 电机使能对话框状态
  @State showMotorEnableDialog: boolean = false
  
  // 复位果杯确认对话框状态
  @State showResetCupConfirmDialog: boolean = false
  
  // 测试果杯对话框状态
  @State showTestCupDialog: boolean = false
  
  // 设备信息对话框状态
  @State showDeviceInfoDialog: boolean = false
  
  // 配置信息对话框状态
  @State showConfigInfoDialog: boolean = false
  
  // 报警信息对话框状态
  @State showAlarmInfoDialog: boolean = false
  
  // 电器故障设置对话框状态
  @State showElectricalFaultDialog: boolean = false
  
  // 系统故障设置对话框状态
  @State showSystemFaultDialog: boolean = false
  
  // 贴标设置对话框状态
  @State showLabelingSettingsDialog: boolean = false
  
  // 出口屏设置对话框状态
  @State showExitScreenSettingsDialog: boolean = false
  
  // 语言选择器状态
  @State showLanguageSelector: boolean = false
  @State currentLanguage: string = '中文'
  @State availableLanguages: string[] = []
  @State selectedLanguageTemp: string = '中文'  // 临时选中的语言（用于确认）
  
  // 翻译编辑器状态
  @State showTranslationEditor: boolean = false
  @State translationFilter: string = ''
  @State newTranslationKey: string = ''
  @State newTranslationValue: string = ''
  @State translations: TranslationItem[] = []
  @State showLanguageNameDialog: boolean = false
  @State languageNameInput: string = ''
  
  
  
  // 页面初始化时初始化 Omni-UI 和 IBest-UI
  async aboutToAppear() {
    this.omniUIInit.init()
    this.omniThemeManager.init()
    // 初始化 Ctrl 多选状态
    AppStorage.setOrCreate('HOME_CTRL_PRESSED', false)
    
    // 初始化用户信息持久化存储并加载保存的用户名和头像
    try {
      const ctx = getContext(this) as common.UIAbilityContext
      const userInfoStorage = UserInfoStorage.getInstance()
      await userInfoStorage.init(ctx)
      
      // 加载保存的用户名
      const savedUserName = await userInfoStorage.loadUserName()
      if (savedUserName && savedUserName !== '姓名') {
        AppStorage.setOrCreate('TOP_USER_LABEL', savedUserName)
        console.log(`[Home] Loaded saved userName: ${savedUserName}`)
      }
      
      // 加载保存的头像URL
      const savedAvatarUrl = await userInfoStorage.loadAvatarUrl()
      if (savedAvatarUrl) {
        AppStorage.setOrCreate('SELECTED_AVATAR_URL', savedAvatarUrl)
        console.log(`[Home] Loaded saved avatarUrl: ${savedAvatarUrl}`)
      }
    } catch (e) {
      console.error('[Home] Failed to load user info from storage:', JSON.stringify(e))
    }
    
    // 同步当前语言（从 I18nManager 或 AppStorage 读取）
    const mgr = I18nManager.getInstance()
    if (mgr.isInitialized()) {
      const savedLang = AppStorage.get(I18N_LANGUAGE_KEY) as string
      if (savedLang) {
        this.currentLanguage = savedLang
        console.log(`[Home] aboutToAppear: synced language to ${savedLang}`)
      }
    }
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

  // 将页面键映射为展示标题（依赖 i18nVersion 确保语言变化时重新计算）
  private getPageTitle(pageKey: string): string {
    // 引用 i18nVersion 确保语言变化时重新计算
    const _version = this.i18nVersion
    const map: Record<string, string> = {
      'home': t('主页', '主页'),
      'quality': t('品质', '品质'),
      'level': t('等级', '等级'),
      'fruit': t('水果信息', '水果信息'),
      'load': t('载入程序', '载入程序'),
      'save': t('保存程序', '保存程序'),
      'history': t('历史加工', '历史加工'),
      'realtime': t('实时统计', '实时统计'),
      'end': t('结束加工', '结束加工'),
      'print': t('打印', '打印'),
      'more': t('更多', '更多')
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
      'end': (): void => this.openEndProcessingConfirmDialog(),
      'more': (): void => this.displayFloatingWindow(t('更多设置', '更多设置'), t('这里是更多设置和系统配置。\\n\\n• 系统设置\\n• 用户管理\\n• 数据备份\\n• 系统维护', '这里是更多设置和系统配置。\\n\\n• 系统设置\\n• 用户管理\\n• 数据备份\\n• 系统维护')),
      // 默认处理：正常页面切换
      'default': (): void => { this.currentPage = this.currentPage }
    }
  }

  private getPageTabIndex(pageKey: string): number {
    if (pageKey === 'home') return 0
    if (pageKey === 'quality') return 1
    if (pageKey === 'level') return 2
    if (pageKey === 'history') return 3
    return 0
  }

  private getPageKeyByTabIndex(index: number): string {
    if (index === 1) return 'quality'
    if (index === 2) return 'level'
    if (index === 3) return 'history'
    return 'home'
  }

  private getActionTabs(): TabConfig[] {
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
              this.handlePrintSubButtonClick('打印报告')
            }
          },
          {
            key: 'print_label',
            label: t('打印标签', '打印标签'),
            onClick: () => {
              this.handlePrintSubButtonClick('打印标签')
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

  private canEndProcessing(): boolean {
    const dbSync = getDatabaseSync()
    const gdi = getGlobalDataInterface()
    const batchId = dbSync.getCurrentBatchId()
    const global = gdi.getGlobalData()
    return !(batchId === 0 || global.startTime === 0 || global.totalYield === 0)
  }

  private openEndProcessingConfirmDialog(): void {
    console.log('结束加工点击')
    if (!this.canEndProcessing()) {
      console.log('结束加工被拦截')
      AlertDialog.show({
        title: t('提示', '提示'),
        message: t('当前状态无法结束加工！', '当前状态无法结束加工！'),
        primaryButton: {
          value: t('确定', '确定'),
          action: () => {}
        }
      })
      return
    }
    this.showEndProcessingConfirmDialog = true
  }

  // 页面切换处理方法
  private handlePageChange(pageName: string): void {
    if (pageName === 'home' || pageName === 'quality' || pageName === 'level' || pageName === 'history') {
      this.currentPage = pageName
      this.pageTabIndex = this.getPageTabIndex(pageName)
      return
    }
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
    this.omniUIUtils.showInfo(t('已取消查看水果信息', '已取消查看水果信息'))
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
    this.omniUIUtils.showInfo(t('已取消载入程序', '已取消载入程序'))
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
    this.omniUIUtils.showInfo(t('已取消保存程序', '已取消保存程序'))
    this.showSaveProgramDialog = false
  }

  // 分选状态功能封装
  private showSortingStatus(): void {
    this.showSortingStatusDialog = true
  }

  // 处理分选状态对话框确认
  private handleSortingStatusConfirm(isNormal: boolean): void {
    const statusText = isNormal ? t('正常分选', '正常分选') : t('异常分选', '异常分选')
    this.omniUIUtils.showInfo(`分选状态已设置为：${statusText}`)
    this.showSortingStatusDialog = false
  }

  // 处理分选状态对话框取消
  private handleSortingStatusCancel(): void {
    this.omniUIUtils.showInfo(t('已取消分选状态设置', '已取消分选状态设置'))
    this.showSortingStatusDialog = false
  }

  // 处理打印按钮点击显示子按钮
  private handlePrintClick(): void {
    console.log(`[Home] handlePrintClick called. Current state: ${this.showPrintSubButtons}`);
    this.showPrintSubButtons = !this.showPrintSubButtons;
    console.log(`[Home] handlePrintClick new state: ${this.showPrintSubButtons}`);
  }

  // 处理打印子按钮点击
  private async handlePrintSubButtonClick(subButtonName: string): Promise<void> {
    console.log(`[Home] handlePrintSubButtonClick called with: ${subButtonName}`);
    this.omniUIUtils.showInfo(`正在准备${subButtonName}...`)
    
    try {
      const context = getContext(this) as common.UIAbilityContext
      const filesDir = context.filesDir
      console.log(`[Home] Files directory: ${filesDir}`);
      
      const printManager = PrintManager.getInstance()
      
      // 创建一个简单的测试文件
      const fileName = subButtonName.includes('报告') ? 'report_test.txt' : 'label_test.txt'
      const filePath = `${filesDir}/${fileName}`
      const fileContent = subButtonName.includes('报告') 
        ? '这是一份测试报告\n\n项目: 水果分选系统\n时间: 2025-12-15\n状态: 正常' 
        : '测试标签\n\n等级: 特级\n重量: 250g'
      
      const file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC)
      fs.writeSync(file.fd, fileContent)
      fs.closeSync(file.fd)
      
      // 使用 FD (文件描述符) 方式传递，解决系统打印服务无法读取私有路径文件的问题
      const fileRead = fs.openSync(filePath, fs.OpenMode.READ_ONLY)
      const fileUri = `fd://${fileRead.fd}`
      console.log(`[Home] Created test file for printing (FD): ${fileUri}`)
      
      await printManager.printFiles(context, [fileUri])
      console.log(`[Home] printManager.printFiles called`);
      
      // 注意：这里暂时不关闭 fileRead.fd，等待打印服务读取
      // 在实际业务中，应该监听打印结束事件后再关闭

      
    } catch (e) {
      console.error('[Home] Print failed:', e)
      this.omniUIUtils.showError(`打印失败: ${JSON.stringify(e)}`)
    }
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
    this.omniUIUtils.showSuccess(t('工程设置已保存', '工程设置已保存'))
    this.showEngineeringSettingsDialog = false
  }

  private handleEngineeringSettingsCancel(): void {
    this.omniUIUtils.showInfo(t('已取消工程设置', '已取消工程设置'))
    this.showEngineeringSettingsDialog = false
  }

  // 语言选择相关方法
  private async openLanguageSelector(): Promise<void> {
    console.log('[Home] Opening language selector')
    await this.refreshAvailableLanguages()
    this.selectedLanguageTemp = this.currentLanguage  // 初始化临时选中为当前语言
    this.showLanguageSelector = true
  }

  private async refreshAvailableLanguages(): Promise<void> {
    console.log('[Home] Refreshing available languages')
    try {
      const mgr = I18nManager.getInstance()
      const context = getContext(this) as common.UIAbilityContext
      if (!mgr.isInitialized() && context) {
        await mgr.init(context)
      }
      const languages = mgr.listLanguageFiles()
      this.availableLanguages = languages
      console.log(`[Home] Available languages: ${JSON.stringify(languages)}`)
    } catch (e) {
      console.error('[Home] Failed to refresh languages:', e)
      this.availableLanguages = []
    }
  }

  private selectLanguageTemp(lang: string): void {
    // 临时选中语言（不立即切换）
    this.selectedLanguageTemp = lang
    console.log(`[Home] Temporarily selected language: ${lang}`)
  }

  private async confirmLanguageSelection(): Promise<void> {
    // 确认选择语言
    const lang = this.selectedLanguageTemp
    console.log(`[Home] Confirming language selection: ${lang}`)
    this.currentLanguage = lang
    
    try {
      const mgr = I18nManager.getInstance()
      await mgr.setLanguage(lang)
      this.omniUIUtils.showSuccess(`已切换到：${lang}`)
    } catch (e) {
      console.error(`[Home] Failed to set language ${lang}:`, e)
      this.omniUIUtils.showError(`切换语言失败: ${JSON.stringify(e)}`)
    }
    
    this.showLanguageSelector = false
  }

  private cancelLanguageSelection(): void {
    // 取消选择，恢复原状态
    this.selectedLanguageTemp = this.currentLanguage
    this.showLanguageSelector = false
    console.log('[Home] Language selection cancelled')
  }

  // 翻译编辑相关方法
  private async openTranslationEditor(): Promise<void> {
    console.log('[Home] openTranslationEditor: start')
    try {
      const context = getContext(this) as common.UIAbilityContext;
      if (!context) {
        console.error('[Home] context is not available')
        this.omniUIUtils.showError(t('翻译初始化失败：上下文未就绪', '翻译初始化失败：上下文未就绪'))
        return
      }
      const mgr = I18nManager.getInstance()
      if (!mgr.isInitialized()) {
        console.log('[Home] I18nManager not initialized, initializing...')
        await mgr.init(context)
      }

      // 获取当前语言
      const currentLang = mgr.getCurrentLanguage()
      console.log(`[Home] Current language: ${currentLang}`)

      // 从默认模板文件加载所有字段（中文键）
      const appCtx = context.getApplicationContext()
      const filesDir = appCtx.filesDir
      const defaultTemplatePath = `${filesDir}/i18n/translations.default.json`
      console.log(`[Home] Loading default template from: ${defaultTemplatePath}`)

      let content: string | undefined = undefined

      // 优先读取 rawfile 中的最新版本，确保字段完整
      let rawfileContent: string | undefined = undefined
      try {
        const rawBytes: Uint8Array = appCtx.resourceManager.getRawFileContentSync('file/translations.default.json')
        const rawBuf = buffer.from(rawBytes.buffer)
        rawfileContent = rawBuf.toString('utf-8')
        console.log('[Home] Loaded template from rawfile')
      } catch (e) {
        console.error(`[Home] Failed to load template from rawfile: ${JSON.stringify(e)}`)
      }

      // 读取沙箱文件（如果存在）
      let sandboxContent: string | undefined = undefined
      try {
        const stat = fs.statSync(defaultTemplatePath)
        if (stat.size > 0) {
          const file = fs.openSync(defaultTemplatePath, fs.OpenMode.READ_ONLY)
          const dataBuffer = new ArrayBuffer(stat.size)
          fs.readSync(file.fd, dataBuffer)
          fs.closeSync(file.fd)
          const u8 = new Uint8Array(dataBuffer)
          const buf = buffer.from(u8.buffer)
          sandboxContent = buf.toString('utf-8')
          console.log(`[Home] Sandbox template size: ${stat.size} bytes`)
        }
      } catch (e) {
        console.warn(`[Home] Sandbox template missing: ${JSON.stringify(e)}`)
      }

      // 比较字段数量，使用字段更多的版本
      let rawfileCount = 0
      let sandboxCount = 0
      
      if (rawfileContent) {
        try {
          const rawfileMap = new Map<string, string>()
          JSON.parse(rawfileContent, (key: string, value: string | number | boolean | null): string | number | boolean | null => {
            if (key !== '' && value !== undefined && value !== null) {
              rawfileMap.set(key, String(value))
            }
            return value
          })
          rawfileCount = rawfileMap.size
          console.log(`[Home] Rawfile has ${rawfileCount} fields`)
        } catch (e) {
          console.warn(`[Home] Failed to parse rawfile: ${JSON.stringify(e)}`)
        }
      }

      if (sandboxContent) {
        try {
          const sandboxMap = new Map<string, string>()
          JSON.parse(sandboxContent, (key: string, value: string | number | boolean | null): string | number | boolean | null => {
            if (key !== '' && value !== undefined && value !== null) {
              sandboxMap.set(key, String(value))
            }
            return value
          })
          sandboxCount = sandboxMap.size
          console.log(`[Home] Sandbox has ${sandboxCount} fields`)
        } catch (e) {
          console.warn(`[Home] Failed to parse sandbox: ${JSON.stringify(e)}`)
        }
      }

      // 使用字段更多的版本，优先使用 rawfile（如果字段数相同或更多）
      if (rawfileContent && rawfileCount >= sandboxCount) {
        content = rawfileContent
        console.log(`[Home] Using rawfile template (${rawfileCount} fields)`)
        // 同步到沙箱
        try {
          const bufToSave = buffer.from(content, 'utf-8')
          const f = fs.openSync(defaultTemplatePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC)
          fs.writeSync(f.fd, bufToSave.buffer)
          fs.closeSync(f.fd)
          console.log('[Home] Synced rawfile template to sandbox')
        } catch (e) {
          console.warn(`[Home] Failed to sync to sandbox: ${JSON.stringify(e)}`)
        }
      } else if (sandboxContent) {
        content = sandboxContent
        console.log(`[Home] Using sandbox template (${sandboxCount} fields)`)
      } else if (rawfileContent) {
        content = rawfileContent
        console.log(`[Home] Using rawfile template (${rawfileCount} fields) as fallback`)
        // 同步到沙箱
        try {
          const bufToSave = buffer.from(content, 'utf-8')
          const f = fs.openSync(defaultTemplatePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC)
          fs.writeSync(f.fd, bufToSave.buffer)
          fs.closeSync(f.fd)
          console.log('[Home] Synced rawfile template to sandbox')
        } catch (e) {
          console.warn(`[Home] Failed to sync to sandbox: ${JSON.stringify(e)}`)
        }
      }

      // 加载当前语言的翻译（作为原始文本）
      let currentLangTranslations = new Map<string, string>()
      if (currentLang !== '中文') {
        const currentLangPath = `${filesDir}/i18n/${currentLang}.json`
        console.log(`[Home] Loading current language translations from: ${currentLangPath}`)
        try {
          if (fs.statSync(currentLangPath).size > 0) {
            const file = fs.openSync(currentLangPath, fs.OpenMode.READ_ONLY)
            const stat = fs.statSync(currentLangPath)
            const dataBuffer = new ArrayBuffer(stat.size)
            fs.readSync(file.fd, dataBuffer)
            fs.closeSync(file.fd)
            const u8 = new Uint8Array(dataBuffer)
            const buf = buffer.from(u8.buffer)
            const langContent = buf.toString('utf-8')
            // 使用 JSON.parse 的 reviver 函数解析 JSON 到 Map
            JSON.parse(langContent, (key: string, value: string | number | boolean | null): string | number | boolean | null => {
              if (key !== '' && value !== undefined && value !== null) {
                currentLangTranslations.set(key, String(value))
              }
              return value
            })
            console.log(`[Home] Loaded ${currentLangTranslations.size} translations from current language`)
          }
        } catch (e) {
          console.warn(`[Home] Failed to load current language translations: ${JSON.stringify(e)}`)
        }
      }

      let arr: TranslationItem[] = []
      if (content) {
        try {
          // 先解析为 Map 以便访问值
          const templateMap = new Map<string, string>()
          JSON.parse(content, (key: string, value: string | number | boolean | null): string | number | boolean | null => {
            if (key !== '' && value !== undefined && value !== null) {
              templateMap.set(key, String(value))
            }
            return value
          })
          
          // 遍历 Map 构建 TranslationItem 数组
          templateMap.forEach((val: string, k: string) => {
            // 如果当前语言不是中文，使用当前语言的翻译作为显示文本；否则使用中文键
            const displayText = currentLang !== '中文' && currentLangTranslations.has(k) 
              ? currentLangTranslations.get(k) ?? k 
              : k
            // 如果当前语言不是中文，使用当前语言的翻译作为初始值；否则使用空字符串
            const initialValue = currentLang !== '中文' && currentLangTranslations.has(k)
              ? currentLangTranslations.get(k) ?? ''
              : ''
            const item: TranslationItem = { key: displayText, originalKey: k, value: initialValue }
            arr.push(item)
          })
          console.log(`[Home] Loaded ${arr.length} template entries`)
        } catch (e) {
          console.error(`[Home] Failed to parse template content: ${JSON.stringify(e)}`)
        }
      } else {
        console.warn('[Home] No template content available, using empty list')
      }

      this.translations = arr
      console.log(`[Home] openTranslationEditor: loaded ${this.translations.length} items`)
      this.showTranslationEditor = true
    } catch (e) {
      console.error('[Home] openTranslationEditor failed', e)
      this.omniUIUtils.showError(t('翻译加载失败', '翻译加载失败') + ': ' + JSON.stringify(e))
    }
  }

  private updateTranslationKey(index: number, value: string): void {
    if (index < 0 || index >= this.translations.length) return
    const next: TranslationItem[] = [...this.translations]
    const updated: TranslationItem = { key: value, originalKey: next[index].originalKey, value: next[index].value }
    next[index] = updated
    this.translations = next
  }

  private updateTranslationValue(originalKey: string, value: string): void {
    const index = this.translations.findIndex(item => item.originalKey === originalKey)
    if (index === -1) return
    const next: TranslationItem[] = [...this.translations]
    const updated: TranslationItem = { key: next[index].key, originalKey: next[index].originalKey, value }
    next[index] = updated
    this.translations = next
  }

  private removeTranslation(index: number): void {
    if (index < 0 || index >= this.translations.length) return
    const next: TranslationItem[] = [...this.translations]
    next.splice(index, 1)
    this.translations = next
  }

  private addTranslation(): void {
    if (!this.newTranslationKey || this.newTranslationKey.trim().length === 0) {
      this.omniUIUtils.showInfo(t('请输入翻译键', '请输入翻译键'))
      return
    }
    const next: TranslationItem[] = [...this.translations]
    const item: TranslationItem = { 
      key: this.newTranslationKey.trim(), 
      originalKey: this.newTranslationKey.trim(),  // 新添加的项，originalKey 和 key 相同
      value: this.newTranslationValue ?? '' 
    }
    next.push(item)
    this.translations = next
    this.newTranslationKey = ''
    this.newTranslationValue = ''
  }

  private filteredTranslations(): TranslationItem[] {
    if (!this.translationFilter || this.translationFilter.trim().length === 0) {
      return this.translations
    }
    const keyword = this.translationFilter.trim().toLowerCase()
    return this.translations.filter((item) => {
      return item.key.toLowerCase().includes(keyword) || 
             item.originalKey.toLowerCase().includes(keyword) || 
             (item.value ?? '').toLowerCase().includes(keyword)
    })
  }

  /**
   * 获取总条目数
   */
  private getTotalCount(): number {
    return this.translations.length
  }

  /**
   * 获取已翻译条目数
   */
  private getTranslatedCount(): number {
    return this.translations.filter((item) => {
      return item.value && item.value.trim().length > 0
    }).length
  }

  /**
   * 获取翻译进度百分比
   */
  private getTranslationProgress(): number {
    const total = this.getTotalCount()
    if (total === 0) {
      return 0
    }
    const translated = this.getTranslatedCount()
    return Math.round((translated / total) * 100)
  }

  private async saveTranslations(): Promise<void> {
    console.log('[Home] saveTranslations: opening language name dialog')
    this.languageNameInput = ''
    this.showLanguageNameDialog = true
  }

  private async confirmSaveLanguage(): Promise<void> {
    const langName = this.languageNameInput.trim()
    if (!langName || langName.length === 0) {
      this.omniUIUtils.showInfo(t('请输入语言名称', '请输入语言名称'))
      return
    }

    // 检查文件名是否合法
    if (!/^[a-zA-Z0-9_\u4e00-\u9fa5]+$/.test(langName)) {
      this.omniUIUtils.showError('语言名称只能包含字母、数字、下划线和中文')
      return
    }

    console.log(`[Home] Saving translations as language: ${langName}`)
    this.showLanguageNameDialog = false

    try {
      const mgr = I18nManager.getInstance()
      const map = new Map<string, string>()
      this.translations.forEach((item) => {
        // 使用 originalKey 作为保存的键（原始中文键）
        if (item.originalKey && item.originalKey.trim().length > 0) {
          map.set(item.originalKey.trim(), item.value ?? '')
        }
      })
      console.log(`[Home] Prepared ${map.size} translations to save`)
      
      await mgr.saveLanguage(langName, map)
      this.omniUIUtils.showSuccess(t('翻译已保存为：{0}', '翻译已保存为：{0}').replace('{0}', langName))
      this.showTranslationEditor = false
      
      // 刷新可用语言列表
      await this.refreshAvailableLanguages()
    } catch (e) {
      console.error('[Home] saveTranslations failed', e)
      this.omniUIUtils.showError(t('保存失败', '保存失败') + ': ' + JSON.stringify(e))
    }
  }

  // 处理出口清空功能
  private handleExportClear(): void {
    console.log('开始清空液体卡片数据...')
    
    // 从AppStorage获取LiquidCardsArea引用
    const liquidCardsAreaRef: LiquidCardsArea | null = AppStorage.get('LIQUID_CARDS_AREA_REF') as LiquidCardsArea | null
    if (liquidCardsAreaRef) {
      liquidCardsAreaRef.clearAllCardData()
      this.omniUIUtils.showSuccess(t('清空成功！', '清空成功！'))//提示弹窗
      // 显示系统对话框，确保用户可见
      AlertDialog.show({
        title: t('提示', '提示'),
        message: t('清空成功！', '清空成功！'),
        confirm: { value: t('确定', '确定'), action: () => {} }
      })
    } else {
      console.error('液体卡片区域引用为空，无法清空数据')
      this.omniUIUtils.showError(t('清空失败：液体卡片区域未初始化', '清空失败：液体卡片区域未初始化'))
    }
  }

  // 处理数据清零功能（向下位机发送清零命令）
  private async handleClearData(): Promise<void> {
    try {
      const configSender = getConfigSender()
      
      // 显示确认对话框
      AlertDialog.show({
        title: t('确认', '确认'),
        message: t('确定要清零所有数据吗？此操作将清空下位机的统计数据。', '确定要清零所有数据吗？此操作将清空下位机的统计数据。'),
        primaryButton: {
          value: t('取消', '取消'),
          action: () => {}
        },
        secondaryButton: {
          value: t('确定', '确定'),
          action: async () => {
            try {
              // 发送数据清零命令到所有已连接的设备
              const success = await configSender.sendClearData()
              
              if (success) {
                this.omniUIUtils.showSuccess(t('数据清零命令已发送', '数据清零命令已发送'))
                console.log('数据清零命令发送成功')
              } else {
                this.omniUIUtils.showError(t('数据清零命令发送失败，请检查设备连接', '数据清零命令发送失败，请检查设备连接'))
                console.error('数据清零命令发送失败')
              }
            } catch (error) {
              const errorMsg = error instanceof Error ? error.message : String(error)
              this.omniUIUtils.showError(t('数据清零失败', '数据清零失败') + ': ' + errorMsg)
              console.error('数据清零异常:', error)
            }
          }
        }
      })
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error)
      this.omniUIUtils.showError(t('操作失败', '操作失败') + ': ' + errorMsg)
      console.error('处理数据清零失败:', error)
    }
  }

  private async handleEndProcessing(clearDeviceData: boolean): Promise<void> {
    const dbSync = getDatabaseSync()
    const gdi = getGlobalDataInterface()
    const batchId = dbSync.getCurrentBatchId()
    const global = gdi.getGlobalData()
    if (batchId === 0 || global.startTime === 0 || global.totalYield === 0) {
      this.omniUIUtils.showError(t('当前状态无法结束加工！', '当前状态无法结束加工！'))
      return
    }

    try {
      await dbSync.saveNow()
      const sender = getConfigSender()
      const deviceOk = clearDeviceData ? await sender.sendClearData() : await sender.sendSaveData()
      if (!deviceOk) {
        this.omniUIUtils.showError(t('结束加工指令发送失败！', '结束加工指令发送失败！'))
        return
      }

      const endOk = await dbSync.endCurrentBatch()
      if (!endOk) {
        this.omniUIUtils.showError(t('结束加工失败：批次未保存', '结束加工失败：批次未保存'))
        return
      }

      gdi.stopProcessing()
      gdi.clearData()

      AlertDialog.show({
        title: t('提示', '提示'),
        message: t('本次加工结束！是否打印报表？', '本次加工结束！是否打印报表？'),
        primaryButton: {
          value: t('否', '否'),
          action: () => {}
        },
        secondaryButton: {
          value: t('是', '是'),
          action: () => {
            this.handlePrintSubButtonClick(t('打印报告', '打印报告'))
          }
        }
      })
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e)
      this.omniUIUtils.showError(t('结束加工失败', '结束加工失败') + ': ' + msg)
    }
  }

  // 构建悬浮窗Tab按钮
  @Builder
  private buildFloatingTabButton(title: string, tabKey: string): void {
    Button(title)
      .fontSize(15) // Apple风格：合理字体
      .fontWeight(this.selectedFloatingTab === tabKey ? FontWeight.Medium : FontWeight.Normal) // Apple风格：Medium而非Bold
      .fontColor(this.selectedFloatingTab === tabKey ? this.getCurrentTheme().primary : this.getCurrentTheme().textColor)
      .backgroundColor(this.selectedFloatingTab === tabKey ? this.getCurrentTheme().primary + '15' : Color.Transparent) // Apple风格：更柔和的背景色
      .borderRadius(AppleDesignStyle.BORDER_RADIUS_SMALL) // Apple风格：小圆角(8px)
      .padding({ left: 20, right: 20, top: 12, bottom: 12 }) // 增加左右padding，确保文字完整显示
      .layoutWeight(1) // 平均分配宽度
      .height('100%') // 填满父容器高度
      .transition(AppleDesignStyle.getTransitionNormal()) // Apple风格：流畅过渡动画
      .onClick(() => {
        this.selectedFloatingTab = tabKey
      })
  }

  // 构建出口Tab内容
  @Builder
  @Builder
  private buildExportTabContent(): void {
    Text(t('出口管理', '出口管理'))
      .fontSize(18)
      .fontWeight(FontWeight.Medium) // Apple风格：Medium而非Bold
      .fontColor(this.getCurrentTheme().textColor)
      .margin({ bottom: AppleDesignStyle.SPACING_LARGE }) // Apple风格：统一间距
      .alignSelf(ItemAlign.Start)
      .padding({ left: AppleDesignStyle.SPACING_MEDIUM, right: AppleDesignStyle.SPACING_MEDIUM }) // Apple风格：统一内边距

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
    .rowsGap(AppleDesignStyle.SPACING_MEDIUM) // Apple风格：统一间距
    .columnsGap(AppleDesignStyle.SPACING_MEDIUM) // Apple风格：统一间距
    .width('100%')
    .padding({ left: AppleDesignStyle.SPACING_MEDIUM, right: AppleDesignStyle.SPACING_MEDIUM, top: 0, bottom: AppleDesignStyle.SPACING_MEDIUM }) // Apple风格：统一内边距
  }

  // 构建设置Tab内容
  @Builder
  private buildSettingsTabContent(): void {
    Text(t('系统设置', '系统设置'))
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
    .rowsGap(AppleDesignStyle.SPACING_MEDIUM) // Apple风格：统一间距
    .columnsGap(AppleDesignStyle.SPACING_MEDIUM) // Apple风格：统一间距
    .width('100%')
    .padding({ left: AppleDesignStyle.SPACING_MEDIUM, right: AppleDesignStyle.SPACING_MEDIUM, top: 0, bottom: AppleDesignStyle.SPACING_MEDIUM }) // Apple风格：统一内边距
  }

  // 构建帮助Tab内容
  @Builder
  private buildHelpTabContent(): void {
    Text(t('帮助支持', '帮助支持'))
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
      GridItem() { this.buildFloatingButton('✏️', '翻译管理') }
      GridItem() { this.buildFloatingButton('🚪', '退出') }
      GridItem() { this.buildFloatingButton('👨', '用户切换') }
    }
    .columnsTemplate('1fr 1fr 1fr 1fr')
    .rowsGap(AppleDesignStyle.SPACING_MEDIUM) // Apple风格：统一间距
    .columnsGap(AppleDesignStyle.SPACING_MEDIUM) // Apple风格：统一间距
    .width('100%')
    .padding({ left: AppleDesignStyle.SPACING_MEDIUM, right: AppleDesignStyle.SPACING_MEDIUM, top: 0, bottom: AppleDesignStyle.SPACING_MEDIUM }) // Apple风格：统一内边距
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
        Text(t('选择主题', '选择主题'))
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

  // 语言选择弹窗
  @Builder
  private buildLanguageSelectorDialog(): void {
    Stack() {
      // 遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.showLanguageSelector = false
        })

      // 内容
      Column() {
        // 标题
        Row() {
          Text('🌐 选择语言')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .layoutWeight(1)

          Button() {
            Text('×')
              .fontSize(32)
              .fontColor(this.getCurrentTheme().textColor)
          }
          .width(40)
          .height(40)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.showLanguageSelector = false
          })
        }
        .width('100%')
        .padding({ left: 28, right: 28, top: 24, bottom: 20 })
        .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })

        // 说明
        Text(t('选择界面显示语言。选择"自定义"后，可通过"翻译管理"编辑翻译内容。', '选择界面显示语言。选择"自定义"后，可通过"翻译管理"编辑翻译内容。'))
          .fontSize(16)
          .fontColor(this.getCurrentTheme().subTextColor)
          .padding({ left: 28, right: 28, top: 16, bottom: 16 })

        // 语言选项
        Scroll() {
          Column() {
            // 中文选项（固定）
            this.buildLanguageOption('🇨🇳', t('中文', '中文'), t('使用原始中文界面', '使用原始中文界面'), '中文')
            
            // 动态显示扫描到的语言文件
            ForEach(this.availableLanguages, (lang: string) => {
              this.buildLanguageOption('📄', lang, t('使用 {0} 翻译', '使用 {0} 翻译').replace('{0}', lang), lang)
            }, (lang: string) => lang)
          }
          .width('100%')
          .padding({ left: 28, right: 28, bottom: 24 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Auto)

        // 底部按钮
        Row() {
          Button(t('取消', '取消'))
            .layoutWeight(1)
            .height(52)
            .fontSize(17)
            .borderRadius(12)
            .border({ width: 1, color: this.getCurrentTheme().borderColor })
            .backgroundColor(this.getCurrentTheme().backgroundColor)
            .fontColor(this.getCurrentTheme().textColor)
            .onClick(() => this.cancelLanguageSelection())

          Button(t('确认', '确认'))
            .layoutWeight(1)
            .height(52)
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 16 })
            .borderRadius(12)
            .backgroundColor(this.getCurrentTheme().primary)
            .fontColor(Color.White)
            .onClick(() => this.confirmLanguageSelection())
        }
        .width('100%')
        .padding({ left: 28, right: 28, top: 16, bottom: 24 })
      }
      .width('80%')
      .constraintSize({ maxWidth: 800, minWidth: 500 })
      .height('85%')
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
    .position({ x: 0, y: 0 })
    .zIndex(4000)
  }

  // 构建语言选项
  @Builder
  private buildLanguageOption(icon: string, lang: string, desc: string, langValue: string): void {
    Row() {
      Text(icon)
        .fontSize(32)
        .margin({ right: 16 })

      Column() {
        Text(lang)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getCurrentTheme().textColor)
        Text(desc)
          .fontSize(15)
          .fontColor(this.getCurrentTheme().subTextColor)
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (this.selectedLanguageTemp === langValue) {
        Text('✓')
          .fontSize(24)
          .fontColor(this.getCurrentTheme().primary)
          .fontWeight(FontWeight.Bold)
      }
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 18, bottom: 18 })
    .backgroundColor(this.selectedLanguageTemp === langValue ? this.getCurrentTheme().primary + '15' : Color.Transparent)
    .borderRadius(12)
    .border({ 
      width: this.selectedLanguageTemp === langValue ? 2 : 1, 
      color: this.selectedLanguageTemp === langValue ? this.getCurrentTheme().primary : this.getCurrentTheme().borderColor 
    })
    .margin({ bottom: 12 })
    .onClick(() => {
      this.selectLanguageTemp(langValue)
    })
  }

  // 翻译编辑弹窗
  @Builder
  private buildTranslationEditorDialog(): void {
    Stack() {
      // 遮罩 - Apple Design风格，更柔和的背景模糊
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.4)')
        .backgroundBlurStyle(BlurStyle.Regular) // 背景模糊效果
        .onClick(() => {
          this.showTranslationEditor = false
        })
        .transition(TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.EaseOut }))

      // 内容卡片 - 调整为与工程设置对话框一致的大小
      Column() {
        // 顶部导航栏区域
        Row() {
          Button(t('取消', '取消'))
            .fontSize(16)
            .fontColor(this.getCurrentTheme().primary)
            .backgroundColor(Color.Transparent)
            .onClick(() => { this.showTranslationEditor = false })
          
          Text(t('翻译管理', '翻译管理'))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          
          Button(t('保存', '保存'))
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().primary)
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.saveTranslations()
            })
        }
        .width('100%')
        .height(50)
        .padding({ left: 16, right: 16 })
        .border({ width: { bottom: 0.5 }, color: this.getCurrentTheme().borderColor }) // 细分割线

        // 统计信息卡片 - 专业展示（左右分布）
        Row() {
          // 总条目数（左侧）
          Column() {
            Text(`${this.getTotalCount()}`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#007AFF')
            Text(t('总条目', '总条目'))
              .fontSize(12)
              .fontColor('#8E8E93')
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          .padding({ top: 12, bottom: 12, left: 20 })
          
          Blank()
          
          // 重翻译数（右侧）
          Column() {
            Text(`${this.getTranslatedCount()}`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#34C759')
            Text(t('重翻译', '重翻译'))
              .fontSize(12)
              .fontColor('#8E8E93')
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.End)
          .padding({ top: 12, bottom: 12, right: 20 })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .backgroundColor('#F2F2F7')
        .borderRadius(12)
        .margin({ left: 16, right: 16, top: 8, bottom: 8 })
        
        // 搜索栏区域
        Column() {
          Row() {
            Text('🔍')
              .fontSize(16)
              .fontColor('#8E8E93') // iOS 系统灰色
              .margin({ right: 6, left: 8 })
            
            TextInput({ placeholder: t('搜索', '搜索'), text: this.translationFilter })
              .layoutWeight(1)
              .height('100%')
              .fontSize(16)
              .backgroundColor(Color.Transparent)
              .placeholderColor('#8E8E93')
              .caretColor(this.getCurrentTheme().primary)
              .fontColor(this.getCurrentTheme().textColor)
              .onChange((v: string) => { this.translationFilter = v })
              
            if (this.translationFilter) {
               Button() {
                  // iOS 风格清除按钮
                  Stack() {
                    Circle({ width: 18, height: 18 }).fill('#8E8E93')
                    Text('×').fontSize(14).fontColor(Color.White).fontWeight(FontWeight.Bold).margin({ bottom: 1 })
                  }.alignContent(Alignment.Center)
               }
               .width(30)
               .height(30)
               .backgroundColor(Color.Transparent)
               .onClick(() => { this.translationFilter = '' })
            }
          }
          .width('100%')
          .height(36) // iOS 搜索框标准高度
          .backgroundColor('#1F767680') // 浅灰色背景
          .borderRadius(10)
        }
        .padding({ left: 16, right: 16, top: 0, bottom: 10 })

        // 表头区域 - Apple Design风格优化版
        Row() {
          // 原始语言列标题
          Text(t('原始语言', '原始语言'))
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor('#8E8E93') // iOS系统灰色
            .layoutWeight(1)
            .padding({ left: 16, right: 12 })
          
          // 中间分隔线
          Divider()
            .vertical(true)
            .strokeWidth(0.5)
            .color('#C6C6C8')
            .height(20)
            .margin({ left: 4, right: 4 })
          
          // 修改的语言列标题
          Text(t('修改的语言', '修改的语言'))
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor('#8E8E93') // iOS系统灰色
            .layoutWeight(1.2)
            .padding({ left: 12, right: 16 })
        }
        .width('100%')
        .height(40) // 稍微增加高度，更舒适
        .backgroundColor('#F2F2F7') // iOS浅灰背景
        .border({ width: { bottom: 0.5 }, color: '#C6C6C8' }) // 底部细分割线
        .padding({ top: 6, bottom: 6 }) // 垂直内边距
        .margin({ bottom: 2 }) // 与列表的间距

        // 列表
        List() {
            ForEach(this.filteredTranslations(), (item: TranslationItem, index: number) => {
              ListItem() {
                Row() {
                  // 原始文本（只读）
                  Text(item.key)
                    .fontSize(16) // 标准正文大小
                    .fontColor(this.getCurrentTheme().textColor)
                    .layoutWeight(1)
                    .padding({ right: 12 })
                    .maxLines(3) // 允许更多行以支持换行
                    .textAlign(TextAlign.Start) // 左对齐，更易读

                  // 中间分隔线
                  Divider()
                    .vertical(true)
                    .strokeWidth(0.5)
                    .color('#E5E5EA') // 更淡的分隔线
                    .height(28)
                    .margin({ left: 4, right: 4 })

                  // 翻译文本（可编辑）
                  TextInput({ text: item.value, placeholder: t('输入翻译', '输入翻译') })
                    .layoutWeight(1.2) // 给输入框更多空间
                    .height(40)
                    .fontSize(16)
                    .textAlign(TextAlign.Start) // 改为左对齐，更符合输入习惯
                    .fontColor(this.getCurrentTheme().textColor) // 使用正常文字颜色
                    .placeholderColor('#C7C7CC')
                    .backgroundColor('#F9F9F9') // 浅灰背景，区分可编辑区域
                    .borderRadius(8) // 圆角输入框
                    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                    .onChange((v: string) => this.updateTranslationValue(item.originalKey, v))
                }
                .width('100%')
                .padding({ top: 14, bottom: 14, right: 16 }) // 增加垂直内边距，更舒适
              }
              .padding({ left: 16 })
            }, (item: TranslationItem) => item.key)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
        .divider({ strokeWidth: 0.5, color: '#C6C6C8', startMargin: 16, endMargin: 0 }) // 列表分割线
      }
      .width('85%') // 与工程设置对话框宽度一致
      .height('90%') // 与工程设置对话框高度一致
      .backgroundColor(this.getCurrentTheme().surfaceColor)
      .borderRadius(16) // Apple Design风格，更大的圆角
      .shadow({
        radius: 30,
        color: 'rgba(0, 0, 0, 0.15)',
        offsetX: 0,
        offsetY: 8
      }) // Apple Design风格，更柔和的阴影
      .transition(TransitionEffect.move(TransitionEdge.BOTTOM).animation({ duration: 350, curve: Curve.EaseOut })) // 更流畅的动画
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
    .position({ x: 0, y: 0 })
    .zIndex(4000)
  }

  // 语言名称输入对话框
  @Builder
  private buildLanguageNameDialog(): void {
    Stack() {
      // 遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.showLanguageNameDialog = false
        })

      // 内容
      Column() {
        // 标题
        Row() {
          Text('💾 保存翻译')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .layoutWeight(1)

          Button() {
            Text('×')
              .fontSize(32)
              .fontColor(this.getCurrentTheme().textColor)
          }
          .width(40)
          .height(40)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.showLanguageNameDialog = false
          })
        }
        .width('100%')
        .padding({ left: 28, right: 28, top: 24, bottom: 20 })
        .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })

        // 说明
        Text(t('请输入语言名称（如：English、日本語、Español）', '请输入语言名称（如：English、日本語、Español）'))
          .fontSize(16)
          .fontColor(this.getCurrentTheme().subTextColor)
          .padding({ left: 28, right: 28, top: 20, bottom: 12 })

        // 输入框
        TextInput({ 
          text: this.languageNameInput, 
          placeholder: t('请输入语言名称（如：English、日本語、Español）', '请输入语言名称（如：English、日本語、Español）') 
        })
          .width('100%')
          .height(56)
          .fontSize(18)
          .margin({ left: 28, right: 28, top: 12, bottom: 28 })
          .padding({ left: 16, right: 16 })
          .backgroundColor(this.getCurrentTheme().backgroundColor)
          .borderRadius(12)
          .onChange((v: string) => {
            this.languageNameInput = v
          })

        // 底部按钮
        Row() {
          Button(t('取消', '取消'))
            .layoutWeight(1)
            .height(52)
            .fontSize(17)
            .borderRadius(12)
            .border({ width: 1, color: this.getCurrentTheme().borderColor })
            .backgroundColor(this.getCurrentTheme().backgroundColor)
            .fontColor(this.getCurrentTheme().textColor)
            .onClick(() => {
              this.showLanguageNameDialog = false
            })

          Button(t('保存', '保存'))
            .layoutWeight(1)
            .height(52)
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 16 })
            .borderRadius(12)
            .backgroundColor(this.getCurrentTheme().primary)
            .fontColor(Color.White)
            .onClick(() => this.confirmSaveLanguage())
        }
        .width('100%')
        .padding({ left: 28, right: 28, bottom: 24 })
      }
      .width('80%')
      .constraintSize({ maxWidth: 800, minWidth: 500 })
      .height('85%')
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
    .position({ x: 0, y: 0 })
    .zIndex(5000)
  }

  // 构建悬浮窗按钮
  // title 参数应该是原始中文键（用于逻辑判断），显示时会自动翻译
  @Builder
  private buildFloatingButton(icon: string, originalKey: string): void {
    Button() {
      Column({ space: AppleDesignStyle.SPACING_XS }) { // Apple风格：统一间距
        Text(icon)
          .fontSize(28) // Apple风格：合理图标大小
          .margin({ bottom: AppleDesignStyle.SPACING_XS })
        
        Text(t(originalKey, originalKey))
          .fontSize(13) // Apple风格：合理字体
          .fontWeight(FontWeight.Medium) // Apple风格：Medium
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
    .height(100) // Apple风格：合理按钮高度
    .backgroundColor(this.getCurrentTheme().surfaceColor)
    .border({ width: AppleDesignStyle.BORDER_WIDTH_THIN, color: this.getCurrentTheme().borderColor }) // Apple风格：细边框
    .borderRadius(AppleDesignStyle.BORDER_RADIUS_SMALL) // Apple风格：小圆角(8px)
    .shadow(AppleDesignStyle.getShadowSmall()) // Apple风格：柔和阴影
    .transition(AppleDesignStyle.getTransitionNormal()) // Apple风格：流畅过渡动画
    .onClick(() => {
      console.log('悬浮窗按钮被点击:', originalKey, '类型:', typeof originalKey)
      if (originalKey === '主题切换') {
        this.selectedTheme = this.consumedThemeType // 初始化选中主题为当前主题
        this.showThemeSelector = true
      } else if (originalKey === '工程设置') {
        this.showEngineeringSettings()
      } else if (originalKey === '电磁阀测试') {
        this.showValveTestDialog = true
      } else if (originalKey === '电机使能') {
        this.showMotorEnableDialog = true
      } else if (originalKey === '复位果杯') {
        this.showResetCupConfirmDialog = true
      } else if (originalKey === '测试果杯') {
        this.showTestCupDialog = true
      } else if (originalKey === '设备信息') {
        this.showDeviceInfoDialog = true
      } else if (originalKey === '配置设置') {
        this.showConfigInfoDialog = true
      } else if (originalKey === '故障信息') {
        this.showAlarmInfoDialog = true
      } else if (originalKey === '电器故障设置') {
        this.showElectricalFaultDialog = true
      } else if (originalKey === '系统故障设置') {
        this.showSystemFaultDialog = true
      } else if (originalKey === '贴标设置') {
        this.showLabelingSettingsDialog = true
      } else if (originalKey === '出口清空') {
        console.log('执行出口清空操作...')
        this.handleExportClear()
      } else if (originalKey === '数据清零') {
        console.log('执行数据清零操作...')
        this.handleClearData()
      } else if (originalKey === '出口屏设置') {
        this.showExitScreenSettingsDialog = true
      } else if (originalKey === '语言') {
        this.openLanguageSelector()
      } else if (originalKey === '翻译管理') {
        this.openTranslationEditor()
      } else {
        console.log('未匹配的按钮:', originalKey)
        this.omniUIUtils.showInfo(t('已点击', '已点击') + t(originalKey, originalKey))
      }
    })
  }



  // 创建导航按钮配置（依赖 i18nVersion 确保语言变化时重新计算）
  private getNavigationButtons(): NavigationButton[] {
    // 引用 i18nVersion 确保语言变化时重新计算
    const _version = this.i18nVersion
    return [
      { text: t('主页', '主页'), pageName: 'home' },
      { text: t('品质', '品质'), pageName: 'quality' },
      { text: t('等级', '等级'), pageName: 'level' },
      { text: t('水果信息', '水果信息'), pageName: 'fruit' },
      { text: t('载入程序', '载入程序'), pageName: 'load' },
      { text: t('保存程序', '保存程序'), pageName: 'save' },
      { text: t('历史加工', '历史加工'), pageName: 'history' },
      { text: t('实时统计', '实时统计'), pageName: 'realtime' },
      { text: t('结束加工', '结束加工'), pageName: 'end' },
      { text: t('打印', '打印'), pageName: 'print' },
      { text: t('更多', '更多'), pageName: 'more' }
    ]
  }

  // ==================== 页面懒加载：为每个页面创建独立的 Builder ====================
  // 这样只有在切换到对应页面时才会创建组件，实现真正的懒加载

  @Builder
  private buildHomePage(): void {
    HomeContent()
  }

  private onLiquidCardDoubleClickIndexChange(): void {
    if (this.liquidCardDoubleClickIndex > 0) {
      this.openOutletDialogForIndex(this.liquidCardDoubleClickIndex)
      AppStorage.set('HOME_LIQUID_CARD_DOUBLE_CLICK_INDEX', 0)
    }
  }

  @Builder
  private buildLevelPage(): void {
    LevelContent({
      onPageChange: (pageName: string) => {
        this.handlePageChange(pageName)
      }
    })
  }

  @Builder
  private buildQualityPage(): void {
    QualityContent({
      onPageChange: (pageName: string) => {
        this.handlePageChange(pageName)
      }
    })
  }

  @Builder
  private buildRealtimePage(): void {
    // 实时统计占位页面（后续可替换为真实组件）
    Column() {
      Text(t('实时统计', '实时统计'))
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.getCurrentTheme().primary)
        .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private buildHistoryPage(): void {
    HistoryContent()
  }

  @Builder
  private buildEndPage(): void {
    EndProcessingContent()
  }

  // 渲染页面内容（懒加载：只创建当前页面的组件）
  @Builder
  private renderPageContent(): void {
    if (this.currentPage === 'home') {
      this.buildHomePage()  // 延迟创建：只有切换到 home 时才创建
    } else if (this.currentPage === 'level') {
      this.buildLevelPage()  // 延迟创建：只有切换到 level 时才创建
    } else if (this.currentPage === 'quality') {
      this.buildQualityPage()  // 延迟创建：只有切换到 quality 时才创建
    } else if (this.currentPage === 'realtime') {
      this.buildRealtimePage()  // 延迟创建：只有切换到 realtime 时才创建
    } else if (this.currentPage === 'history') {
      this.buildHistoryPage()  // 延迟创建：只有切换到 history 时才创建
    } else if (this.currentPage === 'end') {
      this.buildEndPage()  // 延迟创建：只有切换到 end 时才创建
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

  private getOutletCount(): number {
    const key = this.selectedFSM === 'FSM1' ? 'OutletCount_FSM1' : 'OutletCount_FSM2'
    const raw = AppStorage.get(key) as number | undefined
    if (typeof raw === 'number' && raw > 0) {
      return raw
    }
    return this.selectedFSM === 'FSM1' ? 20 : 20
  }

  private openOutletDialogForIndex(index: number): void {
    const count = this.getOutletCount()
    const nextIndex = Math.max(1, Math.min(index, count))
    this.outletDialogIndex = nextIndex
    const dataManager = HomeDataManager.getInstance()
    dataManager.setFSM(this.selectedFSM)
    this.outletDialogLevelTableData = dataManager.getTableData('等级表')
    const cfg = ExitConfigManager.getInstance().getExitConfig(this.selectedFSM, nextIndex)
    this.outletDialogConfig = cfg
    this.showOutletDialog = true
  }

  private navigateOutletDialog(delta: number): void {
    const count = this.getOutletCount()
    let next = this.outletDialogIndex + delta
    if (next < 1) next = count
    if (next > count) next = 1
    this.openOutletDialogForIndex(next)
  }

  private closeOutletDialog(): void {
    this.showOutletDialog = false
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
        Button(t('打印报告', '打印报告'))
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
            this.handlePrintSubButtonClick(t('打印报告', '打印报告'))
          })

        // 子按钮2：打印标签
        Button(t('打印标签', '打印标签'))
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
            this.handlePrintSubButtonClick(t('打印标签', '打印标签'))
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
          Text(this.quickDialogTitle || t('提示', '提示'))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .layoutWeight(1)
          
          // 右上角：上一个/下一个按钮
          Row() {
            Button(t('上一个', '上一个'))
              .fontSize(12)
              .fontColor(this.getCurrentTheme().textColor)
              .backgroundColor(this.getCurrentTheme().backgroundColor)
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
              .borderRadius(6)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .onClick(() => { this.navigateQuickDialog(-1) })

            Button(t('下一个', '下一个'))
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
            Button(t('取消', '取消'))
              .fontSize(14)
              .fontColor(this.getCurrentTheme().textColor)
              .backgroundColor(this.getCurrentTheme().backgroundColor)
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
              .borderRadius(8)
              .padding({ left: 20, right: 20, top: 10, bottom: 10 })
              .onClick(() => { this.quickDialogVisible = false })

            Button(t('确认', '确认'))
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
                  this.omniUIUtils.showSuccess(t('已确认', '已确认'))
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
        Column() {
          TopStatusBar({
            currentPage: this.currentPage,
            selectedFSM: this.selectedFSM,
            layoutMode: 'side',
            onFSMChange: (fsm: 'FSM1' | 'FSM2') => {
              console.log(`🔄 FSM切换开始: ${this.selectedFSM} -> ${fsm}`)

              const currentTheme = this.omniThemeManager.getCurrentThemeType()
              if (this.selectedFSM === 'FSM1') {
                this.fsm1Theme = currentTheme
                console.log(`💾 保存当前FSM1的主题设置:`, currentTheme, `状态变量: fsm1Theme`)
              } else {
                this.fsm2Theme = currentTheme
                console.log(`💾 保存当前FSM2的主题设置:`, currentTheme, `状态变量: fsm2Theme`)
              }
              
              const currentThemeValue = this.selectedFSM === 'FSM1' ? this.fsm1Theme : this.fsm2Theme
              console.log(`✅ 验证保存结果:`, currentThemeValue, `状态变量: ${this.selectedFSM === 'FSM1' ? 'fsm1Theme' : 'fsm2Theme'}`)
              
              AppStorage.set('HOME_SELECTED_FSM', fsm)
              console.log(`🔄 已更新FSM状态为: ${fsm}`)

              const targetTheme = fsm === 'FSM1' ? this.fsm1Theme : this.fsm2Theme
              console.log(`🔍 查找目标${fsm}的主题设置:`, targetTheme, `状态变量: ${fsm === 'FSM1' ? 'fsm1Theme' : 'fsm2Theme'}`)
              
              console.log(`🔍 检查组件状态中的FSM主题:`)
              console.log(`  fsm1Theme:`, this.fsm1Theme, `(类型: ${typeof this.fsm1Theme})`)
              console.log(`  fsm2Theme:`, this.fsm2Theme, `(类型: ${typeof this.fsm2Theme})`)
              
              if (targetTheme) {
                this.omniThemeManager.setTheme(targetTheme)
                console.log(`✅ 恢复${fsm}的主题设置:`, targetTheme)
              } else {
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
        }
        .width(160)
        .height('100%')
        .backgroundColor(this.getCurrentTheme().headerColor ?? this.getCurrentTheme().backgroundColor)

        // 右侧内容
        Stack() {
          Tabs({
            index: this.pageTabIndex,
            barPosition: BarPosition.Start
          }) {
            TabContent() {
              this.buildHomePage()
            }
            .tabBar(t('主页', '主页'))

            TabContent() {
              this.buildQualityPage()
            }
            .tabBar(t('品质', '品质'))

            TabContent() {
              this.buildLevelPage()
            }
            .tabBar(t('等级', '等级'))

            TabContent() {
              this.buildHistoryPage()
            }
            .tabBar(t('历史加工', '历史加工'))
          }
          .onChange((index: number) => {
            this.pageTabIndex = index
            this.currentPage = this.getPageKeyByTabIndex(index)
          })
          .barHeight(0)
          .width('100%')
          .height('100%')

          EndProcessingConfirmDialog({
            isVisible: this.showEndProcessingConfirmDialog,
            title: t('结束加工', '结束加工'),
            message: t('是否结束加工？\n\n是：该批次数据清零并生成报表，该批次数据不可修改\n否：结束加工但保留下位机统计数据（下批次在当前基础上继续计数）\n取消：不结束加工', '是否结束加工？\n\n是：该批次数据清零并生成报表，该批次数据不可修改\n否：结束加工但保留下位机统计数据（下批次在当前基础上继续计数）\n取消：不结束加工'),
            onYes: () => {
              this.showEndProcessingConfirmDialog = false
              console.log('结束加工成功')
              this.handleEndProcessing(true)
            },
            onNo: () => {
              this.showEndProcessingConfirmDialog = false
              console.log('取消结束加工')
            },
            onCancel: () => {
              this.showEndProcessingConfirmDialog = false
              console.log('取消结束加工')
            }
          })
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.getCurrentTheme().pageBg ?? this.getCurrentTheme().surfaceColor)
        .padding({ bottom: this.currentPage === 'home' ? '1%' : 12 })
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
            this.omniUIUtils.showInfo(t('已确认实时统计', '已确认实时统计'))
            this.showRealtimeDialog = false
          },
          onCancel: () => {
            this.omniUIUtils.showInfo(t('已取消查看实时统计', '已取消查看实时统计'))
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

      if (this.showOutletDialog) {
        Stack() {
          OutletDialog({
            isVisible: this.showOutletDialog,
            currentOutletIndex: this.outletDialogIndex,
            levelTableData: this.outletDialogLevelTableData,
            outletConfig: this.outletDialogConfig ?? ExitConfigManager.getInstance().createDefaultConfig(this.outletDialogIndex),
            currentFSM: this.selectedFSM,
            onPrevious: () => {
              this.navigateOutletDialog(-1)
            },
            onNext: () => {
              this.navigateOutletDialog(1)
            },
            onConfirm: async (config: OutletConfig) => {
              ExitConfigManager.getInstance().setExitConfig(this.selectedFSM, config)
              GradeInfoConfigManager.getInstance().applyOutletLeftFields(this.selectedFSM, config.exitIndex, config)
              await ExitConfigManager.getInstance().sendExitConfig(this.selectedFSM)
              this.closeOutletDialog()
            },
            onCancel: () => {
              this.closeOutletDialog()
            }
          })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(2000)
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
              Text(t('修改个人信息', '修改个人信息'))
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
                Text(t('当前设置：', '当前设置：'))
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
                Text(t('选择头像：', '选择头像：'))
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
                Text(t('姓名设置：', '姓名设置：'))
                  .fontSize(20)
                  .fontColor(this.getCurrentTheme().textColor)
                  .margin({ right: 12 })
                
                TextInput({ 
                  text: this.tempUserLabel, 
                  placeholder: t('请输入显示标签', '请输入显示标签') 
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
              Button(t('取消', '取消'))
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

              Button(t('确认', '确认'))
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor(Color.White)
                .backgroundColor(this.getThemePrimaryColor())
                .borderRadius(8)
                .padding({ left: 40, right: 40, top: 16, bottom: 16 })
                .layoutWeight(1)
                .margin({ left: 12 })
                .onClick(async () => {
                  const text = (this.tempUserLabel || '').trim()
                  if (text.length > 0) {
                    AppStorage.setOrCreate('TOP_USER_LABEL', text)
                    // 持久化保存用户名
                    try {
                      const userInfoStorage = UserInfoStorage.getInstance()
                      await userInfoStorage.saveUserName(text)
                      console.log(`[Home] Saved userName to persistent storage: ${text}`)
                    } catch (e) {
                      console.error('[Home] Failed to save userName:', JSON.stringify(e))
                    }
                  }
                  // 保存选中的头像
                  console.log('保存头像:', this.selectedAvatarUrl)
                  AppStorage.setOrCreate('SELECTED_AVATAR_URL', this.selectedAvatarUrl)
                  // 持久化保存头像URL
                  try {
                    const userInfoStorage = UserInfoStorage.getInstance()
                    await userInfoStorage.saveAvatarUrl(this.selectedAvatarUrl || this.avatarOptions[0])
                    console.log(`[Home] Saved avatarUrl to persistent storage: ${this.selectedAvatarUrl}`)
                  } catch (e) {
                    console.error('[Home] Failed to save avatarUrl:', JSON.stringify(e))
                  }
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
      Row() {
        Row() {
          Image($r('app.media.logo'))
            .height('60%')
            .objectFit(ImageFit.Contain)
            .margin({ right: 16 })
        }
        .width(160)
        .height('100%')
        .alignItems(VerticalAlign.Center)

        LeftNavigationTabBar({
          currentPage: this.currentPage,
          showPrintSubButtons: this.showPrintSubButtons,
          layoutDirection: TabBarDirection.HORIZONTAL,
          useChrome: false,
          customTabs: this.getActionTabs(),
          onPageChange: (pageKey: string) => {
            this.handlePageChange(pageKey)
            if (pageKey !== 'fruit' && pageKey !== 'realtime' && pageKey !== 'end' && pageKey !== 'print') {
              this.omniUIUtils.showInfo(`已切换到${this.getPageTitle(pageKey)}页面`)
            }
          },
          onPrintSubButtonClick: (subButtonName: string) => {
            this.handlePrintSubButtonClick(subButtonName)
          }
        })
        .layoutWeight(1)
        .height('100%')

        Column() {
          WindowControlButtons()
        }
        .height('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .height('8%')
      .padding({ left: 16, right: 16 })

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
            Row({ space: AppleDesignStyle.SPACING_XS }) {
              this.buildFloatingTabButton(t('出口', '出口'), 'export')
              this.buildFloatingTabButton(t('设置', '设置'), 'settings')
              this.buildFloatingTabButton(t('帮助', '帮助'), 'help')
            }
            .width('100%')
            .height(50) // 固定高度，确保有足够空间显示文字
            .backgroundColor(this.getCurrentTheme().surfaceColor)
            .borderRadius(AppleDesignStyle.BORDER_RADIUS_SMALL) // Apple风格：小圆角(8px)
            .margin({ bottom: AppleDesignStyle.SPACING_LARGE }) // Apple风格：统一间距
            .padding({ left: AppleDesignStyle.SPACING_XS, right: AppleDesignStyle.SPACING_XS, top: AppleDesignStyle.SPACING_XS, bottom: AppleDesignStyle.SPACING_XS }) // Apple风格：统一内边距
            .opacity(this.i18nVersion >= 0 ? 1 : 1)  // 引用 i18nVersion 确保语言变化时重新渲染

            // Tab内容区域（依赖 i18nVersion 确保语言变化时重新渲染）
            Column() {
              if (this.floatingWindowTitle === t('更多设置', '更多设置')) {
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
            .layoutWeight(1)
            .opacity(this.i18nVersion >= 0 ? 1 : 1)  // 引用 i18nVersion 确保语言变化时重新渲染
            .hitTestBehavior(HitTestMode.Default)  // 确保可以接收点击事件
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
      
      // 电磁阀测试对话框
      if (this.showValveTestDialog) {
        Stack() {
          ValveTestDialog({
            isVisible: this.showValveTestDialog,
            onCancel: () => {
              this.showValveTestDialog = false
            }
          })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(2999) // 电磁阀测试对话框层级
      }
      
      // 电机使能对话框
      if (this.showMotorEnableDialog) {
        Stack() {
          MotorEnableDialog({
            isVisible: this.showMotorEnableDialog,
            onCancel: () => {
              this.showMotorEnableDialog = false
            }
          })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(2998) // 电机使能对话框层级
      }
      
      // 复位果杯确认对话框
      if (this.showResetCupConfirmDialog) {
        Stack() {
          ResetCupConfirmDialog({
            isVisible: this.showResetCupConfirmDialog,
            message: '果杯将复位,请确定分选机上无水果!',
            onConfirm: () => {
              console.log('确认复位果杯')
              // TODO: 实现复位果杯逻辑
              this.showResetCupConfirmDialog = false
            },
            onCancel: () => {
              this.showResetCupConfirmDialog = false
            }
          })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(2997) // 复位果杯确认对话框层级
      }
      
      // 测试果杯对话框
      if (this.showTestCupDialog) {
        Stack() {
          TestCupDialog({
            isVisible: this.showTestCupDialog,
            message: '请确认分选机上无任何水果!',
            onConfirm: () => {
              console.log('开始测试果杯')
              // TODO: 实现测试果杯逻辑
              this.showTestCupDialog = false
            },
            onCancel: () => {
              this.showTestCupDialog = false
            }
          })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(2996) // 测试果杯对话框层级
      }
      
      // 设备信息对话框
      if (this.showDeviceInfoDialog) {
        Stack() {
          DeviceInfoDialog({
            isVisible: this.showDeviceInfoDialog,
            onConfirm: () => {
              console.log('确认设备信息')
              // TODO: 实现保存设备信息逻辑
              this.showDeviceInfoDialog = false
            },
            onCancel: () => {
              this.showDeviceInfoDialog = false
            }
          })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(2995) // 设备信息对话框层级
      }
      
      // 配置信息对话框
      if (this.showConfigInfoDialog) {
        Stack() {
          ConfigInfoDialog({
            isVisible: this.showConfigInfoDialog,
            onConfirm: () => {
              console.log('确认配置信息')
              this.showConfigInfoDialog = false
            },
            onCancel: () => {
              this.showConfigInfoDialog = false
            }
          })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(2994) // 配置信息对话框层级
      }
      
      // 报警信息对话框
      if (this.showAlarmInfoDialog) {
        Stack() {
          AlarmInfoDialog({
            isVisible: this.showAlarmInfoDialog,
            onCancel: () => {
              this.showAlarmInfoDialog = false
            }
          })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(2993) // 报警信息对话框层级
      }
      
      // 电器故障设置对话框
      if (this.showElectricalFaultDialog) {
        Stack() {
          ElectricalFaultDialog({
            isVisible: this.showElectricalFaultDialog,
            onCancel: () => {
              this.showElectricalFaultDialog = false
            },
            onLoad: () => {
              this.omniUIUtils.showInfo(t('正在导入电器故障配置...', '正在导入电器故障配置...'))
              // TODO: 实现导入逻辑
            },
            onSave: () => {
              this.omniUIUtils.showSuccess(t('电器故障配置已保存', '电器故障配置已保存'))
              // TODO: 实现保存逻辑
            }
          })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(2992) // 电器故障设置对话框层级
      }
      
      // 系统故障设置对话框
      if (this.showSystemFaultDialog) {
        Stack() {
          SystemFaultDialog({
            isVisible: this.showSystemFaultDialog,
            onCancel: () => {
              this.showSystemFaultDialog = false
            },
            onLoad: () => {
              this.omniUIUtils.showInfo(t('正在导入系统故障配置...', '正在导入系统故障配置...'))
              // TODO: 实现导入逻辑
            },
            onSave: () => {
              this.omniUIUtils.showSuccess(t('系统故障配置已保存', '系统故障配置已保存'))
              // TODO: 实现保存逻辑
            }
          })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(2991) // 系统故障设置对话框层级
      }
      
      // 贴标设置对话框
      if (this.showLabelingSettingsDialog) {
        Stack() {
          LabelingSettingsDialog({
            isVisible: this.showLabelingSettingsDialog,
            onConfirm: () => {
              console.log('确认贴标设置')
              // TODO: 实现保存贴标设置逻辑
              this.showLabelingSettingsDialog = false
            },
            onCancel: () => {
              this.showLabelingSettingsDialog = false
            }
          })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(2990) // 贴标设置对话框层级
      }
      
      // 出口屏设置对话框
      if (this.showExitScreenSettingsDialog) {
        Stack() {
          ExitScreenSettingsDialog({
            isVisible: this.showExitScreenSettingsDialog,
            onConfirm: () => {
              console.log('确认出口屏设置')
              // TODO: 实现保存出口屏设置逻辑
              this.showExitScreenSettingsDialog = false
            },
            onCancel: () => {
              this.showExitScreenSettingsDialog = false
            }
          })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(2989) // 出口屏设置对话框层级
      }
      
      // 语言选择弹窗
      if (this.showLanguageSelector) {
        this.buildLanguageSelectorDialog()
      }
      
      // 翻译编辑弹窗
      if (this.showTranslationEditor) {
        this.buildTranslationEditorDialog()
      }

      // 语言名称输入对话框
      if (this.showLanguageNameDialog) {
        this.buildLanguageNameDialog()
      }
    }
    .width('100%')
    .height('100%')
    .focusable(true)
    .defaultFocus(true)
    .onKeyEvent((event) => {
      // 在最外层 Home 页面统一监听左 Ctrl，并写入全局多选状态
      if (event.keyCode === KeyCode.KEYCODE_CTRL_LEFT) {
        if (event.type === KeyType.Down) {
          AppStorage.setOrCreate('HOME_CTRL_PRESSED', true);
        } else if (event.type === KeyType.Up) {
          AppStorage.setOrCreate('HOME_CTRL_PRESSED', false);

        }
      }
      return false;
    })
  }
}
