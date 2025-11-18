import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import common from '@ohos.app.ability.common';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { NetworkOptimizer } from '../utils/network/NetworkOptimizer';
import { startHttpServer, stopHttpServer, isHttpServerRunning } from '../utils/network/http/HttpServer';
import { HttpServerHandler } from '../utils/network/http/HttpServerHandler';
import { copyRawDirectoryAuto } from '../utils/FileUtils';
import { AppCleanup } from '../utils/lifecycle/AppCleanup';
import { ProcessingCurveFeed } from '../utils/data/ProcessingCurveFeed';
import { ProcessingBarFeed } from '../utils/data/ProcessingBarFeed';
import { MultiSeriesBarFeed } from '../utils/data/MultiSeriesBarFeed';
import { WavePhaseManager } from '../utils/ui/WavePhaseManager';
import { relationalStore } from '@kit.ArkData';
import { IBestORMInit } from '../database/orm';
import { runDatabaseDemo } from '../database/examples/DatabaseDemo';
import { runPerformanceTest } from '../database/examples/PerformanceTest';

const DOMAIN = 0x0000;
const HTTP_SERVER_PORT: number = 8080;

export default class EntryAbility extends UIAbility {
  private networkOptimizer: NetworkOptimizer = NetworkOptimizer.getInstance();
  private httpServerInitialized: boolean = false; 

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');

    this.copyResourceFiles();
    this.initNetworkOptimizer();
    this.initHttpServer();
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');

    this.networkOptimizer.stop();
    
    if (isHttpServerRunning()) {
      stopHttpServer();
      this.httpServerInitialized = false; 
      hilog.info(DOMAIN, 'EntryAbility', 'HTTP服务器已停止');
    }

    AppCleanup.shutdownAll();
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    try {
      await IBestORMInit(this.context, {
        name: "database.db",
        securityLevel: relationalStore.SecurityLevel.S1
      });
      hilog.info(DOMAIN, 'EntryAbility', 'IBest-ORM 数据库初始化完成');
      
      // 运行数据库功能演示
      runDatabaseDemo().then(() => {
        hilog.info(DOMAIN, 'EntryAbility', '数据库功能演示执行完成');
      }).catch((error: Error) => {
        hilog.error(DOMAIN, 'EntryAbility', `数据库功能演示执行失败: ${JSON.stringify(error)}`);
      });
      
      // 运行性能压测（可选，需要时取消注释）
      // runPerformanceTest().then(() => {
      //   hilog.info(DOMAIN, 'EntryAbility', '性能压测执行完成');
      // }).catch((error: Error) => {
      //   hilog.error(DOMAIN, 'EntryAbility', `性能压测执行失败: ${JSON.stringify(error)}`);
      // });
      
    } catch (e) {
      hilog.error(DOMAIN, 'EntryAbility', `数据库初始化失败: ${JSON.stringify(e)}`);
    }

    windowStage.loadContent('pages/Home', async (err) => { 
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
      try {
        const mainWindow: window.Window = await windowStage.getMainWindow();
        await mainWindow.setWindowLayoutFullScreen(true);
        await mainWindow.setFullScreen(true);
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
    
    Promise.resolve().then(() => {
      try {
        // 恢复所有全局定时器和动画
        WavePhaseManager.getInstance().resume();
        
        hilog.info(DOMAIN, 'EntryAbility', '前台恢复：已恢复所有全局定时器和动画');
      } catch (e) {
        hilog.error(DOMAIN, 'EntryAbility', `前台恢复失败: ${JSON.stringify(e)}`);
      }
    });
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
    
    Promise.resolve().then(() => {
      try {
        ProcessingCurveFeed.getInstance().stop();
        ProcessingBarFeed.getInstance().stop();
        MultiSeriesBarFeed.getInstance().stop();
        WavePhaseManager.getInstance().stop();
        
        hilog.info(DOMAIN, 'EntryAbility', '后台清理：已停止所有全局定时器');
      } catch (e) {
        hilog.error(DOMAIN, 'EntryAbility', `后台清理失败: ${JSON.stringify(e)}`);
      }
    });
  }

  onStop(): void {

    hilog.info(DOMAIN, 'EntryAbility', 'onStop: 执行全局清理');
    AppCleanup.shutdownAll();
  }


  private async initNetworkOptimizer() {
    try {
      hilog.info(DOMAIN, 'EntryAbility', '开始初始化网络优化器');

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

  private async initHttpServer() {
    if (this.httpServerInitialized) {
      hilog.warn(DOMAIN, 'EntryAbility', 'HTTP服务器已经初始化过，跳过重复启动');
      return;
    }
    
    if (isHttpServerRunning()) {
      hilog.warn(DOMAIN, 'EntryAbility', 'HTTP服务器已经在运行中，跳过重复启动');
      this.httpServerInitialized = true;
      return;
    }
    
    try {
      hilog.info(DOMAIN, 'EntryAbility', '开始启动HTTP服务器');
      

      HttpServerHandler.setFileBasePath(this.context);
      
      const handler = HttpServerHandler.createRouterHandler(); // 带路由功能的处理器
      
      await startHttpServer(HTTP_SERVER_PORT, handler);
      

      this.httpServerInitialized = true;
      hilog.info(DOMAIN, 'EntryAbility', `HTTP服务器启动成功，监听端口: ${HTTP_SERVER_PORT}`);
    } catch (error) {
      hilog.error(DOMAIN, 'EntryAbility', `HTTP服务器启动失败: ${error.message}`);

      this.httpServerInitialized = false;
    }
  }

  private async copyResourceFiles() {
    try {
      hilog.info(DOMAIN, 'EntryAbility', '开始自动复制资源文件...');
      

      const result = await copyRawDirectoryAuto(
        this.context,
        'file',
        undefined,
        'file'
      );
      
      hilog.info(DOMAIN, 'EntryAbility', `资源文件复制成功: ${result.fileCount} 个文件已复制到 ${result.targetPath}`);
      hilog.info(DOMAIN, 'EntryAbility', `复制的文件列表: ${result.fileList.join(', ')}`);
    } catch (error) {
      hilog.error(DOMAIN, 'EntryAbility', `资源文件复制失败: ${error instanceof Error ? error.message : JSON.stringify(error)}`);
    }
  }
}
