/**
 * Apple Design 风格样式工具类
 * 功能：提供统一的 Apple Design 风格样式常量和方法
 * 用途：统一管理圆角、阴影、背景模糊等 Apple Design 风格的视觉样式
 */

/**
 * Apple Design 风格样式配置
 */
export class AppleDesignStyle {
  // ==================== 圆角配置 ====================
  // Apple Design 使用更大更柔和的圆角
  
  /** 小圆角 - 用于按钮、输入框等小元素 */
  static readonly BORDER_RADIUS_SMALL: number = 8
  
  /** 中等圆角 - 用于卡片、容器等中等元素 */
  static readonly BORDER_RADIUS_MEDIUM: number = 12
  
  /** 大圆角 - 用于大卡片、对话框等大元素 */
  static readonly BORDER_RADIUS_LARGE: number = 16
  
  /** 超大圆角 - 用于大型对话框、模态窗口 */
  static readonly BORDER_RADIUS_XLARGE: number = 20
  
  /** 圆形 - 用于头像、图标等 */
  static readonly BORDER_RADIUS_CIRCLE: number = 999
  
  // ==================== 阴影配置 ====================
  // Apple Design 使用柔和、多层阴影效果
  
  /**
   * 小阴影 - 用于按钮、小卡片等
   */
  static getShadowSmall(color: string = 'rgba(0, 0, 0, 0.1)'): ShadowOptions {
    return {
      radius: 8,
      color: color,
      offsetX: 0,
      offsetY: 2
    }
  }
  
  /**
   * 中等阴影 - 用于卡片、容器等
   */
  static getShadowMedium(color: string = 'rgba(0, 0, 0, 0.12)'): ShadowOptions {
    return {
      radius: 12,
      color: color,
      offsetX: 0,
      offsetY: 4
    }
  }
  
  /**
   * 大阴影 - 用于对话框、模态窗口等
   */
  static getShadowLarge(color: string = 'rgba(0, 0, 0, 0.15)'): ShadowOptions {
    return {
      radius: 20,
      color: color,
      offsetX: 0,
      offsetY: 8
    }
  }
  
  /**
   * 超大阴影 - 用于大型对话框、浮动窗口
   */
  static getShadowXLarge(color: string = 'rgba(0, 0, 0, 0.2)'): ShadowOptions {
    return {
      radius: 30,
      color: color,
      offsetX: 0,
      offsetY: 10
    }
  }
  
  /**
   * 双层阴影 - 创新效果，用于重要卡片
   */
  static getDoubleShadow(primaryColor: string = 'rgba(0, 0, 0, 0.12)', secondaryColor: string = 'rgba(0, 0, 0, 0.08)'): ShadowOptions[] {
    return [
      {
        radius: 20,
        color: primaryColor,
        offsetX: 0,
        offsetY: 6
      },
      {
        radius: 10,
        color: secondaryColor,
        offsetX: 0,
        offsetY: 2
      }
    ]
  }
  
  // ==================== 背景模糊配置 ====================
  // Apple Design 使用背景模糊效果（毛玻璃效果）
  
  /** 背景模糊样式 - 轻微模糊 */
  static readonly BLUR_STYLE_LIGHT: BlurStyle = BlurStyle.Thin
  
  /** 背景模糊样式 - 中等模糊 */
  static readonly BLUR_STYLE_MEDIUM: BlurStyle = BlurStyle.Regular
  
  /** 背景模糊样式 - 强烈模糊 */
  static readonly BLUR_STYLE_STRONG: BlurStyle = BlurStyle.Thick
  
  // ==================== 遮罩透明度 ====================
  
  /** 轻微遮罩 */
  static readonly OVERLAY_LIGHT: string = 'rgba(0, 0, 0, 0.2)'
  
  /** 中等遮罩 */
  static readonly OVERLAY_MEDIUM: string = 'rgba(0, 0, 0, 0.4)'
  
  /** 强烈遮罩 */
  static readonly OVERLAY_STRONG: string = 'rgba(0, 0, 0, 0.6)'
  
  // ==================== 边框配置 ====================
  // Apple Design 使用更细更柔和的边框
  
  /** 细边框宽度 */
  static readonly BORDER_WIDTH_THIN: number = 0.5
  
  /** 标准边框宽度 */
  static readonly BORDER_WIDTH_NORMAL: number = 1
  
  /** 中等边框宽度 */
  static readonly BORDER_WIDTH_MEDIUM: number = 1.5
  
  /** 粗边框宽度 */
  static readonly BORDER_WIDTH_THICK: number = 2
  
  // ==================== 间距配置 ====================
  // Apple Design 使用更宽松、更规律的间距
  
  /** 小间距 */
  static readonly SPACING_XS: number = 4
  
  /** 小间距 */
  static readonly SPACING_SMALL: number = 8
  
  /** 中等间距 */
  static readonly SPACING_MEDIUM: number = 12
  
  /** 大间距 */
  static readonly SPACING_LARGE: number = 16
  
  /** 超大间距 */
  static readonly SPACING_XLARGE: number = 20
  
  /** 特大间距 */
  static readonly SPACING_XXLARGE: number = 24
  
  // ==================== 过渡动画配置 ====================
  // Apple Design 使用流畅的过渡动画
  
  /**
   * 快速过渡动画 - 用于快速交互
   */
  static getTransitionFast(): TransitionEffect {
    return TransitionEffect.OPACITY.animation({ duration: 150, curve: Curve.EaseOut })
  }
  
  /**
   * 标准过渡动画 - 用于一般交互
   */
  static getTransitionNormal(): TransitionEffect {
    return TransitionEffect.OPACITY.animation({ duration: 250, curve: Curve.EaseInOut })
  }
  
  /**
   * 慢速过渡动画 - 用于重要交互
   */
  static getTransitionSlow(): TransitionEffect {
    return TransitionEffect.OPACITY.animation({ duration: 350, curve: Curve.EaseOut })
  }
  
  /**
   * 移动过渡动画 - 用于元素移动
   */
  static getTransitionMove(edge: TransitionEdge = TransitionEdge.BOTTOM): TransitionEffect {
    return TransitionEffect.move(edge).animation({ duration: 350, curve: Curve.EaseOut })
  }
  
  // ==================== 创新样式配置 ====================
  // 更现代的视觉效果
  
  /**
   * 渐变背景色 - 用于卡片背景（浅色到透明）
   */
  static getGradientBackground(startColor: string, endColor: string = 'rgba(255, 255, 255, 0)'): ResourceColor {
    // 注意：HarmonyOS中渐变需要使用LinearGradient，这里返回基础色
    return startColor as ResourceColor
  }
  
  /**
   * 卡片内边距 - 合理的内边距
   */
  static readonly CARD_PADDING_SMALL: number = 12
  static readonly CARD_PADDING_MEDIUM: number = 14
  static readonly CARD_PADDING_LARGE: number = 16
  
  /**
   * 卡片间距 - 合理的卡片间距
   */
  static readonly CARD_MARGIN_SMALL: number = 10
  static readonly CARD_MARGIN_MEDIUM: number = 12
  static readonly CARD_MARGIN_LARGE: number = 16
}

