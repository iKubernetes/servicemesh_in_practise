# HTTP Front Proxy demo

### 环境说明
三个Service:
- envoy：Front Proxy,地址由docker-compose动态分配
- webserver01：第一个后端服务,地址由docker-compose动态分配，且将webserver01解析到该地址
- webserver02：第二个后端服务,地址由docker-compose动态分配，且将webserver02解析到该地址

### 运行和测试
1. 创建
```
docker-compose up
```

2. 测试
```
front_proxy_ip=$(docker container inspect --format '{{ $network := index .NetworkSettings.Networks "cluster-static-dns-discovery_envoymesh" }}{{ $network.IPAddress}}' cluster-static-dns-discovery_envoy_1)
curl http://${front_proxy_ip}

可以通过admin interface了解集群的相关状态，尤其是获取的各endpoint的相关信息
curl http://${front_proxy_ip}/clusters
```

3. 停止后清理
```
docker-compose down
```

## 版权声明
本文档版本归[马哥教育](www.magedu.com)所有，未经允许，不得随意转载和商用。
