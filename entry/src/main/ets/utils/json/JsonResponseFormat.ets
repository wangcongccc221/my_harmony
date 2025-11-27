/**
 * JSON 通用响应格式定义
 * 
 * 所有 API 响应都应该遵循这个格式，确保前后端交互的一致性
 * 
 * 使用方式：
 * ```typescript
 * import { JsonResponse, buildSuccessResponse, buildErrorResponse } from './utils/json/JsonResponseFormat';
 * 
 * // 成功响应
 * const response = buildSuccessResponse({ id: 1, name: 'test' }, '操作成功');
 * 
 * // 错误响应
 * const error = buildErrorResponse(400, '参数错误');
 * ```
 */

// ESObject 类型别名
type ESObject = object;

/**
 * 通用 JSON 响应接口
 * 所有 API 响应都应该遵循此格式
 */
export interface JsonResponse<T = ESObject> {
  /** 操作是否成功 */
  ok: boolean;
  /** 响应码（可选，通常与 HTTP 状态码一致） */
  code?: number;
  /** 响应消息（可选） */
  message?: string;
  /** 响应数据（可选） */
  data?: T;
  /** 时间戳（可选） */
  timestamp?: number;
}

/**
 * JSON 响应格式工具类
 */
export class JsonResponseFormat {
  /**
   * 构建成功响应
   * @param data 响应数据
   * @param message 成功消息（可选）
   * @param code 响应码（默认 200）
   * @returns JSON 响应对象
   */
  static buildSuccess<T = ESObject>(
    data?: T,
    message?: string,
    code: number = 200
  ): JsonResponse<T> {
    const response: JsonResponse<T> = {
      ok: true,
      code: code
    };
    
    if (message) {
      response.message = message;
    }
    
    if (data !== undefined) {
      response.data = data;
    }
    
    response.timestamp = Date.now();
    
    return response;
  }

  /**
   * 构建错误响应
   * @param message 错误消息
   * @param code 错误码（默认 400）
   * @returns JSON 响应对象
   */
  static buildError(
    message: string,
    code: number = 400
  ): JsonResponse {
    return {
      ok: false,
      code: code,
      message: message,
      timestamp: Date.now()
    };
  }

  /**
   * 序列化为 JSON 字符串
   * @param response 响应对象
   * @returns JSON 字符串
   */
  static serialize<T = ESObject>(response: JsonResponse<T>): string {
    return JSON.stringify(response);
  }

  /**
   * 从 JSON 字符串反序列化
   * @param json JSON 字符串
   * @returns 响应对象
   */
  static deserialize<T = ESObject>(json: string): JsonResponse<T> {
    return JSON.parse(json) as JsonResponse<T>;
  }
}

/**
 * 便捷函数：构建成功响应
 */
export function buildSuccessResponse<T = ESObject>(
  data?: T,
  message?: string,
  code: number = 200
): JsonResponse<T> {
  return JsonResponseFormat.buildSuccess(data, message, code);
}

/**
 * 便捷函数：构建错误响应
 */
export function buildErrorResponse(
  message: string,
  code: number = 400
): JsonResponse {
  return JsonResponseFormat.buildError(message, code);
}

