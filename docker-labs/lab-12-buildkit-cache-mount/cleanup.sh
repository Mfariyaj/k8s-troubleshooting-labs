#!/bin/bash
LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Cleaning up lab-12-buildkit-cache-mount..."

cd "$LAB_DIR"

# Remove compose services
docker compose down -v 2>/dev/null || true

# Remove built images
docker rmi myapp:latest 2>/dev/null || true

# Clean BuildKit cache created by this lab
docker builder prune -f 2>/dev/null || true

# Unset env vars
unset DOCKER_BUILDKIT
unset COMPOSE_DOCKER_CLI_BUILD

echo "Lab 12 cleaned up."
