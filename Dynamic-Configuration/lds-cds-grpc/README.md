# EDS Filesystem demo

### 环境说明
六个Service:
- envoy：Front Proxy,地址为172.31.15.2
- webserver01：第一个后端服务
- webserver01-sidecar：第一个后端服务的Sidecar Proxy,地址为172.31.15.11
- webserver02：第二个后端服务
- webserver02-sidecar：第二个后端服务的Sidecar Proxy,地址为172.31.15.12
- xdsserver: xDS management server，地址为172.31.15.5

### 运行和测试
1. 创建
```
docker-compose up
```

2. 测试
```
# 查看Cluster及Endpoints信息；
curl 172.31.15.2:9901/clusters
或者查看动态Clusters的相关信息
curl -s 172.31.15.2:9901/config_dump | jq '.configs[1].dynamic_active_clusters'

# 查看Listener列表；
curl 172.31.15.2:9901/listeners
或者查看动态的Listener信息
curl -s 172.31.15.2:9901/config_dump?resource=dynamic_listeners | jq '.configs[0].active_state.listener.address'

# 接入xdsserver容器的交互式接口，修改config.yaml文件中的内容，将另一个endpoint添加进文件中，或进行其它修改；
docker-compose exec xdsserver /bin/sh
cd /etc/envoy-xds-server/config
cat config.yaml-v2 > config.yaml

提示：以上修改操作也可以直接在宿主机上的存储卷目录中进行。

# 再次查看Cluster中的Endpoint信息 
curl 172.31.15.2:9901/clusters
```

3. 停止后清理
```
docker-compose down
```

## 版权声明
本文档版本归[马哥教育](www.magedu.com)所有，未经允许，不得随意转载和商用。
