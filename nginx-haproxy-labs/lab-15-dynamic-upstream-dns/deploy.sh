#!/bin/bash
set -e

echo "============================================"
echo " Lab 15: Dynamic Upstream DNS Resolution"
echo "============================================"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "[*] Starting Nginx + Consul + Backends..."
docker-compose up -d

echo ""
echo "[*] Waiting for all services to start..."
sleep 8

echo "[*] Registering backends in Consul..."
# Register services in Consul
for i in 1 2 3; do
    IP="172.28.0.$((19+i))"
    curl -s -X PUT http://localhost:8500/v1/agent/service/register -d '{
        "Name": "backend",
        "ID": "backend'$i'",
        "Address": "'$IP'",
        "Port": 80,
        "Check": {
            "HTTP": "http://'$IP':80/health",
            "Interval": "5s"
        }
    }' > /dev/null 2>&1 || true
done

echo ""
echo "============================================"
echo " SCENARIO: Stale DNS / Traffic to Dead IPs"
echo "============================================"
echo ""
echo "Your microservices are registered in Consul."
echo "Nginx should discover backends via DNS."
echo "When backends scale down, Nginx keeps sending"
echo "traffic to old IPs (502 errors for minutes)."
echo ""
echo "Test routing:"
echo "  for i in \$(seq 1 10); do curl -s http://localhost:8080/ | jq .instance_ip; done"
echo ""
echo "Scale down a backend:"
echo "  docker stop dns-backend3"
echo "  # Then keep curling - Nginx still sends to 172.28.0.22"
echo "  for i in \$(seq 1 20); do curl -s http://localhost:8080/ | jq .; sleep 1; done"
echo ""
echo "Check DNS resolution:"
echo "  docker exec dns-nginx nslookup backend.service.consul 172.28.0.2"
echo ""
echo "Consul services:"
echo "  curl -s http://localhost:8500/v1/catalog/service/backend | jq ."
echo ""
echo "============================================"
