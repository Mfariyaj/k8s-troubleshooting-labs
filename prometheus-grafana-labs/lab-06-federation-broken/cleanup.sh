#!/bin/bash
echo "🧹 Cleaning up Lab 06: Federation Broken..."
cd "$(dirname "$0")"
docker-compose down -v --remove-orphans
echo "✅ Lab 06 cleaned up."
