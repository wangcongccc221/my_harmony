/**
 * 水果信息对话框组件
 * 功能：显示水果的详细信息，包含确认和取消按钮
 * 用途：在点击"水果信息"按钮时弹出
 */

import { BaseComponentHelper } from '../common/BaseComponent'
import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { DialogButtons } from '../ui/DialogButtons'
import { RdbService, FruitInfoInsertParams, FruitInfoRow } from '../../db/RdbService'

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

@Component
export struct FruitInfoDialog {
  private baseComponentHelper = new BaseComponentHelper()
  @Prop isVisible: boolean = false
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

  // 获取当前主题配置
  getCurrentTheme(): ExtendedOmniThemeStyle {
    return this.baseComponentHelper.getCurrentTheme()
  }

  // 数字解析与边界校验（仅数字、允许小数；可配置最小/最大值）
  private parseNumberWithBounds(raw: string, minValue?: number, maxValue?: number): number {
    const cleaned: string = (raw || '').replace(/[^0-9.\-]/g, '')
    let num: number = Number(cleaned)
    if (isNaN(num)) {
      return 0
    }
    if (minValue !== undefined && num < minValue) {
      num = minValue
    }
    if (maxValue !== undefined && num > maxValue) {
      num = maxValue
    }
    return num
  }

