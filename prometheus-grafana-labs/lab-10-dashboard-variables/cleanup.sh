#!/bin/bash
echo "🧹 Cleaning up Lab 10: Dashboard Variables..."
cd "$(dirname "$0")"
docker-compose down -v --remove-orphans
echo "✅ Lab 10 cleaned up."
