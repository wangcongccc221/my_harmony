import { ConstPreDefine } from './ConstPreDefine';

/**
 * 消息头结构
 */
export interface MessageHeader {
  length: number;
  srcId: number;
  destId: number;
  cmdId: number;
}

export const MESSAGE_HEADER_SIZE = 12;

export function createDefaultWeightInfo(): StWeightInfo {
  return new StWeightInfo();
}

export function createDefaultGradeInfo(): StGradeInfo {
  return new StGradeInfo();
}

// Placeholder for missing structs in ConfigSender
export class StSizeGradeSetting {
  gradeIndex: number = 0;
  enabled: boolean = false;
  weightMin: number = 0;
  weightMax: number = 0;
  diameterMin: number = 0;
  diameterMax: number = 0;
}

export class StQualityGradeSetting {
  // TODO: Add fields
}

export class StExitSetting {
  exitIndex: number = 0;
  enabled: boolean = false;
  targetSizeGrade: number = 0;
  targetQualityGrade: number = 0;
  boxCapacity: number = 0;
  exitName: string = '';
}

/**
 * 颜色区间
 */
export class StColorIntervalItem {
  nMinU: number = 0; // quint8
  nMaxU: number = 0; // quint8
  nMinV: number = 0; // quint8
  nMaxV: number = 0; // quint8

  static getSize(): number {
    return 4;
  }

  readFromDataView(view: DataView, offset: number): number {
    this.nMinU = view.getUint8(offset); offset += 1;
    this.nMaxU = view.getUint8(offset); offset += 1;
    this.nMinV = view.getUint8(offset); offset += 1;
    this.nMaxV = view.getUint8(offset); offset += 1;
    return offset;
  }

  writeToDataView(view: DataView, offset: number): number {
    view.setUint8(offset, this.nMinU); offset += 1;
    view.setUint8(offset, this.nMaxU); offset += 1;
    view.setUint8(offset, this.nMinV); offset += 1;
    view.setUint8(offset, this.nMaxV); offset += 1;
    return offset;
  }
}

/**
 * 重量信息 (Placeholder for protocol strictness)
 */
export class StWeightInfo {
  weight: number = 0;
  finalGrade: number = 0;
  targetExit: number = 0;
  fruitId: number = 0;
  
  // 虚拟字段 (ArkTS 便捷访问用)
  diameter: number = 0;
  volume: number = 0;
  area: number = 0;
  weightGrade: number = 0;
  sizeGrade: number = 0;
  qualityGrade: number = 0;
  cupIndex: number = 0;
  channelIndex: number = 0;
  timestamp: number = 0;
}

/**
 * FSM 设备状态
 */
export class StFsmStatus {
  online: boolean = false;
  deviceId: number = 0;
  ipAddress: string = '';
  version: string = '';
  connectTime: number = 0;
  lastHeartbeat: number = 0;
  subsysIndex: number = 0;
}

export interface GradeItem {
  gradeName: string;
  unitPrice: number;
  weight: number;         // Average weight
  gradeCount: number;
  countPercent: number;
  gradeWeight: number;    // Total weight
  weightPercent: number;
  boxCount: number;
  boxCountPercent: number;
}

/**
 * 全局实时数据 (ArkTS 仅有)
 */
export interface GlobalRealtimeData {
  totalYield: number;
  totalWeight: number;
  totalQualified: number;
  totalUnqualified: number;
  gradeCount: number[];
  gradeWeight: number[];
  boxGradeCount: number[];
  exitCount: number[];
  exitWeight: number[];
  channelYield: number[];
  efficiency: number;
  runningTime: number;
  startTime: number;
}

export function createDefaultGlobalRealtimeData(): GlobalRealtimeData {
  const data: GlobalRealtimeData = {
    totalYield: 0,
    totalWeight: 0,
    totalQualified: 0,
    totalUnqualified: 0,
    gradeCount: new Array(ConstPreDefine.MAX_QUALITY_GRADE_NUM * ConstPreDefine.MAX_SIZE_GRADE_NUM).fill(0),
    gradeWeight: new Array(ConstPreDefine.MAX_QUALITY_GRADE_NUM * ConstPreDefine.MAX_SIZE_GRADE_NUM).fill(0),
    boxGradeCount: new Array(ConstPreDefine.MAX_QUALITY_GRADE_NUM * ConstPreDefine.MAX_SIZE_GRADE_NUM).fill(0),
    exitCount: new Array(ConstPreDefine.MAX_EXIT_NUM).fill(0),
    exitWeight: new Array(ConstPreDefine.MAX_EXIT_NUM).fill(0),
    channelYield: new Array(ConstPreDefine.MAX_CHANNEL_NUM).fill(0),
    efficiency: 0,
    runningTime: 0,
    startTime: 0
  };
  return data;
}

export function createDefaultStatistics(): StStatistics {
  return new StStatistics();
}

export function copyStStatistics(src: StStatistics): StStatistics {
  const dest = new StStatistics();
  // Deep copy arrays
  dest.nGradeCount.set(src.nGradeCount);
  dest.nWeightGradeCount.set(src.nWeightGradeCount);
  dest.nExitCount.set(src.nExitCount);
  dest.nExitWeightCount.set(src.nExitWeightCount);
  dest.nChannelTotalCount.set(src.nChannelTotalCount);
  dest.nChannelWeightCount.set(src.nChannelWeightCount);
  dest.nSubsysId = src.nSubsysId;
  dest.nBoxGradeCount.set(src.nBoxGradeCount);
  dest.nBoxGradeWeight.set(src.nBoxGradeWeight);
  dest.nTotalCupNum = src.nTotalCupNum;
  dest.nInterval = src.nInterval;
  dest.nIntervalSumperminute = src.nIntervalSumperminute;
  dest.nCupState = src.nCupState;
  dest.nPulseInterval = src.nPulseInterval;
  dest.nUnpushFruitCount = src.nUnpushFruitCount;
  dest.nNetState = src.nNetState;
  dest.nWeightSetting = src.nWeightSetting;
  dest.nSCMState = src.nSCMState;
  dest.nIQSNetState = src.nIQSNetState;
  dest.nLockState = src.nLockState;
  dest.ExitBoxNum.set(src.ExitBoxNum);
  dest.ExitWeight.set(src.ExitWeight);
  dest.Notice.set(src.Notice);
  return dest;
}

