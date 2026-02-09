import { copyStGradeInfo, StGradeInfo } from '../../protocol/Structures'
import { ConstPreDefine } from '../../protocol/ConstPreDefine'
import { GradeInfoConfigManager } from '../../pages/home/core/GradeInfoConfigManager'
import { getConfigSender } from '../../protocol/ConfigSender'
import { util } from '@kit.ArkTS'
import { HOME_SELECTED_FSM } from '../../constants/TopBarKeys'

@Component
export struct QualitySettingsDialog {
  @Prop isVisible: boolean
  onConfirm: () => void = () => {}
  onCancel: () => void = () => {}

  @State gradeInfo: StGradeInfo = new StGradeInfo()
  @State currentTabIndex: number = 0
  
  // Use a temporary copy for editing
  @State editingGradeInfo: StGradeInfo = new StGradeInfo()

  aboutToAppear() {
    this.loadData()
  }

  loadData() {
    const fsm = (AppStorage.get(HOME_SELECTED_FSM) as ('FSM1' | 'FSM2') | undefined) ?? 'FSM1'
    const source = GradeInfoConfigManager.getInstance().getOrCreateGradeInfo(fsm)
    this.editingGradeInfo = copyStGradeInfo(source)
  }

  private async handleConfirm(): Promise<void> {
    const fsm = (AppStorage.get(HOME_SELECTED_FSM) as ('FSM1' | 'FSM2') | undefined) ?? 'FSM1'
    const fsmId = fsm === 'FSM1' ? ConstPreDefine.getFsmId(0) : ConstPreDefine.getFsmId(1)
    const ok = await getConfigSender().sendFullGradeInfo(fsmId, this.editingGradeInfo)
    console.log(ok ? '品质参数设置已下发到下位机' : '品质参数设置下发失败')

    const key = `FULL_GRADE_INFO_CONFIG_${fsm}`
    AppStorage.setOrCreate(key, copyStGradeInfo(this.editingGradeInfo))
    this.onConfirm()
  }

