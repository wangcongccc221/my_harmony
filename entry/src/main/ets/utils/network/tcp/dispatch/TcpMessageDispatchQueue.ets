import { DispatchQueue, DispatchTask, QueueType } from '@magicnumber/dispatch';
import { socket } from '@kit.NetworkKit';
import { util } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;

// ESObject 类型别名（Dispatch 库使用但未导出）
type ESObject = object;

/**
 * TCP 消息任务参数接口
 */
export interface TcpMessageTaskParams {
  message: Uint8Array;
}

/**
 * TCP 消息任务结果
 */
export interface TcpMessageTaskResult {
  success: boolean;
  decodedMessage?: string;
  error?: string;
}

/**
 * TCP 消息处理回调函数类型
 * 支持文本消息（string）和二进制消息（Uint8Array）
 */
export type TcpMessageHandler = (message: string | Uint8Array) => void | Promise<void>;

/**
 * TCP 消息任务类（继承 DispatchTask）
 */
export class TcpMessageTask extends DispatchTask {
  message: Uint8Array;

  constructor(message: Uint8Array) {
    super({ message: message });
    this.message = message;
  }
}

/**
 * TCP 消息处理 Dispatch 队列
 * 注意：handler 在 runTask 中执行（在原始 worker 中），不在 TaskPool 中执行
 * 这样可以避免函数序列化问题，同时利用 Dispatch 的队列管理能力
 */
export class TcpMessageDispatchQueue extends DispatchQueue {
  // 存储 handler 的映射（key: task uniqueId, value: handler）
  private handlerMap: Map<string, TcpMessageHandler> = new Map();
  // 存储 clientSocket 的映射（key: task uniqueId, value: socket）
  private socketMap: Map<string, socket.TCPSocketConnection | socket.TCPSocket> = new Map();

  /**
   * 创建并发队列（用于处理 TCP 消息）
   */
  static queue_create_concurrent(label: string): TcpMessageDispatchQueue {
    return new TcpMessageDispatchQueue(label, QueueType.CONCURRENT);
  }

  /**
   * 执行任务
   * 注意：handler 在这里执行（在原始 worker 中），不在 TaskPool 中
   * 这样可以访问到 handler 和 clientSocket
   */
  override runTask(taskData: DispatchTask): void {
    const tcpTask = taskData as TcpMessageTask;
    const taskId = tcpTask.uniqueId;
    const handler = this.handlerMap.get(taskId);
    const clientSocket = this.socketMap.get(taskId);

    if (!handler) {
      const errorResult: TcpMessageTaskResult = {
        success: false,
        error: 'Handler 未找到'
      };
      this.finishTask(taskData, errorResult as ESObject);
      return;
    }

    // 在原始 worker 中执行消息处理（异步，不阻塞队列）
    const processMessage = async () => {
      try {
        // 尝试解析为二进制数据（StStatistics结构体）
        // 首先检查是否为SYNC开头
        const syncBytes = new Uint8Array([0x53, 0x59, 0x4E, 0x43]); // "SYNC"
        const isBinaryData = tcpTask.message.length >= 4 && 
          tcpTask.message[0] === syncBytes[0] &&
          tcpTask.message[1] === syncBytes[1] &&
          tcpTask.message[2] === syncBytes[2] &&
          tcpTask.message[3] === syncBytes[3];
        
        if (isBinaryData) {
          // 二进制数据，直接传递原始字节数组给handler
          // handler需要接收Uint8Array类型
          const handlerResult = handler(tcpTask.message as Uint8Array);
          if (handlerResult instanceof Promise) {
            await handlerResult;
          }
        } else {
          // 文本数据，解码为字符串
          const decoder = new util.TextDecoder();
          const decodedMessage = decoder.decode(tcpTask.message);
          
          // 执行 handler
          const handlerResult = handler(decodedMessage);
          if (handlerResult instanceof Promise) {
            await handlerResult;
          }
        }

        const result: TcpMessageTaskResult = {
          success: true,
          decodedMessage: isBinaryData ? '[Binary Data]' : new util.TextDecoder().decode(tcpTask.message)
        };
        this.finishTask(taskData, result as ESObject);
      } catch (error) {
        const errorMsg = error instanceof Error ? error.message : String(error);
        hilog.error(DOMAIN, 'TcpMessageDispatchQueue', `处理TCP消息失败: ${errorMsg}`);
        const errorResult: TcpMessageTaskResult = {
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
    processMessage();
  }

  /**
   * 设置任务的 handler 和 socket（在添加任务前调用）
   */
  setTaskContext(taskId: string, handler: TcpMessageHandler, clientSocket?: socket.TCPSocketConnection | socket.TCPSocket): void {
    this.handlerMap.set(taskId, handler);
    if (clientSocket) {
      this.socketMap.set(taskId, clientSocket);
    }
  }
}

