/**
 * BorderGrowthButton - 底部边框生长动画按钮组件
 * 
 * 特性：
 * - 常态：透明背景，主题色文字，仅底部有主题色边框
 * - Hover：鼠标悬停时边框从底部向上生长，离开时缩回
 * - Click：点击时触发回调
 * Apple Design 风格优化：更柔和的动画、圆角效果
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'
import { AppleDesignStyle } from '../../../utils/theme/AppleDesignStyle'

@Component
export struct BorderGrowthButton {
  // 按钮文字
  @Prop text: string = 'BUTTON';
  
  // 点击回调
  onClickCallback?: () => void;
  
  // 按钮尺寸（支持数字像素或百分比字符串）
  @Prop buttonWidth: number | string = 200;
  @Prop buttonHeight: number = 50;
  
  // 移除@Prop装饰器，因为在上面已经重新定义了
  // @Prop isActive: boolean = false;
  
  // 边框状态：控制边框生长动画
  @State private borderGrowth: number = 0; // 0 = 仅底部，1 = 完整边框
  
  aboutToAppear() {
    // 如果是激活状态，初始化为全边框
    if (this.isActive) {
      this.borderGrowth = 1;
    }
  }

  // 监听isActive变化
  @Watch('onActiveChange')
  @Prop isActive: boolean = false;

  private onActiveChange() {
    // 状态变为激活时，展开边框；变为非激活时，收缩边框
    // Apple风格：使用更柔和的动画
    animateTo({
      duration: 300,  // Apple风格：标准动画时长
      curve: Curve.EaseOut,  // Apple风格：缓出曲线
    }, () => {
      this.borderGrowth = this.isActive ? 1 : 0;
    });
  }
  
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
      // 文字层 - Apple风格优化
      Text(this.text)
        .fontSize(this.isActive ? 20 : 16) // 选中时字体变大
        .fontWeight(this.isActive ? FontWeight.Bold : FontWeight.Normal) // 选中时加粗
        .fontColor(this.getTextColor())
        .letterSpacing(0.5) // Apple风格：减少字间距，更紧凑
        .animation({ duration: 300, curve: Curve.EaseOut }) // 字体大小变化的动画
      
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
    // 渐变色背景 (isActive 时显示)
    .linearGradient(this.isActive ? {
      angle: 180, // 从上到下
      colors: [
        [this.getCurrentTheme().primary + '33', 0.0], // 顶部透明度约 20%
        [this.getCurrentTheme().primary + '66', 1.0]  // 底部透明度约 40%
      ]
    } : {
      angle: 180,
      colors: [[Color.Transparent, 0], [Color.Transparent, 1]]
    })
    // 毛玻璃效果 (isActive 时显示)
    .backdropBlur(this.isActive ? 20 : 0)
    .borderRadius(8) // 添加圆角以配合背景
    .scale({ x: this.isActive ? 1.3 : 1, y: this.isActive ? 1.3 : 1 }) // 选中时放大比例增大到 1.3
    .animation({ duration: 300, curve: Curve.EaseOut }) // 放大动画
    .onHover((isHover: boolean, event: HoverEvent) => {
      console.info(`[BorderGrowthButton] onHover triggered! isHover: ${isHover}`);
      
      // 如果已经是激活状态，则忽略Hover效果（保持常亮）
      if (this.isActive) {
        return;
      }

      if (isHover) {
        console.info('[BorderGrowthButton] 鼠标进入 - 开始边框生长动画');
        // 鼠标悬停 - 边框向上生长
        // Apple风格：使用更柔和的动画曲线
        animateTo({
          duration: 300,  // Apple风格：标准动画时长
          curve: Curve.EaseOut,  // Apple风格：缓出曲线，更自然
        }, () => {
          this.borderGrowth = 1;
          console.info(`[BorderGrowthButton] 边框生长完成，borderGrowth = ${this.borderGrowth}`);
        });
      } else {
        console.info('[BorderGrowthButton] 鼠标离开 - 开始边框缩回动画');
        // 鼠标离开 - 边框缩回
        animateTo({
          duration: 200,  // Apple风格：快速缩回
          curve: Curve.EaseIn,  // Apple风格：缓入曲线
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

