#include "tcpclient.h"
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <fcntl.h>
#include <iostream>
#include <cstring>

TcpClient::TcpClient()
{
}

TcpClient::~TcpClient()
{
    DestroySocket();
}

bool TcpClient::ConnectServer(const std::string& remoteIp, uint16_t remotePort, const std::string& localIp)
{
    std::lock_guard<std::mutex> lock(m_SocketMutex);

    if (m_IsConnected) {
        return true;
    }

    m_Socket = socket(AF_INET, SOCK_STREAM, 0);
    if (m_Socket == -1) {
        if (m_OnError) m_OnError("Failed to create socket");
        return false;
    }

    // 设置 KeepAlive
    int opt = 1;
    setsockopt(m_Socket, SOL_SOCKET, SO_KEEPALIVE, &opt, sizeof(opt));

    // 绑定本地 IP (如果指定)
    if (!localIp.empty()) {
        sockaddr_in localAddr;
        localAddr.sin_family = AF_INET;
        localAddr.sin_addr.s_addr = inet_addr(localIp.c_str());
        localAddr.sin_port = 0; // 随机端口
        if (bind(m_Socket, (struct sockaddr*)&localAddr, sizeof(localAddr)) < 0) {
            if (m_OnError) m_OnError("Failed to bind local IP");
            close(m_Socket);
            m_Socket = -1;
            return false;
        }
    }

    sockaddr_in serverAddr;
    serverAddr.sin_family = AF_INET;
    serverAddr.sin_port = htons(remotePort);
    if (inet_pton(AF_INET, remoteIp.c_str(), &serverAddr.sin_addr) <= 0) {
        if (m_OnError) m_OnError("Invalid remote IP");
        close(m_Socket);
        m_Socket = -1;
        return false;
    }

    // 连接
    if (connect(m_Socket, (struct sockaddr*)&serverAddr, sizeof(serverAddr)) < 0) {
        if (m_OnError) m_OnError("Failed to connect");
        close(m_Socket);
        m_Socket = -1;
        return false;
    }

    m_IsConnected = true;
    if (m_OnConnected) m_OnConnected();

    // 启动接收线程
    m_ReceiveThread = std::thread(&TcpClient::ReceiveLoop, this);
    m_ReceiveThread.detach();

    return true;
}

bool TcpClient::IsConnected()
{
    return m_IsConnected;
}

bool TcpClient::Send(const std::vector<char>& data)
{
    std::lock_guard<std::mutex> lock(m_SocketMutex);
    
    if (!m_IsConnected || m_Socket == -1) {
        return false;
    }

    if (data.empty()) {
        return false;
    }

    size_t totalSent = 0;
    size_t toSend = data.size();
    const char* buffer = data.data();

    while (totalSent < toSend) {
        ssize_t sent = send(m_Socket, buffer + totalSent, toSend - totalSent, 0);
        if (sent < 0) {
            if (m_OnError) m_OnError("Failed to send data");
            DestroySocket(); // 发送失败通常意味着连接断开
            return false;
        }
        totalSent += sent;
    }

    return true;
}

void TcpClient::DestroySocket()
{
    if (!m_IsConnected) return;

    m_IsConnected = false;
    
    if (m_Socket != -1) {
        // Shutdown 可能会中断阻塞的 recv
        shutdown(m_Socket, SHUT_RDWR);
        close(m_Socket);
        m_Socket = -1;
    }

    if (m_OnDisconnected) m_OnDisconnected();
}

void TcpClient::ReceiveLoop()
{
    const int bufferSize = 4096;
    char buffer[bufferSize];

    while (m_IsConnected) {
        ssize_t bytesRead = recv(m_Socket, buffer, bufferSize, 0);
        
        if (bytesRead > 0) {
            std::vector<char> data(buffer, buffer + bytesRead);
            if (m_OnDataReceived) {
                m_OnDataReceived(data);
            }
        } else if (bytesRead == 0) {
            // 对端关闭
            if (m_OnError) m_OnError("Remote closed connection");
            break;
        } else {
            // 错误
            if (errno != EINTR) {
                if (m_OnError) m_OnError("Receive error");
                break;
            }
        }
    }

    DestroySocket();
}
