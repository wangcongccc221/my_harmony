import { hilog } from '@kit.PerformanceAnalysisKit';
// import { NetworkOptimizer } from '../network/NetworkOptimizer';
// import { isHttpServerRunning, stopHttpServer } from '../network/http/HttpServer';
// import { getTcpClientManager } from '../network/tcp/TcpClientManager';

const DOMAIN = 0x0000;

export class AppCleanup {
  private static extraCleanups: Array<() => Promise<void> | void> = [];

  static register(task: () => Promise<void> | void) {
    AppCleanup.extraCleanups.push(task);
  }

  static clearRegistered() {
    AppCleanup.extraCleanups = [];
  }

  static async shutdownAll(): Promise<void> {
    hilog.info(DOMAIN, 'AppCleanup', '开始执行全局清理...');

    // 1) 停止 HTTP 服务器（若在运行）
    /*
    try {
      if (isHttpServerRunning()) {
        stopHttpServer();
        hilog.info(DOMAIN, 'AppCleanup', 'HTTP 服务器已停止');
      }
    } catch (e) {
      hilog.error(DOMAIN, 'AppCleanup', `停止 HTTP 服务器失败: ${JSON.stringify(e)}`);
    }

    // 2) 清理 TCP 客户端连接
    try {
      await getTcpClientManager().cleanup();
      hilog.info(DOMAIN, 'AppCleanup', 'TCP 客户端已清理');
    } catch (e) {
      hilog.error(DOMAIN, 'AppCleanup', `清理 TCP 客户端失败: ${JSON.stringify(e)}`);
    }

    // 3) 停止网络优化器/全局定时器
    try {
      NetworkOptimizer.getInstance().stop();
      hilog.info(DOMAIN, 'AppCleanup', '网络优化器已停止');
    } catch (e) {
      hilog.error(DOMAIN, 'AppCleanup', `停止网络优化器失败: ${JSON.stringify(e)}`);
    }
    */

    // 4) 执行注册的额外清理任务（页面/模块自定义）
    for (const task of AppCleanup.extraCleanups) {
      try {
        const ret = task();
        if (ret instanceof Promise) {
          await ret;
        }
      } catch (e) {
        hilog.error(DOMAIN, 'AppCleanup', `执行额外清理任务失败: ${JSON.stringify(e)}`);
      }
    }
    AppCleanup.clearRegistered();

    hilog.info(DOMAIN, 'AppCleanup', '全局清理完成');
  }
}


