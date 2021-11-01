## 使用Prometheus和Grafana监控Envoy Mesh 
### 架构示意图
![setup](https://github.com/iKubernetes/servicemesh_in_practise/blob/develop/Monitoring-and-Tracing/monitoring/envoy_monitoring.png)

##### Envoy Mesh使用的网络: 172.31.70.0/24

##### 10个Service:

- front-envoy：Front Proxy,地址为172.31.70.10
- 6个后端服务
  - service_a_envoy和service_a：对应于Envoy中的service_a集群，会调用service_b和service_c；
  - service_b_envoy和service_b：对应于Envoy中的service_b集群；
  - service_c_envoy和service_c：对应于Envoy中的service_c集群；
- 1个statsd_exporter服务
- 1个prometheus服务
- 1个grafana服务

### 运行并测试

1.  启动服务

   ```
   docker-compose build
   docker-compose up
   ```

2. 访问测试

   向Front-Envoy发起请求，下面的命令模拟间隔1秒之内的随机时长进行请求；

   ```
   while true; do curl 172.31.70.10; sleep 0.$RANDOM; done
   
   命令会输出类似如下响应结果：
   Calling Service B: Hello from service B.
   Hello from service A.
   Hello from service C.
   Calling Service B: Hello from service B.
   Hello from service A.
   Hello from service C.
   Calling Service B: fault filter abortHello from service A.
   Hello from service C.
   Calling Service B: Hello from service B.
   Hello from service A.
   Hello from service C.
   Calling Service B: Hello from service B.
   Hello from service A.
   Hello from service C.
   ……
   ```

3. 查看Prometheus

   访问宿主机的9090端口即可打开Prometheus的表达式浏览器；

   ![prometheus](https://github.com/iKubernetes/servicemesh_in_practise/blob/develop/Monitoring-and-Tracing/monitoring/prometheus.png)

4. 查看Grafana

   访问宿主机的3000端口，即可打开Grafana的控制台界面

   ![grafana](https://github.com/iKubernetes/servicemesh_in_practise/blob/develop/Monitoring-and-Tracing/monitoring/grafana.png)

   

5. 停止后清理

```
docker-compose down
```

## 版权声明

本文档版本归[马哥教育](www.magedu.com)所有，未经允许，不得随意转载和商用。
