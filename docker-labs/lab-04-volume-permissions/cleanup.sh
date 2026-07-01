#!/bin/bash
# Cleanup Lab 04
echo "🧹 Cleaning up Lab 04..."
cd "$(dirname "${BASH_SOURCE[0]}")"
docker compose down -v --rmi local 2>/dev/null || true
echo "✅ Lab 04 cleaned up"
