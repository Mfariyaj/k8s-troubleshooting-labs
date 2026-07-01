#!/bin/bash
set -e

echo "============================================"
echo " Lab 13: Thanos Sidecar Upload Failures"
echo " & Data Gaps in Global Query Layer"
echo "============================================"
echo ""

cd "$(dirname "$0")"

echo "[1/3] Starting all Thanos components..."
docker compose up -d

echo "[2/3] Waiting for services to initialize (15 seconds)..."
sleep 15

echo "[3/3] Checking service status..."
echo ""
docker compose ps
echo ""

echo "============================================"
echo " Lab Deployed!"
echo "============================================"
echo ""
echo "Services:"
echo "  - Prometheus:       http://localhost:9090"
echo "  - Thanos Query:     http://localhost:9091"
echo "  - Thanos Sidecar:   http://localhost:10902/metrics"
echo "  - Thanos Compactor: http://localhost:10912/metrics"
echo "  - Thanos Store:     http://localhost:10905"
echo "  - MinIO Console:    http://localhost:9001 (minioadmin/minioadmin-secret)"
echo "  - MinIO API:        http://localhost:9000"
echo ""
echo "Expected Issues:"
echo "  - Sidecar: not uploading blocks (check logs)"
echo "  - Query: gaps in historical data"
echo "  - Compactor: halted with duplicate block errors"
echo "  - Store Gateway: no blocks synced"
echo ""
echo "Start investigating:"
echo "  docker logs thanos-sidecar --tail 30"
echo "  docker logs thanos-compactor --tail 30"
echo ""
