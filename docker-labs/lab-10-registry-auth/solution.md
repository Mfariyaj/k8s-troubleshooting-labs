## Solution: Registry Authentication

### Root Cause

The docker-compose.yml references images from a private registry (`registry.internal.company.io`) that requires authentication:
1. **No docker login** performed — credentials are missing or expired
2. **Non-existent tag** — `scheduler-service:v3.0.0-beta` doesn't exist
3. **Registry inaccessible** — no network connectivity to internal registry

### Step-by-Step Fix

1. Log in to the private registry with valid credentials
2. Fix the scheduler image tag to one that exists
3. For local dev, use a local registry or build images locally

### Fix with Local Registry

```bash
# Start a local registry
docker run -d -p 5000:5000 --name registry registry:2

# Build and push images
docker build -t localhost:5000/myteam/api-service:v2.1.0 .
docker push localhost:5000/myteam/api-service:v2.1.0
docker build -t localhost:5000/myteam/worker-service:v2.1.0 .
docker push localhost:5000/myteam/worker-service:v2.1.0
docker build -t localhost:5000/myteam/scheduler-service:v2.1.0 .
docker push localhost:5000/myteam/scheduler-service:v2.1.0
```

### Fixed docker-compose.yml

```yaml
version: "3.8"

services:
  api:
    image: localhost:5000/myteam/api-service:v2.1.0
    ports:
      - "8080:8080"
    environment:
      - DB_HOST=postgres
      - REDIS_HOST=redis
    depends_on:
      - postgres
      - redis

  worker:
    image: localhost:5000/myteam/worker-service:v2.1.0
    environment:
      - QUEUE_URL=redis://redis:6379
      - DB_HOST=postgres
    depends_on:
      - redis
      - postgres

  scheduler:
    image: localhost:5000/myteam/scheduler-service:v2.1.0
    environment:
      - SCHEDULE_INTERVAL=60
      - API_URL=http://api:8080
    depends_on:
      - api

  postgres:
    image: postgres:15-alpine
    environment:
      - POSTGRES_USER=appuser
      - POSTGRES_PASSWORD=secret
      - POSTGRES_DB=myapp

  redis:
    image: redis:7-alpine
```

### Verification

```bash
docker login registry.internal.company.io -u <user> -p <pass>
docker compose pull
docker compose up -d
docker compose ps
```
