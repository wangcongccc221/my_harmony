import { HttpHelper } from './HttpHelper';
import { HttpResponse } from './model/HttpResponse';
import { HttpRequest } from './model/HttpRequest';
import { HttpFileInfoRequest } from './model/HttpFileInfoRequest';

export class ApiHelper {
  // 配置项
  static BaseUrl: string = "";
  static SecretKey: string = ""; // 密钥，当前暂不使用
  static SelectLanguage: string = "zh-CN"; // 默认语言
  static HttpHost: string = "111.75.253.33";
  static HttpPort: number = 8899;
  static HttpApiUrl: string = "http://111.75.253.33:8899/Api/";
  static DeviceType: string = "FruitSort200";
  static ApiVersion: string = "2.0";
  static OutUrl: string = "http://111.75.253.33:8899/Api/";
  static LocalUrl: string = "http://192.168.10.29:8899/Api/";

  private static httpHelper: HttpHelper = HttpHelper.getInstance();

  static GetBaseUrl(): string {
    // 简单逻辑：优先使用 OutUrl
    // 实际业务可能需要检测 LocalUrl 是否可用
    return ApiHelper.OutUrl;
  }

  private static checkBaseUrl() {
    if (!ApiHelper.BaseUrl) {
      ApiHelper.BaseUrl = ApiHelper.GetBaseUrl();
    }
  }

  static NotVerifyHeaders(): Record<string, string> {
    return {
      "devicetype": ApiHelper.DeviceType,
      "api-version": ApiHelper.ApiVersion,
      "language": ApiHelper.SelectLanguage
    };
  }

  static VerifyHeaders(postData: string): Record<string, string> {
    const timestamp = Date.now().toString();
    
    // C++ 中这里进行了加密 (AES + MD5)，根据要求暂时忽略加密逻辑
    // const signature = ... 

    return {
      "devicetype": ApiHelper.DeviceType,
      "api-version": ApiHelper.ApiVersion,
      "language": ApiHelper.SelectLanguage,
      "secret-key": ApiHelper.SecretKey,
      "signature": "dummy_signature_skipped", // 占位
      "timestamp": timestamp
    };
  }

  static VerifyFileHeaders(): Record<string, string> {
    const timestamp = Date.now().toString();
    return {
      "devicetype": ApiHelper.DeviceType,
      "api-version": ApiHelper.ApiVersion,
      "language": ApiHelper.SelectLanguage,
      "secret-key": ApiHelper.SecretKey,
      "signature": "dummy_signature_skipped",
      "timestamp": timestamp
    };
  }

  // ================== API Methods ==================

  static async GetDeviceConfig(): Promise<HttpResponse> {
    ApiHelper.checkBaseUrl();
    const url = ApiHelper.BaseUrl + "Customer/GetDeviceConfig";
    const data = "";
    return await ApiHelper.httpHelper.HttpResponseApi(url, ApiHelper.VerifyHeaders(data), data);
  }

  static async GetCustomerDeviceInfo(): Promise<HttpResponse> {
    ApiHelper.checkBaseUrl();
    const url = ApiHelper.BaseUrl + "Customer/GetCustomerDeviceInfo";
    const data = "";
    return await ApiHelper.httpHelper.HttpResponseApi(url, ApiHelper.VerifyHeaders(data), data);
  }

  static async DeleteDeviceConfig(fileName: string): Promise<HttpResponse> {
    ApiHelper.checkBaseUrl();
    const url = ApiHelper.BaseUrl + "Customer/DeleteDeviceConfig";
    return await ApiHelper.httpHelper.HttpResponseApi(url, ApiHelper.VerifyHeaders(fileName), fileName);
  }

  static async UpdateDeviceInfo(postData: string): Promise<HttpResponse> {
    ApiHelper.checkBaseUrl();
    const url = ApiHelper.BaseUrl + "Customer/UpdateDeviceInfo";
    // C++ 代码中 UpdateDeviceInfo 似乎没有直接调用 HttpHelper，而是调用了 VerifyHeaders 后自己发？
    // 查看 apihelper.cpp:35: return ... HttpResponseApi(url, VerifyHeaders(postData), postData) (推测)
    // 实际上 cpp 文件里没写实现细节，只声明了。假设它是标准的 post 请求。
    return await ApiHelper.httpHelper.HttpResponseApi(url, ApiHelper.VerifyHeaders(postData), postData);
  }

  // UploadDeviceConfig 和 DownDeviceConfig 涉及文件操作，暂且搁置或简单实现接口
  static async UploadDeviceConfig(filePath: string): Promise<HttpResponse> {
    ApiHelper.checkBaseUrl();
    const url = ApiHelper.BaseUrl + "Customer/UploadDeviceConfig";
    // TODO: 实现文件上传逻辑
    console.warn("UploadDeviceConfig is not fully implemented yet.");
    return new HttpResponse(-1, "Not Implemented", "");
  }

  static async DownDeviceConfig(fileName: string): Promise<HttpResponse> {
    ApiHelper.checkBaseUrl();
    const url = ApiHelper.BaseUrl + "Customer/DownDeviceConfig";
    // TODO: 实现文件下载逻辑
    console.warn("DownDeviceConfig is not fully implemented yet.");
    return new HttpResponse(-1, "Not Implemented", "");
  }
}
