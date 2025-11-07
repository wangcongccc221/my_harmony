import { OmniTheme, OmniThemeStyle } from "../../theme/OmniTheme"

const defaultUnactivatedLineColor = '#999999'
const defaultDoingIcon = $r('app.media.icon_step_doing')
const defaultCompletedIcon = $r('app.media.icon_step_completed')
const defaultActivatedTitleColor = '#333333'
const defaultUnactivatedTitleColor = '#999999'
const defaultHorizontalLineLength = 78
const defaultVerticalLineLength = 65

@Component
export struct OmniSteps {
  @StorageLink(OmniTheme.KEY)
  baseStyle: OmniThemeStyle = OmniTheme.getDefaultStyle()
  @Prop config: OmniStepsConfig
  //横向steps样式
  horizontalStepsStyle: OmniHorizontalStepsStyle = {
    doingIcon: defaultDoingIcon,
    completedIcon: defaultCompletedIcon,
    unactivatedLineColor: defaultUnactivatedLineColor,
    activatedLineColor: this.baseStyle.primary,
    unactivatedTitleColor: defaultUnactivatedTitleColor,
    activatedTitleColor: defaultActivatedTitleColor,
    lineLength: defaultHorizontalLineLength,
    iconColor: this.baseStyle.primary,
  }
  //纵向steps样式
  verticalStepsStyle: OmniVerticalStepsStyle = {
    activatedNodeColor: this.baseStyle.primary,
    unactivatedNodeColor: defaultUnactivatedLineColor,
    unactivatedLineColor: defaultUnactivatedLineColor,
    activatedLineColor: this.baseStyle.primary,
    unactivatedTitleColor: defaultUnactivatedTitleColor,
    activatedTitleColor: defaultActivatedTitleColor,
    unactivatedDescColor: defaultUnactivatedTitleColor,
    activatedDescColor: defaultUnactivatedTitleColor,
    lineLength: defaultVerticalLineLength
  }

  aboutToAppear(): void {
    //限制最多5个，不然展示不下
    if (this.config.steps.length > 5) {
      this.config.stepsCount = 5
      this.config.steps = this.config.steps.slice(0, 5)
    }
  }

  //取当前step的icon，通过状态区分
  _getIcon(step: OmniStepItemConfig, index: number): ResourceStr {
    const s = step.state
    let icon: ResourceStr
    switch (s) {
      case OmniStepState.Doing:
        //优先取数据的，没有取默认配置的
        if (step.doingIcon) {
          icon = step.doingIcon
        } else {
          icon = this.horizontalStepsStyle.doingIcon
        }
        break
      case OmniStepState.Completed:
        //优先取数据的，没有取默认配置的
        if (step.completedIcon) {
          icon = step.completedIcon
        } else {
          icon = this.horizontalStepsStyle.completedIcon
        }
        break
      default:
        icon = this._getIndexIcon(index)
        break
    }
    return icon
  }

  //获取未开始的index步骤
  _getIndexIcon(index: number) {
    if (index != 0) {
      return $r(`app.media.icon_step_${index + 1}`)
    }
    return this.horizontalStepsStyle.doingIcon
  }

  //获取画线的颜色
  _getLineColor(index: number, isLeft: boolean): ResourceColor {
    if (index < this.config.currentIndex) {
      return this.horizontalStepsStyle.activatedLineColor
    } else if (index === this.config.currentIndex && isLeft) {
      return this.horizontalStepsStyle.activatedLineColor
    }
    return this.horizontalStepsStyle.unactivatedLineColor
  }

  //取标题颜色
  _getTitleColor(index: number): ResourceColor {
    if (index <= this.config.currentIndex) {
      return this.horizontalStepsStyle.activatedTitleColor
    } else {
      return this.horizontalStepsStyle.unactivatedTitleColor
    }
  }

