/**
 * 底部状态栏组件 (BottomControlBar)
 * 对应HTML中的 "System Status Footer"
 * 包含：系统状态、SCM、果杯、IQS、IPM 指示器
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { t, I18N_VERSION_KEY } from '../../utils/i18n/I18nManager'

@Component
export struct BottomControlBar {
  // 分选状态 (保留原有API兼容性)
  @State private sortingStatus: boolean = true

  // 主题相关
  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: string = OmniThemeManager.getInstance().getCurrentThemeType()
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0

  // 回调函数 (保留原有API兼容性，可绑定到对应区域)
  onOutletClick?: (outletNumber: number) => void = () => {}
  onFruitCupClick?: (cupNumber: number) => void = () => {}
  onSCMClick?: () => void = () => {}
  onSortingStatusClick?: () => void = () => {}

  // 颜色常量
  private readonly BG_COLOR = '#f0f0f0'
  private readonly BORDER_COLOR = '#cccccc'
  private readonly YELLOW_COLOR = '#ffeb3b'
  private readonly RED_COLOR = '#ff5722'
  private readonly GREEN_COLOR = '#4caf50'
  private readonly ORANGE_COLOR = '#ff9800'
  private readonly TEXT_COLOR_DARK = '#333333'
  private readonly TEXT_COLOR_WHITE = '#ffffff'

  // 生成数字序列
  private buildNumberRange(start: number, count: number): number[] {
    const result: number[] = []
    for (let i = 0; i < count; i++) {
      result.push(start + i)
    }
    return result
  }

  // 指示器盒子构建函数
  @Builder
  IndicatorBox(text: string, bgColor: string, onClick?: () => void) {
    Text(text)
      .width(28)  // 增加宽度到28px
      .height(24)  // 增加高度到24px
      .fontSize(12)  // 增大字体到12px
      .fontColor(this.TEXT_COLOR_WHITE)
      .backgroundColor(bgColor)
      .textAlign(TextAlign.Center)
      .onClick(() => {
        if (onClick) onClick()
      })
      .margin({ right: 4 }) // 增加间距到4px
  }

  // 状态标签构建函数
  @Builder
  StatusLabel(text: string, marginLeft: number = 0) {
    Text(text)
      .fontSize(14)  // 增大字体到14px
      .fontWeight(FontWeight.Bold)
      .fontColor(this.TEXT_COLOR_DARK)
      .margin({ right: 6, left: marginLeft })  // 增加右边距到6px
  }

  build() {
    Row() {
      // 1. Status Yellow (基准整定中...) - 宽度与导航栏视觉匹配(180px)
      Row() {
        Text('基准整定中...')
          .fontSize(14)  // 增大字体到14px
          .fontWeight(FontWeight.Bold)
          .fontColor(this.TEXT_COLOR_DARK)
      }
      .width(180)  // 固定宽度180px，与导航栏视觉宽度匹配
      .height('100%')
      .backgroundColor(this.YELLOW_COLOR)
      .padding({ left: 15, right: 15 })
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)  // 内容居中
      .onClick(() => {
        if (this.onSortingStatusClick) this.onSortingStatusClick()
      })

      // 2. SCM Group - 紧挨着状态栏
      Row() {
        this.StatusLabel('SCM:')
        this.IndicatorBox('1', this.RED_COLOR, this.onSCMClick)
      }
      .alignItems(VerticalAlign.Center)
      .margin({ left: 10, right: 15 })  // 减少左边距，增加右边距

      // 3. 右侧指示器区域 - 紧挨着SCM
      Row() {
        // 果杯 Group (1-12)
        Row() {
          this.StatusLabel('果杯:', 5)
          ForEach(this.buildNumberRange(1, 12), (num: number) => {
            this.IndicatorBox(num.toString(), this.GREEN_COLOR, () => {
              if (this.onFruitCupClick) this.onFruitCupClick(num)
            })
          })
        }
        .alignItems(VerticalAlign.Center)
        .margin({ left: 5, right: 10 })  // 减少间距，左边距5px，右边距10px

        // 4. IQS Group (1-12)
        // 1-4 Red, 5-12 Orange
        Row() {
          this.StatusLabel('IQS:')
          // 1-4 Red
          ForEach(this.buildNumberRange(1, 4), (num: number) => {
            this.IndicatorBox(num.toString(), this.RED_COLOR)
          })
          // 5-12 Orange
          ForEach(this.buildNumberRange(5, 8), (num: number) => { // range(5, 8) creates 5,6,7,8,9,10,11,12 ? No, count is 8
            this.IndicatorBox((num + 4).toString(), this.ORANGE_COLOR)
          })
        }
        .alignItems(VerticalAlign.Center)
        .margin({ right: 10 })  // 减少右边距到10px

        // 5. IPM Group (1-12 Red)
        Row() {
          this.StatusLabel('IPM:')
          ForEach(this.buildNumberRange(1, 12), (num: number) => {
            this.IndicatorBox(num.toString(), this.RED_COLOR)
          })
        }
        .alignItems(VerticalAlign.Center)
      }
      .layoutWeight(1)  // 占据剩余空间
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)  // 内容靠左对齐，紧挨着SCM
      .padding({ left: 0, right: 10 })  // 左侧不留白，右侧留白10px
    }
    .width('100%')
    .height(50)  // 增加高度到50px，更易操作
    .backgroundColor(this.BG_COLOR)
    .border({ width: { top: 1 }, color: this.BORDER_COLOR })
    .alignItems(VerticalAlign.Center)
    // .padding({ left: 0 }) // HTML says left: 0, handled by flow
  }
}
