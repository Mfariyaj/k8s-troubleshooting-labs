#!/bin/bash
set -e

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_NAME="lab-14-docker-network-encryption"

echo "============================================="
echo "  Deploying: $LAB_NAME"
echo "  Swarm Overlay Network Encryption"
echo "============================================="
echo ""
echo "[!] PREREQUISITE: Docker Swarm must be initialized"
echo "[!] Run 'docker swarm init' if not already in swarm mode"
echo ""

cd "$LAB_DIR"

# Check if swarm is initialized
if ! docker info 2>/dev/null | grep -q "Swarm: active"; then
    echo "[!] Docker Swarm is not active. Initializing single-node swarm..."
    docker swarm init 2>/dev/null || {
        echo "[!] Failed to init swarm. Trying with advertise-addr..."
        MAIN_IP=$(hostname -I | awk '{print $1}')
        docker swarm init --advertise-addr "$MAIN_IP" 2>/dev/null || {
            echo "[ERROR] Cannot initialize Docker Swarm."
            echo "[ERROR] Please run: docker swarm init --advertise-addr <your-ip>"
            exit 1
        }
    }
fi

echo "[1/3] Creating encrypted overlay network..."
docker network create \
    --driver overlay \
    --opt encrypted \
    --opt com.docker.network.driver.mtu=1500 \
    --subnet 10.0.1.0/24 \
    encrypted-net 2>/dev/null || echo "  Network already exists"

echo ""
echo "[2/3] Deploying Swarm stack..."
docker stack deploy -c docker-compose.yml mystack

echo ""
echo "[3/3] Simulating firewall restrictions..."
echo "  In a multi-node setup, the following would be blocked:"
echo "  - IP Protocol 50 (ESP) — encrypted overlay traffic"
echo "  - UDP 7946 — gossip protocol"
echo "  - MTU overhead not accounted for"

echo ""
echo "============================================="
echo "  Lab Deployed!"
echo "============================================="
echo ""
echo "NOTE: Full reproduction requires a multi-node Swarm cluster."
echo "On a single node, cross-node issues won't manifest."
echo ""
echo "To simulate on a single node:"
echo "  1. Check network config: docker network inspect encrypted-net"
echo "  2. Run debug script: bash $LAB_DIR/network-debug.sh"
echo "  3. Test MTU issues: docker exec <container> ping -s 1400 -M do <target>"
echo ""
echo "For full multi-node testing:"
echo "  1. Set up 3 nodes (docker swarm join)"
echo "  2. Block protocol 50: iptables -A INPUT -p esp -j DROP"
echo "  3. Block UDP 7946: iptables -A INPUT -p udp --dport 7946 -j DROP"
echo "  4. Observe cross-node failures"
