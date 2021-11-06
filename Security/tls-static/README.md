# 静态配置的Envoy TLS

### 环境说明

##### Envoy Mesh使用的网络: 172.31.90.0/24

##### 6个Service:

- front-envoy：Front Proxy,地址为172.31.90.10
- 3个http后端服务，仅是用于提供测试用的上游服务器，可统一由myservice名称解析到；front-envoy会通过http（会自动跳转至https）和https侦听器接收对这些服务的访问请求，并将其转为http请求后转至后端服务上； （https-http）
  - service-blue
  - service-red
  - service-green
- 2个https目的后端服务
  - service-gray：同时提供http和https侦听器，front-envoy在其cluster配置中，会向该服务发起https请求，并会验证其数字证书；（http-https, https-https）
  - service-purple：同时提供http和https侦听器，通过http接收的请求会自动重定向至https，并且https侦听器强制要求验证客户端证书；front-envoy在其cluster配置中，会向该服务发起https请求，向其提供自身的客户端证书后，并会验证其数字证书；

### 预备操作

#### 生成测试使用的数字证书

脚本gencerts.sh运行时，需指定证书的Subject名称（也将做为证书和私钥等文件存放的目录的目录名），以及OpenSSL配置文件中定义的证书扩展类型，这里支持使用两种类型：

- envoy_server_cert：为Envoy创建服务器证书，用于同下游客户端建立TLS连接，证书和私钥文件默认名称分别为server.crt和server.key；
- envoy_client_cert：为Envoy创建客户端证书，用于同上游服务端建立TLS连接，证书和私钥文件默认名称分别为client.crt和client.key；

本示例中需要用到的证书和私钥：

- front-envoy：server.crt/server.key，client.crt/client.key
- service-gray：server.crt/server.key
- service-purple：server.crt/server.key

脚本使用示例：

```
./gencerts.sh   
Generating RSA private key, 4096 bit long modulus (2 primes)
.............................++++
.............++++
e is 65537 (0x010001)
Certificate Name and Certificate Extenstions(envoy_server_cert/envoy_client_cert): front-envoy envoy_server_cert
# 上面的键入的证书主体名称为front-envoy，而选择的扩展类型为envoy_server_cert
Generating RSA private key, 2048 bit long modulus (2 primes)
.................................................................+++++
...............................................................................+++++
e is 65537 (0x010001)
Generating certs/front-envoy/server.csr
Generating certs/front-envoy/server.crt
Using configuration from openssl.conf
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 4096 (0x1000)
        Validity
            Not Before: Nov  6 08:34:05 2021 GMT
            Not After : Nov  4 08:34:05 2031 GMT
        Subject:
            commonName                = front-envoy
        X509v3 extensions:
        ……
    ……
# 可在出现命令提示符时，分别为front-envoy、service-gray和service-purple创建所需的证书和私钥；
```

**注意**：各目录中的key文件，可以需要做权限调整，以便envoy用户（UID:100, GID:101）能够读取并加载。

### 运行并测试

1.  启动服务

   ```
   docker-compose up
   ```
   
2. 查看证书和监听的https套接字

   首先查看front-envoy启动的Listener

   ```
   curl 172.31.90.10:9901/listeners
   # 下面的命令结果显示出，front-envoy上同时监听有http和https相关的套接字
   listener_http::0.0.0.0:80
   listener_https::0.0.0.0:443
   ```

   而后查看front-envoy加载的证书

   ```
    curl 172.31.90.10:9901/certs
    #下面的结果显示出，front-envoy已然加载了相关的数字证书
   {
    "certificates": [
     {
      "ca_cert": [
       {
        "path": "/etc/envoy/ca/ca.crt",
        "serial_number": "778e3555311639c123fc6e55bf91d956dbb95999",
        "subject_alt_names": [],
        "days_until_expiration": "3649",
        "valid_from": "2021-11-06T08:33:54Z",
        "expiration_time": "2031-11-04T08:33:54Z"
       }
      ],
      "cert_chain": []
     },
     ……
     }
    ]
   }
   ```

   同样的测试方法，也可用于service-gray和service-purple之上。

