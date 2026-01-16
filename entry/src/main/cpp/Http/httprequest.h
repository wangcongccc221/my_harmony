#ifndef HTTPREQUEST_H
#define HTTPREQUEST_H

#include <QObject>

class HttpRequest : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString Data MEMBER Data)

public:
    explicit HttpRequest(QObject *parent = nullptr);

    QString Data;//请求数据
signals:

};

#endif // HTTPREQUEST_H
