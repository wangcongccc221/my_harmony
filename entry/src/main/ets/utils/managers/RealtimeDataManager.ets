/**
 * 实时数据管理器
 * 功能：
 * - 管理从TCP接收的实时统计数据
 * - 计算实时指标（分选效率、实时产量、平均重量等）
 * - 提供数据更新事件通知
 * - 支持多子系统（FSM1、FSM2）数据管理
 */

import { StStatistics, createDefaultStStatistics } from '../network/tcp/types/StStatistics';

const DOMAIN = 0x0000;

// 命令ID定义（对应48项目的FSM_HC_COMMAND_TYPE）
const FSM_CMD_STATISTICS = 0x0001;  // 统计信息命令

/**
 * 全局数据更新版本号（用于UI轮询检测数据变化）
 * 注意：这是一个普通的全局对象，可以在TaskPool中安全访问
 */
class GlobalDataUpdateVersion {
  // 每个子系统的数据更新版本号
  private static updateVersions: Map<number, number> = new Map();
  
  /**
   * 获取指定子系统的更新版本号
   */
  static getVersion(subsysId: number): number {
    return GlobalDataUpdateVersion.updateVersions.get(subsysId) || 0;
  }
  
  /**
   * 递增指定子系统的更新版本号（在TaskPool中调用）
   */
  static incrementVersion(subsysId: number): void {
    const currentVersion: number = GlobalDataUpdateVersion.updateVersions.get(subsysId) || 0;
    GlobalDataUpdateVersion.updateVersions.set(subsysId, currentVersion + 1);
  }
  
  /**
   * 重置版本号
   */
  static resetVersion(subsysId: number): void {
    GlobalDataUpdateVersion.updateVersions.set(subsysId, 0);
  }
}

/**
 * 上次统计数据接口（用于计算增量）
 */
interface PreviousStatistics {
  nTotalCount: number;
  nTotalCupNum: number;
  nWeightCount: number;
}

/**
 * 实时计算的数据结构
 */
export interface RealtimeCalculatedData {
  /** 分选效率（%） */
  separationEfficiency: number;
  
  /** 实时产量（吨/小时） */
  realTimeOutput: number;
  
  /** 实时产量百分比（%） */
  realTimeOutputPercent: number;
  
  /** 速度百分比（%） */
  speedPercent: number;
  
  /** 平均果重（克） */
  avgWeight: number;
  
  /** 分选速度（个/分钟） */
  sortSpeed: number;
  
  /** 间隔速度（ms） */
  intervalSpeed: number;
}

/**
 * 实时数据管理器类
 */
export class RealtimeDataManager {
  private static instance: RealtimeDataManager | null = null;
  
  // 存储每个子系统的统计数据
  private statisticsData: Map<number, StStatistics> = new Map();
  
  // 存储上次的统计数据（用于计算增量）
  private previousStatistics: Map<number, PreviousStatistics> = new Map();
  
  // 存储计算后的实时数据
  private calculatedData: Map<number, RealtimeCalculatedData> = new Map();
  
  // 最大实时产量（用于计算百分比）
  private maxRealWeightCount: number = 100.0; // 默认100吨/小时
  
  // 最大分选速度（用于计算百分比）
  private maxSpeed: number = 100; // 默认100个/分钟
  
  // 计算定时器
  private calculateTimerId: number | null = null;
  private readonly CALCULATE_INTERVAL = 3000; // 每3秒计算一次
  
  private constructor() {
    console.log('[RealtimeDataManager] 实时数据管理器已创建');
    this.loadConfig();
    this.startCalculateTimer();
  }

  /**
   * 获取单例实例
   */
  static getInstance(): RealtimeDataManager {
    if (!RealtimeDataManager.instance) {
      RealtimeDataManager.instance = new RealtimeDataManager();
    }
    return RealtimeDataManager.instance;
  }

