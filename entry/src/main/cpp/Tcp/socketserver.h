#ifndef TCPSOCKETSERVER_H
#define TCPSOCKETSERVER_H

#include <string>
#include <vector>
#include <functional>
#include <thread>
#include <mutex>
#include <atomic>
#include <map>

class SocketServer
{
public:
    SocketServer();
    ~SocketServer();

    // 启动服务器
    bool Start(const std::string& ip, int port);
    
    // 发送数据给所有客户端
    bool SendData(const std::vector<char>& data);
    
    // 销毁/停止服务器
    void Destroy();

    // 回调函数定义
    using OnConnectedCallback = std::function<void()>;
    using OnDataReceivedCallback = std::function<void(const std::string& clientIP, const std::vector<char>& data)>;
    using OnErrorCallback = std::function<void(const std::string& error)>;
    using OnClosedCallback = std::function<void()>;

    void SetOnConnected(OnConnectedCallback cb) { m_OnConnected = cb; }
    void SetOnDataReceived(OnDataReceivedCallback cb) { m_OnDataReceived = cb; }
    void SetOnError(OnErrorCallback cb) { m_OnError = cb; }
    void SetOnClosed(OnClosedCallback cb) { m_OnClosed = cb; }

private:
    void AcceptLoop();
    void ClientHandler(int clientSocket, std::string clientIP);
    void RemoveClient(const std::string& clientIP);

private:
    int m_MasterSocket = -1;
    std::atomic<bool> m_IsRunning = {false};
    
    // 存储客户端 Socket: IP:Port -> SocketFD
    std::map<std::string, int> m_Clients;
    std::mutex m_ClientsMutex;
    
    std::thread m_AcceptThread;

    // Callbacks
    OnConnectedCallback m_OnConnected;
    OnDataReceivedCallback m_OnDataReceived;
    OnErrorCallback m_OnError;
    OnClosedCallback m_OnClosed;
};

#endif // TCPSOCKETSERVER_H
