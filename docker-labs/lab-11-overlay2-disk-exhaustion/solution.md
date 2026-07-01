## Solution: Overlay2 Disk Exhaustion

### Root Cause

Multiple issues cause disk exhaustion:
1. **No log rotation**: `json-file` driver with no size limits — logs grow unbounded
2. **DEBUG/TRACE logging**: Excessive verbosity fills disk rapidly
3. **Orphaned volumes**: Named volumes accumulate and are never cleaned
4. **No daemon-level log limits**: `daemon.json` lacks `log-opts`

### Step-by-Step Fix

1. Add log rotation to `daemon.json`
2. Add per-service logging in docker-compose
3. Prune unused resources

### Fixed daemon.json

```json
{
  "storage-driver": "overlay2",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "data-root": "/var/lib/docker",
  "debug": false,
  "experimental": false
}
```

### Fixed docker-compose.yml (key sections)

```yaml
services:
  payment-service:
    build: .
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    environment:
      - LOG_LEVEL=INFO
      - ENABLE_REQUEST_LOGGING=true
      - ENABLE_RESPONSE_BODY_LOGGING=false

  audit-logger:
    build: .
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    environment:
      - LOG_LEVEL=INFO
      - AUDIT_RETENTION_DAYS=30
```

### Immediate Cleanup Commands

```bash
docker compose down
docker system prune -af
docker volume prune -f
docker system df
sudo cp daemon.json /etc/docker/daemon.json
sudo systemctl restart docker
```

### Verification

```bash
docker compose up -d
sleep 60
docker inspect --format='{{.LogPath}}' payment-service | xargs ls -lh
docker system df
df -h /var/lib/docker
```
