import { http } from '@kit.NetworkKit';
import { HttpResponse } from './model/HttpResponse';
import { HttpRequest } from './model/HttpRequest';
import { BusinessError } from '@kit.BasicServicesKit';

export class HttpHelper {
  private static instance: HttpHelper;

  public static getInstance(): HttpHelper {
    if (!HttpHelper.instance) {
      HttpHelper.instance = new HttpHelper();
    }
    return HttpHelper.instance;
  }

  /**
   * 发送 HTTP POST 请求并返回字符串结果
   */
  async HttpApi(url: string, headers: Record<string, string>, postData: string): Promise<string> {
    const httpRequest = http.createHttp();
    
    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          ...headers
        },
        extraData: postData,
        expectDataType: http.HttpDataType.STRING
      });

      if (response.responseCode === 200) {
        return response.result as string;
      } else {
        console.error(`HttpApi failed with code: ${response.responseCode}`);
        return "";
      }
    } catch (err) {
      console.error(`HttpApi error: ${JSON.stringify(err)}`);
      return "";
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 发送 HTTP POST 请求并返回 HttpResponse 对象
   */
  async HttpResponseApi(url: string, headers: Record<string, string>, postData: string | HttpRequest): Promise<HttpResponse> {
    const httpRequest = http.createHttp();
    let dataStr = "";
    
    if (typeof postData === 'string') {
      dataStr = postData;
    } else {
      dataStr = JSON.stringify(postData);
    }

    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          ...headers
        },
        extraData: dataStr,
        expectDataType: http.HttpDataType.STRING // 期望返回 JSON 字符串
      });

      if (response.responseCode === 200) {
        const resultStr = response.result as string;
        try {
          const jsonObj = JSON.parse(resultStr);
          const httpResponse = new HttpResponse();
          // 映射字段
          if (jsonObj.returnCode !== undefined) httpResponse.returnCode = jsonObj.returnCode;
          if (jsonObj.returnMessage !== undefined) httpResponse.returnMessage = jsonObj.returnMessage;
          if (jsonObj.data !== undefined) {
             // data 可能是对象或字符串，这里根据 C++ 定义它是 QString，但 JSON 中可能是对象
             // 如果 JSON 中是对象，我们将其转回字符串以匹配 C++ 行为，或者根据实际业务调整
             if (typeof jsonObj.data === 'object') {
               httpResponse.data = JSON.stringify(jsonObj.data);
             } else {
               httpResponse.data = String(jsonObj.data);
             }
          }
          return httpResponse;
        } catch (e) {
          console.error(`JSON parse error: ${e}`);
          return new HttpResponse(-1, "JSON Parse Error", "");
        }
      } else {
        return new HttpResponse(response.responseCode, `HTTP Error ${response.responseCode}`, "");
      }
    } catch (err) {
      const error = err as BusinessError;
      console.error(`HttpResponseApi error: ${JSON.stringify(error)}`);
      return new HttpResponse(-1, error.message, "");
    } finally {
      httpRequest.destroy();
    }
  }

  async HttpGet(url: string): Promise<string> {
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.STRING
      });
      if (response.responseCode === 200) {
        return response.result as string;
      }
      return "";
    } catch (err) {
      console.error(`HttpGet error: ${JSON.stringify(err)}`);
      return "";
    } finally {
      httpRequest.destroy();
    }
  }

  // TODO: Implement HttpMultipartResponseApi for file upload if needed
  // HarmonyOS supports uploading files via request.uploadFile, but for small multipart requests
  // we might need to construct the body manually if using http.request.
}
