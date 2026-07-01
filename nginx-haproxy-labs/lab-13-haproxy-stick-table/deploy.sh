#!/bin/bash
set -e

echo "============================================"
echo " Lab 13: HAProxy Stick-Table Peer Replication"
echo "============================================"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "[*] Starting HAProxy cluster with backends..."
docker-compose up -d

echo ""
echo "[*] Waiting for services to start..."
sleep 5

echo ""
echo "============================================"
echo " SCENARIO: Session Persistence Lost on Failover"
echo "============================================"
echo ""
echo "Two HAProxy instances use stick-table replication"
echo "for session persistence. Users are losing their"
echo "sessions when traffic fails over between instances."
echo ""
echo "Test session persistence:"
echo "  # Hit haproxy1 multiple times - should stick to same backend"
echo "  for i in \$(seq 1 5); do curl -s http://localhost:8080/ | grep backend; done"
echo ""
echo "  # Hit haproxy2 - should honor same stick-table entry"
echo "  for i in \$(seq 1 5); do curl -s http://localhost:8081/ | grep backend; done"
echo ""
echo "Check stick-table state:"
echo "  echo 'show table http_back' | socat stdio tcp4:localhost:8080"
echo ""
echo "Stats dashboards:"
echo "  HAProxy 1: http://localhost:8404/stats"
echo "  HAProxy 2: http://localhost:8405/stats"
echo ""
echo "============================================"
