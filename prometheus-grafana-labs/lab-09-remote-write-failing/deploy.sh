#!/bin/bash
echo "🚀 Deploying Lab 09: Remote Write Failing..."
cd "$(dirname "$0")"
docker-compose up -d
echo ""
echo "✅ Lab deployed!"
echo "   Prometheus: http://localhost:9090"
echo "   Remote receiver (Thanos): http://localhost:19291"
echo "❌ Remote write is failing - check Prometheus logs for 401/queue errors"
echo ""
echo "Your task: Fix the remote_write configuration so metrics are sent to the remote receiver."
