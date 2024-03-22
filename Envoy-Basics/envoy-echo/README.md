# envoy-echo demo

### 环境说明
一个Service:
- envoy：Front Proxy,地址为172.31.4.4

### 运行和测试
1. 创建
```
docker-compose up
```

2. 测试，于宿主机上运行如下命令
```
# 测试访问8080端口，并键入任意字符串
telnet 172.31.4.4 8080
```

3. 停止后清理
```
docker-compose down
```

## 版权声明
本文档版本归[马哥教育](www.magedu.com)所有，未经允许，不得随意转载和商用。
