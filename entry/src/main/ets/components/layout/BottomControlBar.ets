/**
 * 底部控制栏组件
 * 包含：正常分选标签、SCM按钮、果杯按钮(1-8)
 * 可在任何页面直接使用
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { StandardRoundButton } from '../ui/buttons/StandardRoundButton'
import { FruitCupButton } from '../ui/buttons/FruitCupButton'
import { t, I18N_VERSION_KEY } from '../../utils/i18n/I18nManager'

@Component
export struct BottomControlBar {
  // 分选状态
  @State private sortingStatus: boolean = true  // true=正常分选, false=异常分选

  // 主题相关
  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: string = OmniThemeManager.getInstance().getCurrentThemeType()
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0  // 监听语言变化，触发 UI 更新

  // 出口按钮点击回调
  onOutletClick?: (outletNumber: number) => void = () => {}
  
  // 果杯按钮点击回调
  onFruitCupClick?: (cupNumber: number) => void = () => {}
  
  // SCM按钮点击回调
  onSCMClick?: () => void = () => {}
  
  // 分选状态按钮点击回调
  onSortingStatusClick?: () => void = () => {}

  // 获取当前主题配置
  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return this.consumedTheme
  }

  // 获取分选状态字符串（依赖 i18nVersion 确保语言变化时重新计算）
  private getSortingStatusText(): string {
    const _version = this.i18nVersion
    return this.sortingStatus ? t('正常分选', '正常分选') : t('异常分选', '异常分选')
  }


  // 生成数字序列
  private buildNumberRange(start: number, count: number): number[] {
    const result: number[] = []
    for (let i = 0; i < count; i++) {
      result.push(start + i)
    }
    return result
  }

  build() {
    Row() {
      // 左侧控制区域
      Row() {
        // 左侧按钮：分选状态（可点击）
        Button(this.getSortingStatusText())
          .fontSize(18)  // 调大到18px
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getCurrentTheme().textColor)  // 使用主题文字颜色
          .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
          .border({ width: 1, color: this.getCurrentTheme().borderColor })
          .borderRadius(4)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })  // 增加内边距
          .margin({ right: 16 })
          .onClick(() => {
            if (this.onSortingStatusClick) {
              this.onSortingStatusClick()
            }
          })

        // SCM标签
        Text('SCM:')
          .fontSize(18)  // 调大到18px
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getCurrentTheme().buttonBarTextColor ?? this.getCurrentTheme().textColor)  // 使用底部状态栏文字颜色
          .margin({ right: 8 })
          .alignSelf(ItemAlign.Center)

        // SCM按钮
        StandardRoundButton({
            text: '1',
            onClickAction: () => {
              console.log('SCM按钮被点击')
              // TODO: 后期添加SCM相关逻辑
              if (this.onSCMClick) {
                this.onSCMClick()
              }
            }
        })
          .margin({ right: 16 })

        // 果杯标签
        Text(t('果杯:', '果杯:'))
          .fontSize(18)  // 调大到18px
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getCurrentTheme().buttonBarTextColor ?? this.getCurrentTheme().textColor)  // 使用底部状态栏文字颜色
          .margin({ right: 8 })
          .alignSelf(ItemAlign.Center)
          .opacity(this.i18nVersion >= 0 ? 1 : 1)  // 引用 i18nVersion 确保语言变化时重新渲染

        // 8个果杯按钮（使用循环生成）
        ForEach(this.buildNumberRange(1, 8), (index: number) => {
          FruitCupButton({
            cupNumber: index,
            onCupClick: (cupNumber: number) => {
              if (this.onFruitCupClick) {
                this.onFruitCupClick(cupNumber)
              }
            }
          })
        })
      }
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)

      // 中间空白区域，用于分隔左右两部分
      Blank()
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .padding({ left: 150, right: 20, top: 8, bottom: 8 })
    .backgroundColor(this.getCurrentTheme().buttonBarBg ?? this.getCurrentTheme().surfaceColor)
    .border({ width: { top: 1 }, color: this.getCurrentTheme().borderColor })
  }


}
