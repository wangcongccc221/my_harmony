import { HomeContent } from './home/HomeContent'
import { LevelContent } from './level/LevelContent'
import { QualityContent } from './quality/QualityContent'
import { HistoryContent } from './history/HistoryContent'
import { EndProcessingContent } from './endprocessing/EndProcessingContent'
import { MoreContent } from './more/MoreContent'
// import { ThemeSelector } from '../components/ThemeSelector'
import { ArrowToggleButton } from '../components/ui/ArrowToggleButton'
import { NavButton } from '../components/ui/NavButton'
import { LeftNavigationTabBar } from '../components/layout/LeftNavigationTabBar'
import { FruitInfoDialog } from '../components/feedback/FruitInfoDialog'
import { RealtimeStatsDialog } from '../components/feedback/RealtimeStatsDialog'
import { LoadProgramDialog } from '../components/dialogs/LoadProgramDialog'
import { SaveProgramDialog } from '../components/dialogs/SaveProgramDialog'
import { SortingStatusDialog } from '../components/dialogs/SortingStatusDialog'
import { BaseComponentHelper } from '../components/common/BaseComponent'
import { NavigationUtils } from '../utils/helpers/NavigationUtils'
import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../utils/theme/OmniThemeManager'
import { useOmniTheme, OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../utils/theme/useOmniTheme'
import { OmniUIInit } from '../utils/helpers/OmniUIInit'
import { OmniUIUtils } from '../utils/helpers/OmniUIUtils'
import { OmniBottomTabBar, OmniBottomBarItem } from '@wuba58/omni-ui'
// 导入 IBest-UI 组件
import { IBestButton, IBestIcon, IBestTag, IBestInit } from '@ibestservices/ibest-ui'
import { window } from '@kit.ArkUI'
import { RectButton } from '../components/ui/RectButton'
import { TopStatusBar } from '../components/layout/TopStatusBar'
import { BottomControlBar } from '../components/layout/BottomControlBar'
// 移除 BottomBar 集成


// 导航按钮配置接口
interface NavigationButton {
  text: string // 展示文字（中文）
  pageName: string // 英文页面键（用于路由/比较）
}

// 页面处理策略类型
type PageHandler = () => void

// 页面内容渲染器类型
type PageRenderer = () => void

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

interface ProgramInfo {
  id: string
  name: string
  description: string
  version: string
  createDate: string
  lastModified: string
}

// 保存用户配置信息接口（仅保留名称、描述、标签）
interface SaveProgramInfo {
  name: string
  description: string
  tags: string
}

@Entry
@Component
struct Page {
  @State currentPage: string = 'home'
  @State showThemeSelector: boolean = false  // 控制主题选择器显示
  @State sideBarStatus: boolean = true  // 控制侧边栏展开/收缩状态
  @State showFruitInfoDialog: boolean = false  // 控制水果信息对话框显示
  @State showRealtimeDialog: boolean = false   // 控制实时统计对话框显示
  @State showLoadProgramDialog: boolean = false  // 控制载入程序对话框显示
  @State showSaveProgramDialog: boolean = false  // 控制保存程序对话框显示
  @State showSortingStatusDialog: boolean = false  // 控制分选状态对话框显示
  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: OmniThemeType = OmniThemeManager.getInstance().getCurrentThemeType()
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0
  private omniThemeManager = OmniThemeManager.getInstance()  // Omni-UI 主题管理器实例
  private omniUIInit = OmniUIInit.getInstance()  // Omni-UI 初始化实例
  private omniUIUtils = OmniUIUtils.getInstance()  // Omni-UI 工具实例
  private baseComponentHelper = new BaseComponentHelper()  // 基础组件助手
  // 通用快捷对话框状态
  @State quickDialogVisible: boolean = false
  @State quickDialogTitle: string = ''
  @State quickDialogContent: string = ''
  private quickDialogConfirm?: () => void
  @State private quickDialogIndex: number = -1
  private bottomButtonsCount: number = 10
  // 打印按钮悬停状态
  @State showPrintSubButtons: boolean = false
  // 顶部个人信息 - 全屏居中编辑弹窗全局状态
  @StorageLink('EDIT_USER_LABEL_VISIBLE') private editUserLabelVisible: boolean = false
  @StorageLink('TEMP_USER_LABEL') private tempUserLabel: string = '姓名'
  
  
  // 页面初始化时初始化 Omni-UI 和 IBest-UI
  aboutToAppear() {
    this.omniUIInit.init()
    this.omniThemeManager.init()
  }
  
  
  
  // 获取当前主题配置的方法
  getCurrentTheme(): ExtendedOmniThemeStyle {
    // 引用 themeVersion，确保主题版本变化触发本组件重建
    const __version: number = this.themeVersion
    return this.baseComponentHelper.getCurrentTheme(this.consumedTheme)
  }

  // 将页面键映射为展示标题（中文）
  private getPageTitle(pageKey: string): string {
    const map: Record<string, string> = {
      'home': '主页',
      'quality': '品质',
      'level': '等级',
      'fruit': '水果信息',
      'load': '载入程序',
      'save': '保存程序',
      'history': '历史加工',
      'end': '结束加工',
      'print': '打印',
      'more': '更多'
    }
    return map[pageKey] || pageKey
  }

  // 页面处理策略映射（按英文 pageKey）
  private getPageHandlers(): Record<string, PageHandler> {
    return {
      'fruit': (): void => this.showFruitInfo(),
      'realtime': (): void => this.showRealtimeStats(),
      'load': (): void => this.showLoadProgram(),
      'save': (): void => this.showSaveProgram(),
      'print': (): void => this.handlePrintClick(),
      // 默认处理：正常页面切换
      'default': (): void => { this.currentPage = this.currentPage }
    }
  }

  // 页面切换处理方法
  private handlePageChange(pageName: string): void {
    const handlers = this.getPageHandlers()
    const handler = handlers[pageName] || handlers['default']
    
    if (handler === handlers['default']) {
      // 对于默认处理，需要设置正确的页面名称
      this.currentPage = pageName
    } else {
      handler()
    }
  }

  // 水果信息功能封装
  private showFruitInfo(): void {
    this.showFruitInfoDialog = true
  }

  // 实时统计弹窗功能封装（与水果信息同风格）
  private showRealtimeStats(): void {
    this.showRealtimeDialog = true
  }

  // 处理水果信息对话框确认
  private handleFruitInfoConfirm(fruitInfo: FruitInfo): void {
    this.omniUIUtils.showInfo(`已确认水果信息：${fruitInfo.name}`)
    this.showFruitInfoDialog = false
  }

  // 处理水果信息对话框取消
  private handleFruitInfoCancel(): void {
    this.omniUIUtils.showInfo('已取消查看水果信息')
    this.showFruitInfoDialog = false
  }

  // 载入程序功能封装
  private showLoadProgram(): void {
    this.showLoadProgramDialog = true
  }

  // 处理载入程序对话框确认
  private handleLoadProgramConfirm(programInfo: ProgramInfo): void {
    this.omniUIUtils.showInfo(`已载入程序：${programInfo.name} (${programInfo.version})`)
    this.showLoadProgramDialog = false
  }

  // 处理载入程序对话框取消
  private handleLoadProgramCancel(): void {
    this.omniUIUtils.showInfo('已取消载入程序')
    this.showLoadProgramDialog = false
  }

  // 保存程序功能封装
  private showSaveProgram(): void {
    this.showSaveProgramDialog = true
  }

  // 处理保存程序对话框确认
  private handleSaveProgramConfirm(saveProgramInfo: SaveProgramInfo): void {
    // 这里可以添加实际的保存逻辑，比如保存到本地存储
    console.log('保存程序信息:', saveProgramInfo)
    this.omniUIUtils.showSuccess(`程序 "${saveProgramInfo.name}" 已保存到本地`)
    this.showSaveProgramDialog = false
  }

  // 处理保存程序对话框取消
  private handleSaveProgramCancel(): void {
    this.omniUIUtils.showInfo('已取消保存程序')
    this.showSaveProgramDialog = false
  }

  // 分选状态功能封装
  private showSortingStatus(): void {
    this.showSortingStatusDialog = true
  }

  // 处理分选状态对话框确认
  private handleSortingStatusConfirm(isNormal: boolean): void {
    const statusText = isNormal ? '正常分选' : '异常分选'
    this.omniUIUtils.showInfo(`分选状态已设置为：${statusText}`)
    this.showSortingStatusDialog = false
  }

  // 处理分选状态对话框取消
  private handleSortingStatusCancel(): void {
    this.omniUIUtils.showInfo('已取消分选状态设置')
    this.showSortingStatusDialog = false
  }

  // 处理打印按钮点击显示子按钮
  private handlePrintClick(): void {
    this.showPrintSubButtons = !this.showPrintSubButtons
  }

  // 处理打印子按钮点击
  private handlePrintSubButtonClick(subButtonName: string): void {
    this.omniUIUtils.showInfo(`已点击${subButtonName}`)
    // 点击子按钮后不自动隐藏，保持子按钮显示状态
  }



  // 创建导航按钮配置（pageName 使用英文键）
  private getNavigationButtons(): NavigationButton[] {
    return [
      { text: '主   页', pageName: 'home' },
      { text: '品   质', pageName: 'quality' },
      { text: '等   级', pageName: 'level' },
      { text: '水果信息', pageName: 'fruit' },
      { text: '载入程序', pageName: 'load' },
      { text: '保存程序', pageName: 'save' },
      { text: '历史加工', pageName: 'history' },
      { text: '实时统计', pageName: 'realtime' },
      { text: '结束加工', pageName: 'end' },
      { text: '打    印', pageName: 'print' },
      { text: '更    多', pageName: 'more' }
    ]
  }

  // 渲染页面内容
  @Builder
  private renderPageContent(): void {
    if (this.currentPage === 'home') {
      HomeContent()
    } else if (this.currentPage === 'level') {
      LevelContent()
    } else if (this.currentPage === 'quality') {
      QualityContent()
    } else if (this.currentPage === 'realtime') {
      // 实时统计占位页面（后续可替换为真实组件）
      Column() {
        Text('实时统计')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getCurrentTheme().primary)
          .margin({ top: 20 })
      }
      .width('100%')
      .height('100%')
    } else if (this.currentPage === 'history') {
      HistoryContent()
    } else if (this.currentPage === 'end') {
      EndProcessingContent()
    } else if (this.currentPage === 'more') {
      MoreContent()
    } else {
      // 默认页面内容
      this.renderDefaultPage()
    }
  }

  // 渲染默认页面内容
  @Builder
  private renderDefaultPage(): void {
    Column() {
      Text(`${this.getPageTitle(this.currentPage)}页面`)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getCurrentTheme().textColor)
        .margin({ top: 50 })
      Text(`这里将显示${this.getPageTitle(this.currentPage)}功能`)
        .fontSize(16)
        .fontColor(this.getCurrentTheme().subTextColor)
        .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  // 获取当前主题的主色调（基于页面状态）
  getThemePrimaryColor(): string {
    const themeConfigs = this.omniThemeManager.getAllThemes()
    const themeType = this.consumedThemeType ?? this.omniThemeManager.getCurrentThemeType()
    const primaryColor = themeConfigs[themeType]?.primary
    return typeof primaryColor === 'string' ? primaryColor : '#007AFF'
  }

  // 根据当前页面获取左侧导航背景色（未配置则回退到通用 navBg）
  private getNavBgForCurrentPage(): string | number {
    const theme = this.getCurrentTheme()
    const page = this.currentPage
    if (page === 'home' && theme.navBgHome) return theme.navBgHome
    if (page === 'level' && theme.navBgLevel) return theme.navBgLevel
    if (page === 'quality' && theme.navBgQuality) return theme.navBgQuality
    if (page === 'history' && theme.navBgHistory) return theme.navBgHistory
    if (page === 'more' && theme.navBgMore) return theme.navBgMore
    return theme.navBg ?? theme.surfaceColor
  }

  // 统一弹出快捷对话框
  private openQuickDialog(title: string, content: string, onConfirm?: () => void): void {
    this.quickDialogTitle = title
    this.quickDialogContent = content
    this.quickDialogConfirm = onConfirm
    this.quickDialogVisible = true
  }

  // 根据索引弹出快捷对话框（用于底部按钮1~10）
  private openQuickDialogForIndex(index: number, onConfirm?: () => void): void {
    this.quickDialogIndex = index
    const title = `${index}号出口`
    const content = `你点击了底部按钮 ${index}`
    this.openQuickDialog(title, content, onConfirm)
  }

  // 切换到上一个/下一个
  private navigateQuickDialog(delta: number): void {
    if (!this.quickDialogVisible || this.quickDialogIndex < 1) {
      return
    }
    const count = this.bottomButtonsCount
    let nextIndex = ((this.quickDialogIndex - 1 + delta) % count + count) % count + 1
    this.openQuickDialogForIndex(nextIndex)
  }

  // 构建打印子按钮（向下展开，带缩进）
  @Builder
  private buildPrintSubButtons() {
    if (this.showPrintSubButtons) {
      Column() {
        // 子按钮1：打印报告
        Button('打印报告')
          .width('70%')
          .height(36)
          .margin({ bottom: 4, left: 20, right: 20 })
          .fontSize(12)
          .fontWeight(FontWeight.Bolder)
          .fontColor(this.getCurrentTheme().textColor)
          .backgroundColor(this.getCurrentTheme().surfaceColor)
          .border({ 
            width: 1, 
            color: this.getCurrentTheme().borderColor 
          })
          .borderRadius(0)
          .onClick(() => {
            this.handlePrintSubButtonClick('打印报告')
          })

        // 子按钮2：打印标签
        Button('打印标签')
          .width('70%')
          .height(36)
          .margin({ left: 20, right: 20 })
          .fontSize(12)
          .fontWeight(FontWeight.Bolder)
          .fontColor(this.getCurrentTheme().textColor)
          .backgroundColor(this.getCurrentTheme().surfaceColor)
          .border({ 
            width: 1, 
            color: this.getCurrentTheme().borderColor 
          })
          .borderRadius(0)
          .onClick(() => {
            this.handlePrintSubButtonClick('打印标签')
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ top: 4 })
    }
  }


  // 渲染快捷对话框
  @Builder
  private renderQuickDialog() {
    Stack() {
      Column() {
        Row() {
          Text(this.quickDialogTitle || '提示')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .layoutWeight(1)
          
          // 右上角：上一个/下一个按钮
          Row() {
            Button('上一个')
              .fontSize(12)
              .fontColor(this.getCurrentTheme().textColor)
              .backgroundColor(this.getCurrentTheme().backgroundColor)
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
              .borderRadius(6)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .onClick(() => { this.navigateQuickDialog(-1) })

            Button('下一个')
              .fontSize(12)
              .fontColor(this.getCurrentTheme().textColor)
              .backgroundColor(this.getCurrentTheme().backgroundColor)
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
              .borderRadius(6)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .margin({ left: 8 })
              .onClick(() => { this.navigateQuickDialog(1) })
          }
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 15, bottom: 15 })
        .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })

        // 内容区域暂时留空
        Blank()
          .height(60)

        // 右下角：确认/取消按钮
        Row() {
          Blank()
          
          Row() {
            Button('取消')
              .fontSize(14)
              .fontColor(this.getCurrentTheme().textColor)
              .backgroundColor(this.getCurrentTheme().backgroundColor)
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
              .borderRadius(8)
              .padding({ left: 20, right: 20, top: 10, bottom: 10 })
              .onClick(() => { this.quickDialogVisible = false })

            Button('确认')
              .fontSize(14)
              .fontColor(Color.White)
              .backgroundColor(this.getThemePrimaryColor())
              .borderRadius(8)
              .padding({ left: 20, right: 20, top: 10, bottom: 10 })
              .margin({ left: 10 })
              .onClick(() => {
                if (this.quickDialogConfirm) {
                  this.quickDialogConfirm()
                } else {
                  this.omniUIUtils.showSuccess('已确认')
                }
                this.quickDialogVisible = false
              })
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
        .alignItems(VerticalAlign.Center)
        .padding({ left: 20, right: 20, top: 0, bottom: 20 })
      }
      .width('80%')
      .constraintSize({ maxWidth: 500 })
      .backgroundColor(this.getCurrentTheme().surfaceColor)
      .borderRadius(12)
      .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 4 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0, 0, 0, 0.5)')
    .alignContent(Alignment.Center)
    .onClick(() => { this.quickDialogVisible = false })
    .visibility(this.quickDialogVisible ? Visibility.Visible : Visibility.None)
  }

  @Builder
  renderPage() {
    Stack() {
      Column() {
      
      Row() {
        // 左侧竖向导航（自定义展开/收缩）
        Stack() {
          // 导航按钮内容
          if (this.sideBarStatus) {
            LeftNavigationTabBar({
              currentPage: this.currentPage,
              showPrintSubButtons: this.showPrintSubButtons,
              onPageChange: (pageKey: string) => {
                this.handlePageChange(pageKey)
                // 只有非水果信息页面才显示切换消息
                if (pageKey !== 'fruit' && pageKey !== 'realtime') {
                  this.omniUIUtils.showInfo(`已切换到${this.getPageTitle(pageKey)}页面`)
                }
              },
              onPrintSubButtonClick: (subButtonName: string) => {
                this.handlePrintSubButtonClick(subButtonName)
              }
            })
          }

          // 箭头按钮 - 贴在右边边缘，垂直居中，更突出
          ArrowToggleButton({
            isExpanded: this.sideBarStatus,
            onToggle: () => {
              this.sideBarStatus = !this.sideBarStatus
            }
          })
          .position({ x: this.sideBarStatus ? 120 : 5, y: '50%' })
          .translate({ y: -20 })
          .zIndex(10) // 确保在最上层
        }
        .width(this.sideBarStatus ? 150 : 50)
        .height('100%')
        .padding({ left: 8, right: 8, top: 8, bottom: 8 })
        .backgroundColor(this.getNavBgForCurrentPage())
        .border({ width: { right: 1 }, color: this.getCurrentTheme().borderColor })

        // 右侧内容
        Column() {
          this.renderPageContent()
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.getCurrentTheme().pageBg ?? this.getCurrentTheme().surfaceColor)
        .padding({ bottom: 12 })
        .layoutWeight(1)

      }
      .width('100%')
      .height('100%')
      .layoutWeight(1)

      //（已按需移除底部任务栏）
      }
      .height('100%')
      .width('100%')
      
      // 移除底部栏
      
      // 主题选择器弹窗
      // if (this.showThemeSelector) {
      //   ThemeSelector({
      //     onThemeSelected: (theme: OmniThemeType) => {
      //       const hook = useOmniTheme()
      //       hook.setTheme(theme)
      //       this.showThemeSelector = false
      //       const themeName = this.omniThemeManager.getThemeName(theme)
      //       this.omniUIUtils.showSuccess(`已切换到${themeName}`)
      //     },
      //     onCancel: () => {
      //       this.showThemeSelector = false
      //     }
      //   })
      // }

      // 水果信息对话框
      if (this.showFruitInfoDialog) {
        FruitInfoDialog({
          isVisible: this.showFruitInfoDialog,
          onConfirm: (fruitInfo: FruitInfo) => {
            this.handleFruitInfoConfirm(fruitInfo)
          },
          onCancel: () => {
            this.handleFruitInfoCancel()
          }
        })
      }

      // 载入程序对话框
      if (this.showLoadProgramDialog) {
        LoadProgramDialog({
          isVisible: this.showLoadProgramDialog,
          onConfirm: (programInfo: ProgramInfo) => {
            this.handleLoadProgramConfirm(programInfo)
          },
          onCancel: () => {
            this.handleLoadProgramCancel()
          }
        })
      }

      // 实时统计对话框（与水果信息同风格：统一为独立弹窗组件）
      if (this.showRealtimeDialog) {
        RealtimeStatsDialog({
          isVisible: this.showRealtimeDialog,
          onConfirm: (_stats) => {
            this.omniUIUtils.showInfo('已确认实时统计')
            this.showRealtimeDialog = false
          },
          onCancel: () => {
            this.omniUIUtils.showInfo('已取消查看实时统计')
            this.showRealtimeDialog = false
          }
        })
      }

      // 保存程序对话框
      if (this.showSaveProgramDialog) {
        SaveProgramDialog({
          isVisible: this.showSaveProgramDialog,
          onConfirm: (saveProgramInfo: SaveProgramInfo) => {
            this.handleSaveProgramConfirm(saveProgramInfo)
          },
          onCancel: () => {
            this.handleSaveProgramCancel()
          }
        })
      }

      // 分选状态对话框 - 悬浮在底部控制栏上方
      if (this.showSortingStatusDialog) {
        Stack() {
          SortingStatusDialog({
            isVisible: this.showSortingStatusDialog,
            onConfirm: (isNormal: boolean) => {
              this.handleSortingStatusConfirm(isNormal)
            },
            onCancel: () => {
              this.handleSortingStatusCancel()
            }
          })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .onClick(() => {
          // 点击外部区域关闭弹窗
          this.showSortingStatusDialog = false
        })
      }

      // 通用快捷对话框
      this.renderQuickDialog()

      // 全屏居中：个人信息编辑弹窗（由页面根部渲染，覆盖全屏）
      if (this.editUserLabelVisible) {
        Stack() {
          Column() {
            // 标题
            Row() {
              Text('修改姓名标签')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.getCurrentTheme().textColor)
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 16, bottom: 10 })
            .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })

            // 输入框
            TextInput({ text: this.tempUserLabel, placeholder: '请输入显示标签' })
              .fontSize(14)
              .fontColor(this.getCurrentTheme().textColor)
              .backgroundColor(this.getCurrentTheme().backgroundColor)
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
              .borderRadius(8)
              .padding({ left: 12, right: 12, top: 10, bottom: 10 })
              .onChange((v: string) => { this.tempUserLabel = v })

            // 底部操作
            Row() {
              Blank()
              Button('取消')
                .fontSize(14)
                .fontColor(this.getCurrentTheme().textColor)
                .backgroundColor(this.getCurrentTheme().backgroundColor)
                .border({ width: 1, color: this.getCurrentTheme().borderColor })
                .borderRadius(8)
                .padding({ left: 20, right: 20, top: 10, bottom: 10 })
                .onClick(() => { AppStorage.set('EDIT_USER_LABEL_VISIBLE', false) })

              Button('确认')
                .fontSize(14)
                .fontColor(Color.White)
                .backgroundColor(this.getThemePrimaryColor())
                .borderRadius(8)
                .padding({ left: 20, right: 20, top: 10, bottom: 10 })
                .margin({ left: 10 })
                .onClick(() => {
                  const text = (this.tempUserLabel || '').trim()
                  if (text.length > 0) {
                    AppStorage.setOrCreate('TOP_USER_LABEL', text)
                  }
                  AppStorage.set('EDIT_USER_LABEL_VISIBLE', false)
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.End)
            .alignItems(VerticalAlign.Center)
            .padding({ left: 20, right: 20, top: 16, bottom: 16 })
          }
          .width('80%')
          .constraintSize({ maxWidth: 460 })
          .backgroundColor(this.getCurrentTheme().surfaceColor)
          .borderRadius(12)
          .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 4 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .alignContent(Alignment.Center)
        .onClick(() => { AppStorage.set('EDIT_USER_LABEL_VISIBLE', false) })
      }


    }
  }

  build() {
    Column() {
      // 顶部状态栏（全局可见）
      TopStatusBar({ currentPage: this.currentPage })

      // 主体内容区域（可伸缩，占据中间空间）
      Column() {
        if ((this.themeVersion % 2) === 0) {
          this.renderPage()
        } else {
          this.renderPage()
        }
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ bottom: 0 })

      // 底部控制栏（全局固定）
      BottomControlBar({
        onSortingStatusClick: () => {
          this.showSortingStatus()
        },
        onOutletClick: (outletNumber: number) => {
          console.log(`出口${outletNumber}被点击`)
          // 可以在这里处理出口点击逻辑
        },
        onFruitCupClick: (cupNumber: number) => {
          console.log(`果杯${cupNumber}被点击`)
          // 可以在这里处理果杯点击逻辑
        },
        onSCMClick: () => {
          console.log('SCM按钮被点击')
          // 可以在这里处理SCM点击逻辑
        }
      })
      .width('100%')
      .zIndex(100) // 确保在最上层
    }
    .width('100%')
    .height('100%')
  }
}