## Solution: BuildKit Cache Mount

### Root Cause

Multiple BuildKit cache issues:
1. **Wrong Go module cache path**: `--mount=type=cache,target=/root/.cache/go-mod` — Go expects `/go/pkg/mod`
2. **Wrong build cache path**: Uses `/tmp/go-build-cache` but `GOCACHE` must match
3. **Mount syntax error in test stage**: Missing comma (`--mount=type=cache target=...`)
4. **Cache export disabled**: `BUILDKIT_INLINE_CACHE=0` should be `1`
5. **cache_from format**: Should reference proper BuildKit cache format

### Fixed Dockerfile

```dockerfile
# syntax=docker/dockerfile:1.4
FROM golang:1.21-alpine AS builder

RUN apk add --no-cache git gcc musl-dev

WORKDIR /src

COPY go.mod go.sum ./

# Fixed: correct Go module cache path
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download

COPY . .

# Fixed: correct Go build cache path
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    CGO_ENABLED=0 GOOS=linux \
    go build -ldflags="-w -s" -o /app/server ./cmd/server

# --- Test Stage ---
FROM builder AS test

# Fixed: proper comma syntax on mount
RUN --mount=type=cache,target=/root/.cache/go-build,sharing=locked \
    --mount=type=cache,target=/go/pkg/mod \
    go test -v ./...

# --- Production Stage ---
FROM alpine:3.18 AS production

RUN apk add --no-cache ca-certificates tzdata curl

WORKDIR /app

COPY --from=builder /app/server /app/server
COPY --from=builder /src/configs /app/configs

EXPOSE 8080
HEALTHCHECK --interval=10s --timeout=3s CMD curl -f http://localhost:8080/health || exit 1

ENTRYPOINT ["/app/server"]
```

### Fixed docker-compose.yml

```yaml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
      target: production
      cache_from:
        - type=registry,ref=myregistry.io/myapp:cache
      args:
        - BUILDKIT_INLINE_CACHE=1
```

### Verification

```bash
export DOCKER_BUILDKIT=1
docker build --target production -t myapp:latest .
# Second build should use cache
docker build --target production -t myapp:latest .
docker run -d -p 8080:8080 myapp:latest
curl http://localhost:8080/health
```
