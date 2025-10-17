import { OmniThemeManager, ExtendedOmniThemeStyle, OmniThemeType } from './OmniThemeManager'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from './useOmniTheme'

/**
 * 主题混入工具 - 为组件提供主题相关的属性和方法
 */
export class ThemeMixin {
  
  /**
   * 为主题组件添加主题相关的StorageLink属性
   * @param component 组件实例
   */
  static addThemeProperties(component: any): void {
    const omniThemeManager = OmniThemeManager.getInstance()
    
    // 添加主题相关的StorageLink属性
    component.consumedTheme = omniThemeManager.getCurrentTheme()
    component.consumedThemeType = omniThemeManager.getCurrentThemeType()
    component.themeVersion = 0
  }

  /**
   * 为主题组件添加主题相关的方法
   * @param component 组件实例
   */
  static addThemeMethods(component: any): void {
    const omniThemeManager = OmniThemeManager.getInstance()
    
    // 添加getCurrentTheme方法
    component.getCurrentTheme = function(): ExtendedOmniThemeStyle {
      return this.consumedTheme ?? omniThemeManager.getCurrentTheme()
    }

    // 添加getCurrentThemeType方法
    component.getCurrentThemeType = function(): OmniThemeType {
      return this.consumedThemeType ?? omniThemeManager.getCurrentThemeType()
    }
  }

  /**
   * 创建主题装饰器函数
   * @param target 目标组件
   */
  static withTheme<T extends Object>(target: T): T {
    const omniThemeManager = OmniThemeManager.getInstance()
    
    // 添加主题管理器实例
    (target as any).omniThemeManager = omniThemeManager
    
    // 添加主题相关的StorageLink属性
    (target as any).consumedTheme = omniThemeManager.getCurrentTheme()
    (target as any).consumedThemeType = omniThemeManager.getCurrentThemeType()
    (target as any).themeVersion = 0
    
    // 添加主题相关的方法
    (target as any).getCurrentTheme = function(): ExtendedOmniThemeStyle {
      return this.consumedTheme ?? omniThemeManager.getCurrentTheme()
    }
    
    (target as any).getCurrentThemeType = function(): OmniThemeType {
      return this.consumedThemeType ?? omniThemeManager.getCurrentThemeType()
    }
    
    return target
  }
}
