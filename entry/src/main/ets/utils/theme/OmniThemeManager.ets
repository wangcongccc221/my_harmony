/**
 * Omni-UI 主题管理器
 * 功能：基于 Omni-UI 主题系统，提供深色/浅色主题切换
 * 用途：统一管理应用的主题切换和主题配置
 */

import { OmniTheme, OmniThemeStyle } from '@wuba58/omni-ui'

// 主题类型枚举
export enum OmniThemeType {
  BLUE = 'blue',
  GREEN = 'green',
  PURPLE = 'purple',
  ORANGE = 'orange',
  PINK = 'pink',
  TEAL = 'teal',
  DEEP_BLUE = 'deep_blue',
  WARM_AMBER = 'warm_amber',
  MINIMAL = 'minimal',
  FRESH_GREEN = 'fresh_green',
  ELEGANT_PURPLE = 'elegant_purple',
  PROFESSIONAL_BLUE = 'professional_blue'
}

// 扩展的主题配置接口
// 说明：
// - navBg/pageBg/controlBg/sectionBg/sectionEmphasisBg 等为“语义化”配色，便于跨主题统一风格：
//   - navBg: 左侧导航/侧栏的统一底色（如果未使用按页面细分，会直接用这个）
//   - pageBg: 页面右侧主内容区的根背景色
//   - controlBg: 页面内部卡片、表格等控件的统一底色（例如 LevelTable 的 containerBg）
//   - sectionBg: 普通分区/卡片背景（如分区容器）
//   - sectionEmphasisBg: 更强调的分区/卡片背景（对比 sectionBg 更突出）
//   - tableHeaderBg/tableRowAltBg: 表头与斑马纹行背景
//   - buttonBarBg: 底部按钮条背景
// - navBgHome/navBgLevel/... 为“按页面细分”的左侧导航背景：
//   - 如果配置了当前页面对应字段，则优先生效；
//   - 否则回退到 navBg；
//   - 仅影响左侧导航区域，不影响右侧主内容区。
export interface ExtendedOmniThemeStyle extends OmniThemeStyle {
  // 背景色
  backgroundColor: string
  surfaceColor: string
  // 文字颜色
  textColor: string
  subTextColor: string
  // 边框颜色
  borderColor: string
  // 头部颜色
  headerColor: string
  // 可选的语义分区配色（未提供时以 surface/background 回退）
  sectionBg?: string            // 普通分区背景
  sectionEmphasisBg?: string    // 强调分区背景
  tableHeaderBg?: string        // 表头背景
  tableHeaderTextColor?: string  // 表头文字颜色
  tableRowAltBg?: string        // 斑马纹行背景
  buttonBarBg?: string          // 底部按钮条背景
  buttonBarTextColor?: string   // 底部按钮条文字颜色
  navBg?: string                // 左侧导航栏背景
  pageBg?: string               // 页面根背景
  controlBg?: string            // 页面内控件统一底色
  // 图表（可选）
  chartBg?: string              // 图表背景色
  chartLineColor?: string       // 折线图主线颜色
  // 按页面细分的左侧导航栏背景（可选）
  // 说明：以下字段若未设置，则在运行时回退到 navBg；仅作用于左侧导航区域，不影响右侧主内容区。
  // 建议：保持色彩轻浅、对比适中，避免喧宾夺主；可与页面主色(primary)形成弱对比。

  // 主页侧栏背景色（页面名："主页"）。
  // 回退顺序：navBgHome -> navBg -> surfaceColor。
  // 示例：'#E6F0FF'（浅蓝）。
  navBgHome?: string

  // 三层卡片颜色配置（可选）
  // 用于ThreeLayerCard组件的颜色定制，随主题切换自动更新
  cardBorderColor?: string           // 卡片边框颜色
  cardNumberTextColor?: string       // 卡片序号文字颜色
  cardWavePercentTextColor?: string  // 波浪百分比文字颜色
  cardDataListTextColor?: string     // 数据列表文字颜色
  cardWaveGradientLeft?: string      // 波浪渐变左色
  cardWaveGradientMid?: string       // 波浪渐变中间色
  cardWaveGradientRight?: string     // 波浪渐变右色

