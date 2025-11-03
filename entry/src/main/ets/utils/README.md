# FileUtils 使用说明

这是一个纯函数式的文件工具库，用于在 HarmonyOS 应用中处理 rawfile 文件操作。

## ⚙️ 路径配置

**重要**：所有文件存储路径都通过 `PathConfig` 集中管理，只需修改配置即可更改所有路径，无需修改业务代码。

### 配置文件位置

在 `FileUtils.ets` 文件开头的 `PathConfig` 对象：

```typescript
export const PathConfig: IPathConfig = {
  // 存储模式：'haps' 使用 haps/entry/file，'sandbox' 使用 filesDir
  storageMode: 'haps',
  
  // 当 storageMode = 'sandbox' 时使用的目录名
  sandboxDirName: 'webSources',
  
  // 当 storageMode = 'haps' 时使用的路径（相对于包根目录）
  hapsPath: 'haps/entry/file',
  
  // 解压文件的子目录（相对于存储目录）
  extractSubDir: 'extracted'
};
```

### 如何修改路径

#### 方式1：切换存储模式

```typescript
// 使用 haps 模式（默认）
storageMode: 'haps',
// 文件将存储在：/data/storage/el1/bundle/{包名}/haps/entry/file/

// 使用 sandbox 模式
storageMode: 'sandbox',
// 文件将存储在：/data/storage/el1/bundle/{包名}/files/webSources/
```

#### 方式2：修改具体路径

```typescript
// 修改 haps 路径
hapsPath: 'haps/entry/custom',  // 改成你想要的路径

// 修改 sandbox 目录名
sandboxDirName: 'myData',  // 改成你想要的目录名

// 修改解压目录
extractSubDir: 'unzipped',  // 改成你想要的解压目录名
```

## 📦 导入方式

### 方式1：按需导入（推荐）

```typescript
import { 
  copyRawFileToSandbox,
  extractZipFile,
  copyAndExtractZipFile,
  getDefaultStoragePath,
  getExtractPath,
  checkFileExists,
  copyRawDirectoryFilesToSandbox,
  listFilesInDirectory,
  PathConfig
} from '../utils/FileUtils';
```

### 方式2：导入整个工具对象（向后兼容）

```typescript
import { FileUtils } from '../utils/FileUtils';

// 使用方式
await FileUtils.copyRawFileToSandbox(context, 'file.zip');
```

## 🚀 使用示例

### 1. 复制单个文件（使用配置中的默认路径）

```typescript
import { copyRawFileToSandbox, getDefaultStoragePath } from '../utils/FileUtils';
import getContext from '@ohos.app.ability.common';
import { common } from '@kit.AbilityKit';

// 在页面组件中
async copyFile() {
  const context = getContext(this) as common.UIAbilityContext;
  
  // 复制文件（使用配置中的默认路径）
  const filePath = await copyRawFileToSandbox(
    context,
    'file.zip',      // rawfile 中的文件路径
    undefined,       // 不指定目录，使用配置中的默认路径
    'file.zip'       // 目标文件名（可选，默认使用原文件名）
  );
  
  console.log('文件已复制到:', filePath);
  // 如果 storageMode = 'haps'，路径类似：
  // /data/storage/el1/bundle/com.example.app/haps/entry/file/file.zip
}
```

### 2. 复制到指定目录（覆盖配置）

```typescript
// 复制到指定的 sandbox 目录（忽略配置）
const filePath = await copyRawFileToSandbox(
  context,
  'file.zip',
  'customDir',  // 指定目录，将覆盖配置
  'file.zip'
);
```

### 3. 检查文件是否存在

```typescript
import { checkFileExists, getDefaultStoragePath } from '../utils/FileUtils';

// 使用默认存储路径
const storagePath = getDefaultStoragePath(context);
const filePath = `${storagePath}/file.zip`;

// 或者使用工具函数检查（需要在 sandbox 模式下）
const exists = checkFileExists(context, 'file.zip', 'webSources');
```

### 4. 解压 ZIP 文件（使用配置中的默认路径）

```typescript
import { extractZipFile, getDefaultStoragePath, getExtractPath } from '../utils/FileUtils';

async extractZip() {
  const context = getContext(this) as common.UIAbilityContext;
  
  // 获取默认存储路径中的 zip 文件
  const storagePath = getDefaultStoragePath(context);
  const zipPath = `${storagePath}/file.zip`;
  
  // 解压文件（使用配置中的默认解压路径）
  const extractPath = await extractZipFile(context, zipPath);
  
  console.log('解压路径:', extractPath);
  // 如果 storageMode = 'haps'，路径类似：
  // /data/storage/el1/bundle/com.example.app/haps/entry/file/extracted/
}
```

### 5. 一步完成：复制并解压

```typescript
import { copyAndExtractZipFile } from '../utils/FileUtils';

async copyAndExtract() {
  const context = getContext(this) as common.UIAbilityContext;
  
  // 使用配置中的默认路径
  const result = await copyAndExtractZipFile(
    context,
    'file.zip'  // rawfile 中的 zip 文件路径
  );
  
  console.log('ZIP 路径:', result.zipPath);
  console.log('解压路径:', result.extractPath);
}
```

