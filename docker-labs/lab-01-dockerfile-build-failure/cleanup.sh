#!/bin/bash
# Cleanup Lab 01
echo "🧹 Cleaning up Lab 01..."
docker rmi lab01-broken-app 2>/dev/null || true
docker builder prune -f 2>/dev/null || true
echo "✅ Lab 01 cleaned up"
