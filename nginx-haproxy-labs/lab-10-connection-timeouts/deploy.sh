#!/bin/bash
echo "🚀 Deploying Lab 10: Connection Timeouts..."
docker-compose up -d --build
echo ""
echo "✅ Lab deployed! Test with:"
echo "   curl -s http://localhost:8091/ | jq ."
echo "   ./load-test.sh"
echo ""
echo "📋 Expected behavior: Failures under concurrent load"
