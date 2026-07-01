#!/bin/bash
LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Cleaning up lab-14-docker-network-encryption..."

cd "$LAB_DIR"

# Remove Swarm stack
docker stack rm mystack 2>/dev/null || true

# Wait for services to drain
echo "Waiting for services to drain..."
sleep 10

# Remove the encrypted network
docker network rm encrypted-net 2>/dev/null || true

# Remove any firewall rules added for testing
iptables -D INPUT -p esp -j DROP 2>/dev/null || true
iptables -D INPUT -p udp --dport 7946 -j DROP 2>/dev/null || true

echo "Lab 14 cleaned up."
echo ""
echo "Note: Docker Swarm is still active. To leave swarm:"
echo "  docker swarm leave --force"