  // 等级页侧栏背景色（页面名："等级"）。
  // 回退顺序：navBgLevel -> navBg -> surfaceColor。
  // 示例：'#EAF7EF'（薄绿）。
  navBgLevel?: string

  // 品质页侧栏背景色（页面名："品质"）。
  // 回退顺序：navBgQuality -> navBg -> surfaceColor。
  // 示例：'#F1ECF7'（淡紫）。
  navBgQuality?: string

  // 历史加工页侧栏背景色（页面名："历史加工"）。
  // 回退顺序：navBgHistory -> navBg -> surfaceColor。
  // 示例：'#FFF6DE'（米杏）。
  navBgHistory?: string

  // 更多页侧栏背景色（页面名："更多"）。
  // 回退顺序：navBgMore -> navBg -> surfaceColor。
  // 示例：'#F3F5F8'（淡灰）。
  navBgMore?: string

  // 等级页专属配色（可选）
  // levelSectionBg: 等级页分区容器/大卡片背景；未配则回退 sectionBg，再回退 surfaceColor。
  // levelControlBg: 等级页内部控件/小卡片背景（表单、报警、标准、右侧卡片等）；未配则回退 controlBg。
  // levelDialogBg: 等级页弹窗背景；未配则回退 surfaceColor。
  levelSectionBg?: string
  levelControlBg?: string
  levelDialogBg?: string
}


// 蓝色主题配置 - 现代科技深色系
const BLUE_THEME: ExtendedOmniThemeStyle = {
  primary: '#4A90E2',
  primaryColorWithOpacity: (opacity: number) => `rgba(74, 144, 226, ${opacity})`,
  fontSizeXs: 10,
  fontSizeSm: 12,
  fontSizeMd: 14,
  fontSizeLg: 16,
  fontSizeXl: 20,
  backgroundColor: '#1A233A',
  surfaceColor: '#2A3A5B',
  textColor: '#E0E6F0',
  subTextColor: '#9CA3AF',
  borderColor: '#4C5774',
  headerColor: '#233150',
  sectionBg: '#23314A',
  sectionEmphasisBg: '#1F2A42',
  tableHeaderBg: '#2F4166',
  tableHeaderTextColor: '#FFFFFF',
  tableRowAltBg: '#21304A',
  buttonBarBg: '#223053',
  // 布局分区：左侧导航/页面根/控件底色
  // - navBg: 左侧导航栏背景（若存在 navBgHome 等页面细分色，则优先细分色）
  // - pageBg: 右侧主内容区根背景
  // - controlBg: 页面内部控件（卡片/表格等）的统一底色
  navBg: '#E6F0FF',
  pageBg: '#2F4166',
  controlBg: '#21304A',
  chartBg: '#21304A',
  chartLineColor: '#4A90E2',
  
  // 三层卡片颜色配置
  cardBorderColor: '#4C5774',                    // 卡片边框颜色 - 中蓝色
  cardNumberTextColor: '#E0E6F0',                // 卡片序号文字颜色 - 浅色
  cardWavePercentTextColor: '#9CA3AF',           // 波浪百分比文字颜色 - 中灰色
  cardDataListTextColor: '#E0E6F0',              // 数据列表文字颜色 - 浅色
  cardWaveGradientLeft: 'rgba(74, 144, 226, 0.7)',   // 波浪渐变左色 - 蓝色
  cardWaveGradientMid: 'rgba(52, 152, 219, 0.8)',    // 波浪渐变中间色 - 深蓝色
  cardWaveGradientRight: 'rgba(74, 144, 226, 0.7)'   // 波浪渐变右色 - 蓝色
}

