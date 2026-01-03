# CMakeLists.txt for Native C++ module

cmake_minimum_required(VERSION 3.5.0)
project(NativeModule)

# 设置C++标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 添加源文件
add_library(native_module SHARED
    native_module.cpp
)

# 包含头文件目录
target_include_directories(native_module PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# 链接系统库
# 暂时不链接NAPI库，先确保基本编译通过
target_link_libraries(native_module PUBLIC
    # 基本库会在后续添加NAPI支持时链接
)

