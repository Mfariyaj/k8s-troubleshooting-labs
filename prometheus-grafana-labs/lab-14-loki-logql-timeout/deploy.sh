#!/bin/bash
set -e

echo "============================================"
echo " Lab 14: Loki LogQL Query Timeouts"
echo "============================================"
echo ""

cd "$(dirname "$0")"

echo "[1/3] Starting Loki, Promtail, log generators, and Grafana..."
docker compose up -d

echo "[2/3] Waiting for services to start (10 seconds)..."
sleep 10

echo "[3/3] Verifying service status..."
echo ""
docker compose ps
echo ""

echo "============================================"
echo " Lab Deployed!"
echo "============================================"
echo ""
echo "Services:"
echo "  - Loki:      http://localhost:3100"
echo "  - Promtail:  http://localhost:9080/targets"
echo "  - Grafana:   http://localhost:3000 (admin/admin)"
echo ""
echo "Expected Issues:"
echo "  - All LogQL queries timeout with 'context deadline exceeded'"
echo "  - Promtail can't deliver logs (wrong port)"
echo "  - Even if logs were ingested, queries are too restrictive"
echo ""
echo "Try querying:"
echo "  curl -s 'http://localhost:3100/loki/api/v1/query' --data-urlencode 'query={job=~\".+\"}'"
echo ""
echo "Check Promtail:"
echo "  docker logs promtail-timeout --tail 20"
echo ""
