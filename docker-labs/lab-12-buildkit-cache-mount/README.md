# Lab 12: BuildKit Cache Mount — CI Build Failures

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your Go microservice builds fine on developer laptops but consistently fails in CI (Jenkins/GitHub Actions). The Dockerfile uses advanced BuildKit features (`RUN --mount=type=cache`) for faster builds, but CI pipelines report syntax errors and cache never persists between builds.

The team recently upgraded from legacy Docker builds to BuildKit with cache mounts for a 70% build-time improvement locally. But CI builds:
1. Fail with syntax errors on `--mount` directives
2. Never hit the cache (cold build every time)
3. Inline cache metadata isn't exported to registry
4. BuildKit configuration has aggressive garbage collection

## Symptoms Observed

```
$ docker build -t myapp:latest .
Step 5/12 : RUN --mount=type=cache,target=/root/.cache/go-mod     go mod download
 ---> Running in 4a5b6c7d8e9f
/bin/sh: --mount=type=cache,target=/root/.cache/go-mod: not found
The command '/bin/sh -c --mount=type=cache,target=/root/.cache/go-mod     go mod download' returned a non-zero code: 127

$ echo $DOCKER_BUILDKIT
0

$ docker compose build
failed to solve: rpc error: code = Unknown desc = failed to solve with frontend dockerfile.v0:
failed to create LLB definition: dockerfile parse error line 22:
unknown flag: mount

$ docker build --cache-from myregistry.io/myapp:cache -t myapp .
WARNING: failed to fetch metadata for myregistry.io/myapp:cache:
  pull access denied, repository does not exist or may require authentication

$ docker buildx inspect
Name:   default
Driver: docker

$ cat buildkit.toml
[worker.oci]
  gckeepbytes = 104857600  # Only 100MB — Go modules alone are 200MB+

$ docker buildx du
ID          RECLAIMABLE SIZE        LAST ACCESSED
abc123      true        0B          2 months ago
```

## What's Broken

1. **DOCKER_BUILDKIT=0** in CI environment — disables BuildKit, making `--mount` syntax invalid
2. **Cache target paths wrong** — Go module cache is at `/go/pkg/mod` (not `/root/.cache/go-mod`)
3. **RUN --mount syntax error** in test stage — missing comma separator
4. **cache-from references unreachable** — registry doesn't exist, no auth configured
5. **BUILDKIT_INLINE_CACHE=0** — should be `1` to export cache metadata
6. **buildkit.toml GC too aggressive** — evicts cache between builds

## Debugging Commands

```bash
# Check if BuildKit is enabled
echo $DOCKER_BUILDKIT
docker buildx version
docker buildx inspect --bootstrap

# Build with verbose output
DOCKER_BUILDKIT=1 docker build --progress=plain -t myapp:latest .

# Check syntax directive in Dockerfile
head -1 Dockerfile

# Validate Dockerfile syntax
docker buildx build --check .

# Inspect build cache
docker buildx du
docker builder prune --dry-run

# Test cache mount paths (inside a builder container)
docker run --rm golang:1.21-alpine go env GOPATH GOMODCACHE GOCACHE

# Check BuildKit daemon config
docker buildx inspect default --bootstrap
cat buildkit.toml

# Build with explicit cache export
DOCKER_BUILDKIT=1 docker build \
  --cache-to type=inline \
  --cache-from type=registry,ref=myregistry.io/myapp:cache \
  -t myapp:latest .

# Check compose build configuration
docker compose config
cat docker-compose.yml | grep -A5 cache

# Verify environment in CI simulation
env | grep -i docker
env | grep -i buildkit
```

## Hints

<details>
<summary>Hint 1</summary>
Set `DOCKER_BUILDKIT=1` and `COMPOSE_DOCKER_CLI_BUILD=1`. The `# syntax=docker/dockerfile:1.4` directive at the top of the Dockerfile tells Docker to use the BuildKit frontend, but only works when BuildKit is actually enabled.
</details>

<details>
<summary>Hint 2</summary>
Go's module cache lives at `$GOPATH/pkg/mod` (default: `/go/pkg/mod` in official images). The build cache is at `$HOME/.cache/go-build`. Use `go env GOMODCACHE GOCACHE` to verify correct paths for `--mount=type=cache,target=`.
</details>

<details>
<summary>Hint 3</summary>
For cache to persist in CI: Set `BUILDKIT_INLINE_CACHE=1` as a build arg, use `--cache-to type=inline` when building, and push the built image so subsequent builds can use `--cache-from type=registry,ref=<image>`. The buildkit.toml GC policy must also retain enough bytes to hold your dependency cache.
</details>

## Learning Objectives

- Understanding BuildKit architecture and cache mount types
- Debugging CI/CD Docker build environment issues
- Configuring BuildKit garbage collection for persistent caches
- Implementing cache-from/cache-to strategies for CI pipelines
- Go module cache mechanics inside Docker builds