export function copyGlobalRealtimeData(src: GlobalRealtimeData): GlobalRealtimeData {
  const dest: GlobalRealtimeData = {
    totalYield: src.totalYield,
    totalWeight: src.totalWeight,
    totalQualified: src.totalQualified,
    totalUnqualified: src.totalUnqualified,
    gradeCount: new Array(src.gradeCount.length),
    gradeWeight: new Array(src.gradeWeight.length),
    boxGradeCount: new Array(src.boxGradeCount.length),
    exitCount: new Array(src.exitCount.length),
    exitWeight: new Array(src.exitWeight.length),
    channelYield: new Array(src.channelYield.length),
    efficiency: src.efficiency,
    runningTime: src.runningTime,
    startTime: src.startTime
  };

  // Manually copy array contents
  for (let i = 0; i < src.gradeCount.length; i++) dest.gradeCount[i] = src.gradeCount[i];
  for (let i = 0; i < src.gradeWeight.length; i++) dest.gradeWeight[i] = src.gradeWeight[i];
  for (let i = 0; i < src.boxGradeCount.length; i++) dest.boxGradeCount[i] = src.boxGradeCount[i];
  for (let i = 0; i < src.exitCount.length; i++) dest.exitCount[i] = src.exitCount[i];
  for (let i = 0; i < src.exitWeight.length; i++) dest.exitWeight[i] = src.exitWeight[i];
  for (let i = 0; i < src.channelYield.length; i++) dest.channelYield[i] = src.channelYield[i];

  return dest;
}

export function copyStWeightInfo(src: StWeightInfo): StWeightInfo {
  const dest = new StWeightInfo();
  dest.weight = src.weight;
  dest.finalGrade = src.finalGrade;
  dest.targetExit = src.targetExit;
  dest.fruitId = src.fruitId;
  return dest;
}

export function copyStGradeInfo(src: StGradeInfo): StGradeInfo {
  const size = StGradeInfo.getSize();
  const buffer = new ArrayBuffer(size);
  const view = new DataView(buffer);
  src.writeToDataView(view, 0);
  
  const dest = new StGradeInfo();
  dest.readFromDataView(view, 0);
  return dest;
}

export function copyStGradeInfoArray(src: StGradeInfo[]): StGradeInfo[] {
  return src.map(item => copyStGradeInfo(item));
}

export function copyStFsmStatus(src: StFsmStatus): StFsmStatus {
  const dest = new StFsmStatus();
  dest.online = src.online;
  return dest;
}
/**
 * 百分比信息
 */
export class StPercentInfo {
  nMax: number = 0; // quint8
  nMin: number = 0; // quint8

  static getSize(): number {
    return 2;
  }

  readFromDataView(view: DataView, offset: number): number {
    this.nMax = view.getUint8(offset); offset += 1;
    this.nMin = view.getUint8(offset); offset += 1;
    return offset;
  }

  writeToDataView(view: DataView, offset: number): number {
    view.setUint8(offset, this.nMax); offset += 1;
    view.setUint8(offset, this.nMin); offset += 1;
    return offset;
  }
}

/**
 * 范围信息
 */
export class StRange {
  nMax: number = 0.0; // float
  nMin: number = 0.0; // float

  static getSize(): number {
    return 8;
  }

  readFromDataView(view: DataView, offset: number): number {
    this.nMax = view.getFloat32(offset, true); offset += 4;
    this.nMin = view.getFloat32(offset, true); offset += 4;
    return offset;
  }

  writeToDataView(view: DataView, offset: number): number {
    view.setFloat32(offset, this.nMax, true); offset += 4;
    view.setFloat32(offset, this.nMin, true); offset += 4;
    return offset;
  }
}

/**
 * 等级项信息
 * #pragma pack(4) in C++
 */
export class StGradeItemInfo {
  exit: number = 0; // ulong (32-bit uint)
  nMinSize: number = 0; // float
  nMaxSize: number = 0; // float
  nFruitNum: number = 0; // int
  nColorGrade: number = 0; // qint8
  sbShapeSize: number = 0; // qint8
  sbDensity: number = 0; // qint8
  sbFlawArea: number = 0; // qint8
  sbBruise: number = 0; // qint8
  sbRot: number = 0; // qint8
  sbSugar: number = 0; // qint8
  sbAcidity: number = 0; // qint8
  sbHollow: number = 0; // qint8
  sbSkin: number = 0; // qint8
  sbBrown: number = 0; // qint8
  sbTangxin: number = 0; // qint8
  sbRigidity: number = 0; // qint8
  sbWater: number = 0; // qint8
  sbLabelbyGrade: number = 0; // qint8

  static getSize(): number {
    return 32;
  }

  readFromDataView(view: DataView, offset: number): number {
    this.exit = view.getUint32(offset, true); offset += 4;
    this.nMinSize = view.getFloat32(offset, true); offset += 4;
    this.nMaxSize = view.getFloat32(offset, true); offset += 4;
    this.nFruitNum = view.getInt32(offset, true); offset += 4;
    this.nColorGrade = view.getInt8(offset); offset += 1;
    this.sbShapeSize = view.getInt8(offset); offset += 1;
    this.sbDensity = view.getInt8(offset); offset += 1;
    this.sbFlawArea = view.getInt8(offset); offset += 1;
    this.sbBruise = view.getInt8(offset); offset += 1;
    this.sbRot = view.getInt8(offset); offset += 1;
    this.sbSugar = view.getInt8(offset); offset += 1;
    this.sbAcidity = view.getInt8(offset); offset += 1;
    this.sbHollow = view.getInt8(offset); offset += 1;
    this.sbSkin = view.getInt8(offset); offset += 1;
    this.sbBrown = view.getInt8(offset); offset += 1;
    this.sbTangxin = view.getInt8(offset); offset += 1;
    this.sbRigidity = view.getInt8(offset); offset += 1;
    this.sbWater = view.getInt8(offset); offset += 1;
    this.sbLabelbyGrade = view.getInt8(offset); offset += 1;
    offset += 1; // Padding
    return offset;
  }

