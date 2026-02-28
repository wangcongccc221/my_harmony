/**
 * 配置信息对话框组件
 * 功能：显示和查询系统配置信息
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { t, I18N_VERSION_KEY } from '../../utils/i18n/I18nManager'
import { SystemSettingsDataService, SystemConfigEntry } from '../../db/services/SystemSettingsDataService'

// 配置项接口
interface ConfigItem {
  name: string
  value: string
}

@Component
export struct ConfigInfoDialog {
  @Prop isVisible: boolean = false
  @StorageLink(OMNI_THEME_KEY) @Watch('onThemeChange') consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_VERSION_KEY) @Watch('onThemeChange') themeVersion: number = 0
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0

  // 配置数据
  @State configList: ConfigItem[] = []

  // 查询输入
  @State queryName: string = ''
  // 过滤后的配置列表
  @State filteredConfigList: ConfigItem[] = []
  // 编辑中的值（用于保持焦点）
  @State editingValues: Record<string, string> = {}

  // 对话框回调
  onConfirm?: () => void
  onCancel?: () => void

  aboutToAppear() {
    void this.loadConfigEntries()
  }

  private async loadConfigEntries(): Promise<void> {
    const dbEntries = await SystemSettingsDataService.getInstance().getConfigEntries()
    const nextList: ConfigItem[] = []
    for (let i = 0; i < dbEntries.length; i++) {
      const item: ConfigItem = { name: dbEntries[i].name, value: dbEntries[i].value }
      nextList.push(item)
    }
    this.configList = nextList
    this.filteredConfigList = [...this.configList]
    const nextEditingValues: Record<string, string> = {}
    this.configList.forEach((item: ConfigItem) => {
      nextEditingValues[item.name] = item.value
    })
    this.editingValues = nextEditingValues
  }

  // 获取当前主题配置
  getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.consumedTheme)
  }

  // 监听主题变化
  onThemeChange(): void {
    console.log('ConfigInfoDialog: 主题已变化，重新渲染')
  }

  // 查询配置
  private handleQuery(): void {
    if (!this.queryName || this.queryName.trim() === '') {
      // 如果查询名为空，显示所有配置
      this.filteredConfigList = [...this.configList]
    } else {
      // 根据配置名称过滤
      const query = this.queryName.trim().toLowerCase()
      this.filteredConfigList = this.configList.filter(item => 
        item.name.toLowerCase().includes(query)
      )
    }
    // 确保过滤后的列表的编辑值已初始化
    this.filteredConfigList.forEach(item => {
      if (this.editingValues[item.name] === undefined) {
        this.editingValues[item.name] = item.value
      }
    })
  }

  // 确认按钮点击
  private handleConfirm(): void {
    void this.saveConfigEntries()
  }

  private async saveConfigEntries(): Promise<void> {
    const savedEntries: SystemConfigEntry[] = []
    for (let i = 0; i < this.configList.length; i++) {
      const item = this.configList[i]
      const edited = this.editingValues[item.name]
      const value = edited !== undefined ? edited : item.value
      savedEntries.push(new SystemConfigEntry(item.name, value))
    }
    await SystemSettingsDataService.getInstance().saveConfigEntries(savedEntries)
    console.log(`[CONFIG_SETTINGS_SAVE] count=${savedEntries.length}`)
    if (this.onConfirm) {
      this.onConfirm()
    }
  }

  // 取消/关闭按钮点击
  private handleCancel(): void {
    if (this.onCancel) {
      this.onCancel()
    }
  }

  build() {
    // 对话框遮罩层
    Stack() {
      if (!this.isVisible) {
        // 不可见时返回空内容
        Blank()
      } else {
        // 背景遮罩
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .onClick(() => {
            this.handleCancel()
          })

        // 对话框内容
        Column() {
          // 标题栏
          Row() {
            Text('配置信息')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getCurrentTheme().textColor)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)

            Button() {
              Text('×')
                .fontSize(24)
                .fontColor(this.getCurrentTheme().textColor)
            }
            .type(ButtonType.Normal)
            .backgroundColor('transparent')
            .width(32)
            .height(32)
            .onClick(() => {
              this.handleCancel()
            })
          }
          .width('100%')
          .height(50)
          .padding({ left: 16, right: 16 })
          .backgroundColor(this.getCurrentTheme().surfaceColor)
          .borderRadius({ topLeft: 8, topRight: 8 })

          // 内容区域
          Column() {
            // 配置列表（可滚动）
            Scroll() {
              Column() {
                // 表头
                Row() {
                  Text('配置名称')
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.getCurrentTheme().textColor)
                    .width('50%')
                    .textAlign(TextAlign.Center)
                    .padding({ top: 8, bottom: 8, left: 8, right: 8 })
                    .border({ width: 0.5, color: this.getCurrentTheme().borderColor })
                    .backgroundColor('#F5F5F5')

                  Text('配置内容')
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.getCurrentTheme().textColor)
                    .width('50%')
                    .textAlign(TextAlign.Center)
                    .padding({ top: 8, bottom: 8, left: 8, right: 8 })
                    .border({ width: 0.5, color: this.getCurrentTheme().borderColor })
                    .backgroundColor('#F5F5F5')
                }
                .width('100%')

                // 配置项列表
                ForEach(this.filteredConfigList, (item: ConfigItem, index: number) => {
                  Row() {
                    // 配置名称列
                    Column() {
                      Text(item.name)
                        .fontSize(13)
                        .fontColor(this.getCurrentTheme().textColor)
                        .textAlign(TextAlign.Center)
                        .width('100%')
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                    }
                    .width('50%')
                    .height(40)
                    .justifyContent(FlexAlign.Center)
                    .padding({ left: 8, right: 8 })
                    .border({ width: 0.5, color: this.getCurrentTheme().borderColor })
                    .backgroundColor(Color.White)

                    // 配置内容列
                    Column() {
                      TextInput({ 
                        text: (this.editingValues[item.name] !== undefined ? this.editingValues[item.name] : item.value), 
                        placeholder: '' 
                      })
                        .fontSize(13)
                        .fontColor(this.getCurrentTheme().textColor)
                        .textAlign(TextAlign.Center)
                        .width('100%')
                        .backgroundColor(Color.White)
                        .border({ width: 0 })
                        .onChange((value: string) => {
                          // 只更新编辑中的值，不触发数组重新渲染
                          this.editingValues[item.name] = value
                        })
                        .onSubmit(() => {
                          // 提交时更新到数组
                          const filteredIndex = this.filteredConfigList.findIndex(config => config.name === item.name)
                          if (filteredIndex >= 0 && this.editingValues[item.name] !== undefined) {
                            const value = this.editingValues[item.name]
                            const newFilteredList: ConfigItem[] = []
                            for (let i = 0; i < this.filteredConfigList.length; i++) {
                              if (i === filteredIndex) {
                                newFilteredList.push({ name: this.filteredConfigList[i].name, value: value })
                              } else {
                                newFilteredList.push({ name: this.filteredConfigList[i].name, value: this.filteredConfigList[i].value })
                              }
                            }
                            this.filteredConfigList = newFilteredList
                            
                            // 更新原始列表
                            const originalIndex = this.configList.findIndex(config => config.name === item.name)
                            if (originalIndex >= 0) {
                              const newConfigList: ConfigItem[] = []
                              for (let i = 0; i < this.configList.length; i++) {
                                if (i === originalIndex) {
                                  newConfigList.push({ name: this.configList[i].name, value: value })
                                } else {
                                  newConfigList.push({ name: this.configList[i].name, value: this.configList[i].value })
                                }
                              }
                              this.configList = newConfigList
                            }
                          }
                        })
                    }
                    .width('50%')
                    .height(40)
                    .justifyContent(FlexAlign.Center)
                    .padding({ left: 8, right: 8 })
                    .border({ width: 0.5, color: this.getCurrentTheme().borderColor })
                    .backgroundColor(Color.White)
                  }
                  .width('100%')
                }, (item: ConfigItem) => item.name)
              }
              .width('100%')
            }
            .layoutWeight(1)
            .width('100%')
            .margin({ top: 8 })

            // 底部查询区域
            Row() {
              Text('配置名称:')
                .fontSize(14)
                .fontColor(this.getCurrentTheme().textColor)
                .margin({ right: 8 })

              TextInput({ text: this.queryName, placeholder: '请输入配置名称' })
                .layoutWeight(1)
                .height(32)
                .fontSize(14)
                .backgroundColor(Color.White)
                .border({ width: 1, color: this.getCurrentTheme().borderColor })
                .borderRadius(4)
                .margin({ right: 8 })
                .onChange((value: string) => {
                  this.queryName = value
                })

              Button('查询')
                .type(ButtonType.Normal)
                .fontSize(14)
                .fontColor(Color.White)
                .backgroundColor('#228B22')
                .width(80)
                .height(32)
                .borderRadius(4)
                .onClick(() => {
                  this.handleQuery()
                })

              Button('确定')
                .type(ButtonType.Normal)
                .fontSize(14)
                .fontColor(Color.White)
                .backgroundColor('#228B22')
                .width(80)
                .height(32)
                .borderRadius(4)
                .margin({ left: 8 })
                .onClick(() => {
                  this.handleConfirm()
                })
            }
            .width('100%')
            .padding({ top: 12, bottom: 12, left: 16, right: 16 })
            .alignItems(VerticalAlign.Center)
          }
          .layoutWeight(1)
          .width('100%')
          .backgroundColor(this.getCurrentTheme().surfaceColor)
        }
        .width(700)
        .height(600)
        .backgroundColor(this.getCurrentTheme().surfaceColor)
        .borderRadius(8)
        .shadow({
          radius: 20,
          color: 'rgba(0, 0, 0, 0.3)',
          offsetX: 0,
          offsetY: 4
        })
        .align(Alignment.Center)
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(1000)
  }
}
