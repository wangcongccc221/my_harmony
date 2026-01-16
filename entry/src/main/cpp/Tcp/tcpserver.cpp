#include "tcpserver.h"
#include "structures.h"
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <iostream>
#include <cstring>
#include <vector>
#include <hilog/log.h>

#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0x0001
#define LOG_TAG "TcpServer"

TcpServer::TcpServer()
{
    m_IsRunning = true;
}

TcpServer::~TcpServer()
{
    m_IsRunning = false;
    DestroyMasterSocket();
    if (m_ServerThread.joinable()) {
        m_ServerThread.join();
    }
}

bool TcpServer::Start(const std::string& ip, int16_t port, int32_t dstId, bool runOnce,
                      SetDataLengthCallback setDataLength,
                      SetBufferCallback setBuffer,
                      SetReceiveCommandHeadCallback setReceiveCommandHead,
                      int maxPendingConnections)
{
    m_RunOnce = runOnce;
    m_DstId = dstId;
    m_setDataLength = setDataLength;
    m_setBuffer = setBuffer;
    m_setReceiveCommandHead = setReceiveCommandHead;

    m_MasterSocket = socket(AF_INET, SOCK_STREAM, 0);
    if (m_MasterSocket == -1) {
        return false;
    }

    int opt = 1;
    setsockopt(m_MasterSocket, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));

    sockaddr_in serverAddr;
    serverAddr.sin_family = AF_INET;
    serverAddr.sin_port = htons(port);
    if (ip.empty()) {
        serverAddr.sin_addr.s_addr = INADDR_ANY;
    } else {
        inet_pton(AF_INET, ip.c_str(), &serverAddr.sin_addr);
    }

    if (bind(m_MasterSocket, (struct sockaddr*)&serverAddr, sizeof(serverAddr)) < 0) {
        close(m_MasterSocket);
        return false;
    }

    if (listen(m_MasterSocket, maxPendingConnections) < 0) {
        close(m_MasterSocket);
        return false;
    }
    
    m_IsRunning = true;
    m_ServerThread = std::thread(&TcpServer::CreateClientSocket, this);
    
    return true;
}

void TcpServer::DestroyMasterSocket()
{
    if (m_MasterSocket != -1) {
        close(m_MasterSocket);
        m_MasterSocket = -1;
    }
}

void TcpServer::CreateClientSocket()
{
    bool rc = true;
    CommandHead head;

    while (m_IsRunning) {
        if (m_MasterSocket == -1) break;

        sockaddr_in clientAddr;
        socklen_t len = sizeof(clientAddr);
        int clientSocket = accept(m_MasterSocket, (struct sockaddr*)&clientAddr, &len);
        
        if (clientSocket < 0) {
            continue;
        }

        // 获取客户端IP
        char clientIp[INET_ADDRSTRLEN];
        inet_ntop(AF_INET, &(clientAddr.sin_addr), clientIp, INET_ADDRSTRLEN);
        std::cout << "[TCP] Client Connected: " << clientIp << " came" << std::endl;

        // 注意：原代码逻辑是单线程处理一个连接，或者需要改为多线程
        // 这里尽可能还原原代码逻辑
        
        head.nCmdId = -1;
        head.nSrcId = -1;
        head.nLength = 0;
        head.nReadDataPack = false;
        head.nChangeData = nullptr;

        rc = RecvSync(clientSocket);
        if (rc) {
            head.nLength = 0;
            rc = RecvCommand(clientSocket, &head);
            if (rc) {
                // Log received command info
                std::cout << "[TCP] Received Command ID: " << head.nCmdId << ", SrcID: " << head.nSrcId << std::endl;

                if (m_setDataLength) {
                    head = m_setDataLength(head);
                }
                if (head.nReadDataPack) {
                    RecvData(clientSocket, head);
                    head.nLength = BytesToInt(m_Data);
                }
                if (m_setReceiveCommandHead) {
                    m_setReceiveCommandHead(head);
                }
                if (head.nLength > 0) {
                    std::cout << "[TCP] Expecting Data Length: " << head.nLength << std::endl;
                    RecvData(clientSocket, head);
                    std::cout << "[TCP] Received Data Body (Size: " << m_Data.size() << ")" << std::endl;
                    if (m_setBuffer) {
                        m_setBuffer(head, m_Data);
                    }
                }
            }
        }

        close(clientSocket);
        
        if (m_RunOnce) {
            break; 
        }
    }
}

bool TcpServer::RecvSync(int clientSocket)
{
    // 协议同步字: "SYNC" -> 0x434e5953 (Little Endian)
    const int32_t SYNC_FLAG = 0x434e5953;
    int32_t syncBuffer = 0;

    if (RecvN(clientSocket, (char*)&syncBuffer, sizeof(int32_t))) {
        if (syncBuffer == SYNC_FLAG) {
            return true;
        } else {
            OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_DOMAIN, LOG_TAG, "[TCP] Sync Error: Expected 0x%{public}x, got 0x%{public}x", SYNC_FLAG, syncBuffer);
        }
    }
    return false;
}

bool TcpServer::RecvCommand(int clientSocket, CommandHead* commandHead)
{
    // 读取剩余的协议头 (SendCMD 除去 SYNC 的部分)
    // struct SendCMD { int SYNC; int nSrcId; int nDestId; int nCmd; };
    // 还需要读取: nSrcId, nDestId, nCmd (3 * 4 = 12 bytes)
    
    int32_t buffer[3]; // [0]:SrcId, [1]:DestId, [2]:CmdId
    
    if (RecvN(clientSocket, (char*)buffer, sizeof(buffer))) {
        commandHead->nSrcId = buffer[0];
        // DestId (buffer[1]) 本地可以用来校验是否发给我的，这里暂且忽略或打印
        commandHead->nCmdId = buffer[2];
        
        // nLength 初始为0，后续通过回调 m_setDataLength 计算
        commandHead->nLength = 0; 
        
        return true;
    }
    return false;
}

bool TcpServer::RecvData(int clientSocket, CommandHead commandHead)
{
    if (commandHead.nLength <= 0) return true;
    
    m_Data.resize(commandHead.nLength);
    if (RecvN(clientSocket, m_Data.data(), commandHead.nLength)) {
        return true;
    }
    return false;
}

bool TcpServer::RecvN(int socket, char* buffer, size_t size)
{
    size_t total = 0;
    while (total < size) {
        ssize_t received = recv(socket, buffer + total, size - total, 0);
        if (received <= 0) return false;
        total += received;
    }
    return true;
}

int32_t TcpServer::BytesToInt(const std::vector<char>& bytes)
{
    if (bytes.size() < 4) return 0;
    int32_t value;
    std::memcpy(&value, bytes.data(), sizeof(int32_t));
    return value;
}
