#!/bin/bash
echo "🚀 Deploying Lab 05: Uneven Load Distribution..."
docker-compose up -d --build
echo ""
echo "✅ Lab deployed! Test with:"
echo "   for i in {1..20}; do curl -s http://localhost:8085/ | jq -r '.server_id'; done | sort | uniq -c"
echo ""
echo "📋 Expected behavior: All requests go to same backend"
