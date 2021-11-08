## Running the Example



docker-compose up --build



./1-start-spire-agents.sh

./2-create-registration-entries.sh







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

