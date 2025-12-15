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
import { AppleDesignStyle } from '../../utils/theme/AppleDesignStyle'

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
        // 左侧按钮：分选状态（优化为胶囊样式）
        Row() {
          // 状态指示点
          Circle({ width: 8, height: 8 })
            .fill(this.sortingStatus ? '#67C23A' : '#F56C6C')
            .margin({ right: 8 })
          
          Text(this.getSortingStatusText())
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.sortingStatus ? '#67C23A' : '#F56C6C')
        }
        .height(36)
        .padding({ left: 16, right: 16 })
        .backgroundColor(this.sortingStatus ? 'rgba(103, 194, 58, 0.1)' : 'rgba(245, 108, 108, 0.1)')
        .borderRadius(18)
        .margin({ right: 24 })
        .onClick(() => {
          if (this.onSortingStatusClick) {
            this.onSortingStatusClick()
          }
        })

        // SCM 区域
        Row() {
          Text('SCM')
            .fontSize(12)
            .fontColor('#909399')
            .margin({ right: 8 })
            .fontWeight(FontWeight.Bold)
          
          StandardRoundButton({
              text: '1',
              onClickAction: () => {
                console.log('SCM按钮被点击')
                if (this.onSCMClick) {
                  this.onSCMClick()
                }
              }
          })
        }
        .margin({ right: 24 })

        // 垂直分隔线
        Divider()
          .vertical(true)
          .height(20)
          .color('#E4E7ED')
          .margin({ right: 24 })

        // 果杯区域
        Row() {
          Text(t('果杯', '果杯')) // 移除冒号
            .fontSize(12)
            .fontColor('#909399')
            .margin({ right: 12 })
            .fontWeight(FontWeight.Bold)
            .opacity(this.i18nVersion >= 0 ? 1 : 1)

          // 8个果杯按钮
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
      }
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)

      // 中间空白区域
      Blank()
    }
    .width('100%')
    .height(60) // 固定高度
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .padding({ left: AppleDesignStyle.SPACING_LARGE, right: AppleDesignStyle.SPACING_LARGE })
    .backgroundColor(this.getCurrentTheme().surfaceColor) // 纯色背景
    .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.05)', offsetY: -5 }) // 顶部柔和阴影
    .border({ width: { top: 1 }, color: '#F2F6FC' }) // 极淡的顶部边框
  }


}
