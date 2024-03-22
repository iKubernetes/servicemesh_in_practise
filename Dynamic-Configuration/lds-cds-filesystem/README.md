# EDS Filesystem demo

### 环境说明
五个Service:
- envoy：Front Proxy,地址为172.31.12.2
- webserver01：第一个后端服务
- webserver01-sidecar：第一个后端服务的Sidecar Proxy,地址为172.31.12.11
- webserver02：第二个后端服务
- webserver02-sidecar：第二个后端服务的Sidecar Proxy,地址为172.31.12.12

### 运行和测试
1. 创建
```
docker-compose up
```

2. 测试
```
# 查看Cluster的信息 
curl 172.31.12.2:9901/clusters

# 查看Listener的信息 
curl 172.31.12.2:9901/listeners

# 接入front proxy envoy容器的交互式接口
docker exec -it eds-filesystem_envoy_1 /bin/sh
cd /etc/envoy/conf.d/
# 修改lds.yaml或cds.yaml的内容满足需要后，
# 运行类似下面的命令强制激活文件更改，以便基于inode监视的工作机制可被触发
mv lds.yaml temp && mv temp lds.yaml

# 再次验证相关的配置信息
curl 172.31.12.2:9901/clusters
```

3. 停止后清理
```
docker-compose down
```

## 版权声明
本文档版本归[马哥教育](www.magedu.com)所有，未经允许，不得随意转载和商用。
