#!/bin/bash
set -e

echo "============================================"
echo " Lab 11: High Cardinality Explosion"
echo " Prometheus OOM Kill Scenario"
echo "============================================"
echo ""
echo "⚠️  WARNING: This lab intentionally generates millions of time series."
echo "    Prometheus WILL be OOM-killed. This is the expected broken behavior."
echo ""

cd "$(dirname "$0")"

echo "[1/3] Building high-cardinality metrics application..."
docker compose build --quiet

echo "[2/3] Starting services..."
docker compose up -d

echo "[3/3] Waiting for services to start..."
sleep 5

echo ""
echo "============================================"
echo " Lab Deployed!"
echo "============================================"
echo ""
echo "Services:"
echo "  - Prometheus:  http://localhost:9090"
echo "  - Metrics App: http://localhost:8000/metrics"
echo "  - Grafana:     http://localhost:3000 (admin/admin)"
echo ""
echo "Watch the cardinality explosion:"
echo "  curl -s localhost:8000/metrics | wc -l"
echo "  docker stats prometheus-cardinality --no-stream"
echo ""
echo "Prometheus will OOM within 5-10 minutes depending on your system."
echo "Your job: diagnose, recover, and prevent the cardinality explosion."
echo ""
