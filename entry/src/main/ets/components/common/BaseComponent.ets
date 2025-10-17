import { OmniThemeManager, ExtendedOmniThemeStyle, OmniThemeType } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'

/**
 * 基础组件工具类 - 提供主题管理和UI工具的统一接口
 * 通过组合模式为组件提供主题功能
 */
export class BaseComponentHelper {
  // 主题管理器实例
  private omniThemeManager = OmniThemeManager.getInstance()
  
  /**
   * 获取当前主题配置
   * 优先使用consumedTheme，如果为空则使用主题管理器
   */
  getCurrentTheme(consumedTheme?: ExtendedOmniThemeStyle): ExtendedOmniThemeStyle {
    return consumedTheme ?? this.omniThemeManager.getCurrentTheme()
  }

  /**
   * 获取当前主题类型
   */
  getCurrentThemeType(consumedThemeType?: OmniThemeType): OmniThemeType {
    return consumedThemeType ?? this.omniThemeManager.getCurrentThemeType()
  }

  /**
   * 获取主题管理器实例
   */
  getOmniThemeManager(): OmniThemeManager {
    return this.omniThemeManager
  }
}

/**
 * 主题混入接口 - 为组件提供主题相关的属性和方法
 */
export interface ThemeMixin {
  // 主题相关的StorageLink属性
  consumedTheme: ExtendedOmniThemeStyle
  consumedThemeType: OmniThemeType
  themeVersion: number
  
  // 主题相关的方法
  getCurrentTheme(): ExtendedOmniThemeStyle
  getCurrentThemeType(): OmniThemeType
}
