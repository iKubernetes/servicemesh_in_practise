# HTTP Request Mirror Demo

### 环境说明
##### Envoy Mesh使用的网络: 172.31.62.0/24

##### 四个Service:

- envoy：Front Proxy,地址为172.31.62.10
- 3个后端服务
  - service_blue：对应于Envoy中的blue_abort集群，带有abort故障注入配置
  - service_red：对应于Envoy中的red_delay集群，带有delay故障注入配置
  - service_green：对应于Envoy中的green集群

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
                  numerator: 10      # 向10%的请求注入503中断
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
                  numerator: 10     # 向10%的请求注入10秒钟的延迟
                  denominator: HUNDRED
```



### 运行和测试

1. 创建并运行容器
```
docker-compose up
```

2. 测试注入的delay故障

   ```
   # 反复向/service/red发起多次请求，被注入延迟的请求，会有较长的响应时长；
   curl -w"@curl_format.txt" -o /dev/null -s "http://172.31.62.10/service/red"
   
   #被后端Envoy注入了delay的请求，将被Front-Envoy响应以类似如下内容：
       time_namelookup:  0.000054
          time_connect:  0.000261
       time_appconnect:  0.000000
      time_pretransfer:  0.000349
         time_redirect:  0.000000
    time_starttransfer:  10.007628
                       ----------
            time_total:  10.007820
   ```
   
3. 测试注入的abort故障

   ```
   # 反复向/service/blue发起多次请求，被注入中断的请求，则响应以503代码；
   curl -o /dev/null -w '%{http_code}\n' -s "http://172.31.62.10/service/blue"
   ```
   
   

4. 发往/service/green的请求，将无故障注入

5. 发往/的请求，会被调度至red_delay、blue_abort和green三个集群，它们有的可能被延迟、有的可能被中断；

6. 停止后清理

```
docker-compose down
```

## 版权声明
本文档版本归[马哥教育](www.magedu.com)所有，未经允许，不得随意转载和商用。
