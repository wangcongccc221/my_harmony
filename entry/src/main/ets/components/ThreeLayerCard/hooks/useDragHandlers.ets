/**
 * 拖拽处理 hooks（初版）
 * - 解析 Drop 负载
 * - 标记是否已处理（handled/unhandled）
 * - 来源判定工具
 */

import { SystemWrapper, DragOuterPayload } from '../types'
import { StorageKeys } from '../../../utils/constants/StorageKeys'

export interface ParsedDropResult {
  valueStr: string
  originalValue: string
  sourceTable: string
  sourceCardId: string
}

export class UseDragHandlers {
  static parseDrop(extraParams: string): ParsedDropResult | null {
    if (!extraParams || extraParams.length === 0) { return null }
    try {
      let payload = extraParams
      if (extraParams.includes('"extraInfo"')) {
        const wrapper: SystemWrapper = JSON.parse(extraParams) as SystemWrapper
        payload = String(wrapper.extraInfo ?? extraParams)
      }
      const parsed: Record<string, string | number> = JSON.parse(payload)
      const valueStr: string = String(parsed['value'] ?? '')
      const originalValue: string = String(parsed['sourceValue'] ?? parsed['originalValue'] ?? valueStr)
      const sourceTable: string = String(parsed['sourceTable'] ?? '等级表')
      const sourceCardId: string = String(parsed['sourceCardId'] ?? '')
      // 仅保留关键链路：onDrop 解析摘要
      console.log('🧩 Drop解析: value=', valueStr, 'original=', originalValue, 'from=', sourceTable, 'sourceCardId=', sourceCardId)
      return { valueStr, originalValue, sourceTable, sourceCardId }
    } catch (_e) {
      return null
    }
  }

  static markDropHandled(): void {
    AppStorage.set(StorageKeys.GLOBAL_DROP_HANDLED, true)
  }

  static markDropUnhandled(): void {
    AppStorage.set(StorageKeys.GLOBAL_DROP_HANDLED, false)
  }

  static isFromCard(sourceTable: string, sourceCardId: string, targetCardId: string): boolean {
    return (
      !!sourceCardId && String(sourceCardId) !== String(targetCardId)
    ) || (sourceTable === 'card_third_layer' && String(sourceCardId) !== String(targetCardId))
  }

  /**
   * 根据 cardId 与原始值(valStr)移除映射，并上报等级出口移除事件
   */
  static emitRemoveLevelExit(cardId: string, valStr: string, exitNum: number): void {
    try {
      const mapRaw = AppStorage.get('CARD_ITEM_LEVEL_MAP') as Record<string, Record<string, string>> | null
      const mapObj: Record<string, Record<string, string>> = mapRaw ? mapRaw : {}
      const levelName = (mapObj[cardId] && mapObj[cardId][valStr]) ? mapObj[cardId][valStr] : ''
      if (levelName) {
        // 检查该卡片是否还有其他相同等级的元素
        const cardMappings = mapObj[cardId] || {}
        const sameLevelItems = Object.keys(cardMappings).filter(key => 
          key !== valStr && cardMappings[key] === levelName
        )
        
        console.log(`🔍 检查卡片${cardId}中等级${levelName}的其他元素:`, sameLevelItems)
        
        // 如果该卡片没有其他相同等级的元素，删除出口映射
        if (sameLevelItems.length === 0) {
          console.log(`❌ 卡片${cardId}中没有其他${levelName}元素，删除出口映射`)
          AppStorage.setOrCreate('LEVEL_STAT_REMOVE', { levelName: levelName, exit: exitNum })
        } else {
          console.log(`✅ 卡片${cardId}中还有${sameLevelItems.length}个${levelName}元素，不删除出口映射`)
        }
        
        // 删除当前元素的映射
        mapObj[cardId][valStr] = ''
        const cleaned: Record<string, Record<string, string>> = {}
        Object.keys(mapObj).forEach(cid => {
          const inner = mapObj[cid]
          const nextInner: Record<string, string> = {}
          Object.keys(inner).forEach(k => {
            const v = inner[k]
            if (v && v.length > 0) { nextInner[k] = v }
          })
          cleaned[cid] = nextInner
        })
        AppStorage.setOrCreate('CARD_ITEM_LEVEL_MAP', cleaned)
        console.log(`🗑️ 删除元素映射: 等级=${levelName}, 出口=${exitNum}, key=${valStr}`)
      }
    } catch (_e) {}
  }

