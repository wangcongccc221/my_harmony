#include "udpserver.h"
#include <iostream>

UdpServer::UdpServer()
{
    m_Socket = socket(AF_INET, SOCK_DGRAM, 0);
}

UdpServer::~UdpServer()
{
    if (m_Socket != -1)
    {
        close(m_Socket);
        m_Socket = -1;
    }
}

int64_t UdpServer::SendData(const char *data, int64_t size, const std::string &ip, uint16_t port)
{
    if (m_Socket == -1) return -1;

    sockaddr_in destAddr;
    destAddr.sin_family = AF_INET;
    destAddr.sin_port = htons(port);
    inet_pton(AF_INET, ip.c_str(), &destAddr.sin_addr);

    ssize_t bytes = sendto(m_Socket, data, size, 0, (struct sockaddr*)&destAddr, sizeof(destAddr));
    return bytes;
}