// 绿色主题配置 - 自然深色系
const GREEN_THEME: ExtendedOmniThemeStyle = {
  primary: '#50C878',
  primaryColorWithOpacity: (opacity: number) => `rgba(80, 200, 120, ${opacity})`,
  fontSizeXs: 10,
  fontSizeSm: 12,
  fontSizeMd: 14,
  fontSizeLg: 16,
  fontSizeXl: 20,
  backgroundColor: '#1B322C',
  surfaceColor: '#2C4F42',
  textColor: '#ECF8E8',
  subTextColor: '#A3B5A1',
  borderColor: '#446E5C',
  headerColor: '#11211E',
  sectionBg: '#1A3B31',
  sectionEmphasisBg: '#16342B',
  tableHeaderBg: '#275546',
  tableHeaderTextColor: '#FFFFFF',
  tableRowAltBg: '#17392F',
  buttonBarBg: '#183D32',
  navBg: '#E6F0FF',
  pageBg: '#F5F6F8',
  controlBg: '#FFFFFF',
  chartBg: '#FFFFFF',
  chartLineColor: '#50C878',
  
  // 三层卡片颜色配置
  cardBorderColor: '#446E5C',                    // 卡片边框颜色 - 绿色
  cardNumberTextColor: '#ECF8E8',                // 卡片序号文字颜色 - 浅绿色
  cardWavePercentTextColor: '#A3B5A1',           // 波浪百分比文字颜色 - 中绿色
  cardDataListTextColor: '#ECF8E8',              // 数据列表文字颜色 - 浅绿色
  cardWaveGradientLeft: 'rgba(80, 200, 120, 0.7)',   // 波浪渐变左色 - 绿色
  cardWaveGradientMid: 'rgba(50, 150, 100, 0.8)',    // 波浪渐变中间色 - 深绿色
  cardWaveGradientRight: 'rgba(80, 200, 120, 0.7)'   // 波浪渐变右色 - 绿色
}

// 紫色主题配置 - 优雅深色系
const PURPLE_THEME: ExtendedOmniThemeStyle = {
  primary: '#9370DB',
  primaryColorWithOpacity: (opacity: number) => `rgba(147, 112, 219, ${opacity})`,
  fontSizeXs: 10,
  fontSizeSm: 12,
  fontSizeMd: 14,
  fontSizeLg: 16,
  fontSizeXl: 20,
  backgroundColor: '#2D1E40',
  surfaceColor: '#43325B',
  textColor: '#F0EBF5',
  subTextColor: '#B3A2C7',
  borderColor: '#645582',
  headerColor: '#1F142D',
  sectionBg: '#34214D',
  sectionEmphasisBg: '#2A1A40',
  tableHeaderBg: '#4B3570',
  tableHeaderTextColor: '#FFFFFF',
  tableRowAltBg: '#2C1E44',
  buttonBarBg: '#38275A',
  navBg: '#E6F0FF',
  pageBg: '#F5F6F8',
  controlBg: '#FFFFFF'
  ,chartBg: '#FFFFFF'
  ,chartLineColor: '#9370DB'
}

// 橙色主题配置 - 活力深色系
const ORANGE_THEME: ExtendedOmniThemeStyle = {
  primary: '#FF8C42',
  primaryColorWithOpacity: (opacity: number) => `rgba(255, 140, 66, ${opacity})`,
  fontSizeXs: 10,
  fontSizeSm: 12,
  fontSizeMd: 14,
  fontSizeLg: 16,
  fontSizeXl: 20,
  backgroundColor: '#3A2B1A',
  surfaceColor: '#5E482D',
  textColor: '#FDEFE1',
  subTextColor: '#C4B29B',
  borderColor: '#8C6C49',
  headerColor: '#2E2214',
  sectionBg: '#4A3722',
  sectionEmphasisBg: '#3F2E1B',
  tableHeaderBg: '#6B4E2E',
  tableHeaderTextColor: '#FFFFFF',
  tableRowAltBg: '#3A2A1A',
  buttonBarBg: '#4F3B24',
  navBg: '#E6F0FF',
  pageBg: '#F5F6F8',
  controlBg: '#FFFFFF'
  ,chartBg: '#FFFFFF'
  ,chartLineColor: '#FF8C42'
}

