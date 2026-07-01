#!/bin/bash
# Lab 08: Swap Thrashing
# Creates memory pressure that forces heavy swap usage

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[Lab 08] Deploying: Swap Thrashing"
echo "======================================"

# Get available memory (in MB)
AVAIL_MB=$(awk '/MemAvailable/ {print int($2/1024)}' /proc/meminfo)
echo "[*] Available memory: ${AVAIL_MB}MB"

# We want to consume enough memory to push the system into swap
# but not enough to trigger OOM killer
# Target: consume 80% of available memory with multiple processes
TARGET_MB=$((AVAIL_MB * 60 / 100))
PROCS=4
PER_PROC=$((TARGET_MB / PROCS))

echo "[*] Creating ${PROCS} memory-intensive processes (${PER_PROC}MB each)..."

PIDS=""
for i in $(seq 1 $PROCS); do
    python3 -c "
import time
import sys
data = []
target_mb = ${PER_PROC}
allocated = 0
chunk_size = 50  # MB per chunk
while allocated < target_mb:
    try:
        data.append(bytearray(chunk_size * 1024 * 1024))
        allocated += chunk_size
    except MemoryError:
        break
while True:
    # Touch pages periodically to prevent them from being fully swapped
    for chunk in data:
        _ = chunk[0]
    time.sleep(2)
" &
    PIDS="$PIDS $!"
done

echo "$PIDS" > /tmp/.lab08-pids

# Set high swappiness to encourage swap usage
ORIG_SWAPPINESS=$(cat /proc/sys/vm/swappiness)
echo "$ORIG_SWAPPINESS" > /tmp/.lab08-orig-swappiness
echo 80 > /proc/sys/vm/swappiness 2>/dev/null || true

sleep 5

echo ""
echo "[✓] Lab 08 deployed!"
echo "    Scenario: The system is extremely slow. Users report"
echo "    high latency on all operations. You suspect memory pressure"
echo "    and swap thrashing."
echo ""
echo "    Start investigating with:"
echo "      free -m"
echo "      vmstat 1 5"
echo "      cat /proc/sys/vm/swappiness"
echo "      swapon --show"
