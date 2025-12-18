import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import common from '@ohos.app.ability.common';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { NetworkOptimizer } from '../utils/network/NetworkOptimizer';
import { startHttpServer, stopHttpServer, isHttpServerRunning, runHttpServerWorker } from '../utils/network/http/HttpServer';
import { taskpool } from '@kit.ArkTS';
import { HttpServerHandler } from '../utils/network/http/HttpServerHandler';
import { copyRawDirectoryAuto } from '../utils/FileUtils';
import { AppCleanup } from '../utils/lifecycle/AppCleanup';
import { ProcessingCurveFeed } from '../utils/data/ProcessingCurveFeed';
import { ProcessingBarFeed } from '../utils/data/ProcessingBarFeed';
import { MultiSeriesBarFeed } from '../utils/data/MultiSeriesBarFeed';
import { WavePhaseManager } from '../utils/ui/WavePhaseManager';
import { relationalStore } from '@kit.ArkData';
import { IBestORMInit, GetIBestORM } from '../database/orm';
import GlobalStore from '../database/orm/model/GlobalStore';
import { ProcessingHistory } from '../database/models/ProcessingHistory';
import { FruitInfo } from '../database/models/FruitInfo';
import { GradeInfo } from '../database/models/GradeInfo';
import { ExportInfo } from '../database/models/ExportInfo';
import { FarmerInfo } from '../database/models/FarmerInfo';
import { ProcessingTask } from '../database/models/ProcessingTask';
import { AlarmInfo } from '../database/models/AlarmInfo';
import { I18nManager } from '../utils/i18n/I18nManager';
import { OutletCountStorage } from '../utils/storage/OutletCountStorage';
// import { taskPoolExecuteInsert, taskPoolExecuteQuery, taskPoolExecuteUpdate, taskPoolExecuteDelete } from '../database/examples/taskpool'; // 文件已删除

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
    // 初始化自定义翻译（JSON 模式）
    I18nManager.getInstance().init(this.context).catch((e: Error | object | string) => {
      const reason = typeof e === 'string'
        ? e
        : (e instanceof Error ? e.message : JSON.stringify(e));
      hilog.warn(DOMAIN, 'EntryAbility', `I18n 初始化失败: ${reason}`);
    });
  }
  
  private async initOutletCountStorage(): Promise<void> {
    try {
      const storage = OutletCountStorage.getInstance();
      await storage.init(this.context);
      
      // 加载保存的出口数量并设置到 AppStorage
      const counts = await storage.loadAllOutletCounts();
      AppStorage.setOrCreate('OutletCount_FSM1', counts.fsm1);
      AppStorage.setOrCreate('OutletCount_FSM2', counts.fsm2);
      
      hilog.info(DOMAIN, 'EntryAbility', `出口数量已加载: FSM1=${counts.fsm1}, FSM2=${counts.fsm2}`);
    } catch (e) {
      hilog.error(DOMAIN, 'EntryAbility', `出口数量存储初始化失败: ${JSON.stringify(e)}`);
      // 使用默认值
      AppStorage.setOrCreate('OutletCount_FSM1', 20);
      AppStorage.setOrCreate('OutletCount_FSM2', 20);
    }
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
      await GlobalStore.init(this.context, {
        name: 'db_fruitsor.db',
        securityLevel: relationalStore.SecurityLevel.S2,
      });
      GetIBestORM().AutoMigrate(ProcessingHistory);
      GetIBestORM().AutoMigrate(FruitInfo);
      GetIBestORM().AutoMigrate(GradeInfo);
      GetIBestORM().AutoMigrate(ExportInfo);
      GetIBestORM().AutoMigrate(FarmerInfo);
      GetIBestORM().AutoMigrate(ProcessingTask);
      GetIBestORM().AutoMigrate(AlarmInfo);
      // 创建索引以优化查询性能
      ProcessingHistory.createIndexes();
      FruitInfo.createIndexes();
      GradeInfo.createIndexes();
      ExportInfo.createIndexes();
      FarmerInfo.createIndexes();
      ProcessingTask.createIndexes();
      AlarmInfo.createIndexes();
      hilog.info(DOMAIN, 'EntryAbility', 'ORM 初始化完成并迁移所有表');

    } catch (e) {
      hilog.error(DOMAIN, 'EntryAbility', `数据库初始化失败: ${JSON.stringify(e)}`);
    }

    // 确保出口数量存储已初始化并加载数据
    await this.initOutletCountStorage();

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

      // 注册全局键盘监听（左 Ctrl），供全局多选等功能使用
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
      const task: taskpool.Task = new taskpool.Task(runHttpServerWorker, this.context as common.Context, HTTP_SERVER_PORT);
      taskpool.execute(task);
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
  // TaskPool 示例已删除（taskpool.ets 文件已删除）
  // private async runOrmTaskpoolDemo() {
  //   const ctx = this.context as common.Context;
  //   const title = `Demo_${Date.now()}`;
  //   const a: ArticlePayload = {
  //     userImage: 'default_image_url',
  //     phone: '13800000000',
  //     name: 'DemoUser',
  //     source: 'DemoSource',
  //     title: title,
  //     contentStr: 'DemoContent',
  //     likes: 1,
  //     comments: 2,
  //     shares: 3
  //   };
  //
  //   try {
  //     await taskPoolExecuteInsert(ctx, a);
  //     hilog.info(DOMAIN, 'EntryAbility', `Demo: 插入完成 title=${title}`);
  //
  //     const list1 = await taskPoolExecuteQuery(ctx);
  //     const inserted = list1.find(item => item.Title === title);
  //     if (!inserted) {
  //       hilog.error(DOMAIN, 'EntryAbility', 'Demo: 未找到插入的数据');
  //       return;
  //     }
  //
  //     inserted.Likes = (inserted.Likes ?? 0) + 1;
  //     await taskPoolExecuteUpdate(ctx, inserted);
  //     hilog.info(DOMAIN, 'EntryAbility', `Demo: 更新完成 id=${inserted.ID} likes=${inserted.Likes}`);
  //
  //     const list2 = await taskPoolExecuteQuery(ctx);
  //     const updated = list2.find(item => item.ID === inserted.ID);
  //     hilog.info(DOMAIN, 'EntryAbility', `Demo: 校验更新 likes=${updated?.Likes}`);
  //
  //     if (inserted.ID) {
  //       await taskPoolExecuteDelete(ctx, inserted.ID);
  //       hilog.info(DOMAIN, 'EntryAbility', `Demo: 删除完成 id=${inserted.ID}`);
  //     }
  //
  //     const list3 = await taskPoolExecuteQuery(ctx);
  //     const exists = list3.some(item => item.ID === inserted.ID);
  //     hilog.info(DOMAIN, 'EntryAbility', `Demo: 删除校验 exists=${exists}`);
  //   } catch (err) {
  //     hilog.error(DOMAIN, 'EntryAbility', `Demo 执行失败: ${JSON.stringify(err)}`);
  //   }
  // }
}