// 粉色主题配置 - 温柔深色系
const PINK_THEME: ExtendedOmniThemeStyle = {
  primary: '#E57373',
  primaryColorWithOpacity: (opacity: number) => `rgba(229, 115, 115, ${opacity})`,
  fontSizeXs: 10,
  fontSizeSm: 12,
  fontSizeMd: 14,
  fontSizeLg: 16,
  fontSizeXl: 20,
  backgroundColor: '#3A242B',
  surfaceColor: '#5A3B43',
  textColor: '#F7EBEB',
  subTextColor: '#C9B7B7',
  borderColor: '#85606A',
  headerColor: '#2D1A21',
  sectionBg: '#452A31',
  sectionEmphasisBg: '#3A2329',
  tableHeaderBg: '#623B45',
  tableHeaderTextColor: '#FFFFFF',
  tableRowAltBg: '#372127',
  buttonBarBg: '#4A3037',
  navBg: '#E6F0FF',
  pageBg: '#F5F6F8',
  controlBg: '#FFFFFF'
  ,chartBg: '#FFFFFF'
  ,chartLineColor: '#E57373'
}

// 青色主题配置 - 清新深色系
const TEAL_THEME: ExtendedOmniThemeStyle = {
  primary: '#2DB5A8',
  primaryColorWithOpacity: (opacity: number) => `rgba(45, 181, 168, ${opacity})`,
  fontSizeXs: 10,
  fontSizeSm: 12,
  fontSizeMd: 14,
  fontSizeLg: 16,
  fontSizeXl: 20,
  backgroundColor: '#0F2A28',
  surfaceColor: '#1A3F3C',
  textColor: '#F0FFFE',
  subTextColor: '#B8D5D2',
  borderColor: '#3A6B67',
  headerColor: '#0A1F1D',
  sectionBg: '#133533',
  sectionEmphasisBg: '#102C2B',
  tableHeaderBg: '#1E4C49',
  tableHeaderTextColor: '#FFFFFF',
  tableRowAltBg: '#102E2C',
  buttonBarBg: '#143A37',
  navBg: '#E6F0FF',
  pageBg: '#F5F6F8',
  controlBg: '#FFFFFF'
  ,chartBg: '#FFFFFF'
  ,chartLineColor: '#2DB5A8'
}

// 方案一：冷静深蓝风格（科技感）
const DEEP_BLUE_THEME: ExtendedOmniThemeStyle = {
  primary: '#2F6BFF',
  primaryColorWithOpacity: (opacity: number) => `rgba(47, 107, 255, ${opacity})`,
  fontSizeXs: 12,
  fontSizeSm: 14,
  fontSizeMd: 16,
  fontSizeLg: 18,
  fontSizeXl: 22,
  headerColor: '#14202C',
  backgroundColor: '#EBF0F6',
  surfaceColor: '#FFFFFF',
  borderColor: '#D6DEE8',
  textColor: '#0F1C2A',
  subTextColor: '#4B5B6B',
  tableHeaderBg: '#E6F0FF',
  tableHeaderTextColor: '#0F1C2A',
  navBg: '#E6F0FF',
  pageBg: '#F5F6F8',
  controlBg: '#FFFFFF'
  ,chartBg: '#FFFFFF'
  ,chartLineColor: '#2F6BFF'
}

