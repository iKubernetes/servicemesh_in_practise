# TLS Front Proxy demo

### 环境说明
五个Service:
- envoy：Front Proxy,地址为172.31.8.2，监听于8443端口
- webserver01：第一个后端服务
- webserver01-sidecar：第一个后端服务的Sidecar Proxy,地址为172.31.8.11，监听于443端口
- webserver02：第二个后端服务
- webserver02-sidecar：第二个后端服务的Sidecar Proxy,地址为172.31.8.12, 监听于443端口

### 运行和测试
1. 创建
```
docker-compose up
```

2. 测试
```
# https请求测试
curl -k -v https://172.31.8.2:8443/

下面的命令输出示例，是因为我们在curl命令使用了-v选项所获取到的详细交互过程。

*   Trying 172.31.8.2:8443...
* TCP_NODELAY set
* Connected to 172.31.8.2 (172.31.8.2) port 8443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* successfully set certificate verify locations:
*   CAfile: /etc/ssl/certs/ca-certificates.crt
  CApath: /etc/ssl/certs
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
* TLSv1.3 (IN), TLS handshake, Server hello (2):
* TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
* TLSv1.3 (IN), TLS handshake, Certificate (11):
* TLSv1.3 (IN), TLS handshake, CERT verify (15):
* TLSv1.3 (IN), TLS handshake, Finished (20):
* TLSv1.3 (OUT), TLS change cipher, Change cipher spec (1):
* TLSv1.3 (OUT), TLS handshake, Finished (20):
* SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384
* ALPN, server did not agree to a protocol
* Server certificate:
*  subject: CN=www.magedu.com
*  start date: May 19 03:56:18 2021 GMT
*  expire date: May 17 03:56:18 2031 GMT
*  issuer: CN=www.magedu.com
*  SSL certificate verify result: self signed certificate (18), continuing anyway.
> GET / HTTP/1.1
> Host: 172.31.8.2:8443
> User-Agent: curl/7.68.0
> Accept: */*
> 
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* old SSL session ID is stale, removing
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< content-type: text/html; charset=utf-8
< content-length: 97
< server: envoy
< date: Fri, 22 Jul 2022 09:56:49 GMT
< x-envoy-upstream-service-time: 4
< 
iKubernetes demoapp v1.0 !! ClientIP: 127.0.0.1, ServerName: webserver02, ServerIP: 172.31.8.12!
* Connection #0 to host 172.31.8.2 left intact

# 请求访问admin interface
curl http://172.31.8.2:9901/
```

3. 停止后清理
```
docker-compose down
```

## 版权声明
本文档版本归[马哥教育](www.magedu.com)所有，未经允许，不得随意转载和商用。
