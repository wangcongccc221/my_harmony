/**
 * 水果信息设置页面组件
 * 名称：FruitTypedataGridView
 * 功能：显示水果信息相关的设置内容 (10列表格)
 * 用途：在工程设置对话框的"水果信息设置"Tab中使用
 */

import { ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../../utils/theme/ThemeUtils'
import { t, I18N_VERSION_KEY } from '../../../utils/i18n/I18nManager'

// 水果信息数据接口
interface FruitInfoItem {
  id: number
  typeName: string      // 第0列：水果种类（只读）
  density: string       // 第1列：密度(kg/m³)（可编辑）
  subTypes: boolean[]   // 第2-9列：水果子类（可双击选择/取消），共8个
}

// 列宽配置接口
interface ColumnWeights {
  type: number
  density: number
  subtype: number
}

@Component
export struct FruitInfoPage {
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0
  @State private fruitList: FruitInfoItem[] = [] // 初始化为空，不要模拟数据

  // 表格列宽配置 (Flex权重)
  private readonly COL_WEIGHTS: ColumnWeights = {
    type: 2,    // 水果种类
    density: 2, // 密度
    subtype: 1  // 子类 (x8)
  }

  private resolveTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme()
  }

  // 渲染表头
  @Builder
  HeaderBuilder() {
    Row() {
      // 第0列：水果种类
      Text(t('水果种类', '水果种类'))
        .layoutWeight(this.COL_WEIGHTS.type)
        .textAlign(TextAlign.Center)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.resolveTheme().textColor)
        .height(40)
        .border({ width: { right: 1 }, color: this.resolveTheme().borderColor })

      // 第1列：密度
      Text(t('密度(kg/m³)', '密度(kg/m³)'))
        .layoutWeight(this.COL_WEIGHTS.density)
        .textAlign(TextAlign.Center)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.resolveTheme().textColor)
        .height(40)
        .border({ width: { right: 1 }, color: this.resolveTheme().borderColor })

      // 第2-9列：子类序号
      ForEach([1, 2, 3, 4, 5, 6, 7, 8], (index: number) => {
        Text(`${index}`)
          .layoutWeight(this.COL_WEIGHTS.subtype)
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.resolveTheme().textColor)
          .height(40)
          .border({ width: { right: index === 8 ? 0 : 1 }, color: this.resolveTheme().borderColor })
      })
    }
    .width('100%')
    .height(45)
    .backgroundColor(this.resolveTheme().surfaceColor)
    .border({ width: { bottom: 1 }, color: this.resolveTheme().borderColor })
  }

  build() {
    Column() {
      // 表格容器
      Column() {
        // 1. 表头
        this.HeaderBuilder()

        // 2. 表格内容
        if (this.fruitList.length > 0) {
          // 数据列表
          List() {
            ForEach(this.fruitList, (item: FruitInfoItem, index: number) => {
              ListItem() {
                Row() {
                  // 第0列：水果种类 (只读)
                  Text(item.typeName)
                    .layoutWeight(this.COL_WEIGHTS.type)
                    .textAlign(TextAlign.Center)
                    .fontColor(this.resolveTheme().textColor)
                    .height(40)
                    .border({ width: { right: 1 }, color: this.resolveTheme().borderColor })

                  // 第1列：密度 (可编辑)
                  TextInput({ text: item.density })
                    .layoutWeight(this.COL_WEIGHTS.density)
                    .textAlign(TextAlign.Center)
                    .height(36)
                    .margin(2)
                    .backgroundColor('transparent')
                    .onChange((value: string) => {
                        item.density = value
                    })
                    .border({ width: { right: 1 }, color: this.resolveTheme().borderColor })

                  // 第2-9列：子类 (双击选择/取消)
                  ForEach([0, 1, 2, 3, 4, 5, 6, 7], (subIndex: number) => {
                    Stack() {
                        if (item.subTypes[subIndex]) {
                            // 选中状态：显示勾选或其他标识，这里暂用背景色或图标表示
                             Circle({ width: 10, height: 10 })
                                .fill(this.resolveTheme().primary)
                        }
                    }
                    .layoutWeight(this.COL_WEIGHTS.subtype)
                    .height(40)
                    .border({ width: { right: subIndex === 7 ? 0 : 1 }, color: this.resolveTheme().borderColor })
                    .backgroundColor(item.subTypes[subIndex] ? this.resolveTheme().primary + '33' : 'transparent') // 选中时浅色背景
                    .gesture(
                        TapGesture({ count: 2 })
                            .onAction(() => {
                                // 双击切换状态
                                item.subTypes[subIndex] = !item.subTypes[subIndex]
                                // 强制刷新 (简单方式，实际项目可能需要Observables)
                                this.fruitList = [...this.fruitList]
                            })
                    )
                  })
                }
                .width('100%')
                .border({ width: { bottom: 1 }, color: this.resolveTheme().borderColor })
              }
            })
          }
          .width('100%')
          .layoutWeight(1) // 占满剩余空间
        }
      }
      .width('100%')
      .layoutWeight(1) // 表格占满剩余空间
      .border({ width: 1, color: this.resolveTheme().borderColor })
      .borderRadius(4)
      .backgroundColor(this.resolveTheme().surfaceColor)

      // 立即生效按钮
      Row() {
        Button(t('立即生效', '立即生效'))
          .type(ButtonType.Normal)
          .backgroundColor('#FF4444') // 红色背景
          .fontColor(Color.White)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .width(120)
          .height(40)
          .onClick(() => {
            // TODO: 实现立即生效逻辑
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .alignItems(HorizontalAlign.Start)
  }
}
