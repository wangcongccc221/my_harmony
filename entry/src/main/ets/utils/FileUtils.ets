import { fileIo as fs } from '@kit.CoreFileKit';
import { buffer } from '@kit.ArkTS';
import { Context } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { zlib } from '@kit.BasicServicesKit';

const TAG = 'FileUtils';
const DOMAIN = 0x0000;

/**
 * 路径配置接口
 */
export interface IPathConfig {
  // 存储模式：'haps' 使用 haps/entry/file，'sandbox' 使用 filesDir
  storageMode: 'haps' | 'sandbox';
  
  // 当 storageMode = 'sandbox' 时使用的目录名
  sandboxDirName: string;
  
  // 当 storageMode = 'haps' 时使用的路径（相对于包根目录）
  hapsPath: string;
  
  // 解压文件的子目录（相对于存储目录）
  extractSubDir: string;
}

/**
 * 路径配置 - 集中管理所有路径设置
 * 修改这里即可更改所有文件存储路径
 */
export const PathConfig: IPathConfig = {
  // 存储模式：'haps' 使用 haps/entry/files，'sandbox' 使用 filesDir
  storageMode: 'haps',
  
  // 当 storageMode = 'sandbox' 时使用的目录名
  sandboxDirName: 'webSources',
  
  // 当 storageMode = 'haps' 时使用的路径（相对于包根目录）
  hapsPath: 'haps/entry/files',
  
  // 解压文件的子目录（相对于存储目录）
  extractSubDir: 'extracted'
};

/**
 * 解压结果接口
 */
export interface ExtractResult {
  zipPath: string;
  extractPath: string;
}

/**
 * 目录复制结果接口
 */
export interface DirectoryCopyResult {
  targetPath: string;
  fileCount: number;
  fileList: string[];
}

/**
 * FileUtils 工具对象接口
 */
export interface IFileUtils {
  copyRawFileToSandbox: (context: Context, rawFilePath: string, sandboxDirName?: string, fileName?: string, useCustomPath?: boolean, customPath?: string) => Promise<string>;
  copyRawFileToSandboxSync: (context: Context, rawFilePath: string, sandboxDirName?: string, fileName?: string) => string;
  checkFileExists: (context: Context, fileName: string, sandboxDirName?: string) => boolean;
  getSandboxFilePath: (context: Context, fileName: string, sandboxDirName?: string) => string;
  getBundleRootPath: (context: Context) => string;
  getHapsEntryFilePath: (context: Context) => string;
  getDefaultStoragePath: (context: Context) => string;
  getExtractPath: (context: Context, subDir?: string) => string;
  copyRawDirectoryFilesToSandbox: (context: Context, rawFileDir: string, fileList: string[], sandboxDirName?: string, targetDirName?: string, useCustomPath?: boolean, customPath?: string) => Promise<DirectoryCopyResult>;
  listFilesInDirectory: (dirPath: string) => string[];
  extractZipFile: (context: Context, zipFilePath: string, outputDirName?: string, useCustomPath?: boolean, customBasePath?: string) => Promise<string>;
  copyAndExtractZipFile: (context: Context, rawFilePath: string, sandboxDirName?: string, extractDirName?: string, useCustomPath?: boolean, customPath?: string) => Promise<ExtractResult>;
}

/**
 * 创建目录（递归）
 */
function ensureDirectoryExists(dirPath: string): void {
  try {
    const dirs = dirPath.split('/');
    let currentPath = '';
    for (const dir of dirs) {
      if (dir) {
        currentPath = currentPath ? `${currentPath}/${dir}` : dir;
        try {
          fs.mkdirSync(currentPath);
        } catch (e) {
          // 目录可能已存在，继续
        }
      }
    }
  } catch (e) {
    hilog.info(DOMAIN, TAG, 'Directory may already exist: %{public}s', dirPath);
  }
}

/**
 * 将 rawfile 中的文件复制到沙箱
 * 支持所有文件类型（zip、txt、json、图片等）
 * @param context 应用上下文
 * @param rawFilePath rawfile 中的文件路径（例如: "file.zip"、"data.json"、"image.png" 等）
 * @param sandboxDirName 沙箱中的目标目录名（可选，默认为 "webSources"）
 * @param fileName 目标文件名（可选，如果不提供则使用原始文件名）
 * @returns Promise<string> 返回沙箱中的完整文件路径
 */
