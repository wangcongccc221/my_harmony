/**
 * 基础对话框组件
 * 功能：统一的对话框容器和布局
 * 用途：可复用的对话框基础组件
 */

import { IThemeManager, ThemeStyle } from '../../utils/theme/ThemeInterface'
import { DialogButtons } from './DialogButtons'

@Component
export struct BaseDialog {
  @Prop isVisible: boolean = false  // 是否显示
  @Prop title: string = ''  // 标题
  @Prop dialogWidth: string | Length = '80%'  // 对话框宽度（使用dialogWidth避免与组件width方法冲突）
  @Prop maxWidth: number = 500  // 最大宽度
  @Prop maxHeight: number = 600  // 最大高度
  @Prop showCancel: boolean = true  // 是否显示取消按钮
  @Prop confirmText: string = '确认'  // 确认按钮文字
  @Prop cancelText: string = '取消'  // 取消按钮文字
  @Prop confirmDisabled: boolean = false  // 确认按钮是否禁用
  
  // 主题管理器（通过参数传入）
  themeManager?: IThemeManager
  
  onConfirm?: () => void  // 确认回调
  onCancel?: () => void  // 取消回调
  onMaskClick?: () => void  // 遮罩点击回调

  // 内容插槽
  @BuilderParam content?: () => void

  private getCurrentTheme(): ThemeStyle {
    if (this.themeManager) {
      return this.themeManager.getCurrentTheme()
    }
    // 默认主题（当没有传入主题管理器时使用）
    return {
      primary: '#1890FF',
      backgroundColor: '#FFFFFF',
      surfaceColor: '#FFFFFF',
      textColor: '#000000',
      subTextColor: '#999999',
      borderColor: '#D9D9D9'
    }
  }

  build() {
    if (this.isVisible) {
      Stack() {
        // 遮罩层
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .onClick(() => {
            if (this.onMaskClick) {
              this.onMaskClick()
            }
          })
        
        // 对话框内容
        Column() {
          // 标题栏
          if (this.title) {
            Row() {
              Text(this.title)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.getCurrentTheme().textColor)
                .layoutWeight(1)
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 15, bottom: 15 })
            .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })
          }

          // 内容区域
          if (this.content) {
            this.content()
          }

          // 底部按钮
          DialogButtons({
            confirmText: this.confirmText,
            cancelText: this.cancelText,
            showCancel: this.showCancel,
            confirmDisabled: this.confirmDisabled,
            themeManager: this.themeManager,
            onConfirm: this.onConfirm,
            onCancel: this.onCancel
          })
        }
        .width(this.dialogWidth)
        .constraintSize({ maxWidth: this.maxWidth, maxHeight: this.maxHeight })
        .backgroundColor(this.getCurrentTheme().surfaceColor)
        .borderRadius(12)
        .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 4 })
        .alignSelf(ItemAlign.Center)
      }
      .width('100%')
      .height('100%')
      .alignContent(Alignment.Center)
    }
  }
}

