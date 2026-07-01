#!/bin/bash
# Lab 03 - Container Networking
# Deploys 4 microservices that can't communicate

echo "🌐 Lab 03: Deploying microservices with broken networking..."
echo "======================================================"

cd "$(dirname "${BASH_SOURCE[0]}")"

docker compose up -d --build

echo ""
echo "⏳ Waiting 10 seconds for services to start..."
sleep 10

echo ""
echo "📋 Container status:"
docker compose ps

echo ""
echo "📜 Backend logs (showing errors):"
docker compose logs backend 2>&1 | tail -10

echo ""
echo "📜 Frontend logs (showing errors):"
docker compose logs frontend 2>&1 | tail -10

echo ""
echo "❌ Services cannot communicate! (Expected)"
echo "🔍 Your task: Fix the networking so all services can reach each other"
echo "💡 Hint: Check networks, service names, and port numbers"
