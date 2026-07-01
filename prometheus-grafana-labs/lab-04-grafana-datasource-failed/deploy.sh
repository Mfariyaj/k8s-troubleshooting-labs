#!/bin/bash
echo "🚀 Deploying Lab 04: Grafana Datasource Connection Failed..."
cd "$(dirname "$0")"
docker-compose up -d
echo ""
echo "✅ Lab deployed!"
echo "   Grafana: http://localhost:3000 (admin/admin)"
echo "   Prometheus: http://localhost:9090"
echo "❌ Grafana datasource test will FAIL"
echo ""
echo "Your task: Fix the datasource configuration so Grafana can query Prometheus."
