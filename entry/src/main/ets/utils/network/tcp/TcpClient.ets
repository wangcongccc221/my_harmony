import { socket } from '@kit.NetworkKit';
import { util } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;

/**
 * TCP客户端 - 后台运行版本
 * 专门用于连接到指定服务器，无需UI界面
 */
export class TcpClient {
  private tcpSocket: socket.TCPSocket | null = null;
  private isConnected: boolean = false;
  private serverIp: string = '';
  private serverPort: number = 0;
  private messageCallbacks: ((message: string) => void)[] = [];
  private statusCallbacks: ((connected: boolean) => void)[] = [];
  private errorCallbacks: ((error: string) => void)[] = [];
  private reconnectAttempts: number = 0;
  private maxReconnectAttempts: number = 5;
  private reconnectInterval: number = 5000; // 5秒
  private reconnectTimer: number | null = null;

  constructor() {
    hilog.info(DOMAIN, 'TcpClient', 'TCP客户端实例已创建');
  }

  /**
   * 连接到TCP服务器
   * @param ip 服务器IP地址
   * @param port 服务器端口
   * @returns Promise<boolean> 连接是否成功
   */
  async connect(ip: string, port: number): Promise<boolean> {
    this.serverIp = ip;
    this.serverPort = port;
    
    try {
      hilog.info(DOMAIN, 'TcpClient', `正在连接到服务器 ${ip}:${port}`);
      
      this.tcpSocket = socket.constructTCPSocketInstance();
      
      // 监听服务器消息
      this.tcpSocket.on('message', (data: socket.SocketMessageInfo) => {
        try {
          const decoder = new util.TextDecoder();
          const uint8Array = new Uint8Array(data.message);
          const message = decoder.decode(uint8Array);
          hilog.info(DOMAIN, 'TcpClient', `收到消息: ${message}`);
          this.notifyMessageCallbacks(message);
        } catch (error) {
          hilog.error(DOMAIN, 'TcpClient', `接收消息解码失败: ${error}`);
          this.notifyErrorCallbacks(`接收消息解码失败: ${error}`);
        }
      });
      
      // 监听连接关闭
      this.tcpSocket.on('close', () => {
        this.isConnected = false;
        hilog.info(DOMAIN, 'TcpClient', '与服务器连接已断开');
        this.notifyStatusCallbacks(false);
        this.notifyMessageCallbacks('与服务器连接已断开');
        
        // 自动重连
        this.scheduleReconnect();
      });
      
      // 监听连接错误
      this.tcpSocket.on('error', (error: Error) => {
        this.isConnected = false;
        hilog.error(DOMAIN, 'TcpClient', `连接错误: ${error.message}`);
        this.notifyStatusCallbacks(false);
        this.notifyErrorCallbacks(`连接错误: ${error.message}`);
        
        // 自动重连
        this.scheduleReconnect();
      });
      
      // 连接到服务器
      await this.tcpSocket.connect({
        address: {
          address: ip,
          port: port,
          family: 1 // IPv4
        }
      });
      
      this.isConnected = true;
      this.reconnectAttempts = 0; // 重置重连计数
      hilog.info(DOMAIN, 'TcpClient', `已连接到服务器 ${ip}:${port}`);
      this.notifyStatusCallbacks(true);
      this.notifyMessageCallbacks(`已连接到服务器 ${ip}:${port}`);
      
      return true;
    } catch (error) {
      hilog.error(DOMAIN, 'TcpClient', `连接失败: ${error}`);
      this.notifyErrorCallbacks(`连接失败: ${error}`);
      
      // 自动重连
      this.scheduleReconnect();
      return false;
    }
  }

  /**
   * 断开与服务器的连接
   * @returns Promise<boolean> 断开是否成功
   */
  async disconnect(): Promise<boolean> {
    try {
      // 清除重连定时器
      if (this.reconnectTimer) {
        clearTimeout(this.reconnectTimer);
        this.reconnectTimer = null;
      }
      
      if (this.tcpSocket) {
        await this.tcpSocket.close();
        this.tcpSocket = null;
      }
      
      this.isConnected = false;
      hilog.info(DOMAIN, 'TcpClient', '已断开与服务器的连接');
      this.notifyStatusCallbacks(false);
      this.notifyMessageCallbacks('已断开与服务器的连接');
      
      return true;
    } catch (error) {
      hilog.error(DOMAIN, 'TcpClient', `断开连接失败: ${error}`);
      this.notifyErrorCallbacks(`断开连接失败: ${error}`);
      return false;
    }
  }