export async function copyRawFileToSandbox(
  context: Context,
  rawFilePath: string,
  sandboxDirName?: string,
  fileName?: string,
  useCustomPath?: boolean,
  customPath?: string
): Promise<string> {
  try {
    // 获取目标目录路径
    let targetDir: string;
    if (useCustomPath && customPath) {
      // 使用自定义路径
      targetDir = customPath;
    } else if (sandboxDirName) {
      // 使用指定的 sandboxDirName
      const boxPath = context.getApplicationContext().filesDir;
      targetDir = `${boxPath}/${sandboxDirName}`;
    } else {
      // 使用配置中的默认路径
      targetDir = getDefaultStoragePath(context);
    }
    
    const unzipPath = targetDir;

    // 创建沙箱目录
    ensureDirectoryExists(unzipPath);

    // 确定目标文件名
    const targetFileName = fileName || rawFilePath.split('/').pop() || 'file';
    const filePath = `${unzipPath}/${targetFileName}`;

    // 获取 rawfile 资源文件
    hilog.info(DOMAIN, TAG, 'Reading rawfile: %{public}s', rawFilePath);
    const uint8Array: Uint8Array = context.resourceManager.getRawFileContentSync(rawFilePath);

    // 转换为 ArrayBuffer
    const bf = buffer.from(uint8Array).buffer;

    // 打开文件（如果不存在会自动创建）
    const fsOpen = fs.openSync(
      filePath,
      fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC
    );

    // 写入文件
    fs.writeSync(fsOpen.fd, bf);
    
    // 关闭文件
    fs.closeSync(fsOpen.fd);

    hilog.info(DOMAIN, TAG, 'File copied successfully to: %{public}s', filePath);
    return filePath;
  } catch (error) {
    hilog.error(DOMAIN, TAG, 'Failed to copy file: %{public}s', JSON.stringify(error));
    throw new Error(`Failed to copy file: ${error instanceof Error ? error.message : JSON.stringify(error)}`);
  }
}

/**
 * 同步版本：将 rawfile 中的文件复制到沙箱
 * 支持所有文件类型（zip、txt、json、图片等）
 * @param context 应用上下文
 * @param rawFilePath rawfile 中的文件路径
 * @param sandboxDirName 沙箱中的目标目录名
 * @param fileName 目标文件名
 * @returns 沙箱中的完整文件路径
 */
export function copyRawFileToSandboxSync(
  context: Context,
  rawFilePath: string,
  sandboxDirName: string = 'webSources',
  fileName?: string
): string {
  try {
    // 获取沙箱根目录
    const boxPath = context.getApplicationContext().filesDir;
    const unzipPath = `${boxPath}/${sandboxDirName}`;

    // 创建沙箱目录
    ensureDirectoryExists(unzipPath);

    // 确定目标文件名
    const targetFileName = fileName || rawFilePath.split('/').pop() || 'file';
    const filePath = `${unzipPath}/${targetFileName}`;

    // 获取 rawfile 资源文件
    hilog.info(DOMAIN, TAG, 'Reading rawfile: %{public}s', rawFilePath);
    const uint8Array: Uint8Array = context.resourceManager.getRawFileContentSync(rawFilePath);

    // 转换为 ArrayBuffer
    const bf = buffer.from(uint8Array).buffer;

    // 打开文件（如果不存在会自动创建）
    const fsOpen = fs.openSync(
      filePath,
      fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC
    );

    // 写入文件
    fs.writeSync(fsOpen.fd, bf);
    
    // 关闭文件
    fs.closeSync(fsOpen.fd);

    hilog.info(DOMAIN, TAG, 'File copied successfully to: %{public}s', filePath);
    return filePath;
  } catch (error) {
    hilog.error(DOMAIN, TAG, 'Failed to copy file: %{public}s', JSON.stringify(error));
    throw new Error(`Failed to copy file: ${error instanceof Error ? error.message : JSON.stringify(error)}`);
  }
}

/**
 * 检查沙箱中文件是否存在
 * @param context 应用上下文
 * @param fileName 文件名
 * @param sandboxDirName 沙箱目录名
 * @returns 文件是否存在
 */
