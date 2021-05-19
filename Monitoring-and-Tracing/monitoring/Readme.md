## Micro services monitoring with envoy service mesh, prometheus & grafana  
### Setup
![setup](https://raw.githubusercontent.com/dnivra26/envoy_monitoring/master/envoy_monitoring.png)

### Run  
1. `docker-compose build`    
2. `docker-compose up`  
3. Hit `localhost:8080` to generate some traffic between the services
4. Visit `localhost:9090` for prometheus
5. Visit `localhost:3000` for grafana dashboard

### Output
![output](https://raw.githubusercontent.com/dnivra26/envoy_monitoring/master/grafana.png)