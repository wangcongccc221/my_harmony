/**
 * Omni-UI 初始化工具
 * 功能：初始化 Omni-UI 主题系统和组件
 * 用途：在应用启动时初始化 Omni-UI
 */

import { OmniTheme } from '@wuba58/omni-ui'

export class OmniUIInit {
  private static instance: OmniUIInit
  private isInitialized: boolean = false
  
  // 单例模式
  static getInstance(): OmniUIInit {
    if (!OmniUIInit.instance) {
      OmniUIInit.instance = new OmniUIInit()
    }
    return OmniUIInit.instance
  }
  
  /**
   * 初始化 Omni-UI
   */
  init(): void {
    if (this.isInitialized) {
      console.log('Omni-UI 已经初始化过了')
      return
    }
    
    try {
      // 初始化 Omni-UI 主题系统
      OmniTheme.init()
      this.isInitialized = true
      console.log('Omni-UI 初始化成功')
    } catch (error) {
      console.error('Omni-UI 初始化失败:', error)
    }
  }
  
  /**
   * 检查是否已初始化
   */
  isOmniUIInitialized(): boolean {
    return this.isInitialized
  }
}
