import { fileIo as fs } from '@kit.CoreFileKit'
import { Context } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { buffer } from '@kit.ArkTS'
import { copyRawFileToSandbox } from '../FileUtils'

const TAG = 'I18nManager'
const DOMAIN = 0x0000
const I18N_LANGUAGE_KEY = 'i18n_current_language'
const I18N_VERSION_KEY = 'i18n_version'

// JSON 值类型（避免使用 any/unknown，简化版本，因为翻译文件只包含字符串值）
type JsonValue = string | number | boolean | null

// 翻译记录类型（使用 Map 避免索引签名）
type TranslationRecord = Map<string, string>

interface ListFileFilterOption {
  suffix?: string[]
  displayName?: string[]
  fileSizeOver?: number
  lastModifiedAfter?: number
}

interface ListFileOption {
  recursion: boolean
  listNum: number
  filter: ListFileFilterOption
}

/**
 * 多语言管理器
 * - 支持多个语言文件（English.json, 日本語.json 等）
 * - 语言文件保存在沙盒 filesDir/i18n/ 目录
 * - 默认模板在 rawfile/file/translations.default.json
 */
export class I18nManager {
  private static instance = new I18nManager()
  private context?: Context
  private i18nDir: string = ''
  private currentLanguage: string = '中文' // 当前选择的语言
  private translations: Map<string, string> = new Map()
  private initialized: boolean = false

  static getInstance(): I18nManager {
    return I18nManager.instance
  }

  /**
   * 初始化：准备目录，必要时拷贝默认模板
   */
  async init(context: Context): Promise<void> {
    if (this.initialized) {
      console.log(`[${TAG}] Already initialized, skip`)
      return
    }
    console.log(`[${TAG}] Initializing...`)
    this.context = context

    const appCtx = context.getApplicationContext?.() ?? context
    const baseDir = appCtx.filesDir
    this.i18nDir = `${baseDir}/i18n`

    this.ensureDirectory(this.i18nDir)
    console.log(`[${TAG}] I18n directory: ${this.i18nDir}`)

    // 若目录为空，尝试从 rawfile 拷贝默认模板
    const files = this.listLanguageFiles()
    if (files.length === 0) {
      console.log(`[${TAG}] No language files found, copying default template...`)
      try {
        await copyRawFileToSandbox(context, 'file/translations.default.json', 'i18n', 'translations.default.json', true, this.i18nDir)
        console.log(`[${TAG}] Default template copied successfully`)
      } catch (e) {
        console.warn(`[${TAG}] Failed to copy default template: ${JSON.stringify(e)}`)
        // 创建空文件作为模板
        await this.writeFile(`${this.i18nDir}/translations.default.json`, '{}')
      }
    } else {
      console.log(`[${TAG}] Found ${files.length} existing language files`)
    }

    // 初始化 AppStorage
    AppStorage.setOrCreate(I18N_LANGUAGE_KEY, this.currentLanguage)
    AppStorage.setOrCreate(I18N_VERSION_KEY, 0)
    console.log(`[${TAG}] AppStorage initialized`)

    this.initialized = true
    console.log(`[${TAG}] Initialization completed`)
  }

  /**
   * 翻译函数：返回用户翻译，否则回退到 fallback 或 key
   */
  t(key: string, fallback?: string): string {
    const value = this.translations.get(key)
    if (value !== undefined && value !== null && value !== '') {
      return value
    }
    return fallback ?? key
  }

  /**
   * 获取当前语言
   */
  getCurrentLanguage(): string {
    return this.currentLanguage
  }

  /**
   * 设置当前语言并加载对应翻译
   */
  async setLanguage(lang: string): Promise<void> {
    console.log(`[${TAG}] Setting language to: ${lang}`)
    this.currentLanguage = lang

    if (lang === '中文') {
      // 清空翻译，使用原始中文
      this.translations.clear()
      console.log(`[${TAG}] Language set to 中文, translations cleared`)
    } else {
      // 加载对应语言文件
      const filePath = `${this.i18nDir}/${lang}.json`
      console.log(`[${TAG}] Loading language file: ${filePath}`)
      await this.loadLanguageFile(filePath)
    }

    // 更新 AppStorage 并触发 UI 更新
    AppStorage.set(I18N_LANGUAGE_KEY, lang)
    const prevVersion = AppStorage.get(I18N_VERSION_KEY) as number
    const newVersion = (typeof prevVersion === 'number' ? prevVersion : 0) + 1
    AppStorage.set(I18N_VERSION_KEY, newVersion)
    console.log(`[${TAG}] Language updated in AppStorage, version: ${newVersion}`)
  }

