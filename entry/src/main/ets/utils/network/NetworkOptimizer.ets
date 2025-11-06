/**
 * 网络优化器
 * 
 * 简化版网络管理，专注于核心功能：
 * - TCP服务器和客户端管理
 * - 消息发送
 * - 基本状态获取
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import { TCPServer } from './TCPServer';
import { TcpClient, createTcpClient } from './TcpClient';

const DOMAIN = 0x0000;

// TCP 网络配置
const TCP_SERVER_IP: string = '192.168.0.15';      // TCP 服务器监听地址
const TCP_CLIENT_REMOTE_IP: string = '192.168.0.16'; // TCP 客户端连接的目标地址
const TCP_SERVER_PORT: number = 8081;               // TCP 服务器端口（避免与 HTTP 服务器 8080 冲突）

/**
 * 网络优化器
 */
export class NetworkOptimizer {
  private static instance: NetworkOptimizer | null = null;
  
  // 网络组件
  private tcpServer: TCPServer | null = null;
  private tcpClient: TcpClient | null = null;
  
  // 状态管理
  private isInitialized: boolean = false;

  private constructor() {
    hilog.info(DOMAIN, 'NetworkOptimizer', '网络优化器实例已创建');
  }

  /**
   * 获取单例实例
   */
  static getInstance(): NetworkOptimizer {
    if (!NetworkOptimizer.instance) {
      NetworkOptimizer.instance = new NetworkOptimizer();
    }
    return NetworkOptimizer.instance;
  }

  /**
   * 初始化网络优化器
   */
  async initialize(): Promise<boolean> {
    try {
      if (this.isInitialized) {
        hilog.warn(DOMAIN, 'NetworkOptimizer', '网络优化器已经初始化');
        return true;
      }
      
      hilog.info(DOMAIN, 'NetworkOptimizer', '开始初始化网络优化器');
      
      // 初始化TCP服务器
      await this.initializeTCPServer();
      
      // 初始化TCP客户端
      await this.initializeTcpClient();
      
      this.isInitialized = true;
      hilog.info(DOMAIN, 'NetworkOptimizer', '网络优化器初始化完成');
      
      return true;
    } catch (error) {
      hilog.error(DOMAIN, 'NetworkOptimizer', `网络优化器初始化失败: ${error}`);
      return false;
    }
  }

  /**
   * 初始化TCP服务器
   */
  private async initializeTCPServer(): Promise<void> {
    try {
      this.tcpServer = new TCPServer();
      
      // 设置服务器回调
      this.tcpServer.setOnServerStatus((isRunning, message) => {
        hilog.info(DOMAIN, 'NetworkOptimizer', `TCP服务器状态: ${isRunning ? '运行中' : '已停止'} - ${message}`);
      });
      
      this.tcpServer.setOnClientConnect((client) => {
        hilog.info(DOMAIN, 'NetworkOptimizer', `客户端连接: ${client.address}:${client.port}`);
      });
      
      this.tcpServer.setOnClientDisconnect((clientId) => {
        hilog.info(DOMAIN, 'NetworkOptimizer', `客户端断开: ${clientId}`);
      });
      
      this.tcpServer.setOnMessage((type, content, clientId) => {
        hilog.info(DOMAIN, 'NetworkOptimizer', `TCP消息 [${type}]: ${content} ${clientId ? `from ${clientId}` : ''}`);
      });
      
      // 启动服务器
      const success = await this.tcpServer.start(TCP_SERVER_IP, TCP_SERVER_PORT);
      if (success) {
        hilog.info(DOMAIN, 'NetworkOptimizer', `TCP服务器启动成功 - ${TCP_SERVER_IP}:${TCP_SERVER_PORT}`);
      } else {
        hilog.error(DOMAIN, 'NetworkOptimizer', 'TCP服务器启动失败');
        return;
      }
    } catch (error) {
      hilog.error(DOMAIN, 'NetworkOptimizer', `TCP服务器初始化失败: ${error}`);
      return;
    }
  }

  /**
   * 初始化TCP客户端
   */
  private async initializeTcpClient(): Promise<void> {
    try {
      this.tcpClient = createTcpClient();
      
      // 设置客户端回调
      this.tcpClient.onMessage((message) => {
        hilog.info(DOMAIN, 'NetworkOptimizer', `TCP客户端收到消息: ${message}`);
      });
      
      this.tcpClient.onStatusChange((connected) => {
        hilog.info(DOMAIN, 'NetworkOptimizer', `TCP客户端连接状态: ${connected ? '已连接' : '已断开'}`);
      });
      
      this.tcpClient.onError((error) => {
        hilog.error(DOMAIN, 'NetworkOptimizer', `TCP客户端错误: ${error}`);
      });
      
      // 设置重连配置
      this.tcpClient.setReconnectConfig(10, 5000); // 最多重连10次，间隔5秒  后期修改一下 可以无限自动重连
      
      // 连接到服务器
      const connected = await this.tcpClient.connect(TCP_CLIENT_REMOTE_IP, TCP_SERVER_PORT);
      if (connected) {
        hilog.info(DOMAIN, 'NetworkOptimizer', `TCP客户端连接成功 - ${TCP_CLIENT_REMOTE_IP}:${TCP_SERVER_PORT}`);
      } else {
        hilog.warn(DOMAIN, 'NetworkOptimizer', `TCP客户端连接失败，将自动重连`);
      }
    } catch (error) {
      hilog.error(DOMAIN, 'NetworkOptimizer', `TCP客户端初始化失败: ${error}`);
      return;
    }
  }

  /**
   * 获取网络状态
   */
  getNetworkStatus(): boolean {
    return this.tcpServer !== null && this.tcpClient !== null;
  }

  /**
   * 发送消息
   */
  async sendMessage(message: string): Promise<boolean> {
    if (!this.tcpClient) {
      hilog.warn(DOMAIN, 'NetworkOptimizer', 'TCP客户端未初始化');
      return false;
    }
    
    try {
      return await this.tcpClient.sendMessage(message);
    } catch (error) {
      hilog.error(DOMAIN, 'NetworkOptimizer', `发送消息失败: ${error}`);
      return false;
    }
  }

  /**
   * 停止网络优化器
   */
  async stop(): Promise<boolean> {
    try {
      hilog.info(DOMAIN, 'NetworkOptimizer', '正在停止网络优化器');
      
      // 停止TCP服务器
      if (this.tcpServer) {
        await this.tcpServer.stop();
        this.tcpServer = null;
      }
      
      // 停止TCP客户端
      if (this.tcpClient) {
        await this.tcpClient.disconnect();
        this.tcpClient = null;
      }
      
      this.isInitialized = false;
      hilog.info(DOMAIN, 'NetworkOptimizer', '网络优化器已停止');
      
      return true;
    } catch (error) {
      hilog.error(DOMAIN, 'NetworkOptimizer', `停止网络优化器失败: ${error}`);
      return false;
    }
  }
}
