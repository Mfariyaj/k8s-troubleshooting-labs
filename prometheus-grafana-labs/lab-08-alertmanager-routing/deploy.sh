#!/bin/bash
echo "🚀 Deploying Lab 08: Alertmanager Routing Misconfiguration..."
cd "$(dirname "$0")"
docker-compose up -d
echo ""
echo "✅ Lab deployed!"
echo "   Prometheus: http://localhost:9090"
echo "   Alertmanager: http://localhost:9093"
echo "❌ Alertmanager may fail to start or route alerts incorrectly"
echo ""
echo "Your task: Fix the alertmanager.yml so alerts are routed to the correct receivers."
