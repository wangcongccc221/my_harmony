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
import { IBestORMInit } from '@ibestservices/ibest-orm';
import { relationalStore } from '@kit.ArkData';
import { DatabaseManager } from '../database/DatabaseManager';
import { User, TestModel, ProcessingHistory } from '../database';
import { UserData, TestData, ProcessingHistoryData } from '../database/types';

const DOMAIN = 0x0000;

// HTTP 服务器端口配置
const HTTP_SERVER_PORT: number = 8080;

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

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // 初始化 IBest-ORM 数据库（必须在加载页面之前完成）
    try {
      await IBestORMInit(this.context, {
        name: "database.db",
        securityLevel: relationalStore.SecurityLevel.S1
      });
      hilog.info(DOMAIN, 'EntryAbility', 'IBest-ORM 数据库初始化完成');
      console.info('✅ IBest-ORM 数据库初始化完成');
      
      // 初始化数据库表结构
      const dbManager = DatabaseManager.getInstance();
      await dbManager.initDatabase();
      hilog.info(DOMAIN, 'EntryAbility', '数据库表结构初始化完成');
      console.info('✅ 数据库表结构初始化完成');
      
      // 测试数据库操作：查询现有数据
      console.info('📊 ========== 开始数据库查询测试 ==========');
      
      // 测试用户数据
      console.info('📋 ========== 用户数据测试 ==========');
      const existingUsers: UserData[] = dbManager.getAllUsers();
      console.info(`📋 当前数据库中的用户数量: ${existingUsers.length}`);
      if (existingUsers.length > 0) {
        console.info('📋 现有用户数据:');
        existingUsers.forEach((user: UserData, index: number) => {
          console.info(`  用户 ${index + 1}: ID=${user.id}, Name=${user.Name}, Age=${user.Age}`);
        });
      } else {
        console.info('📋 用户表为空，正在创建测试数据...');
        // 创建一些测试数据（使用实体对象传参）
        dbManager.createUser(new User("测试用户1", 25));
        dbManager.createUser(new User("测试用户2", 30));
        dbManager.createUser(new User("测试用户3", 28));
        console.info('✅ 测试数据创建完成');
        
        // 再次查询验证
        const newUsers: UserData[] = dbManager.getAllUsers();
        console.info(`📋 创建后的用户数量: ${newUsers.length}`);
        console.info('📋 所有用户数据:');
        newUsers.forEach((user: UserData, index: number) => {
          console.info(`  用户 ${index + 1}: ID=${user.id}, Name=${user.Name}, Age=${user.Age}`);
        });
        
        // 测试按年龄查询
        const age25Users: UserData[] = dbManager.getUsersByAge(25);
        console.info(`📋 年龄为25的用户数量: ${age25Users.length}`);
        
        // 测试按ID查询
        if (newUsers.length > 0 && newUsers[0].id !== undefined) {
          const firstUser: UserData | null = dbManager.getUserById(newUsers[0].id);
          if (firstUser) {
            console.info(`📋 通过ID查询到的用户: ID=${firstUser.id}, Name=${firstUser.Name}, Age=${firstUser.Age}`);
          }
        }
      }
      console.info('📋 ========== 用户数据测试完成 ==========');
      
      // 测试 TestModel 数据
      console.info('📋 ========== 测试表数据测试 ==========');
      const existingTestRecords: TestData[] = dbManager.getAllTestRecords();
      console.info(`📋 当前数据库中的测试记录数量: ${existingTestRecords.length}`);
      if (existingTestRecords.length > 0) {
        console.info('📋 现有测试记录数据:');
        existingTestRecords.forEach((record: TestData, index: number) => {
          console.info(`  记录 ${index + 1}: ID=${record.id}, Title=${record.Title}, Count=${record.Count}`);
        });
      } else {
        console.info('📋 测试表为空，正在创建测试数据...');
        // 创建一些测试数据（使用实体对象传参）
        dbManager.createTestRecord(new TestModel("测试标题1", "这是第一个测试描述", 10, 1));
        dbManager.createTestRecord(new TestModel("测试标题2", "这是第二个测试描述", 20, 1));
        dbManager.createTestRecord(new TestModel("测试标题3", "这是第三个测试描述", 30, 0));
        console.info('✅ 测试数据创建完成');
        
        // 再次查询验证
        const newTestRecords: TestData[] = dbManager.getAllTestRecords();
        console.info(`📋 创建后的测试记录数量: ${newTestRecords.length}`);
        console.info('📋 所有测试记录数据:');
        newTestRecords.forEach((record: TestData, index: number) => {
          console.info(`  记录 ${index + 1}: ID=${record.id}`);
          console.info(`    标题: ${record.Title}`);
          console.info(`    描述: ${record.Description}`);
          console.info(`    数量: ${record.Count}`);
          console.info(`    启用: ${record.IsEnabled}`);
        });
      }
      console.info('📋 ========== 测试表数据测试完成 ==========');
      
      // 测试历史加工数据
      console.info('📋 ========== 历史加工数据测试 ==========');
      const existingHistory: ProcessingHistoryData[] = dbManager.getAllProcessingHistory();
      console.info(`📋 当前数据库中的历史加工记录数量: ${existingHistory.length}`);
      if (existingHistory.length > 0) {
        console.info('📋 现有历史加工记录数据:');
        existingHistory.forEach((record: ProcessingHistoryData, index: number) => {
          console.info(`  记录 ${index + 1}: ID=${record.id}`);
          console.info(`    客户名称: ${record.CustomerName}`);
          console.info(`    农场名称: ${record.FarmName}`);
          console.info(`    水果名称: ${record.FruitName}`);
          console.info(`    状态: ${record.Status}`);
          console.info(`    开始时间: ${record.StartTime}`);
          console.info(`    结束时间: ${record.EndTime}`);
          console.info(`    重量: ${record.Weight}`);
          console.info(`    数量: ${record.Quantity}`);
        });
      } else {
        console.info('📋 历史加工表为空，正在创建测试数据...');
        // 创建一些测试数据
        const now = new Date();
        const startTime = new Date(now.getTime() - 2 * 60 * 60 * 1000); // 2小时前
        const endTime = new Date(now.getTime() - 30 * 60 * 1000); // 30分钟前
        
        const formatDateTime = (date: Date): string => {
          const year = date.getFullYear();
          const month = String(date.getMonth() + 1).padStart(2, '0');
          const day = String(date.getDate()).padStart(2, '0');
          const hours = String(date.getHours()).padStart(2, '0');
          const minutes = String(date.getMinutes()).padStart(2, '0');
          const seconds = String(date.getSeconds()).padStart(2, '0');
          return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
        };
        
        // 创建一些测试数据（使用实体对象传参）
        dbManager.createProcessingHistory(new ProcessingHistory(
          "客户A",
          "阳光农场",
          "苹果",
          "已完成",
          formatDateTime(startTime),
          formatDateTime(endTime),
          1500.5,
          100
        ));
        
        dbManager.createProcessingHistory(new ProcessingHistory(
          "客户B",
          "绿色农场",
          "橙子",
          "进行中",
          formatDateTime(now),
          "",  // 进行中的任务，结束时间为空字符串
          800.0,
          50
        ));
        
        dbManager.createProcessingHistory(new ProcessingHistory(
          "客户C",
          "丰收农场",
          "香蕉",
          "已完成",
          formatDateTime(new Date(now.getTime() - 5 * 60 * 60 * 1000)),
          formatDateTime(new Date(now.getTime() - 3 * 60 * 60 * 1000)),
          2000.0,
          200
        ));
        
        console.info('✅ 历史加工测试数据创建完成');
        
        // 再次查询验证
        const newHistory: ProcessingHistoryData[] = dbManager.getAllProcessingHistory();
        console.info(`📋 创建后的历史加工记录数量: ${newHistory.length}`);
        console.info('📋 所有历史加工记录数据:');
        newHistory.forEach((record: ProcessingHistoryData, index: number) => {
          console.info(`  记录 ${index + 1}: ID=${record.id}`);
          console.info(`    客户名称: ${record.CustomerName}`);
          console.info(`    农场名称: ${record.FarmName}`);
          console.info(`    水果名称: ${record.FruitName}`);
          console.info(`    状态: ${record.Status}`);
          console.info(`    开始时间: ${record.StartTime}`);
          console.info(`    结束时间: ${record.EndTime}`);
          console.info(`    重量: ${record.Weight}`);
          console.info(`    数量: ${record.Quantity}`);
        });
      }
      console.info('📋 ========== 历史加工数据测试完成 ==========');
      console.info('📊 ========== 数据库查询测试完成 ==========');
    } catch (e) {
      hilog.error(DOMAIN, 'EntryAbility', `数据库初始化失败: ${JSON.stringify(e)}`);
      console.error('❌ 数据库初始化失败:', e);
    }

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
    
    // 进入后台时立即停止所有定时器和动画，避免阻塞系统操作
    // 使用异步执行，避免阻塞 onBackground 回调（系统在 onBackground 中会执行帧率设置等操作）
    // 注意：必须在下一个事件循环中执行，不能在 onBackground 中同步执行，否则会阻塞系统操作
    Promise.resolve().then(() => {
      try {
        // 停止全局数据源的定时器
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
      
      // 启动HTTP服务器
      await startHttpServer(HTTP_SERVER_PORT, handler);
      
      // 标记为已初始化
      this.httpServerInitialized = true;
      hilog.info(DOMAIN, 'EntryAbility', `HTTP服务器启动成功，监听端口: ${HTTP_SERVER_PORT}`);
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
