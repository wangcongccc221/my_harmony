import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme as resolveTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { AppleDesignStyle } from '../../utils/theme/AppleDesignStyle'
import { QualityStateManager } from './core/QualityStateManager'
import { QualityDataManager } from './core/QualityDataManager'
import { QualityEventHandler } from './core/QualityEventHandler'
import { QualityControlPanel } from './QualityControlPanel'
import { QualityDataTable } from './QualityDataTable'
import { QualityOutletDialog } from './QualityOutletDialog'
import { QualityLevelData } from './QualityConstants'
import { QualitySettingsDialog } from '../../components/dialogs/QualitySettingsDialog'
import { DEFAULT_QUALITY_SETTINGS } from './QualityConstants'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { ThreeDButton } from '../../components/ui/buttons/ThreeDButton'
import { HomeDataManager } from '../home/core/HomeDataManager'
import { HOME_SELECTED_FSM } from '../../constants/TopBarKeys'
import { GradeInfoConfigManager } from '../home/core/GradeInfoConfigManager'
import { ConstPreDefine } from '../../protocol/ConstPreDefine'
import { util } from '@kit.ArkTS'
import { getConfigSender } from '../../protocol/ConfigSender'

const DOMAIN = 0x0000
const TAG = 'QualityContent'
interface HomeContentRef {
  refreshAllTables?: () => void
}

type QualityAutoDimKey = 'color' | 'sugar' | 'acidity' | 'mold'

interface QualityAutoDim {
  key: QualityAutoDimKey
  values: string[]
}

interface QualityPickedValues {
  color?: string
  sugar?: string
  acidity?: string
  mold?: string
}

/**
 * 品质内容组件
 * 
 * 功能说明：
 * - 显示品质相关的内容和功能
 * - 集成模块化组件架构
 * - 支持主题切换和样式适配
 * 
 * 组件架构：
 * - 状态管理：使用QualityStateManager集中管理状态
 * - 数据管理：使用QualityDataManager管理数据
 * - 事件处理：使用QualityEventHandler处理事件
 * - UI组件：使用模块化组件构建界面
 * 
 * 主要功能：
 * - 品质等级管理
 * - 出口设置配置
 * - 数据表格显示
 * - 用户交互处理
 */
@Component
export struct QualityContent {
  // ==================== 状态管理 ====================
  
  /**
   * 品质页面状态管理器
   * 
   * 功能说明：
   * - 集中管理品质页面的所有状态
   * - 提供状态更新和重置功能
   * - 简化状态管理逻辑
   * 
   * 使用场景：
   * - 状态初始化和更新
   * - 状态重置和恢复
   * - 状态验证和同步
   */
  private stateManager = new QualityStateManager()

  /**
   * 品质页面数据管理器
   * 
   * 功能说明：
   * - 管理品质页面的所有数据操作
   * - 提供数据的增删改查功能
   * - 支持数据验证和格式化
   * 
   * 使用场景：
   * - 数据初始化和加载
   * - 数据更新和同步
   * - 数据验证和格式化
   */
  private dataManager = new QualityDataManager()

  /**
   * 品质页面事件处理器
   * 
   * 功能说明：
   * - 处理品质页面的所有用户交互事件
   * - 提供事件日志和调试功能
   * - 支持事件的扩展和自定义
   * 
   * 使用场景：
   * - 用户交互处理
   * - 事件日志记录
   * - 错误处理和调试
   */
  private eventHandler = new QualityEventHandler()

  // 用于驱动UI刷新的可观察数据（表格与等级数量联动）
  @State private currentLevels: QualityLevelData[] = []
  
  // 悬浮按钮显示状态
  @State private showFloatingButtons: boolean = true
  // 悬浮按钮悬停状态
  @State private isHovering: boolean = false
  // 品质参数设置对话框显示状态
  @State private showQualitySettingsDialog: boolean = false

  /**
   * 页面切换回调
   * 当需要切换页面时（如保存后返回主页），通过此回调通知父组件
   */
  onPageChange?: (pageName: string) => void

  // 控制面板组件引用
  private controlPanelRef: QualityControlPanel | null = null

  private readFixedName(bytes: Uint8Array, index: number): string {
    const start = index * ConstPreDefine.MAX_TEXT_LENGTH
    let end = start
    while (end < start + ConstPreDefine.MAX_TEXT_LENGTH && bytes[end] !== 0) {
      end++
    }
    if (end <= start) { return '' }
    const slice = bytes.subarray(start, end)
    const decoder = new util.TextDecoder()
    return decoder.decodeWithStream(slice)
  }

