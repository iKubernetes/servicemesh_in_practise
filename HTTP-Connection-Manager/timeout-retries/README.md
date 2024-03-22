# HTTP Request Mirror Demo

### 环境说明
##### 四个Service:

- envoy：Front Proxy,地址为172.31.65.10
- 3个后端服务
  - service_blue：对应于Envoy中的blue_abort集群，带有abort故障注入配置，地址为172.31.65.5；
  - service_red：对应于Envoy中的red_delay集群，带有delay故障注入配置，地址为172.31.65.7；
  - service_green：对应于Envoy中的green集群，地址为172.31.65.6；

##### 使用的abort配置

```
          http_filters:
          - name: envoy.filters.http.fault
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.fault.v3.HTTPFault
              max_active_faults: 100
              abort:
                http_status: 503
                percentage:
                  numerator: 50   # 为一半的请求注入中断故障，以便于在路由侧模拟重试的效果；
                  denominator: HUNDRED
```

##### 使用的delay配置

```
          http_filters:
          - name: envoy.filters.http.fault
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.fault.v3.HTTPFault
              max_active_faults: 100
              delay:
                fixed_delay: 10s
                percentage:
                  numerator: 50     # 为一半的请求注入延迟故障，以便于在路由侧模拟超时的效果；
                  denominator: HUNDRED
```

##### 超时和重试相关的配置

```
            virtual_hosts:
            - name: backend
              domains:
              - "*"
              routes:
              - match:
                  prefix: "/service/blue"
                route:
                  cluster: blue_abort
                  retry_policy:
                    retry_on: "5xx"   # 响应码为5xx时，则进行重试，重试最大次数为3次；
                    num_retries: 3
              - match:
                  prefix: "/service/red"
                route:
                  cluster: red_delay
                  timeout: 1s      # 超时时长为1秒，长于1秒，则执行超时操作；
              - match:
                  prefix: "/service/green"
                route:
                  cluster: green
              - match:
                  prefix: "/service/colors"
                route:
                  cluster: mycluster
                  retry_policy:    # 超时和重试策略同时使用； 
                    retry_on: "5xx"
                    num_retries: 3
                  timeout: 1s
```



### 运行和测试

1. 创建并运行容器
```
docker-compose up
```

2. 测试注入的delay故障

   ```
   # 反复向/service/red发起多次请求，被注入延迟的请求，会有较长的响应时长；
   curl -w"@curl_format.txt" -o /dev/null -s "http://172.31.65.10/service/red"
   
   # 在后端Envoy上被注入10秒延迟的请求，在请求时长超过一秒钟后即会触发前端Envoy上的重试操作，进而进行请求重试，直至首次遇到未被注入延迟的请求，因此其总的响应时长一般为1秒多一点：
       time_namelookup:  0.000020
          time_connect:  0.000141
       time_appconnect:  0.000000
      time_pretransfer:  0.000164
         time_redirect:  0.000000
    time_starttransfer:  1.000309
                       ----------
            time_total:  1.000351
   ```
   
3. 测试注入的abort故障

   ```
   # 反复向/service/blue发起多次请求，后端被Envoy注入中断的请求，会因为响应的503响应码而触发自定义的
   # 重试操作；最大3次的重试，仍有可能在连续多次的错误响应后，仍然响应以错误信息，但其比例会大大降低。
   ./send-requests.sh 172.31.65.10/service/blue 100 
   200
   200
   200
   503
   200
   200
   200
   200
   200
   200
   503
   200
   200
   503
   200
   200
   ……
   
   #被注入了abort的请求，将响应以503的响应码；
   ```

   

4. 发往/service/green的请求，因后端无故障注入而几乎全部得到正常响应

   ```
   ./send-requests.sh 172.31.65.10/service/green 100     
   200
   200
   200
   200
   200
   200
   200
   200
   ……
   ```

5. 发往/service/colors的请求，会被调度至red_delay、blue_abort和green三个集群，它们有的可能被延迟、有的可能被中断；

   ```
   ./send-requests.sh 172.31.65.10/service/colors 100 
   200
   200
   200
   200
   200
   504     # 504响应码是由于上游请求超时所致
   200
   200
   200
   504
   200
   ……
   ```

   

6. 停止后清理

```
docker-compose down
```

## 版权声明
本文档版本归[马哥教育](www.magedu.com)所有，未经允许，不得随意转载和商用。
