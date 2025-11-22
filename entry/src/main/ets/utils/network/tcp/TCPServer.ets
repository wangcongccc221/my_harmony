import { socket } from '@kit.NetworkKit';
import { util } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
// AppStorage 是全局可用的，无需导入
import { TCP_CONNECTION_STATUS } from '../../../constants/TopBarKeys';
import { taskpool } from '@kit.ArkTS';

@Concurrent
export async function runTcpServerWorker(ip: string, port: number): Promise<void> {
  const DOMAIN = 0x0000;
  try {
    const server = socket.constructTCPSocketServerInstance();

    const MAX_MSG_CONCURRENT = 64;
    const MAX_MSG_QUEUE = 256;
    let active = 0;
    const queue: Array<() => Promise<void>> = [];

    const processQueue = () => {
      while (active < MAX_MSG_CONCURRENT && queue.length > 0) {
        const next = queue.shift();
        if (next) {
          active++;
          next().finally(() => {
            active--;
            processQueue();
          });
        }
      }
    };

    const schedule = (task: () => Promise<void>, onReject: () => void) => {
      if (active < MAX_MSG_CONCURRENT) {
        active++;
        task().finally(() => {
          active--;
          processQueue();
        });
        return;
      }
      if (queue.length < MAX_MSG_QUEUE) {
        queue.push(task);
        return;
      }
      onReject();
    };

    server.on('connect', async (client: socket.TCPSocketConnection) => {
      try {
        const remote = await client.getRemoteAddress();
        hilog.info(DOMAIN, 'TCPServerWorker', `客户端连接: ${remote.address}:${remote.port || 0}`);
        AppStorage.setOrCreate(TCP_CONNECTION_STATUS, true);

        client.on('message', (data: socket.SocketMessageInfo) => {
          schedule(async () => {
            try {
              const decoder = new util.TextDecoder();
              const uint8Array = new Uint8Array(data.message);
              const message = decoder.decode(uint8Array);
              hilog.info(DOMAIN, 'TCPServerWorker', `收到消息: ${message}`);
            } catch (error) {
              hilog.error(DOMAIN, 'TCPServerWorker', `消息处理失败: ${error}`);
            }
          }, () => {
            try {
              const encoder = new util.TextEncoder();
              const rejectMsg = encoder.encodeInto('SERVER_BUSY');
              client.send({ data: rejectMsg }).catch(() => {});
            } catch (_) {}
          });
        });

        client.on('close', () => {
          hilog.info(DOMAIN, 'TCPServerWorker', `客户端断开: ${remote.address}:${remote.port || 0}`);
          AppStorage.setOrCreate(TCP_CONNECTION_STATUS, false);
        });

        client.on('error', (err: Error) => {
          hilog.error(DOMAIN, 'TCPServerWorker', `客户端错误: ${err.message}`);
        });
      } catch (e) {
        hilog.error(DOMAIN, 'TCPServerWorker', `处理连接失败: ${e}`);
      }
    });

    server.on('error', (error: Error) => {
      hilog.error(DOMAIN, 'TCPServerWorker', `服务器错误: ${error.message}`);
    });

    await server.listen({ address: ip, port, family: 1 });
    hilog.info(DOMAIN, 'TCPServerWorker', `服务器启动成功: ${ip}:${port}`);

    // 简单的关闭信号轮询
    const SHUTDOWN_KEY = 'TCP_SERVER_SHUTDOWN';
    const checkInterval = setInterval(async () => {
      try {
        const flag = AppStorage.get(SHUTDOWN_KEY) as boolean | null;
        if (flag) {
          clearInterval(checkInterval);
          try { server.off('connect'); server.off('error'); } catch (_) {}
          hilog.info(DOMAIN, 'TCPServerWorker', '收到关闭信号，服务器退出');
        }
      } catch (_) {}
    }, 1000) as number;
  } catch (error) {
    hilog.error(DOMAIN, 'TCPServerWorker', `启动失败: ${error instanceof Error ? error.message : String(error)}`);
  }
}

