#ifndef WEBSOCKETCLIENT_H
#define WEBSOCKETCLIENT_H

#include <QObject>
#include <QtWebSockets/QWebSocket>
#include <QDebug>
#include <QUrl>
#include <QTimer>
class WebSocketClient : public QObject
{
    Q_OBJECT
public:
    explicit WebSocketClient(QObject *parent = nullptr);
    ~WebSocketClient();

    void connectUrl(QString url,QMap<QString,QString> headMaps,QString appid); // 连接websocket服务器的URL
    void close(); // 关闭websocket
    void sendTextMsg(QString message); // 发送Text类型的消息  例如发送json格式的字符串
    void sendBinaryMsg(QByteArray data); // 发送Binary类型的消息 例如发送文件,图片,需要转换为QBytearray
    bool getConStatus(); // 返回服务器连接状态
    QString getAppids();
    QWebSocket m_pWebSocket;
    void Reconnect();

    //void setParam(QString url,QMap<QString,QString> headMaps,QString appids);
signals:
    void sigRecvTextMsg(QString message); // 接受到Text类型消息的信号
    void ReconnectSuccessful();

private slots:
    void slotConnected(); // 连接成功
    void slotDisconnected(); // 断开连接
    void slotRecvTextMsg(QString message); // 接受字符数据
    void slotRecvBinaryMsg(QByteArray message); // 接受二进制数据
private:
    QUrl m_url;
    bool m_bConnected = false; // 为true,表明已连接服务器，否则未连接上
    QNetworkRequest m_request;
    bool m_bIsReconnect = false;
    QString m_Appids;
};

#endif // WEBSOCKETCLIENT_H
