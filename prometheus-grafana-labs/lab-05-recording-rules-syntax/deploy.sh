#!/bin/bash
echo "🚀 Deploying Lab 05: Recording Rules Syntax Errors..."
cd "$(dirname "$0")"
docker-compose up -d
echo ""
echo "✅ Lab deployed! Prometheus is available at http://localhost:9090"
echo "❌ Prometheus may fail to start due to invalid recording rules"
echo "🔍 Check docker logs prometheus-lab05 for errors"
echo ""
echo "Your task: Fix all syntax errors in the recording rules file."
