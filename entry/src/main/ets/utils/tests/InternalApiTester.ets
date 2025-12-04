import { Context } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { FruitInfoService } from '../../database/services/FruitInfoService';
import { GradeInfoService } from '../../database/services/GradeInfoService';
import { ExportInfoService } from '../../database/services/ExportInfoService';
import { FruitInfo } from '../../database/models/FruitInfo';
import { GradeInfo } from '../../database/models/GradeInfo';
import { ExportInfo } from '../../database/models/ExportInfo';

const DOMAIN = 0x0000;
const TAG = 'InternalApiTester';

export class InternalApiTester {
  /**
   * 运行全部测试
   */
  static async runAll(ctx: Context): Promise<void> {
    hilog.info(DOMAIN, TAG, '--- 开始内部API测试 ---');
    
    try {
      await InternalApiTester.testFruitInfo(ctx);
    } catch (e) {
      const err = e as Error;
      hilog.error(DOMAIN, TAG, `FruitInfoService 测试失败: ${err.message}`);
    }
    await FruitInfoService.delete(2,ctx);
    try {
      await InternalApiTester.testGradeInfo(ctx);
    } catch (e) {
      const err = e as Error;
      hilog.error(DOMAIN, TAG, `GradeInfoService 测试失败: ${err.message}`);
    }
    
    try {
      await InternalApiTester.testExportInfo(ctx);
    } catch (e) {
      const err = e as Error;
      hilog.error(DOMAIN, TAG, `ExportInfoService 测试失败: ${err.message}`);
    }
    
    hilog.info(DOMAIN, TAG, '--- 内部API测试完成 ---');
  }

  /**
   * 测试水果信息服务
   */
  static async testFruitInfo(ctx: Context): Promise<void> {
    hilog.info(DOMAIN, TAG, '开始测试 FruitInfoService');

    const testData = new FruitInfo();
    testData.FruitName = '内部测试水果';
    testData.CustomerName = '内部测试客户';
    testData.BatchWeight = 111.11;
    testData.BatchNumber = 11;
    testData.SortType = 1;
    testData.ProgramName = 'InternalTestProgram';

    const id = await FruitInfoService.save(testData, ctx);
    hilog.info(DOMAIN, TAG, `FruitInfoService.save 成功，ID=${id}`);

    const list = await FruitInfoService.queryAll(ctx);
    hilog.info(DOMAIN, TAG, `FruitInfoService.queryAll 返回 ${list.length} 条记录`);

    await FruitInfoService.delete(id, ctx);
    hilog.info(DOMAIN, TAG, `FruitInfoService.delete 删除 ID=${id}`);
  }

  /**
   * 测试等级信息服务
   */
  static async testGradeInfo(ctx: Context): Promise<void> {
    hilog.info(DOMAIN, TAG, '开始测试 GradeInfoService');

    const testData = new GradeInfo();
    testData.CustomerID = 2001;
    testData.ChannelID = 1;
    testData.QualityIndex = 1;
    testData.SizeID = 1;
    testData.SizeIndex = 1;
    testData.BoxNumber = 5;
    testData.FruitNumber = 50;
    testData.FruitWeight = 25.5;
    testData.FPrice = 9.99;
    testData.GradeID = 1;
    testData.QualityName = '内部测试等级';

    const id = await GradeInfoService.save(testData, ctx);
    hilog.info(DOMAIN, TAG, `GradeInfoService.save 成功，ID=${id}`);

    const list = await GradeInfoService.queryAll(ctx);
    hilog.info(DOMAIN, TAG, `GradeInfoService.queryAll 返回 ${list.length} 条记录`);

    await GradeInfoService.delete(id, ctx);
    hilog.info(DOMAIN, TAG, `GradeInfoService.delete 删除 ID=${id}`);
  }

  /**
   * 测试导出信息服务
   */
  static async testExportInfo(ctx: Context): Promise<void> {
    hilog.info(DOMAIN, TAG, '开始测试 ExportInfoService');

    const testData = new ExportInfo();
    testData.CustomerID = 3001;
    testData.ChannelID = 1;
    testData.ExportID = 100;
    testData.FruitNumber = 60;
    testData.FruitWeight = 30.5;
    testData.BoxNumber = 6;
    testData.ExitName = '内部测试出口';

    const id = await ExportInfoService.save(testData, ctx);
    hilog.info(DOMAIN, TAG, `ExportInfoService.save 成功，ID=${id}`);

    const list = await ExportInfoService.queryAll(ctx);
    hilog.info(DOMAIN, TAG, `ExportInfoService.queryAll 返回 ${list.length} 条记录`);

    await ExportInfoService.delete(id, ctx);
    hilog.info(DOMAIN, TAG, `ExportInfoService.delete 删除 ID=${id}`);
  }
}

