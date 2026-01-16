export class HttpResponse {
  returnCode: number = -1;
  returnMessage: string = "";
  data: string = "";

  constructor(code: number = -1, message: string = "", data: string = "") {
    this.returnCode = code;
    this.returnMessage = message;
    this.data = data;
  }
}
