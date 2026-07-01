#!/bin/bash
#
# cleanup.sh — Clean up Lab 12: Network Namespace Leak
#

BRIDGE_NAME="cni-lab12"
IPAM_DIR="/tmp/lab12-cni-networks"

echo "============================================"
echo " Cleaning up Lab 12: Network Namespace Leak"
echo "============================================"
echo ""

# Remove all cni-* namespaces
echo "[1/4] Removing orphaned network namespaces..."
NS_COUNT=0
for ns in $(ip netns list 2>/dev/null | grep "^cni-" | awk '{print $1}'); do
    sudo ip netns del "$ns" 2>/dev/null || true
    NS_COUNT=$((NS_COUNT + 1))
    if (( NS_COUNT % 25 == 0 )); then
        echo "  Removed $NS_COUNT namespaces..."
    fi
done
echo "  Total removed: $NS_COUNT"

# Remove bridge
echo "[2/4] Removing bridge ${BRIDGE_NAME}..."
sudo ip link set "$BRIDGE_NAME" down 2>/dev/null || true
sudo ip link del "$BRIDGE_NAME" 2>/dev/null || true

# Remove IPAM state
echo "[3/4] Cleaning IPAM state..."
rm -rf "$IPAM_DIR"

# Remove any lingering veth pairs
echo "[4/4] Cleaning orphaned veth pairs..."
for veth in $(ip link show type veth 2>/dev/null | grep "veth0000" | awk -F: '{print $2}' | tr -d ' ' | cut -d@ -f1); do
    sudo ip link del "$veth" 2>/dev/null || true
done

echo ""
echo "[✓] Lab 12 cleaned up successfully."
echo "  Namespaces remaining: $(ip netns list 2>/dev/null | wc -l)"
