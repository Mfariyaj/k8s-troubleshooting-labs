#!/bin/bash
echo "🧹 Cleaning up Lab 02: Alert Rules Not Firing..."
cd "$(dirname "$0")"
docker-compose down -v --remove-orphans
echo "✅ Lab 02 cleaned up."
