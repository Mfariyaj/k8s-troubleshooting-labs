#!/bin/bash
echo "🚀 Deploying Lab 01: 502 Bad Gateway..."
docker-compose up -d --build
echo ""
echo "✅ Lab deployed! Test with:"
echo "   curl -v http://localhost:8081/"
echo ""
echo "📋 Expected behavior: 502 Bad Gateway"
