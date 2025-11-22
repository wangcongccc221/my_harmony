/**
 * 网络优化器
 * 
 * 简化版网络管理，专注于核心功能：
 * - TCP服务器和客户端管理
 * - 消息发送
 * - 基本状态获取
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import { TCPServer, SendResult } from './tcp/TCPServer';
import { TcpClient, createTcpClient, runTcpClientWorker } from './tcp/TcpClient';
import { runTcpServerWorker } from './tcp/TCPServer';
import { taskpool } from '@kit.ArkTS';

const DOMAIN = 0x0000;

// TCP 网络配置
const TCP_SERVER_IP: string = '0.0.0.0';      // TCP 服务器监听地址（0.0.0.0表示监听所有网络接口，可从局域网访问）
const TCP_CLIENT_REMOTE_IP: string = '192.168.0.16'; // TCP 客户端连接的目标地址
const TCP_SERVER_PORT: number = 8081;               // TCP 服务器端口（避免与 HTTP 服务器 8080 冲突）

/**
 * 网络优化器
 */
export class NetworkOptimizer {
  private static instance: NetworkOptimizer | null = null;
  
  // 网络组件
  private tcpServer: TCPServer | null = null; // 兼容保留，不再直接在UI启动
  private tcpClient: TcpClient | null = null; // 兼容保留，不再直接在UI启动
  
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
      const task: taskpool.Task = new taskpool.Task(runTcpServerWorker, TCP_SERVER_IP, TCP_SERVER_PORT);
      taskpool.execute(task);
      hilog.info(DOMAIN, 'NetworkOptimizer', `TCP服务器已在TaskPool中启动 - ${TCP_SERVER_IP}:${TCP_SERVER_PORT}`);
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
      const task: taskpool.Task = new taskpool.Task(runTcpClientWorker, TCP_CLIENT_REMOTE_IP, TCP_SERVER_PORT);
      taskpool.execute(task);
      // 初始化客户端发信队列
      AppStorage.setOrCreate('TCP_CLIENT_OUTBOX', [] as string[]);
      hilog.info(DOMAIN, 'NetworkOptimizer', `TCP客户端已在TaskPool中启动 - ${TCP_CLIENT_REMOTE_IP}:${TCP_SERVER_PORT}`);
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
    try {
      const queue = AppStorage.get('TCP_CLIENT_OUTBOX') as string[] | null;
      const next = Array.isArray(queue) ? queue : [];
      next.push(message);
      AppStorage.setOrCreate('TCP_CLIENT_OUTBOX', next);
      return true;
    } catch (error) {
      hilog.error(DOMAIN, 'NetworkOptimizer', `发送消息失败(队列): ${error}`);
      return false;
    }
  }

  /**
   * 停止网络优化器
   */
  async stop(): Promise<boolean> {
    try {
      hilog.info(DOMAIN, 'NetworkOptimizer', '正在停止网络优化器');
      
      // 发出停止信号，交由Worker处理
      AppStorage.setOrCreate('TCP_SERVER_SHUTDOWN', true);
      AppStorage.setOrCreate('TCP_CLIENT_SHUTDOWN', true);
      
      this.isInitialized = false;
      hilog.info(DOMAIN, 'NetworkOptimizer', '网络优化器已停止');
      
      return true;
    } catch (error) {
      hilog.error(DOMAIN, 'NetworkOptimizer', `停止网络优化器失败: ${error}`);
      return false;
    }
  }
}
