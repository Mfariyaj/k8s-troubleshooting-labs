#!/bin/bash
# Lab 08 - Container OOM Killed
echo "💀 Lab 08: Deploying Java app that will be OOM killed..."
echo "======================================================"

cd "$(dirname "${BASH_SOURCE[0]}")"

docker compose down 2>/dev/null || true
docker compose up --build -d

echo ""
echo "⏳ Waiting 15 seconds for OOM to occur..."
sleep 15

echo ""
echo "📋 Container status:"
docker ps -a --filter "name=lab08" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "🔍 Was it OOM Killed?"
OOM=$(docker inspect lab08-java --format='{{.State.OOMKilled}}' 2>/dev/null)
EXIT_CODE=$(docker inspect lab08-java --format='{{.State.ExitCode}}' 2>/dev/null)
echo "  OOMKilled: $OOM"
echo "  Exit Code: $EXIT_CODE (137 = SIGKILL/OOM)"

echo ""
echo "📜 Application logs:"
docker compose logs app 2>&1 | tail -15

echo ""
echo "❌ Container was OOM killed! (Expected)"
echo "🔍 Your task: Fix the memory configuration so the app runs within limits"
echo "💡 Hint: Compare JVM -Xmx setting with container memory limit"
