#!/bin/bash
echo "🧹 Cleaning up Lab 08: Alertmanager Routing..."
cd "$(dirname "$0")"
docker-compose down -v --remove-orphans
echo "✅ Lab 08 cleaned up."
