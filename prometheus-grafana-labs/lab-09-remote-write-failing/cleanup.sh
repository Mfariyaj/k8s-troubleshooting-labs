#!/bin/bash
echo "🧹 Cleaning up Lab 09: Remote Write Failing..."
cd "$(dirname "$0")"
docker-compose down -v --remove-orphans
echo "✅ Lab 09 cleaned up."
