import { socket } from '@kit.NetworkKit';
import { util } from '@kit.ArkTS';
// AppStorage 是全局可用的，无需导入
import { TCP_CONNECTION_STATUS } from '../../../constants/TopBarKeys';
import { taskpool } from '@kit.ArkTS';
import { TcpMessageQueueManager } from './dispatch';
import { handleStatisticsData } from './handlers/StatisticsDataHandler';

@Concurrent
export async function runTcpServerWorker(ip: string, port: number): Promise<void> {
  try {
    const server = socket.constructTCPSocketServerInstance();

    server.on('connect', async (client: socket.TCPSocketConnection) => {
      try {
        const remote = await client.getRemoteAddress();
        console.log(`[TCPServerWorker] 客户端连接: ${remote.address}:${remote.port || 0}`);
        // 注意：在@Concurrent函数中无法使用AppStorage，需要通过其他方式通知
        // AppStorage.setOrCreate(TCP_CONNECTION_STATUS, true);

        client.on('message', (data: socket.SocketMessageInfo) => {
          // 使用 Dispatch 队列处理消息
          const messageData = new Uint8Array(data.message);
          
          console.log(`[TCPServerWorker] 收到数据，长度: ${messageData.length} 字节`);
          
          // 检查是否为二进制统计数据（以SYNC开头）
          const isBinaryData = messageData.length >= 4 && 
            messageData[0] === 0x53 && // 'S'
            messageData[1] === 0x59 && // 'Y'
            messageData[2] === 0x4E && // 'N'
            messageData[3] === 0x43;    // 'C'
          
          console.log(`[TCPServerWorker] 数据前4字节: ${messageData[0]}, ${messageData[1]}, ${messageData[2]}, ${messageData[3]}, 是否为SYNC: ${isBinaryData}`);
          
          if (isBinaryData) {
            // 二进制统计数据，直接处理
            console.log(`[TCPServerWorker] 识别为二进制统计数据，开始处理...`);
            handleStatisticsData(messageData).catch((err: Error | object) => {
              const errorMsg = err instanceof Error ? err.message : String(err);
              console.error(`[TCPServerWorker] 处理统计数据失败: ${errorMsg}`);
            });
          } else {
            // 文本消息，使用原有处理方式
            TcpMessageQueueManager.executeMessage(
              messageData,
              async (message: string | Uint8Array) => {
                const messageStr = typeof message === 'string' ? message : '[Binary Data]';
                console.log(`[TCPServerWorker] 收到文本消息: ${messageStr}`);
              },
              client
            ).catch((err: Error | object) => {
              // 错误已经在 executeMessage 中处理，这里只记录日志
              const errorMsg = err instanceof Error ? err.message : String(err);
              console.error(`[TCPServerWorker] 消息处理异常: ${errorMsg}`);
            });
          }
        });

        client.on('close', () => {
          console.log(`[TCPServerWorker] 客户端断开: ${remote.address}:${remote.port || 0}`);
          // 注意：在@Concurrent函数中无法使用AppStorage
          // AppStorage.setOrCreate(TCP_CONNECTION_STATUS, false);
        });

        client.on('error', (err: Error) => {
          console.error(`[TCPServerWorker] 客户端错误: ${err.message}`);
        });
      } catch (e) {
        const errorMsg = e instanceof Error ? e.message : String(e);
        console.error(`[TCPServerWorker] 处理连接失败: ${errorMsg}`);
      }
    });

    server.on('error', (error: Error) => {
      console.error(`[TCPServerWorker] 服务器错误: ${error.message}`);
    });

    await server.listen({ address: ip, port, family: 1 });
    console.log(`[TCPServerWorker] 服务器启动成功: ${ip}:${port}`);

    // 简单的关闭信号轮询
    // 注意：在@Concurrent函数中无法使用AppStorage，这里简化处理
    // const SHUTDOWN_KEY = 'TCP_SERVER_SHUTDOWN';
    // const checkInterval = setInterval(async () => {
    //   try {
    //     const flag = AppStorage.get(SHUTDOWN_KEY) as boolean | null;
    //     if (flag) {
    //       clearInterval(checkInterval);
    //       try { server.off('connect'); server.off('error'); } catch (_) {}
    //       console.log(`[TCPServerWorker] 收到关闭信号，服务器退出`);
    //     }
    //   } catch (_) {}
    // }, 1000) as number;
  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : String(error);
    console.error(`[TCPServerWorker] 启动失败: ${errorMsg}`);
  }
}

interface ClientInfo {
  id: string;
  address: string;
  port: number;
  name: string;
  connection: socket.TCPSocketConnection;
}

interface SendResult {
  success: number;
  fail: number;
}

