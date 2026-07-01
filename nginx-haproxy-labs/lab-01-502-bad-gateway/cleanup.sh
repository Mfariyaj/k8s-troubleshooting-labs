#!/bin/bash
echo "🧹 Cleaning up Lab 01: 502 Bad Gateway..."
docker-compose down -v --remove-orphans
echo "✅ Lab 01 cleaned up."
