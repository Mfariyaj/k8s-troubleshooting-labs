## Solution: Dockerfile Build Failure

### Root Cause

The Dockerfile has three bugs:
1. **Typo in base image**: `node:22-alphine` should be `node:22-alpine`
2. **Missing backslash**: The multi-line `RUN` command is missing `\` after `npm install`, breaking the command chain
3. **Non-existent directory**: `COPY src/config/ ./config/` references a directory that doesn't exist in the build context

### Step-by-Step Fix

1. Fix the base image tag: `FROM node:22-alpine`
2. Add missing backslash after `npm install`
3. Remove the COPY for non-existent `src/config/`

### Fixed Dockerfile

```dockerfile
FROM node:22-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install \
    && npm cache clean --force \
    && rm -rf /tmp/*

COPY src/ ./src/

EXPOSE 3000

CMD ["node", "src/index.js"]
```

### Verification

```bash
docker build -t lab01-fixed .
docker run -d -p 3000:3000 --name lab01 lab01-fixed
curl http://localhost:3000
docker logs lab01
docker rm -f lab01
```
