/**
 * 命令类型定义
 * 对应48项目 interface.h 中的命令枚举
 * 定义上位机(HC)与下位机(FSM/IPM/WAM)之间的通信命令
 */

/**
 * HC → FSM 命令类型（上位机发送给水果分选机）
 * 命令范围：0x0000 - 0x00FF
 */
export enum HC_FSM_COMMAND_TYPE {
  // ==================== 无参数命令（0x0000 - 0x004F）====================
  /** 断开连接 */
  HC_CMD_DISPLAY_OFF = 0x0000,
  /** 数据清零 */
  HC_CMD_CLEAR_DATA = 0x0001,
  /** 保存当前数据（清理批量加工数据，保存装箱量） */
  HC_CMD_SAVE_CURRENT_DATA = 0x0002,
  /** 打开工程配置 */
  HC_CMD_PROJ_OPENED = 0x0003,
  /** 关闭工程配置 */
  HC_CMD_PROJ_CLOSED = 0x0004,
  /** 称重重置 */
  HC_CMD_WEIGHTRESET = 0x0005,
  /** 果杯测试开 */
  HC_CMD_TEST_CUP_ON = 0x0006,
  /** 果杯测试关 */
  HC_CMD_TEST_CUP_OFF = 0x0007,
  /** 果杯状态复位 */
  HC_CMD_CUPSTATERESET = 0x0008,

  /** 波形捕捉开 */
  HC_CMD_WAVE_FORM_ON = 0x0009,
  /** 波形捕捉关 */
  HC_CMD_WAVE_FORM_OFF = 0x000A,
  /** 数据追踪开 */
  HC_CMD_DATA_TRACKING_ON = 0x000B,
  /** 数据追踪关 */
  HC_CMD_DATA_TRACKING_OFF = 0x000C,
  /** 更新背景 */
  HC_CMD_BACK_LEARN = 0x000D,
  /** 网络关机 */
  HC_CMD_SHUT_DOWN = 0x000E,
  /** 获取水果实时分级信息开 */
  HC_CMD_GRADEINFO_ON = 0x000F,
  /** 获取水果实时分级信息关 */
  HC_CMD_GRADEINFO_OFF = 0x0010,
  /** 获取重量统计信息开 */
  HC_CMD_WEIGHTINFO_ON = 0x0011,
  /** 获取重量统计信息关 */
  HC_CMD_WEIGHTINFO_OFF = 0x0012,
  /** 内信号源开 */
  HC_CMD_SIMULATEDPULSE_ON = 0x0013,
  /** 内信号源关 */
  HC_CMD_SIMULATEDPULSE_OFF = 0x0014,
  /** 网络测试 */
  HC_CMD_TEST_NET = 0x0015,
  /** 电机使能 */
  HC_CMD_MOTOR_ENABLE = 0x0016,
  /** 跳转boot程序 */
  HC_CMD_BOOT_APP_TO_BOOT = 0x0017,
  /** 保存参数进Flash */
  HC_CMD_SAVE_PARAS = 0x0018,
  /** 连接 */
  HC_CMD_DISPLAY_ON = 0x0019,
  /** 请求FSM版本号 */
  HC_CMD_GETVERSION = 0x001A,
  /** 自动匹配开启 */
  HC_CMD_AUTO_MATCH_ON = 0x001B,
  /** 自动匹配关闭 */
  HC_CMD_AUTO_MATCH_OFF = 0x001C,
  /** 程序自锁开启 */
  HC_CMD_LOCK_ON = 0x001D,
  /** 程序自锁关闭 */
  HC_CMD_LOCK_OFF = 0x001E,
  /** 出果清框 */
  HC_CMD_EXIT_CLEAR = 0x001F,
  /** 清除水果队列 */
  HC_CMD_CLEAR_QUEUE = 0x0020,
  /** 切换大水果 */
  HC_CMD_SOFTVLAG_MOD = 0x0021,
  /** 切换小水果 */
  HC_CMD_SOFTVSML_MOD = 0x0022,

  // ==================== 带参数命令（0x0050 - ）====================
  /** 系统配置 (stSysConfig) */
  HC_CMD_SYS_CONFIG = 0x0050,
  /** 等级设置 (stGradeInfo) */
  HC_CMD_GRADE_INFO = 0x0051,
  /** 出口信息设置 (stExitInfo) */
  HC_CMD_EXIT_INFO = 0x0052,
  /** 重量信息设置 (stWeightBaseInfo) */
  HC_CMD_WEIGHT_INFO = 0x0053,
  /** 通道范围等参数设置 (stParas) */
  HC_CMD_PARAS_INFO = 0x0054,
  /** 电磁阀测试 (stVolveTest) */
  HC_CMD_TEST_VOLVE = 0x0055,
  /** 测试所有通道的同一出口 (stVolveTest) */
  HC_CMD_TEST_ALL_LANE_VOLVE = 0x0056,
  /** AD归零 (stResetAD) */
  HC_CMD_RESET_AD = 0x0057,
  /** 全局出口信息设置 (stGlobalExitInfo) */
  HC_CMD_GLOBAL_EXIT_INFO = 0x0058,
  /** 全局重量信息设置 (stGlobalWeightBaseInfo) */
  HC_CMD_GLOBAL_WEIGHT_INFO = 0x0059,
  /** 瑕疵参数设置 */
  HC_CMD_FlAWAREA_INFO = 0x005A,
  /** 初始化配置参数设置 */
  HC_CMD_GLOBAL_INFO = 0x005B,
  /** 电机使能参数 */
  HC_CMD_MOTOR_INFO = 0x005C,
  /** 品质等级设置（修改颜色） */
  HC_CMD_COLOR_GRADE_INFO = 0x005D,
  /** 模拟密度信息设置 */
  HC_CMD_DENSITY_INFO = 0x005E,
  /** 电机信息所有 */
  HC_CMD_MOTOR_INFO_ALL = 0x005F,