export function checkFileExists(
  context: Context,
  fileName: string,
  sandboxDirName: string = 'webSources'
): boolean {
  try {
    const boxPath = context.getApplicationContext().filesDir;
    const filePath = `${boxPath}/${sandboxDirName}/${fileName}`;
    return fs.accessSync(filePath);
  } catch (e) {
    return false;
  }
}

/**
 * 获取沙箱中文件的完整路径
 * @param context 应用上下文
 * @param fileName 文件名
 * @param sandboxDirName 沙箱目录名
 * @returns 文件的完整路径
 */
export function getSandboxFilePath(
  context: Context,
  fileName: string,
  sandboxDirName: string = 'webSources'
): string {
  const boxPath = context.getApplicationContext().filesDir;
  return `${boxPath}/${sandboxDirName}/${fileName}`;
}

/**
 * 获取沙箱根目录路径
 * @param context 应用上下文
 * @returns 沙箱根目录路径
 */
export function getSandboxRootPath(context: Context): string {
  return context.getApplicationContext().filesDir;
}

/**
 * 获取应用包根目录路径
 * @param context 应用上下文
 * @returns 应用包根目录路径（例如: /data/storage/el1/bundle/com.example.app）
 */
export function getBundleRootPath(context: Context): string {
  const filesDir = context.getApplicationContext().filesDir;
  // filesDir 通常是 /data/storage/el1/bundle/{包名}/files/
  // 向上两级得到包根目录
  const parts = filesDir.split('/');
  // 移除最后的 'files' 和空字符串
  const bundleRoot = parts.slice(0, parts.length - 1).join('/');
  return bundleRoot;
}

/**
 * 获取 haps/entry/file 目录路径
 * @param context 应用上下文
 * @returns haps/entry/file 的完整路径
 */
export function getHapsEntryFilePath(context: Context): string {
  const bundleRoot = getBundleRootPath(context);
  return `${bundleRoot}/${PathConfig.hapsPath}`;
}

/**
 * 获取默认存储目录路径（根据配置自动选择）
 * @param context 应用上下文
 * @returns 默认存储目录的完整路径
 */
export function getDefaultStoragePath(context: Context): string {
  if (PathConfig.storageMode === 'haps') {
    return getHapsEntryFilePath(context);
  } else {
    const boxPath = context.getApplicationContext().filesDir;
    return `${boxPath}/${PathConfig.sandboxDirName}`;
  }
}

/**
 * 获取解压目录路径（根据配置自动选择）
 * @param context 应用上下文
 * @param subDir 子目录名（可选）
 * @returns 解压目录的完整路径
 */
export function getExtractPath(context: Context, subDir?: string): string {
  const basePath = getDefaultStoragePath(context);
  const extractDir = subDir || PathConfig.extractSubDir;
  return `${basePath}/${extractDir}`;
}

/**
 * 获取沙箱中目录的完整路径
 * @param context 应用上下文
 * @param dirName 目录名
 * @returns 目录的完整路径
 */
export function getSandboxDirPath(
  context: Context,
  dirName: string = 'webSources'
): string {
  const boxPath = context.getApplicationContext().filesDir;
  return `${boxPath}/${dirName}`;
}

/**
 * 递归复制 rawfile 目录中的所有文件（需要提供文件列表）
 * @param context 应用上下文
 * @param rawFileDir rawfile 中的目录路径
 * @param fileList 需要复制的文件列表（相对路径，例如: ["file1.txt", "subdir/file2.txt"]）
 * @param sandboxDirName 沙箱中的目标目录名
 * @param targetDirName 目标目录名
 * @returns Promise 返回复制结果
 */
