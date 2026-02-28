import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { t, I18N_VERSION_KEY } from '../../utils/i18n/I18nManager'
import { CartonSpecRecord, getPackingSpecStorage } from '../../utils/storage/PackingSpecStorage'

class SelectValueOption {
  value: string = ''

  constructor(value: string) {
    this.value = value
  }
}

@Component
export struct PackingSpecDialog {
  @Prop isVisible: boolean = false
  @Prop initialConfigsJson: string = '[]'
  @Prop initialPrimarySpecId: number = 1
  @Prop initialSecondarySpecId: number = 2
  @StorageLink(OMNI_THEME_KEY) @Watch('onThemeChange') consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_VERSION_KEY) @Watch('onThemeChange') themeVersion: number = 0
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0

  @State private selectedSpecId: number = 1
  @State private primarySpecId: number = 1
  @State private secondarySpecId: number = 2
  @State private specList: CartonSpecRecord[] = []

  onConfirm?: (configsJson: string, primarySpecId: number, secondarySpecId: number) => void
  onCancel?: () => void

  getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.consumedTheme)
  }

  onThemeChange(): void {
    console.log('PackingSpecDialog: 主题已变化，重新渲染')
  }

  aboutToAppear(): void {
    const storage = getPackingSpecStorage()
    if (this.initialConfigsJson && this.initialConfigsJson.length > 2) {
      this.specList = storage.parseConfigs(this.initialConfigsJson)
    } else {
      this.specList = storage.getConfigs()
    }
    this.primarySpecId = this.initialPrimarySpecId
    this.secondarySpecId = this.initialSecondarySpecId
    this.selectedSpecId = this.primarySpecId
  }

  private handleCancel(): void {
    if (this.onCancel) {
      this.onCancel()
    }
  }

  private handleConfirm(): void {
    console.log(`[PACKING_SPEC_UI] confirm selected=${this.selectedSpecId} primary=${this.primarySpecId} secondary=${this.secondarySpecId}`)
    if (this.onConfirm) {
      this.onConfirm(JSON.stringify(this.specList), this.primarySpecId, this.secondarySpecId)
    }
  }

  private updateField(specId: number, field: string, value: string): void {
    const nextList: CartonSpecRecord[] = []
    for (let i = 0; i < this.specList.length; i++) {
      const item = this.specList[i]
      const next = new CartonSpecRecord(item.id, item.name, item.length, item.width, item.height, item.netWeight, item.note)
      if (item.id === specId) {
        if (field === 'name') {
          next.name = value
        } else if (field === 'length') {
          next.length = value
        } else if (field === 'width') {
          next.width = value
        } else if (field === 'height') {
          next.height = value
        } else if (field === 'netWeight') {
          next.netWeight = value
        } else if (field === 'note') {
          next.note = value
        }
      }
      nextList.push(next)
    }
    this.specList = nextList
  }

  private getSelectedSpec(): CartonSpecRecord {
    for (let i = 0; i < this.specList.length; i++) {
      if (this.specList[i].id === this.selectedSpecId) {
        return this.specList[i]
      }
    }
    return new CartonSpecRecord(1, '', '', '', '', '', '')
  }

  private buildWeightPreviewText(spec: CartonSpecRecord): string {
    return `${spec.length} × ${spec.width} × ${spec.height} mm / ${spec.netWeight} kg`
  }

  private getSpecOptions(): SelectValueOption[] {
    const options: SelectValueOption[] = []
    for (let i = 0; i < this.specList.length; i++) {
      options.push(new SelectValueOption(this.specList[i].name))
    }
    return options
  }

  @Builder
  private buildHeader(): void {
    Row() {
      Text(t('纸箱规格', '纸箱规格'))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .layoutWeight(1)

      Button() {
        Text('×')
          .fontSize(22)
          .fontColor(Color.White)
      }
      .type(ButtonType.Normal)
      .backgroundColor(Color.Transparent)
      .width(32)
      .height(32)
      .onClick(() => {
        this.handleCancel()
      })
    }
    .width('100%')
    .height(48)
    .padding({ left: 20, right: 12 })
    .backgroundColor('#4CAF50')
  }

  build() {
    Stack() {
      if (!this.isVisible) {
        Blank()
      } else {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .onClick(() => {
            this.handleCancel()
          })

        Column() {
          this.buildHeader()

          Scroll() {
            Column({ space: 16 }) {
              Row({ space: 12 }) {
                Text(t('当前规格', '当前规格'))
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.getCurrentTheme().textColor)

                ForEach(this.specList, (item: CartonSpecRecord) => {
                  Button(item.name)
                    .height(34)
                    .fontSize(13)
                    .fontColor(this.selectedSpecId === item.id ? Color.White : this.getCurrentTheme().textColor)
                    .backgroundColor(this.selectedSpecId === item.id ? this.getCurrentTheme().primary : this.getCurrentTheme().surfaceColor)
                    .borderRadius(8)
                    .border({ width: 1, color: this.getCurrentTheme().borderColor })
                    .onClick(() => {
                      this.selectedSpecId = item.id
                    })
                })
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)

              Row({ space: 12 }) {
                Column({ space: 8 }) {
                  Text('装箱方案1（对齐 48 的装箱数1）')
                    .fontSize(14)
                    .fontColor(this.getCurrentTheme().subTextColor)
                  Select(this.getSpecOptions())
                    .selected(Math.max(0, this.specList.findIndex((item: CartonSpecRecord) => item.id === this.primarySpecId)))
                    .font({ size: 14 })
                    .height(38)
                    .onSelect((index: number) => {
                      if (index >= 0 && index < this.specList.length) {
                        this.primarySpecId = this.specList[index].id
                      }
                    })
                }
                .layoutWeight(1)

                Column({ space: 8 }) {
                  Text('装箱方案2（对齐 48 的装箱数2）')
                    .fontSize(14)
                    .fontColor(this.getCurrentTheme().subTextColor)
                  Select(this.getSpecOptions())
                    .selected(Math.max(0, this.specList.findIndex((item: CartonSpecRecord) => item.id === this.secondarySpecId)))
                    .font({ size: 14 })
                    .height(38)
                    .onSelect((index: number) => {
                      if (index >= 0 && index < this.specList.length) {
                        this.secondarySpecId = this.specList[index].id
                      }
                    })
                }
                .layoutWeight(1)
              }
              .width('100%')
              .padding(16)
              .backgroundColor(this.getCurrentTheme().surfaceColor)
              .borderRadius(12)
              .border({ width: 1, color: this.getCurrentTheme().borderColor })

              Column({ space: 12 }) {
                Row({ space: 12 }) {
                  Column({ space: 6 }) {
                    Text('规格名称').fontSize(14).fontColor(this.getCurrentTheme().subTextColor)
                    TextInput({ text: this.getSelectedSpec().name })
                      .height(38)
                      .backgroundColor('#FFFFFF')
                      .borderRadius(8)
                      .onChange((value: string) => {
                        this.updateField(this.selectedSpecId, 'name', value)
                      })
                  }
                  .layoutWeight(1)

                  Column({ space: 6 }) {
                    Text('净重(kg)').fontSize(14).fontColor(this.getCurrentTheme().subTextColor)
                    TextInput({ text: this.getSelectedSpec().netWeight })
                      .type(InputType.Number)
                      .height(38)
                      .backgroundColor('#FFFFFF')
                      .borderRadius(8)
                      .onChange((value: string) => {
                        this.updateField(this.selectedSpecId, 'netWeight', value)
                      })
                  }
                  .width('28%')
                }
                .width('100%')

                Row({ space: 12 }) {
                  Column({ space: 6 }) {
                    Text('长(mm)').fontSize(14).fontColor(this.getCurrentTheme().subTextColor)
                    TextInput({ text: this.getSelectedSpec().length })
                      .type(InputType.Number)
                      .height(38)
                      .backgroundColor('#FFFFFF')
                      .borderRadius(8)
                      .onChange((value: string) => {
                        this.updateField(this.selectedSpecId, 'length', value)
                      })
                  }
                  .layoutWeight(1)

                  Column({ space: 6 }) {
                    Text('宽(mm)').fontSize(14).fontColor(this.getCurrentTheme().subTextColor)
                    TextInput({ text: this.getSelectedSpec().width })
                      .type(InputType.Number)
                      .height(38)
                      .backgroundColor('#FFFFFF')
                      .borderRadius(8)
                      .onChange((value: string) => {
                        this.updateField(this.selectedSpecId, 'width', value)
                      })
                  }
                  .layoutWeight(1)

                  Column({ space: 6 }) {
                    Text('高(mm)').fontSize(14).fontColor(this.getCurrentTheme().subTextColor)
                    TextInput({ text: this.getSelectedSpec().height })
                      .type(InputType.Number)
                      .height(38)
                      .backgroundColor('#FFFFFF')
                      .borderRadius(8)
                      .onChange((value: string) => {
                        this.updateField(this.selectedSpecId, 'height', value)
                      })
                  }
                  .layoutWeight(1)
                }
                .width('100%')

                Column({ space: 6 }) {
                  Text('备注').fontSize(14).fontColor(this.getCurrentTheme().subTextColor)
                  TextInput({ text: this.getSelectedSpec().note })
                    .height(74)
                    .backgroundColor('#FFFFFF')
                    .borderRadius(8)
                    .onChange((value: string) => {
                      this.updateField(this.selectedSpecId, 'note', value)
                    })
                }
                .width('100%')

                Row({ space: 8 }) {
                  Text(`预览：${this.buildWeightPreviewText(this.getSelectedSpec())}`)
                    .fontSize(13)
                    .fontColor(this.getCurrentTheme().primary)
                }
                .width('100%')
                .padding(12)
                .backgroundColor(this.getCurrentTheme().primary + '12')
                .borderRadius(8)
              }
              .width('100%')
              .padding(16)
              .backgroundColor(this.getCurrentTheme().surfaceColor)
              .borderRadius(12)
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
            }
            .width('100%')
            .padding(20)
          }
          .layoutWeight(1)
          .width('100%')

          Row({ space: 12 }) {
            Blank().layoutWeight(1)

            Button(t('取消', '取消'))
              .width(100)
              .height(40)
              .fontSize(15)
              .backgroundColor('#E0E0E0')
              .fontColor(this.getCurrentTheme().textColor)
              .borderRadius(8)
              .onClick(() => {
                this.handleCancel()
              })

            Button(t('确定', '确定'))
              .width(100)
              .height(40)
              .fontSize(15)
              .backgroundColor('#4CAF50')
              .fontColor(Color.White)
              .borderRadius(8)
              .onClick(() => {
                this.handleConfirm()
              })
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 12, bottom: 20 })
        }
        .width('72%')
        .height('76%')
        .backgroundColor(this.getCurrentTheme().surfaceColor)
        .borderRadius(12)
        .shadow({ radius: 20, color: 'rgba(0,0,0,0.2)', offsetY: 4 })
        .constraintSize({ maxWidth: 900, maxHeight: 720 })
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
  }
}
