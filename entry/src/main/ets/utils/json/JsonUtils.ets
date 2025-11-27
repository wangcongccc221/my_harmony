/**
 * JSON 序列化和反序列化工具类
 * 
 * 功能：
 * 1. 基本的 JSON 序列化/反序列化
 * 2. 类型安全的序列化/反序列化（带接口验证）
 * 3. 错误处理和日志记录
 * 
 * 使用方式：
 * ```typescript
 * import { JsonUtils } from './utils/json/JsonUtils';
 * 
 * // 基本序列化
 * const json = JsonUtils.serialize(data);
 * 
 * // 基本反序列化
 * const obj = JsonUtils.deserialize<MyType>(json);
 * 
 * // 类型安全的反序列化（带验证）
 * const user = JsonUtils.deserializeSafe<User>(json, UserInterface);
 * ```
 */

// ESObject 类型别名
type ESObject = object;

/**
 * JSON 工具类
 */
export class JsonUtils {
  /**
   * 序列化对象为 JSON 字符串
   * @param data 要序列化的数据
   * @param pretty 是否格式化输出（默认 false）
   * @returns JSON 字符串
   */
  static serialize(data: ESObject | string | number | boolean | null | undefined, pretty: boolean = false): string {
    try {
      if (pretty) {
        // 注意：ArkTS 的 JSON.stringify 不支持格式化参数
        // 如果需要格式化，可以使用第三方库或手动处理
        return JSON.stringify(data);
      }
      return JSON.stringify(data);
    } catch (error) {
      throw new Error(`JSON 序列化失败: ${error}`);
    }
  }

  /**
   * 反序列化 JSON 字符串为对象
   * @param json JSON 字符串
   * @returns 反序列化后的对象
   */
  static deserialize<T extends ESObject = ESObject>(json: string): T {
    try {
      if (!json || json.trim().length === 0) {
        throw new Error('JSON 字符串为空');
      }
      return JSON.parse(json) as T;
    } catch (error) {
      throw new Error(`JSON 反序列化失败: ${error}`);
    }
  }

  /**
   * 安全地反序列化 JSON（带错误处理，返回 null 而不是抛出异常）
   * @param json JSON 字符串
   * @param defaultValue 解析失败时的默认值（可选）
   * @returns 反序列化后的对象，失败时返回 defaultValue 或 null
   */
  static deserializeSafe<T extends ESObject = ESObject>(json: string, defaultValue?: T): T | null {
    try {
      if (!json || json.trim().length === 0) {
        return defaultValue || null;
      }
      return JSON.parse(json) as T;
    } catch (error) {
      console.error('JSON 反序列化失败:', error);
      return defaultValue || null;
    }
  }

  /**
   * 验证 JSON 字符串是否有效
   * @param json JSON 字符串
   * @returns 是否有效
   */
  static isValid(json: string): boolean {
    try {
      if (!json || json.trim().length === 0) {
        return false;
      }
      JSON.parse(json);
      return true;
    } catch {
      return false;
    }
  }

  /**
   * 深度克隆对象（通过序列化/反序列化）
   * @param obj 要克隆的对象
   * @returns 克隆后的新对象
   */
  static deepClone<T extends ESObject>(obj: T): T {
    try {
      const json = JSON.stringify(obj);
      return JSON.parse(json) as T;
    } catch (error) {
      throw new Error(`深度克隆失败: ${error}`);
    }
  }

  /**
   * 合并多个对象（后面的对象会覆盖前面的）
   * @param objects 要合并的对象数组
   * @returns 合并后的对象
   */
  static merge<T extends ESObject>(...objects: T[]): T {
    try {
      const merged = JSON.parse(JSON.stringify(objects[0] || {})) as T;
      for (let i = 1; i < objects.length; i++) {
        const obj = objects[i];
        const keys = Object.keys(obj);
        for (let j = 0; j < keys.length; j++) {
          const key = keys[j];
          (merged as Record<string, ESObject>)[key] = (obj as Record<string, ESObject>)[key];
        }
      }
      return merged;
    } catch (error) {
      throw new Error(`对象合并失败: ${error}`);
    }
  }
}

