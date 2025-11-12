/**
 * 网络工具类
 * 功能：提供网络通信的辅助工具方法
 * 职责：
 * - 提供IP地址和端口验证
 * - 提供网络连接测试
 * - 提供数据格式转换
 * - 提供错误处理
 * - 提供日志记录
 * 
 * 主要方法：
 * - validateIPAddress(ip): 验证IP地址格式是否正确
 * - validatePort(port): 验证端口号是否在有效范围内
 * - testConnection(address, port): 测试网络连接是否可达
 * - parseJSON(data): 安全解析JSON数据
 * - formatMessage(type, content): 格式化消息数据
 * - logNetworkEvent(event, details): 记录网络事件日志
 * - getLocalIPAddress(): 获取本机IP地址
 * - isNetworkAvailable(): 检查网络是否可用
 * - createErrorMessage(error): 创建标准错误消息
 * - sanitizeInput(input): 清理用户输入数据
 * 
 * 工具方法：
 * - IP地址格式验证（IPv4/IPv6）
 * - 端口号范围检查（1-65535）
 * - JSON数据解析和验证
 * - 网络状态检查
 * - 统一的日志输出格式
 * - 数据格式转换和验证
 * - 错误处理和异常捕获
 */
