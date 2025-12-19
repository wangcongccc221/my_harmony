/**
 * 波形数据处理器
 * 功能：处理从TCP接收的StWaveInfo二进制数据
 * 
 * 数据存储：
 * - 将波形数据存储在AppStorage中，最多保存100组
 * - 存储键：'waveInfoList' (StWaveInfo[])
 * - 当列表超过100组时，移除最旧的数据
 */

import { TcpWaveInfoParser, TcpWaveDataPacket } from '../parsers/TcpWaveInfoParser';
import { StWaveInfo } from '../types/StWaveInfo';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const FSM_CMD_WAVEINFO = 0x1004; // 波形信息命令ID
const MAX_WAVE_LIST_SIZE = 100; // 最多保存100组波形数据

/**
 * 处理TCP接收的波形数据
 * @param data TCP接收的原始字节数组
 */
export async function handleWaveInfoData(data: Uint8Array): Promise<void> {
  try {
    console.log(`[WaveInfoDataHandler] 收到数据，长度: ${data.length} 字节`);
    
    // 检查是否为SYNC开头
    if (!TcpWaveInfoParser.isSync(data)) {
      console.warn(`[WaveInfoDataHandler] 接收的数据不是以SYNC开头，前4字节: ${data[0]}, ${data[1]}, ${data[2]}, ${data[3]}`);
      return;
    }
    
    console.log(`[WaveInfoDataHandler] 数据包以SYNC开头，开始解析...`);
    
    // 解析TCP数据包
    const packet: TcpWaveDataPacket | null = TcpWaveInfoParser.parseTcpPacket(data);
    if (!packet) {
      console.warn(`[WaveInfoDataHandler] 解析TCP数据包失败`);
      return;
    }

    // 从packet中提取waveInfo
    const waveInfo: StWaveInfo = packet.waveInfo;
    
    console.log(`[WaveInfoDataHandler] TCP数据包解析成功 - 通道ID: ${waveInfo.nChannelId}, 水果重量: ${waveInfo.fruitweight}g`);
    console.log(`[WaveInfoDataHandler] waveform0[0]: ${waveInfo.waveform0[0]}, waveform1[0]: ${waveInfo.waveform1[0]}`);
    
    // 检查命令ID是否为波形信息命令
    if (packet.commandHead.nCmdId !== FSM_CMD_WAVEINFO) {
      console.warn(`[WaveInfoDataHandler] 收到非波形信息命令，命令ID: ${packet.commandHead.nCmdId}，期望: ${FSM_CMD_WAVEINFO}`);
      return;
    }
    
    // 获取现有的波形数据列表
    let waveInfoList: StWaveInfo[] = AppStorage.get<StWaveInfo[]>('waveInfoList') || [];
    
    // 添加新的波形数据
    waveInfoList.push(waveInfo);
    
    // 如果超过最大数量，移除最旧的数据
    if (waveInfoList.length > MAX_WAVE_LIST_SIZE) {
      waveInfoList = waveInfoList.slice(waveInfoList.length - MAX_WAVE_LIST_SIZE);
    }
    
    // 存储更新后的列表
    AppStorage.setOrCreate('waveInfoList', waveInfoList);
    
    // 同时存储按通道ID分组的波形数据（用于快速查找）
    const channelKey = `waveInfoList_${waveInfo.nChannelId}`;
    let channelWaveInfoList: StWaveInfo[] = AppStorage.get<StWaveInfo[]>(channelKey) || [];
    channelWaveInfoList.push(waveInfo);
    if (channelWaveInfoList.length > MAX_WAVE_LIST_SIZE) {
      channelWaveInfoList = channelWaveInfoList.slice(channelWaveInfoList.length - MAX_WAVE_LIST_SIZE);
    }
    AppStorage.setOrCreate(channelKey, channelWaveInfoList);
    
    // 触发UI更新（使用时间戳作为更新信号）
    AppStorage.setOrCreate('TCP_WAVEINFO_UPDATE', Date.now());
    
    console.log(`[WaveInfoDataHandler] 波形数据已存储 - 总数量: ${waveInfoList.length}, 通道ID: ${waveInfo.nChannelId}`);
    
    hilog.info(DOMAIN, 'WaveInfoDataHandler', `波形数据已存储 - 通道ID: ${waveInfo.nChannelId}, 水果重量: ${waveInfo.fruitweight}g, 总数量: ${waveInfoList.length}`);
    
  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : String(error);
    console.error(`[WaveInfoDataHandler] 处理波形数据失败: ${errorMsg}`);
    if (error instanceof Error && error.stack) {
      console.error(`[WaveInfoDataHandler] 错误堆栈: ${error.stack}`);
    }
    hilog.error(DOMAIN, 'WaveInfoDataHandler', `处理波形数据失败: ${errorMsg}`);
  }
}

