#include "socketserver.h"
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <fcntl.h>
#include <iostream>
#include <cstring>
#include <algorithm>

SocketServer::SocketServer()
{
}

SocketServer::~SocketServer()
{
    Destroy();
}

bool SocketServer::Start(const std::string& ip, int port)
{
    if (m_IsRunning) {
        Destroy();
    }

    m_MasterSocket = socket(AF_INET, SOCK_STREAM, 0);
    if (m_MasterSocket == -1) {
        if (m_OnError) m_OnError("Failed to create socket");
        return false;
    }

    // 设置端口复用
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
        if (m_OnError) m_OnError("Bind failed");
        close(m_MasterSocket);
        m_MasterSocket = -1;
        return false;
    }

    if (listen(m_MasterSocket, 100) < 0) {
        if (m_OnError) m_OnError("Listen failed");
        close(m_MasterSocket);
        m_MasterSocket = -1;
        return false;
    }

    m_IsRunning = true;
    if (m_OnConnected) m_OnConnected();

    m_AcceptThread = std::thread(&SocketServer::AcceptLoop, this);
    m_AcceptThread.detach();

    return true;
}

void SocketServer::AcceptLoop()
{
    while (m_IsRunning) {
        sockaddr_in clientAddr;
        socklen_t clientAddrLen = sizeof(clientAddr);
        
        int clientSocket = accept(m_MasterSocket, (struct sockaddr*)&clientAddr, &clientAddrLen);
        
        if (clientSocket < 0) {
            if (m_IsRunning && m_OnError) {
                // m_OnError("Accept failed"); 
            }
            continue;
        }

        char ipStr[INET_ADDRSTRLEN];
        inet_ntop(AF_INET, &(clientAddr.sin_addr), ipStr, INET_ADDRSTRLEN);
        int port = ntohs(clientAddr.sin_port);
        std::string clientIP = std::string(ipStr) + ":" + std::to_string(port);

        {
            std::lock_guard<std::mutex> lock(m_ClientsMutex);
            m_Clients[clientIP] = clientSocket;
        }

        // 为每个客户端启动接收线程
        std::thread clientThread(&SocketServer::ClientHandler, this, clientSocket, clientIP);
        clientThread.detach();
    }
}

void SocketServer::ClientHandler(int clientSocket, std::string clientIP)
{
    const int bufferSize = 4096;
    char buffer[bufferSize];

    while (m_IsRunning) {
        ssize_t bytesRead = recv(clientSocket, buffer, bufferSize, 0);
        
        if (bytesRead > 0) {
            std::vector<char> data(buffer, buffer + bytesRead);
            if (m_OnDataReceived) {
                m_OnDataReceived(clientIP, data);
            }
        } else {
            break;
        }
    }

    RemoveClient(clientIP);
}

void SocketServer::RemoveClient(const std::string& clientIP)
{
    int socketToClose = -1;
    {
        std::lock_guard<std::mutex> lock(m_ClientsMutex);
        auto it = m_Clients.find(clientIP);
        if (it != m_Clients.end()) {
            socketToClose = it->second;
            m_Clients.erase(it);
        }
    }

    if (socketToClose != -1) {
        close(socketToClose);
    }
}

bool SocketServer::SendData(const std::vector<char>& data)
{
    if (data.empty()) return false;

    std::lock_guard<std::mutex> lock(m_ClientsMutex);
    for (auto& pair : m_Clients) {
        // 简单实现，不检查每个 socket 状态，假设 map 中都是活跃的
        send(pair.second, data.data(), data.size(), 0);
    }
    return true;
}

void SocketServer::Destroy()
{
    if (!m_IsRunning) return;

    m_IsRunning = false;

    if (m_MasterSocket != -1) {
        // Shutdown master socket to break accept loop
        shutdown(m_MasterSocket, SHUT_RDWR);
        close(m_MasterSocket);
        m_MasterSocket = -1;
    }

    {
        std::lock_guard<std::mutex> lock(m_ClientsMutex);
        for (auto& pair : m_Clients) {
            close(pair.second);
        }
        m_Clients.clear();
    }

    if (m_OnClosed) m_OnClosed();
}