// 方案二：暖色质感风格（亲和力强）
// 注：此为默认主题（currentTheme 缺省为 WARM_AMBER）。
// 配色分组：
// - 基础色：primary、textColor、subTextColor、borderColor、surfaceColor、backgroundColor
// - 语义色：sectionBg、sectionEmphasisBg、tableHeaderBg、tableRowAltBg、buttonBarBg
// - 布局色：navBg（左侧导航）、pageBg（页面主背景）、controlBg（控件统一底色）
const WARM_AMBER_THEME: ExtendedOmniThemeStyle = {
  primary: '#EA7A10',
  primaryColorWithOpacity: (opacity: number) => `rgba(234, 122, 16, ${opacity})`,
  fontSizeXs: 12,
  fontSizeSm: 14,
  fontSizeMd: 16,
  fontSizeLg: 18,
  fontSizeXl: 22,
  headerColor: '#6F320F',
  backgroundColor: '#F7E7C7',
  surfaceColor: '#FFFFFF',
  borderColor: '#DFC49E',
  textColor: '#2F221B',
  subTextColor: '#706152',
  sectionBg: '#FFF6DE',
  sectionEmphasisBg: '#FFE9C2',
  tableHeaderBg: '#FFF2D6',
  tableHeaderTextColor: '#2F221B',
  tableRowAltBg: '#FFF9EB',
  buttonBarBg: '#FFF2D6',
  navBg: '#E6F0FF',         // 左侧浅蓝（示范）
  pageBg: '#E9F6EF',        // 页面根背景：浅绿
  controlBg: '#FFFFFF',     // 卡片/表格等统一白色
  chartBg: '#FFFFFF',
  chartLineColor: '#EA7A10',
  
  // 三层卡片颜色配置
  cardBorderColor: '#DFC49E',                    // 卡片边框颜色 - 琥珀色
  cardNumberTextColor: '#2F221B',                // 卡片序号文字颜色 - 深色
  cardWavePercentTextColor: '#706152',           // 波浪百分比文字颜色 - 中色
  cardDataListTextColor: '#2F221B',              // 数据列表文字颜色 - 深色
  cardWaveGradientLeft: 'rgba(234, 122, 16, 0.7)',   // 波浪渐变左色 - 琥珀色
  cardWaveGradientMid: 'rgba(200, 100, 10, 0.8)',    // 波浪渐变中间色 - 深琥珀色
  cardWaveGradientRight: 'rgba(234, 122, 16, 0.7)',  // 波浪渐变右色 - 琥珀色
  
  // 等级页专属默认值（不设则按回退规则取通用语义色）
  levelSectionBg: '#FFF6DE',
  levelControlBg: '#FFFFFF',
  levelDialogBg: '#FFFFFF'
}

// 方案三：极简黑白风格（现代/企业）
const MINIMAL_THEME: ExtendedOmniThemeStyle = {
  primary: '#0066FF',
  primaryColorWithOpacity: (opacity: number) => `rgba(0, 102, 255, ${opacity})`,
  fontSizeXs: 12,
  fontSizeSm: 14,
  fontSizeMd: 16,
  fontSizeLg: 18,
  fontSizeXl: 22,
  headerColor: '#000000',
  backgroundColor: '#F2F3F5',
  surfaceColor: '#FFFFFF',
  borderColor: '#D9D9D9',
  textColor: '#0D0D0D',
  subTextColor: '#595959',
  tableHeaderBg: '#F2F3F5',
  tableHeaderTextColor: '#0D0D0D',
  navBg: '#E6F0FF',
  pageBg: '#F5F6F8',
  controlBg: '#FFFFFF'
  ,chartBg: '#FFFFFF'
  ,chartLineColor: '#0066FF'
}

