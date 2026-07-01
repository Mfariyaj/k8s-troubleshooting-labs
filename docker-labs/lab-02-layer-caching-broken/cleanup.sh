#!/bin/bash
# Cleanup Lab 02
echo "🧹 Cleaning up Lab 02..."
docker rmi lab02-caching-app 2>/dev/null || true
echo "✅ Lab 02 cleaned up"
