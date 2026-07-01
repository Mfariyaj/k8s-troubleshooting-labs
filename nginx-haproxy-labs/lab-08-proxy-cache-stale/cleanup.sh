#!/bin/bash
echo "🧹 Cleaning up Lab 08: Proxy Cache Stale..."
docker-compose down -v --remove-orphans
echo "✅ Lab 08 cleaned up."
