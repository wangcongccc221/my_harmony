/**
 * 等级信息管理器
 * 功能：管理从TCP接收的等级配置信息（FSM_CMD_CONFIG命令）
 * 对应48项目中的globalOut_GradeInfo
 */

import { StGradeInfo, createDefaultStGradeInfo } from '../network/tcp/types/StGradeInfo';
// AppStorage 是全局可用的，无需导入

// AppStorage键名
const GRADE_INFO_KEY_PREFIX = 'GRADE_INFO_';  // 每个子系统一个
const GRADE_INFO_UPDATE_KEY = 'GRADE_INFO_UPDATE';  // 全局更新通知

/**
 * 等级信息管理器（单例）
 */
export class GradeInfoManager {
  private static instance: GradeInfoManager | null = null;
  
  // 每个子系统的等级信息
  private gradeInfos: Map<number, StGradeInfo> = new Map();
  
  private constructor() {
    // 私有构造函数，确保单例
  }
  
  /**
   * 获取单例实例
   */
  static getInstance(): GradeInfoManager {
    if (!GradeInfoManager.instance) {
      GradeInfoManager.instance = new GradeInfoManager();
    }
    return GradeInfoManager.instance;
  }
  
  /**
   * 更新指定子系统的等级信息
   * @param subsysId 子系统ID
   * @param gradeInfo 等级信息
   */
  updateGradeInfo(subsysId: number, gradeInfo: StGradeInfo): void {
    this.gradeInfos.set(subsysId, gradeInfo);
    
    // 更新AppStorage，通知UI
    setTimeout(() => {
      try {
        AppStorage.setOrCreate(`${GRADE_INFO_KEY_PREFIX}${subsysId}`, gradeInfo);
        AppStorage.setOrCreate(GRADE_INFO_UPDATE_KEY, Date.now());
        console.log(`[GradeInfoManager] 已更新子系统${subsysId}的等级信息 - 尺寸等级数: ${gradeInfo.nSizeGradeNum}, 品质等级数: ${gradeInfo.nQualityGradeNum}`);
      } catch (error) {
        const errorMsg = error instanceof Error ? error.message : String(error);
        console.error(`[GradeInfoManager] 无法更新AppStorage: ${errorMsg}`);
      }
    }, 0);
  }
  
  /**
   * 获取指定子系统的等级信息
   * @param subsysId 子系统ID
   * @returns 等级信息，如果不存在则返回默认值
   */
  getGradeInfo(subsysId: number): StGradeInfo {
    const gradeInfo = this.gradeInfos.get(subsysId);
    if (gradeInfo) {
      return gradeInfo;
    }
    
    // 如果不存在，返回默认值
    const defaultGradeInfo = createDefaultStGradeInfo();
    // 设置默认等级名称
    defaultGradeInfo.strQualityGradeName = ['A级', 'B级', 'C级', 'D级', 'E级', 'F级', 'G级', 'H级'];
    defaultGradeInfo.nQualityGradeNum = 8;
    defaultGradeInfo.nSizeGradeNum = 1;
    
    return defaultGradeInfo;
  }
  
  /**
   * 获取指定子系统的品质等级名称列表
   * @param subsysId 子系统ID
   * @returns 品质等级名称数组
   */
  getQualityGradeNames(subsysId: number): string[] {
    const gradeInfo = this.getGradeInfo(subsysId);
    const names: string[] = [];
    
    for (let i = 0; i < gradeInfo.nQualityGradeNum && i < gradeInfo.strQualityGradeName.length; i++) {
      const name = gradeInfo.strQualityGradeName[i];
      if (name && name.trim() !== '') {
        names.push(name);
      } else {
        // 如果名称为空，使用默认名称
        names.push(`${String.fromCharCode(65 + i)}级`); // A级, B级, C级...
      }
    }
    
    // 如果没有配置，返回默认名称
    if (names.length === 0) {
      return ['A级', 'B级', 'C级', 'D级', 'E级', 'F级', 'G级', 'H级'];
    }
    
    return names;
  }
  
  /**
   * 获取指定子系统的尺寸等级名称列表
   * @param subsysId 子系统ID
   * @returns 尺寸等级名称数组
   */
  getSizeGradeNames(subsysId: number): string[] {
    const gradeInfo = this.getGradeInfo(subsysId);
    const names: string[] = [];
    
    for (let i = 0; i < gradeInfo.nSizeGradeNum && i < gradeInfo.strSizeGradeName.length; i++) {
      const name = gradeInfo.strSizeGradeName[i];
      if (name && name.trim() !== '') {
        names.push(name);
      } else {
        // 如果名称为空，使用默认名称
        names.push(`尺寸${i + 1}`);
      }
    }
    
    // 如果没有配置，返回默认名称
    if (names.length === 0) {
      return ['尺寸1'];
    }
    
    return names;
  }
  
  /**
   * 检查是否有等级配置信息
   * @param subsysId 子系统ID
   * @returns 是否有配置信息
   */
  hasGradeInfo(subsysId: number): boolean {
    return this.gradeInfos.has(subsysId);
  }
}

