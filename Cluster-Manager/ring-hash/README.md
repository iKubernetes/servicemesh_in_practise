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
# 我们在路由hash策略中，hash计算的是用户的浏览器类型，因而，使用如下命令持续发起请求可以看出，用户请求将始终被定向到同一个后端端点；因为其浏览器类型一直未变。
while true; do curl 172.31.25.2; sleep .3; done

# 我们可以模拟使用另一个浏览器再次发请求；其请求可能会被调度至其它节点，也可能仍然调度至前一次的相同节点之上；这取决于hash算法的计算结果；
while true; do curl -H "User-Agent: Hello" 172.31.25.2; sleep .3; done

# 也可使用如下脚本，验证同一个浏览器的请求是否都发往了同一个后端端点，而不同浏览器则可能会被重新调度；
while true; do index=$[$RANDOM%10]; curl -H "User-Agent: Browser_${index}" 172.31.25.2/user-agent && curl -H "User-Agent: Browser_${index}" 172.31.25.2/hostname && echo ; sleep .1; done

# 也可以使用如下命令，将一个后端端点的健康检查结果置为失败，动态改变端点，并再次判定其调度结果，验证此前调度至该节点的请求是否被重新分配到了其它节点；
curl -X POST -d 'livez=FAIL' http://172.31.25.11/livez
```

3. 停止后清理
```
docker-compose down
```

## 版权声明
本文档版本归[马哥教育](www.magedu.com)所有，未经允许，不得随意转载和商用。