// 方案四：清新绿意风格（自然/生活类应用）
const FRESH_GREEN_THEME: ExtendedOmniThemeStyle = {
  primary: '#3DAE43',
  primaryColorWithOpacity: (opacity: number) => `rgba(61, 174, 67, ${opacity})`,
  fontSizeXs: 12,
  fontSizeSm: 14,
  fontSizeMd: 16,
  fontSizeLg: 18,
  fontSizeXl: 22,
  headerColor: '#25462A',
  backgroundColor: '#E9F6EF',
  surfaceColor: '#FFFFFF',
  borderColor: '#CFE1D6',
  textColor: '#161616',
  subTextColor: '#415A45',
  tableHeaderBg: '#E9F6EF',
  tableHeaderTextColor: '#161616',
  navBg: '#E6F0FF',
  pageBg: '#F5F6F8',
  controlBg: '#FFFFFF'
  ,chartBg: '#FFFFFF'
  ,chartLineColor: '#3DAE43'
}

// 方案五：优雅紫调风格（艺术/教育类）
const ELEGANT_PURPLE_THEME: ExtendedOmniThemeStyle = {
  primary: '#8858D6',
  primaryColorWithOpacity: (opacity: number) => `rgba(136, 88, 214, ${opacity})`,
  fontSizeXs: 12,
  fontSizeSm: 14,
  fontSizeMd: 16,
  fontSizeLg: 18,
  fontSizeXl: 22,
  headerColor: '#3F3364',
  backgroundColor: '#F1ECF7',
  surfaceColor: '#FFFFFF',
  borderColor: '#D6CBE7',
  textColor: '#241933',
  subTextColor: '#6E5E82',
  tableHeaderBg: '#F1ECF7',
  tableHeaderTextColor: '#241933',
  navBg: '#E6F0FF',
  pageBg: '#F5F6F8',
  controlBg: '#FFFFFF'
  ,chartBg: '#FFFFFF'
  ,chartLineColor: '#8858D6'
}

// 专业蓝色主题配置 - 深蓝色专业配色方案
const PROFESSIONAL_BLUE_THEME: ExtendedOmniThemeStyle = {
  primary: '#1890FF',                    // 强调色：蓝色
  primaryColorWithOpacity: (opacity: number) => `rgba(24, 144, 255, ${opacity})`,
  fontSizeXs: 10,
  fontSizeSm: 12,
  fontSizeMd: 14,
  fontSizeLg: 16,
  fontSizeXl: 20,
  backgroundColor: '#E6F3FF',             // 内容区背景：浅蓝色（更明显）
  surfaceColor: '#F0F8FF',               // 卡片背景：浅蓝色
  textColor: '#1E3A5F',                  // 主文字：深蓝色
  subTextColor: '#4A6FA5',               // 副文字：中蓝色
  borderColor: '#B3D9FF',                // 边框：浅蓝色
  headerColor: '#2C4A6B',                // 顶部任务栏：中蓝色（比深蓝浅一点）
  sectionBg: '#F0F8FF',                  // 分区背景：浅蓝色
  sectionEmphasisBg: '#E6F3FF',          // 强调分区：更浅的蓝色
  tableHeaderBg: '#1E3A5F',              // 表头：深蓝色
  tableHeaderTextColor: '#FFFFFF',        // 表头文字：白色
  tableRowAltBg: '#F8FBFF',              // 表格斑马纹：极浅蓝色
  buttonBarBg: '#2C4A6B',                // 底部状态栏：中蓝色（与顶部一致）
  buttonBarTextColor: '#FFFFFF',          // 底部状态栏文字：白色（在深色背景上清晰）
  // 布局分区配色
  navBg: '#2C4A6B',                      // 左边导航栏：中蓝色（比深蓝浅一点）
  pageBg: '#E6F3FF',                     // 主页背景：浅蓝色（更明显）
  controlBg: '#F0F8FF',                  // 控件背景：浅蓝色
  chartBg: '#F0F8FF',                    // 图表背景：浅蓝色
  chartLineColor: '#1890FF',              // 图表线条：蓝色
  
  // 三层卡片颜色配置
  cardBorderColor: '#B3D9FF',            // 卡片边框：浅蓝色
  cardNumberTextColor: '#1E3A5F',        // 卡片序号：深蓝色
  cardWavePercentTextColor: '#4A6FA5',   // 波浪百分比：中蓝色
  cardDataListTextColor: '#1E3A5F',      // 数据列表：深蓝色
  cardWaveGradientLeft: 'rgba(24, 144, 255, 0.7)',   // 波浪渐变左：蓝色
  cardWaveGradientMid: 'rgba(30, 58, 95, 0.8)',      // 波浪渐变中：深蓝色
  cardWaveGradientRight: 'rgba(47, 79, 79, 0.9)',    // 波浪渐变右：深灰色
  
  // 页面细分导航背景（可选）
  navBgHome: '#2C4A6B',                   // 主页导航：中蓝色
  navBgLevel: '#2C4A6B',                  // 等级页导航：中蓝色
  navBgQuality: '#2C4A6B',                // 品质页导航：中蓝色
  navBgMore: '#2C4A6B',                   // 更多页导航：中蓝色
  
  // 等级页专属配色
  levelSectionBg: '#F0F8FF',              // 等级页分区：浅蓝色
  levelControlBg: '#E6F3FF',              // 等级页控件：更浅的蓝色
  levelDialogBg: '#F0F8FF'                // 等级页弹窗：浅蓝色
}