  /**
   * 加载配置
   */
  private loadConfig(): void {
    // 从AppStorage或数据库加载配置
    // 注意：AppStorage在HarmonyOS中是全局的，不需要导入
    try {
      const maxRealWeight = AppStorage.get<number>('MaxRealWeightCount');
      if (maxRealWeight !== undefined && typeof maxRealWeight === 'number') {
        this.maxRealWeightCount = maxRealWeight;
      }
      
      const maxSpeed = AppStorage.get<number>('MaxSpeed');
      if (maxSpeed !== undefined && typeof maxSpeed === 'number') {
        this.maxSpeed = maxSpeed;
      }
    } catch (error) {
      // 如果AppStorage不可用，使用默认值
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.warn(`[RealtimeDataManager] 无法从AppStorage加载配置，使用默认值: ${errorMsg}`);
    }
  }

  /**
   * 更新统计数据
   * @param subsysId 子系统ID（0=FSM1, 1=FSM2等）
   * @param statistics 统计数据
   */
  updateStatistics(subsysId: number, statistics: StStatistics): void {
    try {
      // 保存当前数据为上次数据（用于计算增量）
      const currentStats = this.statisticsData.get(subsysId);
      if (currentStats) {
        const prevStats: PreviousStatistics = {
          nTotalCount: currentStats.nTotalCount,
          nTotalCupNum: currentStats.nTotalCupNum,
          nWeightCount: currentStats.nWeightCount
        };
        this.previousStatistics.set(subsysId, prevStats);
      } else {
        // 首次接收，初始化上次数据
        const prevStats: PreviousStatistics = {
          nTotalCount: 0,
          nTotalCupNum: 0,
          nWeightCount: 0
        };
        this.previousStatistics.set(subsysId, prevStats);
      }
      
      // 更新统计数据
      this.statisticsData.set(subsysId, statistics);
      
      // 立即计算一次
      this.calculateRealtimeData(subsysId);
      
      // 通知UI更新
      this.notifyDataUpdate(subsysId);
      
      console.log(`[RealtimeDataManager] 子系统${subsysId}统计数据已更新 - 总个数: ${statistics.nTotalCount}, 总重量: ${statistics.nWeightCount}克`);
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error(`[RealtimeDataManager] 更新统计数据失败: ${errorMsg}`);
    }
  }

  /**
   * 计算实时数据
   * @param subsysId 子系统ID
   */
  private calculateRealtimeData(subsysId: number): void {
    const stats: StStatistics | undefined = this.statisticsData.get(subsysId);
    if (!stats) {
      return;
    }
    
    const previous: PreviousStatistics | undefined = this.previousStatistics.get(subsysId);
    if (!previous) {
      return;
    }
    
    const calculated: RealtimeCalculatedData = {
      separationEfficiency: 0,
      realTimeOutput: 0,
      realTimeOutputPercent: 0,
      speedPercent: 0,
      avgWeight: 0,
      sortSpeed: 0,
      intervalSpeed: 0
    };
    
    // 1. 计算分选效率
    const nowTotalCount = stats.nTotalCount;
    const nowTotalCupNum = stats.nTotalCupNum;
    const preTotalCount = previous.nTotalCount;
    const preTotalCupNum = previous.nTotalCupNum;
    
    if (nowTotalCount < preTotalCount || nowTotalCupNum < preTotalCupNum) {
      calculated.separationEfficiency = 0;
    } else {
      const cupDiff = nowTotalCupNum - preTotalCupNum;
      if (cupDiff !== 0) {
        const efficiency = ((nowTotalCount - preTotalCount) * 100.0) / cupDiff;
        calculated.separationEfficiency = Math.max(0, Math.min(100, efficiency));
      } else {
        calculated.separationEfficiency = 0;
      }
    }
    
    // 2. 计算实时产量（吨/小时）
    const nowWeightCount = stats.nWeightCount / 1000000.0; // 转换为吨
    const preWeightCount = previous.nWeightCount / 1000000.0;
    
    if (nowWeightCount > preWeightCount) {
      // 转换为每小时产量：每3秒的增量 * 1200（3600/3）
      calculated.realTimeOutput = (nowWeightCount - preWeightCount) * 1200.0;
      if (calculated.realTimeOutput < 0) {
        calculated.realTimeOutput = 0;
      }
    } else {
      calculated.realTimeOutput = 0;
    }
    
    // 3. 计算实时产量百分比
    if (this.maxRealWeightCount > 0) {
      calculated.realTimeOutputPercent = Math.round((calculated.realTimeOutput * 100) / this.maxRealWeightCount);
      calculated.realTimeOutputPercent = Math.max(0, Math.min(100, calculated.realTimeOutputPercent));
    }
    
    // 4. 计算分选速度（个/分钟）
    calculated.sortSpeed = stats.nIntervalSumperminute;
    
    // 5. 计算速度百分比
    if (this.maxSpeed > 0) {
      calculated.speedPercent = (calculated.sortSpeed * 100.0) / this.maxSpeed;
    }
    
    // 6. 计算平均果重（克）
    if (nowTotalCount > 0) {
      calculated.avgWeight = (stats.nWeightCount / nowTotalCount);
    } else {
      calculated.avgWeight = 0;
    }
    
    // 7. 间隔速度（ms）
    calculated.intervalSpeed = stats.nPulseInterval;
    
    // 保存计算结果
    this.calculatedData.set(subsysId, calculated);
  }

