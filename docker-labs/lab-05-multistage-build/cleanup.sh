#!/bin/bash
# Cleanup Lab 05
echo "🧹 Cleaning up Lab 05..."
docker rmi lab05-app 2>/dev/null || true
docker rm -f lab05-container 2>/dev/null || true
echo "✅ Lab 05 cleaned up"
