/**
 * StWaveInfo 类型定义
 * 对应48项目的 StWaveInfo 结构体
 * 波形数据，FSM发送过来 (WM, HC_ID, FSM_CMD_WAVEINFO, stWaveInfo)
 */

// 波形数据点数量
export const WAVE_POINT_COUNT = 256;

/**
 * 波形数据结构
 */
export interface StWaveInfo {
  /** 通道ID (WM通道) */
  nChannelId: number; // int, 4字节
  
  /** 波形数据0 (AD0通道) - 256个采样点，每个2字节 */
  waveform0: number[]; // ushort[256], 512字节
  
  /** 波形数据1 (AD1通道) - 256个采样点，每个2字节 */
  waveform1: number[]; // ushort[256], 512字节
  
  /** 水果重量 (克) */
  fruitweight: number; // float, 4字节
}

/**
 * 创建默认的StWaveInfo对象
 */
export function createDefaultStWaveInfo(): StWaveInfo {
  return {
    nChannelId: 0,
    waveform0: new Array(WAVE_POINT_COUNT).fill(0),
    waveform1: new Array(WAVE_POINT_COUNT).fill(0),
    fruitweight: 0.0
  };
}

