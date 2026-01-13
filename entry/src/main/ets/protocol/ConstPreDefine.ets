/**
 * 协议常量定义
 * 对应48项目 interface.h 中的 ConstPreDefine 类
 * 定义上位机与下位机通信的基本常量
 */

/**
 * 协议常量类
 * 包含所有通信协议相关的常量定义
 */
export class ConstPreDefine {
  // ==================== ID 定义 ====================
  /** 上位机ID */
  static readonly HC_ID: number = 0x1000

  /** ACS ID */
  static readonly ACS_ID: number = 0x2000

  /** SIM ID */
  static readonly SIM_ID: number = 0x1100

  /** WAM ID */
  static readonly WAM_ID: number = 0x01D0

  /** SIMPLC ID */
  static readonly SIMPLC_ID: number = 0x2100

  // ==================== 端口定义 ====================
  /** 上位机端口号1 */
  static readonly HC_PORT1_NUM: number = 1127

  /** 上位机端口号2 */
  static readonly HC_PORT2_NUM: number = 1128

  /** ACS 端口号 */
  static readonly ACS_PORT_NUM: number = 4127

  /** FSM 端口号 */
  static readonly FSM_PORT_NUM: number = 1279

  /** FSM 端口号2 */
  static readonly FSM_PORT_NUM_2: number = 1269

  /** IPM 端口号 */
  static readonly IPM_PORT_NUM: number = 1289

  /** SIM 端口号 */
  static readonly SIM_PORT_NUM: number = 1129

  /** WAM 端口号 */
  static readonly WAM_PORT_NUM: number = 1299

  /** WAM 端口号2 */
  static readonly WAM_PORT_NUM_2: number = 1270

  /** 水果分级信息端口号 */
  static readonly FRUITGRADEINFO_PORT_NUM: number = 5000

  /** PLC 服务器端口号 */
  static readonly PLC_SERVER_PORT_NUM: number = 8008

  /** PLC 出口端口号 */
  static readonly PLC_EXIT_PORT_NUM: number = 8088

  /** PLC 客户端端口号 */
  static readonly PLC_CLIENT_PORT_NUM: number = 6006

  // ==================== 系统限制常量 ====================
  /** 最大子系统数 */
  static readonly MAX_SUBSYS_NUM: number = 4

  /** 单个子系统最多IPM个数 */
  static readonly MAX_IPM_NUM: number = 12

  /** 单个子系统支持最大通道数 */
  static readonly MAX_CHANNEL_NUM: number = 12

  /** 单个IPM支持最大通道数 */
  static readonly CHANNEL_NUM: number = 2

  /** 单个IPM最多带的相机个数 */
  static readonly MAX_CAMERA_NUM: number = 9

  /** 单个IPM最多带的彩色相机个数 */
  static readonly MAX_COLOR_CAMERA_NUM: number = 3

  /** 单个IPM最多带的红外相机个数 */
  static readonly MAX_NIR_CAMERA_NUM: number = 6

  /** 单个IPM最多带相机种类数 */
  static readonly MAX_CAMERA_TYPE: number = 3

  /** 每种相机不同方位相机数 */
  static readonly MAX_CAMERA_DIRECTION: number = 3

  // ==================== 等级/出口限制 ====================
  /** 品质最多等级数 */
  static readonly MAX_QUALITY_GRADE_NUM: number = 16

  /** 尺寸（重量）最多等级数 */
  static readonly MAX_SIZE_GRADE_NUM: number = 16

  /** 最多出口数（标准版48，大型版64） */
  static readonly MAX_EXIT_NUM: number = 48

  /** ACS 最多出口数 */
  static readonly ACS_MAX_EXIT_NUM: number = 64

  /** 最大出口显示名称长度 */
  static readonly MAX_EXIT_DISPLAYNAME_LENGTH: number = 20

  /** 最大出口附加名称长度 */
  static readonly MAX_EXIT_ADDITIONALNAME_LENGTH: number = 100

  // ==================== 颜色/品质参数 ====================
  /** 颜色最多区间数（红，黄，绿） */
  static readonly MAX_COLOR_INTERVAL_NUM: number = 3

  /** 最多果杯个数 */
  static readonly MAX_CUP_NUM: number = 10

  /** 最大颜色显示界面果杯个数 */
  static readonly MAX_SPLICE_CUP_NUM: number = 19

  /** 去标签参数个数 */
  static readonly PARAS_TAGINFO_NUM: number = 6

  /** 每页字节数 */
  static readonly BYTE_NUM_PER_PAGE: number = 64

  /** FSM版本信息长度 */
  static readonly BYTE_NUM_FSM_VERSION: number = 64

  /** 最大标签数 */
  static readonly MAX_LABEL_NUM: number = 4

  // ==================== 等级数量定义 ====================
  /** 颜色等级数 */
  static readonly MAX_COLOR_GRADE_NUM: number = 16

  /** 形状等级数 */
  static readonly MAX_SHAPE_GRADE_NUM: number = 6

  /** 瑕疵等级数 */
  static readonly MAX_FLAWAREA_GRADE_NUM: number = 6

  /** 擦伤等级数 */
  static readonly MAX_BRUISE_GRADE_NUM: number = 6

  /** 腐烂等级数 */
  static readonly MAX_ROT_GRADE_NUM: number = 6

  /** 密度等级数 */
  static readonly MAX_DENSITY_GRADE_NUM: number = 6

  /** 糖度等级数 */
  static readonly MAX_SUGAR_GRADE_NUM: number = 6

  /** 酸度等级数 */
  static readonly MAX_ACIDITY_GRADE_NUM: number = 6

  /** 空心等级数 */
  static readonly MAX_HOLLOW_GRADE_NUM: number = 6

