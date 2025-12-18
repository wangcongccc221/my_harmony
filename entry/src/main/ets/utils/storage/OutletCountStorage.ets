/**
 * 出口数量持久化存储工具
 * 功能：持久化存储FSM1和FSM2的出口数量，应用重启后仍然有效
 */

import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

const OUTLET_COUNT_FSM1_KEY = 'outlet_count_fsm1'
const OUTLET_COUNT_FSM2_KEY = 'outlet_count_fsm2'
const DEFAULT_OUTLET_COUNT = 20

/**
 * 出口数量接口
 */
export interface OutletCounts {
  fsm1: number
  fsm2: number
}

export class OutletCountStorage {
  private static instance: OutletCountStorage | null = null
  private preferencesStore: preferences.Preferences | null = null
  private context: common.UIAbilityContext | null = null

  private constructor() {}

  static getInstance(): OutletCountStorage {
    if (!OutletCountStorage.instance) {
      OutletCountStorage.instance = new OutletCountStorage()
    }
    return OutletCountStorage.instance
  }

  /**
   * 初始化 Preferences 存储
   */
  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.preferencesStore) {
      return // 已经初始化过
    }

    try {
      this.context = context
      const dataPreferences = await preferences.getPreferences(context, 'outlet_count_settings')
      this.preferencesStore = dataPreferences
      console.log('[OutletCountStorage] Preferences initialized')
    } catch (e) {
      console.error('[OutletCountStorage] Failed to initialize Preferences:', JSON.stringify(e))
    }
  }

  /**
   * 保存FSM1的出口数量
   */
  async saveFSM1OutletCount(count: number): Promise<void> {
    if (!this.preferencesStore) {
      console.warn('[OutletCountStorage] Preferences not initialized, cannot save FSM1 outlet count')
      return
    }

    try {
      await this.preferencesStore.put(OUTLET_COUNT_FSM1_KEY, count)
      await this.preferencesStore.flush()
      console.log(`[OutletCountStorage] Saved FSM1 outlet count: ${count}`)
    } catch (e) {
      console.error('[OutletCountStorage] Failed to save FSM1 outlet count:', JSON.stringify(e))
    }
  }

  /**
   * 加载FSM1的出口数量
   */
  async loadFSM1OutletCount(): Promise<number> {
    if (!this.preferencesStore) {
      console.warn('[OutletCountStorage] Preferences not initialized, returning default FSM1 outlet count')
      return DEFAULT_OUTLET_COUNT
    }

    try {
      const count = await this.preferencesStore.get(OUTLET_COUNT_FSM1_KEY, DEFAULT_OUTLET_COUNT)
      console.log(`[OutletCountStorage] Loaded FSM1 outlet count: ${count}`)
      return count as number
    } catch (e) {
      console.error('[OutletCountStorage] Failed to load FSM1 outlet count:', JSON.stringify(e))
      return DEFAULT_OUTLET_COUNT
    }
  }

  /**
   * 保存FSM2的出口数量
   */
  async saveFSM2OutletCount(count: number): Promise<void> {
    if (!this.preferencesStore) {
      console.warn('[OutletCountStorage] Preferences not initialized, cannot save FSM2 outlet count')
      return
    }

    try {
      await this.preferencesStore.put(OUTLET_COUNT_FSM2_KEY, count)
      await this.preferencesStore.flush()
      console.log(`[OutletCountStorage] Saved FSM2 outlet count: ${count}`)
    } catch (e) {
      console.error('[OutletCountStorage] Failed to save FSM2 outlet count:', JSON.stringify(e))
    }
  }

  /**
   * 加载FSM2的出口数量
   */
  async loadFSM2OutletCount(): Promise<number> {
    if (!this.preferencesStore) {
      console.warn('[OutletCountStorage] Preferences not initialized, returning default FSM2 outlet count')
      return DEFAULT_OUTLET_COUNT
    }

    try {
      const count = await this.preferencesStore.get(OUTLET_COUNT_FSM2_KEY, DEFAULT_OUTLET_COUNT)
      console.log(`[OutletCountStorage] Loaded FSM2 outlet count: ${count}`)
      return count as number
    } catch (e) {
      console.error('[OutletCountStorage] Failed to load FSM2 outlet count:', JSON.stringify(e))
      return DEFAULT_OUTLET_COUNT
    }
  }

  /**
   * 同时加载FSM1和FSM2的出口数量
   */
  async loadAllOutletCounts(): Promise<OutletCounts> {
    const fsm1 = await this.loadFSM1OutletCount()
    const fsm2 = await this.loadFSM2OutletCount()
    const result: OutletCounts = {
      fsm1: fsm1,
      fsm2: fsm2
    }
    return result
  }
}

