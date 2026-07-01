#!/bin/bash
#
# deploy.sh — Deploy Lab 11: Kernel Soft Lockup
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "============================================"
echo " Deploying Lab 11: Kernel Soft Lockup"
echo "============================================"
echo ""
echo "This lab simulates a kernel soft lockup caused by:"
echo "  - Misconfigured network sysctl tunables"
echo "  - All interrupts pinned to CPU0"
echo "  - Tiny ring buffers on high-speed NIC"
echo "  - NAPI budget too low to process packet flood"
echo ""
echo "Prerequisites:"
echo "  - Linux VM (DO NOT run on production!)"
echo "  - Root/sudo access"
echo "  - ethtool, hping3 or nping (optional for packet gen)"
echo ""

# Apply broken sysctl
echo "[+] Applying broken sysctl configuration..."
sudo cp "${SCRIPT_DIR}/sysctl-broken.conf" /etc/sysctl.d/99-network-tuning.conf
sudo sysctl -p /etc/sysctl.d/99-network-tuning.conf 2>/dev/null || true

echo ""
echo "[+] Verifying broken settings applied:"
echo "    net.core.netdev_budget = $(sysctl -n net.core.netdev_budget 2>/dev/null || echo 'N/A')"
echo "    net.core.netdev_max_backlog = $(sysctl -n net.core.netdev_max_backlog 2>/dev/null || echo 'N/A')"
echo ""
echo "[✓] Lab deployed. Run ./simulate.sh to trigger the soft lockup."
echo ""
echo "============================================"
echo " YOUR TASK: Diagnose and fix the soft lockup"
echo "============================================"
echo ""
echo "Investigate using:"
echo "  sysctl -a | grep netdev"
echo "  cat /proc/interrupts"
echo "  cat /proc/net/softnet_stat"
echo "  ethtool -g <interface>"
echo "  cat /sys/class/net/<iface>/queues/rx-*/rps_cpus"
echo ""
