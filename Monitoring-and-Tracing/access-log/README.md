## 使用Prometheus和Grafana监控Envoy Mesh 
### 环境说明

##### Envoy Mesh使用的网络: 172.31.73.0/24

##### 10个Service:

- front-envoy：Front Proxy,地址为172.31.73.10
- 3个后端服务，仅是用于提供测试用的上游服务器
  - service_blue
  - service_red
  - service_green

### 运行并测试

1.  启动服务

   ```
   docker-compose up
   ```
   
2. 文本日志

   先向Front-Envoy发起请求，以便生成访问日志；

   ```
   curl 172.31.73.10/service/colors
   Hello from App behind Envoy (service blue)! hostname: d2ef1dfa1056 resolved hostname: 172.31.73.3
   ```
   
   而后在docker-compose的控制台查看输出的访问日志，日志信息应该类似如下
   
   ```
   [2021-11-02T12:33:35.336Z] "GET /service/colors HTTP/1.1" 200 - 0 98 2 2 "-" "curl/7.68.0" "6426a435-5f7a-41df-b4f0-75028bf3937b" "172.31.73.10" "172.31.73.3:80" "172.31.73.1"
   ```
   
3. JSON日志

   停止docker-compose的服务后，修改日志配置，注释日志配置中的“text_format”配置行，并启用“json_format”配置行； 

   ```
             access_log:
             - name: envoy.access_loggers.file
               typed_config:
                 "@type": type.googleapis.com/envoy.extensions.access_loggers.file.v3.FileAccessLog 
                 path: "/dev/stdout"
                 log_format:
                   json_format: {"start": "[%START_TIME%] ", "method": "%REQ(:METHOD)%", "url": "%REQ(X-ENVOY-ORIGINAL-PATH?:PATH)%", "protocol": "%PROTOCOL%", "status": "%RESPONSE_CODE%", "respflags": "%RESPONSE_FLAGS%", "bytes-received": "%BYTES_RECEIVED%", "bytes-sent": "%BYTES_SENT%", "duration": "%DURATION%", "upstream-service-time": "%RESP(X-ENVOY-UPSTREAM-SERVICE-TIME)%", "x-forwarded-for": "%REQ(X-FORWARDED-FOR)%", "user-agent": "%REQ(USER-AGENT)%", "request-id": "%REQ(X-REQUEST-ID)%", "authority": "%REQ(:AUTHORITY)%", "upstream-host": "%UPSTREAM_HOST%", "remote-ip": "%DOWNSTREAM_REMOTE_ADDRESS_WITHOUT_PORT%"}
                   #text_format: "[%START_TIME%] \"%REQ(:METHOD)% %REQ(X-ENVOY-ORIGINAL-PATH?:PATH)% %PROTOCOL%\" %RESPONSE_CODE% %RESPONSE_FLAGS% %BYTES_RECEIVED% %BYTES_SENT% %DURATION% %RESP(X-ENVOY-UPSTREAM-SERVICE-TIME)% \"%REQ(X-FORWARDED-FOR)%\" \"%REQ(USER-AGENT)%\" \"%REQ(X-REQUEST-ID)%\" \"%REQ(:AUTHORITY)%\" \"%UPSTREAM_HOST%\" \"%DOWNSTREAM_REMOTE_ADDRESS_WITHOUT_PORT%\"\n"
   ```

   而后，启动服务

   ```
   docker-compose up
   ```

   接下来，向Front-Envoy发起请求，以便生成访问日志；

   ```
   curl 172.31.73.10/service/colors
   Hello from App behind Envoy (service blue)! hostname: d2ef1dfa1056 resolved hostname: 172.31.73.3
   ```

   最后在docker-compose的控制台查看输出的访问日志，日志信息应该类似如下

   ```
   {"protocol":"HTTP/1.1","url":"/service/colors","authority":"172.31.73.10","respflags":"-","remote-ip":"172.31.73.1","request-id":"92e42697-3c5e-496d-a128-2b244776ed04","method":"GET","x-forwarded-for":null,"status":200,"bytes-received":0,"upstream-service-time":"2","upstream-host":"172.31.73.2:80","start":"[2021-11-02T12:39:47.684Z] ","duration":2,"user-agent":"curl/7.68.0","bytes-sent":98}
   ```

4. 停止后清理

```
docker-compose down
```

## 版权声明

本文档版本归[马哥教育](www.magedu.com)所有，未经允许，不得随意转载和商用。
