# HTTP Traffic Shifting Demo

### 环境说明
#### 六个Service:

- envoy：Front Proxy,地址为172.31.55.10
- 5个后端服务
  - demoapp-v1.0-1、demoapp-v1.0-2和demoapp-v1.0-3：对应于Envoy中的demoappv10集群
  - demoapp-v1.1-1和demoapp-v1.1-2：对应于Envoy中的demoappv11集群

#### 使用的路由配置

```
            virtual_hosts:
            - name: demoapp
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                  runtime_fraction:
                    default_value:
                      numerator: 100
                      denominator: HUNDRED
                    runtime_key: routing.traffic_shift.demoapp
                route:
                  cluster: demoappv10
              - match:
                  prefix: "/"
                route:
                  cluster: demoappv11
```

### 运行和测试
1. 创建并运行容器
```
docker-compose up
```

2. 在一个特定的终端上，运行测试脚本send-request.sh

   ```
   # 脚本需要front-envoy的地址为参数，并每隔两秒钟向其发起一次HTTP请求
   ./send-request.sh 172.31.55.10
   demoapp-v1.0:demoapp-v1.1 = 1:0
   demoapp-v1.0:demoapp-v1.1 = 2:0
   demoapp-v1.0:demoapp-v1.1 = 3:0
   demoapp-v1.0:demoapp-v1.1 = 4:0
   ……
   # 此时所有流量，都将由集群demoappv10所承载，因为默认配置中，100%的流量比例将保留给该集群
   ```
   
3. 另外启动一个终端，动态调整流量分发比例

   ```
   # 将保留给demoappv10集群的流量比例调整为90%，方法是将指定键的值定义为相应的分子数即可
   curl -XPOST http://172.31.55.10:9901/runtime_modify?routing.traffic_shift.demoapp=90
   ```
   
4. 重新运行测试脚本，可以得出类似如下的结果

   ```
   # 在请求中使用特定的查询条件
   ./send-request.sh 172.31.55.10
   demoapp-v1.0:demoapp-v1.1 = 1:0
   demoapp-v1.0:demoapp-v1.1 = 2:0
   demoapp-v1.0:demoapp-v1.1 = 3:0
   demoapp-v1.0:demoapp-v1.1 = 4:0
   demoapp-v1.0:demoapp-v1.1 = 5:0
   demoapp-v1.0:demoapp-v1.1 = 6:0
   demoapp-v1.0:demoapp-v1.1 = 6:1
   demoapp-v1.0:demoapp-v1.1 = 7:1
   demoapp-v1.0:demoapp-v1.1 = 8:1
   demoapp-v1.0:demoapp-v1.1 = 9:1
   demoapp-v1.0:demoapp-v1.1 = 10:1
   demoapp-v1.0:demoapp-v1.1 = 11:1
   demoapp-v1.0:demoapp-v1.1 = 12:1
   demoapp-v1.0:demoapp-v1.1 = 13:1
   demoapp-v1.0:demoapp-v1.1 = 14:1
   demoapp-v1.0:demoapp-v1.1 = 15:1
   demoapp-v1.0:demoapp-v1.1 = 16:1
   demoapp-v1.0:demoapp-v1.1 = 17:1
   demoapp-v1.0:demoapp-v1.1 = 18:1
   demoapp-v1.0:demoapp-v1.1 = 18:2
   demoapp-v1.0:demoapp-v1.1 = 19:2
   demoapp-v1.0:demoapp-v1.1 = 20:2
   demoapp-v1.0:demoapp-v1.1 = 21:2
   demoapp-v1.0:demoapp-v1.1 = 22:2
   demoapp-v1.0:demoapp-v1.1 = 23:2
   demoapp-v1.0:demoapp-v1.1 = 24:2
   demoapp-v1.0:demoapp-v1.1 = 25:2
   demoapp-v1.0:demoapp-v1.1 = 25:3
   demoapp-v1.0:demoapp-v1.1 = 26:3
   demoapp-v1.0:demoapp-v1.1 = 27:3
   demoapp-v1.0:demoapp-v1.1 = 28:3
   demoapp-v1.0:demoapp-v1.1 = 29:3
   demoapp-v1.0:demoapp-v1.1 = 30:3
   demoapp-v1.0:demoapp-v1.1 = 31:3
   demoapp-v1.0:demoapp-v1.1 = 32:3
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
