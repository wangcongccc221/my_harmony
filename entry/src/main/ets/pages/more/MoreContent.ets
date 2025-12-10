/**
 * 更多页面内容组件
 * 功能：显示系统设置、主题切换、数据管理等功能
 * 用途：在Home页面中作为更多功能页面显示
 */

import { MoreTabBar } from './MoreTabBar'
import { OmniThemeManager, ExtendedOmniThemeStyle, OmniThemeType } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme as resolveTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { useOmniTheme } from '../../utils/theme/useOmniTheme'
import { OmniUIUtils } from '../../utils/helpers/OmniUIUtils'
import { EngineeringSettingsDialog } from '../../components/dialogs/EngineeringSettingsDialog'
import { I18nManager, t, I18N_VERSION_KEY, I18N_LANGUAGE_KEY } from '../../utils/i18n/I18nManager'
import GlobalStore from '../../database/orm/model/GlobalStore'
import { fileIo as fs } from '@kit.CoreFileKit'
import { buffer } from '@kit.ArkTS'

// 设置项接口
interface SettingItem {
  icon: string
  title: string
  subtitle: string
  onClick?: () => void
}

// 翻译项接口
interface TranslationItem {
  key: string  // 显示文本（当前语言的翻译或中文键）
  originalKey: string  // 原始中文键（用于保存）
  value: string  // 用户编辑的翻译文本
}

// 翻译记录类型
type TranslationRecord = Record<string, string>

