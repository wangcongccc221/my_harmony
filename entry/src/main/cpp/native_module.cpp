#include "napi/native_api.h"
#include "native_module.h"
#include "Tcp/socketserver.h"
#include "Tcp/tcpclient.h"
#include "Tcp/tcpserver.h"
#include "Tcp/structures.h"
#include <string>
#include <memory>
#include <vector>
#include <cstring>
#include <iostream>

#include <hilog/log.h>

#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0x3d00 // 自定义Domain
#define LOG_TAG "NativeModule" // 自定义Tag

// ===================== 基础测试函数 NAPI Binding =====================

static napi_value NapiGetHelloString(napi_env env, napi_callback_info info) {
    const char* str = "Hello from Native C++!"; // 简单直接返回，或者调用 C 函数
    napi_value result;
    napi_create_string_utf8(env, str, NAPI_AUTO_LENGTH, &result);
    return result;
}

static napi_value NapiAddNumbers(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int32_t a, b;
    napi_get_value_int32(env, args[0], &a);
    napi_get_value_int32(env, args[1], &b);

    napi_value result;
    napi_create_int32(env, a + b, &result);
    return result;
}

static napi_value NapiGetVersion(napi_env env, napi_callback_info info) {
    const char* str = "1.0.0";
    napi_value result;
    napi_create_string_utf8(env, str, NAPI_AUTO_LENGTH, &result);
    return result;
}

// ===================== SocketServer (PLC) NAPI Binding =====================

static std::unique_ptr<SocketServer> g_socketServer;

static void CallJsSocketServerData(napi_env env, napi_value js_cb, void* context, void* data) {
    // data 结构: IP(string) + Data(vector<char>)
    struct CallbackData {
        std::string ip;
        std::vector<char> buffer;
    };
    auto* cbData = static_cast<CallbackData*>(data);

    // 1. IP 参数
    napi_value clientIp;
    napi_create_string_utf8(env, cbData->ip.c_str(), NAPI_AUTO_LENGTH, &clientIp);

    // 2. Data 参数 (Uint8Array)
    void* bufferData;
    napi_value arrayBuffer;
    napi_create_arraybuffer(env, cbData->buffer.size(), &bufferData, &arrayBuffer);
    memcpy(bufferData, cbData->buffer.data(), cbData->buffer.size());
    
    napi_value uint8Array;
    napi_create_typedarray(env, napi_uint8_array, cbData->buffer.size(), arrayBuffer, 0, &uint8Array);

    napi_value args[2] = { clientIp, uint8Array };
    napi_value result;
    napi_call_function(env, nullptr, js_cb, 2, args, &result);
    
    delete cbData;
}

static napi_value SocketServer_Start(napi_env env, napi_callback_info info) {
    size_t argc = 3;
    napi_value args[3] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    char ip[64];
    size_t len;
    napi_get_value_string_utf8(env, args[0], ip, 64, &len);

    int port;
    napi_get_value_int32(env, args[1], &port);

    // 回调函数
    napi_value resourceName;
    napi_create_string_utf8(env, "SocketServerData", NAPI_AUTO_LENGTH, &resourceName);
    
    napi_threadsafe_function tsfn;
    napi_create_threadsafe_function(env, args[2], nullptr, resourceName, 0, 1, nullptr, nullptr, nullptr, CallJsSocketServerData, &tsfn);

    if (!g_socketServer) {
        g_socketServer = std::make_unique<SocketServer>();
    }

    g_socketServer->SetOnDataReceived([tsfn](const std::string& clientIP, const std::vector<char>& data) {
        struct CallbackData {
            std::string ip;
            std::vector<char> buffer;
        };
        auto* cbData = new CallbackData{clientIP, data};
        napi_call_threadsafe_function(tsfn, cbData, napi_tsfn_nonblocking);
    });

    bool success = g_socketServer->Start(std::string(ip), port);
    
    napi_value result;
    napi_get_boolean(env, success, &result);
    return result;
}

