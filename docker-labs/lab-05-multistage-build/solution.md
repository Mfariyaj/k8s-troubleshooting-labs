## Solution: Multistage Build

### Root Cause

The Go binary is built with CGO enabled (default), producing a dynamically linked executable that depends on C libraries (libc). The runtime stage uses `FROM scratch` — an empty image with no libraries. When the container starts, the binary fails with "not found" because the dynamic linker and shared libraries are missing.

### Step-by-Step Fix

1. Set `CGO_ENABLED=0` to produce a statically linked binary
2. Add `-ldflags="-w -s"` to strip debug info and reduce size

### Fixed Dockerfile

```dockerfile
# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /build

COPY go.mod ./
COPY main.go ./

# Static linking — binary has no external dependencies
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o server .

# Runtime stage
FROM scratch

WORKDIR /app

COPY --from=builder /build/server ./server

EXPOSE 8080

ENTRYPOINT ["/app/server"]
```

### Verification

```bash
docker build -t lab05-fixed .
docker run -d -p 8080:8080 --name lab05 lab05-fixed
curl http://localhost:8080
docker logs lab05
docker rm -f lab05
```
