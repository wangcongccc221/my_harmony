/**
 * 数据库演示：展示增删改查和事务处理操作。
 * 请在任何 Ability/Page 的生命周期（如 `onWindowStageCreate`）里调用 `runDatabaseDemo()`，
 * 可以看到每一步的日志输出作为校验。
 */
import { DatabaseManager } from '../DatabaseManager';
import { ProcessingHistory } from '../models/ProcessingHistory';

/**
 * 运行完整演示，覆盖以下内容：
 *  - 初始化和自动迁移
 *  - 增删改查操作流程
 *  - 事务的提交和回滚场景
 */
export async function runDatabaseDemo(): Promise<void> {
  const dbManager = DatabaseManager.getInstance();


  // 1. 初始化/迁移表结构
  await dbManager.initDatabase();
  console.info('测试: AutoMigrate 初始化完成');//初始化完成

  // 基线快照（未修改前）
  const usersBefore = dbManager.getAllUsers();
  const historyBefore = dbManager.getAllProcessingHistory();
  console.info(`测试: 初始用户总数 => ${usersBefore.length}`);
  console.info(`测试: 初始用户详情 => ${JSON.stringify(usersBefore)}`);
  console.info(`测试: 初始加工记录总数 => ${historyBefore.length}`);
  console.info(`测试: 初始加工记录详情 => ${JSON.stringify(historyBefore)}`);

  // 2. 新增用户和加工记录
  const demoUserName = `DemoUser_${Date.now()}`;
  dbManager.addUser(demoUserName, 28);//添加数据
  console.info(`测试: addUser 成功 => ${demoUserName}`);
  const usersAfterAdd = dbManager.getAllUsers();
  console.info(`测试: addUser 后用户总数 => ${usersAfterAdd.length}`);
  const createdUser = usersAfterAdd.find((user) => user.Name === demoUserName);
  console.info(`测试: addUser 后新增用户详情 => ${JSON.stringify(createdUser)}`);

  dbManager.addProcessingHistory(// 添加数据
    'DemoCustomer',
    'DemoFarm',
    'Blueberry',
    '进行中',
    '2025-11-12 09:00:00',
    '2025-11-12 12:00:00',
    150.5,
    42
  );
  console.info('测试: addProcessingHistory 成功');
  const historyAfterAdd = dbManager.getAllProcessingHistory();
  console.info(`测试: addProcessingHistory 后加工记录总数 => ${historyAfterAdd.length}`);
  const createdHistory = historyAfterAdd[historyAfterAdd.length - 1];
  console.info(`测试: addProcessingHistory 后新增记录详情 => ${JSON.stringify(createdHistory)}`);

  // 4. 更新最新一条加工记录（如有）
  const latestHistory = historyAfterAdd[historyAfterAdd.length - 1];
  if (latestHistory && latestHistory.id) {
    const updatedRecord = new ProcessingHistory(
      latestHistory.CustomerName || 'DemoCustomer',
      latestHistory.FarmName || 'DemoFarm',
      latestHistory.FruitName || 'Blueberry',
      '已完成',
      latestHistory.StartTime || '2025-11-12 09:00:00',
      latestHistory.EndTime || '2025-11-12 12:00:00',
      (latestHistory.Weight || 150.5) + 10,
      (latestHistory.Quantity || 42) + 5
    );

    dbManager.updateProcessingHistory(latestHistory.id, updatedRecord);
    console.info(`测试: updateProcessingHistory 成功 => id=${latestHistory.id}`);
    const reloaded = dbManager.getProcessingHistoryById(latestHistory.id);
    console.info(`测试: updateProcessingHistory 后记录 => ${JSON.stringify(reloaded)}`);
    console.info(`测试: updateProcessingHistory 后全部加工记录 => ${JSON.stringify(dbManager.getAllProcessingHistory())}`);
  } else {
    console.warn('测试: 跳过更新，未找到加工记录');
  }

  // 5. 删除刚插入的演示用户
  const demoUser = usersAfterAdd.find((user) => user.Name === demoUserName);
  if (demoUser && demoUser.id) {
    dbManager.deleteUser(demoUser.id);
    console.info(`测试: deleteUser 成功 => id=${demoUser.id}`);
    console.info(`测试: deleteUser 后用户总数 => ${dbManager.getAllUsers().length}`);
    console.info(`测试: deleteUser 后用户详情 => ${JSON.stringify(dbManager.getAllUsers())}`);
  } else {
    console.warn(`测试: 跳过删除，未找到用户 "${demoUserName}"`);
  }

  // 6. 事务 - 正常提交流程
  const usersBeforeTx = dbManager.getAllUsers().length;
  const historyBeforeTx = dbManager.getAllProcessingHistory().length;
  const transactionOk = await dbManager.executeInTransaction(async () => {
    const txUserName = `TxUser_${Date.now()}`;
    dbManager.addUser(txUserName, 30);
    dbManager.addProcessingHistory(
      'TxCustomer',
      'TxFarm',
      'TxFruit',
      '进行中',
      '2025-11-12 13:00:00',
      '2025-11-12 15:00:00',
      80,
      20
    );
  });
  console.info(`测试: 事务提交成功 => ${transactionOk}`);
  const usersAfterTx = dbManager.getAllUsers();
  const historyAfterTx = dbManager.getAllProcessingHistory();
  console.info(`测试: 事务后用户数 => ${usersAfterTx.length} (之前 ${usersBeforeTx})`);
  console.info(`测试: 事务后用户详情 => ${JSON.stringify(usersAfterTx)}`);
  console.info(`测试: 事务后加工记录数 => ${historyAfterTx.length} (之前 ${historyBeforeTx})`);
  console.info(`测试: 事务后加工记录详情 => ${JSON.stringify(historyAfterTx)}`);

  // 7. 事务 - 回滚流程（故意抛出异常）
  const usersBeforeRollback = dbManager.getAllUsers().length;
  const historyBeforeRollback = dbManager.getAllProcessingHistory().length;
  const snapshotUsersBeforeRollback = dbManager.getAllUsers();
  const snapshotHistoryBeforeRollback = dbManager.getAllProcessingHistory();
  try {
    await dbManager.executeInTransaction(async () => {
      dbManager.addUser('RollbackUser', 35);
      throw new Error('模拟故障以触发事务回滚');
    });
  } catch (err) {
    console.warn(`测试: 事务回滚成功 => ${err}`);
  }
  const usersAfterRollback = dbManager.getAllUsers();
  const historyAfterRollback = dbManager.getAllProcessingHistory();
  console.info(`测试: 事务回滚后用户数 => ${usersAfterRollback.length} (之前 ${usersBeforeRollback})`);
  console.info(`测试: 事务回滚后用户详情 => ${JSON.stringify(usersAfterRollback)}`);
  console.info(`测试: 事务回滚后加工记录数 => ${historyAfterRollback.length} (之前 ${historyBeforeRollback})`);
  console.info(`测试: 事务回滚后加工记录详情 => ${JSON.stringify(historyAfterRollback)}`);
  console.info(`测试: 事务回滚前用户快照 => ${JSON.stringify(snapshotUsersBeforeRollback)}`);
  console.info(`测试: 事务回滚前加工记录快照 => ${JSON.stringify(snapshotHistoryBeforeRollback)}`);

  console.info('测试: DatabaseDemo 演示结束');
}

