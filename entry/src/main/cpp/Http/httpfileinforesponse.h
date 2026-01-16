#ifndef HTTPFILEINFORESPONSE_H
#define HTTPFILEINFORESPONSE_H

#include <QObject>

class HttpFileInfoResponse : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString FFile MEMBER FFile)
    Q_PROPERTY(int FType MEMBER FType)
    Q_PROPERTY(QString FProject MEMBER FProject)
    Q_PROPERTY(QString FVersion MEMBER FVersion)
    Q_PROPERTY(QString FZHDescribe MEMBER FZHDescribe)
    Q_PROPERTY(QString FENDescribe MEMBER FENDescribe)
    Q_PROPERTY(bool FIsEncryption MEMBER FIsEncryption)
    Q_PROPERTY(QByteArray FFileData MEMBER FFileData)

public:
    explicit HttpFileInfoResponse(QObject *parent = nullptr);

    QString FFile;
    int FType;
    QString FProject;
    QString FVersion;
    QString FZHDescribe;
    QString FENDescribe;
    bool FIsEncryption;
    QByteArray FFileData;

signals:

};

#endif // HTTPFILEINFORESPONSE_H