  // 格式化数字显示（用于TextInput的text属性）
  private formatNumberForDisplay(value: number): string {
    if (value === 0 || value === undefined || isNaN(value)) {
      return ''
    }
    return String(value)
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
      const insertParams: FruitInfoInsertParams = {
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
      
      // 保存到数据库（使用upsert：存在则更新，不存在则插入）
      const id = await RdbService.upsertFruitInfo(insertParams)
      console.log('水果信息已保存到数据库，ID:', id, '通道:', lane)
      
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

  // 显示对话框时重置通道为 lane-1（index = 0），不自动加载数据
  aboutToAppear() {
    this.selectedLaneIndex = 0
    // 不清空数据，也不自动加载，等用户选择通道后再加载
  }

  // 加载指定通道的数据并填充表单
  private async loadLaneData(lane: string): Promise<void> {
    try {
      const data = await RdbService.queryFruitInfoByLane(lane)
      if (data) {
        // 如果该通道有数据，填充到表单
        this.levelText = data.level || ''
        this.diameterMm = data.diameterMm || 0
        this.weightG = data.weightG || 0
        this.projectionAreaMm2 = data.projectionAreaMm2 || 0
        this.densityKgPerM3 = data.densityKgPerM3 || 0
        this.volumeMm3 = data.volumeMm3 || 0
        this.brix = data.brix || 0
        this.color1Pct = data.color1Pct || 0
        this.acidity = data.acidity || 0
        this.color2Pct = data.color2Pct || 0
        this.drynessPct = data.drynessPct || 0
        this.color3Pct = data.color3Pct || 0
        this.maturityPct = data.maturityPct || 0
        this.defectAreaMm2 = data.defectAreaMm2 || 0
        this.pulpColorPct = data.pulpColorPct || 0
        this.defectCount = data.defectCount || 0
        this.outletText = data.outlet || ''
        this.verticalAxis = data.verticalAxis || 0
        this.horizontalRatio = data.horizontalRatio || 0
        this.flatEllipticalRatioMm = data.flatEllipticalRatioMm || 0
        console.log(`已加载通道 ${lane} 的数据`)
      } else {
        // 如果该通道没有数据，清空表单
        this.clearFormData()
        console.log(`通道 ${lane} 没有数据，表单已清空`)
      }
    } catch (error) {
      console.error(`加载通道 ${lane} 数据失败:`, error)
      // 发生错误时也清空表单
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

  build() {
    if (this.isVisible) {
      // 遮罩层
      Stack() {
        // 对话框内容
        Column() {
          // 标题栏
          Row() {
            Text('水果信息')
              .fontSize(24)  // 标题字体调大到24px
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getCurrentTheme().textColor)
              .layoutWeight(1)
            
            // 关闭按钮
            Button() {
              Text('×')
                .fontSize(24)  // 关闭按钮字体调大到24px
                .fontColor(this.getCurrentTheme().textColor)
            }
            .width(30)
            .height(30)
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.handleCancel()
            })
          }
          .width('100%')
          .padding({ left: 12, right: 12, top: 10, bottom: 10 })
          .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })

          // 内容区域（卡片栈）
          Scroll() {
            Column() {
              // 基础信息卡片：通道下拉（默认 lane-1）与右侧等级输入框
              Column() {
                Row() {
                  Text('通道')
                    .fontSize(18)  // 标签字体调大到18px
                    .fontColor(this.getCurrentTheme().textColor)
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
                    .fontColor(this.getCurrentTheme().textColor)
                    .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                    .border({ width: 1, color: this.getCurrentTheme().borderColor })
                    .borderRadius(2)  // 使用等级页面的圆角样式
                    .padding({ left: 8, right: 25, top: 3, bottom: 3 })  // 增加右侧padding，让箭头靠右
                    .layoutWeight(1)  // 添加layoutWeight，让箭头自动靠右
                    .constraintSize({ minWidth: 120, maxWidth: 220 })
                    .height(34)  // 保持水果信息页面的高度
                    .onSelect((index: number) => {
                      this.selectedLaneIndex = index
                      // 当通道改变时，自动加载该通道的数据
                      const lane = `lane-${index + 1}`
                      this.loadLaneData(lane)
                    })

                  Blank().layoutWeight(1)

                  Text('等级:')
                    .fontSize(18)  // 标签字体调大到18px
                    .fontColor(this.getCurrentTheme().textColor)
                    .margin({ right: 8 })

                  TextInput({ text: this.levelText })
                    .fontSize(18)  // 等级输入框字体调大到18px
                    .fontColor(this.getCurrentTheme().textColor)
                    .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                    .border({ width: 1, color: this.getCurrentTheme().borderColor })
                    .borderRadius(8)
                    .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                    .constraintSize({ minWidth: 120, maxWidth: 220 })
                    .height(28)
                    .onChange((val: string) => {
                      // 等级文本（如 A/B/C 或自定义）
                      this.levelText = val
                    })
                }
                .width('100%')
                .alignItems(VerticalAlign.Center)
              }
              .width('100%')
              .padding(12)
              .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
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
                    Row() {
                      Text('直径')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(72)
                        .textAlign(TextAlign.End)
                        .margin({ right: 8 })
                      TextInput({ text: this.diameterMm > 0 ? String(this.diameterMm) : '' })
                        .type(InputType.Number)
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                        .border({ width: 1, color: this.getCurrentTheme().borderColor })
                        .borderRadius(8)
                        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                        .constraintSize({ minWidth: 140, maxWidth: 180 })
                        .height(34)
                        .onChange((val: string) => {
                          // 直径(mm) 取值范围示例：0 - 1000
                          this.diameterMm = this.parseNumberWithBounds(val, 0, 1000)
                        })
                      Text('mm')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().subTextColor)
                        .margin({ left: 8 })
                    }
                    .layoutWeight(1)
                    .alignItems(VerticalAlign.Center)

                    // 右列字段
                    Row() {
                      Text('重量')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(72)
                        .textAlign(TextAlign.End)
                        .margin({ right: 8 })
                      TextInput({ text: this.formatNumberForDisplay(this.weightG) })
                        .type(InputType.Number)
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                        .border({ width: 1, color: this.getCurrentTheme().borderColor })
                        .borderRadius(8)
                        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                        .constraintSize({ minWidth: 140, maxWidth: 180 })
                        .height(34)
                        .onChange((val: string) => {
                          // 重量(g) 取值范围示例：0 - 100000
                          this.weightG = this.parseNumberWithBounds(val, 0, 100000)
                        })
                      Text('g')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().subTextColor)
                        .margin({ left: 8 })
                    }
                    .layoutWeight(1)
                    .alignItems(VerticalAlign.Center)
                  }
                  .width('100%')
                  .margin({ bottom: 10 })

                  // 投影面积(mm^2) | 密度(kg/m^3)
                  Row() {
                    Row() {
                      Text('投影面积')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(72)
                        .textAlign(TextAlign.End)
                        .margin({ right: 8 })
                      TextInput({ text: this.formatNumberForDisplay(this.projectionAreaMm2) })
                        .type(InputType.Number)
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                        .border({ width: 1, color: this.getCurrentTheme().borderColor })
                        .borderRadius(8)
                        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                        .constraintSize({ minWidth: 140, maxWidth: 180 })
                        .height(34)
                        .onChange((val: string) => {
                          this.projectionAreaMm2 = this.parseNumberWithBounds(val, 0, 100000000)
                        })
                      Text('mm^2')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().subTextColor)
                        .margin({ left: 8 })
                    }
                    .layoutWeight(1)
                    .alignItems(VerticalAlign.Center)

                    Row() {
                      Text('密度')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(72)
                        .textAlign(TextAlign.End)
                        .margin({ right: 8 })
                      TextInput({ text: this.formatNumberForDisplay(this.densityKgPerM3) })
                        .type(InputType.Number)
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                        .border({ width: 1, color: this.getCurrentTheme().borderColor })
                        .borderRadius(8)
                        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                        .constraintSize({ minWidth: 140, maxWidth: 180 })
                        .height(34)
                        .onChange((val: string) => {
                          this.densityKgPerM3 = this.parseNumberWithBounds(val, 0, 5000)
                        })
                      Text('kg/m^3')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().subTextColor)
                        .margin({ left: 8 })
                    }
                    .layoutWeight(1)
                    .alignItems(VerticalAlign.Center)
                  }
                  .width('100%')
                  .margin({ bottom: 10 })