  writeToDataView(view: DataView, offset: number): number {
    view.setUint32(offset, this.exit, true); offset += 4;
    view.setFloat32(offset, this.nMinSize, true); offset += 4;
    view.setFloat32(offset, this.nMaxSize, true); offset += 4;
    view.setInt32(offset, this.nFruitNum, true); offset += 4;
    view.setInt8(offset, this.nColorGrade); offset += 1;
    view.setInt8(offset, this.sbShapeSize); offset += 1;
    view.setInt8(offset, this.sbDensity); offset += 1;
    view.setInt8(offset, this.sbFlawArea); offset += 1;
    view.setInt8(offset, this.sbBruise); offset += 1;
    view.setInt8(offset, this.sbRot); offset += 1;
    view.setInt8(offset, this.sbSugar); offset += 1;
    view.setInt8(offset, this.sbAcidity); offset += 1;
    view.setInt8(offset, this.sbHollow); offset += 1;
    view.setInt8(offset, this.sbSkin); offset += 1;
    view.setInt8(offset, this.sbBrown); offset += 1;
    view.setInt8(offset, this.sbTangxin); offset += 1;
    view.setInt8(offset, this.sbRigidity); offset += 1;
    view.setInt8(offset, this.sbWater); offset += 1;
    view.setInt8(offset, this.sbLabelbyGrade); offset += 1;
    offset += 1; // Padding
    return offset;
  }
}

/**
 * 等级信息
 */
export class StGradeInfo {
  intervals: StColorIntervalItem[] = [];
  percent: StPercentInfo[] = [];
  grades: StGradeItemInfo[] = [];
  ExitEnabled: Int32Array = new Int32Array(2);
  ColorIntervals: Int32Array = new Int32Array(2);
  nExitSwitchNum: Int32Array = new Int32Array(ConstPreDefine.MAX_EXIT_NUM);
  nTagInfo: Uint8Array = new Uint8Array(ConstPreDefine.PARAS_TAGINFO_NUM);
  nFruitType: number = 0; // int
  strFruitName: Uint8Array = new Uint8Array(ConstPreDefine.MAX_FRUIT_NAME_LENGTH);
  unFlawAreaFactor: Uint32Array = new Uint32Array(ConstPreDefine.MAX_FlAWAREA_GRADE_NUM * 2);
  unBruiseFactor: Uint32Array = new Uint32Array(ConstPreDefine.MAX_BRUISE_GRADE_NUM * 2);
  unRotFactor: Uint32Array = new Uint32Array(ConstPreDefine.MAX_ROT_GRADE_NUM * 2);
  fDensityFactor: Float32Array = new Float32Array(ConstPreDefine.MAX_DENSITY_GRADE_NUM);
  fSugarFactor: Float32Array = new Float32Array(ConstPreDefine.MAX_SUGAR_GRADE_NUM);
  fAcidityFactor: Float32Array = new Float32Array(ConstPreDefine.MAX_ACIDITY_GRADE_NUM);
  fHollowFactor: Float32Array = new Float32Array(ConstPreDefine.MAX_HOLLOW_GRADE_NUM);
  fSkinFactor: Float32Array = new Float32Array(ConstPreDefine.MAX_SKIN_GRADE_NUM);
  fBrownFactor: Float32Array = new Float32Array(ConstPreDefine.MAX_BROWN_GRADE_NUM);
  fTangxinFactor: Float32Array = new Float32Array(ConstPreDefine.MAX_TANGXIN_GRADE_NUM);
  fRigidityFactor: Float32Array = new Float32Array(ConstPreDefine.MAX_RIGIDITY_GRADE_NUM);
  fWaterFactor: Float32Array = new Float32Array(ConstPreDefine.MAX_WATER_GRADE_NUM);
  fShapeFactor: Float32Array = new Float32Array(ConstPreDefine.MAX_SHAPE_GRADE_NUM);
  
  strSizeGradeName: Uint8Array = new Uint8Array(ConstPreDefine.MAX_SIZE_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH);
  strQualityGradeName: Uint8Array = new Uint8Array(ConstPreDefine.MAX_QUALITY_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH);
  stDensityGradeName: Uint8Array = new Uint8Array(ConstPreDefine.MAX_DENSITY_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH);
  strColorGradeName: Uint8Array = new Uint8Array(ConstPreDefine.MAX_COLOR_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH);
  strShapeGradeName: Uint8Array = new Uint8Array(ConstPreDefine.MAX_SHAPE_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH);
  stFlawareaGradeName: Uint8Array = new Uint8Array(ConstPreDefine.MAX_FlAWAREA_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH);
  stBruiseGradeName: Uint8Array = new Uint8Array(ConstPreDefine.MAX_BRUISE_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH);
  stRotGradeName: Uint8Array = new Uint8Array(ConstPreDefine.MAX_ROT_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH);
  stSugarGradeName: Uint8Array = new Uint8Array(ConstPreDefine.MAX_SUGAR_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH);
  stAcidityGradeName: Uint8Array = new Uint8Array(ConstPreDefine.MAX_ACIDITY_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH);
  stHollowGradeName: Uint8Array = new Uint8Array(ConstPreDefine.MAX_HOLLOW_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH);
  stSkinGradeName: Uint8Array = new Uint8Array(ConstPreDefine.MAX_SKIN_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH);
  stBrownGradeName: Uint8Array = new Uint8Array(ConstPreDefine.MAX_BROWN_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH);
  stTangxinGradeName: Uint8Array = new Uint8Array(ConstPreDefine.MAX_TANGXIN_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH);
  stRigidityGradeName: Uint8Array = new Uint8Array(ConstPreDefine.MAX_FlAWAREA_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH);
  stWaterGradeName: Uint8Array = new Uint8Array(ConstPreDefine.MAX_WATER_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH);

  ColorType: number = 0; // quint8
  nLabelType: number = 0; // quint8
  nLabelbyExit: Uint8Array = new Uint8Array(ConstPreDefine.MAX_EXIT_NUM);
  nSwitchLabel: Uint8Array = new Uint8Array(ConstPreDefine.MAX_EXIT_NUM);
  nSizeGradeNum: number = 0; // quint8
  nQualityGradeNum: number = 0; // quint8
  nClassifyType: number = 0; // quint8
  nCheckNum: number = 0; // short
  ForceChannel: number = 0; // short

