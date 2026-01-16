#ifndef UDPCLIENT_H
#define UDPCLIENT_H

#include <string>
#include <vector>
#include <functional>
#include <thread>
#include <atomic>
#include <mutex>

class UdpClient
{
public:
    UdpClient();
    ~UdpClient();

    using SetBufferCallback = std::function<void(int32_t nSrcId, int32_t nCmdId, std::vector<char> data)>;

    bool Start(const std::string& ip, int16_t port, SetBufferCallback setBuffer);
    void Stop();

private:
    void RecvThread();

private:
    int m_Socket = -1;
    std::atomic<bool> m_IsRunning = {false};
    std::thread m_Thread;
    
    const int PackageMaxSize = 1472;
    SetBufferCallback m_setBuffer;
};

#endif // UDPCLIENT_H
