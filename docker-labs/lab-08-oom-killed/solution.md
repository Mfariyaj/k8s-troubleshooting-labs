## Solution: OOM Killed

### Root Cause

The JVM is configured with `-Xmx512m -Xms256m` (requesting 512MB max heap), but the container memory limit is only 256MB. The JVM heap exceeds the cgroup memory limit, causing the kernel OOM killer to terminate the process (exit code 137).

### Step-by-Step Fix

1. Set JVM heap (`-Xmx`) to ~75% of container memory limit
2. For a 256MB container, use `-Xmx192m` max
3. Keep `-Xms` low to avoid immediate allocation pressure

### Fixed Dockerfile

```dockerfile
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

COPY App.java ./

RUN apk add --no-cache openjdk17 && \
    javac App.java && \
    apk del openjdk17

# Fixed: Heap fits within 256MB container limit
ENTRYPOINT ["java", "-Xmx192m", "-Xms64m", "App"]
```

### docker-compose.yml (unchanged)

```yaml
version: "3.8"

services:
  app:
    build: .
    container_name: lab08-java
    ports:
      - "8080:8080"
    deploy:
      resources:
        limits:
          memory: 256m
    mem_limit: 256m
    memswap_limit: 256m
```

### Verification

```bash
docker compose down
docker compose build --no-cache
docker compose up -d
sleep 5
docker ps --filter name=lab08-java
# Should be "Up", not "Exited (137)"
docker inspect lab08-java --format='{{.State.OOMKilled}}'
# Should be "false"
docker stats lab08-java --no-stream
docker compose down
```
