#!/bin/bash
# Lab 04 - Volume Mount Permission Denied
echo "📂 Lab 04: Deploying app with volume permission issues..."
echo "======================================================"

cd "$(dirname "${BASH_SOURCE[0]}")"

# Remove any existing volume to start fresh
docker compose down -v 2>/dev/null || true

docker compose up --build -d

echo ""
echo "⏳ Waiting 5 seconds for app to start..."
sleep 5

echo ""
echo "📋 Container status:"
docker compose ps

echo ""
echo "📜 Application logs:"
docker compose logs app 2>&1

echo ""
echo "❌ Permission denied error! (Expected)"
echo "🔍 Your task: Fix the volume permissions so the app can write data"
echo "💡 Hint: What user is the app running as? Who owns the volume?"
