#!/bin/bash
echo "🚀 Deploying Lab 07: Metric Relabeling Drops All Metrics..."
cd "$(dirname "$0")"
docker-compose up -d
echo ""
echo "✅ Lab deployed! Prometheus is available at http://localhost:9090"
echo "❌ Targets show UP but all metrics are missing!"
echo "🔍 Try querying 'up' or 'node_cpu_seconds_total' in the expression browser"
echo ""
echo "Your task: Fix the metric_relabel_configs so metrics are actually stored."
