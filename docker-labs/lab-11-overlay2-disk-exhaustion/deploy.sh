#!/bin/bash
set -e

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_NAME="lab-11-overlay2-disk-exhaustion"

echo "============================================="
echo "  Deploying: $LAB_NAME"
echo "  Docker Host Disk Exhaustion Scenario"
echo "============================================="
echo ""
echo "[!] WARNING: This lab generates large log files quickly!"
echo "[!] Monitor disk usage with: watch -n 5 'docker system df'"
echo ""

cd "$LAB_DIR"

# Simulate multiple builds that leave dangling images
echo "[1/4] Building images (creating dangling layers)..."
docker build -t disk-exhaust-app:v1 . 2>/dev/null || true
docker build -t disk-exhaust-app:v2 --build-arg CACHE_BUST=$(date +%s) . 2>/dev/null || true
docker build -t disk-exhaust-app:v3 --build-arg CACHE_BUST=$(date +%s)_2 . 2>/dev/null || true

echo "[2/4] Starting services with docker-compose..."
docker compose -f docker-compose.yml up -d --build

echo "[3/4] Simulating old exited containers (not pruned)..."
for i in $(seq 1 5); do
    docker run -d --name "old-batch-run-$i" disk-exhaust-app:v1 bash -c "echo 'batch $i done'" 2>/dev/null || true
done
sleep 2

echo "[4/4] Creating orphaned volumes..."
for i in $(seq 1 3); do
    docker volume create "orphaned-data-vol-$i" 2>/dev/null || true
done

echo ""
echo "============================================="
echo "  Lab Deployed!"
echo "============================================="
echo ""
echo "The following issues are now active:"
echo "  1. Containers logging without rotation (growing fast)"
echo "  2. Dangling images from multiple builds"
echo "  3. Exited containers not cleaned up"
echo "  4. Orphaned volumes consuming space"
echo "  5. No log-opts in daemon.json"
echo ""
echo "Run disk-analysis.sh to see the impact:"
echo "  bash $LAB_DIR/disk-analysis.sh"
echo ""
echo "Your task: Identify all sources of disk waste and fix them."
