# HTTP Route Simple Match Demo

### 环境说明
##### 八个Service:

- envoy：Front Proxy,地址为172.31.50.10
- 7个后端服务
  - light_blue和dark_blue：对应于Envoy中的blue集群
  - light_red和dark_red：对应于Envoy中的red集群
  - light_green和dark_green：对应Envoy中的green集群
  - gray：对应于Envoy中的gray集群

##### 使用的路由配置

```
            virtual_hosts:
            - name: vh_001
              domains: ["ilinux.io", "*.ilinux.io", "ilinux.*"]
              routes:
              - match:
                  path: "/service/blue"
                route:
                  cluster: blue
              - match:
                  safe_regex: 
                    google_re2: {}
                    regex: "^/service/.*blue$"
                redirect:
                  path_redirect: "/service/blue"
              - match:
                  prefix: "/service/yellow"
                direct_response:
                  status: 200
                  body:
                    inline_string: "This page will be provided soon later.\n"
              - match:
                  prefix: "/"
                route:
                  cluster: red
            - name: vh_002
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: gray
```

### 运行和测试
1. 创建并运行容器
```
docker-compose up
```

2. 测试domain的匹配机制

   ```
   # 首先访问无法匹配到vh_001的域名
   curl -H "Host: www.magedu.com" http://172.31.50.10/service/a
   
   <body bgcolor="gray"><span style="color:white;font-size:4em;">
   Hello from gray (hostname: 91a424fbb509 resolvedhostname:172.31.50.5)
   </span></body>
   
   # 接着访问可以匹配vh_001的域名
   curl -H "Host: www.ilinux.io" http://172.31.50.10/service/a
   
   <body bgcolor="light_red"><span style="color:white;font-size:4em;">
   Hello from light_red (hostname: 4b6793c1f445 resolvedhostname:172.31.50.7)
   </span></body>
   ```
3. 测试路由匹配机制

   ```
   # 首先访问“/service/blue”
   curl -H "Host: www.ilinux.io" http://172.31.50.10/service/blue
   <body bgcolor="dark_blue"><span style="color:white;font-size:4em;">
   Hello from dark_blue (hostname: 96edc379cac7 resolvedhostname:172.31.50.8)
   </span></body>
   
   # 接着访问“/service/dark_blue”
   curl -I -H "Host: www.ilinux.io" http://172.31.50.10/service/dark_blue
   HTTP/1.1 301 Moved Permanently
   location: http://www.ilinux.io/service/blue
   date: Fri, 29 Oct 2021 03:02:59 GMT
   server: envoy
   transfer-encoding: chunked
   
   # 然后访问“/serevice/yellow”
   curl -H "Host: www.ilinux.io" http://172.31.50.10/service/yellow
   This page will be provided soon later.
   ```

4. 停止后清理

```
docker-compose down
```

## 版权声明
本文档版本归[马哥教育](www.magedu.com)所有，未经允许，不得随意转载和商用。