### 6. 递归复制整个文件夹

```typescript
import { copyRawDirectoryFilesToSandbox } from '../utils/FileUtils';

async copyFolder() {
  const context = getContext(this) as common.UIAbilityContext;
  
  // 定义要复制的文件列表（相对路径）
  const fileList = [
    '123.txt',
    '新建文本文档.txt',
    '1/新建文本文档.txt',
    '2/新建文本文档.txt',
    '3/新建文本文档.txt'
  ];
  
  // 使用配置中的默认路径
  const result = await copyRawDirectoryFilesToSandbox(
    context,
    'file',           // rawfile 中的文件夹路径
    fileList,          // 文件列表
    undefined,         // 使用配置中的默认路径
    'file'             // 目标文件夹名（可选）
  );
  
  console.log('目标路径:', result.targetPath);
  console.log('复制文件数:', result.fileCount);
  console.log('文件列表:', result.fileList);
}
```

### 7. 列出目录中的文件

```typescript
import { listFilesInDirectory, getDefaultStoragePath } from '../utils/FileUtils';

const context = getContext(this) as common.UIAbilityContext;
const storagePath = getDefaultStoragePath(context);
const fileList = listFilesInDirectory(storagePath);
console.log('文件列表:', fileList);
// 输出: ['file1.txt', 'file2.txt', 'subdir/file3.txt', ...]
```

### 8. 获取路径信息

```typescript
import { 
  getDefaultStoragePath, 
  getExtractPath, 
  getBundleRootPath,
  PathConfig 
} from '../utils/FileUtils';

const context = getContext(this) as common.UIAbilityContext;

// 获取默认存储路径（根据配置自动选择）
const storagePath = getDefaultStoragePath(context);

// 获取解压路径
const extractPath = getExtractPath(context);

// 获取包根目录
const bundleRoot = getBundleRootPath(context);

// 查看当前配置
console.log('存储模式:', PathConfig.storageMode);
console.log('存储路径:', storagePath);
```

## 📝 API 参考

### `copyRawFileToSandbox`
复制 rawfile 中的文件到存储目录

**参数：**
- `context: Context` - 应用上下文
- `rawFilePath: string` - rawfile 中的文件路径
- `sandboxDirName?: string` - 沙箱目录名（可选，不指定则使用配置中的默认路径）
- `fileName?: string` - 目标文件名（可选，默认使用原文件名）
- `useCustomPath?: boolean` - 是否使用自定义路径（高级用法）
- `customPath?: string` - 自定义路径（高级用法）

**返回：** `Promise<string>` - 存储目录中的完整文件路径

### `extractZipFile`
解压 ZIP 文件

**参数：**
- `context: Context` - 应用上下文
- `zipFilePath: string` - zip 文件的完整路径
- `outputDirName?: string` - 解压输出目录（可选，不指定则使用配置中的默认路径）
- `useCustomPath?: boolean` - 是否使用自定义路径（高级用法）
- `customBasePath?: string` - 自定义基础路径（高级用法）

**返回：** `Promise<string>` - 解压后的目录路径

### `copyAndExtractZipFile`
复制并解压 ZIP 文件（一步完成）

**参数：**
- `context: Context` - 应用上下文
- `rawFilePath: string` - rawfile 中的 zip 文件路径
- `sandboxDirName?: string` - 沙箱目录名（可选）
- `extractDirName?: string` - 解压目录名（可选）
- `useCustomPath?: boolean` - 是否使用自定义路径（高级用法）
- `customPath?: string` - 自定义路径（高级用法）

**返回：** `Promise<ExtractResult>` - 包含 zipPath 和 extractPath

### `copyRawDirectoryFilesToSandbox`
递归复制文件夹中的所有文件

**参数：**
- `context: Context` - 应用上下文
- `rawFileDir: string` - rawfile 中的文件夹路径
- `fileList: string[]` - 文件列表（相对路径）
- `sandboxDirName?: string` - 沙箱目录名（可选，不指定则使用配置中的默认路径）
- `targetDirName?: string` - 目标文件夹名（可选，默认使用原文件夹名）
- `useCustomPath?: boolean` - 是否使用自定义路径（高级用法）
- `customPath?: string` - 自定义路径（高级用法）

**返回：** `Promise<DirectoryCopyResult>` - 包含 targetPath, fileCount, fileList

### `getDefaultStoragePath`
获取默认存储目录路径（根据配置自动选择）

**参数：**
- `context: Context` - 应用上下文

**返回：** `string` - 默认存储目录的完整路径

### `getExtractPath`
获取解压目录路径

**参数：**
- `context: Context` - 应用上下文
- `subDir?: string` - 子目录名（可选，不指定则使用配置中的 extractSubDir）

**返回：** `string` - 解压目录的完整路径

### `getBundleRootPath`
获取应用包根目录路径

**参数：**
- `context: Context` - 应用上下文

**返回：** `string` - 应用包根目录路径（例如: /data/storage/el1/bundle/com.example.app）

