#!/bin/bash
echo "🚀 Deploying Lab 03: Rate Limiting..."
docker-compose up -d --build
echo ""
echo "✅ Lab deployed! Test with:"
echo "   for i in {1..5}; do curl -s -o /dev/null -w '%{http_code}\n' http://localhost:8083/health; done"
echo ""
echo "📋 Expected behavior: Most requests return 429 Too Many Requests"
