#ifndef APIHELPER_H
#define APIHELPER_H

#include <QObject>
#include <Http/httphelper.h>
#include <Http/httpresponse.h>
#include <jsonconverthelper.h>
class ApiHelper : public QObject
{
    Q_OBJECT
public:
    static QString BaseUrl;
    static QString SecretKey;
    static QString SelectLanguage;
    static QString HttpHost;
    static int HttpPort;
    static QString HttpApiUrl;
    static QString DeviceType;
    static QString ApiVersion;
    static QString OutUrl;
    static QString LocalUrl;
    explicit ApiHelper(QObject *parent = nullptr);


    static QMap<QString,QString> NotVerifyHeaders();
    static QMap<QString,QString> VerifyHeaders(QString& postData);
    static QMap<QString,QString>VerifyFileHeaders();

    static HttpResponse* GetDeviceConfig(HttpHelper *httpHelper);
    static HttpResponse* UploadDeviceConfig(QFile *file,HttpHelper *httphelper);
    static HttpResponse* GetCustomerDeviceInfo();
    static HttpResponse* DeleteDeviceConfig(QString fileName,HttpHelper *httpHelper);
    static HttpResponse* DownDeviceConfig(QString fileName,HttpHelper *httpHelp);
    static HttpResponse* GetDeviceUnLockInfo(HttpHelper *httpHelp);
    static HttpResponse* UpdateDeviceInfo(QString postData);
    static QString GetBaseUrl();
signals:

private:
    static HttpHelper *m_HttpHelp;
};

#endif // APIHELPER_H