// TCP服务器封装类 - 纯后台运行
export class TCPServer {
  private server: socket.TCPSocketServer | null = null;
  private clients: Map<string, ClientInfo> = new Map();
  private messageIdCounter: number = 0;
  private onMessageCallback?: (type: 'send' | 'receive', content: string, clientId?: string) => void;
  private onClientConnectCallback?: (client: ClientInfo) => void;
  private onClientDisconnectCallback?: (clientId: string) => void;
  private onServerStatusCallback?: (isRunning: boolean, message: string) => void;

  constructor() {
    console.log(`[TCPServer] TCP服务器实例已创建`);
    // 初始化连接状态为false
    AppStorage.setOrCreate(TCP_CONNECTION_STATUS, false);
  }

  // 设置消息回调
  setOnMessage(callback: (type: 'send' | 'receive', content: string, clientId?: string) => void) {
    this.onMessageCallback = callback;
  }

  // 设置客户端连接回调
  setOnClientConnect(callback: (client: ClientInfo) => void) {
    this.onClientConnectCallback = callback;
  }

  // 设置客户端断开回调
  setOnClientDisconnect(callback: (clientId: string) => void) {
    this.onClientDisconnectCallback = callback;
  }

  // 设置服务器状态回调
  setOnServerStatus(callback: (isRunning: boolean, message: string) => void) {
    this.onServerStatusCallback = callback;
  }

  // 启动服务器
  async start(ip: string, port: number): Promise<boolean> {
    try {
      console.log(`[TCPServer] 正在启动TCP服务器 ${ip}:${port}`);
      
      this.server = socket.constructTCPSocketServerInstance();
      
      // 监听客户端连接
      this.server.on('connect', async (client: socket.TCPSocketConnection) => {
        try {
          const remoteAddress = await client.getRemoteAddress();
          const clientInfo: ClientInfo = {
            id: `${remoteAddress.address}:${remoteAddress.port || 0}`,
            address: remoteAddress.address,
            port: remoteAddress.port || 0,
            name: `客户端 ${this.clients.size + 1}`,
            connection: client
          };
          
          this.clients.set(clientInfo.id, clientInfo);
          console.log(`[TCPServer] 客户端连接: ${clientInfo.address}:${clientInfo.port}`);
          this.onMessageCallback?.('receive', `客户端 ${clientInfo.address}:${clientInfo.port} 已连接`);
          this.onClientConnectCallback?.(clientInfo);
          
          // 更新连接状态为true（有客户端连接）
          AppStorage.setOrCreate(TCP_CONNECTION_STATUS, true);
          
          // 监听客户端消息
          client.on('message', (data: socket.SocketMessageInfo) => {
            // 使用 Dispatch 队列处理消息
            const messageData = new Uint8Array(data.message);
            
            // 检查是否为二进制统计数据（以SYNC开头）
            const isBinaryData = messageData.length >= 4 && 
              messageData[0] === 0x53 && // 'S'
              messageData[1] === 0x59 && // 'Y'
              messageData[2] === 0x4E && // 'N'
              messageData[3] === 0x43;    // 'C'
            
            if (isBinaryData) {
              // 二进制统计数据，直接处理
              console.log(`[TCPServer] 识别为二进制统计数据，开始处理...`);
              handleStatisticsData(messageData).catch((err: Error | object) => {
                const errorMsg = err instanceof Error ? err.message : String(err);
                console.error(`[TCPServer] 处理统计数据失败: ${errorMsg}`);
              });
            } else {
              // 文本消息，使用原有处理方式
              TcpMessageQueueManager.executeMessage(
                messageData,
                (message: string | Uint8Array) => {
                  const messageStr = typeof message === 'string' ? message : '[Binary Data]';
                  console.log(`[TCPServer] 收到文本消息: ${messageStr}`);
                  this.onMessageCallback?.('receive', messageStr, clientInfo.id);
                },
                client
              ).catch((err: Error | object) => {
                const errorMsg = err instanceof Error ? err.message : String(err);
                console.error(`[TCPServer] 接收消息处理失败: ${errorMsg}`);
                this.onMessageCallback?.('receive', `接收消息处理失败: ${errorMsg}`, clientInfo.id);
              });
            }
          });
          
          // 监听客户端断开
          client.on('close', () => {
            this.clients.delete(clientInfo.id);
            console.log(`[TCPServer] 客户端断开: ${clientInfo.address}:${clientInfo.port}`);
            this.onMessageCallback?.('receive', `客户端 ${clientInfo.address}:${clientInfo.port} 已断开`);
            this.onClientDisconnectCallback?.(clientInfo.id);
            
            // 检查是否还有客户端连接，如果没有则更新状态为false
            if (this.clients.size === 0) {
              AppStorage.setOrCreate(TCP_CONNECTION_STATUS, false);
            }
          });
          
          // 监听客户端错误
          client.on('error', (error: Error) => {
            console.error(`[TCPServer] 客户端错误: ${error.message}`);
            this.onMessageCallback?.('receive', `客户端 ${clientInfo.address}:${clientInfo.port} 发生错误: ${error.message}`);
            this.clients.delete(clientInfo.id);
            this.onClientDisconnectCallback?.(clientInfo.id);
            
            // 检查是否还有客户端连接，如果没有则更新状态为false
            if (this.clients.size === 0) {
              AppStorage.setOrCreate(TCP_CONNECTION_STATUS, false);
            }
          });
        } catch (error) {
          const errorMsg = error instanceof Error ? error.message : String(error);
          console.error(`[TCPServer] 处理客户端连接失败: ${errorMsg}`);
          this.onMessageCallback?.('receive', `处理客户端连接失败: ${errorMsg}`);
        }
      });
      
      // 监听服务器错误
      this.server.on('error', (error: Error) => {
        console.error(`[TCPServer] 服务器错误: ${error.message}`);
        this.onMessageCallback?.('receive', `服务器错误: ${error.message}`);
        this.onServerStatusCallback?.(false, `服务器错误: ${error.message}`);
      });
      
      // 启动服务器
      await this.server.listen({
        address: ip,
        port: port,
        family: 1 // IPv4
      });
      
      console.log(`[TCPServer] TCP服务器启动成功，监听 ${ip}:${port}`);
      this.onMessageCallback?.('receive', `服务器已启动，监听 ${ip}:${port}`);
      this.onServerStatusCallback?.(true, `服务器运行正常 - ${ip}:${port}`);
      return true;
      
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error(`[TCPServer] 启动服务器失败: ${errorMsg}`);
      this.onMessageCallback?.('receive', `启动服务器失败: ${errorMsg}`);
      this.onServerStatusCallback?.(false, `启动失败: ${errorMsg}`);
      return false;
    }
  }

