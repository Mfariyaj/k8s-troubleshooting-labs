#!/bin/bash
echo "🧹 Cleaning up Lab 07: Metric Relabeling Drops..."
cd "$(dirname "$0")"
docker-compose down -v --remove-orphans
echo "✅ Lab 07 cleaned up."