  /** 烧写boot程序 */
  HC_CMD_BOOT_FLASH_BURN = 0x0100,
  /** 网络烧写WAM */
  HC_CMD_WAM_FLASH_BURN = 0x011E,
  /** WAM网络跳转命令 */
  HC_CMD_WAM_APP_TO_BOOT = 0x011F
}

/**
 * FSM → HC 命令类型（水果分选机发送给上位机）
 * 命令范围：0x1000 -
 */
export enum FSM_HC_COMMAND_TYPE {
  /** 配置信息 (stGlobal) */
  FSM_CMD_CONFIG = 0x1000,
  /** 统计信息 (stStatistics) */
  FSM_CMD_STATISTICS = 0x1001,
  /** 水果实时分级信息 (stFruitGradeInfo) */
  FSM_CMD_GRADEINFO = 0x1002,
  /** 重量统计信息 (stWeightResult) */
  FSM_CMD_WEIGHTINFO = 0x1003,
  /** 波形数据 (stWaveInfo) */
  FSM_CMD_WAVEINFO = 0x1004,
  /** 版本不一致错误 */
  FSM_CMD_VERSIONERROR = 0x1005,
  /** 烧写FSM进度显示 */
  FSM_CMD_BURN_FLASH_PROGRESS = 0x1006,
  /** FSM调试信息 */
  FSM_CMD_BURN_DEBUG = 0x1007,
  /** FSM版本信息 */
  FSM_CMD_GETVERSION = 0x1008,
  /** Boot Flash进度 */
  FSM_CMD_BOOT_FLASH_PROGRESS = 0x1009
}

/**
 * IPM → HC 命令类型（图像处理机发送给上位机）
 * 命令范围：0x3000 -
 */
export enum IPM_HC_COMMAND_TYPE {
  /** 图像数据 (stImageInfo) */
  IPM_CMD_IMAGE = 0x3000,
  /** 自动白平衡系数 (stWhiteBalanceCoefficient) */
  IPM_CMD_AUTOBALANCE_COEFFICIENT = 0x3001,
  /** 颜色拼图 */
  IPM_CMD_IMAGE_SPLICE = 0x3002,
  /** 瑕疵拼图 */
  IPM_CMD_IMAGE_SPOT = 0x3003,
  /** 快门调节 */
  IPM_CMD_SHUTTER_ADJUST = 0x3004
}

/**
 * ACS → HMI 命令类型
 */
export enum ACS_HMI_COMMAND_TYPE {
  /** 出口停 */
  ACS_HMI_EXIT_STOP = 0x8000
}

/**
 * HC → IPM 命令类型
 */
export enum HC_IPM_COMMAND_TYPE {
  /** 单张图像采集 */
  HC_CMD_SINGLE_SAMPLE = 0x2000,
  /** 连续采集开 */
  HC_CMD_CONTINUOUS_SAMPLE_ON = 0x2001,
  /** 连续采集关 */
  HC_CMD_CONTINUOUS_SAMPLE_OFF = 0x2002,
  /** 显示blob开 */
  HC_CMD_SHOW_BLOB_ON = 0x2003,
  /** 相机自带白平衡 */
  HC_CMD_AUTOBALANCE_ON_CAMERA = 0x2004,
  /** 启动白平衡 */
  HC_CMD_AUTOBALANCE_ON = 0x2005,
  /** 单张采集有瑕疵的图 */
  HC_CMD_SINGLE_SAMPLE_SPOT = 0x2006,
  /** 选定标签区域的BGR均值 */
  HC_CMD_TAG_BGR = 0x2007,
  /** 命令IPM关机 */
  HC_CMD_SHUTDOWN = 0x2008,
  /** 发送瑕疵检测效果测试原始拼图 */
  HC_CMD_SPOT_DETECT_TEST = 0x2009,
  /** 快门调节开 */
  HC_CMD_SHUTTER_ADJUST_ON = 0x200A,
  /** 快门调节关 */
  HC_CMD_SHUTTER_ADJUST_OFF = 0x200B
}

export function getCommandName(cmdId: number): string {
  // Try to find in HC_FSM_COMMAND_TYPE
  if (HC_FSM_COMMAND_TYPE[cmdId]) {
    return HC_FSM_COMMAND_TYPE[cmdId];
  }
  // Try to find in FSM_HC_COMMAND_TYPE
  if (FSM_HC_COMMAND_TYPE[cmdId]) {
    return FSM_HC_COMMAND_TYPE[cmdId];
  }
  // Try to find in IPM_HC_COMMAND_TYPE
  if (IPM_HC_COMMAND_TYPE[cmdId]) {
    return IPM_HC_COMMAND_TYPE[cmdId];
  }
  // Try to find in ACS_HMI_COMMAND_TYPE
  if (ACS_HMI_COMMAND_TYPE[cmdId]) {
    return ACS_HMI_COMMAND_TYPE[cmdId];
  }
  // Try to find in HC_IPM_COMMAND_TYPE
  if (HC_IPM_COMMAND_TYPE[cmdId]) {
    return HC_IPM_COMMAND_TYPE[cmdId];
  }
  
  return `UNKNOWN_CMD_0x${cmdId.toString(16)}`;
}
