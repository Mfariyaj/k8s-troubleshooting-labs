## Solution: Container Runtime Shim

### Root Cause

The `containerd-shim-runc-v2` process (runtime shim) gets OOM-killed alongside containers:
1. **Memory limit too tight**: Container allocates more than its 128M limit, triggering OOM
2. **Shim caught in OOM cascade**: Kernel kills shim process when container's cgroup hits limit
3. **No OOM score protection**: Shim has default OOM score, making it vulnerable
4. **No healthcheck**: Docker can't detect when container becomes unresponsive after shim death

### Step-by-Step Fix

1. Increase memory limits to accommodate actual usage
2. Protect the shim process OOM score
3. Add healthchecks to detect unresponsive containers
4. Configure containerd to restart shims

### Fixed docker-compose.yml

```yaml
version: '3.8'

services:
  memory-hog:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: memory-hog
    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M
    # Prevent OOM from cascading to shim
    oom_score_adj: 1000
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 10s
      timeout: 5s
      retries: 3
    restart: unless-stopped
    environment:
      - ALLOC_MB=200
      - ALLOC_PATTERN=gradual

  worker-a:
    build: .
    container_name: worker-a
    deploy:
      resources:
        limits:
          memory: 256M
    oom_score_adj: 500
    healthcheck:
      test: ["CMD-SHELL", "pgrep -f stress-test || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 3
    environment:
      - ALLOC_MB=100
      - ALLOC_PATTERN=burst
    restart: unless-stopped

  worker-b:
    build: .
    container_name: worker-b
    deploy:
      resources:
        limits:
          memory: 256M
    oom_score_adj: 500
    healthcheck:
      test: ["CMD-SHELL", "pgrep -f stress-test || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 3
    environment:
      - ALLOC_MB=150
      - ALLOC_PATTERN=random
    restart: unless-stopped

  monitor:
    image: docker:24-cli
    container_name: monitor
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: |
      sh -c "while true; do
        echo '[MONITOR] Checking worker health...'
        timeout 5 docker exec worker-a echo 'alive' || echo '[MONITOR] worker-a: UNRESPONSIVE'
        timeout 5 docker exec worker-b echo 'alive' || echo '[MONITOR] worker-b: UNRESPONSIVE'
        sleep 10
      done"
    depends_on:
      - worker-a
      - worker-b
    restart: unless-stopped
```

### Protect Shim OOM Score (host-level)

```bash
# Find shim PIDs and lower their OOM score
for pid in $(pgrep containerd-shim); do
  echo -999 > /proc/$pid/oom_score_adj
done

# Configure containerd to set shim OOM score
# In /etc/containerd/config.toml:
# [plugins."io.containerd.runtime.v2.task"]
#   oom_score = -999
sudo systemctl restart containerd
```

### Verification

```bash
docker compose down
docker compose up -d
sleep 30
docker compose ps
# All should be "Up (healthy)"
docker stats --no-stream
docker inspect memory-hog --format='{{.State.OOMKilled}}'
```
