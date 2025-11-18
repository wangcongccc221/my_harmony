/**
 * 数据库性能压测
 * 重点测试：字段数量对性能的影响
 */
import { GetIBestORM } from '../orm';
import { Table, Field, FieldType, Model } from '../orm';
import { relationalStore } from '@kit.ArkData';
import { PerformanceTestState, CompleteTestResults, TestSummary, TestConclusions, PerformanceResult } from '../../utils/network/http/handlers/PerformanceApiHandler';

/**
 * 窄表模型（10个字段）
 */
@Table
export class NarrowTable extends Model {
  @Field({ type: FieldType.TEXT })
  field1?: string;
  
  @Field({ type: FieldType.TEXT })
  field2?: string;
  
  @Field({ type: FieldType.TEXT })
  field3?: string;
  
  @Field({ type: FieldType.TEXT })
  field4?: string;
  
  @Field({ type: FieldType.TEXT })
  field5?: string;
  
  @Field({ type: FieldType.INTEGER })
  field6?: number;
  
  @Field({ type: FieldType.INTEGER })
  field7?: number;
  
  @Field({ type: FieldType.INTEGER })
  field8?: number;
  
  @Field({ type: FieldType.REAL })
  field9?: number;
  
  @Field({ type: FieldType.REAL })
  field10?: number;
}

/**
 * 宽表模型（50个字段）
 */
@Table
export class WideTable extends Model {
  @Field({ type: FieldType.TEXT })
  field1?: string;
  
  @Field({ type: FieldType.TEXT })
  field2?: string;
  
  @Field({ type: FieldType.TEXT })
  field3?: string;
  
  @Field({ type: FieldType.TEXT })
  field4?: string;
  
  @Field({ type: FieldType.TEXT })
  field5?: string;
  
  @Field({ type: FieldType.TEXT })
  field6?: string;
  
  @Field({ type: FieldType.TEXT })
  field7?: string;
  
  @Field({ type: FieldType.TEXT })
  field8?: string;
  
  @Field({ type: FieldType.TEXT })
  field9?: string;
  
  @Field({ type: FieldType.TEXT })
  field10?: string;
  
  @Field({ type: FieldType.TEXT })
  field11?: string;
  
  @Field({ type: FieldType.TEXT })
  field12?: string;
  
  @Field({ type: FieldType.TEXT })
  field13?: string;
  
  @Field({ type: FieldType.TEXT })
  field14?: string;
  
  @Field({ type: FieldType.TEXT })
  field15?: string;
  
  @Field({ type: FieldType.TEXT })
  field16?: string;
  
  @Field({ type: FieldType.TEXT })
  field17?: string;
  
  @Field({ type: FieldType.TEXT })
  field18?: string;
  
  @Field({ type: FieldType.TEXT })
  field19?: string;
  
  @Field({ type: FieldType.TEXT })
  field20?: string;
  
  @Field({ type: FieldType.TEXT })
  field21?: string;
  
  @Field({ type: FieldType.TEXT })
  field22?: string;
  
  @Field({ type: FieldType.TEXT })
  field23?: string;
  
  @Field({ type: FieldType.TEXT })
  field24?: string;
  
  @Field({ type: FieldType.TEXT })
  field25?: string;
  
  @Field({ type: FieldType.TEXT })
  field26?: string;
  
  @Field({ type: FieldType.TEXT })
  field27?: string;
  
  @Field({ type: FieldType.TEXT })
  field28?: string;
  
  @Field({ type: FieldType.TEXT })
  field29?: string;
  
  @Field({ type: FieldType.TEXT })
  field30?: string;
  
  @Field({ type: FieldType.TEXT })
  field31?: string;
  
  @Field({ type: FieldType.TEXT })
  field32?: string;
  
  @Field({ type: FieldType.TEXT })
  field33?: string;
  
  @Field({ type: FieldType.TEXT })
  field34?: string;
  
  @Field({ type: FieldType.TEXT })
  field35?: string;
  
