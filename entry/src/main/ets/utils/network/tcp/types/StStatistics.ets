/**
 * 统计数据结构体定义
 * 对应48项目中的StStatistics结构体
 * 用于接收下位机通过TCP发送的实时统计数据
 */

// 常量定义（对应48项目的ConstPreDefine）
const MAX_QUALITY_GRADE_NUM = 8;  // 最大品质等级数
const MAX_SIZE_GRADE_NUM = 16;     // 最大尺寸等级数
const MAX_EXIT_NUM = 20;            // 最大出口数
const MAX_CHANNEL_NUM = 12;         // 最大通道数

/**
 * 分选基准范围结构
 */
export interface StRange {
  nMin: number;  // 最小值
  nMax: number;  // 最大值
}

/**
 * 基本统计信息结构体
 * 对应48项目中的StStatistics结构
 * FSM发送过来 (FSM, HC_ID, FSM_CMD_STATISTICS, stStatistics)
 */
export interface StStatistics {
  // ==================== 等级统计数据 ====================
  /** 各等级的水果个数数组 [品质等级数 * 尺寸等级数] */
  nGradeCount: number[];
  
  /** 各等级的水果重量数组（单位：克）[品质等级数 * 尺寸等级数] */
  nWeightGradeCount: number[];
  
  /** 各等级的箱数数组 [品质等级数 * 尺寸等级数] */
  nBoxGradeCount: number[];
  
  /** 各等级的每箱重量数组（单位：克）[品质等级数 * 尺寸等级数] */
  nBoxGradeWeight: number[];
  
  // ==================== 出口统计数据 ====================
  /** 各个出口的水果个数数组（单位：个）[MAX_EXIT_NUM] */
  nExitCount: number[];
  
  /** 重量分选时各个出口的重量数组（单位：克）[MAX_EXIT_NUM] */
  nExitWeightCount: number[];
  
  /** 各个出口的箱数数组 [MAX_EXIT_NUM] */
  ExitBoxNum: number[];
  
  // ==================== 总体统计数据 ====================
  /** 水果批总个数 */
  nTotalCount: number;
  
  /** 水果批总重量（单位：克） */
  nWeightCount: number;
  
  /** 子系统ID（FSM） */
  nSubsysId: number;
  
  /** 总的果杯数 */
  nTotalCupNum: number;
  
  // ==================== 速度与间隔数据 ====================
  /** 与上次发送统计信息的间隔数 */
  nInterval: number;
  
  /** 一分钟内光电开关的个数（用于计算分选速度） */
  nIntervalSumperminute: number;
  
  /** 脉冲间隔（单位：ms，2000以上时分选速度为0） */
  nPulseInterval: number;
  
  /** 遗漏的水果个数（上位机每20秒调用一次） */
  nUnpushFruitCount: number;
  
  // ==================== 设备状态数据 ====================
  /** 12个通道的果杯状态（低12位有效，最低位代表通道1，0正常，1故障） */
  nCupState: number;
  
  /** IPM网络状态（低6位有效，低6位代表6个IPM，最低位代表IPM1，0正常，1故障） */
  nNetState: number;
  
  /** 重量整定标志（1整定完毕，0基准整定中） */
  nWeightSetting: number;
  
  /** SCM状态（0正常，1故障） */
  nSCMState: number;
  
  /** 糖度传感器网络状态（0正常，1故障） */
  nIQSNetState: number;
  
  /** 锁定状态 */
  nLockState: number;
  
  // ==================== 其他数据 ====================
  /** 分选基准范围数组 [MAX_SIZE_GRADE_NUM] */
  fSelectBasisRange: StRange[];
}

/**
 * 创建默认的StStatistics对象
 */
export function createDefaultStStatistics(): StStatistics {
  return {
    nGradeCount: new Array(MAX_QUALITY_GRADE_NUM * MAX_SIZE_GRADE_NUM).fill(0),
    nWeightGradeCount: new Array(MAX_QUALITY_GRADE_NUM * MAX_SIZE_GRADE_NUM).fill(0),
    nBoxGradeCount: new Array(MAX_QUALITY_GRADE_NUM * MAX_SIZE_GRADE_NUM).fill(0),
    nBoxGradeWeight: new Array(MAX_QUALITY_GRADE_NUM * MAX_SIZE_GRADE_NUM).fill(0),
    nExitCount: new Array(MAX_EXIT_NUM).fill(0),
    nExitWeightCount: new Array(MAX_EXIT_NUM).fill(0),
    ExitBoxNum: new Array(MAX_EXIT_NUM).fill(0),
    nTotalCount: 0,
    nWeightCount: 0,
    nSubsysId: 0,
    nTotalCupNum: 0,
    nInterval: 0,
    nIntervalSumperminute: 0,
    nPulseInterval: 0,
    nUnpushFruitCount: 0,
    nCupState: 0,
    nNetState: 0,
    nWeightSetting: 0,
    nSCMState: 0,
    nIQSNetState: 0,
    nLockState: 0,
    fSelectBasisRange: (() => {
      const ranges: StRange[] = [];
      for (let i = 0; i < MAX_SIZE_GRADE_NUM; i++) {
        ranges.push({ nMin: 0, nMax: 0 });
      }
      return ranges;
    })()
  };
}

/**
 * 命令头结构（对应48项目的CommandHead）
 */
export interface CommandHead {
  nCmdId: number;      // 命令ID
  nSrcId: number;      // 源ID
  nDstId: number;      // 目标ID
  nLength: number;     // 数据长度
}

/**
 * TCP数据包格式
 * [SYNC字符串(4字节)] + [命令头(12字节)] + [数据体(结构体二进制)]
 */
export interface TcpDataPacket {
  sync: string;           // "SYNC"字符串
  commandHead: CommandHead; // 命令头
  data: Uint8Array;        // 数据体（二进制）
}

