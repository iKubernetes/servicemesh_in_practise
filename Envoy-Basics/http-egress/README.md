# HTTP Egress Proxy demo

### 环境说明
三个Service:
- envoy：Front Proxy,地址为172.31.4.2
- webserver01：第一个外部服务,地址为172.31.4.11
- webserver02：第二个外部服务,地址为172.31.4.12

### 运行和测试
1. 创建
```
docker-compose up
```

2. 于容器client的交互式接口中进行测试
```
docker exec -it http-egress_client_1  /bin/sh
curl 127.0.0.1 
```

3. 停止后清理
```
docker-compose down
```

## 版权声明
本文档版本归[马哥教育](www.magedu.com)所有，未经允许，不得随意转载和商用。
