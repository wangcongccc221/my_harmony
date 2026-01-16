#include "httphelper.h"
#include <Http/httpfileinforesponse.h>
#include <qobjectconverthelper.h>
#include <QFile>
#include <QDataStream>
#include <QTextCodec>
#include <codetransform.h>
#include <QThread>
QNetworkAccessManager* HttpHelper::m_ShttpManager = new QNetworkAccessManager();
HttpHelper::HttpHelper(QObject *parent) : QObject(parent)
{
    m_httpManager = new QNetworkAccessManager();
}

HttpHelper::~HttpHelper()
{
    if(m_httpManager!=nullptr){
        m_httpManager->deleteLater();
        m_httpManager = nullptr;
    }
}

QString HttpHelper::HttpApi(const QString url, const QMap<QString, QString> headers, const QString postData){
    QNetworkReply* reply = nullptr;
    QNetworkRequest request;
    request.setUrl(QUrl(url));
    request.setHeader(QNetworkRequest::ContentTypeHeader,QVariant("application/json"));
    QMapIterator<QString, QString> iterator(headers);
    while (iterator.hasNext()) {
        iterator.next();
        request.setRawHeader(iterator.key().toUtf8(),iterator.value().toUtf8());
    }
    reply = m_httpManager->post(request,postData.toUtf8());
    //添加事件循环机制，返回后再运行后面的
    QEventLoop eventLoop;
    connect(reply, &QNetworkReply::finished, &eventLoop, &QEventLoop::quit);
    eventLoop.exec();
    QString result = reply->readAll();
    if(reply != nullptr){
        reply->abort();
        reply->deleteLater();
        reply = nullptr;
    }
    return result;
}

HttpResponse* HttpHelper::HttpResponseApi(const QString url, const QMap<QString, QString> headers, const QString postData){
    QNetworkReply* reply = nullptr;
    QNetworkRequest request;
    request.setUrl(QUrl(url));
    request.setHeader(QNetworkRequest::ContentTypeHeader,QVariant("application/json"));
    QMapIterator<QString, QString> iterator(headers);
    while (iterator.hasNext()) {
        iterator.next();
        request.setRawHeader(iterator.key().toUtf8(),iterator.value().toUtf8());
    }
    reply = m_httpManager->post(request,postData.toUtf8());
    //添加事件循环机制，返回后再运行后面的
    QEventLoop eventLoop;
    connect(reply,&QNetworkReply::finished,&eventLoop,&QEventLoop::quit);
    eventLoop.exec();
    QString result = reply->readAll();
    if(reply != nullptr){
        reply->close();
        reply->deleteLater();
        reply = nullptr;
    }
    QVariantMap map = JsonConvertHelper::DeserializeObject(result);
    HttpResponse* response = new HttpResponse();
    QObjectConvertHelper::QVariant2QObject(map,response);
    return response;
}

HttpResponse* HttpHelper::HttpResponseApi(const QString url, const QMap<QString, QString> headers, HttpRequest* httpRequest){
    QNetworkReply* reply = nullptr;
    QNetworkRequest request;;
    request.setUrl(QUrl(url));
    request.setHeader(QNetworkRequest::ContentTypeHeader,QVariant("application/json"));
    QMapIterator<QString, QString> iterator(headers);
    while (iterator.hasNext()) {
        iterator.next();
        request.setRawHeader(iterator.key().toUtf8(),iterator.value().toUtf8());
    }
    QVariantMap postMap = QObjectConvertHelper::QObject2QVariant(httpRequest);
    QString postData = JsonConvertHelper::SerializeObject(postMap);
    reply = m_httpManager->post(request,postData.toUtf8());
    //添加事件循环机制，返回后再运行后面的
    QEventLoop eventLoop;
    connect(reply, &QNetworkReply::finished, &eventLoop,&QEventLoop::quit);
    eventLoop.exec();
    QString result = reply->readAll();
    if(reply != nullptr){
        reply->close();
        reply->deleteLater();
        reply = nullptr;
    }
    QVariantMap map = JsonConvertHelper::DeserializeObject(result);
    HttpResponse* response = new HttpResponse();
    QObjectConvertHelper::QVariant2QObject(map,response);
    return response;
}

