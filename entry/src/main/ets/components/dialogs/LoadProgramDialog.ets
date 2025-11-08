/**
 * 载入程序对话框组件
 * 功能：显示程序载入界面，包含程序列表选择和载入按钮
 * 用途：在点击"载入程序"按钮时弹出
 */

import { ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { DialogButtons } from '../ui/DialogButtons'
import { DialogHeader, Padding } from '../ui/DialogHeader'

// 程序信息接口
interface ProgramInfo {
  id: string
  name: string
  description: string
  version: string
  createDate: string
  lastModified: string
}

@Component
export struct LoadProgramDialog {
  @Prop isVisible: boolean = false
  @State selectedProgram: ProgramInfo | null = null
  @State programList: ProgramInfo[] = [
    {
      id: '1',
      name: '苹果分选程序',
      description: '用于苹果自动分选的程序',
      version: 'v1.2.0',
      createDate: '2025-09-03',
      lastModified: '2024-01-20'
    },
    {
      id: '2',
      name: '橙子分选程序',
      description: '用于橙子自动分选的程序',
      version: 'v1.1.0',
      createDate: '2025-09-11',
      lastModified: '2024-01-18'
    },
    {
      id: '3',
      name: '葡萄分选程序',
      description: '用于葡萄自动分选的程序',
      version: 'v1.0.5',
      createDate: '2025-09-18',
      lastModified: '2024-01-15'
    },
    {
      id: '4',
      name: '混合分选程序',
      description: '支持多种水果混合分选的程序',
      version: 'v2.0.0',
      createDate: '2025-09-25',
      lastModified: '2024-01-28'
    }
  ]
  
  // 对话框回调
  onConfirm?: (programInfo: ProgramInfo) => void
  onCancel?: () => void

  // 选择程序
  private selectProgram(program: ProgramInfo) {
    this.selectedProgram = program
  }

  // 确认载入程序
  private handleConfirm() {
    if (this.selectedProgram && this.onConfirm) {
      this.onConfirm(this.selectedProgram)
    }
  }

  // 取消载入程序
  private handleCancel() {
    if (this.onCancel) {
      this.onCancel()
    }
  }

  build() {
    if (this.isVisible) {
      // 遮罩层
      Stack() {
        // 对话框内容
        Column() {
          // 标题栏
          DialogHeader({
            title: '加载用户配置',
            customPadding: { left: 20, right: 20, top: 15, bottom: 15 } as Padding,
            onClose: () => {
              this.handleCancel()
            }
          })

          // 程序列表内容（卡片包裹）
          Column() {
            Scroll() {
              Column() {
                ForEach(this.programList, (program: ProgramInfo) => {
                  this.buildProgramItem(program)
                })
              }
              .width('100%')
            }
            .layoutWeight(1)
            .height('50%')
          }
          .width('100%')
          .padding(20)
          .backgroundColor(getCurrentTheme().controlBg ?? getCurrentTheme().backgroundColor)
          .border({ width: 1, color: getCurrentTheme().borderColor })
          .borderRadius(8)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.08)', offsetY: 2 })

          // 底部按钮栏（使用DialogButtons组件）
          DialogButtons({
            confirmText: '载入程序',
            cancelText: '取消',
            showCancel: true,
            confirmDisabled: this.selectedProgram === null,
            onConfirm: () => {
              this.handleConfirm()
            },
            onCancel: () => {
              this.handleCancel()
            }
          })
          .width('100%')
          .padding({ left: 20, right: 20, top: 15, bottom: 20 })
        }
        .width('55%')  // 调整宽度为55%
        .height('70%')  // 调整高度为70%
        .backgroundColor(getCurrentTheme().surfaceColor)
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

  // 构建程序项
  @Builder
  buildProgramItem(program: ProgramInfo) {
    Row() {
      // 左侧选择区域
      Column() {
        // 单选按钮
        Radio({ value: program.id, group: 'programGroup' })
          .checked(this.selectedProgram?.id === program.id)
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              this.selectProgram(program)
            }
          })
      }
      .width(30)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)

      // 程序信息区域
      Column() {
        // 程序名称和版本
        Row() {
          Text(program.name)
            .fontSize(20)  // 程序名称字体调大到20px
            .fontColor(getCurrentTheme().textColor)
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
          
          Text(program.version)
            .fontSize(16)  // 版本标签字体调大到16px
            .fontColor(getCurrentTheme().subTextColor)
            .backgroundColor(getCurrentTheme().backgroundColor)
            .border({ width: 1, color: getCurrentTheme().borderColor })
            .borderRadius(4)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
        }
        .width('100%')
        .margin({ bottom: 4 })

        // 程序描述
        Text(program.description)
          .fontSize(16)  // 描述字体调大到16px
          .fontColor(getCurrentTheme().subTextColor)
          .width('100%')
          .textAlign(TextAlign.Start)
          .margin({ bottom: 8 })

        // 详细信息行
        Row() {
          this.buildInfoItem('创建日期', program.createDate)
          this.buildInfoItem('修改日期', program.lastModified)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding({ top: 12, bottom: 12, left: 8, right: 8 })
    .backgroundColor(this.selectedProgram?.id === program.id ? 
      getCurrentTheme().primary + '20' : 
      getCurrentTheme().backgroundColor)
    .border({ 
      width: this.selectedProgram?.id === program.id ? 2 : 1, 
      color: this.selectedProgram?.id === program.id ? 
        getCurrentTheme().primary : 
        getCurrentTheme().borderColor 
    })
    .borderRadius(8)
    .margin({ bottom: 8 })
    .onClick(() => {
      this.selectProgram(program)
    })
  }

  // 构建信息项
  @Builder
  buildInfoItem(label: string, value: string) {
    Column() {
      Text(label)
        .fontSize(14)  // 信息标签字体调大到14px
        .fontColor(getCurrentTheme().subTextColor)
        .margin({ bottom: 2 })
      
      Text(value)
        .fontSize(15)  // 信息值字体调大到15px
        .fontColor(getCurrentTheme().textColor)
        .fontWeight(FontWeight.Medium)
    }
    .alignItems(HorizontalAlign.Center)
  }
}
