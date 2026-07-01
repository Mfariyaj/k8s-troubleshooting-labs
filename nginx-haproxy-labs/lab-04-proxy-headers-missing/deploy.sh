#!/bin/bash
echo "🚀 Deploying Lab 04: Proxy Headers Missing..."
docker-compose up -d --build
echo ""
echo "✅ Lab deployed! Test with:"
echo "   curl -s http://localhost:8084/ | jq ."
echo ""
echo "📋 Expected behavior: Headers show internal names and NOT SET values"
