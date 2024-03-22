# HTTP Front Proxy and Admin Interface demo

### 环境说明
三个Service:
- envoy：Front Proxy,地址为172.31.5.2
- webserver01：第一个后端服务,地址为172.31.5.11
- webserver02：第二个后端服务,地址为172.31.5.12

### 运行和测试
1. 创建
```
docker-compose up
```

2. 测试，于宿主机上运行如下命令
```
# 获取帮助信息
curl 172.31.5.2:9901/help

# 查看完成的配置信息
curl 172.31.5.2:9901/config_dump

# 列出各Listener
curl 172.31.5.2:9901/listeners
```

3. 停止后清理
```
docker-compose down
```

## 版权声明
本文档版本归[马哥教育](www.magedu.com)所有，未经允许，不得随意转载和商用。
