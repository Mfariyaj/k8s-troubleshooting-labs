#!/bin/bash
# Lab 06 - Depends_on Race Condition
echo "🏁 Lab 06: Deploying app with database race condition..."
echo "======================================================"

cd "$(dirname "${BASH_SOURCE[0]}")"

# Fresh start
docker compose down -v 2>/dev/null || true

echo "Starting services (app depends_on db)..."
docker compose up --build -d

echo ""
echo "⏳ Waiting 8 seconds..."
sleep 8

echo ""
echo "📋 Container status:"
docker compose ps

echo ""
echo "📜 Application logs:"
docker compose logs app 2>&1

echo ""
echo "📜 Database logs (last 5 lines):"
docker compose logs db 2>&1 | tail -5

echo ""
echo "❌ App crashed because DB wasn't ready! (Expected)"
echo "🔍 Your task: Make the app wait until the database is actually ready"
echo "💡 Hint: depends_on doesn't mean 'wait until service is ready'"