  /**
   * 加载指定语言文件
   */
  private async loadLanguageFile(filePath: string): Promise<void> {
    try {
      if (!this.fileExists(filePath)) {
        console.warn(`[${TAG}] Language file not found: ${filePath}, using empty translations`)
        this.translations.clear()
        return
      }

      const content = await this.readFile(filePath)
      if (!content || content.trim().length === 0) {
        console.warn(`[${TAG}] Language file is empty: ${filePath}`)
        this.translations.clear()
        return
      }

      const parsedMap = this.parseJsonToMap(content)
      this.translations = parsedMap
      console.log(`[${TAG}] Loaded ${this.translations.size} translations from ${filePath}`)
    } catch (e) {
      console.error(`[${TAG}] Failed to load language file ${filePath}: ${JSON.stringify(e)}`)
      this.translations.clear()
    }
  }

  /**
   * 列出所有可用的语言文件
   */
  listLanguageFiles(): string[] {
    if (!this.i18nDir) {
      console.warn(`[${TAG}] I18n directory not initialized`)
      return []
    }

    try {
      console.log(`[${TAG}] Listing language files in: ${this.i18nDir}`)
      const option: ListFileOption = {
        recursion: false,
        listNum: 0,
        filter: {
          suffix: ['.json']
        }
      }
      const files: string[] = fs.listFileSync(this.i18nDir, option)
      console.log(`[${TAG}] Found ${files.length} JSON files: ${JSON.stringify(files)}`)
      
      // 提取语言名称（去掉 .json 后缀）
      const languages: string[] = files.map((file: string): string => {
        const name: string = file.replace(/\.json$/, '')
        console.log(`[${TAG}] Language file: ${file} -> language: ${name}`)
        return name
      }).filter((name: string) => name !== 'translations.default') // 排除默认模板
      
      console.log(`[${TAG}] Available languages: ${JSON.stringify(languages)}`)
      return languages
    } catch (e) {
      console.error(`[${TAG}] Failed to list language files: ${JSON.stringify(e)}`)
      return []
    }
  }

  /**
   * 保存翻译到指定语言文件
   * 如果某个字段为空，则保留原来的翻译值
   */
  async saveLanguage(lang: string, translations: Map<string, string>): Promise<void> {
    if (!this.i18nDir) {
      throw new Error('I18nManager not initialized')
    }

    const filePath = `${this.i18nDir}/${lang}.json`
    console.log(`[${TAG}] Saving translations to: ${filePath}`)
    console.log(`[${TAG}] Translations count: ${translations.size}`)

    // 读取已存在的翻译文件（如果存在）
    const existingTranslations = new Map<string, string>()
    if (this.fileExists(filePath)) {
      try {
        const content = await this.readFile(filePath)
        if (content && content.trim().length > 0) {
          const parsed = this.parseJsonToMap(content)
          parsed.forEach((v: string, k: string) => existingTranslations.set(k, v))
          console.log(`[${TAG}] Loaded ${existingTranslations.size} existing translations`)
        }
      } catch (e) {
        console.warn(`[${TAG}] Failed to load existing translations: ${JSON.stringify(e)}`)
      }
    }

    // 合并翻译：如果新值为空，保留原值；如果原值也不存在，使用原始中文键作为 fallback
    const resultMap = new Map<string, string>()
    translations.forEach((v: string, k: string) => {
      if (v && v.trim().length > 0) {
        // 用户填写了新值，使用新值
        resultMap.set(k, v.trim())
      } else if (existingTranslations.has(k)) {
        // 用户没有填写，保留原值
        const existingValue = existingTranslations.get(k)
        if (existingValue !== undefined && existingValue.trim().length > 0) {
          resultMap.set(k, existingValue)
          console.log(`[${TAG}] Keeping existing translation for "${k}": "${existingValue}"`)
        } else {
          // 原值也为空，使用原始中文键作为 fallback
          resultMap.set(k, k)
          console.log(`[${TAG}] Using original key as fallback for "${k}"`)
        }
      } else {
        // 既没有新值也没有原值，使用原始中文键作为 fallback
        resultMap.set(k, k)
        console.log(`[${TAG}] Using original key as fallback for "${k}"`)
      }
    })

    // 转换为 JSON 字符串
    const json = this.mapToJson(resultMap)
    await this.atomicWrite(filePath, json)
    console.log(`[${TAG}] Translations saved successfully to ${filePath}`)

    // 如果当前语言是刚保存的语言，重新加载并触发 UI 更新
    if (this.currentLanguage === lang) {
      console.log(`[${TAG}] Reloading current language: ${lang}`)
      await this.loadLanguageFile(filePath)
      // 触发 UI 更新
      const prevVersion = AppStorage.get(I18N_VERSION_KEY) as number
      const newVersion = (typeof prevVersion === 'number' ? prevVersion : 0) + 1
      AppStorage.set(I18N_VERSION_KEY, newVersion)
      console.log(`[${TAG}] UI update triggered after save, version: ${newVersion}`)
    }
  }

  /**
   * 获取全部翻译（浅拷贝）
   */
  getAllTranslations(): Map<string, string> {
    return new Map(this.translations)
  }