const DOMAIN = 0x0000;

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
    hilog.info(DOMAIN, 'TCPServer', 'TCP服务器实例已创建');
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
      hilog.info(DOMAIN, 'TCPServer', `正在启动TCP服务器 ${ip}:${port}`);
      
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
          hilog.info(DOMAIN, 'TCPServer', `客户端连接: ${clientInfo.address}:${clientInfo.port}`);
          console.log(`[TCP服务器] 客户端连接: ${clientInfo.address}:${clientInfo.port}`);
          this.onMessageCallback?.('receive', `客户端 ${clientInfo.address}:${clientInfo.port} 已连接`);
          this.onClientConnectCallback?.(clientInfo);
          
          // 更新连接状态为true（有客户端连接）
          AppStorage.setOrCreate(TCP_CONNECTION_STATUS, true);
          
          // 监听客户端消息
          client.on('message', (data: socket.SocketMessageInfo) => {
            try {
              const decoder = new util.TextDecoder();
              const uint8Array = new Uint8Array(data.message);
              const message = decoder.decode(uint8Array);
              hilog.info(DOMAIN, 'TCPServer', `收到消息: ${message}`);
              console.log(`[TCP服务器] 从客户端 ${clientInfo.address}:${clientInfo.port} 接收到数据: ${message}`);
              this.onMessageCallback?.('receive', message, clientInfo.id);
            } catch (error) {
              hilog.error(DOMAIN, 'TCPServer', `接收消息解码失败: ${error}`);
              console.log(`[TCP服务器] 接收消息解码失败: ${error}`);
              this.onMessageCallback?.('receive', `接收消息解码失败: ${error}`, clientInfo.id);
            }
          });
          
          // 监听客户端断开
          client.on('close', () => {
            this.clients.delete(clientInfo.id);
            hilog.info(DOMAIN, 'TCPServer', `客户端断开: ${clientInfo.address}:${clientInfo.port}`);
            console.log(`[TCP服务器] 客户端断开: ${clientInfo.address}:${clientInfo.port}`);
            this.onMessageCallback?.('receive', `客户端 ${clientInfo.address}:${clientInfo.port} 已断开`);
            this.onClientDisconnectCallback?.(clientInfo.id);
            
            // 检查是否还有客户端连接，如果没有则更新状态为false
            if (this.clients.size === 0) {
              AppStorage.setOrCreate(TCP_CONNECTION_STATUS, false);
            }
          });
          
          // 监听客户端错误
          client.on('error', (error: Error) => {
            hilog.error(DOMAIN, 'TCPServer', `客户端错误: ${error.message}`);
            this.onMessageCallback?.('receive', `客户端 ${clientInfo.address}:${clientInfo.port} 发生错误: ${error.message}`);
            this.clients.delete(clientInfo.id);
            this.onClientDisconnectCallback?.(clientInfo.id);
            
            // 检查是否还有客户端连接，如果没有则更新状态为false
            if (this.clients.size === 0) {
              AppStorage.setOrCreate(TCP_CONNECTION_STATUS, false);
            }
          });
        } catch (error) {
          hilog.error(DOMAIN, 'TCPServer', `处理客户端连接失败: ${error}`);
          this.onMessageCallback?.('receive', `处理客户端连接失败: ${error}`);
        }
      });
      
      // 监听服务器错误
      this.server.on('error', (error: Error) => {
        hilog.error(DOMAIN, 'TCPServer', `服务器错误: ${error.message}`);
        this.onMessageCallback?.('receive', `服务器错误: ${error.message}`);
        this.onServerStatusCallback?.(false, `服务器错误: ${error.message}`);
      });
      
      // 启动服务器
      await this.server.listen({
        address: ip,
        port: port,
        family: 1 // IPv4
      });
      
      hilog.info(DOMAIN, 'TCPServer', `TCP服务器启动成功，监听 ${ip}:${port}`);
      console.log(`[TCP服务器] 服务器启动成功，监听 ${ip}:${port}`);
      this.onMessageCallback?.('receive', `服务器已启动，监听 ${ip}:${port}`);
      this.onServerStatusCallback?.(true, `服务器运行正常 - ${ip}:${port}`);
      return true;
      
    } catch (error) {
      hilog.error(DOMAIN, 'TCPServer', `启动服务器失败: ${error.message}`);
      this.onMessageCallback?.('receive', `启动服务器失败: ${error.message}`);
      this.onServerStatusCallback?.(false, `启动失败: ${error.message}`);
      return false;
    }
  }

  // 停止服务器
  async stop(): Promise<void> {
    try {
      hilog.info(DOMAIN, 'TCPServer', '正在停止TCP服务器');
      
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
      hilog.info(DOMAIN, 'TCPServer', 'TCP服务器已停止');
      console.log(`[TCP服务器] 服务器已停止`);
      this.onMessageCallback?.('receive', '服务器已停止');
      this.onServerStatusCallback?.(false, '服务器已停止');
      
    } catch (error) {
      hilog.error(DOMAIN, 'TCPServer', `停止服务器失败: ${error.message}`);
      this.onMessageCallback?.('receive', `停止服务器失败: ${error.message}`);
      this.onServerStatusCallback?.(false, `停止失败: ${error.message}`);
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
          hilog.error(DOMAIN, 'TCPServer', `发送消息失败: ${error}`);
          this.onMessageCallback?.('receive', `发送消息到 ${client.address}:${client.port} 失败: ${error}`);
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
        hilog.info(DOMAIN, 'TCPServer', `已断开客户端: ${clientId}`);
        this.onMessageCallback?.('receive', `已断开客户端 ${clientId}`);
        
        // 检查是否还有客户端连接，如果没有则更新状态为false
        if (this.clients.size === 0) {
          AppStorage.setOrCreate(TCP_CONNECTION_STATUS, false);
        }
        return true;
      } catch (error) {
        hilog.error(DOMAIN, 'TCPServer', `断开客户端失败: ${error.message}`);
        this.onMessageCallback?.('receive', `断开客户端失败: ${error.message}`);
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