static napi_value SocketServer_SendData(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    void* data = nullptr;
    size_t length = 0;
    
    bool isTypedArray;
    napi_is_typedarray(env, args[0], &isTypedArray);
    if (isTypedArray) {
        napi_typedarray_type type;
        napi_value input_buffer;
        size_t byte_offset;
        napi_get_typedarray_info(env, args[0], &type, &length, &data, &input_buffer, &byte_offset);
    } else {
        napi_get_arraybuffer_info(env, args[0], &data, &length);
    }

    bool success = false;
    if (g_socketServer && data) {
        std::vector<char> vecData((char*)data, (char*)data + length);
        success = g_socketServer->SendData(vecData);
    }

    napi_value result;
    napi_get_boolean(env, success, &result);
    return result;
}

static napi_value SocketServer_Destroy(napi_env env, napi_callback_info info) {
    if (g_socketServer) {
        g_socketServer->Destroy();
        g_socketServer.reset();
    }
    return nullptr;
}

// ===================== TcpClient NAPI Binding =====================

// 全局实例
static std::unique_ptr<TcpClient> g_tcpClient;

static void CallJsTcpClientDataReceived(napi_env env, napi_value js_cb, void* context, void* data) {
    auto* vecData = static_cast<std::vector<char>*>(data);
    
    // 创建 ArrayBuffer
    void* bufferData;
    napi_value arrayBuffer;
    napi_create_arraybuffer(env, vecData->size(), &bufferData, &arrayBuffer);
    memcpy(bufferData, vecData->data(), vecData->size());
    
    // 创建 Uint8Array
    napi_value uint8Array;
    napi_create_typedarray(env, napi_uint8_array, vecData->size(), arrayBuffer, 0, &uint8Array);

    napi_value result;
    napi_call_function(env, nullptr, js_cb, 1, &uint8Array, &result);
    
    delete vecData;
}

static napi_value TcpClient_Connect(napi_env env, napi_callback_info info) {
    size_t argc = 3;
    napi_value args[3] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    char ip[64];
    size_t len;
    napi_get_value_string_utf8(env, args[0], ip, 64, &len);

    int port;
    napi_get_value_int32(env, args[1], &port);

    // 回调函数
    napi_value resourceName;
    napi_create_string_utf8(env, "TcpClientDataReceived", NAPI_AUTO_LENGTH, &resourceName);
    
    napi_threadsafe_function tsfn;
    napi_create_threadsafe_function(env, args[2], nullptr, resourceName, 0, 1, nullptr, nullptr, nullptr, CallJsTcpClientDataReceived, &tsfn);

    if (!g_tcpClient) {
        g_tcpClient = std::make_unique<TcpClient>();
    }

    g_tcpClient->SetOnDataReceived([tsfn](const std::vector<char>& data) {
        auto* vecData = new std::vector<char>(data);
        napi_call_threadsafe_function(tsfn, vecData, napi_tsfn_nonblocking);
    });

    bool success = g_tcpClient->ConnectServer(std::string(ip), port);
    
    napi_value result;
    napi_get_boolean(env, success, &result);
    return result;
}

static napi_value TcpClient_Send(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    void* data = nullptr;
    size_t length = 0;
    
    bool isTypedArray;
    napi_is_typedarray(env, args[0], &isTypedArray);
    if (isTypedArray) {
        napi_typedarray_type type;
        napi_value input_buffer;
        size_t byte_offset;
        napi_get_typedarray_info(env, args[0], &type, &length, &data, &input_buffer, &byte_offset);
    } else {
        napi_get_arraybuffer_info(env, args[0], &data, &length);
    }

    bool success = false;
    if (g_tcpClient && data) {
        std::vector<char> vecData((char*)data, (char*)data + length);
        success = g_tcpClient->Send(vecData);
    }

    napi_value result;
    napi_get_boolean(env, success, &result);
    return result;
}

static napi_value TcpClient_Destroy(napi_env env, napi_callback_info info) {
    if (g_tcpClient) {
        g_tcpClient->DestroySocket();
        g_tcpClient.reset();
    }
    return nullptr;
}

// ===================== TcpServer (业务) NAPI Binding =====================

// 全局实例
static std::unique_ptr<TcpServer> g_tcpServer;

