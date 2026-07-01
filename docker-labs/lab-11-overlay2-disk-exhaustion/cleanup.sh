#!/bin/bash
LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Cleaning up lab-11-overlay2-disk-exhaustion..."

cd "$LAB_DIR"

# Stop and remove compose services
docker compose -f docker-compose.yml down -v 2>/dev/null || true

# Remove simulated old containers
for i in $(seq 1 5); do
    docker rm -f "old-batch-run-$i" 2>/dev/null || true
done

# Remove orphaned volumes created by the lab
for i in $(seq 1 3); do
    docker volume rm "orphaned-data-vol-$i" 2>/dev/null || true
done

# Remove built images
docker rmi disk-exhaust-app:v1 disk-exhaust-app:v2 disk-exhaust-app:v3 2>/dev/null || true

# Remove dangling images created by this lab
docker image prune -f 2>/dev/null || true

echo "Lab 11 cleaned up."