  /**
   * 启动计算定时器
   */
  private startCalculateTimer(): void {
    if (this.calculateTimerId !== null) {
      return;
    }
    
    this.calculateTimerId = setInterval(() => {
      // 对所有子系统进行计算
      const keys = Array.from(this.statisticsData.keys());
      for (let i = 0; i < keys.length; i++) {
        const subsysId: number = keys[i];
        this.calculateRealtimeData(subsysId);
        this.notifyDataUpdate(subsysId);
      }
    }, this.CALCULATE_INTERVAL) as number;
    
    console.log('[RealtimeDataManager] 实时计算定时器已启动（3秒间隔）');
  }

  /**
   * 停止计算定时器
   */
  private stopCalculateTimer(): void {
    if (this.calculateTimerId !== null) {
      clearInterval(this.calculateTimerId);
      this.calculateTimerId = null;
      console.log('[RealtimeDataManager] 实时计算定时器已停止');
    }
  }

  /**
   * 通知数据更新
   * @param subsysId 子系统ID
   * 注意：现在TCP服务器在UI线程中运行，可以直接使用AppStorage
   */
  private notifyDataUpdate(subsysId: number): void {
    try {
      // 使用 setTimeout 确保在 UI 线程中执行 AppStorage 更新
      // 因为 socket 事件回调可能在后台线程中执行
      setTimeout(() => {
        try {
          // 使用AppStorage通知UI更新（现在可以在UI线程中使用）
          AppStorage.setOrCreate(`TCP_STATISTICS_UPDATE_${subsysId}`, Date.now());
          
          // 触发全局更新事件
          AppStorage.setOrCreate('TCP_STATISTICS_GLOBAL_UPDATE', Date.now());
          
          // 同时递增全局版本号（作为备用机制）
          GlobalDataUpdateVersion.incrementVersion(subsysId);
          
          console.log(`[RealtimeDataManager] 已通知UI更新 - 子系统ID: ${subsysId}`);
        } catch (error) {
          const errorMsg = error instanceof Error ? error.message : String(error);
          console.warn(`[RealtimeDataManager] 无法更新AppStorage，UI可能不会自动刷新: ${errorMsg}`);
        }
      }, 0);
      
      console.log(`[RealtimeDataManager] 数据已更新，子系统ID: ${subsysId}, 版本号: ${GlobalDataUpdateVersion.getVersion(subsysId)}`);
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.warn(`[RealtimeDataManager] 无法更新AppStorage: ${errorMsg}`);
      // 如果AppStorage失败，至少递增版本号
      GlobalDataUpdateVersion.incrementVersion(subsysId);
    }
  }
  
  /**
   * 获取数据更新版本号（用于UI轮询检查）
   * @param subsysId 子系统ID
   * @returns 更新版本号
   */
  getUpdateVersion(subsysId: number): number {
    return GlobalDataUpdateVersion.getVersion(subsysId);
  }

  /**
   * 获取统计数据
   * @param subsysId 子系统ID
   * @returns 统计数据，如果不存在则返回默认值
   */
  getStatistics(subsysId: number): StStatistics {
    return this.statisticsData.get(subsysId) || createDefaultStStatistics();
  }

