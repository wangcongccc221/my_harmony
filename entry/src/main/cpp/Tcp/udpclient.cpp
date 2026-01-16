#include "udpclient.h"
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <iostream>
#include <cstring>

UdpClient::UdpClient()
{
    m_IsRunning = true;
}

UdpClient::~UdpClient()
{
    Stop();
}

bool UdpClient::Start(const std::string& ip, int16_t port, SetBufferCallback setBuffer)
{
    m_setBuffer = setBuffer;
    
    m_Socket = socket(AF_INET, SOCK_DGRAM, 0);
    if (m_Socket == -1) {
        return false;
    }

    // 设置缓冲区大小
    int rcvBuf = 5000000;
    setsockopt(m_Socket, SOL_SOCKET, SO_RCVBUF, &rcvBuf, sizeof(rcvBuf));

    sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    if (ip.empty()) {
        addr.sin_addr.s_addr = INADDR_ANY;
    } else {
        inet_pton(AF_INET, ip.c_str(), &addr.sin_addr);
    }

    if (bind(m_Socket, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
        close(m_Socket);
        return false;
    }

    m_IsRunning = true;
    m_Thread = std::thread(&UdpClient::RecvThread, this);
    
    return true;
}

void UdpClient::Stop()
{
    m_IsRunning = false;
    if (m_Socket != -1) {
        shutdown(m_Socket, SHUT_RDWR);
        close(m_Socket);
        m_Socket = -1;
    }
    if (m_Thread.joinable()) {
        m_Thread.join();
    }
}

void UdpClient::RecvThread()
{
    std::vector<char> buffer(PackageMaxSize);
    
    while (m_IsRunning) {
        sockaddr_in senderAddr;
        socklen_t senderAddrLen = sizeof(senderAddr);
        
        ssize_t bytesRead = recvfrom(m_Socket, buffer.data(), PackageMaxSize, 0,
                                   (struct sockaddr*)&senderAddr, &senderAddrLen);
        
        if (bytesRead > 0) {
            std::vector<char> data(buffer.begin(), buffer.begin() + bytesRead);
            if (m_setBuffer) {
                // 这里假设 UDP 包格式，因为原代码没写具体解析逻辑
                // 暂时传 0, 0 作为 srcId 和 cmdId
                m_setBuffer(0, 0, data);
            }
        } else {
            if (!m_IsRunning) break;
        }
    }
}