  private getFixedNameList(bytes: Uint8Array, maxCount: number): string[] {
    const list: string[] = []
    for (let i = 0; i < maxCount; i++) {
      const name = this.readFixedName(bytes, i).trim()
      if (!name) { break }
      list.push(name)
    }
    return list
  }

  private getSelectedFSM(): 'FSM1' | 'FSM2' {
    const raw = AppStorage.get(HOME_SELECTED_FSM) as string | undefined
    return raw === 'FSM2' ? 'FSM2' : 'FSM1'
  }

  // ==================== 主题相关 ====================
  
  /**
   * 当前主题样式
   * 
   * 功能说明：
   * - 存储当前应用的主题样式
   * - 用于组件样式适配
   * - 自动响应主题变化
   * 
   * 使用场景：
   * - 组件渲染时获取主题样式
   * - 主题切换时自动更新
   */
  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()

  /**
   * 当前主题类型
   * 
   * 功能说明：
   * - 存储当前应用的主题类型
   * - 用于主题类型判断
   * - 自动响应主题变化
   * 
   * 使用场景：
   * - 主题类型判断时
   * - 主题切换时自动更新
   */
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: OmniThemeType = OmniThemeManager.getInstance().getCurrentThemeType()

  /**
   * 主题版本号
   * 
   * 功能说明：
   * - 存储当前主题的版本号
   * - 用于主题更新检测
   * - 自动响应主题变化
   * 
   * 使用场景：
   * - 主题更新检测时
   * - 主题切换时自动更新
   */
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0

  /**
   * 基础组件助手
   * 
   * 功能说明：
   * - 提供基础组件的通用功能
   * - 用于主题获取和样式处理
   * - 私有属性，不对外暴露
   * 
   * 使用场景：
   * - 获取当前主题时
   * - 处理组件样式时
   */
  // private baseComponentHelper = new BaseComponentHelper()

  // ==================== 方法定义 ====================
  
  /**
   * 获取当前主题配置
   * 
   * 功能说明：
   * - 获取当前应用的主题配置
   * - 返回主题样式对象
   * - 用于组件样式适配
   * 
   * @returns 当前主题样式对象
   * 
   * 使用场景：
   * - 组件渲染时获取主题样式
   * - 样式适配时调用
   */
  getCurrentTheme(): ExtendedOmniThemeStyle {
    // 引用 themeVersion，确保主题版本变化触发本组件重建
    const __version: number = this.themeVersion
    return resolveTheme(this.consumedTheme)
  }

  /**
   * 初始化品质页面
   * 
   * 功能说明：
   * - 初始化品质页面的所有组件
   * - 设置默认状态和数据
   * - 注册事件处理器
   * 
   * 初始化内容：
   * - 初始化状态管理器
   * - 初始化数据管理器
   * - 初始化事件处理器
   * - 设置默认状态
   * 
   * 使用场景：
   * - 页面初始化时
   * - 组件创建时
   * - 状态重置时
   */
  private initializeQualityPage(): void {
    // 初始化状态管理器
    this.stateManager.resetAllStates()
    
    // 初始化数据管理器
    this.dataManager.initializeQualityData()
    
    // 初始化事件处理器
    this.eventHandler.onPageInit()

    const savedLevels = AppStorage.get('QUALITY_LEVELS') as QualityLevelData[] | undefined
    const savedIndexRaw = AppStorage.get('QualityLevelCountIndex') as number | undefined
    const savedIndex = typeof savedIndexRaw === 'number'
      ? Math.max(0, Math.min(savedIndexRaw, 16))
      : DEFAULT_QUALITY_SETTINGS.defaultLevelCount

    if (Array.isArray(savedLevels) && savedLevels.length > 0) {
      const trimmed = savedLevels.slice(0, 16)
      this.stateManager.updateQualityLevels(trimmed)
      this.dataManager.setQualityLevels(trimmed)
      const nextCount = savedIndex > 0 ? Math.min(savedIndex, trimmed.length) : trimmed.length
      this.stateManager.updateLevelCountIndex(nextCount)
      this.dataManager.setLevelCount(nextCount)
    } else {
      this.stateManager.updateLevelCountIndex(savedIndex)
      this.dataManager.setLevelCount(savedIndex)
    }

    this.currentLevels = this.stateManager.getQualityLevels()
  }

