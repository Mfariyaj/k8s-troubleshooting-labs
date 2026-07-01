# Lab 02 - Layer Caching Broken

## Difficulty: ⭐

## Scenario
A team's CI/CD pipeline takes 5+ minutes per build even for one-line code changes. The Docker image builds from scratch every time because layer caching is completely invalidated. Developers are frustrated that changing a single line in `app.js` causes all `npm install` dependencies to be re-downloaded.

## What You'll See
When you run `./deploy.sh` twice (changing only app code), the second build re-runs `npm install` from scratch:

```
 => [3/4] COPY . .                                                     0.1s
 => [4/4] RUN npm install                                            45.2s
```

Instead of getting a cached layer:
```
 => CACHED [3/5] RUN npm install                                       0.0s
```

## Hints
1. Docker caches layers sequentially - if one layer changes, all subsequent layers are rebuilt
2. What changes more often - your source code or your dependencies list?
3. Look at the order of COPY and RUN instructions

## Troubleshooting Commands
```bash
# Build and time it
time docker build -t lab02-app .

# Modify a source file
echo "// changed" >> src/app.js

# Build again and compare time
time docker build -t lab02-app .

# Check the build output for CACHED layers
docker build -t lab02-app . 2>&1 | grep -i cached
```

## Resolution
The Dockerfile copies ALL source (`COPY . .`) before running `npm install`. This means any source code change invalidates the cache for the `npm install` layer.

**Fix:** Copy `package.json` and `package-lock.json` first, run `npm install`, THEN copy the rest of the source code:
```dockerfile
COPY package*.json ./
RUN npm install
COPY . .
```
