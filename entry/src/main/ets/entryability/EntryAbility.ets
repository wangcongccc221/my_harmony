import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { taskpool, util } from '@kit.ArkTS';
import { copyRawDirectoryAuto } from '../utils/FileUtils';
import { AppCleanup } from '../utils/lifecycle/AppCleanup';
import { ProcessingCurveFeed } from '../utils/data/ProcessingCurveFeed';
import { ProcessingBarFeed } from '../utils/data/ProcessingBarFeed';
import { MultiSeriesBarFeed } from '../utils/data/MultiSeriesBarFeed';
import { WavePhaseManager } from '../utils/ui/WavePhaseManager';

import { DbManager } from '../db/DbManager';
import { I18nManager } from '../utils/i18n/I18nManager';
import { OutletCountStorage } from '../utils/storage/OutletCountStorage';
import { NativeModule, CommandHead } from '../utils/native/NativeModule';
import { getUIDataSync } from '../protocol/UIDataSync';
import { getStatisticsHandler } from '../protocol/StatisticsHandler';
import { getDatabaseSync } from '../protocol/DatabaseSync'
import { OrmDatabaseSaver } from '../protocol/OrmDatabaseSaver'
import { getGlobalDataInterface } from '../protocol/GlobalDataInterface'
import { ConstPreDefine } from '../protocol/ConstPreDefine';
import { getConfigSender, ITcpSender } from '../protocol/ConfigSender';
import { tcpSendOnce } from '../protocol/ArkTcpClient'
import { FSM_HC_COMMAND_TYPE, IPM_HC_COMMAND_TYPE, WAM_HC_COMMAND_TYPE } from '../protocol/CommandTypes'

const DOMAIN = 0x0000;
const HTTP_SERVER_PORT: number = 8080;

class TcpSenderImpl implements ITcpSender {
  async sendToDevice(deviceId: number, data: ArrayBuffer): Promise<boolean> {
    const overrideIp = AppStorage.get('MOCK_DEVICE_IP') as string | undefined
    const ip = overrideIp ?? ConstPreDefine.getIpFromId(deviceId)
    const ipmIdx = (deviceId >> 4) & 0x0F
    const overridePort = AppStorage.get('MOCK_DEVICE_PORT') as number | undefined
    const port = (overridePort !== undefined && overridePort > 0) ? overridePort : (ipmIdx > 0 ? ConstPreDefine.IPM_PORT_NUM : ConstPreDefine.FSM_PORT_NUM)
    return tcpSendOnce(ip, port, data)
  }
  async sendToAllDevices(data: ArrayBuffer): Promise<void> {
    return
  }
  isDeviceConnected(deviceId: number): boolean {
    return true
  }
}

export default class EntryAbility extends UIAbility {
  private httpServerInitialized: boolean = false; 
  private dbInitPromise: Promise<void> | null = null

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');

    // 初始化 Native 服务
    this.initNativeServers();

    // 初始化数据库配置
    this.dbInitPromise = DbManager.getInstance().init(this.context);

    // 启动 UI 数据同步服务 (连接协议层与UI层)
    this.startUIDataSync();

    // [DEBUG] 注入模拟的出口配置数据 (用于展示自定义名称和列表)
    this.injectMockExitConfig();

