import { print } from '@kit.BasicServicesKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';

export class PrintManager {
  private static instance: PrintManager;

  private constructor() {}

  public static getInstance(): PrintManager {
    if (!PrintManager.instance) {
      PrintManager.instance = new PrintManager();
    }
    return PrintManager.instance;
  }

  /**
   * 打印文件列表
   * @param context UIAbilityContext
   * @param files 文件路径列表 (file:// 或 fd://)
   */
  public async printFiles(context: common.UIAbilityContext, files: Array<string>): Promise<void> {
    try {
      console.log(`[PrintManager] Starting print task for files: ${JSON.stringify(files)}`);
      
      const printTask = await print.print(files, context);
      
      printTask.on('succeed', () => {
        console.log('[PrintManager] Print task succeeded');
      });

      printTask.on('fail', () => {
        console.log('[PrintManager] Print task failed');
      });

      printTask.on('cancel', () => {
        console.log('[PrintManager] Print task canceled');
      });

      printTask.on('block', () => {
        console.log('[PrintManager] Print task blocked');
      });

    } catch (error) {
      const err = error as BusinessError;
      console.error(`[PrintManager] Print failed: code=${err.code}, message=${err.message}`);
      throw new Error(`Print failed: ${err.message}`);
    }
  }

  /**
   * 打印单个文件
   */
  public async printSingleFile(context: common.UIAbilityContext, file: string): Promise<void> {
    return this.printFiles(context, [file]);
  }
}
