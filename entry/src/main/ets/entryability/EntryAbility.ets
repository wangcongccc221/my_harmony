import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { NetworkOptimizer } from '../utils/network/NetworkOptimizer';
import { startHttpServer, stopHttpServer, isHttpServerRunning } from '../utils/network/HttpServer';
import { ArkDataDemoService } from '../db/ArkDataDemo';
import { HttpServerHandler } from '../utils/network/HttpServerHandler';
import { copyRawDirectoryAuto } from '../utils/FileUtils';
import { AppCleanup } from '../utils/AppCleanup';

const DOMAIN = 0x0000;


export default class EntryAbility extends UIAbility {
  private networkOptimizer: NetworkOptimizer = NetworkOptimizer.getInstance();
  private httpServerInitialized: boolean = false; // 标记 HTTP 服务器是否已初始化

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');

    // 复制资源文件到存储目录（应用启动时执行一次）
    this.copyResourceFiles();
    
    // 初始化网络优化器
    this.initNetworkOptimizer();
    
    // 初始化数据库（RDB）
    try {
      ArkDataDemoService.init(this.context);
      // 可选：预建演示表
      ArkDataDemoService.createUsersTable().then(() => {
        hilog.info(DOMAIN, 'EntryAbility', 'RDB users table ready');
      }, (e: object) => {
        hilog.error(DOMAIN, 'EntryAbility', `RDB users table error: ${JSON.stringify(e)}`);
      });
      // 预建加工历史表并预热缓存
      ArkDataDemoService.createProcessingHistoryTable().then(() => {
        hilog.info(DOMAIN, 'EntryAbility', 'RDB processing table ready');
        // 触发一次缓存预热
        try {
          ArkDataDemoService.queryAllProcessing().then((rows) => {
            // 调用 Handler 的静态属性进行预热
            // 这里无法直接写入私有属性，交给 Handler 自己在首次访问时加载
            hilog.info(DOMAIN, 'EntryAbility', `processing preload size=${rows.length}`);
          }, () => {});
        } catch (_) {}
      }, (e: object) => {
        hilog.error(DOMAIN, 'EntryAbility', `RDB processing table error: ${JSON.stringify(e)}`);
      });
    } catch (error) {
      const err = error as object;
      hilog.error(DOMAIN, 'EntryAbility', `RDB init failed: ${JSON.stringify(err)}`);
    }

    // 启动HTTP服务器
    this.initHttpServer();
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'tes`tTag', '%{public}s', 'Ability onDestroy');

    // 停止网络优化器
    this.networkOptimizer.stop();
    
    // 停止HTTP服务器（如果正在运行）
    if (isHttpServerRunning()) {
      stopHttpServer();
      this.httpServerInitialized = false; // 重置标记
      hilog.info(DOMAIN, 'EntryAbility', 'HTTP服务器已停止');
    }

    // 统一清理（兜底）
    AppCleanup.shutdownAll();
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

  onStop(): void {
    // Ability 停止前做统一清理（网络/定时器/连接）
    hilog.info(DOMAIN, 'EntryAbility', 'onStop: 执行全局清理');
    // 同步触发清理（无需 await，避免阻塞生命周期）
    // 如需严格确保完成，可改为 async 并 await。
    AppCleanup.shutdownAll();
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

  // 初始化HTTP服务器（确保只执行一次）
  private async initHttpServer() {
    // 防止重复启动：检查是否已初始化或已在运行
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
      
      // 设置文件浏览基础路径
      HttpServerHandler.setFileBasePath(this.context);
      
      // 使用HttpServerHandler创建处理器
      // 可以选择使用默认处理器或路由处理器
      // const handler = HttpServerHandler.createHandler(); // 简单处理器
      const handler = HttpServerHandler.createRouterHandler(); // 带路由功能的处理器
      
      // 启动HTTP服务器，监听8080端口
      await startHttpServer(8080, handler);
      
      // 标记为已初始化
      this.httpServerInitialized = true;
      hilog.info(DOMAIN, 'EntryAbility', 'HTTP服务器启动成功，监听端口: 8080');
    } catch (error) {
      hilog.error(DOMAIN, 'EntryAbility', `HTTP服务器启动失败: ${error.message}`);
      // 启动失败时重置标记，允许下次重试
      this.httpServerInitialized = false;
    }
  }

  // 复制资源文件到存储目录（自动遍历整个目录）
  private async copyResourceFiles() {
    try {
      hilog.info(DOMAIN, 'EntryAbility', '开始自动复制资源文件...');
      
      // 使用自动遍历功能，无需手动维护文件列表
      // 会自动扫描 rawfile/file 目录下的所有文件（包括子目录）
      const result = await copyRawDirectoryAuto(
        this.context,
        'file',           // rawfile 中的文件夹路径
        undefined,         // 使用配置中的默认路径
        'file'             // 目标文件夹名（可选，默认使用原文件夹名）
      );
      
      hilog.info(DOMAIN, 'EntryAbility', `资源文件复制成功: ${result.fileCount} 个文件已复制到 ${result.targetPath}`);
      hilog.info(DOMAIN, 'EntryAbility', `复制的文件列表: ${result.fileList.join(', ')}`);
    } catch (error) {
      hilog.error(DOMAIN, 'EntryAbility', `资源文件复制失败: ${error instanceof Error ? error.message : JSON.stringify(error)}`);
    }
  }
}