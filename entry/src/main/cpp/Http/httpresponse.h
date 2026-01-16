#ifndef HTTPRESPONSE_H
#define HTTPRESPONSE_H

#include <QObject>

class HttpResponse : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int returnCode MEMBER returnCode)
    Q_PROPERTY(QString returnMessage MEMBER returnMessage)
    Q_PROPERTY(QString data MEMBER data)

public:
    explicit HttpResponse(QObject *parent = nullptr);

    int returnCode = -1;//返回状态
    QString returnMessage;//返回信息
    QString data;//返回数据
signals:

};

#endif // HTTPRESPONSE_H
