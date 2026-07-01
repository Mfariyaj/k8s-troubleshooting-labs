#!/bin/bash
set -e

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_NAME="lab-12-buildkit-cache-mount"

echo "============================================="
echo "  Deploying: $LAB_NAME"
echo "  BuildKit Cache Mount CI Failure"
echo "============================================="
echo ""

cd "$LAB_DIR"

# BUG: Explicitly disable BuildKit (simulating CI environment misconfiguration)
export DOCKER_BUILDKIT=0
export COMPOSE_DOCKER_CLI_BUILD=0

echo "[!] Simulating CI environment..."
echo "[!] DOCKER_BUILDKIT=$DOCKER_BUILDKIT"
echo "[!] COMPOSE_DOCKER_CLI_BUILD=$COMPOSE_DOCKER_CLI_BUILD"
echo ""

echo "[1/3] Attempting to build with docker-compose..."
echo "      (This will fail due to BuildKit features in Dockerfile)"
echo ""

# This should fail because BuildKit is disabled but Dockerfile uses --mount syntax
docker compose build 2>&1 || true

echo ""
echo "[2/3] Attempting direct docker build..."
echo ""

docker build -t myapp:latest . 2>&1 || true

echo ""
echo "[3/3] Attempting build with cache-from (wrong reference)..."
echo ""

docker build \
    --cache-from myregistry.io/myapp:cache \
    --build-arg BUILDKIT_INLINE_CACHE=0 \
    -t myapp:latest . 2>&1 || true

echo ""
echo "============================================="
echo "  Lab Deployed (with failures!)"
echo "============================================="
echo ""
echo "Multiple build failures have occurred:"
echo "  1. BuildKit disabled but Dockerfile uses --mount syntax"
echo "  2. Cache-from references are unreachable"
echo "  3. Cache mount targets point to wrong directories"
echo "  4. buildkit.toml has aggressive GC settings"
echo ""
echo "Your task: Fix all build issues and get cache working properly."
echo ""
echo "Debug with:"
echo "  DOCKER_BUILDKIT=1 docker build --progress=plain -t myapp:latest ."
echo "  docker buildx inspect"
echo "  docker buildx du"
