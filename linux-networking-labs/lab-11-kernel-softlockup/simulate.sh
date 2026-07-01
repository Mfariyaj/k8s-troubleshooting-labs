#!/bin/bash
#
# simulate.sh — Simulates the kernel soft lockup scenario
# WARNING: This script applies broken sysctl settings and generates high packet rates
# Run only in a lab/VM environment!
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INTERFACE="${1:-eth0}"

echo "============================================"
echo " Lab 11: Kernel Soft Lockup Simulation"
echo "============================================"
echo ""
echo "WARNING: This will apply broken network tunables and"
echo "generate massive packet traffic. Only run in a lab VM!"
echo ""
read -p "Continue? (yes/no): " confirm
if [[ "$confirm" != "yes" ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "[1/5] Applying broken sysctl settings..."
sudo cp "${SCRIPT_DIR}/sysctl-broken.conf" /etc/sysctl.d/99-network-tuning.conf
sudo sysctl -p /etc/sysctl.d/99-network-tuning.conf 2>/dev/null || true

echo "[2/5] Setting tiny ring buffer on ${INTERFACE}..."
# Save current ring buffer settings
CURRENT_RX=$(ethtool -g "$INTERFACE" 2>/dev/null | grep -A4 "Current" | grep "RX:" | awk '{print $2}')
echo "$CURRENT_RX" > /tmp/lab11_original_rx_ring
sudo ethtool -G "$INTERFACE" rx 64 tx 64 2>/dev/null || echo "  (Could not set ring buffer — may need real NIC)"

echo "[3/5] Pinning all NIC IRQs to CPU0..."
# Find all IRQs for the interface
for irq in $(grep "$INTERFACE" /proc/interrupts | awk -F: '{print $1}' | tr -d ' '); do
    echo 1 | sudo tee /proc/irq/$irq/smp_affinity > /dev/null 2>&1 || true
done

echo "[4/5] Disabling RPS on all queues..."
for queue in /sys/class/net/${INTERFACE}/queues/rx-*/rps_cpus; do
    if [[ -f "$queue" ]]; then
        echo 0 | sudo tee "$queue" > /dev/null 2>&1 || true
    fi
done

echo "[5/5] Generating packet flood (UDP small packets)..."
echo "  Starting packet generator — this will cause CPU0 to spike."
echo "  Monitor with: top (press 1 for per-CPU), watch cat /proc/interrupts"
echo ""

# Generate massive UDP packet flood to localhost or interface
# Using multiple hping3 processes or nping if available
if command -v hping3 &>/dev/null; then
    echo "  Using hping3 for packet generation..."
    for i in $(seq 1 4); do
        sudo hping3 --udp -p $((5000+i)) --faster -d 64 127.0.0.1 &>/dev/null &
    done
elif command -v nping &>/dev/null; then
    echo "  Using nping for packet generation..."
    sudo nping --udp -p 5001 --rate 100000 -c 0 127.0.0.1 &>/dev/null &
else
    echo "  Using netcat + /dev/urandom for packet generation..."
    for i in $(seq 1 8); do
        (while true; do dd if=/dev/urandom bs=64 count=1 2>/dev/null | nc -u -w0 127.0.0.1 $((5000+i)); done) &
    done
fi

PIDS=$(jobs -p)
echo ""
echo "Packet generators running (PIDs: $PIDS)"
echo "To stop: kill $PIDS"
echo ""
echo "============================================"
echo " OBSERVE THE PROBLEM:"
echo "  1. top (press '1' for per-CPU) — see CPU0 at 99% si"
echo "  2. cat /proc/interrupts | grep eth0"
echo "  3. cat /proc/net/softnet_stat"
echo "  4. dmesg -w (watch for soft lockup messages)"
echo "============================================"
