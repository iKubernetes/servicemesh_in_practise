# Locality Weighted Cluster Demo

### 环境说明
五个Service:
- envoy：Front Proxy,地址为172.31.31.2
- webserver01：第一个后端服务
- webserver01-sidecar：第一个后端服务的Sidecar Proxy,地址为172.31.31.11, 别名为red和webservice1
- webserver02：第二个后端服务
- webserver02-sidecar：第一个后端服务的Sidecar Proxy,地址为172.31.31.12, 别名为blue和webservice1
- webserver03：第三个后端服务
- webserver03-sidecar：第一个后端服务的Sidecar Proxy,地址为172.31.31.13, 别名为green和webservice1
- webserver04：第四个后端服务
- webserver04-sidecar：第四个后端服务的Sidecar Proxy,地址为172.31.31.14, 别名为gray和webservice2
- webserver05：第五个后端服务
- webserver05-sidecar：第五个后端服务的Sidecar Proxy,地址为172.31.31.15, 别名为black和webservice2

### 运行和测试
1. 创建
```
docker-compose up
```

2. 测试
```
# 通过send-requests.sh脚本进行测试，可发现，用户请求被按权重分配至不同的locality之上，每个locality内部再按负载均衡算法进行调度；
./send-requests.sh 172.31.31.2

# 可以试着将权重较高的一组中的某一主机的健康状态团置为不可用；


```

3. 停止后清理
```
docker-compose down
```

## 版权声明
本文档版本归[马哥教育](www.magedu.com)所有，未经允许，不得随意转载和商用。
