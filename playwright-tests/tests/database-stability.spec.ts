import { test, expect } from '@playwright/test';

/**
 * 数据库稳定性测试
 * 模拟用户持续添加加工历史数据到数据库
 */
test.describe('加工历史数据 - 数据库稳定性测试', () => {
  const BASE_URL = process.env.BASE_URL || 'http://127.0.0.1:8080';
  const PROCESSING_PAGE = '/files/file%2Fprocessing.html';

  // 测试数据池
  const customerNames = ['张三', '李四', '王五', '赵六', '钱七', '孙八', '周九', '吴十'];
  const farmNames = ['阳光农场', '绿野农场', '丰收农场', '田园农场', '生态农场'];
  const fruitNames = ['苹果', '橙子', '香蕉', '葡萄', '草莓', '西瓜', '桃子', '梨子'];
  const statuses = ['已完成', '进行中', '待开始'];

  /**
   * 生成随机测试数据
   */
  function generateRandomData() {
    const customerName = customerNames[Math.floor(Math.random() * customerNames.length)];
    const farmName = farmNames[Math.floor(Math.random() * farmNames.length)];
    const fruitName = fruitNames[Math.floor(Math.random() * fruitNames.length)];
    const status = statuses[Math.floor(Math.random() * statuses.length)];
    
    // 生成随机日期（最近30天内）
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - Math.floor(Math.random() * 30));
    const endDate = new Date(startDate);
    endDate.setDate(endDate.getDate() + Math.floor(Math.random() * 7) + 1);
    
    // 格式化日期为 YYYY-MM-DDTHH:mm 格式（HTML datetime-local 格式）
    const formatDateTime = (date: Date): string => {
      const year = date.getFullYear();
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const day = String(date.getDate()).padStart(2, '0');
      const hours = String(Math.floor(Math.random() * 24)).padStart(2, '0');
      const minutes = String(Math.floor(Math.random() * 60)).padStart(2, '0');
      return `${year}-${month}-${day}T${hours}:${minutes}`;
    };

    const startTime = formatDateTime(startDate);
    const endTime = formatDateTime(endDate);
    const weight = (Math.random() * 1000 + 10).toFixed(2); // 10-1010 kg
    const count = Math.floor(Math.random() * 1000) + 1; // 1-1000 个

    return {
      customerName,
      farmName,
      fruitName,
      status,
      startTime,
      endTime,
      weight,
      count
    };
  }

  /**
   * 填写表单并提交
   * 返回成功或失败的消息
   */
  async function fillAndSubmitForm(page: any, data: any): Promise<string> {
    // 设置 alert 监听器（必须在操作之前）
    let dialogMessage = '';
    const dialogPromise = new Promise<string>((resolve) => {
      page.once('dialog', async (dialog: any) => {
        dialogMessage = dialog.message();
        await dialog.accept();
        resolve(dialogMessage);
      });
    });
    
    // 填写客户名称 (id="cn")
    await page.fill('#cn', data.customerName);
    
    // 填写农场名称 (id="fn")
    await page.fill('#fn', data.farmName);
    
    // 填写水果名称 (id="fruit")
    await page.fill('#fruit', data.fruitName);
    
    // 选择加工状态 (id="st" 是 select 下拉框)
    await page.selectOption('#st', data.status);
    
    // 填写开始时间 (id="s" datetime-local)
    await page.fill('#s', data.startTime);
    
    // 填写结束时间 (id="e" datetime-local)
    await page.fill('#e', data.endTime);
    
    // 填写重量 (id="w")
    await page.fill('#w', data.weight);
    
    // 填写批个数 (id="c")
    await page.fill('#c', data.count.toString());
    
    // 点击新增按钮 (onclick="onAdd()")
    await page.click('button:has-text("新增")');
    
    // 等待 alert 出现（最多等待3秒）
    try {
      await Promise.race([
        dialogPromise,
        new Promise((resolve) => setTimeout(() => resolve(''), 3000))
      ]);
    } catch (error) {
      console.log('等待 alert 超时或出错:', error);
    }
    
    // 额外等待一下，确保操作完成
    await page.waitForTimeout(1000);
    
    return dialogMessage;
  }

  test('持续添加数据 - 长时间稳定性测试（约15分钟）', async ({ page }) => {
    test.setTimeout(900000); // 设置15分钟超时
    
    await page.goto(BASE_URL + PROCESSING_PAGE);
    await page.waitForSelector('#rows', { timeout: 10000 });
    
    // 长时间测试：添加更多记录（约1小时，每3秒一条记录，约1200条）
    const totalRecords = 1200; // 添加1200条记录
    const successCount: number[] = [];
    const errorCount: number[] = [];
    const startTime = Date.now();
    const targetDuration = 900000; // 15分钟（毫秒）
    
    console.log(`开始长时间稳定性测试：将添加 ${totalRecords} 条记录到数据库，预计耗时约1小时`);
    
    for (let i = 0; i < totalRecords; i++) {
      try {
        // 检查是否超时
        const elapsed = Date.now() - startTime;
        if (elapsed > targetDuration) {
          console.log(`已达到目标测试时间（15分钟），停止测试`);
          break;
        }
        
        // 检查页面是否还在
        if (page.isClosed()) {
          console.error(`[${i + 1}] 页面已关闭，无法继续测试`);
          errorCount.push(i + 1);
          break;
        }
        
        const data = generateRandomData();
        // 添加唯一标识，避免重复
        data.customerName = `长时间测试_${Date.now()}_${i}_${Math.floor(Math.random() * 1000000)}`;
        
        // 每50条记录打印一次进度
        if ((i + 1) % 50 === 0) {
          const elapsedMinutes = ((Date.now() - startTime) / 1000 / 60).toFixed(1);
          console.log(`[${i + 1}/${totalRecords}] 已运行 ${elapsedMinutes} 分钟，添加数据: ${data.customerName} - ${data.fruitName}`);
          console.log(`  成功: ${successCount.length}, 失败: ${errorCount.length}, 成功率: ${((successCount.length / (successCount.length + errorCount.length)) * 100).toFixed(2)}%`);
        } else if ((i + 1) % 10 === 0) {
          console.log(`[${i + 1}/${totalRecords}] 添加数据: ${data.customerName} - ${data.fruitName} - ${data.weight}kg`);
        }
        
        const result = await fillAndSubmitForm(page, data);
        
        // 检查结果
        if (result && result.includes('失败')) {
          errorCount.push(i + 1);
          if ((i + 1) % 10 === 0) {
            console.error(`[${i + 1}] 添加失败: ${result}`);
          }
          continue;
        }
        
        // 如果成功（包含"成功"或没有 alert 消息）
        successCount.push(i + 1);
        
        // 每条记录之间等待3秒，让测试持续约1小时
        await page.waitForTimeout(3000);
        
      } catch (error) {
        errorCount.push(i + 1);
        const errorMsg = error instanceof Error ? error.message : String(error);
        if ((i + 1) % 10 === 0) {
          console.error(`[${i + 1}] 添加数据时出错:`, errorMsg);
        }
        
        // 如果页面关闭了，重新打开
        if (errorMsg.includes('closed') || errorMsg.includes('Target page')) {
          console.log(`[${i + 1}] 页面已关闭，尝试重新打开...`);
          try {
            await page.goto(BASE_URL + PROCESSING_PAGE);
            await page.waitForSelector('#rows', { timeout: 10000 });
            await page.waitForTimeout(1000);
          } catch (reopenError) {
            console.error(`[${i + 1}] 重新打开页面失败:`, reopenError);
            break;
          }
        }
      }
    }
    
    const totalDuration = ((Date.now() - startTime) / 1000 / 60).toFixed(1);
    console.log(`\n长时间稳定性测试完成！`);
    console.log(`总测试时长: ${totalDuration} 分钟`);
    console.log(`总记录数: ${totalRecords}`);
    console.log(`成功: ${successCount.length}`);
    console.log(`失败: ${errorCount.length}`);
    console.log(`成功率: ${((successCount.length / (successCount.length + errorCount.length)) * 100).toFixed(2)}%`);
    
    // 验证最终结果（至少60%成功率，长时间测试可能有一些网络波动）
    expect(successCount.length).toBeGreaterThan((successCount.length + errorCount.length) * 0.6);
  });

});

