/**
 * 导航工具类 - 提供页面切换和导航相关的工具方法
 */
export class NavigationUtils {
  
  /**
   * 创建页面切换处理器
   * @param pageName 页面名称
   * @param onPageChange 页面切换回调函数
   * @param showMessage 显示消息的回调函数
   * @returns 页面切换处理函数
   */
  static createPageSwitchHandler(
    pageName: string, 
    onPageChange: (pageName: string) => void,
    showMessage?: (message: string) => void
  ): () => void {
    return () => {
      onPageChange(pageName)
      if (showMessage) {
        showMessage(`已切换到${pageName}页面`)
      }
    }
  }

  /**
   * 创建简单的页面切换处理器（不显示提示）
   * @param pageName 页面名称
   * @param onPageChange 页面切换回调函数
   * @returns 页面切换处理函数
   */
  static createSimplePageSwitchHandler(
    pageName: string, 
    onPageChange: (pageName: string) => void
  ): () => void {
    return () => {
      onPageChange(pageName)
    }
  }

  /**
   * 创建带确认的页面切换处理器
   * @param pageName 页面名称
   * @param onPageChange 页面切换回调函数
   * @param showConfirm 显示确认对话框的回调函数
   * @param showMessage 显示消息的回调函数
   * @param confirmMessage 确认消息
   * @returns 页面切换处理函数
   */
  static createConfirmPageSwitchHandler(
    pageName: string,
    onPageChange: (pageName: string) => void,
    showConfirm?: (message: string, onConfirm: () => void) => void,
    showMessage?: (message: string) => void,
    confirmMessage?: string
  ): () => void {
    return () => {
      const message = confirmMessage || `确定要切换到${pageName}页面吗？`
      if (showConfirm) {
        showConfirm(message, () => {
          onPageChange(pageName)
          if (showMessage) {
            showMessage(`已切换到${pageName}页面`)
          }
        })
      } else {
        onPageChange(pageName)
      }
    }
  }
}
