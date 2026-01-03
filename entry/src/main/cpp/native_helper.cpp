#include "native_module.h"
#include <cstring>
#include <string>

// 辅助函数：处理字符串
std::string processString(const std::string& input) {
    return "Processed: " + input;
}

// 辅助函数：计算
int calculate(int x, int y, char op) {
    switch(op) {
        case '+':
            return x + y;
        case '-':
            return x - y;
        case '*':
            return x * y;
        case '/':
            return y != 0 ? x / y : 0;
        default:
            return 0;
    }
}

