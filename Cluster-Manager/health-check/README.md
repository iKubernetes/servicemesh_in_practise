# Outlier Detection Demo

### 环境说明
五个Service:
- envoy：Front Proxy,地址为172.31.18.2
- webserver01：第一个后端服务
- webserver01-sidecar：第一个后端服务的Sidecar Proxy,地址为172.31.18.11
- webserver02：第二个后端服务
- webserver02-sidecar：第二个后端服务的Sidecar Proxy,地址为172.31.18.12

### 运行和测试
1. 创建
```
docker-compose up
```

2. 测试
```
# 持续请求服务上的特定路径/livez
while true; do curl 172.31.18.2; sleep 1; done

# 等服务调度就绪后，另启一个终端，修改其中任何一个服务的/livez响应为非"OK"值，例如，修改第一个后端端点;
curl -X POST -d 'livez=FAIL' http://172.31.18.11/livez

# 通过请求的响应结果即可观测服务调度及响应的记录

# 请求中，可以看出第一个端点因主动健康状态检测失败，因而会被自动移出集群，直到其再次转为健康为止；
# 我们可使用类似如下命令修改为正常响应结果；
curl -X POST -d 'livez=OK' http://172.31.18.11/livez
```

3. 停止后清理
```
docker-compose down
```

## 版权声明
本文档版本归[马哥教育](www.magedu.com)所有，未经允许，不得随意转载和商用。
