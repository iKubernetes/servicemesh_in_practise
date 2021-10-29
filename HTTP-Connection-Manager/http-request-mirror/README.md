# HTTP Request Mirror Demo

### 环境说明
#### 六个Service:

- envoy：Front Proxy,地址为172.31.60.10
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
                route:
                  cluster: demoappv10
                  request_mirror_policies:
                  - cluster: demoappv11
                    runtime_fraction:
                      default_value:
                        numerator: 20    # 默认只镜像demoappv10集群上20%的流量到该集群
                        denominator: HUNDRED
                      runtime_key: routing.request_mirror.demoapp
```

### 运行和测试
1. 创建并运行容器
```
docker-compose up
```

2. 在一个特定的终端上，运行测试脚本send-request.sh

   ```
   # 脚本需要front-envoy的地址为参数，并每隔两秒钟向其发起一次HTTP请求
   ./send-request.sh 172.31.60.10
   ServerName: demoapp-v1.0-1
   ServerName: demoapp-v1.0-2
   ServerName: demoapp-v1.0-3
   ServerName: demoapp-v1.0-1
   ServerName: demoapp-v1.0-3
   ServerName: demoapp-v1.0-1
   ……
   
   ```
   
   客户端的请求，仅会由demoappv10集群响应；镜像的流量的信息，可以在docker-compose命令控制台的日志信息中显示。当然，没有该控制台时，我们也可以通过demoappv11相关容器的控制台来了解访问请求是否到达。
   
   ```
   demoapp-v1.0-1_1  | 172.31.60.10 - - [29/Oct/2021 07:08:50] "GET /hostname HTTP/1.1" 200 -
   demoapp-v1.0-2_1  | 172.31.60.10 - - [29/Oct/2021 07:08:51] "GET /hostname HTTP/1.1" 200 -
   demoapp-v1.1-2_1  | 172.31.60.10 - - [29/Oct/2021 07:08:51] "GET /hostname HTTP/1.1" 200 -
   demoapp-v1.0-3_1  | 172.31.60.10 - - [29/Oct/2021 07:08:52] "GET /hostname HTTP/1.1" 200 -
   demoapp-v1.0-1_1  | 172.31.60.10 - - [29/Oct/2021 07:08:53] "GET /hostname HTTP/1.1" 200 -
   demoapp-v1.0-3_1  | 172.31.60.10 - - [29/Oct/2021 07:08:54] "GET /hostname HTTP/1.1" 200 -
   demoapp-v1.1-1_1  | 172.31.60.10 - - [29/Oct/2021 07:08:54] "GET /hostname HTTP/1.1" 200 -
   demoapp-v1.0-1_1  | 172.31.60.10 - - [29/Oct/2021 07:08:55] "GET /hostname HTTP/1.1" 200 -
   demoapp-v1.1-2_1  | 172.31.60.10 - - [29/Oct/2021 07:08:56] "GET /hostname HTTP/1.1" 200 -
   demoapp-v1.0-1_1  | 172.31.60.10 - - [29/Oct/2021 07:08:56] "GET /hostname HTTP/1.1" 200 -
   demoapp-v1.0-2_1  | 172.31.60.10 - - [29/Oct/2021 07:08:57] "GET /hostname HTTP/1.1" 200 -
   ……
   ```
   
3. 动态调整镜像流量的比例

   ```
   # 我们可以通过runtime_layer中的routing.request_mirror.demoapp键来调整镜像的流量的比例，例如，将其调整到100%，即镜像所有流量的方法如下；
    curl -XPOST 'http://172.31.60.10:9901/runtime_modify?routing.request_mirror.demoapp=100'
   ```

   调整完成后，再通过脚本发起请求测试

   ```
   ./send-request.sh 172.31.60.10
   ```

   而后可于docker-compose的控制台中看到类似如下日志，这表明流量已经100%镜像。

   ```
   demoapp-v1.0-1_1  | 172.31.60.10 - - [29/Oct/2021 07:16:03] "GET /hostname HTTP/1.1" 200 -
   demoapp-v1.1-2_1  | 172.31.60.10 - - [29/Oct/2021 07:16:03] "GET /hostname HTTP/1.1" 200 -
   demoapp-v1.0-3_1  | 172.31.60.10 - - [29/Oct/2021 07:16:03] "GET /hostname HTTP/1.1" 200 -
   demoapp-v1.1-1_1  | 172.31.60.10 - - [29/Oct/2021 07:16:03] "GET /hostname HTTP/1.1" 200 -
   demoapp-v1.1-2_1  | 172.31.60.10 - - [29/Oct/2021 07:16:04] "GET /hostname HTTP/1.1" 200 -
   demoapp-v1.0-1_1  | 172.31.60.10 - - [29/Oct/2021 07:16:04] "GET /hostname HTTP/1.1" 200 -
   demoapp-v1.0-2_1  | 172.31.60.10 - - [29/Oct/2021 07:16:05] "GET /hostname HTTP/1.1" 200 -
   demoapp-v1.1-1_1  | 172.31.60.10 - - [29/Oct/2021 07:16:05] "GET /hostname HTTP/1.1" 200 -
   demoapp-v1.1-2_1  | 172.31.60.10 - - [29/Oct/2021 07:16:05] "GET /hostname HTTP/1.1" 200 -
   demoapp-v1.0-2_1  | 172.31.60.10 - - [29/Oct/2021 07:16:05] "GET /hostname HTTP/1.1" 200 -
   demoapp-v1.0-3_1  | 172.31.60.10 - - [29/Oct/2021 07:16:06] "GET /hostname HTTP/1.1" 200 -
   demoapp-v1.1-1_1  | 172.31.60.10 - - [29/Oct/2021 07:16:06] "GET /hostname HTTP/1.1" 200 -
   demoapp-v1.0-1_1  | 172.31.60.10 - - [29/Oct/2021 07:16:06] "GET /hostname HTTP/1.1" 200 -
   ……
   ```

   

4. 停止后清理

```
docker-compose down
```

## 版权声明
本文档版本归[马哥教育](www.magedu.com)所有，未经允许，不得随意转载和商用。
