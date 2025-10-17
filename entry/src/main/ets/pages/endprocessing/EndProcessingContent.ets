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

import { BaseComponentHelper } from '../../components/common/BaseComponent'
import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { ProcessingRecordCard } from './ProcessingRecordCard'
import { ActionButtonsCard, ButtonConfig } from './ActionButtonsCard'
import { ProcessingDataManager, ProcessingRecord } from './core/ProcessingDataManager'

@Component
export struct EndProcessingContent {
  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: OmniThemeType = OmniThemeManager.getInstance().getCurrentThemeType()
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0
  private baseComponentHelper = new BaseComponentHelper()
  private dataManager = ProcessingDataManager.getInstance()

  getCurrentTheme(): ExtendedOmniThemeStyle {
    return this.baseComponentHelper.getCurrentTheme(this.consumedTheme)
  }

  /**
   * 获取加工记录数据
   */
  private getProcessingData(): ProcessingRecord[] {
    return this.dataManager.getData()
  }

  /**
   * 获取操作按钮配置
   */
  private getActionButtons(): ButtonConfig[] {
    return [
      {
        text: '是',
        onClick: () => {
          console.log('是按钮被点击')
        }
      },
      {
        text: '否',
        onClick: () => {
          console.log('否按钮被点击')
        }
      },
      {
        text: '取消',
        onClick: () => {
          console.log('取消按钮被点击')
        }
      }
    ]
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
        title: '加工记录',
        data: this.getProcessingData(),
        onRowClick: (record: ProcessingRecord) => {
          this.handleRowClick(record)
        }
      })
      .height('90%')

      // 操作按钮卡片
      ActionButtonsCard({
        buttons: this.getActionButtons()
      })
      .height('10%')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .backgroundColor(this.getCurrentTheme().pageBg ?? this.getCurrentTheme().backgroundColor)
  }
}