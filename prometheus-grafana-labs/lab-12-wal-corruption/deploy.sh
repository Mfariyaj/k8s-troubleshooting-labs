#!/bin/bash
set -e

echo "============================================"
echo " Lab 12: WAL Corruption After Unclean Shutdown"
echo "============================================"
echo ""

cd "$(dirname "$0")"

echo "[1/4] Starting Prometheus and node-exporter..."
docker compose up -d

echo "[2/4] Waiting for Prometheus to collect data (30 seconds)..."
sleep 30

echo "[3/4] Verifying Prometheus is scraping..."
if curl -s localhost:9090/api/v1/query?query=up | grep -q '"1"'; then
    echo "       ✓ Prometheus is collecting metrics"
else
    echo "       ⚠ Prometheus may still be starting..."
    sleep 10
fi

echo "[4/4] Simulating unclean shutdown and WAL corruption..."
chmod +x corrupt-wal.sh
./corrupt-wal.sh

echo ""
echo "============================================"
echo " Lab Deployed (Broken State)!"
echo "============================================"
echo ""
echo "Prometheus is now in a broken state with corrupted WAL."
echo ""
echo "Try to start it:"
echo "  docker compose up -d prometheus"
echo "  docker logs prometheus-wal-corrupt"
echo ""
echo "Your task: Recover Prometheus and fix the shutdown configuration."
echo ""
