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
import { I18nManager, t, I18N_LANGUAGE_KEY, I18N_VERSION_KEY } from '../utils/i18n/I18nManager'
import GlobalStore from '../database/orm/model/GlobalStore'
import { window } from '@kit.ArkUI'
import { fileIo as fs } from '@kit.CoreFileKit'
import { buffer } from '@kit.ArkTS'
import { RectButton } from '../components/ui/buttons/RectButton'
import { TopStatusBar } from '../components/layout/TopStatusBar'
import { BottomControlBar } from '../components/layout/BottomControlBar'
import { KeyCode } from '@kit.InputKit';
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
  aboutToAppear() {
    this.omniUIInit.init()
    this.omniThemeManager.init()
    // 初始化 Ctrl 多选状态
    AppStorage.setOrCreate('HOME_CTRL_PRESSED', false)
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
      if (!mgr.isInitialized() && GlobalStore.context) {
        await mgr.init(GlobalStore.context)
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
      if (!GlobalStore.context) {
        console.error('[Home] GlobalStore.context is not available')
        this.omniUIUtils.showError('翻译初始化失败：上下文未就绪')
        return
      }
      const mgr = I18nManager.getInstance()
      if (!mgr.isInitialized()) {
        console.log('[Home] I18nManager not initialized, initializing...')
        await mgr.init(GlobalStore.context)
      }

      // 获取当前语言
      const currentLang = mgr.getCurrentLanguage()
      console.log(`[Home] Current language: ${currentLang}`)

      // 从默认模板文件加载所有字段（中文键）
      const appCtx = GlobalStore.context.getApplicationContext?.() ?? GlobalStore.context
      const filesDir = appCtx.filesDir
      const defaultTemplatePath = `${filesDir}/i18n/translations.default.json`
      console.log(`[Home] Loading default template from: ${defaultTemplatePath}`)

      let content: string | undefined = undefined

      // 优先读取沙箱文件
      try {
        const stat = fs.statSync(defaultTemplatePath)
        if (stat.size > 0) {
          const file = fs.openSync(defaultTemplatePath, fs.OpenMode.READ_ONLY)
          const dataBuffer = new ArrayBuffer(stat.size)
          fs.readSync(file.fd, dataBuffer)
          fs.closeSync(file.fd)
          const u8 = new Uint8Array(dataBuffer)
          const buf = buffer.from(u8.buffer)
          content = buf.toString('utf-8')
          console.log(`[Home] Sandbox template size: ${stat.size} bytes`)
        } else {
          console.warn('[Home] Sandbox template empty, fallback to rawfile')
        }
      } catch (e) {
        console.warn(`[Home] Sandbox template missing, fallback to rawfile: ${JSON.stringify(e)}`)
      }

      // 如果沙箱不存在/为空，读取 rawfile 并写回沙箱
      if (!content) {
        try {
          const rawBytes: Uint8Array = appCtx.resourceManager.getRawFileContentSync('file/translations.default.json')
          const rawBuf = buffer.from(rawBytes.buffer)
          content = rawBuf.toString('utf-8')
          console.log('[Home] Loaded template from rawfile')
          // 同步到沙箱，便于后续编辑
          const bufToSave = buffer.from(content, 'utf-8')
          const f = fs.openSync(defaultTemplatePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC)
          fs.writeSync(f.fd, bufToSave.buffer)
          fs.closeSync(f.fd)
          console.log('[Home] Synced rawfile template to sandbox')
        } catch (e) {
          console.error(`[Home] Failed to load template from rawfile: ${JSON.stringify(e)}`)
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
            const item: TranslationItem = { key: displayText, originalKey: k, value: val }
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
      this.omniUIUtils.showError(`翻译加载失败: ${JSON.stringify(e)}`)
    }
  }

  private updateTranslationKey(index: number, value: string): void {
    if (index < 0 || index >= this.translations.length) return
    const next: TranslationItem[] = [...this.translations]
    const updated: TranslationItem = { key: value, originalKey: next[index].originalKey, value: next[index].value }
    next[index] = updated
    this.translations = next
  }

  private updateTranslationValue(index: number, value: string): void {
    if (index < 0 || index >= this.translations.length) return
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
      this.omniUIUtils.showInfo('请输入翻译键')
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

  private async saveTranslations(): Promise<void> {
    console.log('[Home] saveTranslations: opening language name dialog')
    this.languageNameInput = ''
    this.showLanguageNameDialog = true
  }

  private async confirmSaveLanguage(): Promise<void> {
    const langName = this.languageNameInput.trim()
    if (!langName || langName.length === 0) {
      this.omniUIUtils.showInfo('请输入语言名称')
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
      this.omniUIUtils.showSuccess(`翻译已保存为：${langName}`)
      this.showTranslationEditor = false
      
      // 刷新可用语言列表
      await this.refreshAvailableLanguages()
    } catch (e) {
      console.error('[Home] saveTranslations failed', e)
      this.omniUIUtils.showError(`保存失败: ${JSON.stringify(e)}`)
    }
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
      GridItem() { this.buildFloatingButton('✏️', '翻译管理') }
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
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .layoutWeight(1)

          Button() {
            Text('×')
              .fontSize(28)
              .fontColor(this.getCurrentTheme().textColor)
          }
          .width(32)
          .height(32)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.showLanguageSelector = false
          })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 12 })
        .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })

        // 说明
        Text('选择界面显示语言。选择"自定义"后，可通过"翻译管理"编辑翻译内容。')
          .fontSize(14)
          .fontColor(this.getCurrentTheme().subTextColor)
          .padding({ left: 20, right: 20, top: 12, bottom: 12 })

        // 语言选项
        Scroll() {
          Column() {
            // 中文选项（固定）
            this.buildLanguageOption('🇨🇳', '中文', '使用原始中文界面', '中文')
            
            // 动态显示扫描到的语言文件
            ForEach(this.availableLanguages, (lang: string) => {
              this.buildLanguageOption('📄', lang, `使用 ${lang} 翻译`, lang)
            }, (lang: string) => lang)
          }
          .width('100%')
          .padding({ left: 20, right: 20, bottom: 20 })
        }
        .width('100%')
        .height(300)
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Auto)

        // 底部按钮
        Row() {
          Button('取消')
            .layoutWeight(1)
            .height(44)
            .borderRadius(10)
            .border({ width: 1, color: this.getCurrentTheme().borderColor })
            .backgroundColor(this.getCurrentTheme().backgroundColor)
            .fontColor(this.getCurrentTheme().textColor)
            .onClick(() => this.cancelLanguageSelection())

          Button('确认')
            .layoutWeight(1)
            .height(44)
            .margin({ left: 12 })
            .borderRadius(10)
            .backgroundColor(this.getCurrentTheme().primary)
            .fontColor(Color.White)
            .onClick(() => this.confirmLanguageSelection())
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 12, bottom: 16 })
      }
      .width('85%')
      .constraintSize({ maxWidth: 400 })
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
        .fontSize(28)
        .margin({ right: 12 })

      Column() {
        Text(lang)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getCurrentTheme().textColor)
        Text(desc)
          .fontSize(13)
          .fontColor(this.getCurrentTheme().subTextColor)
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (this.selectedLanguageTemp === langValue) {
        Text('✓')
          .fontSize(20)
          .fontColor(this.getCurrentTheme().primary)
          .fontWeight(FontWeight.Bold)
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .backgroundColor(this.selectedLanguageTemp === langValue ? this.getCurrentTheme().primary + '15' : Color.Transparent)
    .borderRadius(10)
    .border({ 
      width: this.selectedLanguageTemp === langValue ? 2 : 1, 
      color: this.selectedLanguageTemp === langValue ? this.getCurrentTheme().primary : this.getCurrentTheme().borderColor 
    })
    .margin({ bottom: 10 })
    .onClick(() => {
      this.selectLanguageTemp(langValue)
    })
  }

  // 翻译编辑弹窗
  @Builder
  private buildTranslationEditorDialog(): void {
    Stack() {
      // 遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.showTranslationEditor = false
        })

      // 内容
      Column() {
        Row() {
          Text('✏️ 翻译管理')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .layoutWeight(1)

          Button() {
            Text('×')
              .fontSize(28)
              .fontColor(this.getCurrentTheme().textColor)
          }
          .width(32)
          .height(32)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.showTranslationEditor = false
          })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 12 })
        .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })

        // 使用说明
        Text('在右侧"翻译文本"列填写您的翻译，留空则显示原始中文。')
          .fontSize(14)
          .fontColor(this.getCurrentTheme().subTextColor)
          .padding({ left: 20, right: 20, top: 12, bottom: 8 })

        // 搜索
        Row() {
          Text('🔍')
            .fontSize(20)
            .margin({ right: 8 })
          TextInput({ placeholder: '搜索...', text: this.translationFilter })
            .layoutWeight(1)
            .height(36)
            .onChange((v: string) => { this.translationFilter = v })
        }
        .width('100%')
        .padding({ left: 20, right: 20, bottom: 8 })

        // 列表标题
        Row() {
          Text('原始文本')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .layoutWeight(1)
            .padding({ left: 12 })
          Text('翻译文本')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .layoutWeight(1)
            .padding({ left: 12 })
        }
        .width('100%')
        .padding({ left: 8, right: 8, top: 8, bottom: 8 })
        .backgroundColor(this.getCurrentTheme().primary + '20')

        // 列表
        Scroll() {
          Column() {
            ForEach(this.filteredTranslations(), (item: TranslationItem, index: number) => {
              Row() {
                // 原始文本（只读）
                Text(item.key)
                  .fontSize(15)
                  .fontColor(this.getCurrentTheme().textColor)
                  .layoutWeight(1)
                  .padding({ left: 12, right: 8 })
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                // 翻译文本（可编辑）
                TextInput({ text: item.value, placeholder: '输入翻译...' })
                  .layoutWeight(1)
                  .height(36)
                  .fontSize(14)
                  .backgroundColor(this.getCurrentTheme().backgroundColor)
                  .onChange((v: string) => this.updateTranslationValue(index, v))
              }
              .width('100%')
              .padding({ left: 8, right: 16, top: 8, bottom: 8 })
              .backgroundColor(index % 2 === 0 ? this.getCurrentTheme().surfaceColor : this.getCurrentTheme().backgroundColor)
            }, (item: TranslationItem) => item.key)
          }
          .width('100%')
          .padding({ bottom: 12 })
        }
        .width('100%')
        .height(400)
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Auto)

        // 底部按钮
        Row() {
          Button(t('取消', '取消'))
            .layoutWeight(1)
            .height(46)
            .borderRadius(10)
            .border({ width: 1, color: this.getCurrentTheme().borderColor })
            .backgroundColor(this.getCurrentTheme().backgroundColor)
            .fontColor(this.getCurrentTheme().textColor)
            .onClick(() => { this.showTranslationEditor = false })

          Button(t('保存', '保存'))
            .layoutWeight(1)
            .height(46)
            .margin({ left: 12 })
            .borderRadius(10)
            .backgroundColor(this.getCurrentTheme().primary)
            .fontColor(Color.White)
            .onClick(() => this.saveTranslations())
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 12, bottom: 16 })
      }
      .width('90%')
      .constraintSize({ maxWidth: 600, maxHeight: 800 })
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
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .layoutWeight(1)

          Button() {
            Text('×')
              .fontSize(28)
              .fontColor(this.getCurrentTheme().textColor)
          }
          .width(32)
          .height(32)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.showLanguageNameDialog = false
          })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 12 })
        .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })

        // 说明
        Text('请输入语言名称（如：English、日本語、Español）')
          .fontSize(14)
          .fontColor(this.getCurrentTheme().subTextColor)
          .padding({ left: 20, right: 20, top: 16, bottom: 8 })

        // 输入框
        TextInput({ 
          text: this.languageNameInput, 
          placeholder: '例如：English' 
        })
          .width('100%')
          .height(44)
          .fontSize(16)
          .margin({ left: 20, right: 20, top: 8, bottom: 20 })
          .backgroundColor(this.getCurrentTheme().backgroundColor)
          .onChange((v: string) => {
            this.languageNameInput = v
          })

        // 底部按钮
        Row() {
          Button('取消')
            .layoutWeight(1)
            .height(44)
            .borderRadius(10)
            .border({ width: 1, color: this.getCurrentTheme().borderColor })
            .backgroundColor(this.getCurrentTheme().backgroundColor)
            .fontColor(this.getCurrentTheme().textColor)
            .onClick(() => {
              this.showLanguageNameDialog = false
            })

          Button('保存')
            .layoutWeight(1)
            .height(44)
            .margin({ left: 12 })
            .borderRadius(10)
            .backgroundColor(this.getCurrentTheme().primary)
            .fontColor(Color.White)
            .onClick(() => this.confirmSaveLanguage())
        }
        .width('100%')
        .padding({ left: 20, right: 20, bottom: 16 })
      }
      .width('85%')
      .constraintSize({ maxWidth: 400 })
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
      } else if (title === '语言') {
        this.openLanguageSelector()
      } else if (title === '翻译管理') {
        this.openTranslationEditor()
      } else {
        this.omniUIUtils.showInfo(`已点击${title}`)
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

  @Builder
  private buildLevelPage(): void {
    LevelContent()
  }

  @Builder
  private buildQualityPage(): void {
    QualityContent()
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
          3
        } else if (event.type === KeyType.Up) {
          AppStorage.setOrCreate('HOME_CTRL_PRESSED', false);

        }
      }
      return false;
    })
  }
}
