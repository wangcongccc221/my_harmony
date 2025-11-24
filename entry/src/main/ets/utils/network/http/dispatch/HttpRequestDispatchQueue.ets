import { DispatchQueue, DispatchTask, QueueType } from '@magicnumber/dispatch';
import { HttpRequestHandler, HttpResponseData } from '../HttpServer';
import { socket } from '@kit.NetworkKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;

// ESObject 类型别名（Dispatch 库使用但未导出）
type ESObject = object;

/**
 * HTTP 请求任务数据接口
 */
export interface HttpRequestTaskParams {
  rawRequest: string;
}

/**
 * HTTP 请求任务结果
 */
export interface HttpRequestTaskResult {
  success: boolean;
  response?: HttpResponseData;
  error?: string;
}

/**
 * HTTP 请求任务类（继承 DispatchTask）
 * 注意：handler 不能序列化，所以不包含在任务数据中
 */
export class HttpRequestTask extends DispatchTask {
  rawRequest: string;

  constructor(rawRequest: string) {
    super({ rawRequest: rawRequest });
    this.rawRequest = rawRequest;
  }
}

/**
 * HTTP 请求处理 Dispatch 队列
 * 注意：handler 在 runTask 中执行（在原始 worker 中），不在 TaskPool 中执行
 * 这样可以避免函数序列化问题，同时利用 Dispatch 的队列管理能力
 */
export class HttpRequestDispatchQueue extends DispatchQueue {
  // 存储 handler 的映射（key: task uniqueId, value: handler）
  private handlerMap: Map<string, HttpRequestHandler> = new Map();
  // 存储 clientSocket 的映射（key: task uniqueId, value: socket）
  private socketMap: Map<string, socket.TCPSocketConnection> = new Map();

  /**
   * 创建并发队列（用于处理 HTTP 请求）
   */
  static queue_create_concurrent(label: string): HttpRequestDispatchQueue {
    return new HttpRequestDispatchQueue(label, QueueType.CONCURRENT);
  }

  /**
   * 执行任务
   * 注意：handler 在这里执行（在原始 worker 中），不在 TaskPool 中
   * 这样可以访问到 handler 和 clientSocket
   */
  override runTask(taskData: DispatchTask): void {
    const httpTask = taskData as HttpRequestTask;
    const taskId = httpTask.uniqueId;
    const handler = this.handlerMap.get(taskId);
    const clientSocket = this.socketMap.get(taskId);

    if (!handler || !clientSocket) {
      const errorResult: HttpRequestTaskResult = {
        success: false,
        error: 'Handler 或 Socket 未找到'
      };
      this.finishTask(taskData, errorResult as ESObject);
      return;
    }

    // 在原始 worker 中执行 handler（异步，不阻塞队列）
    const processRequest = async () => {
      try {
        const handlerResult = handler(httpTask.rawRequest);
        const response = handlerResult instanceof Promise ? await handlerResult : handlerResult;
        const result: HttpRequestTaskResult = {
          success: true,
          response: response
        };
        this.finishTask(taskData, result as ESObject);
      } catch (error) {
        const errorMsg = error instanceof Error ? error.message : String(error);
        hilog.error(DOMAIN, 'HttpRequestDispatchQueue', `处理HTTP请求失败: ${errorMsg}`);
        const errorResult: HttpRequestTaskResult = {
          success: false,
          error: errorMsg
        };
        this.finishTask(taskData, errorResult as ESObject);
      } finally {
        // 清理映射
        this.handlerMap.delete(taskId);
        this.socketMap.delete(taskId);
      }
    };

    // 异步执行，不阻塞队列调度
    processRequest();
  }

  /**
   * 设置任务的 handler 和 socket（在添加任务前调用）
   */
  setTaskContext(taskId: string, handler: HttpRequestHandler, clientSocket: socket.TCPSocketConnection): void {
    this.handlerMap.set(taskId, handler);
    this.socketMap.set(taskId, clientSocket);
  }
}

