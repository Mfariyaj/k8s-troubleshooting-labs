#!/bin/bash
#
# simulate.sh — Simulates orphaned network namespace leak
# Creates fake "leaked" network namespaces as a CNI plugin would
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NUM_NAMESPACES="${1:-50}"   # Default 50 for safety, scenario describes 500+
SUBNET="10.244.1"
BRIDGE_NAME="cni-lab12"
IPAM_DIR="/tmp/lab12-cni-networks/cni0"

echo "============================================"
echo " Lab 12: Network Namespace Leak Simulation"
echo "============================================"
echo ""
echo "This simulates $NUM_NAMESPACES orphaned network namespaces"
echo "mimicking a CNI plugin that fails to clean up on container delete."
echo ""
echo "WARNING: Creates real network namespaces and veth pairs."
echo "Run only in a lab environment!"
echo ""
read -p "Continue? (yes/no): " confirm
if [[ "$confirm" != "yes" ]]; then
    echo "Aborted."
    exit 0
fi

# Create IPAM directory
mkdir -p "$IPAM_DIR"

# Create bridge
echo "[1/4] Creating bridge ${BRIDGE_NAME}..."
sudo ip link add name "$BRIDGE_NAME" type bridge 2>/dev/null || true
sudo ip link set "$BRIDGE_NAME" up
sudo ip addr add "${SUBNET}.1/24" dev "$BRIDGE_NAME" 2>/dev/null || true

# Create namespaces with veth pairs
echo "[2/4] Creating $NUM_NAMESPACES orphaned network namespaces..."
CREATED=0
for i in $(seq 2 $((NUM_NAMESPACES + 1))); do
    # Generate a fake CNI-style namespace name
    UUID=$(cat /proc/sys/kernel/random/uuid)
    NS_NAME="cni-${UUID}"
    VETH_HOST="veth$(printf '%08x' $i)"
    VETH_NS="eth0"
    IP="${SUBNET}.${i}"

    # Create namespace
    sudo ip netns add "$NS_NAME" 2>/dev/null || continue

    # Create veth pair
    sudo ip link add "$VETH_HOST" type veth peer name "$VETH_NS" 2>/dev/null || {
        sudo ip netns del "$NS_NAME" 2>/dev/null
        continue
    }

    # Move one end into namespace
    sudo ip link set "$VETH_NS" netns "$NS_NAME" 2>/dev/null || {
        sudo ip link del "$VETH_HOST" 2>/dev/null
        sudo ip netns del "$NS_NAME" 2>/dev/null
        continue
    }

    # Attach other end to bridge
    sudo ip link set "$VETH_HOST" master "$BRIDGE_NAME" 2>/dev/null || true
    sudo ip link set "$VETH_HOST" up 2>/dev/null || true

    # Configure IP inside namespace
    sudo ip netns exec "$NS_NAME" ip addr add "${IP}/24" dev "$VETH_NS" 2>/dev/null || true
    sudo ip netns exec "$NS_NAME" ip link set "$VETH_NS" up 2>/dev/null || true
    sudo ip netns exec "$NS_NAME" ip link set lo up 2>/dev/null || true

    # Create IPAM allocation file (simulating host-local IPAM)
    echo "$NS_NAME" > "${IPAM_DIR}/${IP}"

    CREATED=$((CREATED + 1))

    # Progress
    if (( CREATED % 10 == 0 )); then
        echo "  Created $CREATED/$NUM_NAMESPACES namespaces..."
    fi
done

# Create fake "last_reserved_ip" file
echo "${SUBNET}.$((NUM_NAMESPACES + 1))" > "${IPAM_DIR}/last_reserved_ip.0"

echo "[3/4] Creating summary..."
echo ""
echo "============================================"
echo " SIMULATION COMPLETE"
echo "============================================"
echo ""
echo "Created: $CREATED orphaned network namespaces"
echo "Bridge: $BRIDGE_NAME with $CREATED veth pairs attached"
echo "IPAM dir: $IPAM_DIR ($CREATED allocations)"
echo ""

echo "[4/4] Current state:"
echo "  Network namespaces: $(ip netns list | wc -l)"
echo "  Bridge members: $(bridge link show | grep "$BRIDGE_NAME" | wc -l)"
echo "  IPAM allocations: $(ls ${IPAM_DIR}/ 2>/dev/null | grep -E '^10\.' | wc -l)"
echo ""
echo "============================================"
echo " YOUR TASK:"
echo "  1. Identify orphaned namespaces (no running container)"
echo "  2. Clean up namespaces, veth pairs, IPAM allocations"
echo "  3. Verify IPs are reclaimed"
echo ""
echo " Use: ./ipam-check.sh to see IPAM status"
echo "============================================"
