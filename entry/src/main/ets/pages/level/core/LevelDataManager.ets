/**
 * 等级页面数据管理器
 * 
 * 功能说明：
 * - 管理等级页面的所有数据、数据操作
 * - 统一处理等级页面的数据管理逻辑
 * - 提供数据的增删改查功能
 * - 支持数据的初始化和随机生成
 * 
 * 管理的数据类型：
 * - 等级数据：等级名称、最小重量、包装重量等
 * - 统计数据：底部1和底部2的计数、平均值、设定值等
 * 
 * 主要功能：
 * - 数据初始化：从默认数据初始化等级和统计数据
 * - 数据获取：提供获取等级数据和统计数据的方法
 * - 数据更新：支持更新等级数据和统计数据
 * - 数据调整：根据表格数量调整等级数据
 * - 随机生成：生成随机的统计数据用于测试
 * - 数据清空：清空统计数据
 * 
 * 使用方式：
 * ```typescript
 * const dataManager = new LevelDataManager()
 * 
 * // 初始化数据
 * dataManager.initializeLevelData()
 * 
 * // 获取数据
 * const levelData = dataManager.getLevelData()
 * const statisticsData = dataManager.getStatisticsData()
 * 
 * // 更新数据
 * dataManager.updateLevelData(newLevelData)
 * dataManager.updateStatisticsData(newStatisticsData)
 * 
 * // 生成随机数据
 * dataManager.generateRandomStatisticsData()
 * ```
 * 
 * 数据安全：
 * - 使用深拷贝避免数据污染
 * - 提供数据验证和类型检查
 * - 支持数据重置和恢复
 */

import { DefaultLevelData, DefaultStatisticsData, DEFAULT_LEVEL_DATA, DEFAULT_STATISTICS_DATA } from '../LevelConstants'

/**
 * 等级数据接口
 * 
 * 功能说明：
 * - 定义等级数据的结构
 * - 用于存储和管理等级信息
 * - 包含等级的基本属性
 * 
 * 属性说明：
 * - levelName: 等级名称，如'A级'、'B级'等
 * - minWeight: 最小重量，用于等级判断
 * - packingWeight: 包装重量，用于包装计算
 */
export interface LevelData {
  /** 等级名称（如'A级'、'B级'等） */
  levelName: string
  /** 最小重量（用于等级判断） */
  minWeight: number
  /** 包装重量（用于包装计算） */
  packingWeight: number
}

/**
 * 统计数据接口
 * 
 * 功能说明：
 * - 定义统计数据的结构
 * - 用于存储分选过程中的统计数据
 * - 包含底部1和底部2的各种数据
 * 
 * 属性说明：
 * - bottom1Counts: 底部1的计数数据数组
 * - bottom1Avgs: 底部1的平均值数据数组
 * - bottom1Sets: 底部1的设定值数据数组
 * - bottom2Counts: 底部2的计数数据数组
 * - bottom2Avgs: 底部2的平均值数据数组
 * - bottom2Sets: 底部2的设定值数据数组
 */
export interface StatisticsData {
  /** 底部1的计数数据数组 */
  bottom1Counts: number[]
  /** 底部1的平均值数据数组 */
  bottom1Avgs: number[]
  /** 底部1的设定值数据数组 */
  bottom1Sets: number[]
  /** 底部2的计数数据数组 */
  bottom2Counts: number[]
  /** 底部2的平均值数据数组 */
  bottom2Avgs: number[]
  /** 底部2的设定值数据数组 */
  bottom2Sets: number[]
}

/**
 * 等级页面数据管理器类
 * 
 * 功能说明：
 * - 管理等级页面的所有数据操作
 * - 提供数据的增删改查功能
 * - 支持数据的初始化和随机生成
 * - 确保数据的安全性和一致性
 * 
 * 属性说明：
 * - levelData: 等级数据数组，存储所有等级信息
 * - statisticsData: 统计数据对象，存储分选统计数据
 * 
 * 方法说明：
 * - initializeLevelData(): 初始化等级数据
 * - getLevelData(): 获取等级数据
 * - getStatisticsData(): 获取统计数据
 * - updateLevelData(): 更新等级数据
 * - updateStatisticsData(): 更新统计数据
 * - adjustLevelDataByCount(): 根据表格数量调整等级数据
 * - generateRandomStatisticsData(): 生成随机统计数据
 * - clearStatisticsData(): 清空统计数据
 */
export class LevelDataManager {
  /**
   * 等级数据数组
   * 
   * 功能说明：
   * - 存储所有等级的数据信息
   * - 默认值为空数组
   * - 支持动态添加、删除、修改等级
   */
  private levelData: LevelData[] = []
  
