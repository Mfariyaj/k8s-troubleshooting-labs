#!/bin/bash
# Cleanup Lab 08
echo "🧹 Cleaning up Lab 08..."
cd "$(dirname "${BASH_SOURCE[0]}")"
docker compose down --rmi local 2>/dev/null || true
docker rm -f lab08-java 2>/dev/null || true
echo "✅ Lab 08 cleaned up"
