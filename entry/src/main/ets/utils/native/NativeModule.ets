/**
 * Native C++ 模块调用接口
 * 用于调用C++代码
 * 
 * 注意：当前版本暂时无法直接调用C++函数（需要NAPI接口）
 * 这个文件保留用于后续添加NAPI支持
 */

// 暂时注释掉，等NAPI接口配置好后再启用
// import nativeModule from 'libnative_module.so';

/**
 * Native模块接口
 */
export class NativeModule {
  /**
   * 获取Hello字符串
   * @returns Hello字符串
   */
  static getHelloString(): string {
    // TODO: 等NAPI接口配置好后启用
    // try {
    //   return nativeModule.getHelloString();
    // } catch (error) {
    //   console.error('NativeModule.getHelloString error:', error);
    //   return 'Error calling native function';
    // }
    return 'Native C++ 模块已编译，但NAPI接口尚未配置';
  }

  /**
   * 计算两个数的和
   * @param a 第一个数
   * @param b 第二个数
   * @returns 两数之和
   */
  static addNumbers(a: number, b: number): number {
    // TODO: 等NAPI接口配置好后启用
    // try {
    //   return nativeModule.addNumbers(a, b);
    // } catch (error) {
    //   console.error('NativeModule.addNumbers error:', error);
    //   return 0;
    // }
    return a + b; // 暂时返回计算结果
  }

  /**
   * 获取版本号
   * @returns 版本号字符串
   */
  static getVersion(): string {
    // TODO: 等NAPI接口配置好后启用
    // try {
    //   return nativeModule.getVersion();
    // } catch (error) {
    //   console.error('NativeModule.getVersion error:', error);
    //   return 'Unknown';
    // }
    return '1.0.0 (NAPI未配置)';
  }
}

// 导出默认实例
export default NativeModule;