  /**
   * 设置单条翻译（仅内存，不落盘）
   */
  setTranslation(key: string, value: string): void {
    this.translations.set(key, value)
  }

  /**
   * 删除单条翻译（仅内存，不落盘）
   */
  deleteTranslation(key: string): void {
    this.translations.delete(key)
  }

  /**
   * 批量替换翻译（覆盖内存，不落盘）
   */
  replaceAll(data: Map<string, string>): void {
    this.translations = new Map(data)
  }

  /**
   * 检查是否已初始化
   */
  isInitialized(): boolean {
    return this.initialized
  }

  /**
   * 从磁盘重新加载当前语言
   */
  async reload(): Promise<void> {
    if (this.currentLanguage === '中文') {
      this.translations.clear()
      return
    }
    const filePath = `${this.i18nDir}/${this.currentLanguage}.json`
    await this.loadLanguageFile(filePath)
  }

  private fileExists(path: string): boolean {
    try {
      fs.statSync(path)
      return true
    } catch (e) {
      return false
    }
  }

  private ensureDirectory(dirPath: string): void {
    const parts = dirPath.split('/')
    let current = ''
    for (const part of parts) {
      if (!part) continue
      current = current ? `${current}/${part}` : part
      try {
        fs.mkdirSync(current)
        console.log(`[${TAG}] Created directory: ${current}`)
      } catch (e) {
        // already exists
      }
    }
  }

  private async readFile(path: string): Promise<string> {
    console.log(`[${TAG}] Reading file: ${path}`)
    const file = fs.openSync(path, fs.OpenMode.READ_ONLY)
    const stat = fs.statSync(path)
    const dataBuffer = new ArrayBuffer(stat.size)
    fs.readSync(file.fd, dataBuffer)
    fs.closeSync(file.fd)
    const u8 = new Uint8Array(dataBuffer)
    const buf = buffer.from(u8.buffer)
    const content = buf.toString('utf-8')
    console.log(`[${TAG}] File read successfully, size: ${stat.size} bytes`)
    return content
  }

  private async writeFile(path: string, content: string): Promise<void> {
    console.log(`[${TAG}] Writing file: ${path}`)
    const buf = buffer.from(content, 'utf-8')
    const file = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC)
    fs.writeSync(file.fd, buf.buffer)
    fs.closeSync(file.fd)
    console.log(`[${TAG}] File written successfully`)
  }

  private async atomicWrite(path: string, content: string): Promise<void> {
    const tmpPath = `${path}.tmp`
    console.log(`[${TAG}] Atomic write: ${path} (temp: ${tmpPath})`)
    try {
      await this.writeFile(tmpPath, content)
      fs.renameSync(tmpPath, path)
      console.log(`[${TAG}] Atomic write completed successfully`)
    } catch (e) {
      console.error(`[${TAG}] Atomic write failed: ${JSON.stringify(e)}`)
      // 清理临时文件
      try {
        if (this.fileExists(tmpPath)) {
          fs.unlinkSync(tmpPath)
        }
      } catch (cleanupError) {
        console.error(`[${TAG}] Failed to cleanup temp file: ${JSON.stringify(cleanupError)}`)
      }
      const errMsg = e instanceof Error ? e.message : JSON.stringify(e)
      throw new Error(errMsg)
    }
  }

  /**
   * 将 JSON 字符串解析为 Map
   */
  private parseJsonToMap(json: string): Map<string, string> {
    const map = new Map<string, string>()
    try {
      JSON.parse(json, (key: string, value: JsonValue): JsonValue => {
        if (key !== '' && value !== undefined && value !== null) {
          const valStr: string = String(value)
          map.set(key, valStr)
        }
        return value
      })
    } catch (e) {
      console.error(`[${TAG}] parseJsonToMap failed: ${JSON.stringify(e)}`)
    }
    return map
  }

  /**
   * 将 Map 转为 JSON 字符串，避免使用受限标准库方法
   */
  private mapToJson(map: Map<string, string>): string {
    const parts: string[] = []
    map.forEach((v: string, k: string) => {
      const keyEscaped = this.escapeJson(k)
      const valEscaped = this.escapeJson(v)
      parts.push(`  "${keyEscaped}": "${valEscaped}"`)
    })
    if (parts.length === 0) {
      return '{}'
    }
    return `{\n${parts.join(',\n')}\n}`
  }

  /**
   * 简单的 JSON 字符串转义
   */
  private escapeJson(str: string): string {
    return str.replace(/\\/g, '\\\\').replace(/"/g, '\\"')
  }
}

/**
 * 导出便捷函数
 */
export function t(key: string, fallback?: string): string {
  return I18nManager.getInstance().t(key, fallback)
}

/**
 * 导出 AppStorage 键名常量（供组件使用 @StorageLink 监听）
 */
export { I18N_LANGUAGE_KEY, I18N_VERSION_KEY }
