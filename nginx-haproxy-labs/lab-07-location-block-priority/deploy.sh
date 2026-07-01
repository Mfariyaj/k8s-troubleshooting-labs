#!/bin/bash
echo "🚀 Deploying Lab 07: Location Block Priority..."
docker-compose up -d --build
echo ""
echo "✅ Lab deployed! Test with:"
echo "   curl -s http://localhost:8087/api/v1/health | jq ."
echo "   curl -s http://localhost:8087/api/validate | jq ."
echo ""
echo "📋 Expected behavior: Wrong handlers responding to certain paths"
