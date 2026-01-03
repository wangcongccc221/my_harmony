import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { t, I18N_VERSION_KEY } from '../../utils/i18n/I18nManager'

// 报警信息接口
interface AlarmItem {
  category: string      // 类别
  code: string         // 代码
  module: string       // 模块
  message: string      // 信息
  status: string       // 状态
  startTime: string    // 开始时间
  endTime: string      // 结束时间
}

@Component
export struct AlarmInfoDialog {
  @Prop isVisible: boolean = false
  @StorageLink(OMNI_THEME_KEY) @Watch('onThemeChange') consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_VERSION_KEY) @Watch('onThemeChange') themeVersion: number = 0
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0

  // 模拟数据（仅用于UI展示）
  @State alarmList: AlarmItem[] = [
    { category: '系统', code: '26', module: '', message: '子系统1通道2,杯重异常', status: '已修复', startTime: '2025/12/5 9:05:34', endTime: '2025/12/5 9:05:35' },
    { category: '系统', code: '28', module: '', message: '子系统1通道4,杯重异常', status: '已修复', startTime: '2025/12/5 9:05:34', endTime: '2025/12/5 9:05:35' },
    { category: '系统', code: '121', module: '', message: '子系统1通道1,IQM通信故障', status: '已修复', startTime: '2025/12/4 10:20:15', endTime: '2025/12/4 10:25:30' },
    { category: '系统', code: '50', module: '', message: 'SCM 1与FSM连接失败,立即检查', status: '故障中', startTime: '2025/12/5 14:30:00', endTime: '' },
    { category: '系统', code: '50', module: '', message: 'SCM 20与FSM连接失败,立即检查', status: '故障中', startTime: '2025/12/5 14:32:15', endTime: '' }
  ]

  // 查询条件
  @State startDate: string = '2025-11-25'
  @State endDate: string = '2025-12-25'
  @State messageQuery: string = ''
  @State selectedIndex: number = -1  // 选中的行索引

  // 对话框回调
  onCancel?: () => void

  // 获取当前主题配置
  getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.consumedTheme)
  }

  // 监听主题变化
  onThemeChange(): void {
    console.log('AlarmInfoDialog: 主题已变化，重新渲染')
  }

  // 查询按钮点击
  private handleQuery(): void {
    console.log('查询报警信息', {
      startDate: this.startDate,
      endDate: this.endDate,
      message: this.messageQuery
    })
    // TODO: 数据查询逻辑由外部实现
  }

  // 关闭按钮点击
  private handleCancel(): void {
    if (this.onCancel) {
      this.onCancel()
    }
  }

  build() {
    // 对话框遮罩层
    Stack() {
      if (!this.isVisible) {
        // 不可见时返回空内容
        Blank()
      } else {
        // 背景遮罩
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .onClick(() => {
            this.handleCancel()
          })

        // 对话框内容
        Column() {
          // 标题栏（深绿色背景）
          Row() {
            Text('报警信息')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .layoutWeight(1)
              .textAlign(TextAlign.Start)
              .margin({ left: 12 })

            Button() {
              Text('×')
                .fontSize(20)
                .fontColor(Color.White)
            }
            .type(ButtonType.Normal)
            .backgroundColor('transparent')
            .width(28)
            .height(28)
            .onClick(() => {
              this.handleCancel()
            })
          }
          .width('100%')
          .height(40)
          .padding({ left: 0, right: 12 })
          .backgroundColor('#2E7D32')
          .borderRadius({ topLeft: 8, topRight: 8 })

          // 内容区域
          Row() {
            // 左侧：表格和查询区域
            Column({ space: 0 }) {
              // 固定表头（绿色背景）- 置顶显示
              Row() {
                Text('类别')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
                  .width(80)
                  .textAlign(TextAlign.Center)
                  .padding({ top: 8, bottom: 8 })
                  .border({ width: 0.5, color: '#1B5E20' })
                  .backgroundColor('#4CAF50')

                Text('代码')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
                  .width(60)
                  .textAlign(TextAlign.Center)
                  .padding({ top: 8, bottom: 8 })
                  .border({ width: 0.5, color: '#1B5E20' })
                  .backgroundColor('#4CAF50')

                Text('模块')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
                  .width(80)
                  .textAlign(TextAlign.Center)
                  .padding({ top: 8, bottom: 8 })
                  .border({ width: 0.5, color: '#1B5E20' })
                  .backgroundColor('#4CAF50')

                Text('信息')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
                  .layoutWeight(1)
                  .textAlign(TextAlign.Center)
                  .padding({ top: 8, bottom: 8, left: 4, right: 4 })
                  .border({ width: 0.5, color: '#1B5E20' })
                  .backgroundColor('#4CAF50')

                Text('状态')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
                  .width(80)
                  .textAlign(TextAlign.Center)
                  .padding({ top: 8, bottom: 8 })
                  .border({ width: 0.5, color: '#1B5E20' })
                  .backgroundColor('#4CAF50')

                Text('开始时间')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
                  .width(150)
                  .textAlign(TextAlign.Center)
                  .padding({ top: 8, bottom: 8 })
                  .border({ width: 0.5, color: '#1B5E20' })
                  .backgroundColor('#4CAF50')

                Text('结束时间')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
                  .width(150)
                  .textAlign(TextAlign.Center)
                  .padding({ top: 8, bottom: 8 })
                  .border({ width: 0.5, color: '#1B5E20' })
                  .backgroundColor('#4CAF50')
              }
              .width('100%')
              .height(40) // 设置固定高度
              .margin({ bottom: 0 })

              // 可滚动数据区域 - 使用List组件实现表头置顶
              List() {
                ForEach(this.alarmList, (item: AlarmItem, index: number) => {
                  ListItem() {
                    Row() {
                      Text(item.category)
                        .fontSize(13)
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(80)
                        .textAlign(TextAlign.Center)
                        .padding({ left: 4, right: 4, top: 6, bottom: 6 })

                      Text(item.code)
                        .fontSize(13)
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(60)
                        .textAlign(TextAlign.Center)
                        .padding({ left: 4, right: 4, top: 6, bottom: 6 })

                      Text(item.module || '')
                        .fontSize(13)
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(80)
                        .textAlign(TextAlign.Center)
                        .padding({ left: 4, right: 4, top: 6, bottom: 6 })

                      Text(item.message)
                        .fontSize(13)
                        .fontColor(this.getCurrentTheme().textColor)
                        .layoutWeight(1)
                        .textAlign(TextAlign.Center)
                        .padding({ left: 4, right: 4, top: 6, bottom: 6 })
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })

                      Text(item.status)
                        .fontSize(13)
                        .fontColor(item.status === '故障中' ? '#FF5722' : this.getCurrentTheme().textColor)
                        .width(80)
                        .textAlign(TextAlign.Center)
                        .padding({ left: 4, right: 4, top: 6, bottom: 6 })

                      Text(item.startTime)
                        .fontSize(13)
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(150)
                        .textAlign(TextAlign.Center)
                        .padding({ left: 4, right: 4, top: 6, bottom: 6 })

                      Text(item.endTime || '')
                        .fontSize(13)
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(150)
                        .textAlign(TextAlign.Center)
                        .padding({ left: 4, right: 4, top: 6, bottom: 6 })
                    }
                    .width('100%')
                    .height(40) // 固定行高
                    .backgroundColor(this.selectedIndex === index ? '#E3F2FD' : Color.White)
                    .border({ width: { bottom: 1 }, color: '#E0E0E0' })
                    .onClick(() => {
                      this.selectedIndex = index
                    })
                  }
                }, (item: AlarmItem) => `${item.code}-${item.startTime}`)
              }
              .layoutWeight(1) // 使用layoutWeight填满可用空间
              .width('100%')
              .scrollBar(BarState.Auto) // 显示滚动条
              .edgeEffect(EdgeEffect.Spring) // 弹簧边缘效果
              .friction(100)

              // 底部查询区域
              Row() {
                Text('开始日期:')
                  .fontSize(14)
                  .fontColor(this.getCurrentTheme().textColor)
                  .margin({ right: 8 })

                TextInput({ text: this.startDate, placeholder: 'YYYY-MM-DD' })
                  .width(120)
                  .height(32)
                  .fontSize(14)
                  .backgroundColor(Color.White)
                  .border({ width: 1, color: this.getCurrentTheme().borderColor })
                  .borderRadius(4)
                  .margin({ right: 12 })
                  .onChange((value: string) => {
                    this.startDate = value
                  })

                Text('结束日期:')
                  .fontSize(14)
                  .fontColor(this.getCurrentTheme().textColor)
                  .margin({ right: 8 })

                TextInput({ text: this.endDate, placeholder: 'YYYY-MM-DD' })
                  .width(120)
                  .height(32)
                  .fontSize(14)
                  .backgroundColor(Color.White)
                  .border({ width: 1, color: this.getCurrentTheme().borderColor })
                  .borderRadius(4)
                  .margin({ right: 12 })
                  .onChange((value: string) => {
                    this.endDate = value
                  })

                Text('信息:')
                  .fontSize(14)
                  .fontColor(this.getCurrentTheme().textColor)
                  .margin({ right: 8 })

                TextInput({ text: this.messageQuery, placeholder: '请输入信息关键词' })
                  .layoutWeight(1)
                  .height(32)
                  .fontSize(14)
                  .backgroundColor(Color.White)
                  .border({ width: 1, color: this.getCurrentTheme().borderColor })
                  .borderRadius(4)
                  .margin({ right: 12 })
                  .onChange((value: string) => {
                    this.messageQuery = value
                  })

                Button('查询')
                  .type(ButtonType.Normal)
                  .fontSize(14)
                  .fontColor(Color.White)
                  .backgroundColor('#228B22')
                  .width(80)
                  .height(32)
                  .borderRadius(4)
                  .onClick(() => {
                    this.handleQuery()
                  })
              }
              .width('100%')
              .padding({ top: 12, bottom: 12, left: 16, right: 16 })
              .alignItems(VerticalAlign.Center)
            }
            .layoutWeight(1)
            .width('100%')
            .backgroundColor(this.getCurrentTheme().surfaceColor)
          }
          .layoutWeight(1)
          .width('100%')
          .backgroundColor(this.getCurrentTheme().surfaceColor)
        }
        .width(1000)
        .height(600)
        .backgroundColor(this.getCurrentTheme().surfaceColor)
        .borderRadius(8)
        .shadow({
          radius: 20,
          color: 'rgba(0, 0, 0, 0.3)',
          offsetX: 0,
          offsetY: 4
        })
        .align(Alignment.Center)
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(1000)
  }
}