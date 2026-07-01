#!/bin/bash
set -e

echo "============================================"
echo " Lab 15: Grafana RBAC & Folder Permissions"
echo " Teams Can't See Their Dashboards"
echo "============================================"
echo ""

cd "$(dirname "$0")"

echo "[1/4] Starting Grafana, Prometheus, and setup container..."
docker compose up -d

echo "[2/4] Waiting for Grafana to be healthy (30 seconds)..."
sleep 30

echo "[3/4] Running setup (creating teams, folders, users)..."
# The grafana-setup container runs automatically and creates teams/folders
docker compose logs grafana-setup 2>/dev/null || true
sleep 10

echo "[4/4] Verifying setup..."
echo ""

# Check if users exist
echo "Users created:"
curl -s -u admin:admin http://localhost:3000/api/org/users 2>/dev/null | python3 -m json.tool 2>/dev/null || echo "  (Grafana may still be starting...)"
echo ""

echo "============================================"
echo " Lab Deployed!"
echo "============================================"
echo ""
echo "Services:"
echo "  - Grafana:     http://localhost:3000"
echo "  - Prometheus:  http://localhost:9090"
echo ""
echo "Test Users:"
echo "  - admin/admin      (should see everything)"
echo "  - alice/alice123   (Team A - should see ONLY Team A dashboards)"
echo "  - bob/bob123       (Team B - should see ONLY Team B dashboards)"
echo "  - anonymous        (should see NOTHING - login required)"
echo ""
echo "Expected Issues:"
echo "  - Alice & Bob can't see any dashboards"
echo "  - Anonymous users can see all dashboards (security issue!)"
echo "  - Dashboards provisioned to wrong folder"
echo "  - Nested folder permissions not inherited"
echo ""
echo "Start investigating:"
echo "  curl -s -u alice:alice123 http://localhost:3000/api/search?type=dash-db | jq ."
echo "  curl -s http://localhost:3000/api/search?type=dash-db | jq ."
echo ""
