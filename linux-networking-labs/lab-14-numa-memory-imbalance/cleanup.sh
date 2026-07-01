#!/bin/bash
#
# cleanup.sh — Clean up Lab 14: NUMA Memory Imbalance
#

echo "============================================"
echo " Cleaning up Lab 14: NUMA Memory Imbalance"
echo "============================================"
echo ""

# Kill test processes
echo "[1/3] Stopping simulation processes..."
sudo pkill -f "stress-ng" 2>/dev/null || true
sudo pkill -f "numactl.*dd" 2>/dev/null || true

# Restore sysctl
echo "[2/3] Restoring NUMA sysctl defaults..."
sudo sysctl -w vm.numa_balancing=1 2>/dev/null || true
sudo sysctl -w vm.zone_reclaim_mode=0 2>/dev/null || true
echo "  vm.numa_balancing = $(sysctl -n vm.numa_balancing 2>/dev/null)"
echo "  vm.zone_reclaim_mode = $(sysctl -n vm.zone_reclaim_mode 2>/dev/null)"

# Restart numad if installed
echo "[3/3] Starting numad (if available)..."
sudo systemctl start numad 2>/dev/null || echo "  numad not installed, skipping"

echo ""
echo "[✓] Lab 14 cleaned up successfully."
