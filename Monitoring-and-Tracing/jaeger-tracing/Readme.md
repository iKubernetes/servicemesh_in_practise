## Micro services tracing with envoy service mesh and zipkin.
### Setup
![setup](./envoy_tracing.png)

### Run  
1. `docker-compose build`    
2. `docker-compose up`  
3. Hit `localhost:8080` to generate some traffic between the services
4. Visit `localhost:16686` for Jaeger
