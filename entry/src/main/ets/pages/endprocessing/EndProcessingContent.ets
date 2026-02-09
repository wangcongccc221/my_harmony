 /**
 * 结束加工内容组件
 * 功能：显示结束加工相关的内容和功能
 * 用途：在Home页面中作为结束加工内容显示
 * 集成 Omni-UI 主题系统
 * 
 * 组件化架构：
 * - ProcessingRecordCard: 加工记录卡片
 * - ActionButtonsCard: 操作按钮卡片
 * - ProcessingDataManager: 数据管理器
 */

import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme as resolveTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { ProcessingRecordCard } from './ProcessingRecordCard'
import { ProcessingDataManager, ProcessingRecord } from './core/ProcessingDataManager'
import { t, I18N_VERSION_KEY } from '../../utils/i18n/I18nManager'
import { ToastDialog } from '../../components/dialogs/ToastDialog'
import { getConfigSender } from '../../protocol/ConfigSender'
import { getDatabaseSync } from '../../protocol/DatabaseSync'
import { getGlobalDataInterface } from '../../protocol/GlobalDataInterface'
import { EndProcessingConfirmDialog } from './EndProcessingConfirmDialog'

@Component
export struct EndProcessingContent {
  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: OmniThemeType = OmniThemeManager.getInstance().getCurrentThemeType()
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0  // 监听语言变化，触发 UI 更新
  private dataManager = ProcessingDataManager.getInstance()
  @State private processingRecords: ProcessingRecord[] = []
  @State private dataRefreshKey: number = 0
  @State private showToastDialog: boolean = false
  @State private toastType: 'success' | 'error' = 'success'
  @State private toastMessage: string = ''
  @State private showEndConfirmDialog: boolean = false

  getCurrentTheme(): ExtendedOmniThemeStyle {
    return resolveTheme(this.consumedTheme)
  }

  /**
   * 页面加载时从数据库加载数据
   */
  aboutToAppear(): void {
    this.loadDataFromDatabase()
  }

  /**
   * 组件即将消失时的生命周期方法
   * 清理页面资源，避免内存泄漏
   */
  aboutToDisappear(): void {
    // 清理数据，释放内存
    this.processingRecords = []
    this.showEndConfirmDialog = false
    console.log('EndProcessingContent: 页面资源已清理')
  }

  /**
   * 从数据库加载数据
   */
  private async loadDataFromDatabase(): Promise<void> {
    try {
      await this.dataManager.loadDataFromDatabase()
      this.processingRecords = this.dataManager.getData()
      this.dataRefreshKey++
      console.log('✅ 结束加工页面：数据加载完成，共', this.processingRecords.length, '条记录')
    } catch (error) {
      console.error('❌ 结束加工页面：数据加载失败', error)
      this.processingRecords = []
    }
  }

  /**
   * 获取加工记录数据
   */
  private getProcessingData(): ProcessingRecord[] {
    return this.processingRecords
  }

  private showToast(type: 'success' | 'error', message: string): void {
    this.toastType = type
    this.toastMessage = message
    this.showToastDialog = true
    setTimeout(() => {
      this.showToastDialog = false
    }, 1500)
  }

  private async handleEndProcessing(clearDeviceData: boolean): Promise<void> {
    const dbSync = getDatabaseSync()
    const gdi = getGlobalDataInterface()
    const batchId = dbSync.getCurrentBatchId()
    if (batchId === 0) {
      this.showToast('error', t('当前没有进行中的加工批次', '当前没有进行中的加工批次'))
      return
    }

    try {
      await dbSync.saveNow()
      const endOk = await dbSync.endCurrentBatch()
      if (!endOk) {
        this.showToast('error', t('结束加工失败：批次未保存', '结束加工失败：批次未保存'))
        return
      }

      const sender = getConfigSender()
      const deviceOk = clearDeviceData ? await sender.sendClearData() : await sender.sendSaveData()
      if (!deviceOk) {
        this.showToast('error', t('下位机命令发送失败，请检查连接', '下位机命令发送失败，请检查连接'))
      } else {
        this.showToast('success', t('结束加工成功', '结束加工成功'))
      }

      gdi.stopProcessing()
      gdi.clearData()
      await this.loadDataFromDatabase()
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e)
      this.showToast('error', t('结束加工失败', '结束加工失败') + ': ' + msg)
    }
  }

  /**
   * 处理行点击事件
   */
  private handleRowClick(record: ProcessingRecord): void {
    console.log('点击加工记录:', record)
  }

  build() {
    Column() {
      // 加工记录卡片
      ProcessingRecordCard({
        title: t('加工记录', '加工记录'),
        data: this.getProcessingData(),
        onRowClick: (record: ProcessingRecord) => {
          this.handleRowClick(record)
        }
      })
      .height('90%')
      .opacity(this.i18nVersion >= 0 ? 1 : 1)  // 引用 i18nVersion 确保语言变化时重新渲染

      ToastDialog({
        isVisible: this.showToastDialog,
        type: this.toastType,
        message: this.toastMessage
      })

      EndProcessingConfirmDialog({
        isVisible: this.showEndConfirmDialog,
        title: t('结束加工', '结束加工'),
        message: t('是否结束加工？\n\n是：结束加工并清零数据\n否：结束加工但保留数据\n取消：不结束', '是否结束加工？\n\n是：结束加工并清零数据\n否：结束加工但保留数据\n取消：不结束'),
        onYes: () => {
          this.showEndConfirmDialog = false
          this.handleEndProcessing(true)
        },
        onNo: () => {
          this.showEndConfirmDialog = false
          this.handleEndProcessing(false)
        },
        onCancel: () => {
          this.showEndConfirmDialog = false
        }
      })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .backgroundColor(this.getCurrentTheme().pageBg ?? this.getCurrentTheme().backgroundColor)
  }
}
