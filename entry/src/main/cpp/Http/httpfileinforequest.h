#ifndef HTTPFILEINFOREQUEST_H
#define HTTPFILEINFOREQUEST_H

#include <QObject>

class HttpFileInfoRequest : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int FType MEMBER FType)
    Q_PROPERTY(QString FProject MEMBER FProject)
    Q_PROPERTY(QString FVersion MEMBER FVersion)
    Q_PROPERTY(int FIsEncryption MEMBER FIsEncryption)
    Q_PROPERTY(QString FFileData MEMBER FFileData)

public:
    explicit HttpFileInfoRequest(QObject *parent = nullptr);

    int FType = 0;
    QString FProject = "";
    QString FVersion = "";
    int FIsEncryption = 0;
    QString FFileData = "";

signals:

};

#endif // HTTPFILEINFOREQUEST_H
