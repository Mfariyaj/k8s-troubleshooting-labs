## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (builds and runs broken containers)
2. Check: `docker ps`, `docker logs <container>`
3. Test: Try `curl`, `docker exec`, check connectivity
4. Observe the failure and identify root cause
5. Fix the Dockerfile/docker-compose.yml and rebuild
6. Check `solution.md` if stuck

---

# Lab 04 - Volume Mount Permission Denied

## Difficulty: ⭐⭐

## Scenario
A Python application writes log files and uploaded data to a volume-mounted directory. The Dockerfile correctly uses a non-root user for security, but when the container starts, it crashes because it can't write to the mounted volume.

## What You'll See
When you run `./deploy.sh`, the container starts but immediately logs:

```
app_1  | Starting application...
app_1  | Writing to /app/data/output.log
app_1  | Traceback (most recent call last):
app_1  |   File "/app/main.py", line 15, in <module>
app_1  |     f = open('/app/data/output.log', 'w')
app_1  | PermissionError: [Errno 13] Permission denied: '/app/data/output.log'
```

## Hints
1. What user is the container running as?
2. Who owns the mounted volume directory?
3. What are the permissions on the mount point inside the container?
4. How can you ensure the non-root user has write access?

## Troubleshooting Commands
```bash
# Check what user the container runs as
docker compose exec app id
docker compose exec app whoami

# Check volume mount permissions
docker compose exec app ls -la /app/
docker compose exec app ls -la /app/data/

# Check who owns the data directory
docker run --rm -v lab04_app-data:/data alpine ls -la /data

# Check Dockerfile USER directive
cat Dockerfile
```

## Resolution
The Dockerfile switches to a non-root user (`appuser` with UID 1001), but the volume is created and owned by root (UID 0). The container user can't write to it.

**Fix options:**
1. Add `RUN mkdir -p /app/data && chown -R appuser:appuser /app/data` BEFORE the USER directive
2. Use an init script that fixes permissions before dropping privileges
3. Ensure the volume has correct ownership at creation time
