/**
 * TCP 服务器和客户端模块
 * 统一导出 TCP 相关的所有功能
 */

// TCP 服务器
export { TCPServer, runTcpServerWorker } from './TCPServer';
export type { ClientInfo, SendResult } from './TCPServer';

// TCP 客户端
export { TcpClient, createTcpClient, runTcpClientWorker } from './TcpClient';

// TCP 客户端管理器
export { TcpClientManager } from './TcpClientManager';

// TCP 消息 Dispatch 队列
export * from './dispatch';

