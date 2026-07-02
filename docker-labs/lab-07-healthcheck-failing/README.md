## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (builds and runs broken containers)
2. Check: `docker ps`, `docker logs <container>`
3. Test: Try `curl`, `docker exec`, check connectivity
4. Observe the failure and identify root cause
5. Fix the Dockerfile/docker-compose.yml and rebuild
6. Check `solution.md` if stuck

---

# Lab 07 - Healthcheck Always Unhealthy

## Difficulty: ⭐⭐⭐

## Scenario
A Node.js API container has a HEALTHCHECK configured, but Docker always reports the container as "unhealthy" despite the application responding correctly to requests when tested manually.

## What You'll See
When you run `./deploy.sh`:

```
$ docker ps
CONTAINER ID  IMAGE       STATUS                     PORTS
abc123        lab07-app   Up 30s (health: starting)  0.0.0.0:3000->3000/tcp

# After 30 seconds:
CONTAINER ID  IMAGE       STATUS                      PORTS
abc123        lab07-app   Up 60s (unhealthy)          0.0.0.0:3000->3000/tcp
```

But manual testing works:
```
$ curl http://localhost:3000/health
{"status":"healthy","uptime":45}

$ curl http://localhost:3000/
{"message":"API is working!"}
```

## Hints
1. What tool does the HEALTHCHECK use? Is that tool installed in the image?
2. What port does the HEALTHCHECK curl? What port does the app listen on?
3. What path does the HEALTHCHECK hit? Does that path exist?
4. Check all three: tool availability, port, and path

## Troubleshooting Commands
```bash
# Check container health status
docker inspect --format='{{.State.Health.Status}}' lab07-app-container

# See healthcheck results
docker inspect --format='{{json .State.Health}}' lab07-app-container | jq

# Check what the healthcheck command is
docker inspect --format='{{json .Config.Healthcheck}}' lab07-app-container | jq

# Try running the healthcheck manually inside the container
docker exec lab07-app-container curl -f http://localhost:8080/healthz

# Check if curl exists in the container
docker exec lab07-app-container which curl
```

## Resolution
Three bugs in the HEALTHCHECK:
1. **curl not installed**: The alpine image doesn't include curl by default
2. **Wrong port**: HEALTHCHECK curls port 8080 but app listens on 3000
3. **Wrong path**: HEALTHCHECK hits `/healthz` but the endpoint is `/health`

**Fix:**
1. Install curl in the Dockerfile: `RUN apk add --no-cache curl`
2. Fix the port: use port 3000
3. Fix the path: use `/health`

Or use wget (pre-installed in alpine): `HEALTHCHECK CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1`