export async function copyRawDirectoryFilesToSandbox(
  context: Context,
  rawFileDir: string,
  fileList: string[],
  sandboxDirName?: string,
  targetDirName?: string,
  useCustomPath?: boolean,
  customPath?: string
): Promise<DirectoryCopyResult> {
  try {
    // 获取目标基础路径
    let basePath: string;
    if (useCustomPath && customPath) {
      // 使用自定义路径
      basePath = customPath;
    } else if (sandboxDirName) {
      // 使用指定的 sandboxDirName
      const boxPath = context.getApplicationContext().filesDir;
      basePath = `${boxPath}/${sandboxDirName}`;
    } else {
      // 使用配置中的默认路径
      basePath = getDefaultStoragePath(context);
    }
    
    const targetDirNameFinal = targetDirName || rawFileDir.split('/').pop() || 'folder';
    const targetPath = `${basePath}/${targetDirNameFinal}`;

    const copiedFiles: string[] = [];
    let copiedCount = 0;

    // 创建目标目录
    ensureDirectoryExists(targetPath);

    // 复制每个文件
    for (const file of fileList) {
      try {
        const rawFilePath = rawFileDir ? `${rawFileDir}/${file}` : file;
        const targetFilePath = `${targetPath}/${file}`;

        // 创建子目录（如果需要）
        const fileDirs = file.split('/');
        if (fileDirs.length > 1) {
          let subDirPath = targetPath;
          for (let i = 0; i < fileDirs.length - 1; i++) {
            subDirPath = `${subDirPath}/${fileDirs[i]}`;
            ensureDirectoryExists(subDirPath);
          }
        }

        // 读取 rawfile 中的文件
        const uint8Array: Uint8Array = context.resourceManager.getRawFileContentSync(rawFilePath);
        const bf = buffer.from(uint8Array).buffer;

        // 写入目标文件
        const fsOpen = fs.openSync(
          targetFilePath,
          fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC
        );
        fs.writeSync(fsOpen.fd, bf);
        fs.closeSync(fsOpen.fd);

        copiedFiles.push(file);
        copiedCount++;
        hilog.info(DOMAIN, TAG, 'Copied file: %{public}s', file);
      } catch (error) {
        hilog.warn(DOMAIN, TAG, 'Failed to copy file %{public}s: %{public}s', file, JSON.stringify(error));
      }
    }

    hilog.info(DOMAIN, TAG, 'Directory copied successfully. Total files: %{public}d', copiedCount);
    const result: DirectoryCopyResult = {
      targetPath: targetPath,
      fileCount: copiedCount,
      fileList: copiedFiles
    };
    return result;
  } catch (error) {
    hilog.error(DOMAIN, TAG, 'Failed to copy directory files: %{public}s', JSON.stringify(error));
    throw new Error(`Failed to copy directory files: ${error instanceof Error ? error.message : JSON.stringify(error)}`);
  }
}

/**
 * 列出目录中的所有文件（递归）
 * @param dirPath 目录路径
 * @returns 文件列表
 */
export function listFilesInDirectory(dirPath: string): string[] {
  const fileList: string[] = [];
  try {
    // 使用 listFile 列出目录内容
    const files = fs.listFileSync(dirPath);
    for (let i = 0; i < files.length; i++) {
      const fileName = files[i];
      const fullPath = `${dirPath}/${fileName}`;
      
      // 检查是文件还是目录
      try {
        const stat = fs.statSync(fullPath);
        if (stat.isFile()) {
          fileList.push(fileName);
        } else if (stat.isDirectory()) {
          // 递归列出子目录中的文件
          const subFiles = listFilesInDirectory(fullPath);
          subFiles.forEach(file => {
            fileList.push(`${fileName}/${file}`);
          });
        }
      } catch (e) {
        // 忽略无法访问的文件
        hilog.warn(DOMAIN, TAG, 'Cannot access: %{public}s', fullPath);
      }
    }
  } catch (error) {
    hilog.error(DOMAIN, TAG, 'Failed to list directory: %{public}s', JSON.stringify(error));
  }
  return fileList;
}

/**
 * 解压 zip 文件
 * @param context 应用上下文
 * @param zipFilePath zip 文件的完整路径
 * @param outputDirName 解压输出目录名（可选，默认为 "webSources/extracted"）
 * @returns Promise<string> 返回解压后的目录路径
 */
