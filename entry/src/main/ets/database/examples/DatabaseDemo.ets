/**
 * 数据库 ORM 完整功能演示
 * 展示所有 CRUD 操作、条件查询、事务等功能
 */
import { GetIBestORM } from '../orm';
import { User } from '../models/User';
import { ProcessingHistory } from '../models/ProcessingHistory';
import { TestModel } from '../models/TestModel';

/**
 * 运行完整演示
 */
export async function runDatabaseDemo(): Promise<void> {
  const db = GetIBestORM();
  
  console.info('========== 数据库 ORM 功能演示 ==========');
  
  // ========== 1. 自动迁移（建表） ==========
  console.info('\n【1. 自动迁移】');
  db.AutoMigrate(User);
  db.AutoMigrate(ProcessingHistory);
  db.AutoMigrate(TestModel);
  console.info(' 表结构初始化完成');
  
  // ========== 2. Create（创建数据） ==========
  console.info('\n【2. Create - 创建数据】');
  
  // 方式1：使用实体对象创建
  const user1 = new User('张三', 25);
  const userId1 = await db.Create(user1);
  console.info(` 创建用户成功，ID: ${userId1}`);
  
  // 方式2：使用 Table + Insert（直接插入）
  const insertResult = db.Table('user').Insert({
    Name: '李四',
    Age: 30
  });
  console.info(` 直接插入用户成功，ID: ${insertResult}`);
  
  // 方式3：批量创建
  const users = [
    new User('王五', 28),
    new User('赵六', 35)
  ];
  const batchResult = await db.Create(users);
  console.info(` 批量创建用户成功，数量: ${batchResult}`);
  
  // 创建加工记录
  const history = new ProcessingHistory(
    '客户A',
    '农场B',
    '苹果',
    '已完成',
    '2025-01-15 09:00:00',
    '2025-01-15 12:00:00',
    150.5,
    100
  );
  await db.Create(history);
  console.info(' 创建加工记录成功');
  
  // 创建测试模型数据
  const test1 = new TestModel('测试标题1', '这是测试描述1', 10, 1);
  const test2 = new TestModel('测试标题2', '这是测试描述2', 20, 1);
  await db.Create(test1);
  await db.Create(test2);
  console.info(' 创建测试模型数据成功');
  
  // ========== 3. Find（查询所有） ==========
  console.info('\n【3. Find - 查询所有数据】');
  const allUsers = db.Table('user').Find();
  console.info(` 查询到 ${allUsers.length} 个用户`);
  
  // 使用 Session 方式查询
  const allUsers2 = db.Session(User).Find();
  console.info(` Session 方式查询到 ${allUsers2.length} 个用户`);
  
  // 查询测试模型数据
  const allTests = db.Session(TestModel).Find();
  console.info(` 查询到 ${allTests.length} 个测试模型数据`);
  
  // ========== 4. First/Last（查询第一条/最后一条） ==========
  console.info('\n【4. First/Last - 查询单条数据】');
  
  // First：查询第一条
  const firstUser = db.Table('user').First();
  console.info(` First: ${JSON.stringify(firstUser)}`);
  
  // Last：查询最后一条
  const lastUser = db.Table('user').Last();
  console.info(` Last: ${JSON.stringify(lastUser)}`);
  
  // First 传入实体对象（自动填充）
  const userObj = new User();
  db.Table('user').First(userObj);
  console.info(` First 填充对象: Name=${userObj.Name}, Age=${userObj.Age}`);
  
  // ========== 5. Where（条件查询） ==========
  console.info('\n【5. Where - 条件查询】');
  
  // 等于查询
  const users25 = db.Table('user').Where('Age', 25).Find();
  console.info(` 年龄等于25的用户: ${users25.length} 个`);
  
  // 多条件查询（链式）
  const result1 = db.Table('user')
    .Where('Age', 25)
    .Where('Name', '张三')
    .First();
  console.info(` 多条件查询: ${JSON.stringify(result1)}`);
  
  // ========== 6. Not（非条件查询） ==========
  console.info('\n【6. Not - 非条件查询】');
  const not25 = db.Table('user').Not('Age', 25).Find();
  console.info(` 年龄不等于25的用户: ${not25.length} 个`);
  
  // ========== 7. Like（模糊查询） ==========
  console.info('\n【7. Like - 模糊查询】');
  const likeUsers = db.Table('user').Like('Name', '%三%').Find();
  console.info(` 名字包含"三"的用户: ${likeUsers.length} 个`);
  
  // ========== 8. Between（范围查询） ==========
  console.info('\n【8. Between - 范围查询】');
  const ageRange = db.Table('user').Between('Age', 25, 35).Find();
  console.info(` 年龄在25-35之间的用户: ${ageRange.length} 个`);
  
  // ========== 9. Greater/Less（比较查询） ==========
  console.info('\n【9. Greater/Less - 比较查询】');
  const older30 = db.Table('user').Greater('Age', 30).Find();
  console.info(` 年龄大于30的用户: ${older30.length} 个`);
  
  const younger30 = db.Table('user').Less('Age', 30).Find();
  console.info(` 年龄小于30的用户: ${younger30.length} 个`);
  
  // ========== 10. Select（选择列） ==========
  console.info('\n【10. Select - 选择列】');
  const namesOnly = db.Table('user').Select(['name']).Find();
  console.info(` 只查询 name 列: ${JSON.stringify(namesOnly)}`);
  
  // ========== 11. OrderBy（排序） ==========
  console.info('\n【11. OrderBy - 排序】');
  const sortedUsers = db.Table('user')
    .OrderByAsc('Age')
    .Find();
  console.info(` 按年龄升序排序: ${sortedUsers.length} 个`);
  
  const descUsers = db.Table('user')
    .OrderByDesc('Age')
    .Find();
  console.info(` 按年龄降序排序: ${descUsers.length} 个`);
  
  // ========== 12. Limit/Offset（分页） ==========
  console.info('\n【12. Limit/Offset - 分页】');
  const page1 = db.Table('user')
    .OrderByAsc('Age')
    .Limit(2)
    .Offset(0)
    .Find();
  console.info(` 第1页（每页2条）: ${page1.length} 个`);
  
  const page2 = db.Table('user')
    .OrderByAsc('Age')
    .Limit(2)
    .Offset(2)
    .Find();
  console.info(` 第2页（每页2条）: ${page2.length} 个`);
  
  // ========== 13. Update（更新数据） ==========
  console.info('\n【13. Update - 更新数据】');
  
  // 方式1：使用 Table + Where + Update
  const updateCount = db.Table('user')
    .Where('Name', '张三')
    .Update({ Age: 26 });
  console.info(` 更新了 ${updateCount} 条记录`);
  
  // 方式2：使用 Save（需要先查询到对象，设置ID）
  const userToUpdate = db.Table('user').Where('Name', '李四').First();
  if (userToUpdate && userToUpdate.id) {
    const userEntity = new User('李四', 31);
    userEntity.ID = typeof userToUpdate.id === 'number' ? userToUpdate.id : Number(userToUpdate.id);
    await db.Save(userEntity);
    console.info(' Save 方式更新成功');
  }
  
  // ========== 14. Delete（删除数据） ==========
  console.info('\n【14. Delete - 删除数据】');
  
  // 方式1：条件删除
  const deleteCount = db.Table('user')
    .Where('Name', '赵六')
    .Delete();
  console.info(` 删除了 ${deleteCount} 条记录`);
  
  // 方式2：主键删除
  const userToDelete = db.Table('user').Where('Name', '王五').First();
  if (userToDelete && userToDelete.id) {
    const id = typeof userToDelete.id === 'number' ? userToDelete.id : Number(userToDelete.id);
    const deleted = db.DeleteByKey(User, id);
    console.info(` 主键删除: ${deleted} 条`);
  }
  
  // ========== 15. 复杂链式查询 ==========
  console.info('\n【15. 复杂链式查询】');
  const complexResult = db.Table('user')
    .Where('Age', [25, 28, 30])  // IN 查询
    .OrderByDesc('Age')
    .Limit(5)
    .Find();
  console.info(` 复杂查询结果: ${complexResult.length} 个`);
  
  // ========== 16. 事务处理 ==========
  console.info('\n【16. 事务处理】');
  
  // 事务：正常提交
  db.Begin();
  try {
    const txUser1 = new User('事务用户1', 20);
    const txUser2 = new User('事务用户2', 21);
    await db.Create(txUser1);
    await db.Create(txUser2);
    db.Commit();
    console.info(' 事务提交成功');
  } catch (error) {
    db.Rollback();
    console.error(' 事务回滚:', error);
  }
  
  // 事务：回滚演示
  const beforeCount = db.Table('user').Find().length;
  db.Begin();
  try {
    const rollbackUser = new User('回滚用户', 99);
    await db.Create(rollbackUser);
    throw new Error('模拟错误，触发回滚');
  } catch (error) {
    db.Rollback();
    console.info(' 事务回滚成功（模拟错误）');
  }
  const afterCount = db.Table('user').Find().length;
  console.info(` 回滚验证: 之前 ${beforeCount} 条，之后 ${afterCount} 条`);
  
  // ========== 17. 错误处理 ==========
  console.info('\n【17. 错误处理】');
  db.Table('user').Where('Name', '不存在的用户').First(undefined, (error) => {
    console.info(` 错误回调: ${error}`);
  });
  
  const dbError = db.GetError();
  if (dbError) {
    console.info(` 获取错误信息: ${dbError}`);
  }
  
  // ========== 18. 加工记录查询示例 ==========
  console.info('\n【18. 加工记录查询示例】');
  const completedHistory = db.Session(ProcessingHistory)
    .Where('Status', '已完成')
    .OrderByDesc('StartTime')
    .Find();
  console.info(` 已完成的加工记录: ${completedHistory.length} 条`);
  
  const weightRange = db.Session(ProcessingHistory)
    .Between('Weight', 100, 200)
    .Find();
  console.info(` 重量在100-200之间的记录: ${weightRange.length} 条`);
  
  // ========== 19. TestModel 查询示例 ==========
  console.info('\n【19. TestModel 查询示例】');
  
  // 查询启用的测试数据
  const enabledTests = db.Session(TestModel)
    .Where('is_enabled', 1)
    .Find();
  console.info(` 启用的测试数据: ${enabledTests.length} 条`);
  
  // 查询数量大于15的测试数据
  const countGreater = db.Session(TestModel)
    .Greater('Count', 15)
    .Find();
  console.info(` 数量大于15的测试数据: ${countGreater.length} 条`);
  
  // 模糊查询标题
  const titleLike = db.Session(TestModel)
    .Like('Title', '%测试%')
    .Find();
  console.info(` 标题包含"测试"的数据: ${titleLike.length} 条`);
  
  console.info('\n========== 演示完成 ==========');
  console.info(`最终用户总数: ${db.Table('user').Find().length}`);
  console.info(`最终加工记录数: ${db.Table('processing_history').Find().length}`);
  console.info(`最终测试模型数: ${db.Session(TestModel).Find().length}`);
}

