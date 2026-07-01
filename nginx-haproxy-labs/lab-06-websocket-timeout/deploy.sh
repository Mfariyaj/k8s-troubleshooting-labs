#!/bin/bash
echo "🚀 Deploying Lab 06: WebSocket Timeout..."
docker-compose up -d --build
echo ""
echo "✅ Lab deployed! Test with:"
echo "   curl -s http://localhost:8086/"
echo "   curl -v -N -H 'Connection: Upgrade' -H 'Upgrade: websocket' -H 'Sec-WebSocket-Version: 13' -H 'Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==' http://localhost:8086/"
echo ""
echo "📋 Expected behavior: WebSocket upgrade fails"
