import { DispatchQueue, DispatchTask, QueueType } from '@magicnumber/dispatch';
import { socket } from '@kit.NetworkKit';
import { util, fastbuffer } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;

// ESObject 类型别名（Dispatch 库使用但未导出）
type ESObject = object;

/**
 * TCP 消息任务参数接口
 */
export interface TcpMessageTaskParams {
  message: fastbuffer.FastBuffer;
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
 */
export type TcpMessageHandler = (message: string) => void | Promise<void>;

/**
 * TCP 消息任务类（继承 DispatchTask）
 */
export class TcpMessageTask extends DispatchTask {
  message: fastbuffer.FastBuffer;

  constructor(message: fastbuffer.FastBuffer) {
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
        // 直接使用 FastBuffer 进行解码
        hilog.info(DOMAIN, 'TcpMessageDispatchQueue', `[FastBuffer] 处理消息，使用 FastBuffer，大小: ${tcpTask.message.length} 字节`);
        const decoder = new util.TextDecoder();
        // FastBuffer 支持索引访问，可以直接用于解码（通过 buffer 属性获取 ArrayBuffer，然后创建视图）
        // 注意：TextDecoder.decode() 需要 Uint8Array，所以需要从 FastBuffer.buffer 创建视图
        const decodedMessage = decoder.decode(new Uint8Array(tcpTask.message.buffer));
        hilog.info(DOMAIN, 'TcpMessageDispatchQueue', `[解码] 解码完成，消息内容: ${decodedMessage}`);
        
        // 执行 handler
        hilog.info(DOMAIN, 'TcpMessageDispatchQueue', `[处理] 开始执行 handler`);
        const handlerResult = handler(decodedMessage);
        if (handlerResult instanceof Promise) {
          await handlerResult;
        }
        hilog.info(DOMAIN, 'TcpMessageDispatchQueue', `[处理] handler 执行完成`);

        const result: TcpMessageTaskResult = {
          success: true,
          decodedMessage: decodedMessage
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

