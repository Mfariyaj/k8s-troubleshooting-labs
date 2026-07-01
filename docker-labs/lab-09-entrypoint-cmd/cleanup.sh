#!/bin/bash
# Cleanup Lab 09
echo "🧹 Cleaning up Lab 09..."
docker rmi lab09-tool 2>/dev/null || true
echo "✅ Lab 09 cleaned up"
