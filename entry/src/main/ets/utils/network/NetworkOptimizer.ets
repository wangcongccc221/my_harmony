/**
 * 网络优化器
 * 
 * 简化版网络管理，专注于核心功能：
 * - TCP服务器和客户端管理
 * - 消息发送
 * - 基本状态获取
 */

import { TCPServer, SendResult } from './tcp/TCPServer';
import { TcpClient, createTcpClient } from './tcp/TcpClient';

// AppStorage 是全局可用的，无需导入

// TCP 网络配置
const TCP_SERVER_IP: string = '0.0.0.0';      // 8081
const TCP_CLIENT_REMOTE_IP: string = '192.168.0.16';
const TCP_SERVER_PORT: number = 8081;

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
    console.log('[NetworkOptimizer] 网络优化器实例已创建');
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
        console.warn('[NetworkOptimizer] 网络优化器已经初始化');
        return true;
      }
      
      console.log('[NetworkOptimizer] 开始初始化网络优化器');
      
      // 初始化TCP服务器（不使用TaskPool，直接在UI线程运行）
      await this.initializeTCPServer();
      
      // 初始化TCP客户端（暂时不启动，如果需要可以后续添加）
      // await this.initializeTcpClient();
      
      this.isInitialized = true;
      console.log('[NetworkOptimizer] 网络优化器初始化完成');
      
      return true;
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error(`[NetworkOptimizer] 网络优化器初始化失败: ${errorMsg}`);
      return false;
    }
  }

  /**
   * 初始化TCP服务器（不使用TaskPool，直接在UI线程运行）
   */
  private async initializeTCPServer(): Promise<void> {
    try {
      // 创建TCP服务器实例（不使用TaskPool）
      this.tcpServer = new TCPServer();
      
      // 启动服务器（在UI线程中运行，可以直接使用AppStorage）
      const success: boolean = await this.tcpServer.start(TCP_SERVER_IP, TCP_SERVER_PORT);
      
      if (success) {
        console.log(`[NetworkOptimizer] TCP服务器启动成功 - ${TCP_SERVER_IP}:${TCP_SERVER_PORT}`);
      } else {
        console.error(`[NetworkOptimizer] TCP服务器启动失败 - ${TCP_SERVER_IP}:${TCP_SERVER_PORT}`);
      }
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error(`[NetworkOptimizer] TCP服务器初始化失败: ${errorMsg}`);
      return;
    }
  }

  /**
   * 初始化TCP客户端（暂时不启动，如果需要可以后续添加）
   */
  private async initializeTcpClient(): Promise<void> {
    try {
      // 初始化客户端发信队列
      AppStorage.setOrCreate('TCP_CLIENT_OUTBOX', [] as string[]);
      console.log(`[NetworkOptimizer] TCP客户端队列已初始化`);
      // 如果需要启动TCP客户端，可以在这里创建并启动
      // this.tcpClient = createTcpClient();
      // await this.tcpClient.connect(TCP_CLIENT_REMOTE_IP, TCP_SERVER_PORT);
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error(`[NetworkOptimizer] TCP客户端初始化失败: ${errorMsg}`);
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
    try {
      const queue = AppStorage.get('TCP_CLIENT_OUTBOX') as string[] | null;
      const next = Array.isArray(queue) ? queue : [];
      next.push(message);
      AppStorage.setOrCreate('TCP_CLIENT_OUTBOX', next);
      return true;
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error(`[NetworkOptimizer] 发送消息失败(队列): ${errorMsg}`);
      return false;
    }
  }

  /**
   * 停止网络优化器
   */
  async stop(): Promise<boolean> {
    try {
      console.log('[NetworkOptimizer] 正在停止网络优化器');
      
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
      console.log('[NetworkOptimizer] 网络优化器已停止');
      
      return true;
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error(`[NetworkOptimizer] 停止网络优化器失败: ${errorMsg}`);
      return false;
    }
  }
}
