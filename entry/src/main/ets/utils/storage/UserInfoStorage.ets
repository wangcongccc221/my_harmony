/**
 * 用户信息持久化存储工具
 * 功能：持久化存储用户姓名和头像URL，应用重启后仍然有效
 */

import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

const USER_NAME_KEY = 'user_name'
const USER_AVATAR_URL_KEY = 'user_avatar_url'
const DEFAULT_USER_NAME = '姓名'
const DEFAULT_AVATAR_URL = 'https://img1.baidu.com/it/u=700838104,4078529388&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500'

export class UserInfoStorage {
  private static instance: UserInfoStorage | null = null
  private preferencesStore: preferences.Preferences | null = null
  private context: common.UIAbilityContext | null = null

  private constructor() {}

  static getInstance(): UserInfoStorage {
    if (!UserInfoStorage.instance) {
      UserInfoStorage.instance = new UserInfoStorage()
    }
    return UserInfoStorage.instance
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
      const dataPreferences = await preferences.getPreferences(context, 'user_info')
      this.preferencesStore = dataPreferences
      console.log('[UserInfoStorage] Preferences initialized')
    } catch (e) {
      console.error('[UserInfoStorage] Failed to initialize Preferences:', JSON.stringify(e))
    }
  }

  /**
   * 保存用户名
   */
  async saveUserName(userName: string): Promise<void> {
    if (!this.preferencesStore) {
      console.warn('[UserInfoStorage] Preferences not initialized, cannot save userName')
      return
    }

    try {
      await this.preferencesStore.put(USER_NAME_KEY, userName)
      await this.preferencesStore.flush()
      console.log(`[UserInfoStorage] Saved userName: ${userName}`)
    } catch (e) {
      console.error('[UserInfoStorage] Failed to save userName:', JSON.stringify(e))
    }
  }

  /**
   * 加载用户名
   */
  async loadUserName(): Promise<string> {
    if (!this.preferencesStore) {
      console.warn('[UserInfoStorage] Preferences not initialized, returning default userName')
      return DEFAULT_USER_NAME
    }

    try {
      const userName = await this.preferencesStore.get(USER_NAME_KEY, DEFAULT_USER_NAME)
      console.log(`[UserInfoStorage] Loaded userName: ${userName}`)
      return userName as string
    } catch (e) {
      console.error('[UserInfoStorage] Failed to load userName:', JSON.stringify(e))
      return DEFAULT_USER_NAME
    }
  }

  /**
   * 保存头像URL
   */
  async saveAvatarUrl(avatarUrl: string): Promise<void> {
    if (!this.preferencesStore) {
      console.warn('[UserInfoStorage] Preferences not initialized, cannot save avatarUrl')
      return
    }

    try {
      await this.preferencesStore.put(USER_AVATAR_URL_KEY, avatarUrl)
      await this.preferencesStore.flush()
      console.log(`[UserInfoStorage] Saved avatarUrl: ${avatarUrl}`)
    } catch (e) {
      console.error('[UserInfoStorage] Failed to save avatarUrl:', JSON.stringify(e))
    }
  }

  /**
   * 加载头像URL
   */
  async loadAvatarUrl(): Promise<string> {
    if (!this.preferencesStore) {
      console.warn('[UserInfoStorage] Preferences not initialized, returning default avatarUrl')
      return DEFAULT_AVATAR_URL
    }

    try {
      const avatarUrl = await this.preferencesStore.get(USER_AVATAR_URL_KEY, DEFAULT_AVATAR_URL)
      console.log(`[UserInfoStorage] Loaded avatarUrl: ${avatarUrl}`)
      return avatarUrl as string
    } catch (e) {
      console.error('[UserInfoStorage] Failed to load avatarUrl:', JSON.stringify(e))
      return DEFAULT_AVATAR_URL
    }
  }
}