3. 测试访问服务

   直接向front-envoy发起的http请求，将会被自动跳转至https服务上。

   ```
   curl -I 172.31.90.10/
   # 命令结果显示了自动跳转的结果
   HTTP/1.1 301 Moved Permanently
   location: https://172.31.90.10:443/
   date: Sat, 06 Nov 2021 10:29:37 GMT
   server: envoy
   transfer-encoding: chunked
   ```

   https侦听器监听的443端口也能够正常接收客户端访问，这里可以直接使用openssl s_client命令进行测试。

   ```
   openssl s_client -connect 172.31.90.10:443
   # 如下命令结果显示，tls传话已然能正常建立，但curl命令无法任何服务端证书的CA，除非我们给命令指定相应
   # 的私有CA的证书，以便于验证服务端证书
   CONNECTED(00000003)
   Can't use SSL_get_servername
   depth=0 CN = front-envoy
   verify error:num=20:unable to get local issuer certificate
   verify return:1
   depth=0 CN = front-envoy
   verify error:num=21:unable to verify the first certificate
   verify return:1
   ---
   Certificate chain
    0 s:CN = front-envoy
      i:CN = envoy-ca
   ---
   Server certificate
   -----BEGIN CERTIFICATE-----
   MIIEkDCCAnigAwIBAgICEAAwDQYJKoZIhvcNAQELBQAwEzERMA8GA1UEAwwIZW52
   ……
   -----END CERTIFICATE-----
   subject=CN = front-envoy
   
   issuer=CN = envoy-ca
   
   ---
   No client certificate CA names sent
   Peer signing digest: SHA256
   Peer signature type: RSA-PSS
   Server Temp Key: X25519, 253 bits
   ---
   SSL handshake has read 1662 bytes and written 363 bytes
   Verification error: unable to verify the first certificate
   ---
   New, TLSv1.3, Cipher is TLS_AES_256_GCM_SHA384
   Server public key is 2048 bit
   Secure Renegotiation IS NOT supported
   Compression: NONE
   Expansion: NONE
   No ALPN negotiated
   Early data was not sent
   Verify return code: 21 (unable to verify the first certificate)
   ---
   ```

   于是，我们可在curl命令上为其提供私有CA证书文件，或者使用“-k”选项忽略提示的风险，从而访问https服务。

   ```
   # 先向gray服务发起访问请求进行测试
   curl -k https://172.31.90.10/service/gray  
   Hello from App behind Envoy (service gray)! hostname: 9b1cc51c4223 resolved hostname: 172.31.90.15
   
   # 还可以请求purple服务
   curl -k https://172.31.90.10/service/purple
   Hello from App behind Envoy (service purple)! hostname: 1420024e116c resolved hostname: 172.31.90.16
   ```

   从front-envoy的日志信息中可以看出，它向上游的gray或者purple发起请求时，使用的都是https连接。

   ```
   # 如下日志信息显示，front-envoy向172.31.90.15（service-gray）的443端口发起了访问请求；
   front-envoy_1  | [2021-11-06T10:47:57.445Z] "GET /service/gray HTTP/1.1" 200 - 0 99 7 7 "-" "curl/7.68.0" "66c148c1-105f-421b-8893-df05b79bab57" "172.31.90.10" "172.31.90.15:443"
   
   # 如下日志信息显示，front-envoy向172.31.90.16（service-purple）的443端口发起了访问请求；
   front-envoy_1  | [2021-11-06T10:47:45.733Z] "GET /service/purple HTTP/1.1" 200 - 0 101 7 6 "-" "curl/7.68.0" "aa4b044e-edcd-4826-84d4-c4d40a674beb" "172.31.90.10" "172.31.90.16:443"
   ```

4. 停止后清理

```
docker-compose down
```

## 版权声明

本文档版本归[马哥教育](www.magedu.com)所有，未经允许，不得随意转载和商用。