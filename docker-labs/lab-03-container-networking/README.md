# Lab 03 - Container Networking

## Difficulty: ⭐⭐

## Scenario
A microservices application has 4 services: frontend, backend, database (PostgreSQL), and cache (Redis). Despite all containers running, the services cannot communicate with each other. The frontend can't reach the backend, and the backend can't connect to the database or Redis.

## What You'll See
When you run `./deploy.sh`, containers start but logs show:

```
backend_1   | Error: getaddrinfo ENOTFOUND database
backend_1   | Error: connect ECONNREFUSED 127.0.0.1:6379
frontend_1  | Error: connect ECONNREFUSED backend:3000
```

## Hints
1. Are all services on the same Docker network?
2. Check the service names used in connection strings vs actual service names in docker-compose
3. Look at the port mappings - is the backend exposing the right port?
4. Docker DNS resolves by service name - are the names correct?

## Troubleshooting Commands
```bash
# See all running containers
docker compose ps

# Check networks
docker network ls
docker network inspect lab03_frontend-net
docker network inspect lab03_backend-net

# Check container connectivity
docker compose exec frontend ping backend
docker compose exec backend ping db

# Check logs
docker compose logs backend
docker compose logs frontend

# Inspect a service's network settings
docker inspect lab03-backend-1 | jq '.[0].NetworkSettings.Networks'
```

## Resolution
Three bugs:
1. **Wrong networks**: frontend and backend are on separate networks (`frontend-net` and `backend-net`) - they need a shared network
2. **Wrong service names**: Backend connects to `database` but the service is named `db`; connects to `cache` but service is named `redis`
3. **Wrong ports**: Backend listens on port 3000 but frontend connects to port 8080