  // ==================== 事件处理方法 ====================
  
  /**
   * 处理等级数量变化
   * 
   * 功能说明：
   * - 处理用户选择等级数量的事件
   * - 更新状态管理器和数据管理器
   * - 触发相关事件处理
   * 
   * @param index 等级数量索引
   * 
   * 使用场景：
   * - 用户从下拉框选择等级数量时
   * - 程序自动设置等级数量时
   */
  private handleLevelCountChange(index: number): void {
    console.log(`🔄 处理等级数量变化: ${index}`)
    
    // 更新状态管理器
    this.stateManager.updateLevelCountIndex(index)
    
    // 更新数据管理器
    this.dataManager.setLevelCount(index)
    
    // 触发事件处理
    this.eventHandler.onLevelCountChange(index)

    // 刷新可观察数据，触发表格联动
    this.currentLevels = this.stateManager.getQualityLevels()
    
    console.log(`✅ 等级数量变化处理完成，当前数据条数: ${this.currentLevels.length}`)
  }

  /**
   * 处理自动设定事件
   * 
   * 功能说明：
   * - 处理用户点击自动设定按钮的事件
   * - 执行自动设定逻辑
   * - 触发相关事件处理
   * 
   * 使用场景：
   * - 用户点击自动设定按钮时
   * - 程序需要自动设定参数时
   */
  private handleAutoSet(): void {
    // 触发事件处理
    this.eventHandler.onAutoSet()

    const fsm = this.getSelectedFSM()
    const gradeInfo = GradeInfoConfigManager.getInstance().getOrCreateGradeInfo(fsm)

    const defaultColor: string[] = ['优秀', '良好', '一般', '较差']
    const defaultSugar: string[] = ['高糖度', '中糖度']
    const defaultAcidity: string[] = ['高酸度', '中酸度']
    const defaultMold: string[] = ['无霉芯', '轻微霉芯']

    const colorList = this.getFixedNameList(gradeInfo.strColorGradeName, ConstPreDefine.MAX_COLOR_GRADE_NUM)
    const sugarList = this.getFixedNameList(gradeInfo.stSugarGradeName, ConstPreDefine.MAX_SUGAR_GRADE_NUM)
    const acidityList = this.getFixedNameList(gradeInfo.stAcidityGradeName, ConstPreDefine.MAX_ACIDITY_GRADE_NUM)
    const moldList = this.getFixedNameList(gradeInfo.stHollowGradeName, ConstPreDefine.MAX_HOLLOW_GRADE_NUM)

    const colors = colorList.length > 0 ? colorList : defaultColor
    const sugars = sugarList.length > 0 ? sugarList : defaultSugar
    const acidities = acidityList.length > 0 ? acidityList : defaultAcidity
    const molds = moldList.length > 0 ? moldList : defaultMold

    const activeDims: QualityAutoDim[] = []
    if (colors.length > 1) activeDims.push({ key: 'color', values: colors })
    if (sugars.length > 1) activeDims.push({ key: 'sugar', values: sugars })
    if (acidities.length > 1) activeDims.push({ key: 'acidity', values: acidities })
    if (molds.length > 1) activeDims.push({ key: 'mold', values: molds })

    const rows: QualityLevelData[] = []
    const limit = 16

    const dfs = (idx: number, picked: QualityPickedValues, nameParts: string[]) => {
      if (rows.length >= limit) { return }
      if (idx >= activeDims.length) {
        const levelName = nameParts.length > 0 ? nameParts.join('.') : `${rows.length + 1}`
        const color = (picked.color ?? (colors.length > 0 ? colors[0] : '全部')) || '全部'
        const sugar = (picked.sugar ?? (sugars.length > 0 ? sugars[0] : '全部')) || '全部'
        const acidity = (picked.acidity ?? (acidities.length > 0 ? acidities[0] : '全部')) || '全部'
        const mold = (picked.mold ?? (molds.length > 0 ? molds[0] : '全部')) || '全部'
        rows.push({
          levelName: levelName,
          colorLevel: color,
          sugarLevel: sugar,
          acidityLevel: acidity,
          moldCoreLevel: mold
        })
        return
      }
      const dim = activeDims[idx]
      for (let i = 0; i < dim.values.length; i++) {
        const v = dim.values[i]
        const nextPicked: QualityPickedValues = {
          color: picked.color,
          sugar: picked.sugar,
          acidity: picked.acidity,
          mold: picked.mold
        }
        if (dim.key === 'color') nextPicked.color = v
        else if (dim.key === 'sugar') nextPicked.sugar = v
        else if (dim.key === 'acidity') nextPicked.acidity = v
        else nextPicked.mold = v

        const nextNameParts: string[] = nameParts.slice()
        nextNameParts.push(v)
        dfs(idx + 1, nextPicked, nextNameParts)
        if (rows.length >= limit) { return }
      }
    }

    if (activeDims.length === 0) {
      for (let i = 0; i < Math.min(limit, Math.max(1, this.stateManager.getLevelCountIndex() || 1)); i++) {
        rows.push({
          levelName: `${i + 1}`,
          colorLevel: colors[0] ?? '全部',
          sugarLevel: sugars[0] ?? '全部',
          acidityLevel: acidities[0] ?? '全部',
          moldCoreLevel: molds[0] ?? '全部'
        })
      }
    } else {
      const picked0: QualityPickedValues = {}
      dfs(0, picked0, [])
    }

    this.stateManager.updateQualityLevels(rows)
    this.dataManager.setQualityLevels(rows)
    this.handleLevelCountChange(rows.length)
    AppStorage.setOrCreate('QUALITY_LEVELS', rows)

    hilog.info(DOMAIN, TAG, `品质页面：自动设定生成 ${rows.length} 条`)
  }