  // 虚拟字段 (ArkTS 便捷访问用 - 用于实时分级信息)
  fruitId: number = 0;
  weight: number = 0;
  diameter: number = 0;
  colorGrade: number = 0;
  shapeGrade: number = 0;
  flawGrade: number = 0;
  sugarGrade: number = 0;
  acidityGrade: number = 0;
  densityGrade: number = 0;
  rigidityGrade: number = 0;
  qualityGrade: number = 0;
  sizeGrade: number = 0;
  finalGrade: number = 0;
  targetExit: number = 0;
  cupIndex: number = 0;
  colorR: number = 0;
  colorG: number = 0;
  colorB: number = 0;
  channelIndex: number = 0;
  timestamp: number = 0;

  constructor() {
    for (let i = 0; i < ConstPreDefine.MAX_COLOR_INTERVAL_NUM; i++) {
      this.intervals.push(new StColorIntervalItem());
    }
    for (let i = 0; i < ConstPreDefine.MAX_COLOR_GRADE_NUM * ConstPreDefine.MAX_COLOR_INTERVAL_NUM; i++) {
      this.percent.push(new StPercentInfo());
    }
    for (let i = 0; i < ConstPreDefine.MAX_QUALITY_GRADE_NUM * ConstPreDefine.MAX_SIZE_GRADE_NUM; i++) {
      this.grades.push(new StGradeItemInfo());
    }
  }

  static getSize(): number {
    let size = 0;
    size += ConstPreDefine.MAX_COLOR_INTERVAL_NUM * StColorIntervalItem.getSize();
    size += ConstPreDefine.MAX_COLOR_GRADE_NUM * ConstPreDefine.MAX_COLOR_INTERVAL_NUM * StPercentInfo.getSize();
    size += ConstPreDefine.MAX_QUALITY_GRADE_NUM * ConstPreDefine.MAX_SIZE_GRADE_NUM * StGradeItemInfo.getSize();
    size += 2 * 4; // ExitEnabled
    size += 2 * 4; // ColorIntervals
    size += ConstPreDefine.MAX_EXIT_NUM * 4; // nExitSwitchNum
    size += ConstPreDefine.PARAS_TAGINFO_NUM; // nTagInfo
    size += 4; // nFruitType
    size += ConstPreDefine.MAX_FRUIT_NAME_LENGTH; // strFruitName
    size += ConstPreDefine.MAX_FlAWAREA_GRADE_NUM * 2 * 4; // unFlawAreaFactor
    size += ConstPreDefine.MAX_BRUISE_GRADE_NUM * 2 * 4; // unBruiseFactor
    size += ConstPreDefine.MAX_ROT_GRADE_NUM * 2 * 4; // unRotFactor
    size += ConstPreDefine.MAX_DENSITY_GRADE_NUM * 4; // fDensityFactor
    size += ConstPreDefine.MAX_SUGAR_GRADE_NUM * 4; // fSugarFactor
    size += ConstPreDefine.MAX_ACIDITY_GRADE_NUM * 4; // fAcidityFactor
    size += ConstPreDefine.MAX_HOLLOW_GRADE_NUM * 4; // fHollowFactor
    size += ConstPreDefine.MAX_SKIN_GRADE_NUM * 4; // fSkinFactor
    size += ConstPreDefine.MAX_BROWN_GRADE_NUM * 4; // fBrownFactor
    size += ConstPreDefine.MAX_TANGXIN_GRADE_NUM * 4; // fTangxinFactor
    size += ConstPreDefine.MAX_RIGIDITY_GRADE_NUM * 4; // fRigidityFactor
    size += ConstPreDefine.MAX_WATER_GRADE_NUM * 4; // fWaterFactor
    size += ConstPreDefine.MAX_SHAPE_GRADE_NUM * 4; // fShapeFactor
    
    size += ConstPreDefine.MAX_SIZE_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH;
    size += ConstPreDefine.MAX_QUALITY_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH;
    size += ConstPreDefine.MAX_DENSITY_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH;
    size += ConstPreDefine.MAX_COLOR_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH;
    size += ConstPreDefine.MAX_SHAPE_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH;
    size += ConstPreDefine.MAX_FlAWAREA_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH;
    size += ConstPreDefine.MAX_BRUISE_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH;
    size += ConstPreDefine.MAX_ROT_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH;
    size += ConstPreDefine.MAX_SUGAR_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH;
    size += ConstPreDefine.MAX_ACIDITY_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH;
    size += ConstPreDefine.MAX_HOLLOW_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH;
    size += ConstPreDefine.MAX_SKIN_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH;
    size += ConstPreDefine.MAX_BROWN_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH;
    size += ConstPreDefine.MAX_TANGXIN_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH;
    size += ConstPreDefine.MAX_FlAWAREA_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH;
    size += ConstPreDefine.MAX_WATER_GRADE_NUM * ConstPreDefine.MAX_TEXT_LENGTH;

    size += 1; // ColorType
    size += 1; // nLabelType
    size += ConstPreDefine.MAX_EXIT_NUM; // nLabelbyExit
    size += ConstPreDefine.MAX_EXIT_NUM; // nSwitchLabel
    size += 1; // nSizeGradeNum
    size += 1; // nQualityGradeNum
    size += 1; // nClassifyType
    size += 2; // nCheckNum (short)
    size += 2; // ForceChannel (short)
    
    if (size % 4 !== 0) {
      size += (4 - (size % 4));
    }
    return size;
  }

