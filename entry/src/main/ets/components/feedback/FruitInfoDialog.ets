/**
 * 水果信息对话框组件
 * 功能：显示水果的详细信息，包含确认和取消按钮
 * 用途：在点击"水果信息"按钮时弹出
 */

import { ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { DialogButtons } from '../ui/dialogs/DialogButtons'
import { DialogHeader } from '../ui/dialogs/DialogHeader'
import { FormInputField } from '../ui/forms/FormInputField'
import { getGlobalDataInterface } from '../../protocol/GlobalDataInterface'
import { StFruitGradeRealtime, StSysConfig } from '../../protocol/Structures'
import { ConstPreDefine } from '../../protocol/ConstPreDefine'
import { getConfigSender } from '../../protocol/ConfigSender'
import { HOME_SELECTED_FSM } from '../../constants/TopBarKeys'

// 水果信息接口
interface FruitInfo {
  name: string
  type: string
  weight: number
  color: string
  ripeness: string
  origin: string
  harvestDate: string
  quality: string
}

interface FruitInfoPayload {
  lane: string;
  level: string;
  diameterMm: number;
  weightG: number;
  projectionAreaMm2: number;
  densityKgPerM3: number;
  volumeMm3: number;
  brix: number;
  color1Pct: number;
  acidity: number;
  color2Pct: number;
  drynessPct: number;
  color3Pct: number;
  maturityPct: number;
  defectAreaMm2: number;
  pulpColorPct: number;
  defectCount: number;
  outlet: string;
  verticalAxis: number;
  horizontalRatio: number;
  flatEllipticalRatioMm: number;
  detectionTime: string;
}

type FsmKey = 'FSM1' | 'FSM2'

interface GradeTableConfig {
  sizeGradeNames: string[]
  qualityGradeNames: string[]
}

@Component
export struct FruitInfoDialog {
  @Prop @Watch('onVisibleChange') isVisible: boolean = false
  @State fruitInfo: FruitInfo = {
    name: '苹果',
    type: '红富士',
    weight: 0.25,
    color: '红色',
    ripeness: '成熟',
    origin: '山东烟台',
    harvestDate: '2024-01-15',
    quality: '优质'
  }
  
  // 表单状态字段（后续联调时可根据需要增减/调整默认值）
  @State private selectedLaneIndex: number = 0 // 通道下拉：0 对应 lane-1
  @State private levelText: string = '' // 等级
  @State private diameterMm: number = 0
  @State private weightG: number = 0
  @State private projectionAreaMm2: number = 0
  @State private densityKgPerM3: number = 0
  @State private volumeMm3: number = 0
  @State private brix: number = 0
  @State private color1Pct: number = 0
  @State private acidity: number = 0
  @State private color2Pct: number = 0
  @State private drynessPct: number = 0
  @State private color3Pct: number = 0
  @State private maturityPct: number = 0
  @State private defectAreaMm2: number = 0
  @State private pulpColorPct: number = 0
  @State private defectCount: number = 0
  @State private outletText: string = ''
  @State private verticalAxis: number = 0
  @State private horizontalRatio: number = 0
  @State private flatEllipticalRatioMm: number = 0
  
  // 对话框回调
  onConfirm?: (fruitInfo: FruitInfo) => void
  onCancel?: () => void

  private dataInterface = getGlobalDataInterface()
  private fruitGradeListener: ((data: StFruitGradeRealtime) => void) | null = null
  private lastGradeByChannel: Map<number, StFruitGradeRealtime> = new Map()
  private currentIpmId: number | null = null
  private sysConfigListener: ((data: StSysConfig) => void) | null = null

  @State private classificationMask: number = 0x1F

  private pendingSwitchTimerId: number = 0
  private pendingSwitchIndex: number = 0

  private hasCIR(): boolean { return (this.classificationMask & 0x01) !== 0 }
  private hasUV(): boolean { return (this.classificationMask & 0x02) !== 0 }
  private hasWeight(): boolean { return (this.classificationMask & 0x04) !== 0 }
  private hasInternal(): boolean { return (this.classificationMask & 0x08) !== 0 }
  private hasUltrasonic(): boolean { return (this.classificationMask & 0x10) !== 0 }

  private getGradeTableConfig(fsm: FsmKey): GradeTableConfig | null {
    const key = `HOME_GRADE_TABLE_CONFIG_${fsm}`
    const cfg = AppStorage.get(key) as GradeTableConfig | undefined
    if (!cfg) return null
    if (!Array.isArray(cfg.sizeGradeNames) || !Array.isArray(cfg.qualityGradeNames)) return null
    return cfg
  }

  private getCurrentFsm(): FsmKey {
    const v = AppStorage.get(HOME_SELECTED_FSM) as FsmKey | undefined
    if (v === 'FSM2') return 'FSM2'
    return 'FSM1'
  }

  private formatGradeName(unGrade: number): string {
    const cfg = this.getGradeTableConfig(this.getCurrentFsm())
    const sizeIdx = unGrade & 0x0F
    const qualIdx = (unGrade >> 4) & 0x0F
    if (!cfg) {
      return `${sizeIdx}${qualIdx}`
    }
    const sizeName = (cfg.sizeGradeNames[sizeIdx] ?? `${sizeIdx}`).trim()
    const qualName = (cfg.qualityGradeNames[qualIdx] ?? `${qualIdx}`).trim()
    if (cfg.sizeGradeNames.length > 0 && cfg.qualityGradeNames.length > 0) {
      return `${sizeName}${qualName}`
    }
    if (cfg.qualityGradeNames.length > 0) {
      return qualName
    }
    return sizeName
  }

  private refreshClassificationMask(): void {
    const sys = this.dataInterface.getSysConfig()
    if (sys) {
      this.classificationMask = sys.nClassificationInfo & 0xFF
    } else {
      this.classificationMask = 0x1F
    }
  }

  // 确认按钮点击 - 保存到数据库
  private async handleConfirm() {
    try {
      // 生成检测时间（格式：YYYY-MM-DD HH:mm:ss）
      const now = new Date()
      const year = now.getFullYear()
      const month = String(now.getMonth() + 1).padStart(2, '0')
      const day = String(now.getDate()).padStart(2, '0')
      const hours = String(now.getHours()).padStart(2, '0')
      const minutes = String(now.getMinutes()).padStart(2, '0')
      const seconds = String(now.getSeconds()).padStart(2, '0')
      const detectionTime = `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
      
      // 构建通道字符串（lane-1, lane-2等）
      const lane = `lane-${this.selectedLaneIndex + 1}`
      
      // 构建数据库插入参数
      const insertParams: FruitInfoPayload = {
        lane: lane,
        level: this.levelText || '',
        diameterMm: this.diameterMm,
        weightG: this.weightG,
        projectionAreaMm2: this.projectionAreaMm2,
        densityKgPerM3: this.densityKgPerM3,
        volumeMm3: this.volumeMm3,
        brix: this.brix,
        color1Pct: this.color1Pct,
        acidity: this.acidity,
        color2Pct: this.color2Pct,
        drynessPct: this.drynessPct,
        color3Pct: this.color3Pct,
        maturityPct: this.maturityPct,
        defectAreaMm2: this.defectAreaMm2,
        pulpColorPct: this.pulpColorPct,
        defectCount: this.defectCount,
        outlet: this.outletText || '',
        verticalAxis: this.verticalAxis,
        horizontalRatio: this.horizontalRatio,
        flatEllipticalRatioMm: this.flatEllipticalRatioMm,
        detectionTime: detectionTime
        // processingId 可选，如果需要关联加工批次，可以在这里设置
      }
      
      // 当前版本不再保存到数据库，直接记录日志
      console.log('水果信息已提交', JSON.stringify(insertParams))
      
      // 调用回调
      if (this.onConfirm) {
        this.onConfirm(this.fruitInfo)
      }
    } catch (error) {
      console.error('保存水果信息失败:', error)
      // 即使保存失败，也调用回调（保持原有行为）
      if (this.onConfirm) {
        this.onConfirm(this.fruitInfo)
      }
    }
  }

  // 取消按钮点击
  private handleCancel() {
    if (this.onCancel) {
      this.onCancel()
    }
  }

  onVisibleChange(): void {
    if (this.isVisible) {
      this.startRealtime()
    } else {
      this.stopRealtime()
    }
  }

  // 显示对话框时重置通道为 lane-1（index = 0），不自动加载数据
  aboutToAppear() {
    this.selectedLaneIndex = 0
    this.refreshClassificationMask()
    this.loadLaneData(this.selectedLaneIndex)
  }

  // 加载指定通道的数据并填充表单
  private loadLaneData(channelIndex: number): void {
    const data = this.lastGradeByChannel.get(channelIndex)
    if (data) {
      this.applyGradeInfo(data)
      return
    }

    const recent = this.dataInterface.getRecentFruits()
    for (let i = 0; i < recent.length; i++) {
      const item = recent[i]
      this.lastGradeByChannel.set(item.channelIndex, item)
    }

    const fallback = this.lastGradeByChannel.get(channelIndex)
    if (fallback) {
      this.applyGradeInfo(fallback)
    } else {
      this.clearFormData()
    }
  }

  // 清空表单数据
  private clearFormData(): void {
    this.levelText = ''
    this.diameterMm = 0
    this.weightG = 0
    this.projectionAreaMm2 = 0
    this.densityKgPerM3 = 0
    this.volumeMm3 = 0
    this.brix = 0
    this.color1Pct = 0
    this.acidity = 0
    this.color2Pct = 0
    this.drynessPct = 0
    this.color3Pct = 0
    this.maturityPct = 0
    this.defectAreaMm2 = 0
    this.pulpColorPct = 0
    this.defectCount = 0
    this.outletText = ''
    this.verticalAxis = 0
    this.horizontalRatio = 0
    this.flatEllipticalRatioMm = 0
  }

  private applyGradeInfo(info: StFruitGradeRealtime): void {
    this.levelText = this.formatGradeName(info.grade)
    this.diameterMm = info.diameterMm
    this.weightG = info.weightG
    this.projectionAreaMm2 = info.projectionAreaMm2
    this.densityKgPerM3 = info.densityKgPerM3
    this.volumeMm3 = info.volumeMm3
    this.brix = info.brix
    this.acidity = info.acidity
    this.color1Pct = info.colorRate0Pct
    this.color2Pct = info.colorRate1Pct
    this.color3Pct = info.colorRate2Pct
    this.maturityPct = info.maturity
    this.pulpColorPct = info.pulpColor
    this.defectAreaMm2 = info.visionFlawAreaMm2
    this.defectCount = info.visionFlawCount
    this.drynessPct = info.uvWater
    this.verticalAxis = info.diameterMm
    this.horizontalRatio = info.diameterRatio
    this.flatEllipticalRatioMm = info.minDiameterRatio

    if (info.targetExit >= 0 && info.targetExit < ConstPreDefine.MAX_EXIT_NUM) {
      this.outletText = `${info.targetExit + 1}`
    } else {
      this.outletText = `${info.targetExit}`
    }
  }

  private getIpmIdForChannel(channelIndex: number): number {
    const subsysIndex = 0
    const ipmIndex = Math.floor(channelIndex / ConstPreDefine.CHANNEL_NUM)
    return ConstPreDefine.getIpmId(subsysIndex, ipmIndex)
  }

  private async switchGradeInfoChannel(channelIndex: number): Promise<void> {
    const nextIpmId = this.getIpmIdForChannel(channelIndex)
    if (this.currentIpmId !== null && this.currentIpmId !== nextIpmId) {
      await getConfigSender().sendGradeInfoOff(this.currentIpmId)
    }
    await getConfigSender().sendGradeInfoOn(nextIpmId)
    this.currentIpmId = nextIpmId
  }

  private scheduleSwitchGradeInfoChannel(channelIndex: number): void {
    this.pendingSwitchIndex = channelIndex
    if (this.pendingSwitchTimerId !== 0) {
      clearTimeout(this.pendingSwitchTimerId)
      this.pendingSwitchTimerId = 0
    }
    this.pendingSwitchTimerId = setTimeout(() => {
      this.pendingSwitchTimerId = 0
      this.switchGradeInfoChannel(this.pendingSwitchIndex)
    }, 120)
  }

  private startRealtime(): void {
    if (!this.fruitGradeListener) {
      this.fruitGradeListener = (info: StFruitGradeRealtime) => {
        this.lastGradeByChannel.set(info.channelIndex, info)
        if (this.isVisible && info.channelIndex === this.selectedLaneIndex) {
          this.applyGradeInfo(info)
        }
      }
      this.dataInterface.addFruitGradeListener(this.fruitGradeListener)
    }

    if (!this.sysConfigListener) {
      this.sysConfigListener = (_sys: StSysConfig) => {
        this.refreshClassificationMask()
      }
      this.dataInterface.addSysConfigListener(this.sysConfigListener)
    }

    const recent = this.dataInterface.getRecentFruits()
    for (let i = 0; i < recent.length; i++) {
      const item = recent[i]
      this.lastGradeByChannel.set(item.channelIndex, item)
    }

    this.loadLaneData(this.selectedLaneIndex)
    this.scheduleSwitchGradeInfoChannel(this.selectedLaneIndex)
  }

  private stopRealtime(): void {
    if (this.pendingSwitchTimerId !== 0) {
      clearTimeout(this.pendingSwitchTimerId)
      this.pendingSwitchTimerId = 0
    }
    if (this.fruitGradeListener) {
      this.dataInterface.removeFruitGradeListener(this.fruitGradeListener)
      this.fruitGradeListener = null
    }

    if (this.sysConfigListener) {
      this.dataInterface.removeSysConfigListener(this.sysConfigListener)
      this.sysConfigListener = null
    }

    if (this.currentIpmId !== null) {
      getConfigSender().sendGradeInfoOff(this.currentIpmId)
      this.currentIpmId = null
    }
  }

  build() {
    if (this.isVisible) {
      Stack() {
        Column() {
        }
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .onClick(() => {
            this.handleCancel()
          })

        Column() {
          // 标题栏
          DialogHeader({
            title: '水果信息',
            onClose: () => {
              this.handleCancel()
            }
          })

          // 内容区域（卡片栈）
          Scroll() {
            Column() {
              // 基础信息卡片：通道下拉（默认 lane-1）与右侧等级输入框
              Column() {
                Row() {
                  Text('通道')
                    .fontSize(18)  // 标签字体调大到18px
                    .fontColor(getCurrentTheme().textColor)
                    .margin({ right: 8 })

                  Select([
                    { value: 'lane-1' },
                    { value: 'lane-2' },
                    { value: 'lane-3' },
                    { value: 'lane-4' },
                    { value: 'lane-5' },
                    { value: 'lane-6' },
                    { value: 'lane-7' },
                    { value: 'lane-8' }
                  ])
                    .selected(this.selectedLaneIndex)
                    .font({ size: 18 })  // 下拉框字体调大到18px
                    .fontColor(getCurrentTheme().textColor)
                    .backgroundColor(getCurrentTheme().controlBg ?? getCurrentTheme().surfaceColor)
                    .border({ width: 1, color: getCurrentTheme().borderColor })
                    .borderRadius(2)  // 使用等级页面的圆角样式
                    .padding({ left: 8, right: 25, top: 3, bottom: 3 })  // 增加右侧padding，让箭头靠右
                    .layoutWeight(1)  // 添加layoutWeight，让箭头自动靠右
                    .constraintSize({ minWidth: 120, maxWidth: 220 })
                    .height(34)  // 保持水果信息页面的高度
                    .onSelect((index: number) => {
                      this.selectedLaneIndex = index
                      this.loadLaneData(index)
                      this.scheduleSwitchGradeInfoChannel(index)
                    })

                  Blank().layoutWeight(1)

                  Text('等级:')
                    .fontSize(18)  // 标签字体调大到18px
                    .fontColor(getCurrentTheme().textColor)
                    .margin({ right: 8 })

                  TextInput({ text: this.levelText })
                    .fontSize(18)  // 等级输入框字体调大到18px
                    .fontColor(getCurrentTheme().textColor)
                    .backgroundColor(getCurrentTheme().controlBg ?? getCurrentTheme().surfaceColor)
                    .border({ width: 1, color: getCurrentTheme().borderColor })
                    .borderRadius(8)
                    .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                    .constraintSize({ minWidth: 120, maxWidth: 220 })
                    .height(28)
                    .enabled(false)
                    .opacity(0.55)
                }
                .width('100%')
                .alignItems(VerticalAlign.Center)
              }
              .width('100%')
              .padding(12)
              .backgroundColor(getCurrentTheme().controlBg ?? getCurrentTheme().surfaceColor)
              .border({ width: 1, color: getCurrentTheme().borderColor })
              .borderRadius(10)
              .alignItems(HorizontalAlign.Start)
              

              // 检测数据卡片（外层卡片包内层卡片）
            Column() {
                // 外层标题已按需求移除

                // 内层卡片：两列对齐网格
                Column() {
                  // NOTE: 可在此处调整标签、单位与字段顺序；后续需要新增/删减字段时，保持两列对齐规范
                  // 统一的行生成：每行两个字段，字段由“标签 + 输入 + 单位”组成
                  // 直径(mm) | 重量(g)
                  Row() {
                    // 左列字段
                    FormInputField({
                      config: {
                        label: '直径',
                        value: this.diameterMm,
                        unit: 'mm',
                        minValue: 0,
                        maxValue: 1000,
                        enabled: this.hasCIR()
                      },
                      onValueChange: (value: number) => {
                        this.diameterMm = value
                      }
                    })

                    // 右列字段
                    FormInputField({
                      config: {
                        label: '重量',
                        value: this.weightG,
                        unit: 'g',
                        minValue: 0,
                        maxValue: 100000,
                        enabled: this.hasWeight()
                      },
                      onValueChange: (value: number) => {
                        this.weightG = value
                      }
                    })
                  }
                  .width('100%')
                  .margin({ bottom: 10 })

                  // 投影面积(mm^2) | 密度(kg/m^3)
                  Row() {
                    FormInputField({
                      config: {
                        label: '投影面积',
                        value: this.projectionAreaMm2,
                        unit: 'mm^2',
                        minValue: 0,
                        maxValue: 100000000,
                        enabled: this.hasCIR()
                      },
                      onValueChange: (value: number) => {
                        this.projectionAreaMm2 = value
                      }
                    })

                    FormInputField({
                      config: {
                        label: '密度',
                        value: this.densityKgPerM3,
                        unit: 'kg/m^3',
                        minValue: 0,
                        maxValue: 5000,
                        enabled: this.hasCIR() && this.hasWeight()
                      },
                      onValueChange: (value: number) => {
                        this.densityKgPerM3 = value
                      }
                    })
                  }
                  .width('100%')
                  .margin({ bottom: 10 })

                  // 体积(mm^3) | 糖度(brix)
                  Row() {
                    FormInputField({
                      config: {
                        label: '体积',
                        value: this.volumeMm3,
                        unit: 'mm^3',
                        minValue: 0,
                        maxValue: 100000000,
                        enabled: this.hasCIR()
                      },
                      onValueChange: (value: number) => {
                        this.volumeMm3 = value
                      }
                    })

                    FormInputField({
                      config: {
                        label: '糖度',
                        value: this.brix,
                        unit: 'brix',
                        minValue: 0,
                        maxValue: 100,
                        enabled: this.hasInternal()
                      },
                      onValueChange: (value: number) => {
                        this.brix = value
                      }
                    })
                  }
                  .width('100%')
                  .margin({ bottom: 10 })

                  // 颜色1比例(%) | 酸度(acid)
                  Row() {
                    FormInputField({
                      config: {
                        label: '颜色1比例',
                        value: this.color1Pct,
                        unit: '%',
                        minValue: 0,
                        maxValue: 100,
                        enabled: this.hasCIR()
                      },
                      onValueChange: (value: number) => {
                        this.color1Pct = value
                      }
                    })

                    FormInputField({
                      config: {
                        label: '酸度',
                        value: this.acidity,
                        unit: 'acid',
                        minValue: 0,
                        maxValue: 100,
                        enabled: this.hasInternal()
                      },
                      onValueChange: (value: number) => {
                        this.acidity = value
                      }
                    })
                  }
                  .width('100%')
                  .margin({ bottom: 10 })

                  // 颜色2比例(%) | 枯水(%)
                  Row() {
                    FormInputField({
                      config: {
                        label: '颜色2比例',
                        value: this.color2Pct,
                        unit: '%',
                        minValue: 0,
                        maxValue: 100,
                        enabled: this.hasCIR()
                      },
                      onValueChange: (value: number) => {
                        this.color2Pct = value
                      }
                    })

                    FormInputField({
                      config: {
                        label: '枯水',
                        value: this.drynessPct,
                        unit: '%',
                        minValue: 0,
                        maxValue: 100,
                        enabled: this.hasUV()
                      },
                      onValueChange: (value: number) => {
                        this.drynessPct = value
                      }
                    })
                  }
                  .width('100%')
                  .margin({ bottom: 10 })

                  // 颜色3比例(%) | 成熟度(%)
                  Row() {
                    FormInputField({
                      config: {
                        label: '颜色3比例',
                        value: this.color3Pct,
                        unit: '%',
                        minValue: 0,
                        maxValue: 100,
                        enabled: this.hasCIR()
                      },
                      onValueChange: (value: number) => {
                        this.color3Pct = value
                      }
                    })

                    FormInputField({
                      config: {
                        label: '成熟度',
                        value: this.maturityPct,
                        unit: '%',
                        minValue: 0,
                        maxValue: 100,
                        enabled: this.hasInternal()
                      },
                      onValueChange: (value: number) => {
                        this.maturityPct = value
                      }
                    })
                  }
                  .width('100%')
                  .margin({ bottom: 10 })

                  // 瑕疵面积(mm^2) | 果肉色(%)
                  Row() {
                    FormInputField({
                      config: {
                        label: '瑕疵面积',
                        value: this.defectAreaMm2,
                        unit: 'mm^2',
                        minValue: 0,
                        maxValue: 100000000,
                        enabled: this.hasUV()
                      },
                      onValueChange: (value: number) => {
                        this.defectAreaMm2 = value
                      }
                    })

                    FormInputField({
                      config: {
                        label: '果肉色',
                        value: this.pulpColorPct,
                        unit: '%',
                        minValue: 0,
                        maxValue: 100,
                        enabled: this.hasInternal()
                      },
                      onValueChange: (value: number) => {
                        this.pulpColorPct = value
                      }
                    })
                  }
                  .width('100%')
                  .margin({ bottom: 10 })

                  // 瑕疵个数(个) | 出口
                  Row() {
                    FormInputField({
                      config: {
                        label: '瑕疵个数',
                        value: this.defectCount,
                        unit: '个',
                        minValue: 0,
                        maxValue: 1000000,
                        enabled: this.hasUV()
                      },
                      onValueChange: (value: number) => {
                        this.defectCount = value
                      }
                    })

                    // 出口是文本输入，不使用 FormInputField
                    Row() {
                      Text('出口')
                        .fontSize(18)
                        .fontColor(getCurrentTheme().textColor)
                        .width(72)
                        .textAlign(TextAlign.End)
                        .margin({ right: 8 })
                      TextInput({ text: this.outletText })
                        .fontSize(18)
                        .fontColor(getCurrentTheme().textColor)
                        .backgroundColor(getCurrentTheme().controlBg ?? getCurrentTheme().surfaceColor)
                        .border({ width: 1, color: getCurrentTheme().borderColor })
                        .borderRadius(8)
                        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                        .constraintSize({ minWidth: 140, maxWidth: 180 })
                        .height(34)
                        .enabled(false)
                        .opacity(0.55)
                    }
                    .layoutWeight(1)
                    .alignItems(VerticalAlign.Center)
                  }
                  .width('100%')
                  .margin({ bottom: 10 })

                  // 垂轴径 | 横径比
                  Row() {
                    FormInputField({
                      config: {
                        label: '垂轴径',
                        value: this.verticalAxis,
                        minValue: 0,
                        maxValue: 1000000,
                        enabled: this.hasCIR()
                      },
                      onValueChange: (value: number) => {
                        this.verticalAxis = value
                      }
                    })

                    FormInputField({
                      config: {
                        label: '横径比',
                        value: this.horizontalRatio,
                        minValue: 0,
                        maxValue: 100,
                        enabled: this.hasCIR()
                      },
                      onValueChange: (value: number) => {
                        this.horizontalRatio = value
                      }
                    })
                  }
                  .width('100%')
                  .margin({ bottom: 10 })

                  // 扁椭型横径比(mm) | 空列占位（保持网格对齐）
                  Row() {
                    FormInputField({
                      config: {
                        label: '扁椭型横径比',
                        value: this.flatEllipticalRatioMm,
                        unit: 'mm',
                        minValue: 0,
                        maxValue: 1000000,
                        enabled: this.hasCIR()
                      },
                      onValueChange: (value: number) => {
                        this.flatEllipticalRatioMm = value
                      }
                    })

                    Blank().layoutWeight(1)
                  }
                  .width('100%')
                }
                .width('100%')
                .padding(12)
                .backgroundColor(getCurrentTheme().controlBg ?? getCurrentTheme().surfaceColor)
                .border({ width: 1, color: getCurrentTheme().borderColor })
                .borderRadius(8)
              }
              .width('100%')
              .padding(16)
              .backgroundColor(getCurrentTheme().controlBg ?? getCurrentTheme().surfaceColor)
              .border({ width: 1, color: getCurrentTheme().borderColor })
              .borderRadius(12)
              .shadow({ radius: 8, color: 'rgba(0,0,0,0.06)', offsetY: 2 })
            }
            .width('100%')
            .padding(12)
          }
          .layoutWeight(1)

          // 底部按钮栏（使用DialogButtons组件）
          DialogButtons({
            confirmText: '确认',
            cancelText: '取消',
            showCancel: true,
            confirmDisabled: false,
            onConfirm: () => {
              this.handleConfirm()
            },
            onCancel: () => {
              this.handleCancel()
            }
          })
          .width('100%')
          .padding({ left: 12, right: 12, top: 10, bottom: 12 })
        }
        .width('55%')
        .height('80%')
        .backgroundColor(getCurrentTheme().surfaceColor)
        .borderRadius(12)
        .shadow({
          radius: 20,
          color: 'rgba(0, 0, 0, 0.1)',
          offsetX: 0,
          offsetY: 4
        })
        .onClick(() => {})
      }
      .width('100%')
      .height('100%')
      .alignContent(Alignment.Center)
    }
  }

  // 构建信息行
  @Builder
  buildInfoRow(label: string, value: string) {
    Row() {
      Text(label)
                        .fontSize(18)  // 输入框字体调大到18px
        .fontColor(getCurrentTheme().subTextColor)
        .width(80)
        .textAlign(TextAlign.Start)
      
      Text(value)
                        .fontSize(18)  // 输入框字体调大到18px
        .fontColor(getCurrentTheme().textColor)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.Start)
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
    .alignItems(VerticalAlign.Center)
  }
}
