#!/bin/bash
#
# cleanup.sh — Clean up Lab 11: Kernel Soft Lockup
#

echo "============================================"
echo " Cleaning up Lab 11: Kernel Soft Lockup"
echo "============================================"

# Kill any packet generators
echo "[1/4] Stopping packet generators..."
sudo pkill -f "hping3" 2>/dev/null || true
sudo pkill -f "nping" 2>/dev/null || true
# Kill background netcat flood loops
sudo pkill -f "nc -u -w0 127.0.0.1 500" 2>/dev/null || true

# Restore sysctl defaults
echo "[2/4] Restoring sysctl defaults..."
sudo rm -f /etc/sysctl.d/99-network-tuning.conf

# Restore sensible defaults
sudo sysctl -w net.core.netdev_budget=300 2>/dev/null || true
sudo sysctl -w net.core.netdev_budget_usecs=2000 2>/dev/null || true
sudo sysctl -w net.core.netdev_max_backlog=1000 2>/dev/null || true
sudo sysctl -w net.core.rmem_max=16777216 2>/dev/null || true
sudo sysctl -w net.core.wmem_max=16777216 2>/dev/null || true
sudo sysctl -w net.core.somaxconn=4096 2>/dev/null || true

# Restore ring buffer
echo "[3/4] Restoring ring buffer..."
INTERFACE="${1:-eth0}"
ORIGINAL_RX=$(cat /tmp/lab11_original_rx_ring 2>/dev/null || echo "256")
sudo ethtool -G "$INTERFACE" rx "$ORIGINAL_RX" 2>/dev/null || true
rm -f /tmp/lab11_original_rx_ring

# Restore IRQ balancing
echo "[4/4] Restarting irqbalance..."
sudo systemctl restart irqbalance 2>/dev/null || true

echo ""
echo "[✓] Lab 11 cleaned up successfully."
