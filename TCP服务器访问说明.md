# TCP服务器访问说明

## 当前配置

### TCP服务器
- **监听地址**：`192.168.0.15:8081`
- **问题**：使用固定IP，如果设备IP不是 `192.168.0.15`，服务器将无法启动

### TCP客户端
- **目标地址**：`192.168.0.16:8081`
- **用途**：连接到外部TCP服务器

---

## 访问方式

### 方式1：使用固定IP（当前配置）

**适用场景**：
- 设备IP固定为 `192.168.0.15`
- 局域网内其他设备连接

**访问方法**：
```bash
# 使用 telnet 测试连接
telnet 192.168.0.15 8081

# 使用 nc (netcat) 测试
nc 192.168.0.15 8081

# 使用 Python 测试
python -c "import socket; s=socket.socket(); s.connect(('192.168.0.15', 8081)); s.send(b'Hello'); print(s.recv(1024))"
```

**限制**：
- 如果设备IP不是 `192.168.0.15`，服务器无法启动
- 只能从同一局域网访问

---

### 方式2：使用 `0.0.0.0` 监听所有接口（推荐）

**优势**：
- 自动监听所有网络接口
- 不依赖固定IP
- 可以从局域网内任意IP访问

**修改方法**：
将 `NetworkOptimizer.ets` 中的：
```typescript
const TCP_SERVER_IP: string = '192.168.0.15';  // ❌ 固定IP
```
改为：
```typescript
const TCP_SERVER_IP: string = '0.0.0.0';  // ✅ 监听所有接口
```

**访问方法**：
```bash
# 假设设备实际IP是 192.168.0.100
telnet 192.168.0.100 8081

# 或者使用 localhost（同一设备）
telnet localhost 8081
```

---

## 如何获取设备实际IP地址

### 方法1：通过HTTP服务器查看

HTTP服务器监听在 `0.0.0.0:8080`，可以通过以下方式获取IP：

```bash
# 在设备上执行（通过 hdc）
hdc shell ifconfig | grep "inet "

# 或者在应用日志中查看
# 查看 DevEco Studio 的 Log 窗口，搜索 "HTTP服务器启动成功"
```

### 方法2：通过系统设置查看

1. 打开设备设置
2. 进入"网络和互联网"或"WLAN"
3. 查看当前连接的WiFi详情
4. 记录IP地址（通常是 `192.168.x.x`）

### 方法3：通过路由器查看

1. 登录路由器管理界面
2. 查看"已连接设备"列表
3. 找到你的HarmonyOS设备
4. 查看分配的IP地址

---

## 端口映射（如果需要外网访问）

### 场景说明

**局域网访问**（无需端口映射）：
- 设备IP：`192.168.0.100`
- 访问地址：`192.168.0.100:8081`
- 同一WiFi下的设备可以直接访问

**外网访问**（需要端口映射）：
- 需要配置路由器端口转发
- 将外网IP的8081端口映射到设备的8081端口

### 端口映射步骤

1. **登录路由器管理界面**
   - 通常地址：`192.168.1.1` 或 `192.168.0.1`
   - 查看路由器背面标签获取地址

2. **找到"端口转发"或"虚拟服务器"设置**
   - 不同路由器界面不同
   - 常见位置：高级设置 → 端口转发

3. **添加端口映射规则**
   ```
   服务名称：TCP服务器
   外部端口：8081
   内部IP：192.168.0.100（设备IP）
   内部端口：8081
   协议：TCP
   ```

4. **保存并重启路由器**

5. **获取公网IP**
   ```bash
   # 访问以下网站查看公网IP
   https://www.ip138.com/
   https://ip.sb/
   ```

6. **外网访问**
   ```bash
   telnet <公网IP> 8081
   ```

**注意**：
- 需要公网IP（不是内网IP）
- 运营商可能封禁常用端口
- 建议使用非标准端口（如 28081）

---

## 测试连接

### 使用 telnet（Windows）

```bash
# 打开命令提示符
telnet 192.168.0.15 8081

# 如果提示"telnet不是内部或外部命令"
# 需要在"启用或关闭Windows功能"中启用telnet客户端
```

### 使用 nc (netcat)（Linux/Mac）

```bash
# 测试连接
nc 192.168.0.15 8081

# 发送消息
echo "Hello Server" | nc 192.168.0.15 8081
```

### 使用 Python 脚本

```python
import socket

# 创建TCP连接
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect(('192.168.0.15', 8081))

# 发送消息
sock.send(b'Hello from Python\n')

# 接收响应
response = sock.recv(1024)
print(f'收到: {response.decode()}')

# 关闭连接
sock.close()
```

### 使用 Node.js 脚本

```javascript
const net = require('net');

const client = new net.Socket();
client.connect(8081, '192.168.0.15', () => {
    console.log('已连接到TCP服务器');
    client.write('Hello from Node.js\n');
});

client.on('data', (data) => {
    console.log('收到:', data.toString());
    client.destroy();
});

client.on('close', () => {
    console.log('连接已关闭');
});
```

---

## 推荐配置修改

### 修改为监听所有接口

**文件**：`entry/src/main/ets/utils/network/NetworkOptimizer.ets`

**修改前**：
```typescript
const TCP_SERVER_IP: string = '192.168.0.15';      // TCP 服务器监听地址
```

**修改后**：
```typescript
const TCP_SERVER_IP: string = '0.0.0.0';      // TCP 服务器监听地址（监听所有接口）
```

**好处**：
- ✅ 不依赖固定IP
- ✅ 自动适配设备IP变化
- ✅ 可以从局域网内任意IP访问
- ✅ 更灵活，适合不同网络环境

---

## 常见问题

### Q1: 服务器启动失败，提示"地址已被使用"

**原因**：
- 端口被其他程序占用
- 之前的服务器进程未完全关闭

**解决方法**：
```bash
# 查看端口占用（通过 hdc）
hdc shell netstat -an | grep 8081

# 或者重启应用
```

### Q2: 无法从其他设备连接

**检查清单**：
1. ✅ 设备IP是否正确
2. ✅ 端口号是否正确（8081）
3. ✅ 防火墙是否允许8081端口
4. ✅ 设备是否在同一局域网
5. ✅ 服务器是否成功启动（查看日志）

### Q3: 如何查看服务器日志

**方法**：
1. 打开 DevEco Studio
2. 查看 Log 窗口
3. 过滤关键词：`TCP服务器`
4. 查看启动和连接日志

### Q4: 客户端连接失败

**检查**：
1. 目标服务器IP是否正确（`TCP_CLIENT_REMOTE_IP`）
2. 目标服务器是否运行
3. 网络是否可达
4. 查看客户端日志

---

## 总结

1. **推荐使用 `0.0.0.0`** 作为服务器监听地址，更灵活
2. **局域网访问**：直接使用设备IP + 端口
3. **外网访问**：需要配置路由器端口映射
4. **测试连接**：使用 telnet、nc 或脚本工具
5. **查看日志**：通过 DevEco Studio Log 窗口

