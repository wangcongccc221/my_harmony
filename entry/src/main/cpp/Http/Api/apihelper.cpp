#include "apihelper.h"
#include <Encrypt/aescryption.h>
#include <Encrypt/md5cryption.h>
#include "networkhelper.h"
QString ApiHelper::BaseUrl = "";
QString ApiHelper::SecretKey = "";
QString ApiHelper::SelectLanguage = "";
QString ApiHelper::HttpHost = "111.75.253.33";
int ApiHelper::HttpPort = 8899;
QString ApiHelper::HttpApiUrl ="http://111.75.253.33:8899/Api/";;
QString ApiHelper::DeviceType = "FruitSort200";
QString ApiHelper::ApiVersion = "2.0";
QString ApiHelper::OutUrl = "http://111.75.253.33:8899/Api/";
QString ApiHelper::LocalUrl = "http://192.168.10.29:8899/Api/";
HttpHelper *ApiHelper::m_HttpHelp = new HttpHelper();
ApiHelper::ApiHelper(QObject *parent) : QObject(parent)
{

}

QMap<QString,QString> ApiHelper::NotVerifyHeaders(){
    QMap<QString,QString> header;
    header.insert("devicetype", DeviceType);
    header.insert("api-version", ApiVersion);
    header.insert("language",  SelectLanguage);
    return header;
}

QMap<QString,QString> ApiHelper::VerifyHeaders(QString& postData){
    QMap<QString,QString> header;
    QString timestamp = QString::number(QDateTime::currentMSecsSinceEpoch());
    postData = AESCryption::Encrypt(SecretKey, postData);
    QString signature = AESCryption::Encrypt(SecretKey,
                                             MD5Cryption::Encrypt(QString("data%1timestamp%2").arg(postData).arg(timestamp)));

    header.insert("devicetype", DeviceType);
    header.insert("api-version", ApiVersion);
    header.insert("language",  SelectLanguage);
    header.insert("secret-key", SecretKey);
    header.insert("signature", signature);
    header.insert("timestamp", timestamp);
    return header;
}

QMap<QString,QString> ApiHelper::VerifyFileHeaders(){
    QMap<QString,QString> header;
    QString timestamp = QString::number(QDateTime::currentMSecsSinceEpoch());
    QString signature = AESCryption::Encrypt(SecretKey, MD5Cryption::Encrypt(QString("devicetype%1language%2timestamp%3").arg("FruitSort200").arg(SelectLanguage).arg(timestamp)));
    header.insert("devicetype", DeviceType);
    header.insert("api-version", ApiVersion);
    header.insert("language", SelectLanguage);
    header.insert("secret-key", SecretKey);
    header.insert("signature", signature);
    header.insert("timestamp", timestamp);
    return header;
}

HttpResponse* ApiHelper::GetDeviceConfig(HttpHelper *httpHelper){
    if(BaseUrl.isNull()||BaseUrl.isEmpty())
    {
        BaseUrl = GetBaseUrl();
    }
    QString url = BaseUrl + "Customer/GetDeviceConfig";
    QString data ="";
    return httpHelper->HttpResponseApi(url,VerifyHeaders(data),data);
}

HttpResponse* ApiHelper::UploadDeviceConfig(QFile *file,HttpHelper *httphelper){
    if(BaseUrl.isNull()||BaseUrl.isEmpty())
    {
        BaseUrl = GetBaseUrl();
    }
    QString url = BaseUrl + "Customer/UploadDeviceConfig";
    return httphelper->HttpMultipartResponseApi(url,VerifyFileHeaders(),file);
}


HttpResponse* ApiHelper::GetCustomerDeviceInfo(){
    if(BaseUrl.isNull()||BaseUrl.isEmpty())
    {
        BaseUrl = GetBaseUrl();
    }
    QString url = BaseUrl + "Customer/GetCustomerDeviceInfo";
    QString data ="";
    return m_HttpHelp->HttpResponseApi(url,VerifyHeaders(data),data);
}

HttpResponse* ApiHelper::DeleteDeviceConfig(QString fileName,HttpHelper *httpHelper){
    if(BaseUrl.isNull()||BaseUrl.isEmpty())
    {
        BaseUrl = GetBaseUrl();
    }
    QString url = BaseUrl + "Customer/DeleteDeviceConfig";
    QMap<QString,QString> headers = VerifyHeaders(fileName);
    return httpHelper->HttpResponseApi(url,headers,fileName);
}

HttpResponse* ApiHelper::DownDeviceConfig(QString fileName,HttpHelper *httpHelp){
    if(BaseUrl.isNull()||BaseUrl.isEmpty())
    {
        BaseUrl = GetBaseUrl();
    }
    QString url = BaseUrl + "Customer/DownDeviceConfig";
    QMap<QString,QString> headers = VerifyHeaders(fileName);
    return httpHelp->HttpResponseApi(url,headers,fileName);
}

HttpResponse* ApiHelper::GetDeviceUnLockInfo(HttpHelper *httpHelp){
    QString url = HttpApiUrl + "Customer/GetMqttInfo";
    QString data ="";
    return httpHelp->HttpResponseApi(url,VerifyHeaders(data),data);
}

HttpResponse * ApiHelper::UpdateDeviceInfo(QString postData)
{
    if(BaseUrl.isNull()||BaseUrl.isEmpty())
    {
        BaseUrl = GetBaseUrl();
    }
    QString url = BaseUrl + "Customer/UpdateDeviceInfo";
    QMap<QString, QString> temMap = VerifyHeaders(postData);
    return m_HttpHelp->HttpResponseApi(url, temMap, postData);
}

QString ApiHelper::GetBaseUrl()
{
    QString str = "";
    if(NetWorkHelper::CanConnectionNetWork(LocalUrl,1))//内网
    {
        str = LocalUrl;
    }
    else if(NetWorkHelper::CanConnectionNetWork(OutUrl,1))
    {
        str = OutUrl;
    }
    return str;
}

