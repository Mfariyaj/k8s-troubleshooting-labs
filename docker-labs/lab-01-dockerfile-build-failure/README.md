## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (builds and runs broken containers)
2. Check: `docker ps`, `docker logs <container>`
3. Test: Try `curl`, `docker exec`, check connectivity
4. Observe the failure and identify root cause
5. Fix the Dockerfile/docker-compose.yml and rebuild
6. Check `solution.md` if stuck

---

# Lab 01 - Dockerfile Build Failure

## Difficulty: ⭐

## Scenario
A developer is trying to build a Node.js application image but the build keeps failing with cryptic errors. The Dockerfile has multiple issues that prevent successful building.

## What You'll See
When you run `./deploy.sh`, the build will fail with errors like:

```
ERROR: failed to solve: node:22-alphine: docker.io/library/node:22-alphine: not found
```

After fixing the base image, you'll see:

```
ERROR: failed to parse Dockerfile: dockerfile parse error on line 8: unknown instruction: &&
```

And after fixing that:

```
COPY failed: file not found in build context or excluded by .dockerignore: stat src/config/: file does not exist
```

## Hints
1. Check the base image tag - is it a real tag?
2. Look at the multi-line RUN command carefully - how do you continue a command on the next line?
3. Check what files actually exist vs what the Dockerfile tries to COPY

## Troubleshooting Commands
```bash
# Try building the image
docker build -t lab01-app .

# Check available node image tags
docker search node --limit 5

# Look at what files exist in the build context
ls -la

# Check Dockerfile syntax
cat -A Dockerfile  # shows hidden characters
```

## Resolution
The Dockerfile has 3 bugs:
1. Base image `node:22-alphine` should be `node:22-alpine` (typo)
2. Missing backslash `\` at end of line 7 in multi-line RUN command
3. COPY references `src/config/` which doesn't exist in the build context