    this.copyResourceFiles();
    // this.initNetworkOptimizer();
    // this.initHttpServer();
    // 初始化自定义翻译（JSON 模式）
    I18nManager.getInstance().init(this.context).catch((e: Error | object | string) => {
      const reason = typeof e === 'string'
        ? e
        : (e instanceof Error ? e.message : JSON.stringify(e));
      hilog.warn(DOMAIN, 'EntryAbility', `I18n 初始化失败: ${reason}`);
    });
  }
  
  /**
   * 初始化 Native 服务
   * 启动 SocketServer (PLC) 和 TcpServer (业务)
   */
  private initNativeServers(): void {
    try {
      console.info('========== 开始初始化 Native 服务 ==========');

      // 1. 启动 SocketServer (PLC控制) - 端口 8080
      console.info('🚀 [SocketServer] 尝试启动 (PLC)...');
      const socketSuccess = NativeModule.socketServerStart("", 8080, (clientIP, data) => {
        const dataLen = data.length;
        console.info(`📡 [SocketServer] 收到数据 | 来自: ${clientIP} | 长度: ${dataLen}`);
        try {
          const bytes = data instanceof Uint8Array ? data : new Uint8Array(data)
          const decoder = new util.TextDecoder()
          const cmd = decoder.decodeWithStream(bytes).trim()
          if (cmd === 'END_CLEAR' || cmd === 'END_SAVE') {
            Promise.resolve().then(async () => {
              const dbSync = getDatabaseSync()
              const gdi = getGlobalDataInterface()
              await dbSync.saveNow()
              const ok = await dbSync.endCurrentBatch()
              if (ok) {
                gdi.stopProcessing()
                gdi.clearData()
              }
            })
          }
        } catch (_) {}
      });
      
      if (socketSuccess) {
        console.info('✅ [SocketServer] 启动成功 (Port: 8080)');
      } else {
        console.error('❌ [SocketServer] 启动失败');
      }


      console.info('🚀 [TcpServer] 尝试启动 (业务)...');

      const tcpSuccess = NativeModule.tcpServerStart("", ConstPreDefine.HC_PORT2_NUM, ConstPreDefine.HC_ID, (head: CommandHead) => {
        if (!head || !head.data) {
          return
        }
        // 统计服务：只处理 FSM/WAM 统计相关命令
        const isFsmCmd = head.cmdId >= FSM_HC_COMMAND_TYPE.FSM_CMD_CONFIG &&
          head.cmdId <= FSM_HC_COMMAND_TYPE.FSM_CMD_BOOT_FLASH_PROGRESS
        const isWamCmd = head.cmdId >= WAM_HC_COMMAND_TYPE.WAM__CMD_WEIGHT_INFO &&
          head.cmdId <= WAM_HC_COMMAND_TYPE.WAM_CMD_REP_WAM_INFO
        if (isFsmCmd || isWamCmd) {
          getStatisticsHandler().handleSplitMessage(head.cmdId, head.srcId, head.data);
        } else {
          console.warn(`[TcpServer-Stat] 忽略非统计命令 cmd=0x${head.cmdId.toString(16)} src=0x${head.srcId.toString(16)}`)
        }
      });

      if (tcpSuccess) {
        console.info(`✅ [TcpServer] 启动成功 (Port: ${ConstPreDefine.HC_PORT2_NUM})`);
      } else {
        console.error('❌ [TcpServer] 启动失败');
      }

      console.info('🚀 [TcpServer-Image] 尝试启动 (图像)...');
      const tcpImageSuccess = NativeModule.tcpServerStart("", ConstPreDefine.HC_PORT1_NUM, ConstPreDefine.HC_ID, (head: CommandHead) => {
        if (!head || !head.data) {
          return
        }
        const isIpmImageCmd = head.cmdId >= IPM_HC_COMMAND_TYPE.IPM_CMD_IMAGE &&
          head.cmdId <= IPM_HC_COMMAND_TYPE.IPM_CMD_SHUTTER_ADJUST
        if (isIpmImageCmd) {
          console.info(`[TcpServer-Image] 收到图像链路命令 cmd=0x${head.cmdId.toString(16)} src=0x${head.srcId.toString(16)} len=${head.length}`)
          // 预留：后续在这里接入图像解析/显示流程
        } else {
          console.warn(`[TcpServer-Image] 忽略非图像命令 cmd=0x${head.cmdId.toString(16)} src=0x${head.srcId.toString(16)}`)
        }
      });
      if (tcpImageSuccess) {
        console.info(`✅ [TcpServer-Image] 启动成功 (Port: ${ConstPreDefine.HC_PORT1_NUM})`);
      } else {
        console.error('❌ [TcpServer-Image] 启动失败');
      }

      const tcpSender = new TcpSenderImpl()
      getConfigSender().setTcpSender(tcpSender)
      
      // 3. (可选) TcpClient 连接示例
      // 如果需要在启动时连接某个服务器，可以在这里调用
      /*
      NativeModule.tcpClientConnect("192.168.1.100", 8888, (data) => {
        console.info(`[TcpClient] 收到数据: ${data.length}`);
      });
      */

      console.info('========== Native 服务初始化完成 ==========');
    } catch (error) {
      console.error('❌ Native 服务初始化失败:', error);
    }
  }
  
  /**
   * [DEBUG] 注入模拟的出口配置数据
   */
  private injectMockExitConfig(): void {
    try {
      console.info('========== [DEBUG] 注入模拟出口配置 ==========');
      
      const mockNames = ['特级果', '一级果', '二级果', '三级果', '等外果'];
      const mockCriteria = [
        ['重量>250g', '糖度>15', '无瑕疵'],
        ['重量>200g', '糖度>13', '微瑕疵'],
        ['重量>150g', '糖度>11'],
        ['重量>100g'],
        ['重量<100g', '严重瑕疵']
      ];

      for (let i = 0; i < 20; i++) {
        // 1. 设置自定义名称
        const nameIndex = i % mockNames.length;
        const customName = `${mockNames[nameIndex]} (${i + 1}号)`;
        AppStorage.setOrCreate(`EXIT_NAME_${i + 1}`, customName);

        // 2. 设置列表内容
        const criteria = mockCriteria[nameIndex];
        AppStorage.setOrCreate(`EXIT_ITEMS_${i + 1}`, criteria);
        
      }
      
      console.info('✅ 模拟出口配置注入完成');
    } catch (e) {
      console.error('❌ 模拟配置注入失败:', e);
    }
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

    // this.networkOptimizer.stop();
    
    /*
    if (isHttpServerRunning()) {
      stopHttpServer();
      this.httpServerInitialized = false; 
      hilog.info(DOMAIN, 'EntryAbility', 'HTTP服务器已停止');
    }
    */

    AppCleanup.shutdownAll();
  }
  
  /**
   * 启动 UI 数据同步服务
   * 将协议层的下位机数据同步到 UI 组件
   */
  private startUIDataSync(): void {
    try {
      const uiDataSync = getUIDataSync();
      uiDataSync.start();
      hilog.info(DOMAIN, 'EntryAbility', 'UI数据同步服务已启动');
    } catch (e) {
      hilog.error(DOMAIN, 'EntryAbility', `UI数据同步服务启动失败: ${JSON.stringify(e)}`);
    }
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    try {
      if (this.dbInitPromise) {
        await this.dbInitPromise
      }
      const dbSync = getDatabaseSync()
      dbSync.setDatabaseSaver(new OrmDatabaseSaver())
      dbSync.start()
      dbSync.enableAutoSave(5000)
      /*
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
      */

    } catch (e) {
      hilog.error(DOMAIN, 'EntryAbility', `数据库初始化失败: ${JSON.stringify(e)}`);
    }

    // 确保出口数量存储已初始化并加载数据
    await this.initOutletCountStorage();

    // 启动 UI 数据同步服务 - 将下位机数据同步到 UI
    this.startUIDataSync();

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
    // AppCleanup.shutdownAll();
  }


  private async initNetworkOptimizer() {
    /*
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
    */
  }

  private async initHttpServer() {
    /*
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
    */
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