  // 限制每个卡片的最大映射数量，防止内存泄漏
  private static readonly MAX_MAPPINGS_PER_CARD: number = 1000
  // 限制总卡片数量，防止内存泄漏
  private static readonly MAX_CARDS: number = 50

  /**
   * 限制映射对象大小，防止内存泄漏
   */
  private static limitMapSize(mapObj: Record<string, Record<string, string>>): Record<string, Record<string, string>> {
    const cardIds = Object.keys(mapObj)
    
    // 如果卡片数量超过限制，只保留最新的卡片
    if (cardIds.length > UseDragHandlers.MAX_CARDS) {
      const limited: Record<string, Record<string, string>> = {}
      // 保留最后 MAX_CARDS 个卡片
      const keepCards = cardIds.slice(-UseDragHandlers.MAX_CARDS)
      keepCards.forEach(cardId => {
        limited[cardId] = mapObj[cardId]
      })
      console.warn(`⚠️ CARD_ITEM_LEVEL_MAP 卡片数量超过限制，已清理旧数据: ${cardIds.length} -> ${keepCards.length}`)
      return limited
    }
    
    // 限制每个卡片的映射数量
    const limited: Record<string, Record<string, string>> = {}
    cardIds.forEach(cardId => {
      const cardMap = mapObj[cardId]
      const keys = Object.keys(cardMap)
      if (keys.length > UseDragHandlers.MAX_MAPPINGS_PER_CARD) {
        // 只保留最新的映射
        const keepKeys = keys.slice(-UseDragHandlers.MAX_MAPPINGS_PER_CARD)
        limited[cardId] = {}
        keepKeys.forEach(key => {
          limited[cardId][key] = cardMap[key]
        })
        console.warn(`⚠️ 卡片 ${cardId} 映射数量超过限制，已清理旧数据: ${keys.length} -> ${keepKeys.length}`)
      } else {
        limited[cardId] = cardMap
      }
    })
    
    return limited
  }

  /**
   * 为当前卡片建立 值->等级 的映射，并上报"新增出口"事件
   */
  static mapValueToLevel(cardId: string, originalValue: string, levelName: string, exitNum: number): void {
    try {
      console.log(`🔄 mapValueToLevel 被调用: cardId=${cardId}, originalValue=${originalValue}, levelName=${levelName}, exitNum=${exitNum}`)
      const mapRaw = AppStorage.get('CARD_ITEM_LEVEL_MAP') as Record<string, Record<string, string>> | null
      let mapObj: Record<string, Record<string, string>> = mapRaw ? mapRaw : {}
      
      // 限制映射大小，防止内存泄漏
      mapObj = UseDragHandlers.limitMapSize(mapObj)
      
      if (!mapObj[cardId]) { mapObj[cardId] = {} }
      if (originalValue) {
        mapObj[cardId][originalValue] = levelName
        // 再次限制大小（添加后可能超过限制）
        mapObj = UseDragHandlers.limitMapSize(mapObj)
        AppStorage.setOrCreate('CARD_ITEM_LEVEL_MAP', mapObj)
      }
      if (levelName && exitNum > 0) {
        console.log(`🚀 触发 LEVEL_STAT_UPDATE 事件: { levelName: "${levelName}", exit: ${exitNum} }`)
        AppStorage.setOrCreate('LEVEL_STAT_UPDATE', { levelName: levelName, exit: exitNum })
      }
      console.log(`➕ 映射新增: 等级=${levelName}, 出口=${exitNum}, key=${originalValue}`)
    } catch (_e) {
      console.error(`❌ mapValueToLevel 发生错误:`, _e)
    }
  }

