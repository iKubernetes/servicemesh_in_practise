# EDS Filesystem demo

### 环境说明
五个Service:
- envoy：Front Proxy,地址为172.31.11.2
- webserver01：第一个后端服务
- webserver01-sidecar：第一个后端服务的Sidecar Proxy,地址为172.31.11.11
- webserver02：第二个后端服务
- webserver02-sidecar：第二个后端服务的Sidecar Proxy,地址为172.31.11.12

### 运行和测试
1. 创建
```
docker-compose up
```

2. 测试
```
# 查看Cluster中的Endpoint信息 
curl 172.31.11.2:9901/clusters

# 接入front proxy envoy容器的交互式接口，修改eds.conf文件中的内容，将另一个endpoint添加进文件中；
docker exec -it eds-filesystem_envoy_1 /bin/sh
cd /etc/envoy/eds.conf.d/
cat eds.yaml.v2 > eds.yaml
# 运行下面的命令强制激活文件更改，以便基于inode监视的工作机制可被触发
mv eds.yaml temp && mv temp eds.yaml

# 再次查看Cluster中的Endpoint信息 
curl 172.31.11.2:9901/clusters
```

3. 停止后清理
```
docker-compose down
```

## 版权声明
本文档版本归[马哥教育](www.magedu.com)所有，未经允许，不得随意转载和商用。