  readFromDataView(view: DataView, offset: number): number {
    for (let i = 0; i < this.intervals.length; i++) {
      offset = this.intervals[i].readFromDataView(view, offset);
    }
    for (let i = 0; i < this.percent.length; i++) {
      offset = this.percent[i].readFromDataView(view, offset);
    }
    for (let i = 0; i < this.grades.length; i++) {
      offset = this.grades[i].readFromDataView(view, offset);
    }
    
    for (let i = 0; i < this.ExitEnabled.length; i++) { this.ExitEnabled[i] = view.getInt32(offset, true); offset += 4; }
    for (let i = 0; i < this.ColorIntervals.length; i++) { this.ColorIntervals[i] = view.getInt32(offset, true); offset += 4; }
    for (let i = 0; i < this.nExitSwitchNum.length; i++) { this.nExitSwitchNum[i] = view.getInt32(offset, true); offset += 4; }
    for (let i = 0; i < this.nTagInfo.length; i++) { this.nTagInfo[i] = view.getUint8(offset); offset++; }
    
    this.nFruitType = view.getInt32(offset, true); offset += 4;
    
    for (let i = 0; i < this.strFruitName.length; i++) { this.strFruitName[i] = view.getUint8(offset); offset++; }
    for (let i = 0; i < this.unFlawAreaFactor.length; i++) { this.unFlawAreaFactor[i] = view.getUint32(offset, true); offset += 4; }
    for (let i = 0; i < this.unBruiseFactor.length; i++) { this.unBruiseFactor[i] = view.getUint32(offset, true); offset += 4; }
    for (let i = 0; i < this.unRotFactor.length; i++) { this.unRotFactor[i] = view.getUint32(offset, true); offset += 4; }
    
    for (let i = 0; i < this.fDensityFactor.length; i++) { this.fDensityFactor[i] = view.getFloat32(offset, true); offset += 4; }
    for (let i = 0; i < this.fSugarFactor.length; i++) { this.fSugarFactor[i] = view.getFloat32(offset, true); offset += 4; }
    for (let i = 0; i < this.fAcidityFactor.length; i++) { this.fAcidityFactor[i] = view.getFloat32(offset, true); offset += 4; }
    for (let i = 0; i < this.fHollowFactor.length; i++) { this.fHollowFactor[i] = view.getFloat32(offset, true); offset += 4; }
    for (let i = 0; i < this.fSkinFactor.length; i++) { this.fSkinFactor[i] = view.getFloat32(offset, true); offset += 4; }
    for (let i = 0; i < this.fBrownFactor.length; i++) { this.fBrownFactor[i] = view.getFloat32(offset, true); offset += 4; }
    for (let i = 0; i < this.fTangxinFactor.length; i++) { this.fTangxinFactor[i] = view.getFloat32(offset, true); offset += 4; }
    for (let i = 0; i < this.fRigidityFactor.length; i++) { this.fRigidityFactor[i] = view.getFloat32(offset, true); offset += 4; }
    for (let i = 0; i < this.fWaterFactor.length; i++) { this.fWaterFactor[i] = view.getFloat32(offset, true); offset += 4; }
    for (let i = 0; i < this.fShapeFactor.length; i++) { this.fShapeFactor[i] = view.getFloat32(offset, true); offset += 4; }
    
    // String arrays
    for (let i = 0; i < this.strSizeGradeName.length; i++) { this.strSizeGradeName[i] = view.getUint8(offset); offset++; }
    for (let i = 0; i < this.strQualityGradeName.length; i++) { this.strQualityGradeName[i] = view.getUint8(offset); offset++; }
    for (let i = 0; i < this.stDensityGradeName.length; i++) { this.stDensityGradeName[i] = view.getUint8(offset); offset++; }
    for (let i = 0; i < this.strColorGradeName.length; i++) { this.strColorGradeName[i] = view.getUint8(offset); offset++; }
    for (let i = 0; i < this.strShapeGradeName.length; i++) { this.strShapeGradeName[i] = view.getUint8(offset); offset++; }
    for (let i = 0; i < this.stFlawareaGradeName.length; i++) { this.stFlawareaGradeName[i] = view.getUint8(offset); offset++; }
    for (let i = 0; i < this.stBruiseGradeName.length; i++) { this.stBruiseGradeName[i] = view.getUint8(offset); offset++; }
    for (let i = 0; i < this.stRotGradeName.length; i++) { this.stRotGradeName[i] = view.getUint8(offset); offset++; }
    for (let i = 0; i < this.stSugarGradeName.length; i++) { this.stSugarGradeName[i] = view.getUint8(offset); offset++; }
    for (let i = 0; i < this.stAcidityGradeName.length; i++) { this.stAcidityGradeName[i] = view.getUint8(offset); offset++; }
    for (let i = 0; i < this.stHollowGradeName.length; i++) { this.stHollowGradeName[i] = view.getUint8(offset); offset++; }
    for (let i = 0; i < this.stSkinGradeName.length; i++) { this.stSkinGradeName[i] = view.getUint8(offset); offset++; }
    for (let i = 0; i < this.stBrownGradeName.length; i++) { this.stBrownGradeName[i] = view.getUint8(offset); offset++; }
    for (let i = 0; i < this.stTangxinGradeName.length; i++) { this.stTangxinGradeName[i] = view.getUint8(offset); offset++; }
    for (let i = 0; i < this.stRigidityGradeName.length; i++) { this.stRigidityGradeName[i] = view.getUint8(offset); offset++; }
    for (let i = 0; i < this.stWaterGradeName.length; i++) { this.stWaterGradeName[i] = view.getUint8(offset); offset++; }
    
    this.ColorType = view.getUint8(offset); offset++;
    this.nLabelType = view.getUint8(offset); offset++;
    for (let i = 0; i < this.nLabelbyExit.length; i++) { this.nLabelbyExit[i] = view.getUint8(offset); offset++; }
    for (let i = 0; i < this.nSwitchLabel.length; i++) { this.nSwitchLabel[i] = view.getUint8(offset); offset++; }
    this.nSizeGradeNum = view.getUint8(offset); offset++;
    this.nQualityGradeNum = view.getUint8(offset); offset++;
    this.nClassifyType = view.getUint8(offset); offset++;
    this.nCheckNum = view.getInt16(offset, true); offset += 2;
    this.ForceChannel = view.getInt16(offset, true); offset += 2;

    return offset;
  }

