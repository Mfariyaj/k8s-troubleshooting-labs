#!/bin/bash
echo "🚀 Deploying Lab 02: Alert Rules Not Firing..."
cd "$(dirname "$0")"
docker-compose up -d
echo ""
echo "✅ Lab deployed! Prometheus is available at http://localhost:9090"
echo "🔍 Check alerts at http://localhost:9090/alerts"
echo "❌ You should see alert rule errors or alerts that never fire"
echo ""
echo "Your task: Fix the alert rules so they correctly evaluate and fire."