  /**
   * 获取所有子系统的统计数据（累加）
   * @returns 累加后的统计数据
   */
  getAllStatistics(): StStatistics {
    const result: StStatistics = createDefaultStStatistics();
    
    // 遍历所有子系统数据
    const keys = Array.from(this.statisticsData.keys());
    for (let i = 0; i < keys.length; i++) {
      const subsysId: number = keys[i];
      const stats: StStatistics | undefined = this.statisticsData.get(subsysId);
      if (!stats) {
        continue;
      }
      // 累加总体数据
      result.nTotalCount += stats.nTotalCount;
      result.nWeightCount += stats.nWeightCount;
      result.nTotalCupNum += stats.nTotalCupNum;
      result.nIntervalSumperminute += stats.nIntervalSumperminute;
      
      // 累加数组数据
      for (let i = 0; i < stats.nGradeCount.length; i++) {
        result.nGradeCount[i] += stats.nGradeCount[i];
        result.nWeightGradeCount[i] += stats.nWeightGradeCount[i];
        result.nBoxGradeCount[i] += stats.nBoxGradeCount[i];
      }
      
      for (let i = 0; i < stats.nExitCount.length; i++) {
        result.nExitCount[i] += stats.nExitCount[i];
        result.nExitWeightCount[i] += stats.nExitWeightCount[i];
        result.ExitBoxNum[i] += stats.ExitBoxNum[i];
      }
    }
    
    // 计算平均速度（如果有多个子系统）
    if (this.statisticsData.size > 0) {
      let validSubsysCount: number = 0;
      let totalSpeed: number = 0;
      
      const values = Array.from(this.statisticsData.values());
      for (let i = 0; i < values.length; i++) {
        const stats: StStatistics = values[i];
        if (stats.nIntervalSumperminute > 0) {
          totalSpeed += stats.nIntervalSumperminute;
          validSubsysCount++;
        }
      }
      
      if (validSubsysCount > 0) {
        result.nIntervalSumperminute = Math.round(totalSpeed / validSubsysCount);
      }
    }
    
    return result;
  }

  /**
   * 获取计算后的实时数据
   * @param subsysId 子系统ID
   * @returns 计算后的实时数据
   */
  getCalculatedData(subsysId: number): RealtimeCalculatedData | null {
    return this.calculatedData.get(subsysId) || null;
  }

  /**
   * 获取所有子系统的计算数据（平均值）
   * @returns 平均后的计算数据
   */
  getAllCalculatedData(): RealtimeCalculatedData {
    const result: RealtimeCalculatedData = {
      separationEfficiency: 0,
      realTimeOutput: 0,
      realTimeOutputPercent: 0,
      speedPercent: 0,
      avgWeight: 0,
      sortSpeed: 0,
      intervalSpeed: 0
    };
    
    if (this.calculatedData.size === 0) {
      return result;
    }
    
    // 计算平均值
    let count: number = 0;
    const calculatedValues = Array.from(this.calculatedData.values());
    for (let i = 0; i < calculatedValues.length; i++) {
      const data: RealtimeCalculatedData = calculatedValues[i];
      result.separationEfficiency += data.separationEfficiency;
      result.realTimeOutput += data.realTimeOutput;
      result.realTimeOutputPercent += data.realTimeOutputPercent;
      result.speedPercent += data.speedPercent;
      result.avgWeight += data.avgWeight;
      result.sortSpeed += data.sortSpeed;
      result.intervalSpeed += data.intervalSpeed;
      count++;
    }
    
    if (count > 0) {
      result.separationEfficiency /= count;
      result.realTimeOutput /= count;
      result.realTimeOutputPercent /= count;
      result.speedPercent /= count;
      result.avgWeight /= count;
      result.sortSpeed /= count;
      result.intervalSpeed /= count;
    }
    
    return result;
  }

  /**
   * 清空所有数据
   */
  clearAll(): void {
    this.statisticsData.clear();
    this.previousStatistics.clear();
    this.calculatedData.clear();
    console.log('[RealtimeDataManager] 所有实时数据已清空');
  }

  /**
   * 销毁管理器
   */
  destroy(): void {
    this.stopCalculateTimer();
    this.clearAll();
    RealtimeDataManager.instance = null;
    console.log('[RealtimeDataManager] 实时数据管理器已销毁');
  }
}

