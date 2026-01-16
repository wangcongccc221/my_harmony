#ifndef UDPSERVER_H
#define UDPSERVER_H

#include <string>
#include <vector>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>

class UdpServer
{
public:
    UdpServer();
    ~UdpServer();

    int64_t SendData(const char *data, int64_t size, const std::string &ip, uint16_t port);

private:
    int m_Socket = -1;
};

#endif // UDPSERVER_H
