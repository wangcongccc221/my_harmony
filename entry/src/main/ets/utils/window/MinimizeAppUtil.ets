import { window } from '@kit.ArkUI'
import { BusinessError } from '@kit.BasicServicesKit'
import type common from '@ohos.app.ability.common'

interface ErrorLike {
  message?: string
  code?: number
}

export interface MinimizeConfig {
  maxRetries?: number
  retryDelay?: number
  enableLogging?: boolean
  onSuccess?: () => void
  onError?: (error: Error) => void
}

export class MinimizeAppUtil {
  private static instance: MinimizeAppUtil | null = null
  private readonly context: common.Context
  private config: Required<MinimizeConfig>

  private constructor(context: common.Context, config?: MinimizeConfig) {
    this.context = context
    this.config = {
      maxRetries: config?.maxRetries ?? 3,
      retryDelay: config?.retryDelay ?? 1000,
      enableLogging: config?.enableLogging ?? true,
      onSuccess: config?.onSuccess ?? (() => {}),
      onError: config?.onError ?? (() => {}),
    }
  }

  static getInstance(context: common.Context, config?: MinimizeConfig): MinimizeAppUtil {
    if (!MinimizeAppUtil.instance) {
      MinimizeAppUtil.instance = new MinimizeAppUtil(context, config)
    } else if (config) {
      // 允许运行时调整配置（不重建实例）
      MinimizeAppUtil.instance.updateConfig(config)
    }
    return MinimizeAppUtil.instance
  }

  private updateConfig(config: MinimizeConfig) {
    // 合并配置（避免重新分配回只读对象）
    this.config.maxRetries = config.maxRetries ?? this.config.maxRetries
    this.config.retryDelay = config.retryDelay ?? this.config.retryDelay
    this.config.enableLogging = config.enableLogging ?? this.config.enableLogging
    this.config.onSuccess = config.onSuccess ?? this.config.onSuccess
    this.config.onError = config.onError ?? this.config.onError
  }

  async minimize(): Promise<boolean> {
    for (let attempt = 1; attempt <= this.config.maxRetries; attempt++) {
      try {
        const ok = await this.performMinimize()
        if (ok) {
          this.log(`最小化成功 (第${attempt}次尝试)`) 
          this.config.onSuccess()
          return true
        }
      } catch (e) {
        this.log(`最小化失败 (第${attempt}次尝试): ${this.errMsg(e)}`)
        if (attempt === this.config.maxRetries) {
          const finalErr = new Error(`最小化失败，已重试${this.config.maxRetries}次：${this.errMsg(e)}`)
          this.config.onError(finalErr)
          return false
        }
        await this.delay(this.config.retryDelay)
      }
    }
    return false
  }

  private async performMinimize(): Promise<boolean> {
    try {
      const win: window.Window = await window.getLastWindow(this.context as common.UIAbilityContext)
      // 直接最小化；不强制切换浮窗模式，避免低版本/设备报错
      return await new Promise<boolean>((resolve, reject) => {
        try {
          win.minimize((err?: BusinessError) => {
            if (err && typeof err.code === 'number') {
              const msg = typeof err.message === 'string' ? err.message : ''
              reject(new Error(`窗口最小化失败: ${msg} (code: ${err.code})`))
              return
            }
            resolve(true)
          })
        } catch (inner) {
          reject(new Error(this.errMsg(inner)))
        }
      })
    } catch (error) {
      throw new Error(`获取窗口实例失败: ${this.errMsg(error)}`)
    }
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms))
  }

  private log(message: string): void {
    if (this.config.enableLogging) {
      console.info('[MinimizeAppUtil]', message)
    }
  }

  private errMsg(e: Error | BusinessError | object | string): string {
    if (!e) {
      return 'unknown'
    }
    if (typeof e === 'string') {
      return e
    }
    if (e instanceof Error) {
      return `${e.name}: ${e.message}`
    }
    const maybe = e as ErrorLike
    if (typeof maybe.message === 'string') {
      return maybe.code !== undefined ? `${maybe.message} (code: ${maybe.code})` : maybe.message
    }
    try {
      return JSON.stringify(e)
    } catch (_) {
      return String(e)
    }
  }
}


