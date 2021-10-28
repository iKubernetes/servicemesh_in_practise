# LB Subset Cluster Demo

### 环境说明
五个Service:
- envoy：Front Proxy,地址为172.31.33.2
- [e1, e7]：7个后端服务

### 运行和测试
1. 创建
```
docker-compose up
```

2. 测试
```
# test.sh脚本接受front-envoy的地址，并持续向该地址发起请求，而后显示流量分配的结果；根据路由规则，未指定x-hardware-test和x-custom-version且给予了相应值的请求，均会调度给默认子集，且在两个组之间进行流量分发；
./test.sh 172.31.33.2

# 我们可以指定特殊的首部发出特定的请求，例如附带有”x-hardware-test: memory”的请求，将会被分发至特定的子集；该子集要求标签type的值为bigmem，而标签stage的值为prod；该子集共有e5和e6两个端点
curl -H "x-hardware-test: memory" 172.31.33.2/hostname

# 或者，我们也可以指定特殊的首部发出特定的请求，例如附带有”x-custom-version: pre-release”的请求，将会被分发至特定的子集；该子集要求标签version的值为1.2-pre，而标签stage的值为dev；该子集有e7一个端点;
curl -H "x-custome-version: pre-release" 172.31.33.2/hostname
```

3. 停止后清理
```
docker-compose down
```

## 版权声明
本文档版本归[马哥教育](www.magedu.com)所有，未经允许，不得随意转载和商用。
