#include "native_module.h"
#include <cstring>

// 返回Hello字符串
const char* getHelloString() {
    static const char* hello = "Hello from Native C++!";
    return hello;
}

// 计算两个数的和
int addNumbers(int a, int b) {
    return a + b;
}

// 获取版本号
const char* getVersion() {
    static const char* version = "1.0.0";
    return version;
}

