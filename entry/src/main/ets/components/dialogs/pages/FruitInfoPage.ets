/**
 * 水果信息设置页面组件
 * 功能：显示水果信息相关的设置内容
 * 用途：在工程设置对话框的"水果信息设置"Tab中使用
 */

import { ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../../utils/theme/ThemeUtils'
import { t, I18N_VERSION_KEY } from '../../../utils/i18n/I18nManager'

@Component
export struct FruitInfoPage {
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0  // 监听语言变化，触发 UI 更新

  private resolveTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme()
  }

  build() {
    Column() {
      Text(t('水果信息设置', '水果信息设置'))
        .fontSize(24)  // 标题字体调大到24px
        .fontWeight(FontWeight.Bold)
        .fontColor(this.resolveTheme().textColor)
        .margin({ bottom: 20 })
        .opacity(this.i18nVersion >= 0 ? 1 : 1)  // 引用 i18nVersion 确保语言变化时重新渲染

      // 水果信息设置内容
      Column() {
        Text(t('这里显示水果信息相关的设置内容', '这里显示水果信息相关的设置内容'))
          .fontSize(18)  // 描述文字字体调大到18px
          .fontColor(this.resolveTheme().subTextColor)
          .textAlign(TextAlign.Center)
          .margin({ bottom: 16 })
          .opacity(this.i18nVersion >= 0 ? 1 : 1)  // 引用 i18nVersion 确保语言变化时重新渲染

        // 示例设置项
        Row() {
          Text(t('水果类型', '水果类型') + ':')
            .fontSize(18)  // 标签字体调大到18px
            .fontColor(this.resolveTheme().textColor)
            .width(80)
            .opacity(this.i18nVersion >= 0 ? 1 : 1)  // 引用 i18nVersion 确保语言变化时重新渲染
          
          Text(t('苹果', '苹果'))
            .fontSize(18)  // 值字体调大到18px
            .fontColor(this.resolveTheme().primary)
            .opacity(this.i18nVersion >= 0 ? 1 : 1)  // 引用 i18nVersion 确保语言变化时重新渲染
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ top: 8, bottom: 8 })

        Row() {
          Text(t('检测项目', '检测项目') + ':')
            .fontSize(18)  // 标签字体调大到18px
            .fontColor(this.resolveTheme().textColor)
            .width(80)
            .opacity(this.i18nVersion >= 0 ? 1 : 1)  // 引用 i18nVersion 确保语言变化时重新渲染
          
          Text(t('重量、颜色、大小', '重量、颜色、大小'))
            .fontSize(18)  // 值字体调大到18px
            .fontColor(this.resolveTheme().primary)
            .opacity(this.i18nVersion >= 0 ? 1 : 1)  // 引用 i18nVersion 确保语言变化时重新渲染
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ top: 8, bottom: 8 })

        Row() {
          Text(t('质量标准', '质量标准') + ':')
            .fontSize(18)  // 标签字体调大到18px
            .fontColor(this.resolveTheme().textColor)
            .width(80)
            .opacity(this.i18nVersion >= 0 ? 1 : 1)  // 引用 i18nVersion 确保语言变化时重新渲染
          
          Text(t('A级标准', 'A级标准'))
            .fontSize(18)  // 值字体调大到18px
            .fontColor(this.resolveTheme().primary)
            .opacity(this.i18nVersion >= 0 ? 1 : 1)  // 引用 i18nVersion 确保语言变化时重新渲染
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ top: 8, bottom: 8 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(this.resolveTheme().surfaceColor)
      .borderRadius(8)
      .border({ width: 1, color: this.resolveTheme().borderColor })
    }
    .width('100%')
    .padding(20)
    .alignItems(HorizontalAlign.Start)
  }
}
