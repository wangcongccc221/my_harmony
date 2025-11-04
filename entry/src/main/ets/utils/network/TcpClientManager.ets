import { TcpClient, createTcpClient } from './TcpClient';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;

/**
 * TCP客户端管理器
 * 提供全局的TCP客户端管理功能，支持多个客户端实例
 */
export class TcpClientManager {
  private static instance: TcpClientManager | null = null;
  private clients: Map<string, TcpClient> = new Map();
  private defaultClient: TcpClient | null = null;

  private constructor() {
    hilog.info(DOMAIN, 'TcpClientManager', 'TCP客户端管理器已创建');
  }

  /**
   * 获取单例实例
   */
  static getInstance(): TcpClientManager {
    if (!TcpClientManager.instance) {
      TcpClientManager.instance = new TcpClientManager();
    }
    return TcpClientManager.instance;
  }

  /**
   * 创建命名客户端
   * @param name 客户端名称
   * @returns TcpClient 客户端实例
   */
  createClient(name: string): TcpClient {
    const client = createTcpClient();
    this.clients.set(name, client);
    hilog.info(DOMAIN, 'TcpClientManager', `创建客户端: ${name}`);
    return client;
  }

  /**
   * 获取客户端
   * @param name 客户端名称
   * @returns TcpClient | undefined 客户端实例
   */
  getClient(name: string): TcpClient | undefined {
    return this.clients.get(name);
  }

  /**
   * 连接命名客户端
   * @param name 客户端名称
   * @param ip 服务器IP
   * @param port 服务器端口
   * @returns Promise<boolean> 连接是否成功
   */
  async connectClient(name: string, ip: string, port: number): Promise<boolean> {
    const client = this.clients.get(name);
    if (client) {
      hilog.info(DOMAIN, 'TcpClientManager', `连接客户端 ${name} 到 ${ip}:${port}`);
      return await client.connect(ip, port);
    }
    hilog.warn(DOMAIN, 'TcpClientManager', `客户端 ${name} 不存在`);
    return false;
  }

  /**
   * 断开命名客户端
   * @param name 客户端名称
   * @returns Promise<boolean> 断开是否成功
   */
  async disconnectClient(name: string): Promise<boolean> {
    const client = this.clients.get(name);
    if (client) {
      hilog.info(DOMAIN, 'TcpClientManager', `断开客户端: ${name}`);
      return await client.disconnect();
    }
    hilog.warn(DOMAIN, 'TcpClientManager', `客户端 ${name} 不存在`);
    return false;
  }

  /**
   * 发送消息到命名客户端
   * @param name 客户端名称
   * @param message 消息内容
   * @returns Promise<boolean> 发送是否成功
   */
  async sendToClient(name: string, message: string): Promise<boolean> {
    const client = this.clients.get(name);
    if (client) {
      hilog.info(DOMAIN, 'TcpClientManager', `发送消息到客户端 ${name}: ${message}`);
      return await client.sendMessage(message);
    }
    hilog.warn(DOMAIN, 'TcpClientManager', `客户端 ${name} 不存在`);
    return false;
  }

  /**
   * 设置默认客户端
   * @param name 客户端名称
   */
  setDefaultClient(name: string): void {
    const client = this.clients.get(name);
    if (client) {
      this.defaultClient = client;
      hilog.info(DOMAIN, 'TcpClientManager', `设置默认客户端: ${name}`);
    } else {
      hilog.warn(DOMAIN, 'TcpClientManager', `客户端 ${name} 不存在，无法设置为默认客户端`);
    }
  }

  /**
   * 获取默认客户端
   * @returns TcpClient | null 默认客户端实例
   */
  getDefaultClient(): TcpClient | null {
    return this.defaultClient;
  }

  /**
   * 通过默认客户端发送消息
   * @param message 消息内容
   * @returns Promise<boolean> 发送是否成功
   */
  async sendMessage(message: string): Promise<boolean> {
    if (this.defaultClient) {
      return await this.defaultClient.sendMessage(message);
    }
    hilog.warn(DOMAIN, 'TcpClientManager', '默认客户端未设置');
    return false;
  }

  /**
   * 获取所有客户端名称
   * @returns string[] 客户端名称列表
   */
  getClientNames(): string[] {
    return Array.from(this.clients.keys());
  }

  /**
   * 获取客户端数量
   * @returns number 客户端数量
   */
  getClientCount(): number {
    return this.clients.size;
  }

  /**
   * 移除客户端
   * @param name 客户端名称
   * @returns Promise<boolean> 移除是否成功
   */
  async removeClient(name: string): Promise<boolean> {
    const client = this.clients.get(name);
    if (client) {
      await client.disconnect();
      this.clients.delete(name);
      if (this.defaultClient === client) {
        this.defaultClient = null;
      }
      hilog.info(DOMAIN, 'TcpClientManager', `移除客户端: ${name}`);
      return true;
    }
    hilog.warn(DOMAIN, 'TcpClientManager', `客户端 ${name} 不存在`);
    return false;
  }

  /**
   * 清理所有客户端
   * @returns Promise<void>
   */
  async cleanup(): Promise<void> {
    hilog.info(DOMAIN, 'TcpClientManager', '清理所有客户端');
    
    for (const name of this.clients.keys()) {
      const client = this.clients.get(name);
      if (!client) {
        continue;
      }
      try {
        await client.disconnect();
        hilog.info(DOMAIN, 'TcpClientManager', `已断开客户端: ${name}`);
      } catch (error) {
        hilog.error(DOMAIN, 'TcpClientManager', `断开客户端 ${name} 失败: ${error}`);
      }
    }
    
    this.clients.clear();
    this.defaultClient = null;
    hilog.info(DOMAIN, 'TcpClientManager', '所有客户端已清理');
  }
}

/**
 * 获取全局TCP客户端管理器实例
 * @returns TcpClientManager 管理器实例
 */
export function getTcpClientManager(): TcpClientManager {
  return TcpClientManager.getInstance();
}
