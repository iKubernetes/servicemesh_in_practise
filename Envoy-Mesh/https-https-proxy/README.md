# TLS Front Proxy demo

### 环境说明
五个Service:
- envoy：Front Proxy,地址为172.31.8.2，监听于8443端口
- webserver01：第一个后端服务
- webserver01-sidecar：第一个后端服务的Sidecar Proxy,地址为172.31.8.11，监听于443端口
- webserver02：第二个后端服务
- webserver02-sidecar：第二个后端服务的Sidecar Proxy,地址为172.31.8.12, 监听于443端口

### 运行和测试
1. 创建
```
docker-compose up
```

2. 测试
```
# https请求测试
curl -s https://172.31.8.2:8443/

# 请求访问admin interface
curl http://172.31.8.2:9901/
```

3. 停止后清理
```
docker-compose down
```

## 版权声明
本文档版本归[马哥教育](www.magedu.com)所有，未经允许，不得随意转载和商用。
