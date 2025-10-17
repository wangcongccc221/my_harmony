/**
 * Omni-UI 工具类
 * 功能：提供 Omni-UI 组件的统一调用接口
 * 用途：简化 Omni-UI 组件的使用
 */

import { OmniToast, ToastOptions, OmniLoading } from '@wuba58/omni-ui'

export class OmniUIUtils {
  private static instance: OmniUIUtils
  private omniLoading?: OmniLoading

  // 单例模式
  static getInstance(): OmniUIUtils {
    if (!OmniUIUtils.instance) {
      OmniUIUtils.instance = new OmniUIUtils()
    }
    return OmniUIUtils.instance
  }
  
  /**
   * 显示成功提示
   * @param message 提示消息
   */
  showSuccess(message: string): void {
    const options: ToastOptions = {
      msg: message,
      duration: 2000
    }
    OmniToast.showSuccess(options)
  }
  
  /**
   * 显示错误提示
   * @param message 提示消息
   */
  showError(message: string): void {
    const options: ToastOptions = {
      msg: message,
      duration: 3000
    }
    OmniToast.showError(options)
  }
  
  /**
   * 显示信息提示
   * @param message 提示消息
   */
  showInfo(message: string): void {
    const options: ToastOptions = {
      msg: message,
      duration: 2000
    }
    OmniToast.showText(options)
  }
  
  /**
   * 显示加载状态
   * @param message 加载消息
   */
  showLoading(message: string = '加载中...'): void {
    // 注意：这里需要 UIContext，暂时简化处理
    console.log('显示加载:', message)
  }
  
  /**
   * 隐藏加载状态
   */
  hideLoading(): void {
    // 注意：这里需要 UIContext，暂时简化处理
    console.log('隐藏加载')
  }
  
  /**
   * 显示带加载的异步操作
   * @param asyncOperation 异步操作
   * @param loadingMessage 加载消息
   * @param successMessage 成功消息
   * @param errorMessage 错误消息
   */
  async executeWithLoading<T>(
    asyncOperation: () => Promise<T>,
    loadingMessage: string = '处理中...',
    successMessage?: string,
    errorMessage?: string
  ): Promise<T | null> {
    try {
      this.showLoading(loadingMessage)
      const result = await asyncOperation()
      this.hideLoading()
      
      if (successMessage) {
        this.showSuccess(successMessage)
      }
      
      return result
    } catch (error) {
      this.hideLoading()
      
      if (errorMessage) {
        this.showError(errorMessage)
      } else {
        this.showError('操作失败，请重试')
      }
      
      console.error('异步操作失败:', error)
      return null
    }
  }
}
