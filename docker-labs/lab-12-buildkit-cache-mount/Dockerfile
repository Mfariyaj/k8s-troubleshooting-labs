# syntax=docker/dockerfile:1.4
# Multi-stage BuildKit build with cache mounts for a Go application
# This Dockerfile uses advanced BuildKit features that fail in CI

# BUG 1: Missing syntax directive version compatibility check
# BUG 2: --mount=type=cache target path is wrong for Go
# BUG 3: Cache-from reference uses wrong format
# BUG 4: Inline cache metadata not exported

FROM golang:1.21-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git gcc musl-dev

WORKDIR /src

# Copy go modules first for caching
COPY go.mod go.sum ./

# BUG: --mount=type=cache with incorrect target for Go module cache
# Go expects GOPATH/pkg/mod but we point to wrong path
RUN --mount=type=cache,target=/root/.cache/go-mod \
    go mod download

COPY . .

# BUG: --mount=type=cache with wrong Go build cache path
# Should be /root/.cache/go-build but uses non-existent path
RUN --mount=type=cache,target=/tmp/go-build-cache \
    --mount=type=cache,target=/root/.cache/go-mod \
    GOCACHE=/tmp/go-build-cache \
    CGO_ENABLED=0 GOOS=linux \
    go build -ldflags="-w -s" -o /app/server ./cmd/server

# --- Test Stage ---
FROM builder AS test

# BUG: mount syntax error - comma instead of space separator
RUN --mount=type=cache,target=/tmp/go-build-cache,sharing=locked \
    --mount=type=cache target=/root/.cache/go-mod \
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
