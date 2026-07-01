#!/bin/bash
#
# deploy.sh — Deploy Lab 14: NUMA Memory Imbalance
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "============================================"
echo " Deploying Lab 14: NUMA Memory Imbalance"
echo "============================================"
echo ""
echo "This lab simulates NUMA misconfiguration causing 60%"
echo "performance degradation on a dual-socket database server."
echo ""
echo "Prerequisites:"
echo "  - Multi-NUMA node system (2+ sockets)"
echo "  - numactl, numastat installed"
echo "  - stress-ng (for memory allocation simulation)"
echo "  - perf (for NUMA counter measurement)"
echo ""
echo "Install: apt install numactl numad stress-ng linux-tools-\$(uname -r)"
echo ""

# Apply broken settings
echo "[+] Applying broken NUMA configuration..."
sudo sysctl -w vm.numa_balancing=0 2>/dev/null || true
sudo sysctl -w vm.zone_reclaim_mode=0 2>/dev/null || true
sudo systemctl stop numad 2>/dev/null || true

echo ""
echo "Broken settings applied:"
echo "  vm.numa_balancing = $(sysctl -n vm.numa_balancing 2>/dev/null)"
echo "  vm.zone_reclaim_mode = $(sysctl -n vm.zone_reclaim_mode 2>/dev/null)"
echo "  numad: $(systemctl is-active numad 2>/dev/null || echo 'inactive')"
echo ""
echo "[✓] Lab deployed. Run ./simulate.sh to trigger NUMA imbalance."
echo "                   Run ./numa-check.sh for diagnosis."
