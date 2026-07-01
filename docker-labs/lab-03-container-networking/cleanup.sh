#!/bin/bash
# Cleanup Lab 03
echo "🧹 Cleaning up Lab 03..."
cd "$(dirname "${BASH_SOURCE[0]}")"
docker compose down -v --rmi local 2>/dev/null || true
echo "✅ Lab 03 cleaned up"