  /**
   * 发送消息到服务器
   * @param message 要发送的消息内容
   * @returns Promise<boolean> 发送是否成功
   */
  async sendMessage(message: string): Promise<boolean> {
    if (!this.isConnected || !this.tcpSocket) {
      hilog.warn(DOMAIN, 'TcpClient', '未连接到服务器，无法发送消息');
      this.notifyErrorCallbacks('未连接到服务器');
      return false;
    }
    
    try {
      const encoder = new util.TextEncoder();
      const data = encoder.encodeInto(message);
      await this.tcpSocket.send({ data: data });
      hilog.info(DOMAIN, 'TcpClient', `发送消息: ${message}`);
      return true;
    } catch (error) {
      hilog.error(DOMAIN, 'TcpClient', `发送消息失败: ${error}`);
      this.notifyErrorCallbacks(`发送消息失败: ${error}`);
      return false;
    }
  }

  /**
   * 获取当前连接状态
   * @returns boolean 是否已连接
   */
  getConnectionStatus(): boolean {
    return this.isConnected;
  }

  /**
   * 注册消息接收回调
   * @param callback 消息接收回调函数
   */
  onMessage(callback: (message: string) => void): void {
    this.messageCallbacks.push(callback);
  }

  /**
   * 注册连接状态变化回调
   * @param callback 连接状态回调函数
   */
  onStatusChange(callback: (connected: boolean) => void): void {
    this.statusCallbacks.push(callback);
  }

  /**
   * 注册错误回调
   * @param callback 错误回调函数
   */
  onError(callback: (error: string) => void): void {
    this.errorCallbacks.push(callback);
  }

  /**
   * 移除所有回调
   */
  removeAllCallbacks(): void {
    this.messageCallbacks = [];
    this.statusCallbacks = [];
    this.errorCallbacks = [];
  }

  /**
   * 设置自动重连参数
   * @param maxAttempts 最大重连次数
   * @param interval 重连间隔（毫秒）
   */
  setReconnectConfig(maxAttempts: number, interval: number): void {
    this.maxReconnectAttempts = maxAttempts;
    this.reconnectInterval = interval;
  }

  /**
   * 手动触发重连
   */
  async reconnect(): Promise<boolean> {
    if (this.serverIp && this.serverPort > 0) {
      return await this.connect(this.serverIp, this.serverPort);
    }
    return false;
  }

  // 私有方法：安排重连
  private scheduleReconnect(): void {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      hilog.warn(DOMAIN, 'TcpClient', `已达到最大重连次数 ${this.maxReconnectAttempts}，停止重连`);
      this.notifyErrorCallbacks(`已达到最大重连次数，停止重连`);
      return;
    }

    this.reconnectAttempts++;
    hilog.info(DOMAIN, 'TcpClient', `${this.reconnectInterval / 1000}秒后进行第${this.reconnectAttempts}次重连`);
    
    this.reconnectTimer = setTimeout(async () => {
      if (!this.isConnected) {
        hilog.info(DOMAIN, 'TcpClient', `执行第${this.reconnectAttempts}次重连`);
        await this.connect(this.serverIp, this.serverPort);
      }
    }, this.reconnectInterval);
  }

  // 私有方法：通知消息回调
  private notifyMessageCallbacks(message: string): void {
    this.messageCallbacks.forEach(callback => {
      try {
        callback(message);
      } catch (error) {
        hilog.error(DOMAIN, 'TcpClient', `消息回调执行失败: ${error}`);
      }
    });
  }

  // 私有方法：通知状态回调
  private notifyStatusCallbacks(connected: boolean): void {
    this.statusCallbacks.forEach(callback => {
      try {
        callback(connected);
      } catch (error) {
        hilog.error(DOMAIN, 'TcpClient', `状态回调执行失败: ${error}`);
      }
    });
  }

  // 私有方法：通知错误回调
  private notifyErrorCallbacks(error: string): void {
    this.errorCallbacks.forEach(callback => {
      try {
        callback(error);
      } catch (error) {
        hilog.error(DOMAIN, 'TcpClient', `错误回调执行失败: ${error}`);
      }
    });
  }
}

/**
 * 创建TCP客户端实例的便捷函数
 * @returns TcpClient TCP客户端实例
 */
export function createTcpClient(): TcpClient {
  return new TcpClient();
}
