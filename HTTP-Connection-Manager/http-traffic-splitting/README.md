# HTTP Traffic Splitting Demo

### 环境说明
#### 六个Service:

- envoy：Front Proxy,地址为172.31.57.10
- 5个后端服务
  - demoapp-v1.0-1、demoapp-v1.0-2和demoapp-v1.0-3：对应于Envoy中的demoappv10集群
  - demoapp-v1.1-1和demoapp-v1.1-2：对应于Envoy中的demoappv11集群

#### 使用的路由配置

```
            virtual_hosts:
            - name: demoapp
              domains: ["*"]
              routes:
              routes:
              - match:
                  prefix: "/"
                route:
                  weighted_clusters:
                    clusters:
                    - name: demoappv10
                      weight: 100
                    - name: demoappv11
                      weight: 0
                    total_weight: 100
                    runtime_key_prefix: routing.traffic_split.demoapp
```

### 运行和测试
1. 创建并运行容器
```
docker-compose up
```

2. 在一个特定的终端上，运行测试脚本send-request.sh

   ```
   # 脚本需要front-envoy的地址为参数，并每隔两秒钟向其发起一次HTTP请求
   ./send-request.sh 172.31.57.10
   demoapp-v1.0:demoapp-v1.1 = 1:0
   demoapp-v1.0:demoapp-v1.1 = 2:0
   demoapp-v1.0:demoapp-v1.1 = 3:0
   demoapp-v1.0:demoapp-v1.1 = 4:0
   demoapp-v1.0:demoapp-v1.1 = 5:0
   demoapp-v1.0:demoapp-v1.1 = 6:0
   demoapp-v1.0:demoapp-v1.1 = 7:0
   demoapp-v1.0:demoapp-v1.1 = 8:0
   demoapp-v1.0:demoapp-v1.1 = 9:0
   demoapp-v1.0:demoapp-v1.1 = 10:0
   demoapp-v1.0:demoapp-v1.1 = 11:0
   demoapp-v1.0:demoapp-v1.1 = 12:0
   demoapp-v1.0:demoapp-v1.1 = 13:0
   demoapp-v1.0:demoapp-v1.1 = 14:0
   demoapp-v1.0:demoapp-v1.1 = 15:0
   demoapp-v1.0:demoapp-v1.1 = 16:0
   demoapp-v1.0:demoapp-v1.1 = 17:0
   demoapp-v1.0:demoapp-v1.1 = 18:0
   demoapp-v1.0:demoapp-v1.1 = 19:0
   demoapp-v1.0:demoapp-v1.1 = 20:0
   demoapp-v1.0:demoapp-v1.1 = 21:0
   ……
   # 此时所有流量，所有流量都将由集群demoappv10承载，因为默认配置中，demoappv10与demoappv11的权重比为100:0；
   ```
   
3. 另外启动一个终端，动态调整流量分发比例

   ```
   # 将集群权重对调来模拟蓝绿部署，方法是在指定键（runtime_key）的值后附加以点号分隔的集群名称，并为其各自定义为相应的新权重值即可；
   curl -XPOST 'http://172.31.57.10:9901/runtime_modify?routing.traffic_split.demoapp.demoappv10=0&routing.traffic_split.demoapp.demoappv11=100'
   
   # 注意：各集群的权重之和要等于total_weight的值； 
   ```
   
4. 重新运行测试脚本，可以得出类似如下的结果

   ```
   # 在请求中使用特定的查询条件
   ./send-request.sh 172.31.57.10
   demoapp-v1.0:demoapp-v1.1 = 0:1
   demoapp-v1.0:demoapp-v1.1 = 0:2
   demoapp-v1.0:demoapp-v1.1 = 0:3
   demoapp-v1.0:demoapp-v1.1 = 0:4
   demoapp-v1.0:demoapp-v1.1 = 0:5
   demoapp-v1.0:demoapp-v1.1 = 0:6
   demoapp-v1.0:demoapp-v1.1 = 0:7
   demoapp-v1.0:demoapp-v1.1 = 0:8
   demoapp-v1.0:demoapp-v1.1 = 0:9
   demoapp-v1.0:demoapp-v1.1 = 0:10
   demoapp-v1.0:demoapp-v1.1 = 0:11
   demoapp-v1.0:demoapp-v1.1 = 0:12
   demoapp-v1.0:demoapp-v1.1 = 0:13
   demoapp-v1.0:demoapp-v1.1 = 0:14
   demoapp-v1.0:demoapp-v1.1 = 0:15
   demoapp-v1.0:demoapp-v1.1 = 0:16
   demoapp-v1.0:demoapp-v1.1 = 0:17
   demoapp-v1.0:demoapp-v1.1 = 0:18
   demoapp-v1.0:demoapp-v1.1 = 0:19
   demoapp-v1.0:demoapp-v1.1 = 0:20
   demoapp-v1.0:demoapp-v1.1 = 0:21
   demoapp-v1.0:demoapp-v1.1 = 0:22
   demoapp-v1.0:demoapp-v1.1 = 0:23
   demoapp-v1.0:demoapp-v1.1 = 0:24
   demoapp-v1.0:demoapp-v1.1 = 0:25
   ……
   # 测试的时间越长，样本数越大，越能接近于实际比例；
   # 事实上，我们完全可以阶段性地多次进行流量比例的微调；
   ```
   
5. 停止后清理

```
docker-compose down
```

## 版权声明
本文档版本归[马哥教育](www.magedu.com)所有，未经允许，不得随意转载和商用。