  writeToDataView(view: DataView, offset: number): number {
    for (let i = 0; i < this.intervals.length; i++) {
      offset = this.intervals[i].writeToDataView(view, offset);
    }
    for (let i = 0; i < this.percent.length; i++) {
      offset = this.percent[i].writeToDataView(view, offset);
    }
    for (let i = 0; i < this.grades.length; i++) {
      offset = this.grades[i].writeToDataView(view, offset);
    }
    
    for (let i = 0; i < this.ExitEnabled.length; i++) { view.setInt32(offset, this.ExitEnabled[i], true); offset += 4; }
    for (let i = 0; i < this.ColorIntervals.length; i++) { view.setInt32(offset, this.ColorIntervals[i], true); offset += 4; }
    for (let i = 0; i < this.nExitSwitchNum.length; i++) { view.setInt32(offset, this.nExitSwitchNum[i], true); offset += 4; }
    for (let i = 0; i < this.nTagInfo.length; i++) { view.setUint8(offset, this.nTagInfo[i]); offset++; }
    
    view.setInt32(offset, this.nFruitType, true); offset += 4;
    
    for (let i = 0; i < this.strFruitName.length; i++) { view.setUint8(offset, this.strFruitName[i]); offset++; }
    for (let i = 0; i < this.unFlawAreaFactor.length; i++) { view.setUint32(offset, this.unFlawAreaFactor[i], true); offset += 4; }
    for (let i = 0; i < this.unBruiseFactor.length; i++) { view.setUint32(offset, this.unBruiseFactor[i], true); offset += 4; }
    for (let i = 0; i < this.unRotFactor.length; i++) { view.setUint32(offset, this.unRotFactor[i], true); offset += 4; }
    
    for (let i = 0; i < this.fDensityFactor.length; i++) { view.setFloat32(offset, this.fDensityFactor[i], true); offset += 4; }
    for (let i = 0; i < this.fSugarFactor.length; i++) { view.setFloat32(offset, this.fSugarFactor[i], true); offset += 4; }
    for (let i = 0; i < this.fAcidityFactor.length; i++) { view.setFloat32(offset, this.fAcidityFactor[i], true); offset += 4; }
    for (let i = 0; i < this.fHollowFactor.length; i++) { view.setFloat32(offset, this.fHollowFactor[i], true); offset += 4; }
    for (let i = 0; i < this.fSkinFactor.length; i++) { view.setFloat32(offset, this.fSkinFactor[i], true); offset += 4; }
    for (let i = 0; i < this.fBrownFactor.length; i++) { view.setFloat32(offset, this.fBrownFactor[i], true); offset += 4; }
    for (let i = 0; i < this.fTangxinFactor.length; i++) { view.setFloat32(offset, this.fTangxinFactor[i], true); offset += 4; }
    for (let i = 0; i < this.fRigidityFactor.length; i++) { view.setFloat32(offset, this.fRigidityFactor[i], true); offset += 4; }
    for (let i = 0; i < this.fWaterFactor.length; i++) { view.setFloat32(offset, this.fWaterFactor[i], true); offset += 4; }
    for (let i = 0; i < this.fShapeFactor.length; i++) { view.setFloat32(offset, this.fShapeFactor[i], true); offset += 4; }
    
    for (let i = 0; i < this.strSizeGradeName.length; i++) { view.setUint8(offset, this.strSizeGradeName[i]); offset++; }
    for (let i = 0; i < this.strQualityGradeName.length; i++) { view.setUint8(offset, this.strQualityGradeName[i]); offset++; }
    for (let i = 0; i < this.stDensityGradeName.length; i++) { view.setUint8(offset, this.stDensityGradeName[i]); offset++; }
    for (let i = 0; i < this.strColorGradeName.length; i++) { view.setUint8(offset, this.strColorGradeName[i]); offset++; }
    for (let i = 0; i < this.strShapeGradeName.length; i++) { view.setUint8(offset, this.strShapeGradeName[i]); offset++; }
    for (let i = 0; i < this.stFlawareaGradeName.length; i++) { view.setUint8(offset, this.stFlawareaGradeName[i]); offset++; }
    for (let i = 0; i < this.stBruiseGradeName.length; i++) { view.setUint8(offset, this.stBruiseGradeName[i]); offset++; }
    for (let i = 0; i < this.stRotGradeName.length; i++) { view.setUint8(offset, this.stRotGradeName[i]); offset++; }
    for (let i = 0; i < this.stSugarGradeName.length; i++) { view.setUint8(offset, this.stSugarGradeName[i]); offset++; }
    for (let i = 0; i < this.stAcidityGradeName.length; i++) { view.setUint8(offset, this.stAcidityGradeName[i]); offset++; }
    for (let i = 0; i < this.stHollowGradeName.length; i++) { view.setUint8(offset, this.stHollowGradeName[i]); offset++; }
    for (let i = 0; i < this.stSkinGradeName.length; i++) { view.setUint8(offset, this.stSkinGradeName[i]); offset++; }
    for (let i = 0; i < this.stBrownGradeName.length; i++) { view.setUint8(offset, this.stBrownGradeName[i]); offset++; }
    for (let i = 0; i < this.stTangxinGradeName.length; i++) { view.setUint8(offset, this.stTangxinGradeName[i]); offset++; }
    for (let i = 0; i < this.stRigidityGradeName.length; i++) { view.setUint8(offset, this.stRigidityGradeName[i]); offset++; }
    for (let i = 0; i < this.stWaterGradeName.length; i++) { view.setUint8(offset, this.stWaterGradeName[i]); offset++; }
    
    view.setUint8(offset, this.ColorType); offset++;
    view.setUint8(offset, this.nLabelType); offset++;
    for (let i = 0; i < this.nLabelbyExit.length; i++) { view.setUint8(offset, this.nLabelbyExit[i]); offset++; }
    for (let i = 0; i < this.nSwitchLabel.length; i++) { view.setUint8(offset, this.nSwitchLabel[i]); offset++; }
    view.setUint8(offset, this.nSizeGradeNum); offset++;
    view.setUint8(offset, this.nQualityGradeNum); offset++;
    view.setUint8(offset, this.nClassifyType); offset++;
    view.setInt16(offset, this.nCheckNum, true); offset += 2;
    view.setInt16(offset, this.ForceChannel, true); offset += 2;

    return offset;
  }
}

/**
 * 统计信息
 */
