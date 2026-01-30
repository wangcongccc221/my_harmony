import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme as resolveTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { AppleDesignStyle } from '../../utils/theme/AppleDesignStyle'
import { QualityLevelData, CustomComponentConfig, CustomComponentType } from './QualityConstants'
import { t } from '../../utils/i18n/I18nManager'

@Component
export struct QualityDataTable {
  @Prop qualityLevels: QualityLevelData[] = []
  onDataUpdate?: (data: QualityLevelData, index: number) => void
  onDataClick?: (data: QualityLevelData, index: number) => void

  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: OmniThemeType = OmniThemeManager.getInstance().getCurrentThemeType()

  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0

  private lastCount: number = 0
  @State private levelNameInputs: string[] = []

  getCurrentTheme(): ExtendedOmniThemeStyle {
    return resolveTheme(this.consumedTheme)
  }

  @Builder
  private buildTableHeader() {
    Row() {
      Text(t('等级名称', '等级名称'))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getCurrentTheme().textColor)
        .textAlign(TextAlign.Center)
        .width('20%')
        .padding({ left: 4, right: 4, top: 4, bottom: 4 })

      // 分隔线
      Divider()
        .vertical(true)
        .height(60)
        .color(this.getCurrentTheme().borderColor)

      Text(t('颜色等级', '颜色等级'))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getCurrentTheme().textColor)
        .textAlign(TextAlign.Center)
        .layoutWeight(1)
        .padding({ left: 4, right: 4, top: 4, bottom: 4 })

      // 分隔线
      Divider()
        .vertical(true)
        .height(60)
        .color(this.getCurrentTheme().borderColor)

