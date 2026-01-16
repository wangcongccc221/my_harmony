#include "websocketclient.h"
#include <QThread>
WebSocketClient::WebSocketClient(QObject *parent) : QObject(parent)
{
    //m_pWebSocket = new QWebSocket();
    // 连接相应的信号槽
//    connect(&m_pWebSocket, SIGNAL(connected()), this, SLOT(slotConnected()));
//    connect(&m_pWebSocket, SIGNAL(disconnected()), this, SLOT(slotDisconnected()));
//    connect(&m_pWebSocket, SIGNAL(error(QAbstractSocket::SocketError)), this, SLOT(slotError(QAbstractSocket::SocketError)));
}

WebSocketClient::~WebSocketClient()
{

}

// 连接websocket服务器的URL2
void WebSocketClient::connectUrl(QString url,QMap<QString,QString> headMaps,QString appids)
{
    m_url = QUrl(url);
    m_Appids = appids;
    m_request.setUrl(m_url);
    if(headMaps.count() > 0)
    {
        QMap<QString, QString>::iterator itor;
        for(itor = headMaps.begin();itor != headMaps.end();itor++)
        {
            m_request.setRawHeader(itor.key().toUtf8(),itor.value().toUtf8());
        }
    }
    m_pWebSocket.open(m_request);
    connect(&m_pWebSocket, SIGNAL(textMessageReceived(QString)), this, SLOT(slotRecvTextMsg(QString)));
    connect(&m_pWebSocket, SIGNAL(binaryMessageReceived(QByteArray)), this, SLOT(slotRecvBinaryMsg(QByteArray)));
    connect(&m_pWebSocket, SIGNAL(connected()), this, SLOT(slotConnected()));
    connect(&m_pWebSocket, SIGNAL(disconnected()), this, SLOT(slotDisconnected()));
}

// 关闭websocket
void WebSocketClient::close()
{
    m_pWebSocket.close();
}

// 发送Text类型的消息
void WebSocketClient::sendTextMsg(QString data)
{
    if(!m_bConnected)
    {
        qDebug() << __FILE__ << __LINE__ << "Failed to" << __FUNCTION__ << ", it's not running...";
        return;
    }
    m_pWebSocket.sendTextMessage(data);
    m_pWebSocket.flush();
}

// 发送Binary类型的消息
void WebSocketClient::sendBinaryMsg(QByteArray data)
{
    if(!m_bConnected)
    {
        //qDebug() << __FILE__ << __LINE__ << "Failed to" << __FUNCTION__ << ", it's not running...";
        return;
    }
    m_pWebSocket.sendBinaryMessage(data);
}

// 返回服务器连接状态
bool WebSocketClient::getConStatus()
{
    return m_bConnected;
}

QString WebSocketClient::getAppids()
{
    return m_Appids;
}

void WebSocketClient::Reconnect()
{
    m_bIsReconnect = true;
    m_pWebSocket.open(m_request);
}

//void WebSocketClient::setParam(QString url,QMap<QString,QString> headMaps,QString appids)
//{
//    m_url = QUrl(url);
//    m_Appids = appids;
//    m_request.setUrl(m_url);
//    if(headMaps.count() > 0)
//    {
//        QMap<QString, QString>::iterator itor;
//        for(itor = headMaps.begin();itor != headMaps.end();itor++)
//        {
//            m_request.setRawHeader(itor.key().toUtf8(),itor.value().toUtf8());
//        }
//    }
//}

// 连接成功
void WebSocketClient::slotConnected()
{
    qDebug()<<"连接成功!!!!==="<<QDateTime::currentDateTime();
    m_bConnected = true;
    m_bIsReconnect =false;
    emit ReconnectSuccessful();
}

// 断开连接
void WebSocketClient::slotDisconnected()
{
//    qDebug() << __FILE__ << __LINE__ << "disconnected";
    m_bConnected = false;
    m_pWebSocket.abort();
}

// 接受字符数据
void WebSocketClient::slotRecvTextMsg(QString message)
{
    emit sigRecvTextMsg(message);
}

// 接受二进制数据
void WebSocketClient::slotRecvBinaryMsg(QByteArray message)
{
    qDebug() << "slotRecvBinaryMsg: " << message;
}

// 响应报错
//void WebSocketClient::slotError(QAbstractSocket::SocketError error)
//{
//    qDebug() << __FILE__ << __LINE__ << (int)error << m_pWebSocket.errorString();
//}

