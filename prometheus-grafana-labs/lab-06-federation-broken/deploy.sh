#!/bin/bash
echo "🚀 Deploying Lab 06: Federation Configuration Broken..."
cd "$(dirname "$0")"
docker-compose up -d
echo ""
echo "✅ Lab deployed!"
echo "   Primary Prometheus: http://localhost:9090"
echo "   Federated Prometheus: http://localhost:9091"
echo "❌ Primary cannot pull metrics from federated instance"
echo ""
echo "Your task: Fix the federation config so primary correctly scrapes metrics from the federated instance."
