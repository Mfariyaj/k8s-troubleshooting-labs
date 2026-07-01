#!/bin/bash
echo "🚀 Deploying Lab 09: Infinite Redirect..."
docker-compose up -d --build
echo ""
echo "✅ Lab deployed! Test with:"
echo "   curl -vL --max-redirs 5 http://localhost:8090/"
echo "   curl -sI http://localhost:8089/"
echo ""
echo "📋 Expected behavior: Infinite redirect loop (ERR_TOO_MANY_REDIRECTS)"
