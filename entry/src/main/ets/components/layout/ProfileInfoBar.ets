import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { IBestAvatar } from '@ibestservices/ibest-ui'
import { AppleDesignStyle } from '../../utils/theme/AppleDesignStyle'

@Component
export struct ProfileInfoBar {
  // Data Props
  @Prop userName: string = '姓名'
  @Prop userRole: string = '管理员'
  @Prop currentDate: string = '2023/01/01'
  @Prop currentTime: string = '12:00:00'
  @Prop avatarUrl: string = ''
  
  // State Props
  @Prop isLoading: boolean = false
  
  // Theme
  @StorageLink('OMNI_THEME_VERSION_KEY') themeVersion: number = 0
  
  // Animation State for Skeleton
  @State shimmerTranslate: string = '-100%'
  
  // 滚动播放（Marquee）状态
  @State private scrollOffset: number = 0
  @State private needScroll: boolean = false
  private scrollAnimationId: number | null = null

  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return OmniThemeManager.getInstance().getCurrentTheme()
  }

  aboutToAppear() {
    if (this.isLoading) {
      this.startShimmerAnimation()
    }
    // 检查是否需要滚动播放
    this.checkIfNeedScroll()
  }

  aboutToDisappear() {
    // 清理滚动动画
    if (this.scrollAnimationId) {
      clearTimeout(this.scrollAnimationId)
      this.scrollAnimationId = null
    }
  }

  // 检查文本是否需要滚动播放
  private checkIfNeedScroll() {
    // 简单判断：如果用户名长度超过8个字符，就启用滚动
    if (this.userName && this.userName.length > 8) {
      this.needScroll = true
      // 延迟启动，确保UI已经渲染
      setTimeout(() => {
        this.startScrollAnimation()
      }, 500)
    } else {
      this.needScroll = false
    }
  }

  // 启动滚动动画（循环滚动）
  private startScrollAnimation() {
    if (!this.needScroll || this.scrollAnimationId !== null) {
      return
    }

    // 计算滚动距离（假设每个字符宽度约12px，滚动超出部分的宽度）
    const charWidth = 12
    const textWidth = this.userName.length * charWidth
    const containerWidth = 120 // 左侧可用宽度大约120px（260px总宽度 - 头像42px - 间距）
    const scrollDistance = textWidth - containerWidth + 20 // 额外滚动20px确保完全显示

    if (scrollDistance <= 0) {
      // 文本没有超出，不需要滚动
      this.needScroll = false
      return
    }

    // 递归动画函数
    const animate = () => {
      // 向右滚动（从0到scrollDistance）
      animateTo({
        duration: 2000,
        curve: Curve.Linear,
        onFinish: () => {
          // 滚动到底部，暂停1秒
          this.scrollAnimationId = setTimeout(() => {
            // 向左滚动回起始位置
            animateTo({
              duration: 2000,
              curve: Curve.Linear,
              onFinish: () => {
                // 回到起始位置，暂停1秒后重新开始
                this.scrollAnimationId = setTimeout(() => {
                  this.scrollAnimationId = null // 重置ID，允许重新开始
                  animate() // 重新开始动画循环
                }, 1000)
              }
            }, () => {
              this.scrollOffset = 0
            })
          }, 1000) as number // 修复：ArkTS不支持unknown类型转换，直接转为number
        }
      }, () => {
        this.scrollOffset = scrollDistance
      })
    }

    animate()
  }

  private startShimmerAnimation() {
    // Simple loop animation for shimmer
    animateTo({
      duration: 1200,
      curve: Curve.Linear,
      iterations: -1, // Infinite
      playMode: PlayMode.Normal,
    }, () => {
      this.shimmerTranslate = '100%'
    })
  }

  // 骨架屏构建器（对应 Vue .loader 结构，适配左右分离布局）
  @Builder
  SkeletonBuilder() {
    Stack() {
      // 基础结构（灰色色块）
      Row() {
        // 左侧：头像 + 个人信息
        Row() {
          // 圆形头像占位 .circle
          Row()
            .width(46)
            .height(46)
            .borderRadius(23)
            .backgroundColor('#cacaca')
            .margin({ right: 10 })

          // 姓名角色占位
          Column() {
             Row().width(60).height(14).backgroundColor('#cacaca').margin({ bottom: 8 })
             Row().width(40).height(12).backgroundColor('#cacaca')
          }
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1) // 左侧占据剩余空间
        
        // 分割线占位
        Row().width(1).height(30).backgroundColor('#d3d3d3').margin({ left: 8, right: 8 })

        // 右侧：日期时间占位
        Column() {
           Row().width(70).height(12).backgroundColor('#cacaca').margin({ bottom: 8 })
           Row().width(60).height(12).backgroundColor('#cacaca')
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .height('100%')
      .padding({ left: 10, right: 10, top: 10, bottom: 10 })
      .backgroundColor('#e3e3e3')
      .border({ width: 1, color: '#d3d3d3' })
      .alignItems(VerticalAlign.Center)

      // 流光遮罩层（对应 CSS .loader:after）
      Row()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 110,
          colors: [
            ['rgba(227, 227, 227, 0)', 0.0],
            ['rgba(227, 227, 227, 0)', 0.4],
            ['rgba(227, 227, 227, 0.5)', 0.5], // 高光部分
            ['rgba(227, 227, 227, 0)', 0.6],
            ['rgba(227, 227, 227, 0)', 1.0]
          ]
        })
        .position({ x: this.shimmerTranslate, y: 0 }) // 动画位移
    }
    .width(260) // 稍微加宽一点以适应左右布局
    .height(70)
    .clip(true)
  }

  // 正式内容构建器
  @Builder
  ContentBuilder() {
    Row() {
      // 左侧部分：头像 + (姓名/角色)
      Row() {
        // 头像
        IBestAvatar({
            src: this.avatarUrl,
            defaultAvatar: $r('app.media.default_avatar'),
            avatarSize: 42, // 稍微调小一点，适应高度
            shape: 'circle',
            onAvatarClick: () => {
              AppStorage.setOrCreate('TEMP_USER_LABEL', this.userName)
              AppStorage.setOrCreate('EDIT_USER_LABEL_VISIBLE', true)
            }
          })
          .margin({ right: 10 })

        // 姓名与角色
        Column() {
          // 姓名区域 - 支持滚动播放
          Stack() {
            Row() {
              Text(this.userName)
                .fontSize(this.getCurrentTheme().fontLevel3 ?? 24) // 24px - Name (Big)
                .fontWeight(this.getCurrentTheme().fontWeightBold ?? FontWeight.Bold)
                .fontColor(this.getCurrentTheme().textColor)
                .maxLines(1)
            }
            .translate({ x: -this.scrollOffset })
          }
          .width('100%')
          .height(26) // 调整高度以适应字体
          .clip(true) // 裁剪超出部分
          .margin({ bottom: 3 })
          .alignSelf(ItemAlign.Start) // 姓名左对齐
          .onAppear(() => {
            // 当组件出现时检查是否需要滚动
            if (!this.needScroll) {
              this.checkIfNeedScroll()
            }
          })
          
          // 管理员标签居中显示
          Row() {
            Text(this.userRole)
              .fontSize(this.getCurrentTheme().fontLevel4 ?? 18) // 18px - Role (Small)
              .fontColor(this.getCurrentTheme().primary) // 角色高亮
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .padding({ left: 6, right: 6, top: 1, bottom: 1 })
              .backgroundColor(this.getCurrentTheme().primary + '15') // 浅色背景标签
              .borderRadius(4)
          }
          .width('100%')
          .justifyContent(FlexAlign.Center) // 管理员标签居中
        }
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1) 
      }
      .layoutWeight(1) // 左侧区域自适应占满剩余空间
      .alignItems(VerticalAlign.Center)

      // 竖向分割线
      Divider()
        .vertical(true)
        .height(32)
        .color(this.getCurrentTheme().borderColor)
        .opacity(0.6)
        .margin({ left: 8, right: 8 })

      // 右侧部分：日期/时间
      Column() {
        Text(this.currentDate)
          .fontSize(this.getCurrentTheme().fontLevel4 ?? 18) // 18px
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getCurrentTheme().subTextColor)
          .margin({ bottom: 4 })
        
        Text(this.currentTime)
          .fontSize(this.getCurrentTheme().fontLevel3 ?? 24) // 24px - Time (Big)
          .fontWeight(this.getCurrentTheme().fontWeightBold ?? FontWeight.Bold)
          .fontColor(this.getCurrentTheme().textColor)
      }
      .alignItems(HorizontalAlign.End)
      .justifyContent(FlexAlign.Center)
    }
    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
    .width(260) // 固定宽度 260px，给左右布局足够空间
    .height(64) // 固定高度
    // 移除之前的 border，保持清爽，或者加上淡淡的边框和背景增加卡片感
    // .backgroundColor(this.getCurrentTheme().surfaceColor) 
    // .borderRadius(8)
    // .border({ width: 1, color: this.getCurrentTheme().borderColor + '40' })
  }

  build() {
    if (this.isLoading) {
      this.SkeletonBuilder()
    } else {
      this.ContentBuilder()
    }
  }
}
