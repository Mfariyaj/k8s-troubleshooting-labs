#!/bin/bash
set -e

echo "============================================"
echo " Lab 14: OpenResty/Nginx Lua Scripting Errors"
echo "============================================"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "[*] Starting OpenResty with Lua modules..."
docker-compose up -d

echo ""
echo "[*] Waiting for services to start..."
sleep 3

echo ""
echo "============================================"
echo " SCENARIO: Lua Dynamic Routing Failures"
echo "============================================"
echo ""
echo "Your team implemented dynamic routing using OpenResty's"
echo "Lua modules. The system crashes on startup or fails"
echo "silently with routing errors, memory exhaustion, and"
echo "cosocket API violations."
echo ""
echo "Check if OpenResty started successfully:"
echo "  docker logs lua-nginx"
echo ""
echo "Try to make requests:"
echo "  curl -v http://localhost:8080/api/v1/users"
echo ""
echo "Check error logs:"
echo "  docker exec lua-nginx tail -f /usr/local/openresty/nginx/logs/error.log"
echo ""
echo "============================================"