  /**
   * 处理设置参数事件
   * 
   * 功能说明：
   * - 处理用户点击设置参数按钮的事件
   * - 打开参数设置面板
   * - 触发相关事件处理
   * 
   * 使用场景：
   * - 用户点击设置参数按钮时
   * - 程序需要打开参数设置时
   */
  private handleSettingsClick(): void {
    // 触发事件处理
    this.eventHandler.onSettingsClick()
    
    // 打开参数设置对话框
    this.showQualitySettingsDialog = true
    hilog.info(DOMAIN, TAG, '品质页面：打开参数设置面板')
  }

  /**
   * 处理出口按钮点击
   * 
   * 功能说明：
   * - 处理用户点击出口按钮的事件
   * - 更新状态管理器和数据管理器
   * - 显示出口设置对话框
   * 
   * @param outletNumber 出口编号
   * 
   * 使用场景：
   * - 用户点击出口按钮时
   * - 程序需要打开出口设置时
   */
  private handleOutletClick(outletNumber: number): void {
    // 更新状态管理器
    this.stateManager.updateCurrentOutletIndex(outletNumber)
    this.stateManager.updateShowOutletDialog(true)
    
    // 更新数据管理器
    this.dataManager.setCurrentOutletIndex(outletNumber)
    
    // 触发事件处理
    this.eventHandler.onOutletClick(outletNumber)
  }

  /**
   * 处理出口切换事件
   * 
   * 功能说明：
   * - 处理用户切换出口状态的事件
   * - 更新状态管理器和数据管理器
   * - 触发相关事件处理
   * 
   * @param direction 切换方向
   * 
   * 使用场景：
   * - 用户点击上一个/下一个按钮时
   * - 程序需要切换出口时
   */
  private handleOutletSwitch(direction: 'previous' | 'next'): void {
    // 更新数据管理器
    if (direction === 'previous') {
      this.dataManager.switchToPreviousOutlet()
    } else {
      this.dataManager.switchToNextOutlet()
    }
    
    // 更新状态管理器
    this.stateManager.updateCurrentOutletIndex(this.dataManager.getCurrentOutletIndex())
    
    // 触发事件处理
    this.eventHandler.onOutletSwitch(direction, this.stateManager.getCurrentOutletIndex())
  }

  /**
   * 处理出口确认事件
   * 
   * 功能说明：
   * - 处理用户确认出口设置的事件
   * - 更新状态管理器
   * - 关闭出口设置对话框
   * 
   * 使用场景：
   * - 用户确认出口设置时
   * - 程序需要确认出口设置时
   */
  private handleOutletConfirm(): void {
    // 更新状态管理器
    this.stateManager.updateShowOutletDialog(false)
    
    // 触发事件处理
    this.eventHandler.onOutletConfirm(this.stateManager.getCurrentOutletIndex())
  }

