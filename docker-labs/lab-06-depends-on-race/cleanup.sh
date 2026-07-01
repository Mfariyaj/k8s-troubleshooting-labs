#!/bin/bash
# Cleanup Lab 06
echo "🧹 Cleaning up Lab 06..."
cd "$(dirname "${BASH_SOURCE[0]}")"
docker compose down -v --rmi local 2>/dev/null || true
echo "✅ Lab 06 cleaned up"