// 主题配置数据
const THEME_CONFIGS: Record<OmniThemeType, ExtendedOmniThemeStyle> = {
  [OmniThemeType.BLUE]: BLUE_THEME,
  [OmniThemeType.GREEN]: GREEN_THEME,
  [OmniThemeType.PURPLE]: PURPLE_THEME,
  [OmniThemeType.ORANGE]: ORANGE_THEME,
  [OmniThemeType.PINK]: PINK_THEME,
  [OmniThemeType.TEAL]: TEAL_THEME,
  [OmniThemeType.DEEP_BLUE]: DEEP_BLUE_THEME,
  [OmniThemeType.WARM_AMBER]: WARM_AMBER_THEME,
  [OmniThemeType.MINIMAL]: MINIMAL_THEME,
  [OmniThemeType.FRESH_GREEN]: FRESH_GREEN_THEME,
  [OmniThemeType.ELEGANT_PURPLE]: ELEGANT_PURPLE_THEME,
  [OmniThemeType.PROFESSIONAL_BLUE]: PROFESSIONAL_BLUE_THEME
}

// 主题变化回调函数类型
export type ThemeChangeCallback = (theme: OmniThemeType) => void

// Omni-UI 主题管理器类
export class OmniThemeManager {
  private static instance: OmniThemeManager
  private currentTheme: OmniThemeType = OmniThemeType.WARM_AMBER
  private themeChangeCallbacks: ThemeChangeCallback[] = []  // 主题变化回调列表
  private themeChangeFlag: number = 0  // 主题变化标志，每次主题变化时递增
  
  // 单例模式
  static getInstance(): OmniThemeManager {
    if (!OmniThemeManager.instance) {
      OmniThemeManager.instance = new OmniThemeManager()
    }
    return OmniThemeManager.instance
  }
  
  /**
   * 初始化主题系统
   */
  init(): void {
    // 初始化 Omni-UI 主题系统
    OmniTheme.init()
    
    // 设置当前主题
    this.applyTheme(this.currentTheme)
  }
  
  /**
   * 获取当前主题配置
   */
  getCurrentTheme(): ExtendedOmniThemeStyle {
    return THEME_CONFIGS[this.currentTheme]
  }
  
  /**
   * 获取当前主题类型
   */
  getCurrentThemeType(): OmniThemeType {
    return this.currentTheme
  }
  
  /**
   * 设置主题
   */
  setTheme(theme: OmniThemeType): void {
    const previousTheme = this.currentTheme
    this.currentTheme = theme
    this.applyTheme(theme)
    
    // 更新主题变化标志
    this.themeChangeFlag++
    
    // 通知所有注册的回调函数
    this.notifyThemeChange(theme)
    
    console.log(`Omni-UI 主题已切换到: ${theme}, 标志: ${this.themeChangeFlag}`)
  }
  
