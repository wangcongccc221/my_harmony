import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { NetworkOptimizer } from '../utils/network/NetworkOptimizer';
import { startHttpServer, stopHttpServer } from '../utils/network/HttpServer';
import { HttpServerHandler } from '../utils/network/HttpServerHandler';

const DOMAIN = 0x0000;


export default class EntryAbility extends UIAbility {
  private networkOptimizer: NetworkOptimizer = NetworkOptimizer.getInstance();

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');

    // 初始化网络优化器
    this.initNetworkOptimizer();
    
    // 启动HTTP服务器
    this.initHttpServer();
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'tes`tTag', '%{public}s', 'Ability onDestroy');

    // 停止网络优化器
    this.networkOptimizer.stop();
    
    // 停止HTTP服务器
    stopHttpServer();
    hilog.info(DOMAIN, 'EntryAbility', 'HTTP服务器已停止');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Home', async (err) => { // 修改进入的主页
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
      try {
        const mainWindow: window.Window = await windowStage.getMainWindow();
        // 全屏布局，隐藏系统标题栏
        await mainWindow.setWindowLayoutFullScreen(true);
        await mainWindow.setFullScreen(true);
        //（如需进一步隐藏状态/导航栏，可在确认 SDK API 后再开启）
      } catch (e) {
        hilog.error(DOMAIN, 'testTag', `set non-fullscreen failed: ${JSON.stringify(e)}`);
      }
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }

   // 初始化网络优化器
  private async initNetworkOptimizer() {
    try {
      hilog.info(DOMAIN, 'EntryAbility', '开始初始化网络优化器');

      // 初始化网络优化器
      const success = await this.networkOptimizer.initialize();
      if (success) {
        hilog.info(DOMAIN, 'EntryAbility', '网络优化器初始化成功');
      } else {
        hilog.error(DOMAIN, 'EntryAbility', '网络优化器初始化失败');
      }
    } catch (error) {
      hilog.error(DOMAIN, 'EntryAbility', `网络优化器初始化异常: ${error.message}`);
    }
  }

  // 初始化HTTP服务器
  private async initHttpServer() {
    try {
      hilog.info(DOMAIN, 'EntryAbility', '开始启动HTTP服务器');
      
      // 使用HttpServerHandler创建处理器
      // 可以选择使用默认处理器或路由处理器
      // const handler = HttpServerHandler.createHandler(); // 简单处理器
      const handler = HttpServerHandler.createRouterHandler(); // 带路由功能的处理器
      
      // 启动HTTP服务器，监听8080端口
      await startHttpServer(8080, handler);
      hilog.info(DOMAIN, 'EntryAbility', 'HTTP服务器启动成功，监听端口: 8080');
    } catch (error) {
      hilog.error(DOMAIN, 'EntryAbility', `HTTP服务器启动失败: ${error.message}`);
    }
  }
}