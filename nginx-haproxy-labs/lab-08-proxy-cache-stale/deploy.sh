#!/bin/bash
echo "🚀 Deploying Lab 08: Proxy Cache Stale..."
docker-compose up -d --build
echo ""
echo "✅ Lab deployed! Test with:"
echo "   curl -s -b 'session=user-alice' http://localhost:8088/ | jq ."
echo "   curl -s -b 'session=user-bob' http://localhost:8088/ | jq ."
echo ""
echo "📋 Expected behavior: Bob sees Alice's cached data (security bug!)"
