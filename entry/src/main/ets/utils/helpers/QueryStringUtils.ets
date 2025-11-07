/**
 * 查询字符串工具类
 * 功能：解析和构建URL查询字符串
 * 用途：统一处理HTTP请求参数解析
 */

/**
 * 路径和查询参数解析结果接口
 */
interface PathAndQueryResult {
  path: string;
  params: Record<string, string>;
}

/**
 * 查询字符串工具类
 * 提供统一的查询字符串处理方法
 */
export class QueryStringUtils {
  /**
   * 解析查询字符串为参数对象
   * @param queryString 查询字符串（不含?）
   * @returns 参数对象
   */
  static parseQueryString(queryString: string): Record<string, string> {
    const params: Record<string, string> = {};
    if (!queryString || queryString.length === 0) {
      return params;
    }

    const pairs = queryString.split('&');
    for (let i = 0; i < pairs.length; i++) {
      const kv = pairs[i].split('=');
      const k = decodeURIComponent(kv[0] || '');
      const v = decodeURIComponent(kv[1] || '');
      if (k) {
        params[k] = v;
      }
    }
    return params;
  }

  /**
   * 从完整URL路径中解析查询参数
   * @param path 完整路径（可能包含查询字符串）
   * @returns 包含path和params的对象
   */
  static parsePathAndQuery(path: string): PathAndQueryResult {
    const qIndex = path.indexOf('?');
    
    const cleanPath = qIndex >= 0 ? path.substring(0, qIndex) : path;
    const queryString = qIndex >= 0 ? path.substring(qIndex + 1) : '';
    const params = QueryStringUtils.parseQueryString(queryString);
    
    const result: PathAndQueryResult = { path: cleanPath, params: params };
    return result;
  }

  /**
   * 构建查询字符串
   * @param params 参数对象
   * @returns 查询字符串（不含?）
   */
  static buildQueryString(params: Record<string, string | number | boolean>): string {
    const pairs: string[] = [];
    const keys = Object.keys(params);
    for (let i = 0; i < keys.length; i++) {
      const key = keys[i];
      const value = params[key];
      const encodedKey = encodeURIComponent(key);
      const encodedValue = encodeURIComponent(String(value));
      pairs.push(`${encodedKey}=${encodedValue}`);
    }
    return pairs.join('&');
  }
}