### `getHapsEntryFilePath`
获取 haps/entry/file 目录路径

**参数：**
- `context: Context` - 应用上下文

**返回：** `string` - haps/entry/file 的完整路径

### `checkFileExists`
检查文件是否存在

**参数：**
- `context: Context` - 应用上下文
- `fileName: string` - 文件名
- `sandboxDirName?: string` - 沙箱目录名（默认: 'webSources'）

**返回：** `boolean` - 文件是否存在

### `listFilesInDirectory`
列出目录中的所有文件（递归）

**参数：**
- `dirPath: string` - 目录路径

**返回：** `string[]` - 文件列表（包含子目录中的文件）

## 💡 使用场景

### 场景1：加载离线资源

```typescript
// 在应用启动时加载离线资源（使用配置中的默认路径）
async function loadOfflineResources(context: Context) {
  try {
    // 复制配置文件（使用默认路径）
    await copyRawFileToSandbox(context, 'config.json');
    
    // 复制并解压资源包（使用默认路径）
    const result = await copyAndExtractZipFile(context, 'resources.zip');
    console.log('资源已加载:', result.extractPath);
  } catch (error) {
    console.error('加载失败:', error);
  }
}
```

### 场景2：动态更新资源

```typescript
import { getDefaultStoragePath, listFilesInDirectory } from '../utils/FileUtils';

async function updateResources(context: Context) {
  const storagePath = getDefaultStoragePath(context);
  const configPath = `${storagePath}/config.json`;
  
  // 检查文件是否存在
  try {
    const files = listFilesInDirectory(storagePath);
    if (files.includes('config.json')) {
      // 可以在这里删除旧文件
      // fs.unlinkSync(configPath);
    }
  } catch (e) {
    // 文件不存在，继续
  }
  
  // 复制新文件
  await copyRawFileToSandbox(context, 'config.json');
}
```

### 场景3：处理文件夹资源

```typescript
// 复制整个资源文件夹（使用默认路径）
async function loadResourceFolder(context: Context) {
  const fileList = [
    'index.html',
    'style.css',
    'script.js',
    'images/logo.png',
    'images/icon.png',
    'data/config.json'
  ];
  
  const result = await copyRawDirectoryFilesToSandbox(
    context,
    'resources',
    fileList
    // 不指定目录，使用配置中的默认路径
  );
  
  console.log(`已加载 ${result.fileCount} 个文件到: ${result.targetPath}`);
}
```

## ⚠️ 注意事项

1. **路径配置优先**：如果不指定 `sandboxDirName` 参数，函数会自动使用 `PathConfig` 中配置的默认路径
2. **Context 获取**：在页面组件中需要使用 `getContext(this)` 获取上下文
3. **文件路径**：rawfile 中的文件路径是相对于 `resources/rawfile/` 目录的
4. **异步操作**：大部分函数都是异步的，需要使用 `await` 或 `.then()`
5. **错误处理**：建议使用 `try-catch` 包裹所有文件操作
6. **路径修改**：修改 `PathConfig` 后，所有使用默认路径的函数会自动使用新路径

## 🔗 相关接口

- `ExtractResult` - 解压结果接口
  ```typescript
  interface ExtractResult {
    zipPath: string;      // ZIP 文件路径
    extractPath: string;   // 解压目录路径
  }
  ```

- `DirectoryCopyResult` - 目录复制结果接口
  ```typescript
  interface DirectoryCopyResult {
    targetPath: string;   // 目标路径
    fileCount: number;    // 复制文件数
    fileList: string[];   // 文件列表
  }
  ```

- `IPathConfig` - 路径配置接口
  ```typescript
  interface IPathConfig {
    storageMode: 'haps' | 'sandbox';  // 存储模式
    sandboxDirName: string;           // sandbox 目录名
    hapsPath: string;                 // haps 路径
    extractSubDir: string;            // 解压子目录
  }
  ```

## 📍 路径说明

### haps 模式（默认）

```
/data/storage/el1/bundle/{应用包名}/haps/entry/file/
├── file.zip              # 复制的文件
├── 123.txt
├── file/                 # 复制的文件夹
│   └── ...
└── extracted/            # 解压的文件
    └── ...
```

### sandbox 模式

```
/data/storage/el1/bundle/{应用包名}/files/webSources/
├── file.zip              # 复制的文件
├── 123.txt
├── file/                 # 复制的文件夹
│   └── ...
└── extracted/            # 解压的文件
    └── ...
```

## 🔄 迁移指南

### 从旧版本迁移

如果你之前使用硬编码的路径：

```typescript
// 旧方式（硬编码）
await copyRawFileToSandbox(context, 'file.zip', 'webSources');
```

```typescript
// 新方式（推荐 - 使用配置）
await copyRawFileToSandbox(context, 'file.zip');
// 或者
await copyRawFileToSandbox(context, 'file.zip', undefined);
```

如果需要指定特定目录，仍可以传入参数：

```typescript
// 指定特定目录（覆盖配置）
await copyRawFileToSandbox(context, 'file.zip', 'customDir');
```

