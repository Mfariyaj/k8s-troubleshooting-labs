## Solution: Layer Caching Broken

### Root Cause

The Dockerfile copies ALL source code (`COPY . .`) before running `npm install`. Any change to any file invalidates the Docker layer cache for `npm install`, causing a full reinstall of all dependencies on every build.

### Step-by-Step Fix

1. Copy only `package.json` and `package-lock.json` first
2. Run `npm install` (this layer is cached unless package files change)
3. Then copy the rest of the source code

### Fixed Dockerfile

```dockerfile
FROM node:20-alpine

WORKDIR /app

# Copy package files first for better layer caching
COPY package*.json ./

# This layer is cached as long as package.json doesn't change
RUN npm install --production

# Copy source code last — changes here don't bust the npm cache
COPY . .

EXPOSE 8080

CMD ["node", "src/app.js"]
```

### Verification

```bash
# First build — full install
docker build -t lab02-fixed .

# Make a change to source code
echo "// comment" >> src/app.js

# Second build — should say "CACHED" for npm install layer
docker build -t lab02-fixed .

# Look for "Using cache" or "CACHED" on the npm install step
docker run -d -p 8080:8080 --name lab02 lab02-fixed
curl http://localhost:8080
docker rm -f lab02
```
