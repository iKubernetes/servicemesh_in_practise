## Running the Example

### 环境说明

网络地址：172.31.95.0/24

各服务简介：

- front-envoy：前端入口代理服务
- 3个常规服务：red、green和blue
- 要使用基于spire和spiffe的sds的服务有两个
  - 1个service-gray
  - 1个service-purple

### 运行

```
docker-compose up --build
```

而后，另外打开一个终端，运行如下脚本，启动spire-agent

```
./1-start-spire-agents.sh
```

再运行如下脚本，将front-envoy、service-gray和service-purple注册到spire-server

```
./2-create-registration-entries.sh
```

### 测试

访问/service/gray，会被代理至service-gray服务，front-envoy与service-gray以tls方式通信

访问/service/purple，会被代理至serivce-purple服务，front-envoy与service-purple以mTLS方式通信

访问/service/colors，会被调度为red、blue和green服务

## 重新生成证书

运行脚本，并依次键入如下字符串

- front-envoy envoy_server_cert
- front-envoy spire_agent
- service-gray spire_agent
- service-purple spire_agent



为各组件复制必要的证书文件

```
# 为Spire Server提供各agent所信任的CA的证书
$ cp certs/CA/ca.crt spire-server/conf/

# 为front-envoy、service-gray和service-purple提供由其信任的CA签署的agent证书
$ cp certs/front-envoy/agent.key certs/front-envoy/agent.crt front-envoy/
$ cp certs/service-gray/agent.key certs/service-gray/agent.crt service-gray/
$ cp certs/service-purple/agent.key certs/service-purple/agent.crt service-purple/
```

