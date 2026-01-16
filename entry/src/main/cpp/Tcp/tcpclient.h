#ifndef TCPCLIENT_H
#define TCPCLIENT_H

#include <string>
#include <vector>
#include <functional>
#include <thread>
#include <mutex>
#include <atomic>

class TcpClient
{
public:
    TcpClient();
    ~TcpClient();

    // 连接服务器
    bool ConnectServer(const std::string& remoteIp, uint16_t remotePort, const std::string& localIp = "");
    
    // 检查是否连接
    bool IsConnected();
    
    // 发送数据
    bool Send(const std::vector<char>& data);
    
    // 断开连接
    void DestroySocket();

    // 回调函数定义
    using OnConnectedCallback = std::function<void()>;
    using OnDataReceivedCallback = std::function<void(const std::vector<char>&)>;
    using OnErrorCallback = std::function<void(const std::string&)>;
    using OnDisconnectedCallback = std::function<void()>;

    void SetOnConnected(OnConnectedCallback cb) { m_OnConnected = cb; }
    void SetOnDataReceived(OnDataReceivedCallback cb) { m_OnDataReceived = cb; }
    void SetOnError(OnErrorCallback cb) { m_OnError = cb; }
    void SetOnDisconnected(OnDisconnectedCallback cb) { m_OnDisconnected = cb; }

private:
    void ReceiveLoop();

private:
    int m_Socket = -1;
    std::atomic<bool> m_IsConnected = {false};
    std::thread m_ReceiveThread;
    std::mutex m_SocketMutex;

    // Callbacks
    OnConnectedCallback m_OnConnected;
    OnDataReceivedCallback m_OnDataReceived;
    OnErrorCallback m_OnError;
    OnDisconnectedCallback m_OnDisconnected;
};

#endif // TCPCLIENT_H