export class StStatistics {
  nGradeCount: Uint32Array = new Uint32Array(ConstPreDefine.MAX_QUALITY_GRADE_NUM * ConstPreDefine.MAX_SIZE_GRADE_NUM); // ulong
  nWeightGradeCount: Uint32Array = new Uint32Array(ConstPreDefine.MAX_QUALITY_GRADE_NUM * ConstPreDefine.MAX_SIZE_GRADE_NUM); // ulong
  nExitCount: Uint32Array = new Uint32Array(ConstPreDefine.MAX_EXIT_NUM); // ulong
  nExitWeightCount: Uint32Array = new Uint32Array(ConstPreDefine.MAX_EXIT_NUM); // ulong
  nChannelTotalCount: Uint32Array = new Uint32Array(ConstPreDefine.MAX_CHANNEL_NUM); // ulong
  nChannelWeightCount: Uint32Array = new Uint32Array(ConstPreDefine.MAX_CHANNEL_NUM); // ulong
  nSubsysId: number = 0; // int
  nBoxGradeCount: Int32Array = new Int32Array(ConstPreDefine.MAX_QUALITY_GRADE_NUM * ConstPreDefine.MAX_SIZE_GRADE_NUM); // int
  nBoxGradeWeight: Int32Array = new Int32Array(ConstPreDefine.MAX_QUALITY_GRADE_NUM * ConstPreDefine.MAX_SIZE_GRADE_NUM); // int
  nTotalCupNum: number = 0; // int
  nInterval: number = 0; // int
  nIntervalSumperminute: number = 0; // int
  nCupState: number = 0; // ushort
  nPulseInterval: number = 0; // ushort
  nUnpushFruitCount: number = 0; // ushort
  nNetState: number = 0; // quint8 (if not MAX64/LS8)
  nWeightSetting: number = 0; // quint8
  nSCMState: number = 0; // quint8
  nIQSNetState: number = 0; // quint8
  nLockState: number = 0; // quint8
  ExitBoxNum: Uint16Array = new Uint16Array(ConstPreDefine.MAX_EXIT_NUM); // quint16
  ExitWeight: Uint32Array = new Uint32Array(ConstPreDefine.MAX_EXIT_NUM); // quint32
  // fSelectBasisRange: StRange[] if WEIGHTANDSIZE
  Notice: Uint8Array = new Uint8Array(ConstPreDefine.MAX_NOTICE_LENGTH); // quint8

  // 虚拟字段 (ArkTS 便捷访问用)
  nChannelIndex: number = 0;
  nYield: number = 0;
  nTotalWeight: number = 0;
  nQualifiedCount: number = 0;
  nUnqualifiedCount: number = 0;
  nBigCount: number = 0;
  nSmallCount: number = 0;
  nEmptyCount: number = 0;
  nTimestamp: number = 0;

  static getSize(): number {
    let size = 0;
    size += ConstPreDefine.MAX_QUALITY_GRADE_NUM * ConstPreDefine.MAX_SIZE_GRADE_NUM * 4;
    size += ConstPreDefine.MAX_QUALITY_GRADE_NUM * ConstPreDefine.MAX_SIZE_GRADE_NUM * 4;
    size += ConstPreDefine.MAX_EXIT_NUM * 4;
    size += ConstPreDefine.MAX_EXIT_NUM * 4;
    size += ConstPreDefine.MAX_CHANNEL_NUM * 4;
    size += ConstPreDefine.MAX_CHANNEL_NUM * 4;
    size += 4; // nSubsysId
    size += ConstPreDefine.MAX_QUALITY_GRADE_NUM * ConstPreDefine.MAX_SIZE_GRADE_NUM * 4;
    size += ConstPreDefine.MAX_QUALITY_GRADE_NUM * ConstPreDefine.MAX_SIZE_GRADE_NUM * 4;
    size += 4; // nTotalCupNum
    size += 4; // nInterval
    size += 4; // nIntervalSumperminute
    size += 2; // nCupState
    size += 2; // nPulseInterval
    size += 2; // nUnpushFruitCount
    size += 1; // nNetState
    size += 1; // nWeightSetting
    size += 1; // nSCMState
    size += 1; // nIQSNetState
    size += 1; // nLockState
    size += ConstPreDefine.MAX_EXIT_NUM * 2; // ExitBoxNum
    size += ConstPreDefine.MAX_EXIT_NUM * 4; // ExitWeight
    size += ConstPreDefine.MAX_NOTICE_LENGTH; // Notice
    
    if (size % 4 !== 0) {
      size += (4 - (size % 4));
    }
    return size;
  }

  readFromDataView(view: DataView, offset: number): number {
    for (let i = 0; i < this.nGradeCount.length; i++) { this.nGradeCount[i] = view.getUint32(offset, true); offset += 4; }
    for (let i = 0; i < this.nWeightGradeCount.length; i++) { this.nWeightGradeCount[i] = view.getUint32(offset, true); offset += 4; }
    for (let i = 0; i < this.nExitCount.length; i++) { this.nExitCount[i] = view.getUint32(offset, true); offset += 4; }
    for (let i = 0; i < this.nExitWeightCount.length; i++) { this.nExitWeightCount[i] = view.getUint32(offset, true); offset += 4; }
    for (let i = 0; i < this.nChannelTotalCount.length; i++) { this.nChannelTotalCount[i] = view.getUint32(offset, true); offset += 4; }
    for (let i = 0; i < this.nChannelWeightCount.length; i++) { this.nChannelWeightCount[i] = view.getUint32(offset, true); offset += 4; }
    
    this.nSubsysId = view.getInt32(offset, true); offset += 4;
    
    for (let i = 0; i < this.nBoxGradeCount.length; i++) { this.nBoxGradeCount[i] = view.getInt32(offset, true); offset += 4; }
    for (let i = 0; i < this.nBoxGradeWeight.length; i++) { this.nBoxGradeWeight[i] = view.getInt32(offset, true); offset += 4; }
    
    this.nTotalCupNum = view.getInt32(offset, true); offset += 4;
    this.nInterval = view.getInt32(offset, true); offset += 4;
    this.nIntervalSumperminute = view.getInt32(offset, true); offset += 4;
    this.nCupState = view.getUint16(offset, true); offset += 2;
    this.nPulseInterval = view.getUint16(offset, true); offset += 2;
    this.nUnpushFruitCount = view.getUint16(offset, true); offset += 2;
    this.nNetState = view.getUint8(offset); offset += 1;
    this.nWeightSetting = view.getUint8(offset); offset += 1;
    this.nSCMState = view.getUint8(offset); offset += 1;
    this.nIQSNetState = view.getUint8(offset); offset += 1;
    this.nLockState = view.getUint8(offset); offset += 1;
    
    // C++ 内存对齐修正: 前面是奇数个字节，quint16数组需要偶数地址对齐
    if (offset % 2 !== 0) {
      offset += 1;
    }

    for (let i = 0; i < this.ExitBoxNum.length; i++) { this.ExitBoxNum[i] = view.getUint16(offset, true); offset += 2; }
    for (let i = 0; i < this.ExitWeight.length; i++) { this.ExitWeight[i] = view.getUint32(offset, true); offset += 4; }
    for (let i = 0; i < this.Notice.length; i++) { this.Notice[i] = view.getUint8(offset); offset++; }

    // 自动计算虚拟字段
    this.nYield = this.nTotalCupNum; 
    
    // 计算总重 (所有通道重量之和)
    this.nTotalWeight = 0;
    for (let i = 0; i < this.nChannelWeightCount.length; i++) {
      this.nTotalWeight += this.nChannelWeightCount[i];
    }
    
    // 简单计算合格数 (暂时假设等于产量，或者根据实际分级逻辑完善)
    this.nQualifiedCount = this.nYield; 
    
    // 填充时间戳
    this.nTimestamp = Date.now();

    return offset;
  }
}

