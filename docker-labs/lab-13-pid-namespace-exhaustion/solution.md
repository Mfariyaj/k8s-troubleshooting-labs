## Solution: PID Namespace Exhaustion

### Root Cause

Multiple issues lead to PID exhaustion:
1. **`pid: "host"`**: Containers share the host PID namespace — forked processes count against host PID limit
2. **No `pids_limit`**: Containers can fork unlimited processes
3. **No init process**: Bash as PID 1 doesn't reap zombie processes, causing permanent zombie accumulation
4. **Aggressive forking**: Workers spawn thousands of children without limits

### Step-by-Step Fix

1. Remove `pid: "host"` — use isolated PID namespaces
2. Add `pids_limit` to cap process count per container
3. Add `init: true` to use tini as PID 1 for zombie reaping

### Fixed docker-compose.yml

```yaml
version: '3.8'

services:
  worker-alpha:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: worker-alpha
    # Removed: pid: "host"
    pids_limit: 100
    init: true
    environment:
      - WORKER_ID=alpha
      - MAX_CHILDREN=50
    restart: unless-stopped

  worker-beta:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: worker-beta
    pids_limit: 100
    init: true
    environment:
      - WORKER_ID=beta
      - MAX_CHILDREN=50
    restart: unless-stopped

  worker-gamma:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: worker-gamma
    pids_limit: 100
    init: true
    environment:
      - WORKER_ID=gamma
      - MAX_CHILDREN=50
    restart: unless-stopped

  api-server:
    image: nginx:alpine
    container_name: api-server
    # Removed: pid: "host"
    pids_limit: 50
    ports:
      - "8080:80"
    depends_on:
      - worker-alpha
      - worker-beta
      - worker-gamma
    restart: unless-stopped
```

### Verification

```bash
docker compose down
docker compose up -d
# Check PID limits are enforced
docker inspect worker-alpha --format='{{.HostConfig.PidsLimit}}'
# Should show 100
# Check zombie count
docker exec worker-alpha ps aux | grep -c defunct
# Should be 0 (tini reaps zombies)
docker stats --no-stream
```