bool HttpHelper::HttpDownLoadApi(const QString url, const QMap<QString, QString> headers, const QString postData, const QString path, const QString type)
{
    QNetworkReply* reply = nullptr;
    QNetworkRequest request;
    request.setUrl(QUrl(url));
    request.setHeader(QNetworkRequest::ContentTypeHeader,QVariant("application/json"));
    QMapIterator<QString, QString> iterator(headers);
    while (iterator.hasNext()) {
        iterator.next();
        request.setRawHeader(iterator.key().toUtf8(),iterator.value().toUtf8());
    }
    reply = m_httpManager->post(request,postData.toUtf8());
    //添加事件循环机制，返回后再运行后面的
    QEventLoop eventLoop;
    connect(reply, &QNetworkReply::finished, &eventLoop, &QEventLoop::quit);
    eventLoop.exec();

    QString result = reply->readAll();
    if(reply != nullptr){
        reply->close();
        reply->deleteLater();
        reply = nullptr;
    }

    QVariantMap map = JsonConvertHelper::DeserializeObject(result);
    HttpResponse* response = new HttpResponse();
    QObjectConvertHelper::QVariant2QObject(map,response);
    if (response->returnCode == 1)
    {
        HttpFileInfoResponse httpFileInfoResponse;
        QVariantMap responseData = JsonConvertHelper::DeserializeObject(response->data);
        QObjectConvertHelper::QVariant2QObject(responseData, &httpFileInfoResponse);
        if (httpFileInfoResponse.FFileData.length() > 0)
        {
            QFile configFile(path + httpFileInfoResponse.FProject);
            configFile.remove();
            if(configFile.open(QIODevice::WriteOnly | QIODevice::Text))
            {
                configFile.seek(0);
                QDataStream out(&configFile);
                out.writeRawData(httpFileInfoResponse.FFileData.data(), httpFileInfoResponse.FFileData.length());
                configFile.close();
            }
        }
    }
    return response->returnCode == 1;
}

bool HttpHelper::HttpCanConnect(const QString host, const int port, const int millisecondsTimeout)
{
    QTcpSocket *m_Socket = new QTcpSocket();
    m_Socket->connectToHost(host,port);
    bool bResult = m_Socket->waitForConnected(millisecondsTimeout);
    if(m_Socket->isOpen()){
        m_Socket->close();
    }
    m_Socket->deleteLater();
    m_Socket = nullptr;
    return bResult;
}

HttpResponse *HttpHelper::HttpMultipartResponseApi(const QString url, QMap<QString, QString> headers, QFile *file)
{
    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
    QHttpPart filePart;
    filePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("application/octet-stream"));//这里一般这样写
    filePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"files\"; filename=\"" + file->fileName() + "\""));
    filePart.setBodyDevice(file);
    file->setParent(multiPart);//delte file with the multiPart
    multiPart->append(filePart);

    QNetworkRequest request;
    request.setUrl(QUrl(url));
    QMapIterator<QString, QString> iterator(headers);
    while (iterator.hasNext()) {
        iterator.next();
        request.setRawHeader(iterator.key().toUtf8(),iterator.value().toUtf8());
    }

    QNetworkReply* reply = m_httpManager->post(request, multiPart);
    multiPart->setParent(reply);//delte multiPart with the reply,怎么delete reply?
    //添加事件循环机制，返回后再运行后面的
    QEventLoop eventLoop;
    connect(reply, &QNetworkReply::finished, &eventLoop, &QEventLoop::quit);
    eventLoop.exec();
    QString result = reply->readAll();
    reply->close();
    reply->deleteLater();

    QVariantMap map = JsonConvertHelper::DeserializeObject(result);
    HttpResponse* response = new HttpResponse();
    QObjectConvertHelper::QVariant2QObject(map,response);
    return response;
}

QString HttpHelper::HttpGet(const QString url){
    QNetworkRequest request;
    request.setUrl(QUrl(url));
    QNetworkReply* reply = m_httpManager->get(request);
    //添加事件循环机制，返回后再运行后面的
    QEventLoop eventLoop;
    connect(reply, &QNetworkReply::finished, &eventLoop, &QEventLoop::quit);
    eventLoop.exec();
    QString result = reply->readAll();
    if(reply){
        reply->close();
        reply->deleteLater();
        reply = nullptr;
    }
    return result;
}

HttpResponse *HttpHelper::StaticHttpResponseApi(const QString url, const QMap<QString, QString> headers, const QString postData)
{
    QNetworkReply* reply = nullptr;
    QNetworkRequest request;
    request.setUrl(QUrl(url));
    request.setHeader(QNetworkRequest::ContentTypeHeader,QVariant("application/json"));
    QMapIterator<QString, QString> iterator(headers);
    while (iterator.hasNext()) {
        iterator.next();
        request.setRawHeader(iterator.key().toUtf8(),iterator.value().toUtf8());
    }
    reply = m_ShttpManager->post(request,postData.toUtf8());
    //添加事件循环机制，返回后再运行后面的
    QEventLoop eventLoop;
    connect(reply,&QNetworkReply::finished,&eventLoop,&QEventLoop::quit);
    eventLoop.exec();
    QString result = reply->readAll();
    if(reply != nullptr){
        reply->close();
        reply->deleteLater();
        reply = nullptr;
    }
    QVariantMap map = JsonConvertHelper::DeserializeObject(result);
    HttpResponse* response = new HttpResponse();
    QObjectConvertHelper::QVariant2QObject(map,response);
    return response;
}
