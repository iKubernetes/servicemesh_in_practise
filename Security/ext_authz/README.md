# 外部JWT认证及OPA授权

本实验用于展示Envoy的ext_authz过滤器的功能，该过滤器会将传入的鉴权请求委托给外部的第三方服务。

### 环境说明

##### Envoy Mesh使用的网络: 172.31.97.0/24

##### 5个Service:

- front-envoy：Front Proxy,地址为172.31.97.10
- ext_authz-http-service：外部JWT认证服务，基于http协议
  - front-envoy使用配置文件“config/http-service.yaml”调用该服务
- ext_authz-grpc-service：外部JWT认证服务，基于grpc协议
  - front-envoy使用配置文件“config/grpc-service/v3.yaml”调用该服务
-  ext_authz-opa-service：外部OPA服务
  - front-envoy使用配置文件“config/opa-service/v3.yaml”调用该服务
  - opa-service自身鉴权策略的配置文件是“config/opa-service/policy.rego”
- upstream-service：上游服务

##### 用户账号

认证服务基于“auth/users.json”文件默认定义了三个用户及相关的认证Token，http和grpc认证服务都将加载该文件。

```
{
  "token1": "user1",
  "token2": "user2",
  "token3": "user3"
}
```

### 运行并测试

1. 启动服务

   提示：该实验中存在多个由FRONT_ENVOY_YAML环境变量控制的设置，它指向的是Envoy启动时使用的配置文件，其默认值定义在隐藏文件.env中，指向的是“config/http-service.yaml”。

   ```
   docker-compose up --build
   ```

2. 测试访问

   另外启动一个终端，运行如下命令，即可进行测试

   ```
   $ curl -v 172.31.97.10:8000/
   # 如下命令结果中的“403 Forbidden”表示，用户未能成功获取服务访问授权
   *   Trying 172.31.97.10:8000...
   * TCP_NODELAY set
   * Connected to 172.31.97.10 (172.31.97.10) port 8000 (#0)
   > GET / HTTP/1.1
   > Host: 172.31.97.10:8000
   > User-Agent: curl/7.68.0
   > Accept: */*
   > 
   * Mark bundle as not supporting multiuse
   < HTTP/1.1 403 Forbidden
   < date: Tue, 09 Nov 2021 12:19:25 GMT
   < x-envoy-upstream-service-time: 9
   < server: envoy
   < content-length: 0
   < 
   * Connection #0 to host 172.31.97.10 left intact
   ```

   但若以获得了授权的用户认证到front-envoy，即可请求到相应的服务，如下面的命令及结果所示。

   ```
   $ curl -v -H "Authorization: Bearer token1" 172.31.97.10:8000/
   # 如下结果可以看出，请求已然得到正常响应 
   *   Trying 172.31.97.10:8000...
   * TCP_NODELAY set
   * Connected to 172.31.97.10 (172.31.97.10) port 8000 (#0)
   > GET / HTTP/1.1
   > Host: 172.31.97.10:8000
   > User-Agent: curl/7.68.0
   > Accept: */*
   > Authorization: Bearer token1
   > 
   * Mark bundle as not supporting multiuse
   < HTTP/1.1 200 OK
   < content-type: text/html; charset=utf-8
   < content-length: 106
   < server: envoy
   < date: Tue, 09 Nov 2021 12:21:38 GMT
   < x-envoy-upstream-service-time: 3
   < 
   iKubernetes demoapp v1.0 !! ClientIP: 172.31.97.10, ServerName: upstream-demoapp, ServerIP: 172.31.97.11!
   * Connection #0 to host 172.31.97.10 left intact
   ```

   

3. 切换测试外部grpc鉴权服务

   关掉整个服务，而后设定FRONT_ENVOY_YAML环境变量的值指向“config/grpc-service/v3.yaml”，并再次启动服务。

   ```
   $ docker-compose down
   $ FRONT_ENVOY_YAML=config/grpc-service/v3.yaml docker-compose up --build
   ```

   此时，对front-envoy代理的服务发起请求的响应结果与前面http协议鉴权服务的结果相同。这里就不再列出过程。

