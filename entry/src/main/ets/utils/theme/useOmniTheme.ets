/**
 * useOmniTheme 工具
 * 目标：
 * - 统一读取当前主题对象与主题类型
 * - 提供 setTheme 方法切换主题
 * - 在模块内集中注册主题变化监听，将最新值同步到 AppStorage，组件无需各自维护 flag / 回调
 */

import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from './OmniThemeManager'

// AppStorage 键名常量（可在需要时用 @Consume 直接订阅）
export const OMNI_THEME_KEY: string = 'omni_theme'
export const OMNI_THEME_TYPE_KEY: string = 'omni_theme_type'
export const OMNI_THEME_VERSION_KEY: string = 'omni_theme_version'

// 单例主题管理器
const omniThemeManager = OmniThemeManager.getInstance()

// 模块级桥接是否已初始化
let themeBridgeInitialized: boolean = false

// 已注册的回调（用于必要时移除）
let registeredThemeCallback: ((theme: OmniThemeType) => void) | undefined

function initThemeBridgeIfNeeded(): void {
  if (themeBridgeInitialized) {
    return
  }

  // 初始化 AppStorage 中的主题与主题类型（若不存在则创建）
  const currentType = omniThemeManager.getCurrentThemeType()
  const currentTheme = omniThemeManager.getCurrentTheme()
  AppStorage.setOrCreate(OMNI_THEME_TYPE_KEY, currentType)
  AppStorage.setOrCreate(OMNI_THEME_KEY, currentTheme)
  AppStorage.setOrCreate(OMNI_THEME_VERSION_KEY, 0)

  // 注册主题变化回调：集中一次性注册
  registeredThemeCallback = (themeType: OmniThemeType) => {
    // 同步主题类型与主题对象到 AppStorage
    AppStorage.set(OMNI_THEME_TYPE_KEY, themeType)
    AppStorage.set(OMNI_THEME_KEY, omniThemeManager.getCurrentTheme())
    const prev = AppStorage.get(OMNI_THEME_VERSION_KEY) as number
    AppStorage.set(OMNI_THEME_VERSION_KEY, (typeof prev === 'number' ? prev : 0) + 1)
  }
  omniThemeManager.addThemeChangeCallback(registeredThemeCallback)

  themeBridgeInitialized = true
}

/**
 * 可选：手动释放（通常无需调用，模块全局注册一次即可）
 */
export function disposeThemeBridge(): void {
  if (!themeBridgeInitialized) {
    return
  }
  if (registeredThemeCallback) {
    omniThemeManager.removeThemeChangeCallback(registeredThemeCallback)
  }
  registeredThemeCallback = undefined
  themeBridgeInitialized = false
}

/**
 * useOmniTheme
 * 返回：
 * - theme: 当前主题对象（从管理器即时读取，或可通过 AppStorage 订阅）
 * - themeType: 当前主题类型
 * - setTheme: 切换主题的方法
 *
 * 说明：
 * - 函数内部会确保集中注册主题变化回调，并把变化同步到 AppStorage。
 * - 组件如需自动随主题变化而刷新，建议结合 `@Consume(OMNI_THEME_KEY)`/`@Consume(OMNI_THEME_TYPE_KEY)` 使用；
 *   简单场景下直接调用本函数读取最新值亦可。
 */
export interface OmniThemeHook {
  theme: ExtendedOmniThemeStyle;
  themeType: OmniThemeType;
  setTheme: (themeType: OmniThemeType) => void;
}

export function useOmniTheme(): OmniThemeHook {
  initThemeBridgeIfNeeded()

  const themeType: OmniThemeType = omniThemeManager.getCurrentThemeType()
  const theme: ExtendedOmniThemeStyle = omniThemeManager.getCurrentTheme()

  const setTheme = (next: OmniThemeType): void => {
    omniThemeManager.setTheme(next)
    // setTheme 后，管理器将触发回调，AppStorage 中的值也会被同步更新
  }

  const hook: OmniThemeHook = { theme: theme, themeType: themeType, setTheme: setTheme }
  return hook
}


