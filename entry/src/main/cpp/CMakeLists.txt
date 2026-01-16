# CMakeLists.txt for Native C++ module

cmake_minimum_required(VERSION 3.5.0)
project(NativeModule)

# 设置C++标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 添加源文件
add_library(native_module SHARED
    native_module.cpp
    Tcp/tcpclient.cpp
    Tcp/tcpserver.cpp
    Tcp/udpclient.cpp
    Tcp/udpserver.cpp
    Tcp/socketserver.cpp

)

# 包含头文件目录
target_include_directories(native_module PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/Tcp
)

# 链接系统库
target_link_libraries(native_module PUBLIC
    libace_napi.z.so
    libhilog_ndk.z.so
)

