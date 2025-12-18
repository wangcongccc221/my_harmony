/**
 * 等级信息结构体定义
 * 对应48项目中的StGradeInfo结构体
 * 用于接收下位机通过TCP发送的等级配置信息（FSM_CMD_CONFIG命令中的grade字段）
 */

// 常量定义
const MAX_QUALITY_GRADE_NUM = 8;  // 最大品质等级数
const MAX_SIZE_GRADE_NUM = 16;     // 最大尺寸等级数
const MAX_TEXT_LENGTH = 64;        // 最大文本长度

/**
 * 等级项信息结构
 */
export interface StGradeItemInfo {
  nMinSize: number;      // 最小尺寸/重量
  nMaxSize: number;      // 最大尺寸/重量
  nFruitNum: number;     // 每箱水果个数
  exit: number;          // 出口配置（位掩码）
  nColorGrade: number;   // 颜色等级
  sbShapeSize: number;   // 形状尺寸
  sbFlawArea: number;    // 瑕疵面积
  sbRigidity: number;    // 硬度
  sbDensity: number;     // 密度
  sbBruise: number;      // 擦伤
  sbRot: number;         // 腐烂
  sbSugar: number;       // 糖度
  sbAcidity: number;     // 酸度
  sbHollow: number;      // 空心
  sbSkin: number;        // 浮皮
  sbBrown: number;       // 褐变
  sbTangxin: number;     // 糖心
  sbWater: number;        // 含水率
}

/**
 * 等级信息结构体
 * 对应48项目中的StGradeInfo结构
 * 从FSM_CMD_CONFIG命令的StGlobal.grade字段中获取
 */
export interface StGradeInfo {
  /** 尺寸等级名称数组 [MAX_SIZE_GRADE_NUM * MAX_TEXT_LENGTH] */
  strSizeGradeName: string[];
  
  /** 品质等级名称数组 [MAX_QUALITY_GRADE_NUM * MAX_TEXT_LENGTH] */
  strQualityGradeName: string[];
  
  /** 尺寸等级数量 */
  nSizeGradeNum: number;
  
  /** 品质等级数量 */
  nQualityGradeNum: number;
  
  /** 分选标准: 1=重量(克), 2=重量(个), 4=大小(直径), 8=大小(面积), 16=大小(体积) */
  nClassifyType: number;
  
  /** 等级项信息数组 [MAX_QUALITY_GRADE_NUM * MAX_SIZE_GRADE_NUM] */
  grades: StGradeItemInfo[];
}

/**
 * 创建默认的StGradeInfo对象
 */
export function createDefaultStGradeInfo(): StGradeInfo {
  const grades: StGradeItemInfo[] = [];
  for (let i = 0; i < MAX_QUALITY_GRADE_NUM * MAX_SIZE_GRADE_NUM; i++) {
    grades.push({
      nMinSize: 0,
      nMaxSize: 0,
      nFruitNum: 0,
      exit: 0,
      nColorGrade: 0,
      sbShapeSize: 0,
      sbFlawArea: 0,
      sbRigidity: 0,
      sbDensity: 0,
      sbBruise: 0,
      sbRot: 0,
      sbSugar: 0,
      sbAcidity: 0,
      sbHollow: 0,
      sbSkin: 0,
      sbBrown: 0,
      sbTangxin: 0,
      sbWater: 0
    });
  }
  
  return {
    strSizeGradeName: new Array(MAX_SIZE_GRADE_NUM).fill(''),
    strQualityGradeName: new Array(MAX_QUALITY_GRADE_NUM).fill(''),
    nSizeGradeNum: 0,
    nQualityGradeNum: 0,
    nClassifyType: 0,
    grades: grades
  };
}

