#!/bin/bash
LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Cleaning up lab-15-container-runtime-shim..."

cd "$LAB_DIR"

# Force remove all containers (some may be in ghost state)
docker rm -f memory-hog worker-a worker-b monitor 2>/dev/null || true

# Try compose down (may hang on ghost containers)
timeout 15 docker compose down -v 2>/dev/null || {
    echo "[!] Compose down timed out (ghost containers). Force removing..."
    docker rm -f $(docker compose ps -q) 2>/dev/null || true
}

# Remove built image
docker rmi $(docker compose config --images 2>/dev/null) 2>/dev/null || true

echo "Lab 15 cleaned up."
echo ""
echo "If ghost containers persist:"
echo "  docker rm -f <container_id>"
echo "  systemctl restart containerd docker"
