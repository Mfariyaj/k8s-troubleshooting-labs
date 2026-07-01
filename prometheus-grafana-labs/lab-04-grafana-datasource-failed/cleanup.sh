#!/bin/bash
echo "🧹 Cleaning up Lab 04: Grafana Datasource Connection Failed..."
cd "$(dirname "$0")"
docker-compose down -v --remove-orphans
echo "✅ Lab 04 cleaned up."
