#!/bin/bash
echo "🚀 Deploying Lab 01: Broken Scrape Configuration..."
cd "$(dirname "$0")"
docker-compose up -d
echo ""
echo "✅ Lab deployed! Prometheus is available at http://localhost:9090"
echo "🔍 Check targets at http://localhost:9090/targets"
echo "❌ You should see node-exporter target as DOWN"
echo ""
echo "Your task: Fix the scrape configuration so node-exporter metrics are collected."