  /**
   * 追加映射到目标卡片：只添加新映射，不删除原映射，用于单个元素拖拽
   */
  static appendMappingToCard(fromCardId: string, valStr: string, toCardId: string, toExit: number): void {
    try {
      const mapRaw = AppStorage.get('CARD_ITEM_LEVEL_MAP') as Record<string, Record<string, string>> | null
      let mapObj: Record<string, Record<string, string>> = mapRaw ? mapRaw : {}
      
      // 限制映射大小，防止内存泄漏
      mapObj = UseDragHandlers.limitMapSize(mapObj)
      
      const levelName = (mapObj[fromCardId] && mapObj[fromCardId][valStr]) ? mapObj[fromCardId][valStr] : ''
      if (!levelName) { return }
      
      // 只添加新映射，不删除原映射
      if (toExit > 0) {
        console.log(`🚀 触发 LEVEL_STAT_UPDATE 事件（追加）: { levelName: "${levelName}", exit: ${toExit} }`)
        AppStorage.setOrCreate('LEVEL_STAT_UPDATE', { levelName: levelName, exit: toExit })
      }
      
      // 更新映射关系
      if (!mapObj[toCardId]) { mapObj[toCardId] = {} }
      mapObj[toCardId][valStr] = levelName
      // 再次限制大小（添加后可能超过限制）
      mapObj = UseDragHandlers.limitMapSize(mapObj)
      AppStorage.setOrCreate('CARD_ITEM_LEVEL_MAP', mapObj)
      
      console.log(`➕ 映射追加: 等级=${levelName}, 出口=${toExit}, key=${valStr}`)
    } catch (_e) {
      console.error(`❌ appendMappingToCard 发生错误:`, _e)
    }
  }

  /**
   * 在卡片间移动映射：从 fromCardId 移除，再添加至 toCardId，并上报"出口替换"
   */
  static moveMappingBetweenCards(fromCardId: string, valStr: string, toCardId: string, toExit: number): void {
    try {
      const mapRaw = AppStorage.get('CARD_ITEM_LEVEL_MAP') as Record<string, Record<string, string>> | null
      const mapObj: Record<string, Record<string, string>> = mapRaw ? mapRaw : {}
      const levelName = (mapObj[fromCardId] && mapObj[fromCardId][valStr]) ? mapObj[fromCardId][valStr] : ''
      if (!levelName) { return }
      const fromExit = ((): number => {
        const m = fromCardId.match(/card_(\d+)/)
        return m && m[1] ? (parseInt(m[1]) + 1) : 0
      })()
      if (fromExit > 0) {
        AppStorage.setOrCreate('LEVEL_STAT_REMOVE', { levelName: levelName, exit: fromExit })
      }
      if (toExit > 0) {
        AppStorage.setOrCreate('LEVEL_STAT_UPDATE', { levelName: levelName, exit: toExit })
      }
      if (!mapObj[toCardId]) { mapObj[toCardId] = {} }
      mapObj[toCardId][valStr] = levelName
      if (mapObj[fromCardId]) {
        mapObj[fromCardId][valStr] = ''
      }
      // 清理空值
      const cleaned: Record<string, Record<string, string>> = {}
      Object.keys(mapObj).forEach(cid => {
        const inner = mapObj[cid]
        const nextInner: Record<string, string> = {}
        Object.keys(inner).forEach(k => {
          const v = inner[k]
          if (v && v.length > 0) { nextInner[k] = v }
        })
        cleaned[cid] = nextInner
      })
      AppStorage.setOrCreate('CARD_ITEM_LEVEL_MAP', cleaned)
      console.log(`🔁 映射迁移: 等级=${levelName}, ${fromExit} -> ${toExit}, key=${valStr}`)
    } catch (_e) {}
  }
}


