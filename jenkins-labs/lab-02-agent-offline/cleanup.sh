#!/bin/bash
# Cleanup Jenkins for Lab 02

echo "🧹 Cleaning up Lab 02..."
docker-compose -f "$(dirname "$0")/docker-compose.yml" down -v
echo "✅ Cleanup complete"