  /**
   * 处理出口取消事件
   * 
   * 功能说明：
   * - 处理用户取消出口设置的事件
   * - 更新状态管理器
   * - 关闭出口设置对话框
   * 
   * 使用场景：
   * - 用户取消出口设置时
   * - 程序需要取消出口设置时
   */
  private handleOutletCancel(): void {
    // 更新状态管理器
    this.stateManager.updateShowOutletDialog(false)
    
    // 触发事件处理
    this.eventHandler.onOutletCancel()
  }

  /**
   * 处理数据更新事件
   * 
   * 功能说明：
   * - 处理品质等级数据更新的事件
   * - 更新状态管理器和数据管理器
   * - 触发相关事件处理
   * 
   * @param data 更新的数据
   * @param index 数据索引
   * 
   * 使用场景：
   * - 用户编辑等级数据时
   * - 程序自动更新数据时
   */
  private handleDataUpdate(data: QualityLevelData, index: number): void {
    // 更新状态管理器
    this.stateManager.updateQualityLevel(index, {
      levelName: data.levelName,
      colorLevel: typeof data.colorLevel === 'string' ? data.colorLevel : String(data.colorLevel.value),
      sugarLevel: data.sugarLevel,
      acidityLevel: data.acidityLevel,
      moldCoreLevel: data.moldCoreLevel
    })
    
    // 更新数据管理器
    this.dataManager.updateQualityLevel(index, {
      levelName: data.levelName,
      colorLevel: typeof data.colorLevel === 'string' ? data.colorLevel : String(data.colorLevel.value),
      sugarLevel: data.sugarLevel,
      acidityLevel: data.acidityLevel,
      moldCoreLevel: data.moldCoreLevel
    })
    
    // 触发事件处理
    this.eventHandler.onDataUpdate(data, index)

    // 同步最新数据到可观察数组
    this.currentLevels = this.stateManager.getQualityLevels()
  }

  /**
   * 处理保存并确认
   * 
   * 功能说明：
   * - 保存品质等级数据
   * - 更新首页显示的品质名称
   * - 返回主页
   */
  private async handleSaveAndConfirm(): Promise<void> {
    const levels = this.stateManager.getQualityLevels()
    const selectedFSM = this.getSelectedFSM()
    HomeDataManager.getInstance().updateQualityGradeNames(levels.map(item => item.levelName), selectedFSM)
    HomeDataManager.getInstance().syncStatisticsTableLevels(levels.map(item => item.levelName), selectedFSM)
    const homeContent = AppStorage.get('HOME_CONTENT_REF') as HomeContentRef | null
    if (homeContent?.refreshAllTables) {
      homeContent.refreshAllTables()
    }
    
    // 如果有数据，触发更新事件
    if (levels.length > 0) {
      const first = levels[0]
      this.eventHandler.onDataUpdate(first, -1)
    }
    
    const idx = this.stateManager.getLevelCountIndex()
    AppStorage.setOrCreate('QualityLevelCountIndex', idx)
    AppStorage.setOrCreate('QUALITY_LEVELS', levels)
    
    console.log('品质页面：确认操作')

    try {
      const info = GradeInfoConfigManager.getInstance().rebuildBaseFromHomeGradeTable(selectedFSM)
      const fsmId = selectedFSM === 'FSM1' ? ConstPreDefine.getFsmId(0) : ConstPreDefine.getFsmId(1)
      const ok = await getConfigSender().sendFullGradeInfo(fsmId, info)
      console.log(ok ? '品质配置已下发到下位机' : '品质配置下发失败')
    } catch (e) {
      console.log(`品质配置下发异常: ${String(e)}`)
    }

    // 保存完成后，返回主页
    if (this.onPageChange) {
      console.log('【品质页面】保存完成，返回主页')
      this.onPageChange('home')
    }
  }