static void CallJsTcpServerBuffer(napi_env env, napi_value js_cb, void* context, void* data) {
    // data 是一个结构，包含 CommandHead 和 数据
    // 这里为了简化，我们假设传回一个对象：{ cmdId, srcId, data }
    struct CallbackData {
        CommandHead head;
        std::vector<char> buffer;
    };
    auto* cbData = static_cast<CallbackData*>(data);

    napi_value obj;
    napi_create_object(env, &obj);

    napi_value cmdId, srcId, len;
    napi_create_int32(env, cbData->head.nCmdId, &cmdId);
    napi_create_int32(env, cbData->head.nSrcId, &srcId);
    napi_create_int32(env, cbData->head.nLength, &len);

    napi_set_named_property(env, obj, "cmdId", cmdId);
    napi_set_named_property(env, obj, "srcId", srcId);
    napi_set_named_property(env, obj, "length", len);

    // Data
    void* bufferData;
    napi_value arrayBuffer;
    napi_create_arraybuffer(env, cbData->buffer.size(), &bufferData, &arrayBuffer);
    memcpy(bufferData, cbData->buffer.data(), cbData->buffer.size());
    
    napi_value uint8Array;
    napi_create_typedarray(env, napi_uint8_array, cbData->buffer.size(), arrayBuffer, 0, &uint8Array);
    napi_set_named_property(env, obj, "data", uint8Array);

    napi_value result;
    napi_call_function(env, nullptr, js_cb, 1, &obj, &result);
    
    delete cbData;
}

static napi_value TcpServer_Start(napi_env env, napi_callback_info info) {
    size_t argc = 4;
    napi_value args[4] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    char ip[64];
    size_t len;
    napi_get_value_string_utf8(env, args[0], ip, 64, &len);

    int port;
    napi_get_value_int32(env, args[1], &port);

    int dstId;
    napi_get_value_int32(env, args[2], &dstId);

    // 回调函数
    napi_value resourceName;
    napi_create_string_utf8(env, "TcpServerCallback", NAPI_AUTO_LENGTH, &resourceName);
    
    napi_threadsafe_function tsfn;
    napi_create_threadsafe_function(env, args[3], nullptr, resourceName, 0, 1, nullptr, nullptr, nullptr, CallJsTcpServerBuffer, &tsfn);

    if (!g_tcpServer) {
        g_tcpServer = std::make_unique<TcpServer>();
    }

    // 设置回调
    auto setDataLength = [](CommandHead head) -> CommandHead {
        std::cout << "[TCP] Mapping Data Length for Command ID: " << head.nCmdId << std::endl;
        switch (head.nCmdId) {
            // FSM Commands
            case FSM_HC_COMMAND_TYPE::FSM_CMD_CONFIG:
                head.nLength = sizeof(StGlobal);
                break;
            case FSM_HC_COMMAND_TYPE::FSM_CMD_STATISTICS:
                head.nLength = sizeof(StStatistics);
                break;
            case FSM_HC_COMMAND_TYPE::FSM_CMD_WEIGHTINFO:
                head.nLength = sizeof(StWeightResult);
                break;
            case FSM_HC_COMMAND_TYPE::FSM_CMD_GRADEINFO:
                head.nLength = sizeof(StFruitGradeInfo);
                break;
            case FSM_HC_COMMAND_TYPE::FSM_CMD_WAVEINFO:
                head.nLength = sizeof(StWaveInfo);
                break;
            case FSM_HC_COMMAND_TYPE::FSM_CMD_VERSIONERROR:
                head.nLength = sizeof(int);
                break;
            case FSM_HC_COMMAND_TYPE::FSM_CMD_BURN_FLASH_PROGRESS:
            case FSM_HC_COMMAND_TYPE::FSM_CMD_BOOT_FLASH_PROGRESS:
                head.nLength = sizeof(int);
                break;
            case FSM_HC_COMMAND_TYPE::FSM_CMD_GETVERSION:
                head.nLength = ConstPreDefine::BYTE_NUM_FSM_VERSION;
                break;
            case WAM_HC_COMMAND_TYPE::WAM_CMD_REP_WAM_INFO:
                head.nLength = ConstPreDefine::BYTE_NUM_FSM_VERSION;
                break;
            case WAM_HC_COMMAND_TYPE::WAM_CMD_WEIGHTINFO:
                head.nLength = sizeof(StWeightResult);
                break;
            case WAM_HC_COMMAND_TYPE::WAM_CMD_WAVEINFO:
                head.nLength = sizeof(StWaveInfo);
                break;
            case WAM_HC_COMMAND_TYPE::WAM__CMD_WEIGHT_INFO:
                head.nLength = sizeof(StWeightGlobal);
                break;
            case SIM_HMI_COMMAND_TYPE::SIM_HMI_DISPLAY_ON:
            case SIM_HMI_COMMAND_TYPE::SIM_HMI_INSPECTION_OFF:
                head.nLength = 0;
                break;
            case SIM_HMI_COMMAND_TYPE::SIM_HMI_INSPECTION_ON:
                head.nLength = sizeof(StGradeInfo);
                break;

            // IPM Commands (Variable Length Images)
            case IPM_HC_COMMAND_TYPE::IPM_CMD_IMAGE:
            case IPM_HC_COMMAND_TYPE::IPM_CMD_IMAGE_SPLICE:
            case IPM_HC_COMMAND_TYPE::IPM_CMD_IMAGE_SPOT:
                head.nLength = sizeof(int); // Read 4 bytes length first
                head.nReadDataPack = true;  // Flag to re-read body based on this length
                break;
            
            case IPM_HC_COMMAND_TYPE::IPM_CMD_AUTOBALANCE_COEFFICIENT:
                head.nLength = sizeof(StWhiteBalanceCoefficient);
                break;
            case IPM_HC_COMMAND_TYPE::IPM_CMD_SHUTTER_ADJUST:
                head.nLength = sizeof(StShutterAdjust);
                break;

            // ACS Commands
            case ACS_HMI_COMMAND_TYPE::ACS_HMI_EXIT_STOP:
                head.nLength = sizeof(int);
                break;

            default:
                std::cout << "[TCP] Unknown Command ID: " << head.nCmdId << ", setting length to 0." << std::endl;
                head.nLength = 0;
                break;
        }
        if (head.nLength > 0) {
            std::cout << "[TCP] Expecting " << head.nLength << " bytes for Command ID " << head.nCmdId << std::endl;
        }
        return head;
    };

    auto setBuffer = [tsfn](CommandHead head, std::vector<char> data) {
        struct CallbackData {
            CommandHead head;
            std::vector<char> buffer;
        };
        auto* cbData = new CallbackData{head, data};
        napi_call_threadsafe_function(tsfn, cbData, napi_tsfn_nonblocking);
    };

    auto setReceiveCommandHead = [](CommandHead head) {
        // 可选实现
    };

    bool success = g_tcpServer->Start(std::string(ip), port, dstId, false, setDataLength, setBuffer, setReceiveCommandHead);
    
    napi_value result;
    napi_get_boolean(env, success, &result);
    return result;
}

