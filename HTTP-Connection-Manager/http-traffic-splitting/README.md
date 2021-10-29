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
                      weight: 90
                    - name: demoappv11
                      weight: 10
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
   demoapp-v1.0:demoapp-v1.1 = 2:1
   demoapp-v1.0:demoapp-v1.1 = 3:1
   demoapp-v1.0:demoapp-v1.1 = 4:1
   demoapp-v1.0:demoapp-v1.1 = 5:1
   demoapp-v1.0:demoapp-v1.1 = 5:1
   demoapp-v1.0:demoapp-v1.1 = 6:1
   demoapp-v1.0:demoapp-v1.1 = 7:1
   demoapp-v1.0:demoapp-v1.1 = 8:1
   ……
   # 此时所有流量，90%都将由集群demoappv10所承载，因为默认配置中，demoappv10与demoappv11的权重比为90:10；
   ```
   
3. 另外启动一个终端，动态调整流量分发比例

   ```
   # 将保留给demoappv10集群的流量比例调整为50%，方法是在指定键（runtime_key）的值后附加以点号分隔的集群名称，并为其各自定义为相应的新权重值即可；
   curl -XPOST 'http://172.31.57.10:9901/runtime_modify?routing.traffic_split.demoapp.demoappv10=50&routing.traffic_split.demoapp.demoappv11=50'
   
   # 注意：各集群的权重之和要等于total_weight的值； 
   ```
   
4. 重新运行测试脚本，可以得出类似如下的结果

   ```
   # 在请求中使用特定的查询条件
   ./send-request.sh 172.31.57.10
   demoapp-v1.0:demoapp-v1.1 = 0:1
   demoapp-v1.0:demoapp-v1.1 = 1:1
   demoapp-v1.0:demoapp-v1.1 = 2:1
   demoapp-v1.0:demoapp-v1.1 = 3:1
   demoapp-v1.0:demoapp-v1.1 = 3:2
   demoapp-v1.0:demoapp-v1.1 = 3:3
   demoapp-v1.0:demoapp-v1.1 = 3:4
   demoapp-v1.0:demoapp-v1.1 = 4:4
   demoapp-v1.0:demoapp-v1.1 = 4:5
   demoapp-v1.0:demoapp-v1.1 = 4:6
   demoapp-v1.0:demoapp-v1.1 = 5:6
   demoapp-v1.0:demoapp-v1.1 = 5:7
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
