#ifndef HTTPHELPER_H
#define HTTPHELPER_H

#include <QObject>
#include <QEventLoop>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QException>
#include <QVariantMap>
#include <QMutex>
#include "httprequest.h"
#include "httpresponse.h"
#include "jsonconverthelper.h"
#include "qobjectconverthelper.h"
#include <Encrypt/aescryption.h>
#include <QHttpPart>
#include <QFile>
#include <QTimer>
class HttpHelper : public QObject
{
    Q_OBJECT
public:
    explicit HttpHelper(QObject *parent = nullptr);
    ~HttpHelper();

    QString HttpApi(const QString url,const QMap<QString, QString> headers, const QString postData);

    HttpResponse* HttpResponseApi(const QString url,const QMap<QString, QString> headers,const QString postData);

    HttpResponse* HttpResponseApi(const QString url,const QMap<QString, QString> headers,HttpRequest* httpRequest);

    bool HttpDownLoadApi(const QString url, const QMap<QString, QString> headers, const QString postData, const QString path, const QString type = "POST");

    bool HttpCanConnect(const QString host,const int port, const int millisecondsTimeout=2000);

    HttpResponse* HttpMultipartResponseApi(const QString url,QMap<QString, QString> headers, QFile *file);

    QString HttpGet(const QString url);

    static HttpResponse* StaticHttpResponseApi(const QString url,const QMap<QString, QString> headers,const QString postData);

private:
    QNetworkAccessManager* m_httpManager;

    static QNetworkAccessManager* m_ShttpManager;

signals:

};

#endif // HTTPHELPER_H
