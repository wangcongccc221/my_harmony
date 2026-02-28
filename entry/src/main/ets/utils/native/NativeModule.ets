/**
 * Native C++ 模块调用接口
 * 用于调用C++代码
 */

import nativeModule from 'libnative_module.so';

// 重新导出或定义接口，方便上层使用
export interface CommandHead {
  cmdId: number;
  srcId: number;
  length: number;
  data: Uint8Array;
}

/**
 * Native模块接口
 */
export class NativeModule {
  // ===================== 基础测试接口 =====================

  static getHelloString(): string {
    try {
      return nativeModule.getHelloString();
    } catch (error) {
      console.error('NativeModule.getHelloString error:', error);
      return 'Error calling native function';
    }
  }

  static addNumbers(a: number, b: number): number {
    try {
      return nativeModule.addNumbers(a, b);
    } catch (error) {
      console.error('NativeModule.addNumbers error:', error);
      return 0;
    }
  }

  static getVersion(): string {
    try {
      return nativeModule.getVersion();
    } catch (error) {
      console.error('NativeModule.getVersion error:', error);
      return 'Unknown';
    }
  }

  // ===================== SocketServer 接口 (PLC控制) =====================

  /**
   * 启动 SocketServer
   * @param ip 监听IP (空字符串表示监听所有)
   * @param port 监听端口
   * @param callback 数据接收回调 (clientIP, data)
   * @returns 是否启动成功
   */
  static socketServerStart(ip: string, port: number, callback: (clientIP: string, data: Uint8Array) => void): boolean {
    try {
      console.info(`[NativeModule] 尝试启动 SocketServer ${ip}:${port}`);
      const result = nativeModule.socketServerStart(ip, port, (clientIP: string, data: Uint8Array) => {
        // 在这里打印日志，方便您检查
        // console.info(`[NativeModule] SocketServer 收到来自 ${clientIP} 的数据，长度: ${data.length}`);
        
        // 调用上层回调
        if (callback) {
          callback(clientIP, data);
        }
      }) as boolean;
      console.info(`[NativeModule] SocketServer 启动结果: ${result}`);
      return result;
    } catch (error) {
      console.error('[NativeModule] socketServerStart error:', error);
      return false;
    }
  }

  /**
   * 发送数据给所有客户端
   * @param data 数据 (Uint8Array)
   * @returns 是否发送成功
   */
  static socketServerSendData(data: Uint8Array): boolean {
    try {
      console.info(`[NativeModule] SocketServer 发送数据，长度: ${data.length}`);
      return nativeModule.socketServerSendData(data);
    } catch (error) {
      console.error('[NativeModule] socketServerSendData error:', error);
      return false;
    }
  }

  /**
   * 销毁 SocketServer
   */
  static socketServerDestroy(): void {
    try {
      console.info('[NativeModule] SocketServer 销毁');
      nativeModule.socketServerDestroy();
    } catch (error) {
      console.error('[NativeModule] socketServerDestroy error:', error);
    }
  }

  // ===================== TcpClient 接口 (短连接/发送命令) =====================

  /**
   * 连接 TCP Server
   * @param ip Server IP
   * @param port Server Port
   * @param callback 数据接收回调 (data)
   * @returns 是否连接/启动成功
   */
  static tcpClientConnect(ip: string, port: number, callback: (data: Uint8Array) => void): boolean {
    try {
      console.info(`[NativeModule] TcpClient connecting to ${ip}:${port}`);
      const result = nativeModule.tcpClientConnect(ip, port, (data: Uint8Array) => {
        console.info(`[NativeModule] TcpClient received data, length: ${data.length}`);
        if (callback) {
          callback(data);
        }
      }) as boolean;
      return result;
    } catch (error) {
      console.error('[NativeModule] tcpClientConnect error:', error);
      return false;
    }
  }

  /**
   * TcpClient 发送数据
   * @param data 数据
   */
  static tcpClientSend(data: Uint8Array): boolean {
    try {
      return nativeModule.tcpClientSend(data);
    } catch (error) {
      console.error('[NativeModule] tcpClientSend error:', error);
      return false;
    }
  }

  /**
   * 销毁 TcpClient
   */
  static tcpClientDestroy(): void {
    try {
      nativeModule.tcpClientDestroy();
    } catch (error) {
      console.error('[NativeModule] tcpClientDestroy error:', error);
    }
  }

  // ===================== TcpServer 接口 (业务数据) =====================

  /**
   * 启动业务 TcpServer
   * @param ip 监听IP
   * @param port 监听端口
   * @param dstId 目标ID
   * @param callback 数据接收回调 (head)
   * @returns 是否启动成功
   */
  static tcpServerStart(ip: string, port: number, dstId: number, callback: (head: CommandHead) => void): boolean {
    try {
      console.info(`[NativeModule] TcpServer Start ${ip}:${port} dstId:${dstId}`);
      const result = nativeModule.tcpServerStart(ip, port, dstId, (head: CommandHead) => {
        console.log(`[TCP_RX_TRACE][NATIVE_CB] port=${port} cmd=0x${head.cmdId.toString(16)} src=0x${head.srcId.toString(16)} len=${head.length}`)
        if (callback) {
          callback(head);
        }
      }) as boolean;
      return result;
    } catch (error) {
      console.error('[NativeModule] tcpServerStart error:', error);
      return false;
    }
  }

  /**
   * 销毁 TcpServer
   */
  static tcpServerDestroy(): void {
    try {
      nativeModule.tcpServerDestroy();
    } catch (error) {
      console.error('[NativeModule] tcpServerDestroy error:', error);
    }
  }
}

// 导出默认实例
export default NativeModule;
