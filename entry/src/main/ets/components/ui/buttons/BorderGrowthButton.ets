/**
 * BorderGrowthButton - 底部边框生长动画按钮组件
 * 
 * 特性：
 * - 常态：透明背景，主题色文字，仅底部有主题色边框
 * - Hover：鼠标悬停时边框从底部向上生长，离开时缩回
 * - Click：点击时触发回调
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'

@Component
export struct BorderGrowthButton {
  // 按钮文字
  @Prop text: string = 'BUTTON';
  
  // 点击回调
  onClickCallback?: () => void;
  
  // 按钮尺寸（支持数字像素或百分比字符串）
  @Prop buttonWidth: number | string = 200;
  @Prop buttonHeight: number = 50;
  
  // 是否选中状态
  @Prop isActive: boolean = false;
  
  // 边框状态：控制边框生长动画
  @State private borderGrowth: number = 0; // 0 = 仅底部，1 = 完整边框
  
  // 获取当前主题
  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return OmniThemeManager.getInstance().getCurrentTheme()
  }
  
  // 获取边框颜色（转换为字符串）
  private getBorderColor(): string {
    const color = this.isActive ? this.getCurrentTheme().primary : this.getCurrentTheme().borderColor
    // 确保返回字符串类型
    if (typeof color === 'string') {
      return color
    } else {
      // 如果是数字或Color，转换为字符串
      return String(color)
    }
  }
  
  // 获取文字颜色
  private getTextColor(): string | Color {
    return this.isActive ? this.getCurrentTheme().primary : this.getCurrentTheme().textColor
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 文字层
      Text(this.text)
        .fontSize(16)
        .fontWeight(700)
        .fontColor(this.getTextColor())
        .letterSpacing(1.5)
      
      // 边框层 - 使用 Column 和 Row 来绘制边框
      Column() {
        // 顶部边框
        Row()
          .width('100%')
          .height(2)
          .backgroundColor(this.getBorderColor() as string | Color)
          .opacity(this.borderGrowth)
        
        // 中间区域（左右边框）
        Row() {
          // 左边框
          Column()
            .width(2)
            .height(this.borderGrowth * (this.buttonHeight - 4))
            .backgroundColor(this.getBorderColor() as string | Color)
          
          Blank()
          
          // 右边框
          Column()
            .width(2)
            .height(this.borderGrowth * (this.buttonHeight - 4))
            .backgroundColor(this.getBorderColor() as string | Color)
        }
        .width('100%')
        .height(this.buttonHeight - 4)
        .justifyContent(FlexAlign.SpaceBetween)
        
        // 底部边框 - 始终显示
        Row()
          .width('100%')
          .height(2)
          .backgroundColor(this.getBorderColor() as string | Color)
      }
      .width(typeof this.buttonWidth === 'string' ? this.buttonWidth : this.buttonWidth)
      .height(this.buttonHeight)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width(typeof this.buttonWidth === 'string' ? this.buttonWidth : this.buttonWidth)
    .height(this.buttonHeight)
    .backgroundColor(Color.Transparent)
    .onHover((isHover: boolean, event: HoverEvent) => {
      console.info(`[BorderGrowthButton] onHover triggered! isHover: ${isHover}`);
      
      if (isHover) {
        console.info('[BorderGrowthButton] 鼠标进入 - 开始边框生长动画');
        // 鼠标悬停 - 边框向上生长
        // 使用自定义贝塞尔曲线，让动画更丝滑
        animateTo({
          duration: 500,  // 稍微延长到 0.5 秒，让动画更流畅
          curve: Curve.FastOutSlowIn,  // 快进慢出，更自然
          // 或使用自定义贝塞尔曲线：curves.cubicBezierCurve(0.25, 0.1, 0.25, 1)
        }, () => {
          this.borderGrowth = 1;
          console.info(`[BorderGrowthButton] 边框生长完成，borderGrowth = ${this.borderGrowth}`);
        });
      } else {
        console.info('[BorderGrowthButton] 鼠标离开 - 开始边框缩回动画');
        // 鼠标离开 - 边框缩回
        animateTo({
          duration: 250,  // 稍微延长缩回时间，避免太突兀
          curve: Curve.FastOutSlowIn,  // 使用相同曲线保持一致性
        }, () => {
          this.borderGrowth = 0;
          console.info(`[BorderGrowthButton] 边框缩回完成，borderGrowth = ${this.borderGrowth}`);
        });
      }
    })
    .onClick(() => {
      console.info('[BorderGrowthButton] onClick triggered!');
      // 触发点击回调
      if (this.onClickCallback) {
        this.onClickCallback();
      }
    })
  }
}