  /** 浮皮等级数 */
  static readonly MAX_SKIN_GRADE_NUM: number = 6

  /** 褐变等级数 */
  static readonly MAX_BROWN_GRADE_NUM: number = 6

  /** 糖心等级数 */
  static readonly MAX_TANGXIN_GRADE_NUM: number = 6

  /** 硬度等级数 */
  static readonly MAX_RIGIDITY_GRADE_NUM: number = 6

  /** 含水率等级数 */
  static readonly MAX_WATER_GRADE_NUM: number = 6

  // ==================== 水果类型 ====================
  /** 水果种类最多数（大种类） */
  static readonly MAX_FRUIT_TYPE: number = 32

  /** 水果大类数量 */
  static readonly MAX_FRUIT_TYPE_MAJOR_CLASS_NUM: number = 32

  /** 水果子类数量 */
  static readonly MAX_FRUIT_TYPE_SUB_CLASS_NUM: number = 8

  /** 水果名称最大长度 */
  static readonly MAX_FRUIT_NAME_LENGTH: number = 50

  /** 客户信息最大长度 */
  static readonly MAX_CLIENTINFO_LENGTH: number = 20

  /** 客户信息最大长度（旧版） */
  static readonly MAX_CLIENTINFO_LENGTH_OLD: number = 50

  // ==================== 其他常量 ====================
  /** 拼图最大长度 */
  static readonly CAPTURE_WIDTH: number = 2560

  /** 拼图最大宽度 */
  static readonly CAPTURE_HEIGHT: number = 1920

  /** 最大文本长度 */
  static readonly MAX_TEXT_LENGTH: number = 12

  /** 最大水果文本长度 */
  static readonly MAX_FRUIT_TEXT_LENGTH: number = 20

  /** IPM初始化相机时间 (ms) */
  static readonly IPM_INIT_TIME: number = 4000

  /** 波形最大宽度 */
  static readonly WAVE_POINT_WIDTH: number = 256

  /** 最大通知长度 */
  static readonly MAX_NOTICE_LENGTH: number = 30

  /** PLC发送数据数量 */
  static readonly PLC_SEND_DATA_NUM: number = 16

  // ==================== 分选依据标志位 ====================
  /** 重量（克） */
  static readonly GRADE_WEIGHTGRAM_ON: number = 1

  /** 重量（个） */
  static readonly GRADE_WEIGHTGE_ON: number = 2

  /** 尺寸（直径） */
  static readonly GRADE_DIAMETER_ON: number = 4

  /** 尺寸（面积） */
  static readonly GRADE_AREA_ON: number = 8

  /** 尺寸（体积） */
  static readonly GRADE_VOLUME_ON: number = 16

  // ==================== 版本号 ====================
  /** 版本号，用于比较 */
  static readonly VERSION: number = 40201

  /** 版本号显示 */
  static readonly VERSION_SHOW: string = 'V4.02.01'

  // ==================== FSM模块类型 ====================
  /** DSP模块 - DM642 */
  static readonly FSM_DSP_MODULE: number = 1

  /** STM32模块 - H7 */
  static readonly FSM_STM32_MODULE: number = 2

  // ==================== IP地址（可配置） ====================
  /** 上位机IP地址 */
  static HC_IP_ADDR: string = '192.168.0.0'

  /** ACS IP地址 */
  static ACS_IP_ADDR: string = '192.168.0.1'

  /** 下位机IP地址模板 */
  static LC_IP_ADDR_TEMPLATE: string = '192.168.0.'

  /** WAM IP地址 */
  static WAM_IP_ADDR: string = '192.168.0.208'

  /** SIM IP地址 */
  static SIM_IP_ADDR: string = '192.168.0.14'

  /** 水果分级信息IP地址 */
  static FRUITGRADEINFO_IP_ADDR: string = '192.168.0.100'

  /** PLC服务器IP地址 */
  static PLC_SERVER_IP_ADDR: string = '192.168.0.200'

  /** PLC客户端IP地址 */
  static PLC_CLIENT_IP_ADDR: string = '192.168.0.201'

  /** 广播地址 */
  static BROADCAST_IP_ADDR: string = '255.255.255.255'

  /** 本地广播地址 */
  static BROADCAST_LOCAL_IP_ADDR: string = '192.168.0.255'

  // ==================== 工具方法 ====================
  /**
   * 根据子系统ID获取子系统索引（0-based）
   * @param subsysId 子系统ID（格式 0x0B00）
   * @returns 子系统索引
   */
  static getSubsysIndex(subsysId: number): number {
    return ((subsysId >> 8) & 0x0F) - 1
  }

  /**
   * 根据子系统索引生成FSM ID
   * @param subsysIndex 子系统索引（0-based）
   * @returns FSM ID
   */
  static getFsmId(subsysIndex: number): number {
    return ((subsysIndex + 1) << 8) & 0x0F00
  }

  /**
   * 根据子系统索引和IPM索引生成IPM ID
   * @param subsysIndex 子系统索引（0-based）
   * @param ipmIndex IPM索引（0-based）
   * @returns IPM ID
   */
  static getIpmId(subsysIndex: number, ipmIndex: number): number {
    return (((subsysIndex + 1) << 8) | ((ipmIndex + 1) << 4)) & 0x0FF0
  }

  /**
   * 根据ID生成IP地址
   * @param id 设备ID
   * @returns IP地址字符串
   */
  static getIpFromId(id: number): string {
    const subsysIdx = (id >> 8) & 0x0F
    const ipmIdx = (id >> 4) & 0x0F
    const suffix = (subsysIdx << 4) | ipmIdx
    return `${ConstPreDefine.LC_IP_ADDR_TEMPLATE}${suffix}`
  }
}
