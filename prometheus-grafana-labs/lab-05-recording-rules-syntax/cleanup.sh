#!/bin/bash
echo "🧹 Cleaning up Lab 05: Recording Rules Syntax..."
cd "$(dirname "$0")"
docker-compose down -v --remove-orphans
echo "✅ Lab 05 cleaned up."