                  // 体积(mm^3) | 糖度(brix)
                  Row() {
                    Row() {
                      Text('体积')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(72)
                        .textAlign(TextAlign.End)
                        .margin({ right: 8 })
                      TextInput({ text: this.formatNumberForDisplay(this.volumeMm3) })
                        .type(InputType.Number)
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                        .border({ width: 1, color: this.getCurrentTheme().borderColor })
                        .borderRadius(8)
                        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                        .constraintSize({ minWidth: 140, maxWidth: 180 })
                        .height(34)
                        .onChange((val: string) => {
                          this.volumeMm3 = this.parseNumberWithBounds(val, 0, 100000000)
                        })
                      Text('mm^3')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().subTextColor)
                        .margin({ left: 8 })
                    }
                    .layoutWeight(1)
                    .alignItems(VerticalAlign.Center)

                    Row() {
                      Text('糖度')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(72)
                        .textAlign(TextAlign.End)
                        .margin({ right: 8 })
                      TextInput({ text: this.formatNumberForDisplay(this.brix) })
                        .type(InputType.Number)
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                        .border({ width: 1, color: this.getCurrentTheme().borderColor })
                        .borderRadius(8)
                        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                        .constraintSize({ minWidth: 140, maxWidth: 180 })
                        .height(34)
                        .onChange((val: string) => {
                          this.brix = this.parseNumberWithBounds(val, 0, 100)
                        })
                      Text('brix')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().subTextColor)
                        .margin({ left: 8 })
                    }
                    .layoutWeight(1)
                    .alignItems(VerticalAlign.Center)
                  }
                  .width('100%')
                  .margin({ bottom: 10 })

                  // 颜色1比例(%) | 酸度(acid)
                  Row() {
                    Row() {
                      Text('颜色1比例')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(72)
                        .textAlign(TextAlign.End)
                        .margin({ right: 8 })
                      TextInput({ text: this.formatNumberForDisplay(this.color1Pct) })
                        .type(InputType.Number)
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                        .border({ width: 1, color: this.getCurrentTheme().borderColor })
                        .borderRadius(8)
                        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                        .constraintSize({ minWidth: 140, maxWidth: 180 })
                        .height(34)
                        .onChange((val: string) => {
                          this.color1Pct = this.parseNumberWithBounds(val, 0, 100)
                        })
                      Text('%')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().subTextColor)
                        .margin({ left: 8 })
                    }
                    .layoutWeight(1)
                    .alignItems(VerticalAlign.Center)

                    Row() {
                      Text('酸度')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(72)
                        .textAlign(TextAlign.End)
                        .margin({ right: 8 })
                      TextInput({ text: this.formatNumberForDisplay(this.acidity) })
                        .type(InputType.Number)
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                        .border({ width: 1, color: this.getCurrentTheme().borderColor })
                        .borderRadius(8)
                        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                        .constraintSize({ minWidth: 140, maxWidth: 180 })
                        .height(34)
                        .onChange((val: string) => {
                          this.acidity = this.parseNumberWithBounds(val, 0, 100)
                        })
                      Text('acid')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().subTextColor)
                        .margin({ left: 8 })
                    }
                    .layoutWeight(1)
                    .alignItems(VerticalAlign.Center)
                  }
                  .width('100%')
                  .margin({ bottom: 10 })

                  // 颜色2比例(%) | 枯水(%)
                  Row() {
                    Row() {
                      Text('颜色2比例')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(72)
                        .textAlign(TextAlign.End)
                        .margin({ right: 8 })
                      TextInput({ text: this.formatNumberForDisplay(this.color2Pct) })
                        .type(InputType.Number)
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                        .border({ width: 1, color: this.getCurrentTheme().borderColor })
                        .borderRadius(8)
                        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                        .constraintSize({ minWidth: 140, maxWidth: 180 })
                        .height(34)
                        .onChange((val: string) => {
                          this.color2Pct = this.parseNumberWithBounds(val, 0, 100)
                        })
                      Text('%')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().subTextColor)
                        .margin({ left: 8 })
                    }
                    .layoutWeight(1)
                    .alignItems(VerticalAlign.Center)

                    Row() {
                      Text('枯水')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(72)
                        .textAlign(TextAlign.End)
                        .margin({ right: 8 })
                      TextInput({ text: this.formatNumberForDisplay(this.drynessPct) })
                        .type(InputType.Number)
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                        .border({ width: 1, color: this.getCurrentTheme().borderColor })
                        .borderRadius(8)
                        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                        .constraintSize({ minWidth: 140, maxWidth: 180 })
                        .height(34)
                        .onChange((val: string) => {
                          this.drynessPct = this.parseNumberWithBounds(val, 0, 100)
                        })
                      Text('%')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().subTextColor)
                        .margin({ left: 8 })
                    }
                    .layoutWeight(1)
                    .alignItems(VerticalAlign.Center)
                  }
                  .width('100%')
                  .margin({ bottom: 10 })

                  // 颜色3比例(%) | 成熟度(%)
                  Row() {
                    Row() {
                      Text('颜色3比例')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(72)
                        .textAlign(TextAlign.End)
                        .margin({ right: 8 })
                      TextInput({ text: this.formatNumberForDisplay(this.color3Pct) })
                        .type(InputType.Number)
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                        .border({ width: 1, color: this.getCurrentTheme().borderColor })
                        .borderRadius(8)
                        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                        .constraintSize({ minWidth: 140, maxWidth: 180 })
                        .height(34)
                        .onChange((val: string) => {
                          this.color3Pct = this.parseNumberWithBounds(val, 0, 100)
                        })
                      Text('%')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().subTextColor)
                        .margin({ left: 8 })
                    }
                    .layoutWeight(1)
                    .alignItems(VerticalAlign.Center)

                    Row() {
                      Text('成熟度')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(72)
                        .textAlign(TextAlign.End)
                        .margin({ right: 8 })
                      TextInput({ text: this.formatNumberForDisplay(this.maturityPct) })
                        .type(InputType.Number)
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                        .border({ width: 1, color: this.getCurrentTheme().borderColor })
                        .borderRadius(8)
                        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                        .constraintSize({ minWidth: 140, maxWidth: 180 })
                        .height(34)
                        .onChange((val: string) => {
                          this.maturityPct = this.parseNumberWithBounds(val, 0, 100)
                        })
                      Text('%')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().subTextColor)
                        .margin({ left: 8 })
                    }
                    .layoutWeight(1)
                    .alignItems(VerticalAlign.Center)
                  }
                  .width('100%')
                  .margin({ bottom: 10 })

                  // 瑕疵面积(mm^2) | 果肉色(%)
                  Row() {
                    Row() {
                      Text('瑕疵面积')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(72)
                        .textAlign(TextAlign.End)
                        .margin({ right: 8 })
                      TextInput({ text: this.formatNumberForDisplay(this.defectAreaMm2) })
                        .type(InputType.Number)
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                        .border({ width: 1, color: this.getCurrentTheme().borderColor })
                        .borderRadius(8)
                        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                        .constraintSize({ minWidth: 140, maxWidth: 180 })
                        .height(34)
                        .onChange((val: string) => {
                          this.defectAreaMm2 = this.parseNumberWithBounds(val, 0, 100000000)
                        })
                      Text('mm^2')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().subTextColor)
                        .margin({ left: 8 })
                    }
                    .layoutWeight(1)
                    .alignItems(VerticalAlign.Center)

                    Row() {
                      Text('果肉色')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(72)
                        .textAlign(TextAlign.End)
                        .margin({ right: 8 })
                      TextInput({ text: this.formatNumberForDisplay(this.pulpColorPct) })
                        .type(InputType.Number)
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                        .border({ width: 1, color: this.getCurrentTheme().borderColor })
                        .borderRadius(8)
                        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                        .constraintSize({ minWidth: 140, maxWidth: 180 })
                        .height(34)
                        .onChange((val: string) => {
                          this.pulpColorPct = this.parseNumberWithBounds(val, 0, 100)
                        })
                      Text('%')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().subTextColor)
                        .margin({ left: 8 })
                    }
                    .layoutWeight(1)
                    .alignItems(VerticalAlign.Center)
                  }
                  .width('100%')
                  .margin({ bottom: 10 })

                  // 瑕疵个数(个) | 出口
                  Row() {
                    Row() {
                      Text('瑕疵个数')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(72)
                        .textAlign(TextAlign.End)
                        .margin({ right: 8 })
                      TextInput({ text: this.formatNumberForDisplay(this.defectCount) })
                        .type(InputType.Number)
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                        .border({ width: 1, color: this.getCurrentTheme().borderColor })
                        .borderRadius(8)
                        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                        .constraintSize({ minWidth: 140, maxWidth: 180 })
                        .height(34)
                        .onChange((val: string) => {
                          this.defectCount = this.parseNumberWithBounds(val, 0, 1000000)
                        })
                      Text('个')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().subTextColor)
                        .margin({ left: 8 })
                    }
                    .layoutWeight(1)
                    .alignItems(VerticalAlign.Center)

                    Row() {
                      Text('出口')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(72)
                        .textAlign(TextAlign.End)
                        .margin({ right: 8 })
                      TextInput({ text: this.outletText })
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                        .border({ width: 1, color: this.getCurrentTheme().borderColor })
                        .borderRadius(8)
                        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                        .constraintSize({ minWidth: 140, maxWidth: 180 })
                        .height(34)
                        .onChange((val: string) => {
                          // 出口编号或名称可为文本
                          this.outletText = val
                        })
                    }
                    .layoutWeight(1)
                    .alignItems(VerticalAlign.Center)
                  }
                  .width('100%')
                  .margin({ bottom: 10 })

                  // 垂轴径 | 横径比
                  Row() {
                    Row() {
                      Text('垂轴径')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(72)
                        .textAlign(TextAlign.End)
                        .margin({ right: 8 })
                      TextInput({ text: this.formatNumberForDisplay(this.verticalAxis) })
                        .type(InputType.Number)
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                        .border({ width: 1, color: this.getCurrentTheme().borderColor })
                        .borderRadius(8)
                        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                        .constraintSize({ minWidth: 140, maxWidth: 180 })
                        .height(34)
                        .onChange((val: string) => {
                          this.verticalAxis = this.parseNumberWithBounds(val, 0, 1000000)
                        })
                    }
                    .layoutWeight(1)
                    .alignItems(VerticalAlign.Center)

                    Row() {
                      Text('横径比')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(72)
                        .textAlign(TextAlign.End)
                        .margin({ right: 8 })
                      TextInput({ text: this.formatNumberForDisplay(this.horizontalRatio) })
                        .type(InputType.Number)
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                        .border({ width: 1, color: this.getCurrentTheme().borderColor })
                        .borderRadius(8)
                        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                        .constraintSize({ minWidth: 140, maxWidth: 180 })
                        .height(34)
                        .onChange((val: string) => {
                          // 比例类一般 0-100 或 0-10，根据实际调整
                          this.horizontalRatio = this.parseNumberWithBounds(val, 0, 100)
                        })
                    }
                    .layoutWeight(1)
                    .alignItems(VerticalAlign.Center)
                  }
                  .width('100%')
                  .margin({ bottom: 10 })

                  // 扁椭型横径比(mm) | 空列占位（保持网格对齐）
                  Row() {
                    Row() {
                      Text('扁椭型横径比')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(72)
                        .textAlign(TextAlign.End)
                        .margin({ right: 8 })
                      TextInput({ text: this.formatNumberForDisplay(this.flatEllipticalRatioMm) })
                        .type(InputType.Number)
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().textColor)
                        .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                        .border({ width: 1, color: this.getCurrentTheme().borderColor })
                        .borderRadius(8)
                        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                        .constraintSize({ minWidth: 140, maxWidth: 180 })
                        .height(34)
                        .onChange((val: string) => {
                          this.flatEllipticalRatioMm = this.parseNumberWithBounds(val, 0, 1000000)
                        })
                      Text('mm')
                        .fontSize(18)  // 标签字体调大到18px
                        .fontColor(this.getCurrentTheme().subTextColor)
                        .margin({ left: 8 })
                    }
                    .layoutWeight(1)
                    .alignItems(VerticalAlign.Center)

                    Blank().layoutWeight(1)
                  }
                  .width('100%')
                }
                .width('100%')
                .padding(12)
                .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                .border({ width: 1, color: this.getCurrentTheme().borderColor })
                .borderRadius(8)
              }
              .width('100%')
              .padding(16)
              .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
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
        .backgroundColor(this.getCurrentTheme().surfaceColor)
        .borderRadius(12)
        .shadow({
          radius: 20,
          color: 'rgba(0, 0, 0, 0.1)',
          offsetX: 0,
          offsetY: 4
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('rgba(0, 0, 0, 0.5)')
      .alignContent(Alignment.Center)
      .onClick(() => {
        // 点击遮罩层关闭对话框
        this.handleCancel()
      })
    }
  }

  // 构建信息行
  @Builder
  buildInfoRow(label: string, value: string) {
    Row() {
      Text(label)
                        .fontSize(18)  // 输入框字体调大到18px
        .fontColor(this.getCurrentTheme().subTextColor)
        .width(80)
        .textAlign(TextAlign.Start)
      
      Text(value)
                        .fontSize(18)  // 输入框字体调大到18px
        .fontColor(this.getCurrentTheme().textColor)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.Start)
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
    .alignItems(VerticalAlign.Center)
  }
}
