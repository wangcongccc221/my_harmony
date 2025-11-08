/**
 * 保存程序对话框组件
 * 功能：显示程序保存界面，包含程序信息输入和保存功能
 * 用途：在点击"保存程序"按钮时弹出
 */

import { ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { DialogButtons } from '../ui/dialogs/DialogButtons'
import { DialogHeader, Padding } from '../ui/dialogs/DialogHeader'
import { FormTextField } from '../ui/forms/FormTextField'
import { FormTextArea } from '../ui/forms/FormTextArea'

// 保存用户配置信息接口
interface SaveProgramInfo {
  name: string
  description: string
  tags: string
}

@Component
export struct SaveProgramDialog {
  @Prop isVisible: boolean = false
  @State programInfo: SaveProgramInfo = {
    name: '',
    description: '',
    tags: ''
  }
  
  // 版本/分类已移除，仅保留名称、描述、标签三项
  
  // 对话框回调
  onConfirm?: (programInfo: SaveProgramInfo) => void
  onCancel?: () => void

  // 确认保存程序
  private handleConfirm() {
    if (!this.programInfo.name.trim()) {
      // 可以添加错误提示
      return
    }
    
    if (this.onConfirm) {
      this.onConfirm(this.programInfo)
    }
  }

  // 取消保存程序
  private handleCancel() {
    if (this.onCancel) {
      this.onCancel()
    }
  }

  // 重置表单
  private resetForm() {
    this.programInfo = {
      name: '',
      description: '',
      tags: ''
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
            title: '保存用户配置',
            customPadding: { left: 20, right: 20, top: 15, bottom: 15 } as Padding,
            onClose: () => {
              this.handleCancel()
            }
          })

          // 用户配置输入内容
          Scroll() {
            Column() {
              // 卡片包裹三项：配置名称、配置描述、标签
              Column() {
                // 配置名称
                FormTextField({
                  config: {
                    label: '配置名称',
                    value: this.programInfo.name,
                    required: true
                  },
                  onTextChange: (value: string) => {
                    this.programInfo.name = value
                  }
                })

                // 配置描述
                FormTextArea({
                  config: {
                    label: '配置描述',
                    value: this.programInfo.description
                  },
                  onTextChange: (value: string) => {
                    this.programInfo.description = value
                  }
                })

                // 标签
                FormTextField({
                  config: {
                    label: '标签',
                    value: this.programInfo.tags
                  },
                  onTextChange: (value: string) => {
                    this.programInfo.tags = value
                  }
                })
              }
              .width('100%')
              .padding(12)
              .backgroundColor(getCurrentTheme().controlBg ?? getCurrentTheme().backgroundColor)
              .border({ width: 1, color: getCurrentTheme().borderColor })
              .borderRadius(8)
              .alignItems(HorizontalAlign.Start)
              
            }
            .width('100%')
            .padding(20)
            .alignItems(HorizontalAlign.Start)
          }
          .layoutWeight(1)
          .height('50%')

          // 底部按钮栏（使用DialogButtons组件）
          DialogButtons({
            confirmText: '保存配置',
            cancelText: '取消',
            showCancel: true,
            confirmDisabled: this.programInfo.name.trim() === '',
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
        .height('80%')  // 调整高度为80%
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


  // 构建选择字段
  @Builder
  buildSelectField(label: string, options: string[], selectedIndex: number, onSelect: (index: number) => void) {
    Column() {
      Text(label)
        .fontSize(18)  // 选择字段标签字体调大到18px
        .fontColor(getCurrentTheme().textColor)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ bottom: 8 })
      
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(options, (option: string, index: number) => {
          Button(option)
            .fontSize(18)  // 按钮字体调大到18px
            .fontColor(selectedIndex === index ? Color.White : getCurrentTheme().textColor)
            .backgroundColor(selectedIndex === index ? getCurrentTheme().primary : getCurrentTheme().backgroundColor)
            .border({ width: 1, color: getCurrentTheme().borderColor })
            .borderRadius(6)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .margin({ right: 8 })
            .onClick(() => {
              onSelect(index)
            })
        })
      }
      .width('100%')
    }
    .width('100%')
    .margin({ bottom: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  // 构建预览区域
  @Builder
  buildPreviewSection() {
    Column() {
      Text('保存信息预览')
        .fontSize(18)  // 预览标题字体调大到18px
        .fontColor(getCurrentTheme().textColor)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ bottom: 8 })
      
      Column() {
        this.buildPreviewItem('配置名称', this.programInfo.name || '未填写')
        this.buildPreviewItem('标签', this.programInfo.tags || '无')
        this.buildPreviewItem('配置描述', this.programInfo.description || '无')
      }
      .width('100%')
      .padding(12)
      .backgroundColor(getCurrentTheme().backgroundColor)
      .border({ width: 1, color: getCurrentTheme().borderColor })
      .borderRadius(6)
    }
    .width('100%')
    .margin({ bottom: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  // 构建预览项
  @Builder
  buildPreviewItem(label: string, value: string) {
    Row() {
      Text(label + ':')
        .fontSize(16)  // 预览标签字体调大到16px
        .fontColor(getCurrentTheme().subTextColor)
        .width(60)
        .textAlign(TextAlign.Start)
      
      Text(value)
        .fontSize(16)  // 预览值字体调大到16px
        .fontColor(getCurrentTheme().textColor)
        .layoutWeight(1)
        .textAlign(TextAlign.Start)
    }
    .width('100%')
    .margin({ bottom: 4 })
    .alignItems(VerticalAlign.Center)
  }
}