4. 切换测试外部opa鉴权服务

   关掉整个服务，而后设定FRONT_ENVOY_YAML环境变量的值指向“config/opa-service/v3.yaml”，并再次启动服务。

   ```
   $ docker-compose down
   $ FRONT_ENVOY_YAML=config/opa-service/v3.yaml docker-compose up --build
   ```

   用到的策略如下

   ```
   package envoy.authz
     
   import input.attributes.request.http as http_request
   
   default allow = false
   
   response := {
     "allowed": true,
     "headers": {"x-current-user": "OPA"}
   }
   
   allow = response {
     http_request.method == "GET"
   }
   
   allow = response {
     http_request.method == "POST"
     glob.match("/livez", ["/"], http_request.path)
   }
   ```

   

5. 回到测试终端，再次进行测试

   首先，仍然以匿名用户发起GET请求进行测试。

   ```
   $ curl -v 172.31.97.10:8000/
   # 如下命令结果显示，匿名客户端的GET请求得到了正常响应，而没有被拒绝；OPA策略将GET视为安全请求；
   *   Trying 172.31.97.10:8000...
   * TCP_NODELAY set
   * Connected to 172.31.97.10 (172.31.97.10) port 8000 (#0)
   > GET / HTTP/1.1
   > Host: 172.31.97.10:8000
   > User-Agent: curl/7.68.0
   > Accept: */*
   > 
   * Mark bundle as not supporting multiuse
   < HTTP/1.1 200 OK
   < content-type: text/html; charset=utf-8
   < content-length: 106
   < server: envoy
   < date: Tue, 09 Nov 2021 12:49:23 GMT
   < x-envoy-upstream-service-time: 1
   < 
   iKubernetes demoapp v1.0 !! ClientIP: 172.31.97.10, ServerName: upstream-demoapp, ServerIP: 172.31.97.11!
   * Connection #0 to host 172.31.97.10 left intact
   ```

   docker-compose终端上的日志信息中可以看出，客户端请求的操作，经由OPA基于策略进行了鉴权操作。

   ```
   ……
   ext_authz-opa-service_1   |       "request": {
   ext_authz-opa-service_1   |         "http": {
   ext_authz-opa-service_1   |           "headers": {
   ext_authz-opa-service_1   |             ":authority": "172.31.97.10:8000",
   ext_authz-opa-service_1   |             ":method": "GET",
   ext_authz-opa-service_1   |             ":path": "/",
   ext_authz-opa-service_1   |             ":scheme": "http",
   ext_authz-opa-service_1   |             "accept": "*/*",
   ext_authz-opa-service_1   |             "user-agent": "curl/7.68.0",
   ext_authz-opa-service_1   |             "x-forwarded-proto": "http",
   ext_authz-opa-service_1   |             "x-request-id": "ed8556d8-597a-4641-a014-cc6cd0e65fd3"
   ext_authz-opa-service_1   |           },
   ext_authz-opa-service_1   |           "host": "172.31.97.10:8000",
   ext_authz-opa-service_1   |           "id": "4216350178583812918",
   ext_authz-opa-service_1   |           "method": "GET",
   ext_authz-opa-service_1   |           "path": "/",
   ext_authz-opa-service_1   |           "protocol": "HTTP/1.1",
   ext_authz-opa-service_1   |           "scheme": "http"
   ext_authz-opa-service_1   |         },
   ext_authz-opa-service_1   |         "time": "2021-11-09T12:49:23.850444Z"
   ……
   ext_authz-opa-service_1   |   "result": {
   ext_authz-opa-service_1   |     "allowed": true,
   ext_authz-opa-service_1   |     "headers": {
   ext_authz-opa-service_1   |       "x-current-user": "OPA"
   ext_authz-opa-service_1   |     }
   ext_authz-opa-service_1   |   },
   ……
   ```

   接下来，我们以匿名用户发起POST请求，以测试其访问。

   ```
   $ curl -v -XPOST 172.31.97.10:8000/service
   # 如下结果显示，用户请求被拒绝；这是因为OPA策略中，默认拒绝所有请求，而POST请求仅允许针对“/livez”
   *   Trying 172.31.97.10:8000...
   * TCP_NODELAY set
   * Connected to 172.31.97.10 (172.31.97.10) port 8000 (#0)
   > POST / HTTP/1.1
   > Host: 172.31.97.10:8000
   > User-Agent: curl/7.68.0
   > Accept: */*
   > 
   * Mark bundle as not supporting multiuse
   < HTTP/1.1 403 Forbidden
   < date: Tue, 09 Nov 2021 12:51:14 GMT
   < server: envoy
   < content-length: 0
   < 
   * Connection #0 to host 172.31.97.10 left intact
   ```

   日志中，OPA的相关信息也显示，该请求被拒绝。

   ```
   ……
   ext_authz-opa-service_1   |   "requested_by": "",
   ext_authz-opa-service_1   |   "result": false,
   ext_authz-opa-service_1   |   "time": "2021-11-09T12:51:14Z",
   ……
   ```

   但针对“/livez”的POST请求将允许正常进行

   ```
   curl -v -XPOST -d "livez=FAIL" http://172.31.97.10:8000/livez  
   # 下面的命令结果显示，请求成功返回。
   Note: Unnecessary use of -X or --request, POST is already inferred.
   *   Trying 172.31.97.10:8000...
   * TCP_NODELAY set
   * Connected to 172.31.97.10 (172.31.97.10) port 8000 (#0)
   > POST /livez HTTP/1.1
   > Host: 172.31.97.10:8000
   > User-Agent: curl/7.68.0
   > Accept: */*
   > Content-Length: 10
   > Content-Type: application/x-www-form-urlencoded
   > 
   * upload completely sent off: 10 out of 10 bytes
   * Mark bundle as not supporting multiuse
   < HTTP/1.1 200 OK
   < content-type: text/html; charset=utf-8
   < content-length: 0
   < server: envoy
   < date: Tue, 09 Nov 2021 12:53:54 GMT
   < x-envoy-upstream-service-time: 1
   < 
   * Connection #0 to host 172.31.97.10 left intact
   ```

   日志中，OPA的相关信息也显示，该请求被允许。

   ```
   ……
   ext_authz-opa-service_1   |       "request": {
   ext_authz-opa-service_1   |         "http": {
   ext_authz-opa-service_1   |           "headers": {
   ext_authz-opa-service_1   |             ":authority": "172.31.97.10:8000",
   ext_authz-opa-service_1   |             ":method": "POST",
   ext_authz-opa-service_1   |             ":path": "/livez",
   ext_authz-opa-service_1   |             ":scheme": "http",
   ext_authz-opa-service_1   |             "accept": "*/*",
   ext_authz-opa-service_1   |             "content-length": "10",
   ext_authz-opa-service_1   |             "content-type": "application/x-www-form-urlencoded",
   ext_authz-opa-service_1   |             "user-agent": "curl/7.68.0",
   ext_authz-opa-service_1   |             "x-forwarded-proto": "http",
   ext_authz-opa-service_1   |             "x-request-id": "632d5fef-aa3f-4289-90f8-a462b19a47e0"
   ext_authz-opa-service_1   |           },
   ext_authz-opa-service_1   |           "host": "172.31.97.10:8000",
   ext_authz-opa-service_1   |           "id": "3141243200074452271",
   ext_authz-opa-service_1   |           "method": "POST",
   ext_authz-opa-service_1   |           "path": "/livez",
   ext_authz-opa-service_1   |           "protocol": "HTTP/1.1",
   ext_authz-opa-service_1   |           "scheme": "http"
   ext_authz-opa-service_1   |         },
   ……
   ext_authz-opa-service_1   |   "result": {
   ext_authz-opa-service_1   |     "allowed": true,
   ext_authz-opa-service_1   |     "headers": {
   ext_authz-opa-service_1   |       "x-current-user": "OPA"
   ext_authz-opa-service_1   |     }
   ext_authz-opa-service_1   |   },
   ……
   ```

   

6. 停止后清理

```
docker-compose down
```

## 版权声明

本文档版本归[马哥教育](www.magedu.com)所有，未经允许，不得随意转载和商用。