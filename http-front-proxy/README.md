# HTTP Proxy demo

### 环境说明
三个Service:
- envoy：Front Proxy,地址为172.31.0.2
- webserver01：第一个后端服务,地址为172.31.0.11
- webserver02：第二个后端服务,地址为172.31.0.12

### 运行和测试
1. 创建
```
docker-compose up
```

2. 测试
```
curl 172.31.0.2
```

3. 停止后清理
```
docker-compose down
```

## 版本声明
本文档版本归[马哥教育](www.magedu.com)所有，未经允许，不得随意转载和商用。
