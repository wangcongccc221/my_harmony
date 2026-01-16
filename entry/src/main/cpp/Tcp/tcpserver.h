#ifndef TCPSERVER_H
#define TCPSERVER_H

#include <string>
#include <vector>
#include <functional>
#include <thread>
#include <mutex>
#include <atomic>
#include <map>

// 对应原来的结构体
struct SendCMD
{
    int32_t SYNC;
    int32_t nSrcId;
    int32_t nDestId;
    int32_t nCmd;
};

struct CommandData
{
    int32_t nCmdId;
    int32_t nLength;
    std::vector<char> nData;
};

struct CommandHead
{
    int32_t nCmdId;
    int32_t nSrcId;
    int32_t nLength;
    bool nReadDataPack;
    // 回调函数指针，用于数据转换
    std::function<std::vector<char>(CommandData)> nChangeData;
};

class TcpServer
{
public:
    TcpServer();
    ~TcpServer();

    // 回调函数定义
    using SetDataLengthCallback = std::function<CommandHead(CommandHead)>;
    using SetBufferCallback = std::function<void(CommandHead, std::vector<char>)>;
    using SetReceiveCommandHeadCallback = std::function<void(CommandHead)>;

    bool Start(const std::string& ip, int16_t port, int32_t dstId, bool runOnce,
               SetDataLengthCallback setDataLength,
               SetBufferCallback setBuffer,
               SetReceiveCommandHeadCallback setReceiveCommandHead,
               int maxPendingConnections = 1);
               
    void DestroyMasterSocket();

private:
    void AcceptLoop();
    void CreateClientSocket(); // 对应原 CreateClientSocket
    bool RecvSync(int clientSocket);
    bool RecvCommand(int clientSocket, CommandHead* commandHead);
    bool RecvData(int clientSocket, CommandHead commandHead);
    int32_t BytesToInt(const std::vector<char>& bytes);
    
    // 辅助函数：接收指定长度的数据
    bool RecvN(int socket, char* buffer, size_t size);

private:
    bool m_RunOnce = false;
    std::atomic<bool> m_IsRunning = {false};
    int m_DstId = 0;
    int m_MasterSocket = -1;
    
    std::thread m_ServerThread;
    std::mutex m_Mutex;
    
    // 数据缓冲区
    std::vector<char> m_Data;

    // 回调
    SetDataLengthCallback m_setDataLength;
    SetBufferCallback m_setBuffer;
    SetReceiveCommandHeadCallback m_setReceiveCommandHead;
};

#endif // TCPSERVER_H
