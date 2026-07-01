#!/bin/bash
echo "🚀 Deploying Lab 10: Dashboard Variables Not Working..."
cd "$(dirname "$0")"
docker-compose up -d
echo ""
echo "✅ Lab deployed!"
echo "   Grafana: http://localhost:3000 (admin/admin)"
echo "   Prometheus: http://localhost:9090"
echo "❌ Dashboard variables show errors - datasource UID mismatch"
echo ""
echo "Your task: Fix the dashboard JSON so variables and panels connect to the correct datasource."
