## Solution: Healthcheck Failing

### Root Cause

Three bugs in the HEALTHCHECK instruction:
1. **curl not installed**: Alpine images don't include curl by default
2. **Wrong port**: Healthcheck hits port 8080, but app listens on port 3000
3. **Wrong path**: Healthcheck uses `/healthz`, but app exposes `/health`

### Step-by-Step Fix

1. Install curl (`apk add --no-cache curl`)
2. Change port from 8080 to 3000
3. Change path from `/healthz` to `/health`

### Fixed Dockerfile

```dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package.json ./
RUN npm install --production

# Install curl for healthcheck
RUN apk add --no-cache curl

COPY server.js ./

# Fixed: correct port (3000) and correct path (/health)
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

EXPOSE 3000

CMD ["node", "server.js"]
```

### Alternative (using wget, already in Alpine)

```dockerfile
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1
```

### Verification

```bash
docker build -t lab07-fixed .
docker run -d -p 3000:3000 --name lab07 lab07-fixed
sleep 15
docker inspect --format='{{.State.Health.Status}}' lab07
# Should show "healthy"
docker ps --filter name=lab07
curl http://localhost:3000/health
docker rm -f lab07
```