  @Field({ type: FieldType.TEXT })
  field36?: string;
  
  @Field({ type: FieldType.TEXT })
  field37?: string;
  
  @Field({ type: FieldType.TEXT })
  field38?: string;
  
  @Field({ type: FieldType.TEXT })
  field39?: string;
  
  @Field({ type: FieldType.TEXT })
  field40?: string;
  
  @Field({ type: FieldType.INTEGER })
  field41?: number;
  
  @Field({ type: FieldType.INTEGER })
  field42?: number;
  
  @Field({ type: FieldType.INTEGER })
  field43?: number;
  
  @Field({ type: FieldType.INTEGER })
  field44?: number;
  
  @Field({ type: FieldType.INTEGER })
  field45?: number;
  
  @Field({ type: FieldType.REAL })
  field46?: number;
  
  @Field({ type: FieldType.REAL })
  field47?: number;
  
  @Field({ type: FieldType.REAL })
  field48?: number;
  
  @Field({ type: FieldType.REAL })
  field49?: number;
  
  @Field({ type: FieldType.REAL })
  field50?: number;
}


/**
 * 运行性能测试
 */
export async function runPerformanceTest(): Promise<void> {
  const db = GetIBestORM();
  const state = PerformanceTestState.getInstance();
  const results: PerformanceResult[] = [];
  
  console.info('========== 数据库性能压测开始 ==========');
  console.info('测试目标：验证字段数量对性能的影响\n');
  
  state.setProgress('初始化表结构...');
  // 初始化表
  db.AutoMigrate(NarrowTable);
  db.AutoMigrate(WideTable);
  console.info('表结构初始化完成\n');
  
  state.setProgress('清空测试数据...');
  // 清空测试数据
  db.Table('narrow_table').Delete();
  db.Table('wide_table').Delete();
  
  const testDataCount = 10000; // 测试数据量（增加到10000条）
  
  // ========== 1. 基准测试：插入性能对比 ==========
  state.setProgress('执行基准测试：插入性能对比...');
  console.info('【1. 基准测试 - 插入性能对比】');
  
  // 窄表插入
  const narrowInsertStart = Date.now();
  const narrowData: NarrowTable[] = [];
  for (let i = 0; i < testDataCount; i++) {
    const record = new NarrowTable();
    record.field1 = `value1_${i}`;
    record.field2 = `value2_${i}`;
    record.field3 = `value3_${i}`;
    record.field4 = `value4_${i}`;
    record.field5 = `value5_${i}`;
    record.field6 = i;
    record.field7 = i * 2;
    record.field8 = i * 3;
    record.field9 = i * 1.5;
    record.field10 = i * 2.5;
    narrowData.push(record);
  }
  await db.Create(narrowData);
  const narrowInsertTime = Date.now() - narrowInsertStart;
  
  // 宽表插入
  const wideInsertStart = Date.now();
  const wideData: WideTable[] = [];
  for (let i = 0; i < testDataCount; i++) {
    const record = new WideTable();
    record.field1 = `value1_${i}`;
    record.field2 = `value2_${i}`;
    record.field3 = `value3_${i}`;
    record.field4 = `value4_${i}`;
    record.field5 = `value5_${i}`;
    record.field6 = `value6_${i}`;
    record.field7 = `value7_${i}`;
    record.field8 = `value8_${i}`;
    record.field9 = `value9_${i}`;
    record.field10 = `value10_${i}`;
    record.field11 = `value11_${i}`;
    record.field12 = `value12_${i}`;
    record.field13 = `value13_${i}`;
    record.field14 = `value14_${i}`;
    record.field15 = `value15_${i}`;
    record.field16 = `value16_${i}`;
    record.field17 = `value17_${i}`;
    record.field18 = `value18_${i}`;
    record.field19 = `value19_${i}`;
    record.field20 = `value20_${i}`;
    record.field21 = `value21_${i}`;
    record.field22 = `value22_${i}`;
    record.field23 = `value23_${i}`;
    record.field24 = `value24_${i}`;
    record.field25 = `value25_${i}`;
    record.field26 = `value26_${i}`;
    record.field27 = `value27_${i}`;
    record.field28 = `value28_${i}`;
    record.field29 = `value29_${i}`;
    record.field30 = `value30_${i}`;
    record.field31 = `value31_${i}`;
    record.field32 = `value32_${i}`;
    record.field33 = `value33_${i}`;
    record.field34 = `value34_${i}`;
    record.field35 = `value35_${i}`;
    record.field36 = `value36_${i}`;
    record.field37 = `value37_${i}`;
    record.field38 = `value38_${i}`;
    record.field39 = `value39_${i}`;
    record.field40 = `value40_${i}`;
    record.field41 = i * 1;
    record.field42 = i * 2;
    record.field43 = i * 3;
    record.field44 = i * 4;
    record.field45 = i * 5;
    record.field46 = i * 6;
    record.field47 = i * 7;
    record.field48 = i * 8;
    record.field49 = i * 9;
    record.field50 = i * 10;
    wideData.push(record);
  }
  await db.Create(wideData);
  const wideInsertTime = Date.now() - wideInsertStart;
  
  results.push({
    testName: '插入测试',
    tableType: 'narrow',
    operation: 'INSERT',
    count: testDataCount,
    totalTime: narrowInsertTime,
    avgTime: narrowInsertTime / testDataCount,
    qps: (testDataCount / narrowInsertTime) * 1000,
    tps: (testDataCount / narrowInsertTime) * 1000
  });
  
  results.push({
    testName: '插入测试',
    tableType: 'wide',
    operation: 'INSERT',
    count: testDataCount,
    totalTime: wideInsertTime,
    avgTime: wideInsertTime / testDataCount,
    qps: (testDataCount / wideInsertTime) * 1000,
    tps: (testDataCount / wideInsertTime) * 1000
  });
  
  console.info(`窄表插入 ${testDataCount} 条: ${narrowInsertTime}ms, 平均 ${(narrowInsertTime / testDataCount).toFixed(2)}ms/条, QPS: ${((testDataCount / narrowInsertTime) * 1000).toFixed(2)}`);
  console.info(`宽表插入 ${testDataCount} 条: ${wideInsertTime}ms, 平均 ${(wideInsertTime / testDataCount).toFixed(2)}ms/条, QPS: ${((testDataCount / wideInsertTime) * 1000).toFixed(2)}`);
  console.info(`性能差异: ${((wideInsertTime / narrowInsertTime - 1) * 100).toFixed(2)}%\n`);
  
  // ========== 2. 查询少量字段 ==========
  state.setProgress('测试查询少量字段...');
  console.info('【2. 查询少量字段（SELECT field1, field2）】');
  
  const selectFewStart = Date.now();
  const narrowFew = db.Session(NarrowTable).Select(['field1', 'field2']).Find();
  const narrowFewTime = Date.now() - selectFewStart;
  
  const wideFewStart = Date.now();
  const wideFew = db.Session(WideTable).Select(['field1', 'field2']).Find();
  const wideFewTime = Date.now() - wideFewStart;
  
  results.push({
    testName: '查询少量字段',
    tableType: 'narrow',
    operation: 'SELECT',
    count: narrowFew.length,
    totalTime: narrowFewTime,
    avgTime: narrowFewTime / narrowFew.length,
    qps: (narrowFew.length / narrowFewTime) * 1000
  });
  
  results.push({
    testName: '查询少量字段',
    tableType: 'wide',
    operation: 'SELECT',
    count: wideFew.length,
    totalTime: wideFewTime,
    avgTime: wideFewTime / wideFew.length,
    qps: (wideFew.length / wideFewTime) * 1000
  });
  
  console.info(`窄表查询少量字段: ${narrowFewTime}ms, QPS: ${((narrowFew.length / narrowFewTime) * 1000).toFixed(2)}`);
  console.info(`宽表查询少量字段: ${wideFewTime}ms, QPS: ${((wideFew.length / wideFewTime) * 1000).toFixed(2)}`);
  console.info(`性能差异: ${((wideFewTime / narrowFewTime - 1) * 100).toFixed(2)}%\n`);
  
  // ========== 3. SELECT * 查询 ==========
  state.setProgress('测试 SELECT * 查询...');
  console.info('【3. SELECT * 查询（全字段）】');
  
  const selectAllNarrowStart = Date.now();
  const narrowAll = db.Session(NarrowTable).Find();
  const narrowAllTime = Date.now() - selectAllNarrowStart;
  
  const selectAllWideStart = Date.now();
  const wideAll = db.Session(WideTable).Find();
  const wideAllTime = Date.now() - selectAllWideStart;
  
  results.push({
    testName: 'SELECT * 查询',
    tableType: 'narrow',
    operation: 'SELECT *',
    count: narrowAll.length,
    totalTime: narrowAllTime,
    avgTime: narrowAllTime / narrowAll.length,
    qps: (narrowAll.length / narrowAllTime) * 1000
  });
  
  results.push({
    testName: 'SELECT * 查询',
    tableType: 'wide',
    operation: 'SELECT *',
    count: wideAll.length,
    totalTime: wideAllTime,
    avgTime: wideAllTime / wideAll.length,
    qps: (wideAll.length / wideAllTime) * 1000
  });
  
  console.info(`窄表 SELECT *: ${narrowAllTime}ms, QPS: ${((narrowAll.length / narrowAllTime) * 1000).toFixed(2)}`);
  console.info(`宽表 SELECT *: ${wideAllTime}ms, QPS: ${((wideAll.length / wideAllTime) * 1000).toFixed(2)}`);
  console.info(`性能差异: ${((wideAllTime / narrowAllTime - 1) * 100).toFixed(2)}%\n`);
  
  // ========== 4. 全表扫描 COUNT ==========
  state.setProgress('测试全表扫描...');
  console.info('【4. 全表扫描（COUNT）】');
  
  const countNarrowStart = Date.now();
  const narrowCount = db.Session(NarrowTable).Find().length;
  const narrowCountTime = Date.now() - countNarrowStart;
  
  const countWideStart = Date.now();
  const wideCount = db.Session(WideTable).Find().length;
  const wideCountTime = Date.now() - countWideStart;
  
  results.push({
    testName: '全表扫描',
    tableType: 'narrow',
    operation: 'COUNT',
    count: narrowCount,
    totalTime: narrowCountTime,
    avgTime: narrowCountTime / narrowCount,
    qps: (narrowCount / narrowCountTime) * 1000
  });
  
  results.push({
    testName: '全表扫描',
    tableType: 'wide',
    operation: 'COUNT',
    count: wideCount,
    totalTime: wideCountTime,
    avgTime: wideCountTime / wideCount,
    qps: (wideCount / wideCountTime) * 1000
  });
  
  console.info(`窄表 COUNT: ${narrowCountTime}ms, 记录数: ${narrowCount}`);
  console.info(`宽表 COUNT: ${wideCountTime}ms, 记录数: ${wideCount}`);
  console.info(`性能差异: ${((wideCountTime / narrowCountTime - 1) * 100).toFixed(2)}%\n`);
  
  // ========== 5. 更新操作 ==========
  state.setProgress('测试更新操作...');
  console.info('【5. 更新操作性能对比】');
  
  const updateNarrowStart = Date.now();
  const updateNarrowCount = db.Session(NarrowTable)
    .Where('field1', 'value1_0')
    .Update({ field2: 'updated_value' });
  const updateNarrowTime = Date.now() - updateNarrowStart;
  
  const updateWideStart = Date.now();
  const updateWideCount = db.Session(WideTable)
    .Where('field1', 'value1_0')
    .Update({ field2: 'updated_value' });
  const updateWideTime = Date.now() - updateWideStart;
  
  results.push({
    testName: '更新操作',
    tableType: 'narrow',
    operation: 'UPDATE',
    count: updateNarrowCount,
    totalTime: updateNarrowTime,
    avgTime: updateNarrowTime / updateNarrowCount,
    qps: (updateNarrowCount / updateNarrowTime) * 1000
  });
  
  results.push({
    testName: '更新操作',
    tableType: 'wide',
    operation: 'UPDATE',
    count: updateWideCount,
    totalTime: updateWideTime,
    avgTime: updateWideTime / updateWideCount,
    qps: (updateWideCount / updateWideTime) * 1000
  });
  
  console.info(`窄表更新: ${updateNarrowTime}ms, 更新 ${updateNarrowCount} 条`);
  console.info(`宽表更新: ${updateWideTime}ms, 更新 ${updateWideCount} 条`);
  console.info(`性能差异: ${((updateWideTime / updateNarrowTime - 1) * 100).toFixed(2)}%\n`);
  
  // ========== 6. 并发测试 ==========
  state.setProgress('测试并发查询...');
  console.info('【6. 并发测试（模拟多用户同时读写）】');
  
  const concurrentCount = 50; // 并发数增加到50
  const concurrentNarrowStart = Date.now();
  const narrowPromises: Promise<Record<string, relationalStore.ValueType>[]>[] = [];
  for (let i = 0; i < concurrentCount; i++) {
    const index = i;
    narrowPromises.push(
      Promise.resolve().then((): Record<string, relationalStore.ValueType>[] => {
        return db.Session(NarrowTable).Where('field6', index % 100).Find();
      })
    );
  }
  await Promise.all(narrowPromises);
  const concurrentNarrowTime = Date.now() - concurrentNarrowStart;
  
  const concurrentWideStart = Date.now();
  const widePromises: Promise<Record<string, relationalStore.ValueType>[]>[] = [];
  for (let i = 0; i < concurrentCount; i++) {
    const index = i;
    widePromises.push(
      Promise.resolve().then((): Record<string, relationalStore.ValueType>[] => {
        return db.Session(WideTable).Where('field41', index % 100).Find();
      })
    );
  }
  await Promise.all(widePromises);
  const concurrentWideTime = Date.now() - concurrentWideStart;
  
  results.push({
    testName: '并发查询',
    tableType: 'narrow',
    operation: 'CONCURRENT',
    count: concurrentCount,
    totalTime: concurrentNarrowTime,
    avgTime: concurrentNarrowTime / concurrentCount,
    qps: (concurrentCount / concurrentNarrowTime) * 1000
  });
  
  results.push({
    testName: '并发查询',
    tableType: 'wide',
    operation: 'CONCURRENT',
    count: concurrentCount,
    totalTime: concurrentWideTime,
    avgTime: concurrentWideTime / concurrentCount,
    qps: (concurrentCount / concurrentWideTime) * 1000
  });
  
  console.info(`窄表并发查询（${concurrentCount}个）: ${concurrentNarrowTime}ms`);
  console.info(`宽表并发查询（${concurrentCount}个）: ${concurrentWideTime}ms`);
  console.info(`性能差异: ${((concurrentWideTime / concurrentNarrowTime - 1) * 100).toFixed(2)}%\n`);
  
  // ========== 7. 压力测试 ==========
  state.setProgress('执行压力测试...');
  console.info('【7. 压力测试（大量查询）】');
  
  const stressCount = 1000; // 压力测试次数增加到1000次
  const stressNarrowStart = Date.now();
  for (let i = 0; i < stressCount; i++) {
    db.Session(NarrowTable).Where('field6', i % 100).First();
  }
  const stressNarrowTime = Date.now() - stressNarrowStart;
  
  const stressWideStart = Date.now();
  for (let i = 0; i < stressCount; i++) {
    db.Session(WideTable).Where('field41', i % 100).First();
  }
  const stressWideTime = Date.now() - stressWideStart;
  
  results.push({
    testName: '压力测试',
    tableType: 'narrow',
    operation: 'STRESS',
    count: stressCount,
    totalTime: stressNarrowTime,
    avgTime: stressNarrowTime / stressCount,
    qps: (stressCount / stressNarrowTime) * 1000
  });
  
  results.push({
    testName: '压力测试',
    tableType: 'wide',
    operation: 'STRESS',
    count: stressCount,
    totalTime: stressWideTime,
    avgTime: stressWideTime / stressCount,
    qps: (stressCount / stressWideTime) * 1000
  });
  
  console.info(`窄表压力测试（${stressCount}次）: ${stressNarrowTime}ms, QPS: ${((stressCount / stressNarrowTime) * 1000).toFixed(2)}`);
  console.info(`宽表压力测试（${stressCount}次）: ${stressWideTime}ms, QPS: ${((stressCount / stressWideTime) * 1000).toFixed(2)}`);
  console.info(`性能差异: ${((stressWideTime / stressNarrowTime - 1) * 100).toFixed(2)}%\n`);
  
  // ========== 8. 批量更新测试 ==========
  state.setProgress('测试批量更新...');
  console.info('【8. 批量更新测试】');
  
  const batchUpdateCount = 100;
  const batchUpdateNarrowStart = Date.now();
  for (let i = 0; i < batchUpdateCount; i++) {
    db.Session(NarrowTable).Where('field6', i % 100).Update({ field7: i * 2 });
  }
  const batchUpdateNarrowTime = Date.now() - batchUpdateNarrowStart;
  
  const batchUpdateWideStart = Date.now();
  for (let i = 0; i < batchUpdateCount; i++) {
    db.Session(WideTable).Where('field41', i % 100).Update({ field42: i * 3 });
  }
  const batchUpdateWideTime = Date.now() - batchUpdateWideStart;
  
  results.push({
    testName: '批量更新',
    tableType: 'narrow',
    operation: 'BATCH_UPDATE',
    count: batchUpdateCount,
    totalTime: batchUpdateNarrowTime,
    avgTime: batchUpdateNarrowTime / batchUpdateCount,
    qps: (batchUpdateCount / batchUpdateNarrowTime) * 1000
  });
  
  results.push({
    testName: '批量更新',
    tableType: 'wide',
    operation: 'BATCH_UPDATE',
    count: batchUpdateCount,
    totalTime: batchUpdateWideTime,
    avgTime: batchUpdateWideTime / batchUpdateCount,
    qps: (batchUpdateCount / batchUpdateWideTime) * 1000
  });
  
  console.info(`窄表批量更新（${batchUpdateCount}次）: ${batchUpdateNarrowTime}ms, QPS: ${((batchUpdateCount / batchUpdateNarrowTime) * 1000).toFixed(2)}`);
  console.info(`宽表批量更新（${batchUpdateCount}次）: ${batchUpdateWideTime}ms, QPS: ${((batchUpdateCount / batchUpdateWideTime) * 1000).toFixed(2)}`);
  console.info(`性能差异: ${((batchUpdateWideTime / batchUpdateNarrowTime - 1) * 100).toFixed(2)}%\n`);
  
  // ========== 9. 复杂查询测试（多条件 + 排序）==========
  state.setProgress('测试复杂查询...');
  console.info('【9. 复杂查询测试（多条件 + 排序）】');
  
  const complexNarrowStart = Date.now();
  const complexNarrow: Record<string, relationalStore.ValueType>[] = db.Session(NarrowTable)
    .Where('field6', Math.floor(testDataCount / 2))
    .Where('field7', testDataCount - 1)
    .OrderByDesc('field6')
    .Limit(100)
    .Find();
  const complexNarrowTime = Date.now() - complexNarrowStart;
  
  const complexWideStart = Date.now();
  const complexWide: Record<string, relationalStore.ValueType>[] = db.Session(WideTable)
    .Where('field41', Math.floor(testDataCount / 2))
    .Where('field42', testDataCount - 1)
    .OrderByDesc('field41')
    .Limit(100)
    .Find();
  const complexWideTime = Date.now() - complexWideStart;
  
  results.push({
    testName: '复杂查询',
    tableType: 'narrow',
    operation: 'COMPLEX_SELECT',
    count: complexNarrow.length,
    totalTime: complexNarrowTime,
    avgTime: complexNarrowTime / (complexNarrow.length || 1),
    qps: (complexNarrow.length / complexNarrowTime) * 1000
  });
  
  results.push({
    testName: '复杂查询',
    tableType: 'wide',
    operation: 'COMPLEX_SELECT',
    count: complexWide.length,
    totalTime: complexWideTime,
    avgTime: complexWideTime / (complexWide.length || 1),
    qps: (complexWide.length / complexWideTime) * 1000
  });
  
  console.info(`窄表复杂查询: ${complexNarrowTime}ms, 结果数: ${complexNarrow.length}`);
  console.info(`宽表复杂查询: ${complexWideTime}ms, 结果数: ${complexWide.length}`);
  console.info(`性能差异: ${((complexWideTime / complexNarrowTime - 1) * 100).toFixed(2)}%\n`);
  
  // ========== 输出测试报告 ==========
  console.info('========== 性能测试报告 ==========');
  console.info('测试数据量: ' + testDataCount + ' 条');
  console.info('窄表字段数: 10 个');
  console.info('宽表字段数: 50 个\n');
  
  console.info('测试结果汇总:');
  console.info('测试项\t\t\t窄表耗时\t宽表耗时\t性能差异');
  console.info('------------------------------------------------------------');
  
  for (let i = 0; i < results.length; i += 2) {
    const narrow = results[i];
    const wide = results[i + 1];
    if (narrow && wide) {
      const diff = ((wide.totalTime / narrow.totalTime - 1) * 100).toFixed(2);
      console.info(`${narrow.testName}\t${narrow.totalTime}ms\t\t${wide.totalTime}ms\t\t${diff}%`);
    }
  }
  
  console.info('\n========== 测试结论 ==========');
  console.info('1. 插入操作：宽表比窄表慢 ' + ((wideInsertTime / narrowInsertTime - 1) * 100).toFixed(2) + '%');
  console.info('2. 查询少量字段：性能差异 ' + ((wideFewTime / narrowFewTime - 1) * 100).toFixed(2) + '%');
  console.info('3. SELECT * 查询：宽表比窄表慢 ' + ((wideAllTime / narrowAllTime - 1) * 100).toFixed(2) + '%');
  console.info('4. 全表扫描：宽表比窄表慢 ' + ((wideCountTime / narrowCountTime - 1) * 100).toFixed(2) + '%');
  console.info('5. 更新操作：宽表比窄表慢 ' + ((updateWideTime / updateNarrowTime - 1) * 100).toFixed(2) + '%');
  console.info('\n建议：');
  console.info('- 避免使用 SELECT *，只查询需要的字段');
  console.info('- 宽表（字段多）在 SELECT * 和全表扫描时性能明显下降');
  console.info('- 查询少量字段时，宽表和窄表性能差异较小');
  console.info('========== 测试完成 ==========');
  
  // 保存测试结果到状态
  const summary: TestSummary = {
    testDataCount: testDataCount,
    narrowTableFields: 10,
    wideTableFields: 50,
    totalTests: results.length / 2
  };
  const conclusions: TestConclusions = {
    insertDiff: ((wideInsertTime / narrowInsertTime - 1) * 100).toFixed(2) + '%',
    selectFewDiff: ((wideFewTime / narrowFewTime - 1) * 100).toFixed(2) + '%',
    selectAllDiff: ((wideAllTime / narrowAllTime - 1) * 100).toFixed(2) + '%',
    countDiff: ((wideCountTime / narrowCountTime - 1) * 100).toFixed(2) + '%',
    updateDiff: ((updateWideTime / updateNarrowTime - 1) * 100).toFixed(2) + '%'
  };
  const completeResults: CompleteTestResults = {
    summary: summary,
    results: results,
    conclusions: conclusions
  };
  state.setResults(completeResults);
}

