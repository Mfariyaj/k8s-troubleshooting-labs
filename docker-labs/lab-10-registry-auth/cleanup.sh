#!/bin/bash
# Cleanup Lab 10
echo "🧹 Cleaning up Lab 10..."
cd "$(dirname "${BASH_SOURCE[0]}")"
docker compose down -v 2>/dev/null || true
docker rmi lab10-api-service 2>/dev/null || true
echo "✅ Lab 10 cleaned up"