static napi_value TcpServer_Destroy(napi_env env, napi_callback_info info) {
    if (g_tcpServer) {
        g_tcpServer->DestroyMasterSocket();
        g_tcpServer.reset();
    }
    return nullptr;
}

// 模块初始化
EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
        { "getHelloString", nullptr, NapiGetHelloString, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "addNumbers", nullptr, NapiAddNumbers, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "getVersion", nullptr, NapiGetVersion, nullptr, nullptr, nullptr, napi_default, nullptr },
        
        // SocketServer
        { "socketServerStart", nullptr, SocketServer_Start, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "socketServerSendData", nullptr, SocketServer_SendData, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "socketServerDestroy", nullptr, SocketServer_Destroy, nullptr, nullptr, nullptr, napi_default, nullptr },

        // TcpClient
        { "tcpClientConnect", nullptr, TcpClient_Connect, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "tcpClientSend", nullptr, TcpClient_Send, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "tcpClientDestroy", nullptr, TcpClient_Destroy, nullptr, nullptr, nullptr, napi_default, nullptr },

        // TcpServer
        { "tcpServerStart", nullptr, TcpServer_Start, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "tcpServerDestroy", nullptr, TcpServer_Destroy, nullptr, nullptr, nullptr, napi_default, nullptr }
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "native_module",
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterNativeModule(void) {
    napi_module_register(&demoModule);
}
