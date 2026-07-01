#!/bin/bash
#
# ipam-check.sh — Check IPAM allocation status and identify orphaned namespaces
#

BRIDGE_NAME="cni-lab12"
IPAM_DIR="/tmp/lab12-cni-networks/cni0"
SUBNET="10.244.1"

echo "============================================"
echo " IPAM & Namespace Health Check"
echo "============================================"
echo ""

# 1. Network namespace count
NS_COUNT=$(ip netns list 2>/dev/null | grep -c "^cni-" || echo "0")
echo "[Namespaces]"
echo "  Total CNI namespaces: $NS_COUNT"
echo ""

# 2. IPAM allocation count
if [[ -d "$IPAM_DIR" ]]; then
    IPAM_COUNT=$(ls "$IPAM_DIR" 2>/dev/null | grep -cE "^${SUBNET//./\\.}" || echo "0")
    TOTAL_IPS=253  # /24 minus network, broadcast, gateway
    AVAILABLE=$((TOTAL_IPS - IPAM_COUNT))
    echo "[IPAM Status — ${SUBNET}.0/24]"
    echo "  Allocated IPs: $IPAM_COUNT / $TOTAL_IPS"
    echo "  Available IPs: $AVAILABLE"
    echo "  Utilization: $(( (IPAM_COUNT * 100) / TOTAL_IPS ))%"
    if [[ $AVAILABLE -le 0 ]]; then
        echo "  ⚠️  CRITICAL: No IPs available! New containers will fail!"
    elif [[ $AVAILABLE -le 10 ]]; then
        echo "  ⚠️  WARNING: Only $AVAILABLE IPs remaining!"
    fi
else
    echo "[IPAM Status]"
    echo "  IPAM directory not found: $IPAM_DIR"
    echo "  Run deploy.sh or simulate.sh first."
fi
echo ""

# 3. Bridge status
echo "[Bridge Status — $BRIDGE_NAME]"
if ip link show "$BRIDGE_NAME" &>/dev/null; then
    BRIDGE_MEMBERS=$(bridge link show | grep -c "$BRIDGE_NAME" || echo "0")
    echo "  Bridge exists: YES"
    echo "  Attached veth interfaces: $BRIDGE_MEMBERS"
else
    echo "  Bridge exists: NO"
fi
echo ""

# 4. Orphan detection
echo "[Orphan Detection]"
echo "  Checking which namespaces have no associated running process..."
ORPHAN_COUNT=0
ACTIVE_COUNT=0

for ns in $(ip netns list 2>/dev/null | grep "^cni-" | awk '{print $1}' | head -20); do
    # A truly orphaned namespace will have no processes inside it
    PIDS=$(sudo ip netns pids "$ns" 2>/dev/null | wc -l)
    if [[ "$PIDS" -eq 0 ]]; then
        ORPHAN_COUNT=$((ORPHAN_COUNT + 1))
    else
        ACTIVE_COUNT=$((ACTIVE_COUNT + 1))
    fi
done

# Estimate for remaining
REMAINING=$((NS_COUNT - 20))
if [[ $REMAINING -gt 0 ]]; then
    echo "  (Sampled first 20 namespaces, estimating for rest)"
fi
echo "  Orphaned (no processes): ~$ORPHAN_COUNT+ (of $NS_COUNT checked)"
echo "  Active (has processes):  $ACTIVE_COUNT"
echo ""

# 5. Suggestions
echo "[Recommendations]"
echo "  1. Identify orphaned namespaces: no running processes inside"
echo "  2. For each orphaned namespace:"
echo "     - Delete namespace: ip netns del <name>"
echo "     - Remove IPAM file: rm ${IPAM_DIR}/<ip>"
echo "  3. Verify veth pairs are auto-cleaned when namespace is deleted"
echo "  4. Monitor with: watch -n5 'ip netns list | wc -l'"
echo ""
