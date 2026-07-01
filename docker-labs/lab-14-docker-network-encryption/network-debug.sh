#!/bin/bash
# Network Debug Script for Docker Swarm Encrypted Overlay
# Run on each Swarm node to diagnose connectivity issues

echo "============================================="
echo "  Docker Swarm Network Encryption Debug"
echo "============================================="
echo ""

echo "--- Node Information ---"
docker info 2>/dev/null | grep -A5 "Swarm"
docker node ls 2>/dev/null
echo ""

echo "--- Overlay Networks ---"
docker network ls --filter driver=overlay
echo ""

echo "--- Encrypted Network Details ---"
docker network inspect encrypted-net 2>/dev/null || \
docker network inspect mystack_encrypted-net 2>/dev/null || \
echo "Network not found. Deploy the stack first."
echo ""

echo "--- Checking Required Ports ---"
echo "Port 2377 (Swarm management - TCP):"
ss -tlnp | grep 2377 || echo "  NOT LISTENING"
echo ""
echo "Port 7946 (Gossip - TCP):"
ss -tlnp | grep 7946 || echo "  NOT LISTENING"
echo ""
echo "Port 7946 (Gossip - UDP):"
ss -ulnp | grep 7946 || echo "  NOT LISTENING (BUG: UDP required for SWIM)"
echo ""
echo "Port 4789 (VXLAN - UDP):"
ss -ulnp | grep 4789 || echo "  NOT LISTENING"
echo ""

echo "--- IPSec/ESP Status ---"
echo "Loaded ESP modules:"
lsmod | grep esp || echo "  No ESP modules loaded"
echo ""
echo "XFRM state (IPSec SAs):"
ip xfrm state 2>/dev/null | head -20 || echo "  No xfrm state"
echo ""
echo "XFRM policy:"
ip xfrm policy 2>/dev/null | head -20 || echo "  No xfrm policy"
echo ""

echo "--- Firewall Rules (ESP/Protocol 50) ---"
echo "iptables INPUT chain:"
iptables -L INPUT -n 2>/dev/null | grep -i "esp\|proto 50" || echo "  No ESP rules found (BUG!)"
echo ""
echo "iptables FORWARD chain:"
iptables -L FORWARD -n 2>/dev/null | grep -i "esp\|proto 50" || echo "  No ESP rules in FORWARD"
echo ""

echo "--- MTU Check ---"
echo "Host interface MTU:"
ip link show eth0 2>/dev/null | grep mtu
echo ""
echo "Docker bridge MTU:"
ip link show docker0 2>/dev/null | grep mtu
echo ""
echo "VXLAN interface MTU:"
ip link show | grep -A1 vxlan | head -5
echo ""

echo "--- Packet Capture Test (5 seconds) ---"
echo "Capturing ESP packets (protocol 50)..."
timeout 5 tcpdump -i eth0 -n proto 50 -c 5 2>/dev/null || echo "  No ESP packets seen (BUG: blocked by firewall)"
echo ""
echo "Capturing VXLAN packets (port 4789)..."
timeout 5 tcpdump -i eth0 -n port 4789 -c 5 2>/dev/null || echo "  No VXLAN packets"
echo ""

echo "--- Connectivity Test ---"
CONTAINERS=$(docker ps --format '{{.ID}}' 2>/dev/null | head -2)
if [ -n "$CONTAINERS" ]; then
    FIRST=$(echo "$CONTAINERS" | head -1)
    echo "Testing from container $FIRST..."
    docker exec "$FIRST" ping -c 2 -W 3 10.0.1.1 2>/dev/null || echo "  Ping failed"
    echo ""
    echo "Testing MTU path discovery (1400 bytes):"
    docker exec "$FIRST" ping -c 2 -W 3 -s 1400 -M do 10.0.1.1 2>/dev/null || echo "  Large packet failed (MTU issue)"
    echo ""
    echo "Testing MTU path discovery (1300 bytes):"
    docker exec "$FIRST" ping -c 2 -W 3 -s 1300 -M do 10.0.1.1 2>/dev/null || echo "  Medium packet failed"
fi

echo ""
echo "============================================="
echo "  Required Security Group Rules:"
echo "============================================="
echo ""
echo "  TCP 2377  - Swarm cluster management"
echo "  TCP 7946  - Container network discovery"
echo "  UDP 7946  - Container network discovery (SWIM gossip)"
echo "  UDP 4789  - Overlay network traffic (VXLAN)"
echo "  Proto 50  - Encrypted overlay traffic (IPSec ESP)"
echo ""
echo "  Missing from typical setups: UDP/7946 and Protocol 50"
echo "============================================="
