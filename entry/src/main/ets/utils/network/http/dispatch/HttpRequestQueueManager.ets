import { HttpRequestDispatchQueue, HttpRequestTask, HttpRequestTaskResult } from './HttpRequestDispatchQueue';
import { HttpRequestHandler } from '../HttpServer';
import { socket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;

/**
 * HTTP 请求队列管理器
 * 提供统一的队列访问接口
 */
export class HttpRequestQueueManager {
  // 并发队列：用于处理 HTTP 请求
  private static requestQueue: HttpRequestDispatchQueue | null = null;
  // 最大队列长度（用于背压控制）
  private static readonly MAX_QUEUE_SIZE = 256;

  /**
   * 初始化队列
   */
  static initialize(): void {
    if (!HttpRequestQueueManager.requestQueue) {
      HttpRequestQueueManager.requestQueue = HttpRequestDispatchQueue.queue_create_concurrent(
        'com.harmony.http.request'
      );
      hilog.info(DOMAIN, 'HttpRequestQueueManager', 'HTTP 请求队列已初始化');
    }
  }

  /**
   * 获取请求队列
   */
  static getRequestQueue(): HttpRequestDispatchQueue {
    if (!HttpRequestQueueManager.requestQueue) {
      HttpRequestQueueManager.initialize();
    }
    return HttpRequestQueueManager.requestQueue!;
  }

  /**
   * 检查队列是否可用（用于背压控制）
   * 注意：Dispatch 库可能没有直接获取队列长度的方法
   * 这里返回 true，实际背压控制需要在应用层实现
   */
  static isQueueAvailable(): boolean {
    // 由于 Dispatch 库可能不提供队列长度查询，这里总是返回 true
    // 实际应用中可以通过监控活跃任务数来判断
    return true;
  }

  /**
   * 执行 HTTP 请求处理
   * @param rawRequest 原始 HTTP 请求字符串
   * @param clientSocket 客户端 Socket 连接
   * @param handler HTTP 请求处理器
   * @returns Promise，解析时表示请求已处理完成
   */
  static async executeRequest(
    rawRequest: string,
    clientSocket: socket.TCPSocketConnection,
    handler: HttpRequestHandler
  ): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      const queue = HttpRequestQueueManager.getRequestQueue() as HttpRequestDispatchQueue;
      const task = new HttpRequestTask(rawRequest);
      
      // 在添加任务前，设置 handler 和 socket 的映射
      queue.setTaskContext(task.uniqueId, handler, clientSocket);
      
      // 使用 Dispatch 队列管理任务
      queue.async(task, (result: object) => {
        try {
          const taskResult = result as HttpRequestTaskResult;
          if (taskResult.success && taskResult.response) {
            // 发送成功响应
            clientSocket.send({ data: taskResult.response });
            resolve();
          } else {
            // 发送错误响应
            const errorMsg = taskResult.error || '未知错误';
            hilog.error(DOMAIN, 'HttpRequestQueueManager', `请求处理失败: ${errorMsg}`);
            const errorResponse = 'HTTP/1.1 500 Internal Server Error\r\n\r\n';
            clientSocket.send({ data: errorResponse });
            reject(new Error(errorMsg));
          }
        } catch (err) {
          const error = err as Error | object;
          hilog.error(DOMAIN, 'HttpRequestQueueManager', `处理结果失败: ${JSON.stringify(error)}`);
          const errorResponse = 'HTTP/1.1 500 Internal Server Error\r\n\r\n';
          clientSocket.send({ data: errorResponse });
          reject(error instanceof Error ? error : new Error(String(error)));
        }
      });
    });
  }

  /**
   * 发送服务不可用响应（队列满时）
   */
  static sendServiceUnavailable(clientSocket: socket.TCPSocketConnection): void {
    const tooBusy = 'HTTP/1.1 503 Service Unavailable\r\nRetry-After: 1\r\n\r\n';
    clientSocket.send({ data: tooBusy });
  }
}

