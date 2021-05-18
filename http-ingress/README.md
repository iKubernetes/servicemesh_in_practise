# HTTP Ingress Proxy demo

### 环境说明
两个Service:
- envoy：Sidecar Proxy
- webserver01：第一个后端服务,地址为127.0.0.1

### 运行和测试
1. 创建
```
docker-compose up
```

2. 测试
```
curl 172.33.0.2
```

3. 停止后清理
```
docker-compose down
```

## 版本声明
本文档版本归[马哥教育](www.magedu.com)所有，未经允许，不得随意转载和商用。