  /**
   * 切换主题（在彩色主题之间循环切换）
   */
  toggleTheme(): void {
    const themes: OmniThemeType[] = [
      OmniThemeType.BLUE,
      OmniThemeType.GREEN,
      OmniThemeType.PURPLE,
      OmniThemeType.ORANGE,
      OmniThemeType.PINK,
      OmniThemeType.TEAL
    ]
    const currentIndex = themes.indexOf(this.currentTheme)
    const nextIndex = (currentIndex + 1) % themes.length
    this.currentTheme = themes[nextIndex]
    this.applyTheme(this.currentTheme)
    
    // 更新主题变化标志
    this.themeChangeFlag++
    
    // 通知所有注册的回调函数
    this.notifyThemeChange(this.currentTheme)
    
    console.log(`Omni-UI 主题已切换到: ${this.currentTheme}, 标志: ${this.themeChangeFlag}`)
  }
  
  /**
   * 应用主题到 Omni-UI 系统
   */
  private applyTheme(theme: OmniThemeType): void {
    const themeConfig = THEME_CONFIGS[theme]
    
    // 设置 Omni-UI 主题样式
    OmniTheme.setThemeStyle({
      primary: themeConfig.primary,
      primaryColorWithOpacity: themeConfig.primaryColorWithOpacity,
      fontSizeXs: themeConfig.fontSizeXs,
      fontSizeSm: themeConfig.fontSizeSm,
      fontSizeMd: themeConfig.fontSizeMd,
      fontSizeLg: themeConfig.fontSizeLg,
      fontSizeXl: themeConfig.fontSizeXl
    })
  }
  
  /**
   * 获取所有可用主题
   */
  getAllThemes(): Record<OmniThemeType, ExtendedOmniThemeStyle> {
    return THEME_CONFIGS
  }
  
  /**
   * 获取主题名称
   */
  getThemeName(theme: OmniThemeType): string {
    const themeNames: Record<OmniThemeType, string> = {
      [OmniThemeType.BLUE]: '蓝色主题',
      [OmniThemeType.GREEN]: '绿色主题',
      [OmniThemeType.PURPLE]: '紫色主题',
      [OmniThemeType.ORANGE]: '橙色主题',
      [OmniThemeType.PINK]: '粉色主题',
      [OmniThemeType.TEAL]: '青色主题',
      [OmniThemeType.DEEP_BLUE]: '冷静深蓝',
      [OmniThemeType.WARM_AMBER]: '暖色质感',
      [OmniThemeType.MINIMAL]: '极简黑白',
      [OmniThemeType.FRESH_GREEN]: '清新绿意',
      [OmniThemeType.ELEGANT_PURPLE]: '优雅紫调',
      [OmniThemeType.PROFESSIONAL_BLUE]: '专业蓝色'
    }
    return themeNames[theme] || '未知主题'
  }
  
  /**
   * 获取主题变化标志
   */
  getThemeChangeFlag(): number {
    return this.themeChangeFlag
  }
  
  /**
   * 注册主题变化回调
   */
  addThemeChangeCallback(callback: ThemeChangeCallback): void {
    this.themeChangeCallbacks.push(callback)
  }
  
  /**
   * 移除主题变化回调
   */
  removeThemeChangeCallback(callback: ThemeChangeCallback): void {
    const index = this.themeChangeCallbacks.indexOf(callback)
    if (index > -1) {
      this.themeChangeCallbacks.splice(index, 1)
    }
  }
  
  /**
   * 通知所有注册的回调函数主题已变化
   */
  private notifyThemeChange(theme: OmniThemeType): void {
    this.themeChangeCallbacks.forEach(callback => {
      try {
        callback(theme)
      } catch (error) {
        console.error('主题变化回调执行失败:', error)
      }
    })
  }
}