  // 停止服务器
  async stop(): Promise<void> {
    try {
      console.log(`[TCPServer] 正在停止TCP服务器`);
      
      // 断开所有客户端连接
      for (const clientId of this.clients.keys()) {
        const client = this.clients.get(clientId);
        if (client) {
          try {
            await client.connection.close();
          } catch (error) {
            // 忽略客户端断开时的错误
          }
        }
      }
      
      // 关闭服务器
      if (this.server) {
        this.server.off('connect');
        this.server.off('error');
        this.server = null;
      }
      
      this.clients.clear();
      // 服务器停止时，设置连接状态为false
      AppStorage.setOrCreate(TCP_CONNECTION_STATUS, false);
      console.log(`[TCPServer] TCP服务器已停止`);
      this.onMessageCallback?.('receive', '服务器已停止');
      this.onServerStatusCallback?.(false, '服务器已停止');
      
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error(`[TCPServer] 停止服务器失败: ${errorMsg}`);
      this.onMessageCallback?.('receive', `停止服务器失败: ${errorMsg}`);
      this.onServerStatusCallback?.(false, `停止失败: ${errorMsg}`);
    }
  }

  // 发送消息给所有客户端
  async sendMessage(message: string): Promise<SendResult> {
    let successCount = 0;
    let failCount = 0;
    
    for (const clientId of this.clients.keys()) {
      const client = this.clients.get(clientId);
      if (client) {
        try {
          const encoder = new util.TextEncoder();
          const data = encoder.encodeInto(message);
          await client.connection.send({ data: data });
          successCount++;
        } catch (error) {
          failCount++;
          const errorMsg = error instanceof Error ? error.message : String(error);
          console.error(`[TCPServer] 发送消息失败: ${errorMsg}`);
          this.onMessageCallback?.('receive', `发送消息到 ${client.address}:${client.port} 失败: ${errorMsg}`);
        }
      }
    }
    
    if (successCount > 0) {
      this.onMessageCallback?.('send', message);
    }
    
    const result: SendResult = {
      success: successCount,
      fail: failCount
    };
    return result;
  }

  // 断开指定客户端
  async disconnectClient(clientId: string): Promise<boolean> {
    const client = this.clients.get(clientId);
    if (client) {
      try {
        await client.connection.close();
        this.clients.delete(clientId);
        console.log(`[TCPServer] 已断开客户端: ${clientId}`);
        this.onMessageCallback?.('receive', `已断开客户端 ${clientId}`);
        
        // 检查是否还有客户端连接，如果没有则更新状态为false
        if (this.clients.size === 0) {
          AppStorage.setOrCreate(TCP_CONNECTION_STATUS, false);
        }
        return true;
      } catch (error) {
        const errorMsg = error instanceof Error ? error.message : String(error);
        console.error(`[TCPServer] 断开客户端失败: ${errorMsg}`);
        this.onMessageCallback?.('receive', `断开客户端失败: ${errorMsg}`);
        return false;
      }
    }
    return false;
  }

  // 获取连接客户端列表
  getConnectedClients(): ClientInfo[] {
    return Array.from(this.clients.values());
  }

  // 获取客户端数量
  getClientCount(): number {
    return this.clients.size;
  }

  // 检查服务器是否运行
  isRunning(): boolean {
    return this.server !== null;
  }
}

export { ClientInfo, SendResult };
