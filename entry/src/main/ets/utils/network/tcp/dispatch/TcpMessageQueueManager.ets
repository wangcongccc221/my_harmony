import { TcpMessageDispatchQueue, TcpMessageTask, TcpMessageTaskResult, TcpMessageHandler } from './TcpMessageDispatchQueue';
import { socket } from '@kit.NetworkKit';
import { util, fastbuffer } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;

// ESObject 类型别名
type ESObject = object;

/**
 * TCP 消息队列管理器
 * 提供统一的 TCP 消息处理接口
 */
export class TcpMessageQueueManager {
  // 并发队列：用于处理 TCP 消息
  private static messageQueue: TcpMessageDispatchQueue | null = null;

  /**
   * 初始化队列
   */
  static initialize(): void {
    if (!TcpMessageQueueManager.messageQueue) {
      TcpMessageQueueManager.messageQueue = TcpMessageDispatchQueue.queue_create_concurrent(
        'com.harmony.tcp.message'
      );
      hilog.info(DOMAIN, 'TcpMessageQueueManager', 'TCP 消息队列已初始化');
    }
  }

  /**
   * 获取消息队列
   */
  static getMessageQueue(): TcpMessageDispatchQueue {
    if (!TcpMessageQueueManager.messageQueue) {
      TcpMessageQueueManager.initialize();
    }
    return TcpMessageQueueManager.messageQueue!;
  }

  /**
   * 执行 TCP 消息处理
   * @param message 消息数据（FastBuffer）
   * @param handler 消息处理函数
   * @param clientSocket 可选的客户端 Socket（用于错误处理）
   * @returns Promise，解析时表示消息已处理完成
   */
  static async executeMessage(
    message: fastbuffer.FastBuffer,
    handler: TcpMessageHandler,
    clientSocket?: socket.TCPSocketConnection | socket.TCPSocket
  ): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      const queue = TcpMessageQueueManager.getMessageQueue();
      const task = new TcpMessageTask(message);
      
      // 在添加任务前，设置 handler 和 socket 的映射
      queue.setTaskContext(task.uniqueId, handler, clientSocket);
      
      // 使用 Dispatch 队列管理任务
      queue.async(task, (result: ESObject) => {
        try {
          const taskResult = result as TcpMessageTaskResult;
          if (taskResult.success) {
            resolve();
          } else {
            const errorMsg = taskResult.error || '消息处理失败';
            hilog.error(DOMAIN, 'TcpMessageQueueManager', `消息处理失败: ${errorMsg}`);
            reject(new Error(errorMsg));
          }
        } catch (err) {
          const error = err as Error | object;
          hilog.error(DOMAIN, 'TcpMessageQueueManager', `处理结果失败: ${JSON.stringify(error)}`);
          reject(error instanceof Error ? error : new Error(String(error)));
        }
      });
    });
  }

  /**
   * 发送服务繁忙响应（队列满时）
   */
  static async sendServiceBusy(clientSocket: socket.TCPSocketConnection | socket.TCPSocket): Promise<void> {
    try {
      const encoder = new util.TextEncoder();
      const encodedData = encoder.encodeInto('SERVER_BUSY');
      // 创建 FastBuffer 并复制数据
      const buffer = fastbuffer.alloc(encodedData.length);
      for (let i = 0; i < encodedData.length; i++) {
        buffer[i] = encodedData[i];
      }
      await clientSocket.send({ data: buffer.buffer });
    } catch (error) {
      hilog.error(DOMAIN, 'TcpMessageQueueManager', `发送服务繁忙消息失败: ${JSON.stringify(error)}`);
    }
  }
}

