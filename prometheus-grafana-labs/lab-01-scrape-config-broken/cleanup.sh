#!/bin/bash
echo "🧹 Cleaning up Lab 01: Broken Scrape Configuration..."
cd "$(dirname "$0")"
docker-compose down -v --remove-orphans
echo "✅ Lab 01 cleaned up."