      Text(t('糖度等级', '糖度等级'))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getCurrentTheme().textColor)
        .textAlign(TextAlign.Center)
        .layoutWeight(1)
        .padding({ left: 4, right: 4, top: 4, bottom: 4 })

      Divider()
        .vertical(true)
        .height(60)
        .color(this.getCurrentTheme().borderColor)

      Text(t('酸度等级', '酸度等级'))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getCurrentTheme().textColor)
        .textAlign(TextAlign.Center)
        .layoutWeight(1)
        .padding({ left: 4, right: 4, top: 4, bottom: 4 })

      Divider()
        .vertical(true)
        .height(60)
        .color(this.getCurrentTheme().borderColor)

      Text(t('霉芯等级', '霉芯等级'))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getCurrentTheme().textColor)
        .textAlign(TextAlign.Center)
        .layoutWeight(1)
        .padding({ left: 4, right: 4, top: 4, bottom: 4 })
    }
    .width('100%')
    .height(40) // 设置固定高度
    .padding(0)
    .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })
    .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
  }

  /**
   * 构建自定义组件
   * 
   * 功能说明：
   * - 根据配置动态渲染不同类型的自定义组件
   * - 支持按钮、开关、输入框、下拉选择等
   * - 处理组件事件和数据同步
   * 
   * @param config 自定义组件配置
   * @param data 数据对象
   * @param index 数据索引
   * @returns 自定义组件
   */
  @Builder
  private buildCustomComponent(config: CustomComponentConfig, data: QualityLevelData, index: number) {
    if (config.type === CustomComponentType.BUTTON) {
      // 按钮组件
      Button(config.label)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.getCurrentTheme().textColor)
        .backgroundColor(this.getCurrentTheme().primary)
        .borderRadius(AppleDesignStyle.BORDER_RADIUS_SMALL) // Apple风格：小圆角
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .enabled(config.enabled ?? true)
        .onClick(() => {
          console.log(`按钮点击: ${config.label}, 等级: ${data.levelName}`)
          // 这里可以添加按钮点击的处理逻辑
        })
    } else if (config.type === CustomComponentType.SWITCH) {
      // 开关组件
      Row() {
        Text(config.label)
          .fontSize(16)
          .fontColor(this.getCurrentTheme().textColor)
          .margin({ right: 8 })
        
        Toggle({ type: ToggleType.Switch, isOn: config.value as boolean })
          .onChange((isOn: boolean) => {
            console.log(`开关切换: ${config.label}, 状态: ${isOn}, 等级: ${data.levelName}`)
            // 这里可以添加开关状态变化的处理逻辑
          })
      }
      .alignItems(VerticalAlign.Center)
    } else if (config.type === CustomComponentType.INPUT) {
      // 输入框组件
      TextInput({ placeholder: config.placeholder ?? t('请输入', '请输入') })
        .fontSize(16)
        .fontColor(this.getCurrentTheme().textColor)
        .backgroundColor(this.getCurrentTheme().surfaceColor)
        .border({ width: AppleDesignStyle.BORDER_WIDTH_THIN, color: this.getCurrentTheme().borderColor }) // Apple风格：细边框
        .borderRadius(AppleDesignStyle.BORDER_RADIUS_SMALL) // Apple风格：小圆角
        .padding({ left: 8, right: 8, top: 6, bottom: 6 })
        .onChange((value: string) => {
          console.log(`输入框变化: ${config.label}, 值: ${value}, 等级: ${data.levelName}`)
          // 这里可以添加输入框值变化的处理逻辑
        })
    } else if (config.type === CustomComponentType.SELECT) {
      // 下拉选择组件 - 使用简单的Text显示，点击时弹出选择
      Text(config.value as string)
        .fontSize(16)
        .fontColor(this.getCurrentTheme().textColor)
        .backgroundColor(this.getCurrentTheme().surfaceColor)
        .border({ width: AppleDesignStyle.BORDER_WIDTH_THIN, color: this.getCurrentTheme().borderColor }) // Apple风格：细边框
        .borderRadius(AppleDesignStyle.BORDER_RADIUS_SMALL) // Apple风格：小圆角
        .padding({ left: 8, right: 8, top: 6, bottom: 6 })
        .onClick(() => {
          console.log(`下拉选择: ${config.label}, 当前值: ${config.value}, 等级: ${data.levelName}`)
          // 这里可以添加下拉选择变化的处理逻辑
        })
    } else {
      // 默认文本显示
      Text(String(config.value))
        .fontSize(16)
        .fontColor(this.getCurrentTheme().textColor)
        .textAlign(TextAlign.Center)
    }
  }

  @Builder
  private buildListItem(data: QualityLevelData, index: number) {
    Row() {
      // 等级名称列 - 可编辑
      TextInput({ text: this.levelNameInputs[index] ?? data.levelName })
        .fontSize(24)
        .fontColor(this.getCurrentTheme().textColor)
        .backgroundColor(Color.Transparent)
        .textAlign(TextAlign.Center)
        .width('20%')
        .padding({ left: 4, right: 4, top: 6, bottom: 6 })
        .enterKeyType(EnterKeyType.Done)
        .onChange((value: string) => {
          this.levelNameInputs[index] = value
        })
        .onSubmit((enterKey: EnterKeyType) => {
          const current = this.levelNameInputs[index] ?? ''
          this.levelNameInputs[index] = current
          if (this.onDataUpdate) {
            this.onDataUpdate({
              levelName: current,
              colorLevel: data.colorLevel,
              sugarLevel: data.sugarLevel,
              acidityLevel: data.acidityLevel,
              moldCoreLevel: data.moldCoreLevel
            }, index)
          }
        })
        .onBlur(() => {
          const current = this.levelNameInputs[index] ?? ''
          this.levelNameInputs[index] = current
          if (this.onDataUpdate) {
            this.onDataUpdate({
              levelName: current,
              colorLevel: data.colorLevel,
              sugarLevel: data.sugarLevel,
              acidityLevel: data.acidityLevel,
              moldCoreLevel: data.moldCoreLevel
            }, index)
          }
        })

      // 分隔线
      Divider()
        .vertical(true)
        .height(60)
        .color(this.getCurrentTheme().borderColor)

      // 颜色等级列 - 支持自定义组件
      if (typeof data.colorLevel === 'string') {
        // 传统文本显示
      Text(data.colorLevel)
        .fontSize(24)
        .fontColor(this.getCurrentTheme().textColor)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
          .padding({ left: 4, right: 4, top: 6, bottom: 6 })
      } else {
        // 自定义组件显示
        Column() {
          this.buildCustomComponent(data.colorLevel as CustomComponentConfig, data, index)
        }
        .layoutWeight(1)
        .padding({ left: 4, right: 4, top: 6, bottom: 6 })
      }

      // 分隔线
      Divider()
        .vertical(true)
        .height(60)
        .color(this.getCurrentTheme().borderColor)

      // 糖度等级列
      Text(data.sugarLevel)
        .fontSize(24)
        .fontColor(this.getCurrentTheme().textColor)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .padding({ left: 4, right: 4, top: 6, bottom: 6 })

      Divider()
        .vertical(true)
        .height(60)
        .color(this.getCurrentTheme().borderColor)

      Text(data.acidityLevel)
        .fontSize(24)
        .fontColor(this.getCurrentTheme().textColor)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .padding({ left: 4, right: 4, top: 6, bottom: 6 })

      Divider()
        .vertical(true)
        .height(60)
        .color(this.getCurrentTheme().borderColor)

      Text(data.moldCoreLevel)
        .fontSize(24)
        .fontColor(this.getCurrentTheme().textColor)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .padding({ left: 4, right: 4, top: 6, bottom: 6 })
    }
    .width('100%')
    .height(60)
    .padding(0)
    .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })
    .onClick(() => {
      if (this.onDataClick) {
        this.onDataClick(data, index)
      }
    })
  }

  build() {
    Column() {
      // 固定表头
      this.buildTableHeader()

      // 可滚动数据区域 - 使用List组件
      List() {
        ForEach(this.qualityLevels, (data: QualityLevelData, index: number) => {
          ListItem() {
            this.buildListItem(data, index)
          }
          }, (data: QualityLevelData, index: number) => `${index}`)
        }
        .width('100%')
      .layoutWeight(1) // 使用layoutWeight填满可用空间
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
      .friction(100)
      .divider({
        strokeWidth: 1,
        color: this.getCurrentTheme().borderColor,
        startMargin: 0,
        endMargin: 0
      })
    }
    .width('100%')
    .layoutWeight(1)
  }

  aboutToAppear(): void {
    // 初始化受控输入数组
    this.levelNameInputs = (this.qualityLevels || []).map(item => item.levelName ?? '')
    this.lastCount = this.qualityLevels ? this.qualityLevels.length : 0
    console.log(`📊 品质数据表格初始化 - 数据条数: ${this.lastCount} 条`)
  }

  aboutToRender(): void {
    const current = this.qualityLevels ? this.qualityLevels.length : 0
    if (current !== this.lastCount) {
      // 数据条数变化时更新计数
      this.lastCount = current
      console.log(`📊 品质数据表格 - 数据条数: ${current} 条`)
    }
    // 同步受控输入数组长度与值，避免因为数据刷新导致跳动
    const source = this.qualityLevels || []
    if (!this.levelNameInputs || this.levelNameInputs.length !== source.length) {
      this.levelNameInputs = source.map(item => item.levelName ?? '')
    } else {
      // 对齐内容（当外部数据变化时）
      for (let i = 0; i < source.length; i++) {
        const normalized = source[i].levelName ?? ''
        if (this.levelNameInputs[i] === undefined) {
          this.levelNameInputs[i] = normalized
        }
      }
    }
  }
}
