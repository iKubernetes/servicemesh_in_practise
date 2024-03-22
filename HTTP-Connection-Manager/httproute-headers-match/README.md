# HTTP Route Headers Match Demo

### 环境说明
#### 六个Service:

- envoy：Front Proxy,地址为172.31.52.10
- 5个后端服务
  - demoapp-v1.0-1和demoapp-v1.0-2：对应于Envoy中的demoappv10集群
  - demoapp-v1.1-1和demoapp-v1.1-2：对应于Envoy中的demoappv11集群
  - demoapp-v1.2-1：对应于Envoy中的demoappv12集群

#### 使用的路由配置

```
            virtual_hosts:
            - name: vh_001
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                  headers:
                  - name: X-Canary
                    exact_match: "true"
                route:
                  cluster: demoappv12
              - match:
                  prefix: "/"
                  query_parameters:
                  - name: "username"
                    string_match:
                      prefix: "vip_"
                route:
                  cluster: demoappv11
              - match:
                  prefix: "/"
                route:
                  cluster: demoappv10
```

### 运行和测试
1. 创建并运行容器
```
docker-compose up
```

2. 发起无附加条件的请求

   ```
   # 不使用任何独特的访问条件
   curl 172.31.52.10/hostname
   ServerName: demoapp-v1.0-1
   
   curl 172.31.52.10/hostname
   ServerName: demoapp-v1.0-2
   ```
   
3. 测试使用“X-Canary: true”村头的请求

   ```
   # 使用特定的标头发起请求
   curl -H "X-Canary: true" 172.31.52.10/hostname  
   ServerName: demoapp-v1.2-1
   ```
   
4. 测试使用特定的查询条件

   ```
   # 在请求中使用特定的查询条件
   curl 172.31.52.10/hostname?username=vip_mageedu
   ServerName: demoapp-v1.1-1
   
   curl 172.31.52.10/hostname?username=vip_ilinux     
   ServerName: demoapp-v1.1-2
   ```

5. 停止后清理

```
docker-compose down
```

## 版权声明
本文档版本归[马哥教育](www.magedu.com)所有，未经允许，不得随意转载和商用。