/**
 * 系统配置
 */
export class StSysConfig {
  exitstate: Uint8Array = new Uint8Array(ConstPreDefine.MAX_EXIT_NUM * 2 * 4);
  nChannelInfo: Uint8Array = new Uint8Array(ConstPreDefine.MAX_SUBSYS_NUM);
  nImageUV: Uint8Array = new Uint8Array(ConstPreDefine.MAX_SUBSYS_NUM);
  nDataRegistration: Uint8Array = new Uint8Array(ConstPreDefine.MAX_SUBSYS_NUM);
  nImageSugar: Uint8Array = new Uint8Array(ConstPreDefine.MAX_SUBSYS_NUM);
  nImageUltrasonic: Uint8Array = new Uint8Array(ConstPreDefine.MAX_SUBSYS_NUM);
  nCameraDelay: Int32Array = new Int32Array(ConstPreDefine.MAX_CAMERA_NUM * 2);
  width: number = 0; // int
  height: number = 0; // int
  packetSize: number = 0; // int
  nSystemInfo: number = 0; // quint16
  nSubsysNum: number = 0; // quint8
  nExitNum: number = 0; // quint8
  nClassificationInfo: number = 0; // quint8
  multiFreq: number = 0; // quint8
  nCameraType: number = 0; // quint8
  CIRClassifyType: number = 0; // quint8
  UVClassifyType: number = 0; // quint8
  WeightClassifyTpye: number = 0; // quint8
  InternalClassifyType: number = 0; // quint8
  UltrasonicClassifyType: number = 0; // quint8
  IfWIFIEnable: number = 0; // quint8
  CheckExit: number = 0; // quint8
  CheckNum: number = 0; // quint8
  nIQSEnable: number = 0; // quint8

  static getSize(): number {
    let size = 0;
    size += ConstPreDefine.MAX_EXIT_NUM * 2 * 4; // exitstate
    size += ConstPreDefine.MAX_SUBSYS_NUM; // nChannelInfo
    size += ConstPreDefine.MAX_SUBSYS_NUM; // nImageUV
    size += ConstPreDefine.MAX_SUBSYS_NUM; // nDataRegistration
    size += ConstPreDefine.MAX_SUBSYS_NUM; // nImageSugar
    size += ConstPreDefine.MAX_SUBSYS_NUM; // nImageUltrasonic
    size += ConstPreDefine.MAX_CAMERA_NUM * 2 * 4; // nCameraDelay (int array)
    size += 4; // width
    size += 4; // height
    size += 4; // packetSize
    size += 2; // nSystemInfo
    size += 1; // nSubsysNum
    size += 1; // nExitNum
    size += 1; // nClassificationInfo
    size += 1; // multiFreq
    size += 1; // nCameraType
    size += 1; // CIRClassifyType
    size += 1; // UVClassifyType
    size += 1; // WeightClassifyTpye
    size += 1; // InternalClassifyType
    size += 1; // UltrasonicClassifyType
    size += 1; // IfWIFIEnable
    size += 1; // CheckExit
    size += 1; // CheckNum
    size += 1; // nIQSEnable
    
    // Padding
    if (size % 4 !== 0) {
      size += (4 - (size % 4));
    }
    return size;
  }

  readFromDataView(view: DataView, offset: number): number {
    // exitstate
    for (let i = 0; i < this.exitstate.length; i++) {
      this.exitstate[i] = view.getUint8(offset); offset++;
    }
    // nChannelInfo
    for (let i = 0; i < this.nChannelInfo.length; i++) {
      this.nChannelInfo[i] = view.getUint8(offset); offset++;
    }
    // nImageUV
    for (let i = 0; i < this.nImageUV.length; i++) {
      this.nImageUV[i] = view.getUint8(offset); offset++;
    }
    // nDataRegistration
    for (let i = 0; i < this.nDataRegistration.length; i++) {
      this.nDataRegistration[i] = view.getUint8(offset); offset++;
    }
    // nImageSugar
    for (let i = 0; i < this.nImageSugar.length; i++) {
      this.nImageSugar[i] = view.getUint8(offset); offset++;
    }
    // nImageUltrasonic
    for (let i = 0; i < this.nImageUltrasonic.length; i++) {
      this.nImageUltrasonic[i] = view.getUint8(offset); offset++;
    }
    // nCameraDelay
    for (let i = 0; i < this.nCameraDelay.length; i++) {
      this.nCameraDelay[i] = view.getInt32(offset, true); offset += 4;
    }
    
    this.width = view.getInt32(offset, true); offset += 4;
    this.height = view.getInt32(offset, true); offset += 4;
    this.packetSize = view.getInt32(offset, true); offset += 4;
    this.nSystemInfo = view.getUint16(offset, true); offset += 2;
    this.nSubsysNum = view.getUint8(offset); offset += 1;
    this.nExitNum = view.getUint8(offset); offset += 1;
    this.nClassificationInfo = view.getUint8(offset); offset += 1;
    this.multiFreq = view.getUint8(offset); offset += 1;
    this.nCameraType = view.getUint8(offset); offset += 1;
    this.CIRClassifyType = view.getUint8(offset); offset += 1;
    this.UVClassifyType = view.getUint8(offset); offset += 1;
    this.WeightClassifyTpye = view.getUint8(offset); offset += 1;
    this.InternalClassifyType = view.getUint8(offset); offset += 1;
    this.UltrasonicClassifyType = view.getUint8(offset); offset += 1;
    this.IfWIFIEnable = view.getUint8(offset); offset += 1;
    this.CheckExit = view.getUint8(offset); offset += 1;
    this.CheckNum = view.getUint8(offset); offset += 1;
    this.nIQSEnable = view.getUint8(offset); offset += 1;
    
    return offset;
  }
}