export async function extractZipFile(
  context: Context,
  zipFilePath: string,
  outputDirName?: string,
  useCustomPath?: boolean,
  customBasePath?: string
): Promise<string> {
  try {
    // 获取输出目录路径
    let outputDir: string;
    if (useCustomPath && customBasePath) {
      // 使用自定义基础路径
      outputDir = outputDirName ? `${customBasePath}/${outputDirName}` : customBasePath;
    } else if (outputDirName) {
      // 使用指定的输出目录名
      const boxPath = context.getApplicationContext().filesDir;
      outputDir = `${boxPath}/${outputDirName}`;
    } else {
      // 使用配置中的默认解压路径
      outputDir = getExtractPath(context);
    }

    // 创建解压输出目录
    ensureDirectoryExists(outputDir);

    // 检查 zip 文件是否存在
    if (!fs.accessSync(zipFilePath)) {
      throw new Error(`Zip file not found: ${zipFilePath}`);
    }

    hilog.info(DOMAIN, TAG, 'Extracting zip file: %{public}s to %{public}s', zipFilePath, outputDir);

    // 使用 zlib.decompressFile 解压文件（Promise 包装）
    await new Promise<void>((resolve, reject) => {
      zlib.decompressFile(zipFilePath, outputDir, {}, (err: Error | null) => {
        if (err) {
          reject(new Error(`解压失败: ${err.message || JSON.stringify(err)}`));
        } else {
          resolve();
        }
      });
    });

    // 验证解压结果：列出解压目录中的文件
    const fileList = listFilesInDirectory(outputDir);
    hilog.info(DOMAIN, TAG, 'Zip file extracted successfully to: %{public}s', outputDir);
    hilog.info(DOMAIN, TAG, 'Extracted files count: %{public}d', fileList.length);
    if (fileList.length > 0) {
      hilog.info(DOMAIN, TAG, 'Extracted files: %{public}s', fileList.join(', '));
    } else {
      hilog.warn(DOMAIN, TAG, 'Warning: No files found in extraction directory!');
    }

    return outputDir;
  } catch (error) {
    hilog.error(DOMAIN, TAG, 'Failed to extract zip file: %{public}s', JSON.stringify(error));
    throw new Error(`Failed to extract zip file: ${error instanceof Error ? error.message : JSON.stringify(error)}`);
  }
}

/**
 * 从 rawfile 复制并解压 zip 文件（一步完成）
 * @param context 应用上下文
 * @param rawFilePath rawfile 中的 zip 文件路径
 * @param sandboxDirName 沙箱目录名（可选，默认为 "webSources"）
 * @param extractDirName 解压目录名（可选，默认为 "webSources/extracted"）
 * @returns Promise 返回包含 zip 文件路径和解压目录路径的结果
 */
export async function copyAndExtractZipFile(
  context: Context,
  rawFilePath: string,
  sandboxDirName?: string,
  extractDirName?: string,
  useCustomPath?: boolean,
  customPath?: string
): Promise<ExtractResult> {
  try {
    // 先复制文件
    const zipPath = await copyRawFileToSandbox(
      context,
      rawFilePath,
      sandboxDirName,
      undefined,
      useCustomPath,
      customPath
    );

    // 然后解压文件
    const extractPath = await extractZipFile(
      context, 
      zipPath, 
      extractDirName, 
      useCustomPath,
      customPath || getDefaultStoragePath(context)
    );

    const result: ExtractResult = {
      zipPath: zipPath,
      extractPath: extractPath
    };
    return result;
  } catch (error) {
    hilog.error(DOMAIN, TAG, 'Failed to copy and extract zip file: %{public}s', JSON.stringify(error));
    throw new Error(`Failed to copy and extract zip file: ${error instanceof Error ? error.message : JSON.stringify(error)}`);
  }
}

/**
 * 为了向后兼容，导出一个 FileUtils 对象
 */
export const FileUtils: IFileUtils = {
  copyRawFileToSandbox: copyRawFileToSandbox,
  copyRawFileToSandboxSync: copyRawFileToSandboxSync,
  checkFileExists: checkFileExists,
  getSandboxFilePath: getSandboxFilePath,
  getBundleRootPath: getBundleRootPath,
  getHapsEntryFilePath: getHapsEntryFilePath,
  getDefaultStoragePath: getDefaultStoragePath,
  getExtractPath: getExtractPath,
  copyRawDirectoryFilesToSandbox: copyRawDirectoryFilesToSandbox,
  listFilesInDirectory: listFilesInDirectory,
  extractZipFile: extractZipFile,
  copyAndExtractZipFile: copyAndExtractZipFile
};