@Component
export struct MoreContent {
  @StorageLink(OMNI_THEME_KEY) @Watch('onThemeChange') consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_TYPE_KEY) @Watch('onThemeChange') consumedThemeType: OmniThemeType = OmniThemeManager.getInstance().getCurrentThemeType()
  @StorageLink(OMNI_THEME_VERSION_KEY) @Watch('onThemeChange') themeVersion: number = 0
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0  // 监听语言变化，触发 UI 更新
  private omniThemeManager = OmniThemeManager.getInstance()
  private omniUIUtils = OmniUIUtils.getInstance()
  @State showThemeSelector: boolean = false
  @State selectedTheme: OmniThemeType = OmniThemeType.BLUE
  @State showEngineeringSettingsDialog: boolean = false
  @State showLanguageSelector: boolean = false
  @State currentLanguage: string = '中文'
  @State availableLanguages: string[] = []
  @State selectedLanguageTemp: string = '中文'  // 临时选中的语言（用于确认）
  @State showTranslationEditor: boolean = false
  @State translationFilter: string = ''
  @State newTranslationKey: string = ''
  @State newTranslationValue: string = ''
  @State translations: TranslationItem[] = []
  @State showLanguageNameDialog: boolean = false
  @State languageNameInput: string = ''

  // 设置项配置（依赖 i18nVersion 确保语言变化时重新计算）
  private getSettingItems(): SettingItem[] {
    const _version = this.i18nVersion
    return [
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
  }

  getCurrentTheme(): ExtendedOmniThemeStyle {
    return resolveTheme(this.consumedTheme)
  }

  // 监听主题变化
  onThemeChange(): void {
    console.log('MoreContent: 主题已变化，重新渲染')
    // 强制刷新弹窗状态，确保弹窗背景色也能更新
    if (this.showThemeSelector) {
      this.showThemeSelector = false
      // 使用setTimeout确保状态更新后再重新显示弹窗
      setTimeout(() => {
        this.showThemeSelector = true
      }, 10)
    }
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
    this.omniUIUtils.showSuccess(t('工程设置已保存', '工程设置已保存'))
    this.showEngineeringSettingsDialog = false
  }

  private handleEngineeringSettingsCancel(): void {
    this.omniUIUtils.showInfo(t('已取消工程设置', '已取消工程设置'))
    this.showEngineeringSettingsDialog = false
  }
  //

  // 语言编辑入口
  private async openTranslationEditor(): Promise<void> {
    console.log('[MoreContent] openTranslationEditor: start')
    try {
      if (!GlobalStore.context) {
        console.error('[MoreContent] GlobalStore.context is not available')
        this.omniUIUtils.showError(t('翻译初始化失败：上下文未就绪', '翻译初始化失败：上下文未就绪'))
        return
      }
      const mgr = I18nManager.getInstance()
      if (!mgr.isInitialized()) {
        console.log('[MoreContent] I18nManager not initialized, initializing...')
        await mgr.init(GlobalStore.context)
      }

      // 获取当前语言
      const currentLang = mgr.getCurrentLanguage()
      console.log(`[MoreContent] Current language: ${currentLang}`)

      // 从默认模板文件加载所有字段（中文键）
      const appCtx = GlobalStore.context.getApplicationContext?.() ?? GlobalStore.context
      const filesDir = appCtx.filesDir
      const defaultTemplatePath = `${filesDir}/i18n/translations.default.json`
      console.log(`[MoreContent] Loading default template from: ${defaultTemplatePath}`)

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
          console.log(`[MoreContent] Sandbox template size: ${stat.size} bytes`)
        } else {
          console.warn('[MoreContent] Sandbox template empty, fallback to rawfile')
        }
      } catch (e) {
        console.warn(`[MoreContent] Sandbox template missing, fallback to rawfile: ${JSON.stringify(e)}`)
      }

      // 如果沙箱不存在/为空，读取 rawfile 并写回沙箱
      if (!content) {
        try {
          const rawBytes: Uint8Array = appCtx.resourceManager.getRawFileContentSync('file/translations.default.json')
          const rawBuf = buffer.from(rawBytes.buffer)
          content = rawBuf.toString('utf-8')
          console.log('[MoreContent] Loaded template from rawfile')
          // 同步到沙箱，便于后续编辑
          const bufToSave = buffer.from(content, 'utf-8')
          const f = fs.openSync(defaultTemplatePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC)
          fs.writeSync(f.fd, bufToSave.buffer)
          fs.closeSync(f.fd)
          console.log('[MoreContent] Synced rawfile template to sandbox')
        } catch (e) {
          console.error(`[MoreContent] Failed to load template from rawfile: ${JSON.stringify(e)}`)
        }
      }

      // 加载当前语言的翻译（作为原始文本）
      let currentLangTranslations = new Map<string, string>()
      if (currentLang !== '中文') {
        const currentLangPath = `${filesDir}/i18n/${currentLang}.json`
        console.log(`[MoreContent] Loading current language translations from: ${currentLangPath}`)
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
            console.log(`[MoreContent] Loaded ${currentLangTranslations.size} translations from current language`)
          }
        } catch (e) {
          console.warn(`[MoreContent] Failed to load current language translations: ${JSON.stringify(e)}`)
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
          console.log(`[MoreContent] Loaded ${arr.length} template entries`)
        } catch (e) {
          console.error(`[MoreContent] Failed to parse template content: ${JSON.stringify(e)}`)
        }
      } else {
        console.warn('[MoreContent] No template content available, using empty list')
      }

      this.translations = arr
      console.log(`[MoreContent] openTranslationEditor: loaded ${this.translations.length} items`)
      this.showTranslationEditor = true
    } catch (e) {
      console.error('[MoreContent] openTranslationEditor failed', e)
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
    const item: TranslationItem = { key: this.newTranslationKey.trim(), value: this.newTranslationValue ?? '' }
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
    console.log('[MoreContent] saveTranslations: opening language name dialog')
    this.languageNameInput = ''
    this.showLanguageNameDialog = true
  }

  private async confirmSaveLanguage(): Promise<void> {
    const langName = this.languageNameInput.trim()
    if (!langName || langName.length === 0) {
      this.omniUIUtils.showInfo(t('请输入语言名称', '请输入语言名称'))
      return
    }

    if (!/^[a-zA-Z0-9_\u4e00-\u9fa5]+$/.test(langName)) {
      this.omniUIUtils.showError('语言名称只能包含字母、数字、下划线和中文')
      return
    }

    console.log(`[MoreContent] Saving translations as language: ${langName}`)
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
      console.log(`[MoreContent] Prepared ${map.size} translations to save`)
      
      await mgr.saveLanguage(langName, map)
      this.omniUIUtils.showSuccess(t('翻译已保存为：{0}', '翻译已保存为：{0}').replace('{0}', langName))
      this.showTranslationEditor = false
      
      // 刷新可用语言列表
      await this.refreshAvailableLanguages()
    } catch (e) {
      console.error('[MoreContent] saveTranslations failed', e)
      this.omniUIUtils.showError(t('保存失败', '保存失败') + ': ' + JSON.stringify(e))
    }
  }

  private async refreshAvailableLanguages(): Promise<void> {
    console.log('[MoreContent] Refreshing available languages')
    try {
      const mgr = I18nManager.getInstance()
      if (!mgr.isInitialized() && GlobalStore.context) {
        await mgr.init(GlobalStore.context)
      }
      const languages = mgr.listLanguageFiles()
      this.availableLanguages = languages
      console.log(`[MoreContent] Available languages: ${JSON.stringify(languages)}`)
    } catch (e) {
      console.error('[MoreContent] Failed to refresh languages:', e)
      this.availableLanguages = []
    }
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
      Text(t('出口管理', '出口管理'))
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
      Text(t('系统设置', '系统设置'))
        .fontSize(32)  // 字体调大到32px，更有气势！
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getCurrentTheme().textColor)
        .margin({ left: 16, right: 16, bottom: 20 })
        .alignSelf(ItemAlign.Start)

      // 主题切换按钮
      this.buildThemeSwitchButton()

      // 设置项列表
      Column() {
        ForEach(this.getSettingItems(), (item: SettingItem) => {
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
  buildHelpItem(icon: string, title: string, subtitle: string, onClick?: () => void): void {
    Row() {
      // 图标
      Text(icon)
        .fontSize(36)  // 图标字体调大到36px，更有气势！
        .margin({ right: 16 })

      // 文字内容
      Column() {
        Text(t(title, title))
          .fontSize(26)  // 标题字体调大到26px，更有气势！
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getCurrentTheme().textColor)
          .alignSelf(ItemAlign.Start)

        Text(t(subtitle, subtitle))
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
        Text(t(title, title))
          .fontSize(26)  // 标题字体调大到26px，更有气势！
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getCurrentTheme().textColor)
          .alignSelf(ItemAlign.Start)

        Text(t(subtitle, subtitle))
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
        Text(t(title, title))
          .fontSize(26)  // 标题字体调大到26px，更有气势！
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getCurrentTheme().textColor)
          .alignSelf(ItemAlign.Start)

        Text(t(subtitle, subtitle))
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
      Text(t('主题设置', '主题设置'))
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
            Text(t('切换主题', '切换主题'))
              .fontSize(26)  // 字体调大到26px，更有气势！
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
            Text(t('点击选择主题颜色', '点击选择主题颜色'))
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
          Text(t('选择主题', '选择主题'))
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
      Text(t('帮助支持', '帮助支持'))
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
        this.buildHelpItem('🌐', '语言', '切换系统语言', async () => {
          console.log('[MoreContent] Opening language selector')
          // 同步当前语言（从 AppStorage 读取）
          const savedLang = AppStorage.get(I18N_LANGUAGE_KEY) as string
          if (savedLang) {
            this.currentLanguage = savedLang
            console.log(`[MoreContent] Synced language to ${savedLang}`)
          }
          await this.refreshAvailableLanguages()
          this.selectedLanguageTemp = this.currentLanguage  // 初始化临时选中为当前语言
          this.showLanguageSelector = true
        })
        this.buildHelpItem('✏️', '翻译管理', '编辑自定义翻译', () => {
          this.openTranslationEditor()
        })
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

  // 语言选择相关方法
  private selectLanguageTemp(lang: string): void {
    // 临时选中语言（不立即切换）
    this.selectedLanguageTemp = lang
    console.log(`[MoreContent] Temporarily selected language: ${lang}`)
  }

  private async confirmLanguageSelection(): Promise<void> {
    // 确认选择语言
    const lang = this.selectedLanguageTemp
    console.log(`[MoreContent] Confirming language selection: ${lang}`)
    this.currentLanguage = lang
    
    try {
      const mgr = I18nManager.getInstance()
      await mgr.setLanguage(lang)
      this.omniUIUtils.showSuccess(`已切换到：${lang}`)
    } catch (e) {
      console.error(`[MoreContent] Failed to set language ${lang}:`, e)
      this.omniUIUtils.showError(`切换语言失败: ${JSON.stringify(e)}`)
    }
    
    this.showLanguageSelector = false
  }

  private cancelLanguageSelection(): void {
    // 取消选择，恢复原状态
    this.selectedLanguageTemp = this.currentLanguage
    this.showLanguageSelector = false
    console.log('[MoreContent] Language selection cancelled')
  }

  // 语言选择弹窗
  @Builder
  buildLanguageSelectorDialog(): void {
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
        Text(t('选择界面显示语言。选择"自定义"后，可通过"翻译管理"编辑翻译内容。', '选择界面显示语言。选择"自定义"后，可通过"翻译管理"编辑翻译内容。'))
          .fontSize(14)
          .fontColor(this.getCurrentTheme().subTextColor)
          .padding({ left: 20, right: 20, top: 12, bottom: 12 })

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
          .padding({ left: 20, right: 20, bottom: 20 })
        }
        .width('100%')
        .height(300)
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Auto)

        // 底部按钮
        Row() {
          Button(t('取消', '取消'))
            .layoutWeight(1)
            .height(44)
            .borderRadius(10)
            .border({ width: 1, color: this.getCurrentTheme().borderColor })
            .backgroundColor(this.getCurrentTheme().backgroundColor)
            .fontColor(this.getCurrentTheme().textColor)
            .onClick(() => this.cancelLanguageSelection())

          Button(t('确认', '确认'))
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
  }

  // 构建语言选项
  @Builder
  buildLanguageOption(icon: string, lang: string, desc: string, langValue: string): void {
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
  buildTranslationEditorDialog(): void {
    Stack() {
      // 遮罩 - Apple Design风格，更柔和的背景模糊
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.4)') // Apple Design标准遮罩透明度
        .backgroundBlurStyle(BlurStyle.Regular) // 全屏模糊背景
        .onClick(() => {
          this.showTranslationEditor = false
        })
        .transition(TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.EaseOut }))

      // 内容卡片 - 类似 iPad 的 Page Sheet 风格
      Column() {
        // 顶部导航栏区域
        Row() {
          Button(t('取消', '取消'))
            .fontSize(17)
            .fontColor(this.getCurrentTheme().primary)
            .backgroundColor(Color.Transparent)
            .onClick(() => { this.showTranslationEditor = false })
          
          Text(t('翻译管理', '翻译管理'))
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          
          Button(t('保存', '保存'))
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().primary)
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.saveTranslations()
            })
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .border({ width: { bottom: 0.5 }, color: this.getCurrentTheme().borderColor }) // 细分割线

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
              .fontSize(17)
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
        .padding({ left: 16, right: 16, top: 10, bottom: 10 })

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
                    .fontSize(17) // 标准正文大小
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
                    .height(44)
                    .fontSize(17)
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
  buildLanguageNameDialog(): void {
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
        Text(t('请输入语言名称（如：English、日本語、Español）', '请输入语言名称（如：English、日本語、Español）'))
          .fontSize(14)
          .fontColor(this.getCurrentTheme().subTextColor)
          .padding({ left: 20, right: 20, top: 16, bottom: 8 })

        // 输入框
        TextInput({ 
          text: this.languageNameInput, 
          placeholder: t('请输入语言名称（如：English、日本語、Español）', '请输入语言名称（如：English、日本語、Español）') 
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
}