  /**
   * 构建组件UI
   * 
   * 功能说明：
   * - 构建品质页面的完整UI结构
   * - 使用模块化组件构建界面
   * - 支持主题适配和事件处理
   * 
   * 组件结构：
   * - 控制面板：等级数量选择、自动设定、设置参数
   * - 数据表格：显示品质等级数据
   * - 出口对话框：出口设置和选择
   * 
   * 样式特性：
   * - 响应式设计：适配不同屏幕尺寸
   * - 主题适配：支持明暗主题
   * - 模块化架构：使用独立组件
   * - 事件处理：统一的事件管理
   */
  build() {
    Stack() {
      // 主要内容
      Row() {
        Column() {
        // 控制面板组件
        QualityControlPanel({
          levelCountIndex: this.stateManager.getLevelCountIndex(),
          currentDataCount: this.currentLevels.length,
          onLevelCountChange: (index: number) => {
            this.handleLevelCountChange(index)
          },
          onAutoSet: () => {
            this.handleAutoSet()
          },
          onSettingsClick: () => {
            this.handleSettingsClick()
          }
        })
        .onAppear(() => {
          // 获取控制面板组件引用
          // this.controlPanelRef = this
        })

        // 数据表格组件
        QualityDataTable({
          qualityLevels: this.currentLevels,
          onDataUpdate: (data: QualityLevelData, index: number) => {
            this.handleDataUpdate(data, index)
          },
          onDataClick: (data: QualityLevelData, index: number) => {
            this.handleDataUpdate(data, index)
          }
        })

        }
        .width('100%')
        .height('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Start)

      }
      .width('100%')
      .height('100%')
      .alignItems(VerticalAlign.Top)
      .backgroundColor(this.getCurrentTheme().pageBg ?? this.getCurrentTheme().backgroundColor)
      
      // ==================== 悬浮按钮 ====================
      if (this.showFloatingButtons) {
        Column() {
          // 确认按钮 - ThreeDButton样式
          ThreeDButton({
            text: '确认',
            isSelected: false,
            buttonWidth: 80,
            buttonHeight: 50,
            fontSize: 16,
            onClickCallback: () => {
              this.handleSaveAndConfirm()
            }
          })

          // 取消按钮 - ThreeDButton样式
          ThreeDButton({
            text: '取消',
            isSelected: false,
            buttonWidth: 80,
            buttonHeight: 50,
            fontSize: 16,
            onClickCallback: () => {
              this.eventHandler.onDataReset()
              console.log('品质页面：取消操作')
            }
          })
          .margin({ top: 12 })
        }
        .position({ x: '100%', y: '50%' })
        .translate({ 
          x: this.isHovering ? -80 : -40, // 悬停时完全显示，半隐藏时一半在屏幕外
          y: -56 
        })
        .zIndex(100)
        .animation({
          duration: 300,
          curve: Curve.EaseInOut
        })
        .onHover((isHover: boolean) => {
          this.isHovering = isHover
        })
      }
      
      // 出口设置对话框 - 放在Stack的最上层
      if (this.stateManager.getShowOutletDialog()) {
        QualityOutletDialog({
          showDialog: this.stateManager.getShowOutletDialog(),
          currentOutletIndex: this.stateManager.getCurrentOutletIndex(),
          onOutletSwitch: (direction: 'previous' | 'next') => {
            this.handleOutletSwitch(direction)
          },
          onOutletConfirm: () => {
            this.handleOutletConfirm()
          },
          onOutletCancel: () => {
            this.handleOutletCancel()
          }
        })
      }

      // 品质参数设置对话框
      if (this.showQualitySettingsDialog) {
        Stack() {
          QualitySettingsDialog({
            isVisible: this.showQualitySettingsDialog,
            onConfirm: () => {
              console.log('确认品质参数设置')
              // TODO: 实现保存参数逻辑
              this.showQualitySettingsDialog = false
            },
            onCancel: () => {
              this.showQualitySettingsDialog = false
            }
          })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(3000)
      }
    }
    .width('100%')
    .height('100%')
  }

  // ==================== 生命周期方法 ====================
  
  /**
   * 组件即将出现时的生命周期方法
   * 
   * 功能说明：
   * - 在组件即将出现时调用
   * - 初始化品质页面
   * - 设置默认状态
   * 
   * 使用场景：
   * - 页面初始化
   * - 组件创建
   * - 状态重置
   */
  aboutToAppear(): void {
    this.initializeQualityPage()
  }

  /**
   * 组件即将销毁时的生命周期方法
   * 
   * 功能说明：
   * - 在组件即将销毁时调用
   * - 清理资源和状态
   * - 触发页面销毁事件
   * 
   * 使用场景：
   * - 页面销毁
   * - 资源清理
   * - 状态重置
   */
  aboutToDisappear(): void {
    this.eventHandler.onPageDestroy()
  }

}
