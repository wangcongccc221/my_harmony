#ifndef NATIVE_MODULE_H
#define NATIVE_MODULE_H

#include <string>

// 简单的测试函数
extern "C" {
    // 返回一个字符串
    const char* getHelloString();
    
    // 计算两个数的和
    int addNumbers(int a, int b);
    
    // 获取版本号
    const char* getVersion();
}

#endif // NATIVE_MODULE_H

