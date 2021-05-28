# Outlier Detection Demo

### 环境说明
五个Service:
- envoy：Front Proxy,地址为172.31.20.2
- webserver01：第一个后端服务
- webserver01-sidecar：第一个后端服务的Sidecar Proxy,地址为172.31.20.11, 别名为red和webservice1
- webserver02：第二个后端服务
- webserver02-sidecar：第一个后端服务的Sidecar Proxy,地址为172.31.20.12, 别名为blue和webservice1
- webserver03：第三个后端服务
- webserver03-sidecar：第一个后端服务的Sidecar Proxy,地址为172.31.20.13, 别名为green和webservice1
- webserver04：第四个后端服务
- webserver04-sidecar：第四个后端服务的Sidecar Proxy,地址为172.31.20.14, 别名为gray和webservice2
- webserver05：第五个后端服务
- webserver05-sidecar：第五个后端服务的Sidecar Proxy,地址为172.31.20.15, 别名为black和webservice2

### 运行和测试
1. 创建
```
docker-compose up
```

2. 测试
```
持续请求服务，可发现，请求均被调度至优先级为0的webservice1相关的后端端点之上；
while true; do curl 172.31.29.2; sleep .5; done

# 等确定服务的调度结果后，另启一个终端，修改webservice1中任何一个后端端点的/livez响应为非"OK"值，例如，修改第一个后端端点;
curl -X POST -d 'livez=FAIL' http://172.31.20.11/livez

# 而后通过请求的响应结果可发现，因过载因子为1.4，客户端的请求仍然始终只发往webservice1的后端端点blue和green之上；

# 等确定服务的调度结果后，再修改其中任何一个服务的/livez响应为非"OK"值，例如，修改第一个后端端点;
curl -X POST -d 'livez=FAIL' http://172.31.20.12/livez

# 请求中，可以看出第一个端点因响应5xx的响应码，每次被加回之后，会再次弹出，除非使用类似如下命令修改为正常响应结果；
curl -X POST -d 'livez=OK' http://172.31.20.11/livez

# 而后通过请求的响应结果可发现，因过载因子为1.4，优先级为0的webserver1已然无法锁住所有的客户端请求，于是，客户端的请求的部分流量将被转发至webservice2的端点之上；
```

3. 停止后清理
```
docker-compose down
```

## 版权声明
本文档版本归[马哥教育](www.magedu.com)所有，未经允许，不得随意转载和商用。