  @Builder
  _buildHorizontalSteps() {
    Flex({ alignContent: FlexAlign.SpaceBetween, wrap: FlexWrap.NoWrap, alignItems: ItemAlign.Start }) {
      ForEach(this.config.steps.slice(0, this.config.stepsCount), (step: OmniStepItemConfig, index: number) => {
        Column() {
          Flex({ wrap: FlexWrap.NoWrap, alignContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {

            if (index != 0) {
              Divider()
                .padding({
                  left: 0,
                  right: 5
                })
                .color(this._getLineColor(index, true))
                .strokeWidth(1)
                .borderRadius({
                  topLeft: 1,
                  bottomLeft: 1
                })
                .flexGrow(1)
                .layoutWeight(1)
            } else {
              Row()
                .flexShrink(0)
                .flexGrow(1)
                .layoutWeight(1)
            }

            Image(this._getIcon(step, index))
              .width(16)
              .height(16)
              .flexShrink(0)
              .flexGrow(1)
              .fillColor(this.horizontalStepsStyle.iconColor)

            if (index != this.config.stepsCount - 1) {
              Divider()
                .padding({
                  left: 5,
                  right: 0
                })
                .color(this._getLineColor(index, false))
                .strokeWidth(1)
                .borderRadius({
                  topRight: 1,
                  bottomRight: 1
                })
                .flexGrow(1)
                .layoutWeight(1)
            } else {
              Row()
                .flexShrink(0)
                .flexGrow(1)
                .layoutWeight(1)
            }
          }
          .width('100%')

          Text(step.title)
            .fontSize(12)
            .margin({
              top: 3
            })
            .fontColor(this._getTitleColor(index))
        }.layoutWeight(1)
      })
    }.width('100%')
    .height(78)
    .align(Alignment.Center)
  }

  /**
   * 纵向step的选中节点
   */
  @Builder
  _verticalStepsSelectedNode() {
    Stack() {
      Circle()
        .fill(this.verticalStepsStyle.activatedNodeColor)
        .width(12)
        .height(12)
        .opacity(0.2)

      Circle()
        .fill(this.verticalStepsStyle.activatedNodeColor)
        .width(8)
        .height(8)
    }.alignContent(Alignment.Center)
  }

  /**
   * 纵向step的未选中节点
   */
  @Builder
  _verticalStepsUnSelectedNode() {
    Stack() {
      Circle()
        .fill(Color.Transparent)
        .width(12)
        .height(12)
      Circle()
        .fill(this.verticalStepsStyle.unactivatedNodeColor)
        .width(8)
        .height(8)
        .opacity(0.5)
    }.alignContent(Alignment.Center)
  }

  @Builder
  _buildVerticalSteps() {
    Column() {
      List() {
        ForEach(this.config.steps.slice(0, this.config.stepsCount), (step: OmniStepItemConfig, index: number) => {
          ListItem() {
            Row() {
              //左边 node+line
              Column() {
                if (index <= this.config.currentIndex) {
                  this._verticalStepsSelectedNode()
                } else {
                  this._verticalStepsUnSelectedNode()
                }

                if (index != this.config.stepsCount - 1) {
                  Divider()
                    .vertical(true)
                    .padding({
                      top: 5,
                      bottom: 5
                    })
                    .height(65)
                    .strokeWidth(1)
                    .color(index < this.config.currentIndex ? this.verticalStepsStyle.activatedLineColor :
                    this.verticalStepsStyle.unactivatedLineColor)
                }
              }.alignItems(HorizontalAlign.Center)

              //右边title+desc
              Column() {
                Text(step.title)
                  .fontColor(index <= this.config.currentIndex ? this.verticalStepsStyle.activatedTitleColor :
                  this.verticalStepsStyle.unactivatedTitleColor)
                  .fontSize(14)

                Text(step.desc ?? '').margin({
                  top: 10
                }).fontColor(this.verticalStepsStyle.unactivatedTitleColor)
                  .fontSize(13)
              }.justifyContent(FlexAlign.Start)
              .padding({
                left: 8
              })
              .alignItems(HorizontalAlign.Start)
            }.alignItems(VerticalAlign.Top)
          }
        })
      }
    }
  }

  build() {
    if (this.config.stepsType == OmniStepsType.Horizontal) {
      this._buildHorizontalSteps()
    } else {
      this._buildVerticalSteps()
    }
  }
}

export interface OmniStepsConfig {
  stepsType: OmniStepsType //横or竖
  stepsCount: number //步骤数量
  steps: OmniStepItemConfig[] //步骤
  currentIndex: number //当前步骤下标
}

export interface OmniStepsStyle {
  horizontalStyle: OmniHorizontalStepsStyle
  verticalStyle: OmniVerticalStepsStyle
}

export interface OmniHorizontalStepsStyle {
  doingIcon: ResourceStr //进行中图标
  completedIcon: ResourceStr //已完成图标
  unactivatedLineColor: ResourceColor //未激活线颜色
  activatedLineColor: ResourceColor //已激活线颜色
  unactivatedTitleColor: ResourceColor //未激活文本颜色
  activatedTitleColor: ResourceColor //已激活文本颜色
  lineLength : Length //线的长度
  iconColor: ResourceColor //icon主题色
}

export interface OmniVerticalStepsStyle {
  activatedNodeColor: ResourceColor //已激活节点颜色
  unactivatedNodeColor: ResourceColor //未激活节点颜色
  unactivatedLineColor: ResourceColor //未激活线颜色
  activatedLineColor: ResourceColor //已激活线颜色
  unactivatedTitleColor: ResourceColor //未激活文本颜色
  activatedTitleColor: ResourceColor //已激活文本颜色
  unactivatedDescColor: ResourceColor //未激活辅助信息颜色
  activatedDescColor: ResourceColor //已激活辅助信息颜色
  lineLength : Length //线的长度
}

export interface OmniStepItemConfig {
  state: OmniStepState //状态
  title: string //文案
  desc?: string //辅助信息
  doingIcon?: ResourceStr //进行中图标，单独对某一个item设置
  completedIcon?: ResourceStr //已完成图标，单独对某一个item设置
}

export enum OmniStepsType {
  Horizontal,
  Vertical
}

export enum OmniStepState {
  Indexed, //未开始
  Doing, //进行中
  Completed, //已完成
}