## Running the Example

### Step 1: Install Docker

Ensure that you have recent versions of `docker` and `docker-compose` installed.

### Step 2: Generate Certificates

```bash
$ ./gencerts.sh
```
enter hostname and certificate extensions
- envoy_server_cert for server,
- envoy_client_cert for client, 
- and spire_agent for spire agent.

### Step 3: Start containers

```bash
$ docker-compose up --build -d
$ docker-compose ps
```
