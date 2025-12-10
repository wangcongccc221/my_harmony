import { fileIo as fs } from '@kit.CoreFileKit'
import { Context } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { buffer } from '@kit.ArkTS'
import { copyRawFileToSandbox } from '../FileUtils'

const TAG = 'I18nManager'
const DOMAIN = 0x0000

type TranslationRecord = Record<string, string>

/**
 * 简单的 JSON 多语言管理器
 * - 启动时加载沙箱中的 translations.json
 * - 未找到时从 rawfile 拷贝默认文件，否则创建空文件
 * - 提供 t() 翻译函数、增删改查与保存
 */
export class I18nManager {
  private static instance = new I18nManager()
  private context?: Context
  private filePath: string = ''
  private translations: Map<string, string> = new Map()
  private initialized: boolean = false

  static getInstance(): I18nManager {
    return I18nManager.instance
  }

  isInitialized(): boolean {
    return this.initialized
  }

  /**
   * 初始化：准备文件路径，必要时拷贝默认 JSON，并加载到内存
   */
  async init(context: Context): Promise<void> {
    if (this.initialized) {
      return
    }
    if (!context) {
      throw new Error('I18nManager.init: context is undefined')
    }
    this.context = context

    const appCtx = context.getApplicationContext?.() ?? context
    const baseDir = appCtx.filesDir
    this.filePath = `${baseDir}/i18n/translations.json`

    this.ensureDirectory(`${baseDir}/i18n`)

    // 若文件不存在，尝试从 rawfile 拷贝一个默认模板；否则创建空文件
    if (!this.fileExists(this.filePath)) {
      try {
        await copyRawFileToSandbox(context, 'file/translations.default.json', 'i18n', 'translations.json', true, `${baseDir}/i18n`)
        hilog.info(DOMAIN, TAG, 'Copied default translations to sandbox')
      } catch (e) {
        hilog.warn(DOMAIN, TAG, `Default translations not found, creating empty file, reason: ${this.stringifyErr(e)}`)
        await this.writeFile(this.filePath, '{}')
      }
    }

    await this.load()
    this.initialized = true
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
   * 获取全部翻译（浅拷贝）
   */
  getAllTranslations(): TranslationRecord {
    const result: TranslationRecord = {}
    this.translations.forEach((value, key) => {
      result[key] = value
    })
    return result
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
  replaceAll(data: TranslationRecord): void {
    this.translations.clear()
    Object.keys(data).forEach((key) => {
      this.translations.set(key, data[key])
    })
  }

  /**
   * 保存当前内存翻译到文件（原子写）
   */
  async save(): Promise<void> {
    if (!this.filePath) {
      throw new Error('I18nManager not initialized')
    }
    const json = JSON.stringify(this.getAllTranslations(), null, 2)
    await this.atomicWrite(this.filePath, json)
  }

  /**
   * 导入 JSON 字符串并保存
   */
  async importFromJson(json: string): Promise<void> {
    const data = JSON.parse(json) as TranslationRecord
    this.replaceAll(data)
    await this.save()
  }

  /**
   * 导出为 JSON 字符串
   */
  exportToJson(): string {
    return JSON.stringify(this.getAllTranslations(), null, 2)
  }

  /**
   * 从磁盘重新加载
   */
  async reload(): Promise<void> {
    await this.load()
  }

  private async load(): Promise<void> {
    if (!this.filePath) {
      throw new Error('I18nManager not initialized')
    }
    try {
      const content = await this.readFile(this.filePath)
      if (!content || content.trim().length === 0) {
        this.translations = new Map()
        return
      }
      const data = JSON.parse(content) as TranslationRecord
      this.replaceAll(data)
    } catch (e) {
      hilog.error(DOMAIN, TAG, `Failed to load translations: ${this.stringifyErr(e)}`)
      this.translations = new Map()
    }
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
      } catch (e) {
        // already exists
      }
    }
  }

  private async readFile(path: string): Promise<string> {
    const file = fs.openSync(path, fs.OpenMode.READ_ONLY)
    const stat = fs.statSync(path)
    const dataBuffer = new ArrayBuffer(stat.size)
    fs.readSync(file.fd, dataBuffer)
    fs.closeSync(file.fd)
    const u8: Uint8Array = new Uint8Array(dataBuffer)
    const buf = buffer.from(u8)
    return buf.toString('utf-8')
  }

  private async writeFile(path: string, content: string): Promise<void> {
    const buf = buffer.from(content, 'utf-8')
    const file = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC)
    fs.writeSync(file.fd, buf.buffer)
    fs.closeSync(file.fd)
  }

  private async atomicWrite(path: string, content: string): Promise<void> {
    const tmpPath = `${path}.tmp`
    await this.writeFile(tmpPath, content)
    try {
      fs.renameSync(tmpPath, path)
    } catch (e) {
      // 如果 rename 失败，回退到直接写
      await this.writeFile(path, content)
    }
  }

  private stringifyErr(err: Error | object | string): string {
    if (typeof err === 'string') {
      return err
    }
    if (err instanceof Error) {
      return err.message
    }
    try {
      return JSON.stringify(err)
    } catch (_e) {
      return '[unserializable error]'
    }
  }
}

/**
 * 便捷函数：直接调用翻译
 */
export function t(key: string, fallback?: string): string {
  return I18nManager.getInstance().t(key, fallback)
}

