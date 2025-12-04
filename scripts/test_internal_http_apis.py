import json
import time
from urllib import request, error


BASE_URL = "http://127.0.0.1:8080"


def http_request(method: str, path: str, body: dict | None = None):
    """
    通用 HTTP 请求封装，用于测试本地 Harmony 应用内置 HTTP 接口。
    """
    url = BASE_URL + path
    data_bytes = None
    headers = {
        "Content-Type": "application/json; charset=utf-8",
        "Accept": "application/json",
    }

    if body is not None:
        data_str = json.dumps(body, ensure_ascii=False)
        data_bytes = data_str.encode("utf-8")

    req = request.Request(url, data=data_bytes, headers=headers, method=method.upper())
    try:
        with request.urlopen(req, timeout=10) as resp:
            resp_bytes = resp.read()
            text = resp_bytes.decode("utf-8", errors="ignore")
            print(f"\n[{method} {path}] HTTP {resp.status}")
            print(text)
            try:
                return json.loads(text)
            except Exception:
                return text
    except error.HTTPError as e:
        print(f"\n[{method} {path}] HTTPError {e.code}")
        print(e.read().decode("utf-8", errors="ignore"))
    except Exception as e:
        print(f"\n[{method} {path}] ERROR: {e}")
    return None


def test_fruitinfo():
    print("\n===== 测试 /api/fruitinfo =====")
    # 1. 创建
    create_body = {
        "CustomerName": "HTTP测试客户",
        "FruitName": "HTTP测试水果",
        "BatchWeight": 123.45,
        "BatchNumber": 12,
        "SortType": 1,
        "ProgramName": "HttpTestProgram",
    }
    resp = http_request("POST", "/api/fruitinfo", create_body)
    fruit_id = None
    if isinstance(resp, dict) and resp.get("ok") and isinstance(resp.get("data"), dict):
        fruit_id = resp["data"].get("id")
    print(f"创建 FruitInfo 返回ID: {fruit_id}")

    # 2. 列表查询
    http_request("GET", "/api/fruitinfo?page=1&size=10")

    # 3. 根据ID查询 + 删除
    if fruit_id:
        http_request("GET", f"/api/fruitinfo/{fruit_id}")
        http_request("DELETE", f"/api/fruitinfo/{fruit_id}")


def test_gradeinfo():
    print("\n===== 测试 /api/gradeinfo =====")
    create_body = {
        "CustomerID": 2001,
        "ChannelID": 1,
        "QualityIndex": 1,
        "SizeID": 1,
        "SizeIndex": 1,
        "BoxNumber": 5,
        "FruitNumber": 50,
        "FruitWeight": 25.5,
        "FPrice": 9.99,
        "GradeID": 1,
        "QualityName": "HTTP测试等级",
    }
    resp = http_request("POST", "/api/gradeinfo", create_body)
    grade_id = None
    if isinstance(resp, dict) and resp.get("ok") and isinstance(resp.get("data"), dict):
        grade_id = resp["data"].get("id")
    print(f"创建 GradeInfo 返回ID: {grade_id}")

    http_request("GET", "/api/gradeinfo?page=1&size=10")

    if grade_id:
        http_request("GET", f"/api/gradeinfo/{grade_id}")
        http_request("DELETE", f"/api/gradeinfo/{grade_id}")


def test_exportinfo():
    print("\n===== 测试 /api/exportinfo =====")
    create_body = {
        "CustomerID": 3001,
        "ChannelID": 1,
        "ExportID": 100,
        "FruitNumber": 60,
        "FruitWeight": 30.5,
        "BoxNumber": 6,
        "ExitName": "HTTP测试出口",
    }
    resp = http_request("POST", "/api/exportinfo", create_body)
    export_id = None
    if isinstance(resp, dict) and resp.get("ok") and isinstance(resp.get("data"), dict):
        export_id = resp["data"].get("id")
    print(f"创建 ExportInfo 返回ID: {export_id}")

    http_request("GET", "/api/exportinfo?page=1&size=10")

    if export_id:
        http_request("GET", f"/api/exportinfo/{export_id}")
        http_request("DELETE", f"/api/exportinfo/{export_id}")


if __name__ == "__main__":
    print("开始 HTTP 外部接口测试（FruitInfo / GradeInfo / ExportInfo）...")
    test_fruitinfo()
    time.sleep(0.5)
    test_gradeinfo()
    time.sleep(0.5)
    test_exportinfo()
    print("\n全部测试完成。")


