# Ring Hash LB Demo

### 环境说明
五个Service:
- envoy：Front Proxy,地址为172.31.25.2
- webserver01：第一个后端服务
- webserver01-sidecar：第一个后端服务的Sidecar Proxy,地址为172.31.25.11
- webserver02：第二个后端服务
- webserver02-sidecar：第二个后端服务的Sidecar Proxy,地址为172.31.25.12
- webserver03：第三个后端服务
- webserver03-sidecar：第三个后端服务的Sidecar Proxy,地址为172.31.25.13

### 运行和测试
1. 创建
```
docker-compose up
```

2. 测试
```
# 使用如下脚本即可直接发起服务请求，并根据结果中统计的各后端端点的响应大体比例，判定其是否能够大体符合目标调度机制；
./send-request.sh 172.31.25.2

# 也可以使用如下命令，将一个后端端点的健康检查结果置为失败，动态减少端点，并再次判定其调度结果；
curl -X POST -d 'livez=FAIL' http://172.31.25.11/livez
```

3. 停止后清理
```
docker-compose down
```

## 版权声明
本文档版本归[马哥教育](www.magedu.com)所有，未经允许，不得随意转载和商用。
