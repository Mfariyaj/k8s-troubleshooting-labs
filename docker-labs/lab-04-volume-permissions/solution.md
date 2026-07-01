## Solution: Volume Permissions

### Root Cause

The Dockerfile creates a non-root user (`appuser`, UID 1001) and switches to it with `USER appuser`. However, the volume mounted at `/app/data` is owned by root (UID 0). When the app tries to write to `/app/data/`, it gets "Permission denied" because `appuser` has no write access.

### Step-by-Step Fix

1. Create the `/app/data` directory in the Dockerfile
2. Set ownership to `appuser` before switching users

### Fixed Dockerfile

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py ./

# Create non-root user
RUN useradd -m -u 1001 appuser

# Create data directory and set ownership BEFORE switching user
RUN mkdir -p /app/data && chown -R appuser:appuser /app/data

USER appuser

CMD ["python", "main.py"]
```

### Verification

```bash
docker compose down -v
docker compose build --no-cache
docker compose up -d
docker compose logs app
# Should see successful writes, no "Permission denied"
docker exec $(docker compose ps -q app) ls -la /app/data
docker exec $(docker compose ps -q app) id
```