  build() {
    Column() {
      // Header
      Row() {
        Text('参数设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .padding(10)
      .backgroundColor('#f0f0f0')

      // Content
      Tabs({ barPosition: BarPosition.Start, index: this.currentTabIndex }) {
        // 1. Color
        TabContent() {
          ColorGradeTab({ gradeInfo: this.editingGradeInfo })
        }.tabBar('颜色设置')

        // 2. Shape
        TabContent() {
          SimpleGradeTab({ 
            gradeInfo: this.editingGradeInfo, 
            title: '形状设置', 
            col2Name: '最大/最小直径',
            nameArray: this.editingGradeInfo.strShapeGradeName,
            factorArray: this.editingGradeInfo.fShapeFactor,
            maxCount: ConstPreDefine.MAX_SHAPE_GRADE_NUM
          })
        }.tabBar('形状设置')

        // 3. Blemish (Flaw)
        TabContent() {
          ImageGradeTab({
             gradeInfo: this.editingGradeInfo,
             title: '瑕疵设置',
             col2Name: '瑕疵面积(‰)',
             col3Name: '瑕疵数量',
             nameArray: this.editingGradeInfo.stFlawareaGradeName,
             factorArray: this.editingGradeInfo.unFlawAreaFactor, // Note: this is Uint32Array, might need handling
             maxCount: ConstPreDefine.MAX_FlAWAREA_GRADE_NUM,
             isDoubleFactor: true // Flaw uses unFlawAreaFactor which is area and num? 
                                  // In C++ it was unFlawAreaFactor[MAX * 2]
          })
        }.tabBar('瑕疵设置')

        // 4. Bruise
        TabContent() {
          ImageGradeTab({
             gradeInfo: this.editingGradeInfo,
             title: '擦伤设置',
             col2Name: '擦伤面积(‰)',
             col3Name: '擦伤数量',
             nameArray: this.editingGradeInfo.stBruiseGradeName,
             factorArray: this.editingGradeInfo.unBruiseFactor,
             maxCount: ConstPreDefine.MAX_BRUISE_GRADE_NUM,
             isDoubleFactor: true
          })
        }.tabBar('擦伤设置')

        // 5. Rot
        TabContent() {
          ImageGradeTab({
             gradeInfo: this.editingGradeInfo,
             title: '腐烂设置',
             col2Name: '腐烂面积(‰)',
             col3Name: '腐烂数量',
             nameArray: this.editingGradeInfo.stRotGradeName,
             factorArray: this.editingGradeInfo.unRotFactor,
             maxCount: ConstPreDefine.MAX_ROT_GRADE_NUM,
             isDoubleFactor: true
          })
        }.tabBar('腐烂设置')

        // 6. Density
        TabContent() {
          SimpleGradeTab({
            gradeInfo: this.editingGradeInfo,
            title: '密度设置',
            col2Name: '密度',
            nameArray: this.editingGradeInfo.stDensityGradeName,
            factorArray: this.editingGradeInfo.fDensityFactor,
            maxCount: ConstPreDefine.MAX_DENSITY_GRADE_NUM
          })
        }.tabBar('密度设置')

        // 7. Sugar
        TabContent() {
          SimpleGradeTab({
            gradeInfo: this.editingGradeInfo,
            title: '糖度设置',
            col2Name: '糖度',
            nameArray: this.editingGradeInfo.stSugarGradeName,
            factorArray: this.editingGradeInfo.fSugarFactor,
            maxCount: ConstPreDefine.MAX_SUGAR_GRADE_NUM
          })
        }.tabBar('糖度设置')

        // 8. Acidity
        TabContent() {
          SimpleGradeTab({
            gradeInfo: this.editingGradeInfo,
            title: '酸度设置',
            col2Name: '酸度',
            nameArray: this.editingGradeInfo.stAcidityGradeName,
            factorArray: this.editingGradeInfo.fAcidityFactor,
            maxCount: ConstPreDefine.MAX_ACIDITY_GRADE_NUM
          })
        }.tabBar('酸度设置')
        
        // 9. MoldyCore (Hollow)
        TabContent() {
          SimpleGradeTab({
            gradeInfo: this.editingGradeInfo,
            title: '霉芯设置',
            col2Name: '霉芯',
            nameArray: this.editingGradeInfo.stHollowGradeName,
            factorArray: this.editingGradeInfo.fHollowFactor,
            maxCount: ConstPreDefine.MAX_HOLLOW_GRADE_NUM
          })
        }.tabBar('霉芯设置')

        // 10. Shrivel (Skin)
        TabContent() {
          SimpleGradeTab({
            gradeInfo: this.editingGradeInfo,
            title: '枯水设置',
            col2Name: '枯水',
            nameArray: this.editingGradeInfo.stSkinGradeName,
            factorArray: this.editingGradeInfo.fSkinFactor,
            maxCount: ConstPreDefine.MAX_SKIN_GRADE_NUM
          })
        }.tabBar('枯水设置')

        // 11. FruitColor (Brown)
        TabContent() {
          SimpleGradeTab({
            gradeInfo: this.editingGradeInfo,
            title: '果肉色设置',
            col2Name: '果肉色',
            nameArray: this.editingGradeInfo.stBrownGradeName,
            factorArray: this.editingGradeInfo.fBrownFactor,
            maxCount: ConstPreDefine.MAX_BROWN_GRADE_NUM
          })
        }.tabBar('果肉色设置')

        // 12. Maturity (Tangxin)
        TabContent() {
          SimpleGradeTab({
            gradeInfo: this.editingGradeInfo,
            title: '成熟度设置',
            col2Name: '成熟度',
            nameArray: this.editingGradeInfo.stTangxinGradeName,
            factorArray: this.editingGradeInfo.fTangxinFactor,
            maxCount: ConstPreDefine.MAX_TANGXIN_GRADE_NUM
          })
        }.tabBar('成熟度设置')

        // 13. Hardness (Rigidity)
        TabContent() {
          SimpleGradeTab({
            gradeInfo: this.editingGradeInfo,
            title: '硬度设置',
            col2Name: '硬度',
            nameArray: this.editingGradeInfo.stRigidityGradeName,
            factorArray: this.editingGradeInfo.fRigidityFactor,
            maxCount: ConstPreDefine.MAX_RIGIDITY_GRADE_NUM
          })
        }.tabBar('硬度设置')

        // 14. Water
        TabContent() {
          SimpleGradeTab({
            gradeInfo: this.editingGradeInfo,
            title: '水心设置',
            col2Name: '水心',
            nameArray: this.editingGradeInfo.stWaterGradeName,
            factorArray: this.editingGradeInfo.fWaterFactor,
            maxCount: ConstPreDefine.MAX_WATER_GRADE_NUM
          })
        }.tabBar('水心设置')
      }
      .vertical(false)
      .barMode(BarMode.Scrollable)
      .layoutWeight(1)

      // Footer Buttons
      Row() {
        Button('确定')
          .onClick(() => this.handleConfirm())
          .width(120)
          .margin({ right: 20 })
        
        Button('取消')
          .onClick(() => this.onCancel())
          .width(120)
          .backgroundColor('#cccccc')
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding(10)
    }
    .backgroundColor(Color.White)
    .borderRadius(10)
    .shadow({ radius: 10, color: '#40000000', offsetX: 0, offsetY: 0 })
    .width('90%')
    .height('90%')
  }
}

// Helper function to read string from Uint8Array
function readName(bytes: Uint8Array, index: number): string {
  const start = index * ConstPreDefine.MAX_TEXT_LENGTH
  let end = start
  while (end < start + ConstPreDefine.MAX_TEXT_LENGTH && bytes[end] !== 0) {
    end++
  }
  if (end === start) return ''
  const slice = bytes.subarray(start, end)
  const decoder = new util.TextDecoder()
  return decoder.decodeWithStream(slice)
}

function writeName(bytes: Uint8Array, index: number, name: string) {
  const base = index * ConstPreDefine.MAX_TEXT_LENGTH
  // Clear
  for (let i = 0; i < ConstPreDefine.MAX_TEXT_LENGTH; i++) {
    bytes[base + i] = 0
  }
  const encoder = new util.TextEncoder()
  const src = encoder.encodeInto(name)
  for (let i = 0; i < src.length && i < ConstPreDefine.MAX_TEXT_LENGTH; i++) {
    bytes[base + i] = src[i]
  }
}

@Component
struct SimpleGradeTab {
  @ObjectLink gradeInfo: StGradeInfo
  @Prop title: string
  @Prop col2Name: string
  nameArray: Uint8Array = new Uint8Array(0)
  factorArray: Float32Array = new Float32Array(0)
  @Prop maxCount: number

  @State selectOptions: SelectOption[] = [
    { value: '1' }, { value: '2' }, { value: '3' }, 
    { value: '4' }, { value: '5' }, { value: '6' }
  ]
  @State indexArray: number[] = []

  aboutToAppear() {
    this.indexArray = []
    for (let i = 0; i < this.maxCount; i++) {
      this.indexArray.push(i)
    }
  }

  build() {
    Column() {
      // Top Controls
      Row() {
        Text(this.title).margin({ right: 10 })
        Select(this.selectOptions)
          .value('1')
          .width(100)
      }
      .padding(10)
      .width('100%')
      .justifyContent(FlexAlign.Start)

      // Table
      Row() {
        // Header
        Column() {
          Row() {
            Text('等级名称').width('50%').textAlign(TextAlign.Center).fontWeight(FontWeight.Bold)
            Text(this.col2Name).width('50%').textAlign(TextAlign.Center).fontWeight(FontWeight.Bold)
          }
          .height(40)
          .backgroundColor('#e0e0e0')

          List() {
            ForEach(this.indexArray, (index: number) => {
              ListItem() {
                Row() {
                  TextInput({ text: readName(this.nameArray, index) })
                    .width('50%')
                    .onChange((value: string) => {
                       writeName(this.nameArray, index, value)
                    })
                  
                  TextInput({ text: this.factorArray[index].toString() })
                    .width('50%')
                    .type(InputType.Number)
                    .onChange((value: string) => {
                       this.factorArray[index] = parseFloat(value)
                    })
                }
                .height(40)
                .border({ width: { bottom: 1 }, color: '#f0f0f0' })
              }
            })
          }
          .layoutWeight(1)
        }
      }
      .layoutWeight(1)
      .width('100%')
    }
    .padding(10)
  }
}

@Component
struct ImageGradeTab {
  @ObjectLink gradeInfo: StGradeInfo
  @Prop title: string
  @Prop col2Name: string
  @Prop col3Name: string
  nameArray: Uint8Array = new Uint8Array(0)
  factorArray: Uint32Array = new Uint32Array(0)
  @Prop maxCount: number
  @Prop isDoubleFactor: boolean

  @State selectOptions: SelectOption[] = [
    { value: '1' }, { value: '2' }, { value: '3' }, 
    { value: '4' }, { value: '5' }, { value: '6' }
  ]
  @State indexArray: number[] = []

  aboutToAppear() {
    this.indexArray = []
    for (let i = 0; i < this.maxCount; i++) {
      this.indexArray.push(i)
    }
  }

  build() {
    Row() {
      // Left: List
      Column() {
        Row() {
          Text(this.title).margin({ right: 10 })
          Select(this.selectOptions)
            .value('1')
            .width(100)
        }
        .padding(10)
        .width('100%')

        // Table
        Column() {
          Row() {
            Text('等级名称').width('33%').textAlign(TextAlign.Center).fontWeight(FontWeight.Bold)
            Text(this.col2Name).width('33%').textAlign(TextAlign.Center).fontWeight(FontWeight.Bold)
            Text(this.col3Name).width('33%').textAlign(TextAlign.Center).fontWeight(FontWeight.Bold)
          }
          .height(40)
          .backgroundColor('#e0e0e0')

          List() {
            ForEach(this.indexArray, (index: number) => {
              ListItem() {
                Row() {
                  TextInput({ text: readName(this.nameArray, index) })
                    .width('33%')
                    .onChange((value: string) => {
                       writeName(this.nameArray, index, value)
                    })
                  
                  // Area
                  TextInput({ text: this.factorArray[index * 2].toString() })
                    .width('33%')
                    .type(InputType.Number)
                    .onChange((value: string) => {
                       this.factorArray[index * 2] = parseInt(value)
                    })

                  // Num
                  TextInput({ text: this.factorArray[index * 2 + 1].toString() })
                    .width('33%')
                    .type(InputType.Number)
                    .onChange((value: string) => {
                       this.factorArray[index * 2 + 1] = parseInt(value)
                    })
                }
                .height(40)
                .border({ width: { bottom: 1 }, color: '#f0f0f0' })
              }
            })
          }
          .layoutWeight(1)
        }
        .layoutWeight(1)
        .width('100%')
      }
      .width('40%')
      .height('100%')
      .border({ width: { right: 1 }, color: '#cccccc' })

      // Right: Image & Controls
      Column() {
        // Image Area
        Stack() {
           Text('Image Preview Area')
        }
        .width('100%')
        .height('60%')
        .backgroundColor('#black')
        
        // Buttons
        Row() {
          Button('Get image').margin(5)
          Button('Save image').margin(5)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 10 })

        // Inputs
        Row() {
           Text('Area:')
           TextInput({ placeholder: '0' }).width(80).margin({ right: 10 })
           Text('Num:')
           TextInput({ placeholder: '0' }).width(80)
        }
        .margin({ top: 10 })
      }
      .width('60%')
      .height('100%')
      .padding(10)
    }
    .width('100%')
    .height('100%')
  }
}

@Component
struct ColorGradeTab {
  @ObjectLink gradeInfo: StGradeInfo

  @State selectOptions: SelectOption[] = [
    { value: 'UV map' }, { value: 'Hue map' }, { value: 'Gray scale map' }
  ]
  @State indexArray: number[] = [0, 1, 2, 3, 4]

  build() {
    Row() {
      // Left: List
      Column() {
        Row() {
          Button('+').width(30).margin({ right: 5 })
          Button('-').width(30)
        }
        .padding(5)
        .width('100%')
        .justifyContent(FlexAlign.Start)

        // Table
        Column() {
          Row() {
            Text('Name').width('50%').textAlign(TextAlign.Center).fontWeight(FontWeight.Bold)
            Text('Average').width('50%').textAlign(TextAlign.Center).fontWeight(FontWeight.Bold)
          }
          .height(40)
          .backgroundColor('#e0e0e0')

          List() {
            // Mock data for display since intervals are complex
            ForEach(this.indexArray, (index: number) => {
              ListItem() {
                Row() {
                  Text(`Color ${index + 1}`).width('50%').textAlign(TextAlign.Center)
                  Text('0').width('50%').textAlign(TextAlign.Center)
                }
                .height(40)
                .border({ width: { bottom: 1 }, color: '#f0f0f0' })
              }
            })
          }
          .layoutWeight(1)
        }
        .layoutWeight(1)
        .width('100%')
        
        // Bottom controls
        Column() {
          Select(this.selectOptions)
            .value('UV map')
            .width('100%')
          
          Row() {
            Radio({ value: 'Percent', group: 'colorMode' }).checked(true)
            Text('Percent').margin({ right: 10 })
            Radio({ value: 'Average', group: 'colorMode' })
            Text('Average')
          }.margin({ top: 5 })

          Row() {
            Text('Contrast:').margin({ right: 5 })
            TextInput({ placeholder: '0' }).width(60)
          }.margin({ top: 5 })
        }
        .padding(10)
        .backgroundColor('#f9f9f9')
      }
      .width('30%')
      .height('100%')
      .border({ width: { right: 1 }, color: '#cccccc' })

      // Right: Image
      Column() {
         Stack() {
           Text('Color Image Preview')
        }
        .width('100%')
        .height('70%')
        .backgroundColor('#333')

        Row() {
          Button('Get image').margin(5)
          Button('Color interval').margin(5)
          Button('Save image').margin(5)
          Button('Tag demarcate').margin(5)
        }.margin({ top: 10 })
      }
      .width('70%')
      .height('100%')
      .padding(10)
    }
  }
}
