#!/bin/bash
# Lab 07 - Healthcheck Always Unhealthy
echo "🏥 Lab 07: Deploying app with broken healthcheck..."
echo "======================================================"

cd "$(dirname "${BASH_SOURCE[0]}")"

docker compose down 2>/dev/null || true
docker compose up --build -d

echo ""
echo "⏳ Waiting 15 seconds for healthcheck to run..."
sleep 15

echo ""
echo "📋 Container status (check HEALTH column):"
docker ps --filter "name=lab07" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "📜 Healthcheck results:"
docker inspect --format='{{range .State.Health.Log}}{{.Output}}---{{end}}' lab07-app-container 2>/dev/null || echo "No health log available"

echo ""
echo "🧪 But the app actually works:"
echo "  curl http://localhost:3000/ → $(curl -s http://localhost:3000/ 2>/dev/null || echo 'connection failed')"
echo "  curl http://localhost:3000/health → $(curl -s http://localhost:3000/health 2>/dev/null || echo 'connection failed')"

echo ""
echo "❌ Container is unhealthy despite app working! (Expected)"
echo "🔍 Your task: Fix the HEALTHCHECK so it correctly reports health"
echo "💡 Hint: There are 3 bugs in the HEALTHCHECK - port, path, and tool"
