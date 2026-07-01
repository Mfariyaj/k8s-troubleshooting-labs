#!/bin/bash
# Cleanup Lab 07
echo "🧹 Cleaning up Lab 07..."
cd "$(dirname "${BASH_SOURCE[0]}")"
docker compose down --rmi local 2>/dev/null || true
echo "✅ Lab 07 cleaned up"