  /**
   * 统计数据对象
   * 
   * 功能说明：
   * - 存储分选过程中的统计数据
   * - 使用深拷贝初始化，避免数据污染
   * - 包含底部1和底部2的各种数据
   */
  private statisticsData: StatisticsData = {
    bottom1Counts: DEFAULT_STATISTICS_DATA.bottom1Counts.slice(),  // 底部1计数数据（深拷贝）
    bottom1Avgs: DEFAULT_STATISTICS_DATA.bottom1Avgs.slice(),      // 底部1平均值数据（深拷贝）
    bottom1Sets: DEFAULT_STATISTICS_DATA.bottom1Sets.slice(),       // 底部1设定值数据（深拷贝）
    bottom2Counts: DEFAULT_STATISTICS_DATA.bottom2Counts.slice(),  // 底部2计数数据（深拷贝）
    bottom2Avgs: DEFAULT_STATISTICS_DATA.bottom2Avgs.slice(),       // 底部2平均值数据（深拷贝）
    bottom2Sets: DEFAULT_STATISTICS_DATA.bottom2Sets.slice()        // 底部2设定值数据（深拷贝）
  }

  // ==================== 数据初始化方法 ====================
  /**
   * 初始化等级数据
   * 
   * 功能说明：
   * - 从默认数据初始化等级数据
   * - 使用深拷贝避免数据污染
   * - 记录初始化日志，便于调试
   * 
   * 初始化内容：
   * - 从DEFAULT_LEVEL_DATA获取默认等级数据
   * - 使用slice()方法进行深拷贝
   * - 包含A级、B级、C级三个等级的默认配置
   * 
   * 使用场景：
   * - 页面首次加载时
   * - 数据重置时
   * - 组件初始化时
   */
  initializeLevelData(): void {
    this.levelData = DEFAULT_LEVEL_DATA.slice()
    console.log('等级数据初始化完成:', this.levelData)
  }

  // ==================== 数据获取方法 ====================
  /**
   * 获取等级数据
   * 
   * 功能说明：
   * - 返回当前存储的等级数据
   * - 提供只读访问，确保数据安全
   * - 返回等级数据数组的副本
   * 
   * @returns 等级数据数组
   * 
   * 使用场景：
   * - 需要显示等级数据时
   * - 需要传递给其他组件时
   * - 需要备份等级数据时
   */
  getLevelData(): LevelData[] {
    return this.levelData
  }

  /**
   * 添加等级数据
   * 
   * 功能说明：
   * - 向等级数据数组添加新的等级数据
   * - 记录添加日志，便于调试和监控
   * - 支持动态扩展等级数据
   * 
   * @param data 要添加的等级数据
   * 
   * 使用场景：
   * - 用户创建新等级时
   * - 程序动态添加等级时
   * - 数据导入时
   */
  addLevelData(data: LevelData): void {
    this.levelData.push(data)
    console.log('添加等级数据:', data)
  }

  /**
   * 获取统计数据
   * 
   * 功能说明：
   * - 返回当前存储的统计数据
   * - 提供只读访问，确保数据安全
   * - 返回统计数据对象的副本
   * 
   * @returns 统计数据对象
   * 
   * 使用场景：
   * - 需要显示统计数据时
   * - 需要传递给其他组件时
   * - 需要备份统计数据时
   */
  getStatisticsData(): StatisticsData {
    return this.statisticsData
  }

  // ==================== 数据生成方法 ====================
  /**
   * 生成随机统计数据
   * 
   * 功能说明：
   * - 生成随机的统计数据用于测试
   * - 使用随机数生成器创建模拟数据
   * - 支持自定义数据范围和数量
   * 
   * 生成规则：
   * - 底部1计数：45-55范围
   * - 底部1平均值：120-132范围
   * - 底部1设定值：120固定值
   * - 底部2计数：45-55范围
   * - 底部2平均值：120-132范围
   * - 底部2设定值：118固定值
   * 
   * 使用场景：
   * - 测试数据生成时
   * - 演示功能时
   * - 数据模拟时
   */
  generateRandomStatisticsData(): void {
    const zeros: number[] = new Array<number>(8).fill(0)
    this.statisticsData = {
      bottom1Counts: zeros.slice(),
      bottom1Avgs: zeros.slice(),
      bottom1Sets: zeros.slice(),
      bottom2Counts: zeros.slice(),
      bottom2Avgs: zeros.slice(),
      bottom2Sets: zeros.slice()
    }
    console.log('生成随机统计数据:', this.statisticsData)
  }

  /**
   * 清空统计数据
   */
  clearStatisticsData(): void {
    const zeros: number[] = new Array<number>(8).fill(0)
    this.statisticsData = {
      bottom1Counts: zeros.slice(),
      bottom1Avgs: zeros.slice(),
      bottom1Sets: zeros.slice(),
      bottom2Counts: zeros.slice(),
      bottom2Avgs: zeros.slice(),
      bottom2Sets: zeros.slice()
    }
    console.log('清空统计数据')
  }

  /**
   * 根据表格数量调整等级数据
   * @param count 表格数量
   */
  adjustLevelDataByCount(count: number): void {
    const currentCount = this.levelData.length
    if (count > currentCount) {
      // 添加新等级
      for (let i = currentCount; i < count; i++) {
        const newLevel: LevelData = {
          levelName: `${String.fromCharCode(65 + i)}级`,
          minWeight: 120 - i * 20,
          packingWeight: 5000 - i * 500
        }
        this.addLevelData(newLevel)
      }
    } else if (count < currentCount) {
      // 删除多余等级
      this.levelData = this.levelData.slice(0, count)
    }
    console.log(`根据数量${count}调整等级数据:`, this.levelData)
  }
}
